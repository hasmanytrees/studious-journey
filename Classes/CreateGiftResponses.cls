/******************************************************************************************************
Class Name         : CreateGiftResponses
Description        : This class recieves information about various beneficiaries who have received gift
                     and what is the value of that gift in a JSON. It deserealizes that JSON and create
                     gift correspondence items for that along with the communication kits.
Created By         : Rahul Agarwal
Created On         : 27-Jul-2015
******************************************************************************************************/
@
RestResource(urlMapping = '/CreateGiftResponses')
global class CreateGiftResponses {
    /**
     * Method name  : createUpdateCommKitJSON
     * Description  : This method is used to accept the REST call and deserialize the JSON
     * Return Type  : void
     * Parameter    : void
     **/
    @
    HttpPost
    global static void createGiftResponsesJSON() {
        RestRequest request = RestContext.request;
        RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
        String sRequest = request.requestBody.toString()
            .trim();
        // Deserealizing the JSON
        list<Communication_Kit__c> lstCommKitFromJSON = new list <
            Communication_Kit__c>();
        IF(!Test.ISRunningTest()) {
            CommunicationKitHandler.responseForValidationWrapper oDesJSON =
                CommunicationKitHandler.deserializeJson(sRequest, false, Constants.CREATE_GIFT_RESPONSES_REQ_PN);
            system.debug('<><><> ' + oDesJSON);
            if(oDesJSON.bError) {
                populateInternalServerIntegrationError(oDesJSON.oEx, Constants.METHOD_NAME_CREATEGIFTRESPONSES,
                    null);
                return;
            } else {
                lstCommKitFromJSON = (list<Communication_Kit__c> ) oDesJSON.lstSObject;
            }
        }

        set<String> setLegacySupporterId = new set<String>();
        set<String> setLegacyBeneficiaryId = new set<String>();
        set<String> setGlobalSupporterId = new set<String>();
        set<String> setGlobalBeneficiaryId = new set<String>();
        set<String> setLocalBeneficiaryId = new set<String>();

        for(Communication_Kit__c oCommKit: lstCommKitFromJSON) {
            if(oCommKit.COMPASS_con_pk__c != null)
                setLegacySupporterId.add(oCommKit.COMPASS_con_pk__c);
            if(oCommKit.COMPASS_child_id__c != null)
                setLegacyBeneficiaryId.add(oCommKit.COMPASS_child_id__c);
            if(oCommKit.SUP_INT_Id__c != null)
                setGlobalSupporterId.add(oCommKit.SUP_INT_Id__c);
            if(oCommKit.BEN_INT_Id__c != null)
                setGlobalBeneficiaryId.add(oCommKit.BEN_INT_Id__c);
            if(oCommKit.BEN_INT_Local_Id__c != null)
                setLocalBeneficiaryId.add(oCommKit.BEN_INT_Local_Id__c);
        }

        list<Account> lstAllBenAndSup = new list<Account>();
        try {
            lstAllBenAndSup = [select Id, Name, Global_Number__c,
                Local_Beneficiary_Id__c, Compass_Id__c, GP_Supporter_Id__c, RecordTypeId from Account where GP_Supporter_Id__c IN:
                setLegacySupporterId OR Compass_Id__c IN: setLegacyBeneficiaryId OR Global_Number__c IN:
                setGlobalSupporterId OR Global_Number__c IN: setGlobalBeneficiaryId OR Local_Beneficiary_Id__c IN:
                setLocalBeneficiaryId
            ];
        } catch(QueryException oEx) {
            populateInternalServerIntegrationError(oEx, Constants.METHOD_NAME_CREATEGIFTRESPONSES,
                null);
            return;
        }

        list<Commitment__c> lstCommitments = new list<Commitment__c>();
        try {
            lstCommitments = [Select Id, Status__c, Relationship_Type__c, BEN_Id__c,
                SUP_Id__c from Commitment__c where(SUP_Id__r.GP_Supporter_Id__c IN:
                    setLegacySupporterId OR BEN_Id__r.Compass_Id__c IN:
                    setLegacyBeneficiaryId OR SUP_Id__r.Global_Number__c IN:
                    setGlobalSupporterId OR BEN_Id__r.Global_Number__c IN:
                    setGlobalBeneficiaryId OR BEN_Id__r.Local_Beneficiary_Id__c IN:
                    setLocalBeneficiaryId) AND Status__c =: Constants.COMMITMENT_STATUS_ACTIVE
            ];
        } catch(QueryException oEx) {
            populateInternalServerIntegrationError(oEx, Constants.METHOD_NAME_CREATEGIFTRESPONSES,
                null);
            return;
        }
        // store BenId + Supid for all active commitments
        map<String, Commitment__c> mapHaveActiveCommitment = new map<String,
            Commitment__c>();
        for(Commitment__c oCommit: lstCommitments)
            if(oCommit.BEN_Id__c != null && oCommit.SUP_Id__c != null)
                mapHaveActiveCommitment.put(String.ValueOf(oCommit.BEN_Id__c) + String.ValueOf(
                    oCommit.SUP_Id__c), oCommit);

            // Querying Global Data Object
        Id RTCommKitForGlobalData = Utility.getRecordTypeIdByDeveloperName(
            Global_Data__c.SObjectType, Constants.GLOBAL_DATA_COMM_KIT_DATA_RT_API_NAME);
        list<Global_Data__c> lstGlobalData = new list<Global_Data__c>();
        try {
            lstGlobalData = [select Name, Id, Gift_Max_Value__c, Gift_Min_Value__c from Global_Data__c where RecordTypeId = :
                RTCommKitForGlobalData AND Gift_Max_Value__c != null AND Gift_Min_Value__c !=
                null
            ];
        } catch(QueryException oEx) {
            populateInternalServerIntegrationError(oEx, Constants.METHOD_NAME_CREATEGIFTRESPONSES,
                null);
            return;
        }

        // Arranging all supporters and beneficiaries
        map<String, map<String, Account>> mapAccount = new map<String, map <
            String, Account>> {
                Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID => new map<String,
                Account>(),
                Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID => new map<String,
                Account>(),
                Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID => new map<String,
                Account>(),
                Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID => new map<String,
                Account>(),
                Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID => new map<String,
                Account>()
            };

        // Fetching all the recordtype ids
        Id cspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Id cdspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id supporterRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.SUPPORTER_PERSON_RT_API_NAME);

        for(Account oAcc: lstAllBenAndSup) {
            if(oAcc.Local_Beneficiary_Id__c == null && oAcc.Global_Number__c != null)
                mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID)
                .put(oAcc.Global_Number__c,
                    oAcc);
            if(oAcc.GP_Supporter_Id__c != null)
                mapAccount.get(Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID)
                .put(oAcc.GP_Supporter_Id__c,
                    oAcc);
            if(oAcc.Compass_Id__c != null)
                mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID)
                .put(oAcc.Compass_Id__c,
                    oAcc);
            if(oAcc.Local_Beneficiary_Id__c != null && oAcc.Global_Number__c != null)
                mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID)
                .put(oAcc.Global_Number__c,
                    oAcc);
            if(oAcc.Local_Beneficiary_Id__c != null)
                mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID)
                .put(oAcc.Local_Beneficiary_Id__c,
                    oAcc);
        }


        map<String, String> mapBenIdCommKitType = new map<String, String>();
        for(Communication_Kit__c oCommKit: lstCommKitFromJSON) {

            // BENEFICIARY VALIDATIONS

            CommunicationKitHandler.responseForValidationWrapper oBenValidation =
                CommunicationKitHandler.BeneficiaryValidationForIntegrations(oCommKit.BEN_INT_Id__c,
                    oCommKit.COMPASS_child_id__c, oCommKit.BEN_INT_Local_Id__c, mapAccount);
            if(oBenValidation.bError) {
                populateInternalServerIntegrationError(null, Constants.METHOD_NAME_CREATEGIFTRESPONSES,
                    oBenValidation.sValue);
                return;
            } else {
                oCommKit.BEN_ID__c = oBenValidation.sValue;
            }
            // SUPPORRTER VALIDATIONS

            CommunicationKitHandler.responseForValidationWrapper oSupValidation =
                CommunicationKitHandler.SupporterValidationForIntegrations(oCommKit.SUP_INT_Id__c,
                    oCommKit.COMPASS_con_pk__c, oCommKit.Relationship_Type__c, mapAccount);
            if(oSupValidation.bError) {
                populateInternalServerIntegrationError(null, Constants.METHOD_NAME_CREATEGIFTRESPONSES,
                    oSupValidation.sValue);
                return;
            } else {
                oCommKit.SUP_ID__c = oSupValidation.sValue;
            }

            // Checking for Active Commitments

            if(oCommKit.SUP_Id__c != null && oCommKit.BEN_Id__c != null &&
                !mapHaveActiveCommitment.containsKey(String.ValueOf(
                    oCommKit.BEN_Id__c) + String.ValueOf(oCommKit.SUP_Id__c))
            ) {
                populateInternalServerIntegrationError(null,
                    Constants.METHOD_NAME_CREATEGIFTRESPONSES,
                    Constants.ErrorString_31_ACTIVE_COMMITMENT + Constants.ErrorString_12_GLOBAL_BENEFICIARY_ID +
                    Constants.ErrorString_19_HYPHEN +
                    oCommKit.BEN_INT_Id__c + Constants.ErrorString_15_COMMA + Constants.ErrorString_13_LOCAL_BENEFICIARY_ID +
                    Constants.ErrorString_19_HYPHEN + oCommKit.BEN_INT_Local_Id__c +
                    Constants.ErrorString_17_AND +
                    Constants.ErrorString_11_LEGACY_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN +
                    oCommKit.COMPASS_child_id__c + Constants.ErrorString_15_COMMA + Constants.ErrorString_21_GLOBAL_SUPPORTER_ID 
                    + Constants.ErrorString_19_HYPHEN + oCommKit.SUP_INT_Id__c + Constants.ErrorString_15_COMMA + Constants.ErrorString_20_LEGACY_SUPPORTER_ID 
                    + Constants.ErrorString_19_HYPHEN + oCommKit.COMPASS_con_pk__c);
                return;
            }

            // Checking if proper amount was sent or not
            Double dGiftAmount;
            if(oCommkit.INT_RecordType_Name__c == null || oCommkit.INT_RecordType_Name__c ==
                '') {
                populateInternalServerIntegrationError(null,
                    Constants.METHOD_NAME_CREATEGIFTRESPONSES,
                    Constants.ErrorString_26_GIFT_AMOUNT + Constants.ErrorString_1);
                return;
            } else if(oCommkit.INT_RecordType_Name__c != null && oCommkit.INT_RecordType_Name__c !=
                '') {
                try {
                    dGiftAmount = double.ValueOf(oCommkit.INT_RecordType_Name__c);
                } catch(Exception oEx) {
                    populateInternalServerIntegrationError(oEx,
                        Constants.METHOD_NAME_CREATEGIFTRESPONSES, null);
                    return;
                }
            }
            // setting the communication type
            for(Global_Data__c oGD: lstGlobalData) {
                if(oGD.Gift_Min_Value__c != null && oGD.Gift_Max_Value__c !=
                    null) {
                    if(dGiftAmount>= oGD.Gift_Min_Value__c && dGiftAmount <=
                        oGD.Gift_Max_Value__c) {
                        mapBenIdCommKitType.put(oCommkit.BEN_ID__c, oGD.Name);
                    }
                }
            }
        }
        map<Id, Account> mapBeneficiary = new map<Id, Account>();
        try {
            mapBeneficiary = new map<Id, Account> ([Select Id,
                Local_Beneficiary_Id__c from Account where Id IN: mapBenIdCommKitType.keySet()
            ]);
        } catch(QueryException oEx) {

        }
        map<String, String> mapLocalBenIdCommKitType = new map<String, String>
            ();
        for(String iVar: mapBenIdCommKitType.keySet()) {
            mapLocalBenIdCommKitType.put(mapBeneficiary.get(iVar)
                .Local_Beneficiary_Id__c,
                mapBenIdCommKitType.get(iVar));
        }
        CommunicationKitHandler.bSendJSONResponse = true;
        CommunicationKitHandler.findOrCreateCommKitRecordExt(mapLocalBenIdCommKitType, null);



    }

    /**
     * Method name  : populateInternalServerIntegrationError
     * Description  : This method is called whenever we want to add certain error in the JSON response
     * Return Type  : void
     * Parameter    : Exception, String, String
     **/
    private static void populateInternalServerIntegrationError(Exception oEx,
        String sMethodName, String sMessage) {
        RestContext.response.statusCode = 500;
        String sErrorMessage = (String.isBlank(sMessage)) ? oEx.getMessage() :
            sMessage;
        String sJsonResponse =
            Constants.CONTENT_FAILURE_RESPONSE +
            sErrorMessage + '"}}';
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo(Constants.FALIURE, Constants.INBOUND,
            Constants.CLASS_NAME_CREATEGIFTRESPONSES, sMethodName,
            Constants.SOURCE_SYSTEM_SFDC_CI, null, (String.isBlank(sMessage)) ?
            Constants.Commitment_Updates_LineNo + oEx.getLineNumber() +
            Constants.Commitment_Updates_Exec +
            oEx.getMessage() : sMessage, RestContext.request.requestBody
            .toString()
            .trim(), sJsonResponse,
            sJsonResponse, oEx);
    }
}