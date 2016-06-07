/******************************************************************************************************
Class Name         : CommunicationDeletion
Description        : This class sends the JSON of the communication kit getting deleted
Created By         : Rahul Agarwal 
Created On         : 03-Jul-2015
******************************************************************************************************/
public class CommunicationDeletion {
    /**
     * Method name  : sendCommunicationDeletion
     * Description  : This method is to accept deleted communication kits, create JSON and make an outbound call
     * Return Type  : void
     * Parameter    : list<Communication_Kit__c>
     **/
    public static void sendCommunicationDeletion(list<Communication_Kit__c>
        lstCommKits) {
        system.debug('<><><>lstCommKits ' + lstCommKits);
        set<Id> setCommKitIds = new set<Id>();
        for(Communication_Kit__c oCommKit: lstCommKits)
            setCommKitIds.add(oCommKit.Id);
        String sFieldsQuery = Utility.getFieldGroupElements(Constants.COMMUNICATION_DELETION_RES_FG);
        String sQuery = 'Select ' + sFieldsQuery +
            'CreatedById from Communication_Kit__c where Id IN: setCommKitIds ALL ROWS';
        list<Communication_Kit__c> lstCommKitForJSON = new list <
            Communication_Kit__c>();
        try {
            lstCommKitForJSON = database.query(sQuery);
        } catch(System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'CommunicationDeletion',
                'sendCommunicationDeletion', Constants.SOURCE_SYSTEM_SFDC_CI
            );
        }
        for(Communication_Kit__c oCommKit: lstCommKitForJSON)
            oCommKit.Status__c = Constants.Deleted;
        map<String, List<sObject>> mapOutputVar = new map<String, list <
            sObject>>();
        mapOutputVar.put(Constants.COMMUNICATION_DELETION_RES_FG, lstCommKitForJSON);
        String sResponse = JSONHandlerMethods.serialize(mapOutputVar, Constants.COMMUNICATION_DELETION_RES_PN);

        sResponse = sResponse.replace(Constants.TRUE_WITH_QUOTES, Constants.TRUE_WITHOUT_QUOTES);
        sResponse = sResponse.replace(Constants.FALSE_WITH_QUOTES, Constants.FALSE_WITHOUT_QUOTES);
        sResponse = sResponse.replace('""', Constants.NULL_STRING);
        sResponse = sResponse.replace(Constants.NULL_IN_DOUBLE_QUOTES_STRING,
            Constants.NULL_STRING);
        system.debug('-----JSON STRUCTURE----' + sResponse);
        system.enqueueJob(new CommunicationKitSend(sResponse,
            'CommunicationDeletion', Constants.POST_METHOD, null, true));
    }
}