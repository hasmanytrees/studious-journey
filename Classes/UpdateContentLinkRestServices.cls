/******************************************************************************************************
Class Name         : UpdateContentLinkRestServices
Description        : This web service is exposed to Neuron which sends the content link information
Created By         : Himanshu Raichandani
Created On         : 23-Jan-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@RestResource(urlMapping = '/UpdateContentLink')
global class UpdateContentLinkRestServices {

    /**
     * Method name  : updateContent
     * Description  : This used to send content link information to Neuron
     * Return Type  : void
     * Parameter    : void
     **/
    @HttpPost
    global static void updateContent() {
        List<FeedItem> lstFeedItem = new List<FeedItem>();
        List<Content__c> lstContentToUpdate = new List<Content__c>();
        String sJsonResponse = Constants.EMPTY_STRING;
        String sContentId = Constants.EMPTY_STRING;
        String sAttachmentId = Constants.EMPTY_STRING;
        RestRequest oRequest = RestContext.request;
        RestResponse oResponse = RestContext.response;
        RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
        List<Content__c> lstContent = new List<Content__c>();
        try{
        lstContent = (List<Content__c> ) JSONHandlerMethods.deserialize(
            oRequest.requestBody.toString()
            .trim(), Constants.CONTENT_LINK_REQUEST_PROCESS_NAME);
        }catch(Exception oEx) {
            populateInternalServerIntegrationError(oEx,'updateContent',null);
            return;
        }
            
        for(Content__c oContent: lstContent) {
            sContentId = oContent.Id;
            sAttachmentId = oContent.AttachmentId__c;
            if(String.isBlank(sContentId)) {
                oResponse.statusCode = 400;
                sJsonResponse = Constants.CONTENT_MISSING_ID_RESPONSE;
                oResponse.responseBody = blob.valueOf(sJsonResponse);
                return;
            }
            if(String.isNotBlank(sContentId)) {
                Content__c oCon = new Content__c();
                oCon.id = oContent.Id;
                oCon.Content_Link__c = oContent.Content_Link__c;
                lstContentToUpdate.add(oCon);
            }
        }
        if(String.isNotBlank(sContentId) && String.isNotBlank(sAttachmentId)) {
            try{
                lstFeedItem = [Select Id, ContentType, ContentData, parentid, Type from FeedItem where Id = :
                    sAttachmentId And parentid = : sContentId and Type = : Constants.FEED_ITEM_TYPE
                ];
            } catch(Exception oEx) {
                populateInternalServerIntegrationError(oEx,'updateContent',null);
                return;
            }   
        }
        if(!lstFeedItem.isEmpty()) {
            List<Database.DeleteResult> lstDeleteResults = Database.delete(lstFeedItem,false);
            List<Id> lstFeedItemIds = new List<Id>();
            for(FeedItem oFeedItem:lstFeedItem){
                lstFeedItemIds.add(oFeedItem.Id);
            }
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstDeleteResults, lstFeedItemIds, 'FeedItem',
                    'UpdateContentLinkRestServices', 'updateContent',
                    'SFDC CI');
            if(!mapIdToErrorMsg.isEmpty()) {
                String sErrorMessage = Constants.EMPTY_STRING;
                for(Id feedId: mapIdToErrorMsg.keySet()){
                    for(String sErrorMsg: mapIdToErrorMsg.get(feedId)){
                            sErrorMessage+=sErrorMsg;
                    }
                }
                populateInternalServerIntegrationError(null,'updateContent',sErrorMessage);
                return; 
            }
        }
        if(lstContentToUpdate.isEmpty()) {
            oResponse.statusCode = 400;
            sJsonResponse = Constants.CONTENT_NO_CONTENT_FOUND_RESPONSE;
            oResponse.responseBody = blob.valueOf(sJsonResponse);
            return;
        }
        if(!lstContentToUpdate.isEmpty()) {
            
            List<Database.SaveResult> lstUpdateResults = Database.update(lstContentToUpdate,false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults, lstContentToUpdate, 'Content__c',
                    'UpdateContentLinkRestServices', 'updateContent',
                    'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                String sErrorMessage = Constants.EMPTY_STRING;
                for(Id contentId: mapIdToErrorMsg.keySet()){
                    for(String sErrorMsg: mapIdToErrorMsg.get(contentId)){
                            sErrorMessage+=sErrorMsg;
                    }
                }
                populateInternalServerIntegrationError(null,'updateContent',sErrorMessage);
                return; 
            }
        }
        sJsonResponse = Constants.CONTENT_UPLOAD_SUCCESS_RESPONSE + lstContent[0].Id +
            Constants.SUPPORTER_PROFILE_DOUBLE_END_BRACKET_TOKEN;
        RestContext.response.responseBody = Blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo('Success', 'Inbound', 'UpdateContentLinkRestServices', 'updateContent',
        '', null , 'Success in updating content link', oRequest.requestBody.toString().trim(),sJsonResponse,'',null );
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
            'UpdateContentLinkRestServices', sMethodName,
            'SFDC CI', null, (String.isBlank(sMessage))?'Line Number: ' + oEx.getLineNumber() + ' Exception: ' +
            oEx.getMessage():sMessage, RestContext.request.requestBody.toString()
            .trim(),sJsonResponse ,
            sJsonResponse,oEx);
    }
}