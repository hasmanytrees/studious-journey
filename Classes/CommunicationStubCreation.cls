global class CommunicationStubCreation{
    public static void sendCommunicationStubCreation(list <Communication_Kit__c > lstCommKits){
        set < Id > setCommKitIds = new set < Id > ();
        for (Communication_Kit__c oCommKit: lstCommKits){
            //oCommKit.INT_Source_System__c = 'SFDC-CI';
            setCommKitIds.add(oCommKit.Id);
        }
        String sFieldsQuery = Utility.getFieldGroupElements('CommunicationStubCreation_Res_FG');
        String sQuery = 'Select ' + sFieldsQuery +
            'CreatedById from Communication_Kit__c where Id IN: setCommKitIds';
        list < Communication_Kit__c > lstCommKitForJSON = new list < Communication_Kit__c > ();
        try {
            lstCommKitForJSON = database.query(sQuery);
        } catch (System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'CommunicationStubCreation',
                'sendCommunicationStubCreation', 'SFDC CI');
        }
        Map < String, List < sObject >> mapOutputVar = new Map < String,
            List <
            sObject >> ();
        mapOutputVar.put('CommunicationStubCreation_Res_FG', lstCommKitForJSON);
        String sResponse = JSONHandlerMethods.serialize(mapOutputVar,
            'CommunicationStubCreation_Res_PN');
        sResponse = sResponse.replace('"true"', 'true');
        sResponse = sResponse.replace('"false"', 'false');
        sResponse = sResponse.replace('""', 'null');
        system.debug('-----JSON STRUCTURE----' + sResponse);
    }
}