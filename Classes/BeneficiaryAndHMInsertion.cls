/************************************************************************************************** 
Class Name   : BeneficiaryAndHMInsertion
Created By   : Nayana Prabhakar
Created Date : 02/05/2015
Description  : This class is used for Bolivia Integration functionality.
               It inserts/updates the Beneficiary, its corresponding Household and listed 
               Household Members information sent by Bolivia system. 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@RestResource(urlMapping = '/CreateBeneficiary')
global class BeneficiaryAndHMInsertion {
    
    public static boolean errorFlag = True;
    public static boolean updateHouseholdFlag = True;
    public static String updateHouseholdError;
    public static String updateHouseholdName;
    
    /**
    * Method name  : createBenefAndHM
    * Description  : This method is exposed for Bolivia Integration. This method creates Beneficiary,
                     its corresponding Household and listed Household Members. 
                     This method supports all use cases like new Beneficiary with existing Household
                     OR existing Beneficiary with existing Household but new household members and so on.
    * Return Type  : void
    * Parameter    : NA
    **/
    @HttpPost
    global static void createBenefAndHM() {
        RestRequest request = RestContext.request;
        RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
        List<SObject> lstSObject = null;
        try {
            lstSObject = (List<SObject> ) JSONHandlerMethods.deserialize(
                request.requestBody.toString()
                .trim(), Constants.CREATE_BENEFICIARY_PROCESS_NAME);
        } catch(Exception oEx) {
            populateInternalServerIntegrationError(oEx, 'createBenefAndHM', null);
            return;
        }

        Account oBenefReturned = new Account();
        List<Household_Member__c> lstHMReturned = new List<Household_Member__c>
            ();
        List<Household_Member__c> lstHMToUpsert = new List<Household_Member__c>
            ();
        Map<HouseholdMemberKey, Household_Member__c> mapHMKeyToHMObject = new Map <
            HouseholdMemberKey, Household_Member__c>();
        Household__c oConcernedHousehold = null;
        Account oBenefPersisted = null;
        String sHouseholdName;
        Savepoint oSavePoint = Database.setSavepoint();

        for(SObject obj: lstSObject) {
            if(obj instanceof Account) {
                oBenefReturned = (Account) obj;
            } else if(obj instanceof Household_Member__c) {
                lstHMReturned.add((Household_Member__c) obj);
            }
        }
        
        if(String.isEmpty(oBenefReturned.Local_Beneficiary_Id__c)){
            populateInternalServerIntegrationError(null,'createBenefAndHM',Constants.LOCAL_BENEFICIARY_ID_VALIDATION);
            return;
        }else if(String.isNotEmpty(oBenefReturned.Compass_Id__c) 
                 && Integer.valueOf(oBenefReturned.Compass_Id__c) > 100
                 && checkIfTransferScenario(oBenefReturned)){
           populateInternalServerIntegrationError(null, 'createBenefAndHM', Label.Bolivia_Transfer_Benef_Error);
        }
        else if(checkIfBenefStatusIsInactive(oBenefReturned)){
           populateInternalServerIntegrationError(null, 'createBenefAndHM', Constants.BENEFICIARY_INACTIVE_VALIDATION);
        }
        else if(checkIfBenefUnderApprovalProcess(oBenefReturned)){
           populateInternalServerIntegrationError(null, 'createBenefAndHM', Constants.UNDER_APPROVAL_PROCESS_VALIDATION);
        }
        else{
          sHouseholdName = oBenefReturned.CRCH_Project__c;
          if(String.isNotBlank(oBenefReturned.CRCH_Project__c)) {
              oConcernedHousehold = updateHousehold(oBenefReturned, oConcernedHousehold,
                  mapHMKeyToHMObject);
                try {
                    if(oConcernedHousehold == null) {
                        return;
                    } else {
              updateHouseholdMember(lstHMReturned, lstHMToUpsert, mapHMKeyToHMObject,
                  oConcernedHousehold, oBenefReturned);
          }
                } catch(Exception oEx) {
                    string errorMessage = '';
                    if(oEx != null) {
                        if(oBenefReturned.CRCH_Project__c == null) {
                            errorMessage = 'Household Name is null';
                        }
                    }
                    populateInternalServerIntegrationError(oEx, 'checkIfHouseholdExists',
                        errorMessage);
                }
            }
            oBenefPersisted = updateBeneficiaryInformation(oBenefReturned,
                oConcernedHousehold, oBenefPersisted, oSavePoint);
          if(String.isNotBlank(sHouseholdName) && null<> oBenefPersisted)
              createHMForBenef(oBenefPersisted, oConcernedHousehold);
  
          if(null<> oBenefPersisted) {
              ErrorLogUtility.logIntegrationInfo('Success', 'Inbound',
                  'BeneficiaryAndHMInsertion', 'createBenefAndHM',
                  'SFDC CI', null, 'Success in Bolivia Integration', request.requestBody.toString()
                  .trim(), 'OK', 'OK',null);
          }
        }
    }

    /**
     * Method name  : updateHousehold
     * Description  : This method udpates Household Information based on data sent by Bolivia and queried data from DB
     * Return Type  : Household__c
     * Parameter    : Account oBenefReturned, Household__c oConcernedHousehold,Map<HouseholdMemberKey,Household_Member__c> mapHMKeyToHMObject
     **/
    private static Household__c updateHousehold(Account oBenefReturned,
        Household__c oConcernedHousehold, Map<HouseholdMemberKey,
        Household_Member__c> mapHMKeyToHMObject) {

        List<Household__c> lstHousehold = new List<Household__c>();
        list<Account> lstBeneficiary = new list<Account>();
        try {
            lstBeneficiary = [select Id, Household__c from Account where Local_Beneficiary_Id__c = :
                oBenefReturned.Local_Beneficiary_Id__c limit 1 ];
            if(!lstBeneficiary.IsEmpty()) {
                Id HouseHoldId = lstBeneficiary[0].Household__c;
                lstHousehold = [Select Id, Name, Natural_Father_IsAlive__c,
                    Natural_Mother_IsAlive__c, Male_Occupation__c, Female_Occupation__c,
                    Male_Employment_Status__c, Female_Employment_Status__c,
                    Marital_Status__c,
                    Together_Now__c from Household__c where Id = : HouseHoldId limit 1
                ];
            }
        } catch(QueryException oQEx) {
            populateInternalServerIntegrationError(oQEx, 'updateHousehold', null);
            return null;
        }
        
        if(lstHousehold.isEmpty()) {

            oConcernedHousehold = new Household__c();
            oConcernedHousehold = mapHouseholdFields(oBenefReturned,
                oConcernedHousehold);
            List<Household__c> lstHouseholdToInsert = new List<Household__c> {
                oConcernedHousehold};
            
            List<Database.SaveResult> lstUpdateResults = Database.insert(
                lstHouseholdToInsert, false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults, lstHouseholdToInsert,
                    'Household__c',
                    'BeneficiaryAndHMInsertion', 'updateHousehold', 'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                String sErrorMessage = Constants.EMPTY_STRING;
                for(String sError:mapIdToErrorMsg.get(oConcernedHousehold.Id)){
                    sErrorMessage+=sError+Constants.SPACE_STRING;
                }
                populateInternalServerIntegrationError(null, 'updateHousehold', 'Creation failed for Household Name: '
                            + oConcernedHousehold.Name+'. Error: '+sErrorMessage);
                return null;
            }
            
        } else {
            oConcernedHousehold = lstHousehold[0];
            oConcernedHousehold = mapHouseholdFields(oBenefReturned,
                oConcernedHousehold);
            List<Household__c> lstHouseholdToUpdate = new List<Household__c> {
                oConcernedHousehold};
            List<Database.SaveResult> lstUpdateResults = Database.update(
                lstHouseholdToUpdate, false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults, lstHouseholdToUpdate,
                    'Household__c',
                    'BeneficiaryAndHMInsertion', 'updateHousehold', 'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                String sErrorMessage = Constants.EMPTY_STRING;
                for(String sError:mapIdToErrorMsg.get(oConcernedHousehold.Id)){
                    sErrorMessage+=sError+Constants.SPACE_STRING;
                }
                populateInternalServerIntegrationError(null, 'updateHousehold','Creation failed for Household Name: '
                   + oConcernedHousehold.Name+'. Error: '+sErrorMessage);
                updateHouseholdError = sErrorMessage;
                updateHouseholdName = oConcernedHousehold.Name;
                updateHouseholdFlag = False;
                return null;
            }
        }
            List<Household_Member__c> lstHMQueried = null;
            try {
                lstHMQueried = [Select Id, Name, Household__c,
                    Is_Caregiver__c, Role__c, Is_Caregiver_Text_from_Neuron__c from Household_Member__c where Household__c = :
                    oConcernedHousehold.Id
                ];
            } catch(Exception oEx) {
                populateInternalServerIntegrationError(oEx, 'updateHousehold', null);
                return null;
            }
            if(!lstHMQueried.isEmpty()) {
                for(Household_Member__c oHouseholdMember: lstHMQueried) {
                    mapHMKeyToHMObject.put(new HouseholdMemberKey(oHouseholdMember.Name,
                        oHouseholdMember.Role__c), oHouseholdMember);
                }
            }
        return oConcernedHousehold;
    }

    /**
     * Method name  : mapHouseholdFields
     * Description  : This method maps Household Information based on data sent by Bolivia.
     * Return Type  : Household__c
     * Parameter    : Account oBenefReturned,Household__c oConcernedHousehold
     **/
    private static Household__c mapHouseholdFields(Account oBenefReturned,
        Household__c oConcernedHousehold) {
        oConcernedHousehold.Name = oBenefReturned.CRCH_Project__c;
        oConcernedHousehold.Natural_Father_IsAlive__c = oBenefReturned.Breast_Feeding_Status__c;
        oConcernedHousehold.Natural_Mother_IsAlive__c = oBenefReturned.Caregiver_HIV_Status__c;
        oConcernedHousehold.Male_Occupation__c = oBenefReturned.CGV_Pregnancy_Status__c;
        oConcernedHousehold.Female_Occupation__c = oBenefReturned.CDSP_Status__c;
        oConcernedHousehold.Male_Employment_Status__c = oBenefReturned.Building_Ownership__c;
        oConcernedHousehold.Female_Employment_Status__c = oBenefReturned.Leadership_Style__c;
        oConcernedHousehold.Marital_Status__c = oBenefReturned.Legal_Status__c;
        oConcernedHousehold.Together_Now__c = oBenefReturned.Locale__c;
        if(oBenefReturned.Travel_Time_To_Nearest_Medical_Facility__c<> null) {
            oConcernedHousehold.Natural_Father_Living_With_Child__c = boolean.valueOf(
                oBenefReturned.Travel_Time_To_Nearest_Medical_Facility__c);
        }
        if(oBenefReturned.Primary_Language__c<> null) {
            oConcernedHousehold.Natural_Mother_Living_With_Child__c = boolean.valueOf(
                oBenefReturned.Primary_Language__c);
        }
        return oConcernedHousehold;
    }

    /**
     * Method name  : updateHouseholdMember
     * Description  : This method udpates Household Member Information based on data sent by Bolivia and queried data from DB.
     * Return Type  : void
     * Parameter    : List<Household_Member__c> lstHMReturned,List<Household_Member__c> lstHMToUpsert,Map<HouseholdMemberKey,
                      Household_Member__c> mapHMKeyToHMObject,Household__c oConcernedHousehold
     **/
    private static void updateHouseholdMember(List<Household_Member__c>
        lstHMReturned, List<Household_Member__c> lstHMToUpsert, Map <
        HouseholdMemberKey, Household_Member__c> mapHMKeyToHMObject, Household__c oConcernedHousehold,
        Account oBenefReturned){
        
        Household_Member__c oTempHM = null;
        HouseholdMemberKey oTempKey = null;
        try {
        for(Household_Member__c oHouseholdMember: lstHMReturned) {
            oTempKey = new HouseholdMemberKey(oHouseholdMember.Name, oHouseholdMember.Role__c);
            if(null<> mapHMKeyToHMObject.keySet() && mapHMKeyToHMObject.keySet()
                .contains(oTempKey)) {
                oTempHM = mapHMKeyToHMObject.get(oTempKey);
                if(oHouseholdMember.Is_Caregiver_Text_from_Neuron__c<> null)
                    oTempHM.Is_Caregiver__c = Boolean.valueOf(oHouseholdMember.Is_Caregiver_Text_from_Neuron__c);
                oTempHM.Role__c = oHouseholdMember.Role__c;
                lstHMToUpsert.add(oTempHM);
            } else {
                oHouseholdMember.Household__c = oConcernedHousehold.Id;
                oHouseholdMember.Is_Caregiver__c = Boolean.valueOf(oHouseholdMember.Is_Caregiver_Text_from_Neuron__c);
                lstHMToUpsert.add(oHouseholdMember);
                }
            }
        } catch(Exception oEx) {
            string errorMessage = '';
            if(oEx != null) {
                if(oBenefReturned.CRCH_Project__c == null) {
                    errorMessage = 'Household Name is null';
                }
            }

            if(errorFlag) {
                populateInternalServerIntegrationError(oEx, 'checkIfHouseholdExists',
                    errorMessage);
                errorFlag = false;
            } else if(!updateHouseholdFlag) {
                populateInternalServerIntegrationError(null, 'updateHousehold',
                    'Creation failed for Household Name: ' + updateHouseholdName +
                    '. Error: ' + updateHouseholdError);
            }
        }
        List<Database.UpsertResult> lstUpdateResults = Database.upsert(
            lstHMToUpsert, false);
        Map<Id, List<String>> mapIdToErrorMsg =
            ErrorLogUtility.logDMLError(lstUpdateResults, lstHMToUpsert,
                'Household_Member__c',
                'BeneficiaryAndHMInsertion', 'updateHouseholdMember', 'SFDC CI', false);
        if(!mapIdToErrorMsg.isEmpty()) {
            String sErrorMessage = Constants.EMPTY_STRING;
            for(Id householdMemId : mapIdToErrorMsg.keySet()){
                for(String sError:mapIdToErrorMsg.get(householdMemId)){
                    sErrorMessage+=sError+Constants.SPACE_STRING;
                }
            }
            populateInternalServerIntegrationError(null, 'updateHouseholdMember','Update failed for Household Members List: '
                             + lstHMToUpsert+'. Error: '+sErrorMessage);
        }
    }

    /**
     * Method name  : updateBeneficiaryInformation
     * Description  : This method udpates Beneficiary Information based on data sent by Bolivia and queried data from DB.
     * Return Type  : void
     * Parameter    : Account oBenefReturned, Household__c oConcernedHousehold, Account oBenefPersisted, SavePoint oSavePoint
     **/
    private static Account updateBeneficiaryInformation(Account oBenefReturned,
        Household__c oConcernedHousehold, Account oBenefPersisted, SavePoint oSavePoint) {

        String sFieldsQueryString = Utility.getFieldGroupElements(Constants.CREATE_BENEFICIARY_FIELD_GROUP);
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        String sLocalBenId = oBenefReturned.Local_Beneficiary_Id__c;
        String sQuery = Constants.EMPTY_STRING;
        List<Account> lstBenefQueried = new list<Account>();
        try {
            sQuery = 'Select ' + sFieldsQueryString +
                'RecordTypeId from Account where Local_Beneficiary_Id__c =\'' +
                sLocalBenId + '\' limit 1';
            lstBenefQueried = Database.query(sQuery);
        } catch(Exception oEx) {
            populateInternalServerIntegrationError(oEx, 'updateBeneficiaryInformation',
                null);
            return null;
        }

        List<Fields_for_relationship_mapping__c> lstDummyFields =
            Fields_for_relationship_mapping__c.getall()
            .values();
        set<String> setAPINames = new set<String>();
        for(Fields_for_relationship_mapping__c oEachField: lstDummyFields) {
            Fields_for_relationship_mapping__c oField =
                Fields_for_relationship_mapping__c.getInstance(oEachField.Name);
            string APIName = oField.Field_API__c;
            setAPINames.add(APIName);
        }

        /*If lstBenefQueried is not empty, it implies we need to udpate existing Beneficiary*/
        if(!lstBenefQueried.isEmpty()) {
            try {
            Account oBenefQueried = lstBenefQueried.get(0);
            String[] lstField = sFieldsQueryString.split(Constants.COMMA);
            for(String sFieldName: lstField) {
                if(!setAPINames.contains(sFieldName) && null<>oBenefReturned.get(sFieldName)) {
                    oBenefQueried.put(sFieldName, oBenefReturned.get(sFieldName));
                }
            }

            oBenefQueried.Household__c = (null == oConcernedHousehold) ? null :
                oConcernedHousehold.Id;
            oBenefQueried.Primary_Caregiver__c = fetchPrimaryCaregiverId(oBenefReturned
                .Known_Complications__c, oConcernedHousehold.Id,true);

            oBenefQueried.RecordTypeId = (Constants.CSP_BENEFICIARY_RT_LABEL.equals(
                    oBenefReturned.Educational_Description_Context_Needs__c)) ? cspRecTypeId :
                cdspRecTypeId;
            oBenefQueried.Existing_Beneficiary__c = (null == oBenefReturned.Available_Banks__c) ?
                null : fetchExistingBeneficiaryId(oBenefReturned.Available_Banks__c);
            oBenefQueried.ICP__c = (null == oBenefReturned.Who_Attended_Birth__c) ?
                null : fetchICPId(oBenefQueried.Who_Attended_Birth__c);
            oBenefQueried.Tutor_Implementer_Name__c = (null == oBenefReturned.External_Resources_Available__c) ?
                null : fetchTutorImplementerId(oBenefReturned.External_Resources_Available__c,
                    oBenefQueried.ICP__c);
            oBenefQueried.Local_Beneficiary_Number__c = oBenefReturned.Local_Beneficiary_Id__c
                .Substring(5, 9);
            list<String> lstBenName = new list<String>();
            lstBenName = oBenefQueried.LastName.split(Constants.SPACE_STRING);
            oBenefQueried.FirstName = lstBenName[0];
            oBenefQueried.LastName = Constants.EMPTY_STRING;
            for(Integer i = 1; i<lstBenName.size(); i++) {
                oBenefQueried.LastName = oBenefQueried.LastName + lstBenName[i] +
                    Constants.SPACE_STRING;
            }
            if(oBenefQueried.ICP__c == null) {
                Database.rollback(oSavePoint);
                populateInternalServerIntegrationError(null,'updateBeneficiaryInformation',
                            Constants.ICP_ID_VALIDATION +oBenefQueried.Who_Attended_Birth__c);
                return null;
            }

            List<Account> lstBenefToUpdate = new List<Account> {
                oBenefQueried};
            List<Database.SaveResult> lstUpdateResults = Database.update(
                lstBenefToUpdate, false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults, lstBenefToUpdate, 'Account',
                    'BeneficiaryAndHMInsertion', 'updateBeneficiaryInformation', 'SFDC CI',
                    false);
            if(!mapIdToErrorMsg.isEmpty()) {
                String sErrorMessage = Constants.EMPTY_STRING;
                for(String sError:mapIdToErrorMsg.get(oBenefQueried.Id)){
                    sErrorMessage+=sError+Constants.SPACE_STRING;
                }
                Database.rollback(oSavePoint);
                populateInternalServerIntegrationError(null,'updateBeneficiaryInformation',sErrorMessage);
                return null;
            }
            return oBenefQueried;
            } catch(Exception oEx) {
                string errorMessage = '';
                if(oEx != null) {
                    if(oBenefReturned.CRCH_Project__c == null) {
                        errorMessage = 'Household Name is null';
                    }
                }

                if(errorFlag) {
                    populateInternalServerIntegrationError(oEx, 'checkIfHouseholdExists',
                        errorMessage);
                } else if(!updateHouseholdFlag) {
                    populateInternalServerIntegrationError(oEx,
                        'HouseholdExistsCreationFailed', updateHouseholdError);
                }
                return null;
            }
        } else {
            /*Else We just need to create new Beneficiary*/
            oBenefReturned.RecordTypeId = (Constants.CSP_BENEFICIARY_RT_LABEL.equals(
                    oBenefReturned.Educational_Description_Context_Needs__c)) ? cspRecTypeId :
                cdspRecTypeId;
            oBenefReturned.Review_Status__c = Label.Review_Status_Approved;
            System.debug('oConcernedHousehold: ' + oConcernedHousehold);
            oBenefReturned.Household__c = (null == oConcernedHousehold) ? null :
                oConcernedHousehold.Id;

            oBenefReturned.Existing_Beneficiary__c = (null == oBenefReturned.Available_Banks__c) ?
                null : fetchExistingBeneficiaryId(oBenefReturned.Available_Banks__c);
            oBenefReturned.ICP__c = (null == oBenefReturned.Who_Attended_Birth__c) ?
                null : fetchICPId(oBenefReturned.Who_Attended_Birth__c);
            oBenefReturned.Tutor_Implementer_Name__c = (null == oBenefReturned.External_Resources_Available__c) ?
                null : fetchTutorImplementerId(oBenefReturned.External_Resources_Available__c,
                    oBenefReturned.ICP__c);
            oBenefReturned.Primary_Caregiver__c = fetchPrimaryCaregiverId(
                oBenefReturned.Known_Complications__c, oBenefReturned.Household__c, false);
            if(oBenefReturned.ICP__c == null) {
                Database.rollback(oSavePoint);
                populateInternalServerIntegrationError(null,'updateBeneficiaryInformation',
                            Constants.ICP_ID_VALIDATION +oBenefReturned.Who_Attended_Birth__c);
                return null;
            }
            oBenefReturned.Local_Beneficiary_Number__c = oBenefReturned.Local_Beneficiary_Id__c
                .Substring(5, 9);
            for(String sFieldAPI: setAPINames) {
                oBenefReturned.put(sFieldAPI, null);
            }

            list<String> lstBenName = new list<String>();
            lstBenName = oBenefReturned.LastName.split(Constants.SPACE_STRING);
            oBenefReturned.FirstName = lstBenName[0];
            oBenefReturned.LastName = Constants.EMPTY_STRING;
            for(Integer i = 1; i<lstBenName.size(); i++) {
                oBenefReturned.LastName = oBenefReturned.LastName + lstBenName[i] +
                    Constants.SPACE_STRING;
            }

            List<Account> lstBenefToInsert = new List<Account> {
                oBenefReturned};
            List<Database.SaveResult> lstUpdateResults = Database.insert(
                lstBenefToInsert, false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults, lstBenefToInsert, 'Account',
                    'BeneficiaryAndHMInsertion', 'updateBeneficiaryInformation', 'SFDC CI',
                    false);
            if(!mapIdToErrorMsg.isEmpty()) {
                String sErrorMessage = Constants.EMPTY_STRING;
                for(String sError:mapIdToErrorMsg.get(oBenefReturned.Id)){
                    sErrorMessage+=sError+Constants.SPACE_STRING;
                }
                Database.rollback(oSavePoint);
                populateInternalServerIntegrationError(null,'updateBeneficiaryInformation',sErrorMessage);
                return null;
            }
            return oBenefReturned;
        }
    }
    
    /**
     * Method name  : fetchPrimaryCaregiverId
     * Description  : This method fetches Primary Caregiver id based upon caregiver name and household Id
     * Return Type  : Id
     * Parameter    : String sCaregiverName, Id householdId
     **/
    private static Id fetchPrimaryCaregiverId(String sCaregiverName, Id householdId, Boolean bIsUpdate) {
        List<Household_Member__c> lstHouseholdMem = new list <Household_Member__c>();
        Boolean bNeedToUpdate = false;
        Household_Member__c oHM = null;
        try {
            if(bIsUpdate){
                lstHouseholdMem = [Select Id, Name, Is_Caregiver__c, Is_Primary_Caregiver__c from Household_Member__c 
                    where Household__c = : householdId and Is_Primary_Caregiver__c = true limit 1];
            }
            
            if(lstHouseholdMem == null || lstHouseholdMem.IsEmpty()){
                lstHouseholdMem = [Select Id, Name, Is_Caregiver__c, Is_Primary_Caregiver__c from Household_Member__c 
                    where Name = :sCaregiverName and Household__c = : householdId limit 1];
            }
            
            if(lstHouseholdMem == null || lstHouseholdMem.IsEmpty()){
                lstHouseholdMem = [Select Id, Name, Is_Caregiver__c, Is_Primary_Caregiver__c from Household_Member__c
                    where Is_Caregiver__c =true and Household__c = : householdId limit 1];
            }
        } catch(QueryException oQEx) {
            populateInternalServerIntegrationError(oQEx, 'fetchPrimaryCaregiverId',null);
            return null;
        }
            
        if(lstHouseholdMem <> null && !lstHouseholdMem.IsEmpty()){
            oHM = lstHouseholdMem[0];
            if(!oHM.Is_Caregiver__c || !oHM.Is_Primary_Caregiver__c){
                oHM.Is_Primary_Caregiver__c = true;
                oHM.Is_Caregiver__c = true;
                bNeedToUpdate = true;
            }
            if(bNeedToUpdate){
                List<Database.SaveResult> lstUpdateResults = Database.update(
                lstHouseholdMem, false);
                Map<Id, List<String>> mapIdToErrorMsg =
                    ErrorLogUtility.logDMLError(lstUpdateResults, lstHouseholdMem,
                        'Household_Member__c',
                        'BeneficiaryAndHMInsertion', 'fetchPrimaryCaregiverId', 'SFDC CI', false);
                if(!mapIdToErrorMsg.isEmpty()) {
                    String sErrorMessage = Constants.EMPTY_STRING;
                    for(String sError:mapIdToErrorMsg.get(oHM.Id)){
                        sErrorMessage+=sError+Constants.SPACE_STRING;
                    }
                    populateInternalServerIntegrationError(null, 'fetchPrimaryCaregiverId',
                        'Update failed for Household Member Name: '+oHM.Name+'. Error: '+sErrorMessage);
                    return null;
                }
            }
        }
        
        return(lstHouseholdMem.IsEmpty()) ? null : lstHouseholdMem[0].Id;
    }
    
    /**
     * Method name  : fetchExistingBeneficiaryId
     * Description  : This method fetches Existing Beneficiary Id based upon existing beneficiary name
     * Return Type  : Id
     * Parameter    : String sExisBenefName
     **/
    private static Id fetchExistingBeneficiaryId(String sExisBenefName) {

        List<Account> lstExisBenef = null;
        try {
            lstExisBenef = [Select Id, Name, RecordTypeId from Account where RecordTypeId = :
                Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME) AND Name = :
                sExisBenefName limit 1
            ];
        } catch(QueryException oQEx) {
            populateInternalServerIntegrationError(oQEx, 'fetchExistingBeneficiaryId',
                null);
            return null;
        }
        return(lstExisBenef.IsEmpty()) ? null : lstExisBenef[0].Id;
    }

    /**
     * Method name  : fetchICPId
     * Description  : This method fetches ICP Id based upon ICP name
     * Return Type  : Id
     * Parameter    : String sIcpId
     **/
    private static Id fetchICPId(String sIcpId) {
        List<Account> lstIcp = null;
        try {
            lstIcp = [Select Id, Name, RecordTypeId from Account where RecordTypeId = :
                Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.ICP_RT_API_NAME) AND ICP_Id__c = :
                sIcpId limit 1
            ];
        } catch(QueryException oQEx) {
            populateInternalServerIntegrationError(oQEx, 'fetchICPId', null);
            return null;
        }
        return(lstIcp.IsEmpty()) ? null : lstIcp[0].Id;
    }

    /**
     * Method name  : fetchTutorImplementerId
     * Description  : This method fetches tutor/implementer id based upon contact name and ICP Id
     * Return Type  : Id
     * Parameter    : String sContactName, id icpId
     **/
    private static Id fetchTutorImplementerId(String sContactName, id icpId) {
        List<Contact> lstContacts = null;
        try {
            lstContacts = [Select Id, Name from Contact where Name = :
                sContactName AND AccountId = : icpId limit 1
            ];
        } catch(QueryException oQEx) {
            populateInternalServerIntegrationError(oQEx, 'fetchTutorImplementerId',
                null);
            return null;
        }
        return(lstContacts.IsEmpty()) ? null : lstContacts[0].Id;
    }

    /**
    * Class name   : HouseholdMemberKey
    * Description  : Inner class which is used as a Key for mapHMKeyToHMObject.
                     This key uniquely identifies Household Member object on the basis of Name & Role
    **/
    private class HouseholdMemberKey {
        public String sMemberName;
        public String sMemberRole;

        public HouseholdMemberKey(String sMemberNameArg, String sMemberRoleArg) {
            sMemberName = (null == sMemberNameArg) ? Constants.NA : sMemberNameArg;
            sMemberRole = (null == sMemberRoleArg) ? Constants.NA : sMemberRoleArg;
        }

        /**
         * Method name  : hashCode
         * Description  : Overriding hashCode method so that this inner class can be effectively used as key of Map
         * Return Type  : Integer
         * Parameter    : NA
         **/
        public Integer hashCode() {
            return sMemberName.hashCode() + sMemberRole.hashCode();
        }

        /**
         * Method name  : equals
         * Description  : Overriding equals method so that this inner class can be effectively used as key of Map
         * Return Type  : Boolean
         * Parameter    : Object obj
         **/
        public Boolean equals(Object obj) {
            HouseholdMemberKey oOtherHMKey = (HouseholdMemberKey) obj;
            if(oOtherHMKey.sMemberName.equals(sMemberName) && oOtherHMKey.sMemberRole.equals(
                    sMemberRole))
                return true;
            else
                return false;
        }
    }

    /**
     * Method name  : createHMForBenef
     * Description  : This method creates HOusehold Member for Beneficiary
     * Return Type  : void
     * Parameter    : Account oBenefPersisted, Household__c oHousehold
     **/
    private static void createHMForBenef(Account oBenefPersisted, Household__c oHousehold) {

        List<Household_Member__c> lstHM = null;
        try {
            lstHM = [Select Id from Household_Member__c where Household__c = :
                oHousehold.Id and Existing_Beneficiary__c = : oBenefPersisted.Id
            ];
        } catch(QueryException oQEx) {
            populateInternalServerIntegrationError(oQEx, 'createHMForBenef', null);
        }
        if(lstHM.isEmpty()) {
            Household_Member__c oTempMem = new Household_member__c(Name =
                oBenefPersisted.FirstName + ' ' + oBenefPersisted.LastName,
                Existing_Beneficiary__c = oBenefPersisted.Id,
                Household__c = oHousehold.Id,
                Role__c = oBenefPersisted.Gender__c == 'Male' ?
                Label.Beneficiary_Male : Label.Beneficiary_Female
            );

            List<Household_Member__c> lstHMToInsert = new List<Household_Member__c> {
                oTempMem};
            List<Database.SaveResult> lstUpdateResults = Database.insert(
                lstHMToInsert, false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults, lstHMToInsert,
                    'Household_Member__c',
                    'BeneficiaryAndHMInsertion', 'createHMForBenef', 'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                String sErrorMessage = Constants.EMPTY_STRING;
                for(String sError:mapIdToErrorMsg.get(oTempMem.Id)){
                    sErrorMessage+=sError+Constants.SPACE_STRING;
                }
                populateInternalServerIntegrationError(null, 'createHMForBenef',
                    'Creation failed for Household Member Name: '+oTempMem.Name+'. Error: '+sErrorMessage);
            }
        }
    }
    
    /**********************************
    Method Name : checkIfBenefStatusIsInactive
    Description : This method checks if Beneficiary status is inactive or not
    Return type : Boolean
    Parameter   : Account oBenef
    ************************************/
    private static Boolean checkIfBenefStatusIsInactive(Account oBenef){
      Boolean bValueToReturn = true;
      try {
            List<Account> lstBenefReturned = [Select Beneficiary_Status__c 
                from Account where Local_Beneficiary_Id__c = 
                :oBenef.Local_Beneficiary_Id__c limit 1];
            if(!(lstBenefReturned.size()>0 && Constants.INACTIVE.equals(lstBenefReturned[0].Beneficiary_Status__c))){
              bValueToReturn = false;
           }
      }catch(Exception oEx) {
            populateInternalServerIntegrationError(oEx, 'checkIfBenefStatusIsInactive',null);
        }
        return bValueToReturn;
    }
    
    /**********************************
    Method Name : checkIfTransferScenario
    Description : This method checks whether Beneficiary is transferred in Bolivia system
    Return type : Boolean
    Parameter   : Account oBenef
    ************************************/
    private static Boolean checkIfTransferScenario(Account oBenef){
      Boolean bValueToReturn = false;
      try {
            List<Account> lstBenefQueried = [Select Local_Beneficiary_ID__c from Account where 
                Compass_Id__c = :oBenef.Compass_Id__c limit 1];
            if(lstBenefQueried.size()>0 && 
                    lstBenefQueried[0].Local_Beneficiary_ID__c <> oBenef.Local_Beneficiary_ID__c){
               bValueToReturn = true;
            }
      }catch(Exception oEx) {
            populateInternalServerIntegrationError(oEx, 'checkIfTransferScenario',null);
        }
        return bValueToReturn;
    }

    /**********************************
    Method Name : checkIfBenefUnderApprovalProcess
    Description : This method checks whether Beneficiary is under Review Process
    Return type : Boolean
    Parameter   : Account oBenef
    ************************************/
    private static Boolean checkIfBenefUnderApprovalProcess(Account oBenef){
      Boolean bValueToReturn = false;
      try {
            List<Account> lstBenefQueried = [Select Review_Status__c from Account where 
                Local_Beneficiary_Id__c = :oBenef.Local_Beneficiary_Id__c limit 1];
            if(lstBenefQueried.size()>0 && !Label.Review_Status_Approved.equals(lstBenefQueried[0].Review_Status__c)){
               bValueToReturn = true;
            }
      }
      catch(Exception oEx) {
        populateInternalServerIntegrationError(oEx, 'checkIfTransferScenario',null);
      }
      return bValueToReturn;
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
        String sErrorMessage = (String.isBlank(sMessage))?oEx.getMessage():sMessage;
        String sJsonResponse = '{"response": {"status": "Failure", "message": "'+sErrorMessage+'"}}';
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
            'BeneficiaryAndHMInsertion', sMethodName,
            'SFDC CI', null, (String.isBlank(sMessage))?'Line Number: '+oEx.getLineNumber() +
            ' Exception: ' +
            oEx.getMessage() : sMessage, RestContext.request.requestBody.toString()
            .trim(), sJsonResponse,
            sJsonResponse,oEx);
    }

}