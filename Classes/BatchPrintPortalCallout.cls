/******************************************************************************************************
Class Name         : BatchRetryMechanism
Description        : This class is used to implement Retry logic for integrations in CI.
Created By         : Rahul Agarwal
Created On         : 15-Oct-2015 
******************************************************************************************************/
global class BatchPrintPortalCallout implements Database.Batchable<sObject>, database.stateful, Database.AllowsCallouts{
    
    /**
    * Method name  : start
    * Description  : This method fetches all the error log that needs retry
    * Return Type  : Database.QueryLocator
    * Parameter    : Database.BatchableContext
    **/
    global Database.QueryLocator start(Database.BatchableContext oBC){
        String sQuery = '';
        sQuery = 'Select Id, Printed_Not_Sent_To_FO__c from Communication_Kit__c where Status__c = \'Printed and sent to ICP\' AND Printed_Not_Sent_To_FO__c = true ORDER BY Template_ID__c NULLS LAST';
        return database.getQueryLocator(sQuery);
    }
    
    /**
    * Method name  : execute
    * Description  : This method creates the Scheduled Letters 
    * Return Type  : void
    * Parameter    : Database.BatchableContext, List<Account>
    **/
    global void execute(Database.BatchableContext oBC, List<SObject> lstInScope)
    {
        List < Communication_Kit__c > lstScope = new List < Communication_Kit__c >();
        lstScope = (list < Communication_Kit__c > ) lstInScope;
        String sWhomToSend = Constants.PrintPortalBatch_URL;
        set<Id> setCommKitIds = new set<Id>();
        for(Communication_Kit__c oCommKit: lstScope) 
        {
            setCommKitIds.add(oCommKit.Id);
        }
        
        String sFieldsQuery = Utility.getFieldGroupElements(Constants.COMM_KIT_FIELD_GROUP);
        String sQuery = 'Select ' + sFieldsQuery +
            'CreatedById from Communication_Kit__c where Id IN: setCommKitIds ORDER BY BEN_ID__r.Local_Beneficiary_ID__c';
        System.Debug('sQuery: ' + sQuery);
        list<Communication_Kit__c> lstCommKitForJSON = new list <Communication_Kit__c>();
        try {
            lstCommKitForJSON = database.query(sQuery);
        } catch(System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, Constants.CLASS_NAME_SBCCOMMUNICATIONDETAILS,
                Constants.METHOD_NAME_SENDCOMMUNICATIONDETAILS, Constants.SOURCE_SYSTEM_SFDC_CI
            );
        }

        map<String, Record_Type_Mapping_For_SBC_Integration__c> mapRecordTypeMapping = new map<String,Record_Type_Mapping_For_SBC_Integration__c>();
        mapRecordTypeMapping = Record_Type_Mapping_For_SBC_Integration__c.getAll();
        set<String> setRecordTypeMappingValues = new set<String>();
        //setRecordTypeMappingValues.addAll(mapRecordTypeMapping.Values());
        for(Record_Type_Mapping_For_SBC_Integration__c oVar: mapRecordTypeMapping.Values())
            setRecordTypeMappingValues.add(oVar.RecordType_Name_For_Integration__c);

        list<RecordType> lstRecordType = new list<RecordType>();
        lstRecordType = [select Id, Name, DeveloperName from RecordType where SObjectType = :
            Constants.COMMUNICATION_KIT_API_NAME
        ];
        map<String, RecordType> mapRecordType = new map<String, RecordType>();
        for(RecordType oRecType: lstRecordType)
            mapRecordType.put(oRecType.Name, oRecType);
        // Fixing Original and Translation Language

        map<String, map<String, List<sObject>>> mapOuterOutputVar = new map <
            String, map<String, List<sObject>>>();
        Boolean bImmTransfer = true;
        for(Communication_Kit__c oCommKit: lstCommKitForJSON) 
        {
            String sBenLanguage = oCommKit.BEN_Id__r.Correspondence_Language__c;
            if(!setRecordTypeMappingValues.contains(oCommKit.RecordType.Name))
            {
                oCommKit.RecordType.Name = mapRecordTypeMapping.get(mapRecordType.get(oCommKit.RecordType.Name).DeveloperName).RecordType_Name_For_Integration__c;
            }            
            if(oCommKit.RecordType.Name == Constants.B2S) 
            {
                oCommKit.BEN_Id__r.Correspondence_Language__c = oCommKit.INT_Supporter_Correspondence_Language__c;
                oCommKit.INT_Supporter_Correspondence_Language__c = sBenLanguage;

            }
            if(String.isEmpty(oCommKit.SUP_Id__r.Preferred_Name__pc) && !String.isEmpty(oCommKit.SUP_Id__r.Name))
            {
                oCommKit.SUP_Id__r.Preferred_Name__pc = oCommKit.SUP_Id__r.Name;
            }
        }

        map<String, List<sObject>> mapOutputVar = new map<String, List <sObject>>();
        mapOutputVar.put(Constants.COMM_KIT_FIELD_GROUP, lstCommKitForJSON);
        
        String sResponse = JSONHandlerMethods.serialize(mapOutputVar, Constants.COMM_KIT_PROCESS_NAME);
        system.debug('-----JSON STRUCTURE BEFORE----' + sResponse);
        
        list<String> lstStrings = new list<String>();
        lstStrings = sResponse.split(Constants.SBC_TYPE_NAME);
        sResponse = '';
        for(Integer i = 0; i<lstStrings.size(); i++) {
            if(i == 0){
                sResponse = lstStrings[i];
              }
            else {
                list<String> lstCommTypes = lstStrings[i].subStringBefore(
                        ',')
                    .remove(
                        '"')
                    .split(';');
                String sTempCommTypes = Constants.SBC_TYPE_NAME + '[';
                for(String sVar: lstCommTypes)
                    sTempCommTypes += '"' + sVar + '",';
                sTempCommTypes = sTempCommTypes.subStringBeforeLast(',') +
                    '],';
                sResponse += sTempCommTypes + lstStrings[i].subStringAfter(
                    ',');
            }
        }
        
        sResponse = sResponse.replace(Constants.TRUE_WITH_QUOTES, Constants.TRUE_WITHOUT_QUOTES);
        sResponse = sResponse.replace(Constants.FALSE_WITH_QUOTES, Constants.FALSE_WITHOUT_QUOTES);
        sResponse = sResponse.replace('\\\""','$$SubstituteString$$'); //Added By Ankit
        sResponse = sResponse.replace('""', 'null');
        sResponse = sResponse.replace('\\\'','\''); //Added By Ankit
        sResponse = sResponse.replace('"null"','null');
        sResponse = sResponse.replace('$$SubstituteString$$','\\""'); // Added By Ankit
        
        system.debug('-----JSON STRUCTURE AFTER----' + sResponse);
        
        JSONParserForToken oJsonParserToken = null;
        oJsonParserToken = (null == oJsonParserToken) ? JSONParserForToken.getJSONParserForToken() : oJsonParserToken;
        
        SendRequestToNeuron.bFlagForR3 = true;
        String sESB_URL = ESB_URL__c.getValues(sWhomToSend).Process_ESB_URL__c;
        
        Map<HttpRequest, HttpResponse> mapResponse = SendRequestToNeuron.sendInfoToNeuron(sResponse, sESB_URL, oJsonParserToken);
        
        System.Debug('>>>> mapResponse: ' + mapResponse);
        System.Debug('>>>> Values()[0].getStatusCode() :' + mapResponse.Values()[0].getStatusCode());
        
        if(null == mapResponse) {
            System.debug('>>>> Came inside if');
            ErrorLogUtility.logIntegrationInfoWithRetryExt(Constants.FALIURE, Constants.OUTBOUND,
                Constants.CLASS_NAME_COMMUNICATIONKITSEND, Constants.METHOD_NAME_FORCALLOUT,
                Constants.SOURCE_SYSTEM_SFDC_USA, null, Constants.ErrorString_25_FALIURE_TO_SEND_INFO +
                sResponse, sResponse, null, null, null, sESB_URL, 'POST', null , 'SBCIntegration');
        } else if(mapResponse.Values()[0].getStatusCode() != 200 && mapResponse.Values()[
                0].getStatusCode() != 201) {
            System.debug('>>>> Came inside else if');
            ErrorLogUtility.logIntegrationInfoWithRetryExt(Constants.FALIURE, Constants.OUTBOUND,
                Constants.CLASS_NAME_COMMUNICATIONKITSEND, Constants.METHOD_NAME_FORCALLOUT,
                Constants.SOURCE_SYSTEM_SFDC_USA, mapResponse.Values()[0].getStatusCode(),
                Constants.ErrorString_25_FALIURE_TO_SEND_INFO + sResponse, sResponse,
                mapResponse.Values()[0].getBody(), mapResponse.Values()[0].getStatus(),
                null, sESB_URL, 'POST', null , 'SBCIntegration');
        } else if(mapResponse.Values()[0].getStatusCode() == 200 || mapResponse.Values()[
                0].getStatusCode() == 201) {
            
            for(Communication_Kit__c oCommKit: lstScope) 
            {
                oCommKit.Printed_Not_Sent_To_FO__c = false;
            }
            TriggerContextUtility.switchOffCommunicationTrigger();
            if(lstScope.size() > 0) {
                List<Database.SaveResult> lstUpdateResults = Database.update(
                    lstScope, false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, lstScope, 'Communication_Kit__c',
                    'BatchPrintPortalCallout', 'execute', 'SFDC-CI', false);
            }
        }
        
    }
    
     /**
    * Method name  : finish
    * Description  : This method executes upon completion of the batch process
    * Return Type  : void
    * Parameter    : Database.BatchableContext
    **/
     global void finish(Database.BatchableContext BC)
     {
        String str = system.now().addMinutes(15).format('ss mm HH dd MM ? yyyy');
        System.schedule('ScheduleBatchPrintPortalCallout', str , new ScheduleBatchPrintPortalCallout());
        
     }
}