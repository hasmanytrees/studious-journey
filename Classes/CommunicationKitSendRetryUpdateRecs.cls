/******************************************************************************************************
Class Name         : CommunicationKitSendRetryUpdateRecs
Description        : This is a controller class for making updates after successfull callout
Created By         : Akashdeep Vinnakota 
Created On         : 2-Feb-2016 
******************************************************************************************************/
public class CommunicationKitSendRetryUpdateRecs {
    
    /**
    * Method name  : updateCommRecs
    * Description  : This method updates Communication Records upon Successfull Retry
    * Return Type  : N/A
    * Parameter    : Map<HttpRequest, HttpResponse>
    **/    
    public void updateCommRecs(Map<HttpRequest, HttpResponse> mapResponse)
    {
        System.Debug('Came Here');
        System.Debug('mapResponse: ' + mapResponse);
        String sRequest = mapResponse.Values()[0].getBody().trim();
        if(sRequest.contains('"Responses":')) {
            list<SObject> lstSObject = null;
            lstSObject = (list<SObject> ) JSONHandlerMethods.deserialize(sRequest,
                Constants.COMMUNICATION_RESPONSES_PN);
            set<String> setCommKitName = new set<String>();
            map<String, Communication_Kit__c> mapCommKitName = new map<String,
                Communication_Kit__c>();
            for(Communication_Kit__c oCommKit: (list<Communication_Kit__c> ) lstSObject) {
                setCommKitName.add(oCommKit.INT_Communication_Kit_Id__c);
                mapCommKitName.put(oCommKit.INT_Communication_Kit_Id__c, oCommKit);
            }
            list<Communication_Kit__c> lstQueryCommKit = new list <
                Communication_Kit__c>();
            lstQueryCommKit = [select Id, Name, Local_GP_Kit_ID__c from Communication_Kit__c where Name IN:
                setCommKitName
            ];
            for(Communication_Kit__c oCommKit: lstQueryCommKit) {
                oCommKit.Local_GP_Kit_ID__c = mapCommKitName.get(oCommKit.Name)
                    .Local_GP_Kit_ID__c;
            }
            if(lstQueryCommKit.size()> 0) {
                List<Database.SaveResult> lstUpdateResults = Database.update(
                    lstQueryCommKit, false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, lstQueryCommKit, 'Communication_Kit__c',
                    'CommunicationKitSend', 'execute', 'SFDC-CI', false);
            }
        }
    }
}