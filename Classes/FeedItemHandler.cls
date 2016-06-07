/******************************************************************************************************
Class Name         : FeedItemHandler
Description       :  This is single Class for FeedItem which will cover all it's trigger functionality.
                     These methods will be called from FeedItemTrigger based on required trigger events.
Created By         : Himanshu Raichandani 
Created On         : 23-Jan-2015 
 ******************************************************************************************************/

public class FeedItemHandler {
    public static List<Content__c> lstContentUpdate = new List<Content__c>();

    /**
    Method Name : generateJsonForContent
    Description : This method is called by the future method webServiceCallMethod and is used to generate the JSON string that is
                  to be sent to Neuron to update Content information once content record is created or updated in Salesforce.
    Return type : string
    Parameter   : List<Id> 
    **/
    public static string generateJsonForContent(List<Id> lstContentId) {
        List<Content__c> lstContent = new List<Content__c>();
        List<FeedItem> lstFeedItem = new List<FeedItem>();

        Map<ID, FeedItem> mapContentIdWithImage = new Map<ID, FeedItem>();
        String sFieldsQuery = Utility.getFieldGroupElements(Constants.CONTENT_LINK_REQUEST_GROUP_NAME);
        String sQuery = 'Select ' + sFieldsQuery +
            'ICP_Lead__c,Beneficiary_Assessment__c,Beneficiary_Lifecycle_Event__c,ICP__c,' +
            'ICP__r.RecordTypeId,Field_Office__c,Field_Office__r.RecordTypeId,' +
            'Activity_Plan__c,CreatedDate,Beneficiary__r.Local_Beneficiary_ID__c';
        sQuery += ' from Content__c  where ID IN:lstContentId';
        try {
            lstContent = Database.query(sQuery);
        } catch(System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'FeedItemHandler',
                'generateJsonForContent', 'SFDC CI');
        }
        try {
            lstFeedItem = [Select ID, ContentData, ContentType, ParentID,
                LastModifiedDate from Feeditem where ParentId IN: lstContent
            ];
        } catch(System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'FeedItemHandler',
                'generateJsonForContent', 'SFDC CI');
        }
        for(FeedItem oFeedItem: lstFeedItem) {
            mapContentIdWithImage.put(oFeedItem.parentID, oFeedItem);
        }

        Id fieldOfficeRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.FIELD_OFFICE_RT_API_NAME);
        Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);
        for(Content__c oCont: lstContent) {
            if(NULL <> mapContentIdWithImage.get(oCont.id)) {
                Content__c oUpdtContent = new Content__c(id = oCont.id);
                if(mapContentIdWithImage.get(oCont.id)
                    .ContentType == Constants.APPLICATION_OCTET_STREAM_CONTENT_TYPE) {
                    oUpdtContent.Content_Download_Type__c = Constants.IMAGE_JPEG_CONTENT_TYPE;
                } else {
                    oUpdtContent.Content_Download_Type__c = mapContentIdWithImage.get(oCont.id)
                        .ContentType;
                }
                oCont.AttachmentId__c = mapContentIdWithImage.get(oCont.id)
                    .Id;
                oCont.AttachmentDT__c = mapContentIdWithImage.get(oCont.id)
                    .LastModifiedDate;
                lstContentUpdate.add(oUpdtContent);
            } else {
                oCont.AttachmentDT__c = oCont.CreatedDate;
            }
            if(oCont.Content_Link__c == NULL) {
                oCont.Content_Link__c = '';
            }

            if(NULL <> oCont.Beneficiary__c && String.isNotEmpty(oCont.Beneficiary__r.Local_Beneficiary_ID__c)) {
                oCont.Comments__c = oCont.Beneficiary__r.Local_Beneficiary_ID__c;
            }
            
            if(NULL <> oCont.Field_Office__c && oCont.Field_Office__r.RecordTypeId ==
                fieldOfficeRecTypeId) {
                oCont.Beneficiary__c = oCont.Field_Office__c;
            }

            if(NULL <> oCont.ICP__c && oCont.ICP__r.RecordTypeId == icpRecTypeId) {
                oCont.Beneficiary__c = oCont.ICP__c;
            }

            if(NULL <> oCont.Activity_Plan__c) {
                oCont.Beneficiary__c = oCont.Activity_Plan__c;
            }

            if(NULL <> oCont.Beneficiary_Assessment__c) {
                oCont.Beneficiary__c = oCont.Beneficiary_Assessment__c;
            }

            if(NULL <> oCont.Beneficiary_Lifecycle_Event__c) {
                oCont.Beneficiary__c = oCont.Beneficiary_Lifecycle_Event__c;
            }
            if(NULL <> oCont.ICP_Lead__c) {
                oCont.Beneficiary__c = oCont.ICP_Lead__c;
            }
        }

        Map<String, List<sObject>> mapOutput = new Map<String, List<sObject>>
            ();
        mapOutput.put(Constants.CONTENT_LINK_REQUEST_GROUP_NAME, lstContent);
        String sRequest = JSONHandlerMethods.serialize(mapOutput, Constants.CONTENT_LINK_REQUEST_PROCESS_NAME);
        return sRequest;
    }

    /**
    Method Name : webServiceCallMethod
    Description : This method is a future method which is called whenever a content record is created or updated and is used to 
                  send request to Neuron to update Content information from Salesforce.
    Return type : void
    Parameter   : List<Id> 
    **/
    /**/
    @future(callout = true)
    public static void webServiceCallMethod(List<Id> lstContentId) {
        string sJson = generateJsonForContent(lstContentId);
        JSONParserForToken oJsonParserToken = JSONParserForToken.getJSONParserForToken();
        if(null==oJsonParserToken){
            ErrorLogUtility.logIntegrationInfo('Failure', 'Outbound', 'FeedItemHandler', 'webServiceCallMethod',
            'Neuron', null,'Failure in getting token from Neuron. Cannot send Content updates to Neuron/Perceptive for following Content Ids: '
            +lstContentId, sJson, null, null,null);
            return;
        }
        SendRequestToNeuron.sendInfoToNeuron(sJson,ESB_URL__c.getValues('NeuronURLForSendingImageInfo')
            .Process_ESB_URL__c,oJsonParserToken);
        if(!lstContentUpdate.isEmpty()) {
            List<Database.SaveResult> lstUpdateResults =
                Database.update(lstContentUpdate, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstContentUpdate, 'Content__c',
                'FeedItemHandler', 'webServiceCallMethod', 'SFDC CI', false);
        }
    }

}