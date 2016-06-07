/************************************************************************************************** 
Class Name   : FetchBeneficiaryInformation
Created By   : Himanshu Raichandani
Created Date : 03/24/2015
Description  : This class contains Rest method to fetch Beneficiary and it's corresponding Household
               information and send it to requesting client i.e. Neuron
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@RestResource(urlMapping = '/FetchBeneficiaryInformation')
global class FetchBeneficiaryInformation {

    /**********************************
    Method Name : fetchBeneficiaryInfo
    Description : This exposed web service method fetches Beneficiary 
                  and its corresponding Household Info from Salesforce
    Return type : void
    Parameter   : void
    ************************************/
    @HttpPost
    global static void fetchBeneficiaryInfo() {
        RestRequest oRequest = RestContext.request;
        RestResponse oResponse = RestContext.response;
        String sJsonResponse = Constants.EMPTY_STRING;
        RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
        List<Account> lstBenef = new List<Account>();
        List<Id> lstBenefId = new List<Id>();
        List<Account> lstBenefQueried = new List<Account>();
        Boolean ifInsertScenario = false;
        try {
            lstBenef = (List<Account> ) JSONHandlerMethods.deserialize(
                oRequest.requestBody.toString()
                .trim(), Constants.FETCH_BENEF_INFO_REQUEST_PROCESS);
        } catch(Exception oEx) {
            populateInternalServerIntegrationError(oEx, 'fetchBeneficiaryInfo', null);
            return;
        }
        System.debug('lstBenef'+lstBenef);
        String sLocalBenId = lstBenef[0].Local_Beneficiary_ID__c;
        if(String.IsNotEmpty(sLocalBenId)) {
            lstBenefQueried = [Select Id, Compass_Id__c, Review_Status__c, Local_Beneficiary_ID__c from Account where
                Local_Beneficiary_ID__c = : sLocalBenId limit 1
            ];
        }

        if(lstBenefQueried.isEmpty()) {
            oResponse.statusCode = 404;
            sJsonResponse = Constants.BENEFICIARY_RECORD_DOESNT_EXISTS;
            oResponse.responseBody = blob.valueOf(sJsonResponse);
            ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
                'FetchBeneficiaryInformation', 'fetchBeneficiaryInfo',
                'Neuron', null, sJsonResponse, oRequest.requestBody.toString()
                .trim(), sJsonResponse, sJsonResponse, null
            );
            return;
        }

        if(!Label.Review_Status_Approved.equals(lstBenefQueried[0].Review_Status__c)){
           populateInternalServerIntegrationError(null, 'fetchBeneficiaryInfo', 
                        Constants.UNDER_APPROVAL_PROCESS_VALIDATION_FB);
           return;
        }

        lstBenefId.add(lstBenefQueried[0].Id);
        ifInsertScenario = identifyIfInsertScenario(lstBenefQueried[0].Compass_Id__c);
        sendInfoToNeuron(lstBenefId, ifInsertScenario);
        if(ifInsertScenario && String.isNotEmpty(lstBenef[0].Compass_Id__c) 
            && Integer.valueOf(lstBenef[0].Compass_Id__c)>100) {
            updateCompassId(lstBenefQueried, lstBenef);
        }
    }

    /**********************************
    Method Name : updateCompassId
    Description : This method updates CompassId only if this is
                  insert scenario
    Return type : void
    Parameter   : List<Account>
    ************************************/
    private static void updateCompassId(List<Account> lstBenef, List<Account>
        lstBenefFromNeuron) {

        Account oBenefToUpdate = lstBenef[0];
        oBenefToUpdate.Compass_Id__c = lstBenefFromNeuron[0].Compass_Id__c;

        try {
            update oBenefToUpdate;
        } catch(DMLException oEx) {
            populateInternalServerIntegrationError(oEx, 'updateCompassId',
                null);
            return;
        }
    }

    /**********************************
    Method Name : identifyIfInsertScenario
    Description : This method identifies if this is insert scenario or not
                  based on Compass Id.
    Return type : Boolean
    Parameter   : Id
    ************************************/
    private static Boolean identifyIfInsertScenario(String sCompassId) {
        
        if(String.isNotEmpty(sCompassId) && Integer.valueOf(sCompassId)>100){
            return false;
        }else{ 
            return true;
        }
    }

    /**
    * Method name  : sendInfoToNeuron
    * Description  : This method first fetches all Beneficiaries based on List<Id> sent as argument to this method.
                     Once beneficaires are fetched, corresponding Household and Household Member details are also 
                     fetched and sent to Neuron.
    * Return Type  : void
    * Parameter    : List<Id> ,Boolean 
    **/
    public static void sendInfoToNeuron(List<Id> lstBenefId, Boolean bIsInsert) {
        String sFieldsQuery = Utility.getFieldGroupElements(Constants.BENEFICIARY_RESPONSE_FIELD_GROUP);
        String sQuery = 'Select ' + sFieldsQuery +
            'ICP__r.name,Tutor_Implementer_Name__r.name,Household__r.Name,Existing_Beneficiary__r.name,Primary_Caregiver__r.Name,Owner.Name,Beneficiary_Favorite_Project_Activities__c,Household__c,Household__r.Natural_Father_Living_With_Child__c,Household__r.Natural_Mother_Living_With_Child__c,Household__r.Total_Family_Females__c,Household__r.Total_Family_Males_18__c,Household__r.Natural_Father_IsAlive__c,Household__r.Natural_Mother_IsAlive__c,Household__r.Male_Occupation__c,Household__r.Female_Occupation__c,Household__r.Male_Employment_Status__c,Household__r.Female_Employment_Status__c,Household__r.Marital_Status__c,Household__r.Together_Now__c';
        sQuery += ' from Account where Id IN:lstBenefId';
        List<Account> lstbeneficiary = new List<Account>();
        try {
            lstbeneficiary = Database.query(sQuery);
        } catch(System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'FetchBeneficiaryInformation',
                'sendInfoToNeuron', 'SFDC CI');
            RestContext.response.statusCode = 500;
            String sJsonResponse = Constants.SFDC_ERROR_RESPONSE;
            RestContext.response.responseBody = blob.valueOf(sJsonResponse);
            return;
        }
        Map<Id, List<Id>> mapHouseholdIdToBenIdList = new Map<Id, List<Id>>
            ();
        Map<Id, List<Household_Member__c>> mapBenWithHouseholdMembers = new Map <
            Id, List<Household_Member__c>>();

        if(!lstbeneficiary.isEmpty()) {
            for(Account oBeneficiary: lstbeneficiary) {
                if(mapHouseholdIdToBenIdList.containsKey(oBeneficiary.Household__c)) {
                    mapHouseholdIdToBenIdList.get(oBeneficiary.Household__c)
                        .add(oBeneficiary.Id);
                } else {
                    mapHouseholdIdToBenIdList.put(oBeneficiary.Household__c, new List<Id> {
                        oBeneficiary.Id
                    });
                }
            }
        }
        if(!mapHouseholdIdToBenIdList.isEmpty()) {
            Set<Id> setHouseholdIds = mapHouseholdIdToBenIdList.keyset();
            String sFieldsHMQuery = Utility.getFieldGroupElements(Constants.HM_WITH_BEN_RESPONSE_FIELD_GROUP);
            String sQueryHM = 'Select ' + sFieldsHMQuery + 'Id';
            sQueryHM +=
                ' from Household_Member__c where Household__c IN:setHouseholdIds';
            List<Household_Member__c> lstHouseholdMem = new List <
                Household_Member__c>();
            try {
                lstHouseholdMem = Database.query(sQueryHM);
            } catch(System.QueryException oQe) {
                ErrorLogUtility.logGeneralError(oQe, 'FetchBeneficiaryInformation',
                    'sendInfoToNeuron', 'SFDC CI');
                RestContext.response.statusCode = 500;
                String sJsonResponse = Constants.SFDC_ERROR_RESPONSE;
                RestContext.response.responseBody = blob.valueOf(sJsonResponse);                    
                return;
            }
            for(Household_Member__c oHouseholdMember: lstHouseholdMem) {
                for(Id benefId: mapHouseholdIdToBenIdList.get(oHouseholdMember.Household__c)) {
                    if(mapBenWithHouseholdMembers.containsKey(benefId)) {
                        mapBenWithHouseholdMembers.get(benefId)
                            .add(oHouseholdMember);
                    } else {
                        mapBenWithHouseholdMembers.put(benefId, new List<Household_Member__c> {
                            oHouseholdMember
                        });
                    }
                }
            }
        }

        List<Map<String, List<sObject>>> lstOutputMap = new List<Map <
            String, List<sObject>>>();
        for(Account oAccount: lstbeneficiary) {
            updateBeneficiaryDetails(oAccount, bIsInsert);
            Map<String, List<sObject>> mapOutputVar = new Map<String, List <
                sObject>>();
            mapOutputVar.put(Constants.BENEFICIARY_RESPONSE_FIELD_GROUP, new List <
                sObject> {
                    oAccount
                });
            if(mapBenWithHouseholdMembers.keySet()
                .contains(oAccount.Id)) {
                mapOutputVar.put(Constants.HM_WITH_BEN_RESPONSE_FIELD_GROUP,
                    mapBenWithHouseholdMembers.get(oAccount.Id));
            } else {
                mapOutputVar.put(Constants.HM_WITH_BEN_RESPONSE_FIELD_GROUP, new List <
                    Household_Member__c>());
            }
            lstOutputMap.add(mapOutputVar);
        }

        for(Map<String, List<sObject>> mapEachVar: lstOutputMap) {
            String sResponse;
            try {
                sResponse = JSONHandlerMethods.serialize(mapEachVar, Constants.BEN_HM_DATA_RESPONSE_PROCESS_NAME);
                sResponse = sResponse.replace('/', ' and ');
                sResponse = sResponse.replace('\"null\"', '\"\"');
                sResponse = sResponse.replace('\\\'','\''); //Added By Ankit
                system.debug('-----JSON STRUCTURE----' + sResponse);
            } catch(Exception oExp) {
                ErrorLogUtility.logGeneralError(oExp, 'FetchBeneficiaryInformation',
                    'sendInfoToNeuron', 'SFDC CI');
                return;
            }
            RestContext.response.responseBody = Blob.valueOf(sResponse);
            ErrorLogUtility.logIntegrationInfo('Success', 'Inbound',
                'FetchBeneficiaryInformation', 'sendInfoToNeuron',
                '', null, 'Success in retrieving Beneficiary information', RestContext.request
                .requestBody.toString()
                .trim(), sResponse, 'OK', null);
        }
    }

    /**
    * Method name  : updateBeneficiaryDetails
    * Description  : This method updates information which is not directly present in Account object, 
                     these info is fetched through relations and mapped to some dummy fields so that 
                     it can be finally mapped to JSON Token which will be eventually sent to Neuron
    * Return Type  : void
    * Parameter    : Account,Boolean
    **/
    private static void updateBeneficiaryDetails(Account oBenef, Boolean bIsInsert) {
        oBenef.Educational_Description_Context_Needs__c = Constants.CSP.equals(oBenef.Active_Program__c) ?
            Constants.CSP_BENEFICIARY_RT_LABEL : Constants.CDSP_BENEFICIARY_RT_LABEL; //For AccountRecordType
        oBenef.Economic_Description_Context_Needs__c = oBenef.Owner.Name; //For AccountOwner
        oBenef.Known_Complications__c = (null == oBenef.Primary_Caregiver__c) ? null :
          oBenef.Primary_Caregiver__r.Name; //For CaregiverName
        oBenef.Available_Banks__c = (null == oBenef.Existing_Beneficiary__c) ? null :
            oBenef.Existing_Beneficiary__r.name; //For ExistingBeneficiaryName
        oBenef.Available_Courier_Services__c = oBenef.ICP__r.name; //For ICPName
        oBenef.External_Resources_Available__c = (null == oBenef.Tutor_Implementer_Name__c) ?
            null : oBenef.Tutor_Implementer_Name__r.name; //For TutorImplementerName
        oBenef.CRCH_Project__c = (null == oBenef.Household__c) ? null : oBenef.Household__r
            .Name; //For HouseholdName
        oBenef.Acceptance_Of_Agreement_Renewal__c = (null == oBenef.Household__c) ?
            null : oBenef.Household__r.Natural_Father_Living_With_Child__c;
        oBenef.Breast_Feeding_At_Registration__c = (null == oBenef.Household__c) ?
            null : oBenef.Household__r.Natural_Mother_Living_With_Child__c;
        oBenef.Breast_Feeding_Status__c = (null == oBenef.Household__c) ? null :
            oBenef.Household__r.Natural_Father_IsAlive__c;
        oBenef.Caregiver_HIV_Status__c = (null == oBenef.Household__c) ? null :
            oBenef.Household__r.Natural_Mother_IsAlive__c;
        oBenef.CGV_Pregnancy_Status__c = (null == oBenef.Household__c) ? null :
            oBenef.Household__r.Male_Occupation__c;
        oBenef.CDSP_Status__c = (null == oBenef.Household__c) ? null : oBenef.Household__r
            .Female_Occupation__c;
        oBenef.Building_Ownership__c = (null == oBenef.Household__c) ? null : oBenef
            .Household__r.Male_Employment_Status__c;
        oBenef.CDPR_Frequency__c = (null == oBenef.Household__c) ? null : oBenef.Household__r
            .Total_Family_Females__c;
        oBenef.Max_Age_Limit_of_Beneficiary__c = (null == oBenef.Household__c) ? null : oBenef.Household__r
            .Total_Family_Males_18__c;
        oBenef.Leadership_Style__c = (null == oBenef.Household__c) ? null : oBenef.Household__r
            .Female_Employment_Status__c;
        oBenef.Legal_Status__c = (null == oBenef.Household__c) ? null : oBenef.Household__r
            .Marital_Status__c;
        oBenef.Locale__c = (null == oBenef.Household__c) ? null : oBenef.Household__r
            .Together_Now__c;
        oBenef.Written_By_Laws__c = bIsInsert;
    }
    
    /**********************************
    Method Name : populateInternalServerIntegrationError
    Description : This method logs integration info into Error Log objects by
                  calling ErrorLogUtility class
    Return type : void
    Parameter   : Exception oEx, String sMethodName, String sMessage
    ************************************/
    private static void populateInternalServerIntegrationError(Exception oEx,
        String sMethodName, String sMessage) {
        RestContext.response.statusCode = 500;
        String sJsonResponse = (String.isBlank(sMessage)) ? oEx.getMessage() : sMessage;
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
            'FetchBeneficiaryInformation', sMethodName,
            'SFDC CI', null, (String.isBlank(sMessage)) ? 'Line Number: ' + oEx.getLineNumber() +
            ' Exception: ' +
            oEx.getMessage() : sMessage, RestContext.request.requestBody.toString()
            .trim(), sJsonResponse,
            sJsonResponse, oEx);
    }
}