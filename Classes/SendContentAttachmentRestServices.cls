/******************************************************************************************************
Class Name         : SendContentAttachmentRestServices
Description        : This class is used to send Content data to Neuron system
Created By         : Himanshu Raichandani
Created On         : 26-Jan-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@RestResource(urlMapping = '/ExportAttachment')
global class SendContentAttachmentRestServices {

    /**
     * Method name  : sendContentAttachment
     * Description  : This method is used to send Content data to Neuron system
     * Return Type  : void
     * Parameter    : void
     **/

    @HttpPost
    global static void sendContentAttachment() {
        Set<Id> setContentId = new Set<Id>();
        RestRequest request = RestContext.request;
        RestResponse oResponse = RestContext.response;
        List<FeedItem> lstFeedItem = new List<FeedItem>();
        String sJsonResponse = Constants.EMPTY_STRING;
        String sContentId = Constants.EMPTY_STRING;
        String sAttachmentId = Constants.EMPTY_STRING;
        List<Content__c> lstContent = new List<Content__c>();
        try{
        lstContent = (List<Content__c> ) JSONHandlerMethods.deserialize(
            request.requestBody.toString()
            .trim(), Constants.CONTENT_LINK_REQUEST_PROCESS_NAME);
        } catch(Exception oEx) {
            oResponse.statusCode = 500;
            sJsonResponse = Constants.SFDC_ERROR_RESPONSE;
            oResponse.responseBody = blob.valueOf(sJsonResponse);
            ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
            'SendContentAttachmentRestServices', 'sendContentAttachment', 
            'SFDC CI', null, 'Line Number: ' + oEx.getLineNumber() + ' Exception: ' +
            oEx.getMessage(), request.requestBody.toString()
            .trim(), sJsonResponse,
            sJsonResponse,oEx);
            return; 
        }   
        if(!lstContent.isEmpty()) {
            for(Content__c oContent: lstContent) {
                try{
                    sContentId = oContent.Id;
                    sAttachmentId = oContent.AttachmentId__c;
                }
                catch(Exception oEx){
                    oResponse.statusCode = 400;
                    sJsonResponse = Constants.SFDC_BAD_REQUEST_RESPONSE;
                    oResponse.responseBody = blob.valueOf(sJsonResponse);
                    ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
                        'SendContentAttachmentRestServices', 'sendContentAttachment',
                        'Neuron', null, 'Error in request', request.requestBody.toString()
                        .trim(), sJsonResponse, sJsonResponse,null
                    );
                    return;
                }
                if(String.isBlank(sContentId)) {
                    oResponse.statusCode = 400;
                    sJsonResponse = Constants.CONTENT_MISSING_ID_RESPONSE;
                    oResponse.responseBody = blob.valueOf(sJsonResponse);
                    return;
                } else if(String.isBlank(sAttachmentId)) {
                    oResponse.statusCode = 400;
                    sJsonResponse = Constants.CONTENT_MISSING_ATTACHMENT_ID_RESPONSE;
                    oResponse.responseBody = blob.valueOf(sJsonResponse);
                    return;
                }
            }
        } 
        if(String.isNotBlank(sContentId) && String.isNotBlank(sAttachmentId)) {
            try{
                lstFeedItem = [Select Id, ContentType, ContentData, parentid, Type from feeditem where Id = :
                    sAttachmentId And parentid = : sContentId And Type = : Constants.FEED_ITEM_TYPE limit 1
                ];
            }catch(Exception oEx) {
                oResponse.statusCode = 500;
                sJsonResponse = Constants.SFDC_ERROR_RESPONSE;
                oResponse.responseBody = blob.valueOf(sJsonResponse);
                ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
                'SendContentAttachmentRestServices', 'sendContentAttachment', 
                'SFDC CI', null, 'Line Number: ' + oEx.getLineNumber() + ' Exception: ' +
                oEx.getMessage(), request.requestBody.toString()
                .trim(), sJsonResponse,
                sJsonResponse,oEx);
                return;
            }   
        }
        if(lstFeedItem.isEmpty()) {
            oResponse.statusCode = 400;
            sJsonResponse = Constants.CONTENT_NO_ATTACHMENT_FOUND_RESPONSE;
            oResponse.responseBody = blob.valueOf(sJsonResponse);
            return;
        }

        if(!lstFeedItem.isEmpty()) {
            try {
                oResponse.addHeader(Constants.CONTENT_TYPE, lstFeedItem[0].ContentType);
                oResponse.responseBody = lstFeedItem[0].ContentData;
            } catch(Exception oEx) {
                sJsonResponse = Constants.CONTENT_FAILURE_RESPONSE + oEx + Constants.SUPPORTER_PROFILE_DOUBLE_END_BRACKET_TOKEN;
                oResponse.responseBody = blob.valueOf(sJsonResponse);
                ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound', 'SendContentAttachmentRestServices', 'sendContentAttachment', 
                'SFDC CI', null , 'Error in sending content attachment', request.requestBody.toString().trim(),sJsonResponse,sJsonResponse,oEx );
                return;
            }
        }
        ErrorLogUtility.logIntegrationInfo('Success', 'Inbound', 'SendContentAttachmentRestServices', 'sendContentAttachment', 
        '', null , 'Success in sending content attachment', request.requestBody.toString().trim(),'OK','OK',null );
    }
}