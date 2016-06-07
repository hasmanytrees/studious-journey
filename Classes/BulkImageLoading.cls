/******************************************************************************************************
Class Name         : BulkImageLoading
Description        : This class contains Rest Methods to create content record for the Beneficiary based on local beneficiary Id 
                     and Document Type sent by Neuron.
                     These methods will be called from Neuron.
Created By         : Nayana Prabhakar 
Created On         : 03-Feb-2015 
******************************************************************************************************/

@RestResource(urlMapping = '/BulkImageLoad')
global class BulkImageLoading {

    /**********************************
    Method Name : createContentForBen
    Description : This method is used to create content record for the Beneficiary based on local beneficiary Id and Document Type sent by Neuron.
    Return type : void
    Parameter   : void
    ************************************/
    @HttpPost
    global static void createContentForBen() {
        RestRequest request = RestContext.request;
        RestResponse  oResponse = RestContext.response; 
        String sJsonResponse = Constants.EMPTY_STRING;
        RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
        List<Content__c> lstContent = new List<Content__c>();
        try{
            lstContent = (List<Content__c> ) JSONHandlerMethods.deserialize(
            request.requestBody.toString()
            .trim(), Constants.BULK_IMAGE_RESPONSE_PROCESS_NAME);
            System.debug('---'+request.requestBody.toString()
            .trim()+'----------'+lstContent);
        }catch(Exception oEx) {
            System.debug('---Exception---');
            populateInternalServerIntegrationError(oEx,'createContentForBen',null);
            return; 
        }   
        List<String> lstLocalBenIds = new List<String>();
        for(Content__c oEachCont: lstContent) {
            System.debug('---oEachCont---'+oEachCont.Comments__c);
            lstLocalBenIds.add(oEachCont.Comments__c);
            System.debug('---lstLocalBenIds---'+lstLocalBenIds);
        }
        List<Account> lstBen = new List<Account>();
        try{
            lstBen = [Select Id, Local_Beneficiary_Id__c from Account where Local_Beneficiary_Id__c IN:
                lstLocalBenIds
            ];
            System.debug('--lstBen--'+lstBen);
        }catch(QueryException oQEx){
            populateInternalServerIntegrationError(oQEx,'createContentForBen',null);
            return;
        }
        
        if(lstBen.isEmpty()) {
            
            RestResponse res = RestContext.response;
            res.statusCode = 400;
            sJsonResponse = Constants.BULK_IMAGE_LOAD_FAIL_HTML_RESPONSE;
            ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound', 'BulkImageLoading', 'createContentForBen', 
            'Neuron', null , 'No Beneficiary corresponding to ChildKey found', request.requestBody.toString().trim(),
             sJsonResponse, sJsonResponse,null );
            res.responseBody = blob.valueOf(sJsonResponse);
            return;
        }
        Map<String, String> mapLocalBenIdwithBenefId = new Map<String, String>
            ();

        if(!lstBen.isEmpty()) {
            for(Account oBenef: lstBen) {
                mapLocalBenIdwithBenefId.put(oBenef.Local_Beneficiary_Id__c, oBenef.Id);
            }
        }

        List<Content__c> lstNewContent = new List<Content__c>();
        Id contentBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Content__c.SObjectType, Constants.BEN_API_NAME);
        for(Content__c oNewCon: lstContent) {
            Content__c oContToInsert = new Content__c();
            oContToInsert.Beneficiary__c = mapLocalBenIdwithBenefId.get(oNewCon.Comments__c);
            oContToInsert.Content_Type__c = oNewCon.Content_Type__c;
            oContToInsert.RecordTypeId = contentBenefRecTypeId;
            lstNewContent.add(oContToInsert);

        }

        if(!lstNewContent.isEmpty()) {
            List<Database.SaveResult> lstInsertResults = Database.insert(lstNewContent,false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstInsertResults, lstNewContent, 'Content__c',
                    'BulkImageLoading', 'createContentForBen', 
                    'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                String sErrorMessage = Constants.EMPTY_STRING;
                for(Id contentId: mapIdToErrorMsg.keySet()){
                    for(String sErrorMsg: mapIdToErrorMsg.get(contentId)){
                            sErrorMessage+=sErrorMsg;
                    }
                }
                populateInternalServerIntegrationError(null,'createContentForBen',sErrorMessage);
                return; 
            }
            List<Id> lstInsertedConIds = new List<Id>();
            for(Content__c oInsertedCon: lstNewContent) {
                lstInsertedConIds.add(oInsertedCon.Id);
            }

            String sJson = FeedItemHandler.generateJsonForContent(lstInsertedConIds);
            RestContext.response.responseBody = Blob.valueOf(sJson);
            ErrorLogUtility.logIntegrationInfo('Success', 'Inbound','BulkImageLoading', 'createContentForBen', 
            '', null , 'Success in Bulk content load', request.requestBody.toString().trim(),sJson,'' ,null);
        }
    }
    
    /**********************************
    Method Name : populateInternalServerIntegrationError
    Description : This method logs integration info into Error Log objects by
                  calling ErrorLogUtility class
    Return type : void
    Parameter   : Exception oEx, String sMethodName, String sMessage
    ************************************/
     private static void populateInternalServerIntegrationError(Exception oEx, String sMethodName, String sMessage){
        RestContext.response.statusCode = 500;
        String sJsonResponse = (String.isBlank(sMessage))?oEx.getMessage():sMessage;
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
            'BulkImageLoading', sMethodName,
            'SFDC CI', null, (String.isBlank(sMessage))?'Line Number: ' + oEx.getLineNumber() + ' Exception: ' +
            oEx.getMessage():sMessage, RestContext.request.requestBody.toString()
            .trim(),sJsonResponse ,
            sJsonResponse,oEx);
    }
}