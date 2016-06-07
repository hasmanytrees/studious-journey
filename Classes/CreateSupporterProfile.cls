/******************************************************************************************************
Class Name         : CreateSupporterProfile
Description        : This class contains Rest methods to create Supporter Profile in CI side.
                     This web service is called by USA to keep CI updated about Supporter information.
Created By         : Sowmya Chamakura 
Created On         : 28-Jan-2015 
******************************************************************************************************/

@RestResource(urlMapping = '/CreateSupporter')
global class CreateSupporterProfile {
    /**
     * Method Name   : CreateSupporterProfile
     * Description   : This method creates Supporter Profile in CI side. This web service is called by USA to keep CI updated about Supporter information.
     * Return type   : void
     * Parameter     : void
     **/
    @HttpPost
    global static void createSupporterProfile() {
        List<Account> lstUpsert = new List<Account>();
        Map<String, Id> mapGP = new Map<String, Id>();
        Set<String> setGPName = new set<String>();
        RestRequest oRequest = RestContext.request;
        RestResponse oResponse = RestContext.response;
        String sJsonResponse = Constants.EMPTY_STRING;
        ID recTypeID = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.SUPPORTER_PERSON_RT_API_NAME);
        List<Account> lstSupporter = new List<Account>();        
        // KN: Manipulating incoming JSON if LastName='Null'        
        Map < String, Object > mapDeserialized = (Map < String, Object > ) JSON.deserializeUntyped(
            oRequest.requestBody.toString()
            .trim());
        List < Object > lstDeserialized = (List < Object > ) mapDeserialized.get(
            Constants.SUPPORTER_PROFILE_TOKEN);            
        for(Object objVar: lstDeserialized) {
            mapDeserialized = (Map < String, Object > )(objVar);
            if(String.valueOf(mapDeserialized .get(Constants.LASTNAME)) == Constants.NULL_STR) {
                mapDeserialized.put(Constants.LASTNAME, Constants.NULL_WITH_WILDCHAR); //KN: Concatenating wild characters                
                break;
            }            
        }        
        try { 
            lstSupporter = (List<Account> ) JSONHandlerMethods.deserialize(
                Constants.SUPPORTER_PROFILE_MAIN_TOKEN + JSON.serialize(mapDeserialized) +
                Constants.SUPPORTER_PROFILE_MAIN_END_BRACKET_TOKEN,
                Constants.SUPPORTER_MINI_PROFILE_REQ_PROC_NAME);
                
            //lstSupporter = (List<Account> ) JSONHandlerMethods.deserialize(
            //   oRequest.requestBody.toString()
            //   .trim(), Constants.SUPPORTER_MINI_PROFILE_REQ_PROC_NAME);
                System.debug('---lstSupporter---'+lstSupporter);
        } catch(Exception oEx) {
            populateInternalServerIntegrationError(oEx, 'createSupporterProfile', null);
            return;
        }
        for(Account oAcc: lstSupporter) {
            setGPName.add(String.escapeSinglequotes(oAcc.Global_Partner__c));
        }
        try {
            for(Account oAcc: [Select Id, Name from Account where Name like: setGPName]) {
                mapGP.put(oAcc.Name, oAcc.Id);
            }
        } catch(QueryException oQEx) {
            populateInternalServerIntegrationError(oQEx, 'createSupporterProfile', null);
            return;
        }
        for(Account oSupporter: lstSupporter) {
            Account oNewSupporter = new Account(FirstName = oSupporter.FirstName,
                LastName = oSupporter.LastName, Gender__c = oSupporter.Gender__c,
                Global_Partner__c = mapGP.get(oSupporter.Global_Partner__c),
                GP_Supporter_ID__c = oSupporter.Id, RecordTypeId = recTypeID, 
                Preferred_Name__pc = oSupporter.Preferred_Name__pc, 
                SUP_Status__c = oSupporter.SUP_Status__c);                
                if(oNewSupporter.LastName == Constants.NULL_WITH_WILDCHAR)
                oNewSupporter.LastName = Constants.NULL_STR; //KN: Removing wild character                
                lstUpsert.add(oNewSupporter);
        }


        List<Database.UpsertResult> lstUpsertResults = Database.upsert(lstUpsert,
            Account.GP_Supporter_ID__c, false);

        Map<Id, List<String>> mapIdToErrorMsg =
            ErrorLogUtility.logDMLError(lstUpsertResults, lstUpsert, 'Account',
                'CreateSupporterProfile', 'createSupporterProfile',
                'SFDC CI', false);
        if(!mapIdToErrorMsg.isEmpty()) {
            String sErrorMessage = Constants.EMPTY_STRING;
            for(Id accId: mapIdToErrorMsg.keySet()) {
                for(String sErrorMsg: mapIdToErrorMsg.get(accId)) {
                    sErrorMessage += sErrorMsg;
                }
            }
            populateInternalServerIntegrationError(null, 'createSupporterProfile',
                sErrorMessage);
            return;
        }
        List<Account> lstSupp = new List<Account>();
        try {
            lstSupp = [Select GP_Supporter_ID__c, Global_Number__c from Account where id in: lstUpsert];
        } catch(QueryException oQEx) {
            populateInternalServerIntegrationError(oQEx, 'createSupporterProfile', null);
            return;
        }

        RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
        sJsonResponse = Constants.SUPPORTER_PROFILE_MAIN_TOKEN;
        Integer iSup = 1;
        for(Account oNewSupp: lstSupp) {
            sJsonResponse += Constants.SUPPORTER_PROFILE_ID_TOKEN + oNewSupp.GP_Supporter_ID__c +
                Constants.SUPPORTER_PROFILE_GLOBAL_ID_TOKEN + oNewSupp.Global_Number__c +
                Constants.SUPPORTER_PROFILE_END_BRACKET_TOKEN;
            if(iSup<lstSupp.size())
                sJsonResponse += Constants.COMMA;
            iSup++;
        }
        sJsonResponse += Constants.SUPPORTER_PROFILE_MAIN_END_BRACKET_TOKEN;
        oResponse.responseBody = blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo('Success', 'Inbound',
            'CreateSupporterProfile', 'createSupporterProfile',
            '', null, 'Success in creating supporter profile', oRequest.requestBody.toString()
            .trim(), sJsonResponse, '',null);
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
        String sJsonResponse = (String.isBlank(sMessage))?oEx.getMessage():sMessage;
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
            'CreateSupporterProfile', sMethodName,
            'SFDC CI', null, (String.isBlank(sMessage)) ? 'Line Number: ' + oEx.getLineNumber() +
            ' Exception: ' + oEx.getMessage() : sMessage,
            RestContext.request.requestBody.toString().trim(), sJsonResponse,sJsonResponse,oEx);
    }
}