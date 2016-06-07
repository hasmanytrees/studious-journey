/******************************************************************************************************
Class Name         : CommunicationUpdates
Description        : This class sends the communication status updates to Global Partners
Created By         : Rahul Agarwal 
Created On         : 03-Jul-2015
******************************************************************************************************/
@
RestResource(urlMapping = '/CommunicationUpdates')
global class CommunicationUpdates {
    /**
     * Method name  : reqCommunicationUpdates
     * Description  : This method is to accept status changes in communication kits
     * Return Type  : void
     * Parameter    : void
     **/
    @
    HttpPost
    global static void reqCommunicationUpdates() {
            RestRequest request = RestContext.request;
            RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
            String sRequest = request.requestBody.toString()
                .trim();
            // Handling boolean and null values in the incoming JSON 
            sRequest = sRequest.replace(Constants.TRUE_WITHOUT_QUOTES, Constants.TRUE_WITH_QUOTES);
            sRequest = sRequest.replace(Constants.FALSE_WITHOUT_QUOTES, Constants.FALSE_WITH_QUOTES);
            // Handling Communoication Type in incoming JSON

            list<String> lstTempRequest = new list<String>();
            lstTempRequest = sRequest.split(Constants.SBC_TYPE_NAME);
            sRequest = '';
            for(Integer i = 0; i<lstTempRequest.size(); i++) {
                if(i == 0)
                    sRequest = lstTempRequest[i];
                else {
                    sRequest += Constants.SBC_TYPE_NAME + '"';
                    String sTempString = lstTempRequest[i].substringAfter('[')
                        .substringBefore(
                            ']');
                    sTempString = sTempString.replace('"', '');
                    list<String> lstTempString = new list<String>();
                    lstTempString = sTempString.split(',');
                    for(String sVar: lstTempString) {
                        sRequest += sVar.trim() + ';';
                    }
                    sRequest = sRequest.subStringBeforeLast(';');
                    sRequest += '"' + lstTempRequest[i].substringAfter(']');
                }
            }

            // Removing enter statements
            sRequest = sRequest.replace('\n', '');
            sRequest = sRequest.replace('\r', '');
            sRequest = sRequest.replace('\t', '');

            //Deserializing the JSON
            list<SObject> lstSObject = null;
            try {
                lstSObject = (list<SObject> ) JSONHandlerMethods.deserialize(sRequest,
                    Constants.COMMUNICATIONUPDATES_REQ_PN);
            } catch(Exception oEx) {
                populateInternalServerIntegrationError(oEx, Constants.METHOD_NAME_REQCOMMUNICATIONUPDATES,
                    null);
                return;
            }
            list<Communication_Kit__c> lstCommKitFromJSON = new list <
                Communication_Kit__c>();
            lstCommKitFromJSON = (list<Communication_Kit__c> ) lstSObject;
            // FInd comm it ids
            set<String> setCommunicationKitIds = new set<String>();
            for(Communication_Kit__c oCommKit: lstCommKitFromJSON)
                if(oCommKit.INT_Communication_Kit_Id__c != null)
                    setCommunicationKitIds.add(oCommKit.INT_Communication_Kit_Id__c);

                // Querying all Comm Kits
            list<Communication_Kit__c> lstCommKitToUpdate = new list <
                Communication_Kit__c>();
            lstCommKitToUpdate = [select Id, Name from Communication_Kit__c where Name IN:
                setCommunicationKitIds
            ];
            map<String, Communication_Kit__c> mapCommKitsToUpdate = new map<String,
                Communication_Kit__c>();
            for(Communication_Kit__c oCommKit: lstCommKitToUpdate)
                mapCommKitsToUpdate.put(oCommKit.Name, oCommKit);

            for(Communication_Kit__c oCommKit: lstCommKitFromJSON) {
                if(oCommKit.INT_Communication_Kit_Id__c != null && mapCommKitsToUpdate.containsKey(
                        oCommKit.INT_Communication_Kit_Id__c))
                    oCommKit.Id = mapCommKitsToUpdate.get(oCommKit.INT_Communication_Kit_Id__c)
                    .Id;
                else if(oCommKit.INT_Communication_Kit_Id__c != null && !
                    mapCommKitsToUpdate.containsKey(oCommKit.INT_Communication_Kit_Id__c)) {
                    populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQCOMMUNICATIONUPDATES,
                        Constants.ErrorString_8_INVALID + Constants.ErrorString_9_COMMUNICATION_KIT_ID +
                        oCommKit.INT_Communication_Kit_Id__c);
                    return;
                }
                oCommKit.INT_Communication_Kit_Id__c = '';
            }
            try {
                if(!lstCommKitFromJSON.IsEmpty())
                    update lstCommKitFromJSON;
            } catch(Exception oEx) {
                populateInternalServerIntegrationError(oEx, Constants.METHOD_NAME_REQCOMMUNICATIONUPDATES,
                    null);
                return;
            }

            //Sending the response 
            list<Communication_Kit__c> lstToSendResponse = new list <
                Communication_Kit__c>();
            lstToSendResponse = [select Id, Name, Local_GP_Kit_ID__c, Status__c,
                INT_Communication_Kit_ID__c from Communication_Kit__c where Id IN:
                lstCommKitFromJSON
            ];
            Map<String, List<sObject>> mapOutputVar = new Map<String, List <
                sObject>>();
            for(Communication_Kit__c oCommKit: lstToSendResponse)
                oCOmmKit.INT_Communication_Kit_Id__c = oCommKit.Name;
            mapOutputVar.put(Constants.COMMUNICATION_RESPONSES_FG, lstToSendResponse);
            String sJsonResponse = JSONHandlerMethods.serialize(mapOutputVar, Constants.COMMUNICATION_RESPONSES_PN);
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        }
        /**
         * Method name  : sendCommunicationUpdates
         * Description  : This method sends the communication status updates to Global Partners
         * Return Type  : void
         * Parameter    : String, list<Communication_Kit__c>()
         **/
    public static void sendCommunicationUpdates(String sWhomToSend, list <
        Communication_Kit__c> lstCommKits) {
        system.debug('<><><> sendCommunicationUpdates - ' + sWhomToSend);
        system.debug('<><><> lstCommKits - ' + lstCommKits);
        set<Id> setCommKitIds = new set<Id>();
        for(Communication_Kit__c oCommKit: lstCommKits)
            setCommKitIds.add(oCommKit.Id);

        System.Debug('setCommKitIds : ' + setCommKitIds);
        String sFieldsQuery = Utility.getFieldGroupElements(Constants.COMMUNICATIONUPDATES_RES_FG);
        String sQuery = 'Select ' + sFieldsQuery +
            'CreatedById from Communication_Kit__c where Id IN: setCommKitIds';

        list<Communication_Kit__c> lstCommKitForJSON = new list <
            Communication_Kit__c>();
        try {
            lstCommKitForJSON = database.query(sQuery);
        } catch(System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, Constants.CLASS_NAME_COMMUNICATIONUPDATES,
                Constants.METHOD_NAME_SENDCOMMUNICATIONUPDATES, Constants.SOURCE_SYSTEM_SFDC_CI
            );
        }

        System.Debug('lstCommKitForJSON  ' + lstCommKitForJSON.size());

        map<String, Record_Type_Mapping_For_SBC_Integration__c>
            mapRecordTypeMapping = new map<String,
            Record_Type_Mapping_For_SBC_Integration__c>();
        mapRecordTypeMapping = Record_Type_Mapping_For_SBC_Integration__c.getAll();
        set<String> setRecordTypeMappingValues = new set<String>();
        for(Record_Type_Mapping_For_SBC_Integration__c oVar: mapRecordTypeMapping.Values())
            setRecordTypeMappingValues.add(oVar.RecordType_Name_For_Integration__c);

        list<RecordType> lstRecordType = new list<RecordType>();
        lstRecordType = [select Id, Name, DeveloperName from RecordType where SObjectType = :
            Constants.COMMUNICATION_KIT_API_NAME
        ];
        map<String, RecordType> mapRecordType = new map<String, RecordType>();
        for(RecordType oRecType: lstRecordType)
            mapRecordType.put(oRecType.Name, oRecType);

        for(Communication_Kit__c oCommKit: lstCommKitForJSON) {
            if(!setRecordTypeMappingValues.contains(oCommKit.RecordType.Name))
                oCommKit.RecordType.Name = mapRecordTypeMapping.get(mapRecordType.get(
                        oCommKit.RecordType.Name)
                    .DeveloperName)
                .RecordType_Name_For_Integration__c;
        }

        System.debug('Came outside');

        /* Akash's changes for Onramp URL */
        map<String, map<String, List<sObject>>> mapOuterOutputVar;
        if(sWhomToSend == Constants.GP) {
            System.debug('Came inside too');
            Integer Count = 0;
            mapOuterOutputVar = new map<String, map<String, List<sObject>>>();
            for(Communication_Kit__c oCommKit: lstCommKitForJSON) {
                Count += 1;
                if(mapOuterOutputVar.containsKey(oCommKit.Global_Partner_ID__c)) {
                    map<String, List<sObject>> mapInner = mapOuterOutputVar.get(oCommKit
                        .Global_Partner_ID__c);
                    if(mapInner.containsKey(Constants.COMMUNICATIONUPDATES_RES_FG)) {
                        List<sObject> CommList = mapInner.get(Constants.COMMUNICATIONUPDATES_RES_FG);
                        CommList.add(oCommKit);
                        mapInner.put(Constants.COMMUNICATIONUPDATES_RES_FG, CommList);
                    } else {
                        List<sObject> CommList = new List<sObject>();
                        CommList.add(oCommKit);
                        mapInner.put(Constants.COMMUNICATIONUPDATES_RES_FG, CommList);
                    }
                    mapOuterOutputVar.put(oCommKit.Global_Partner_ID__c, mapInner);
                } else {
                    List<sObject> CommList = new List<sObject>();
                    CommList.add(oCommKit);
                    map<String, List<sObject>> mapInner = new map<String, List <
                        sObject>>();
                    mapInner.put(Constants.COMMUNICATIONUPDATES_RES_FG, CommList);
                    mapOuterOutputVar.put(oCommKit.Global_Partner_ID__c, mapInner);
                }
            }
            System.Debug('Count: ' + Count);
            System.Debug('mapOuterOutputVar: ' + mapOuterOutputVar.size());
        }
        if(sWhomToSend == 'GP') {
            for(String sGPId: mapOuterOutputVar.keyset()) {
                System.debug('sGPId : ' + sGPId);
                map<String, List<sObject>> mapOutputVar = mapOuterOutputVar.get(sGPId);
                callCommunicationKitSend(mapOutputVar, sWhomToSend, sGPId);
            }
        } else {
            System.debug('Came into else : ');
            map<String, List<sObject>> mapOutputVar = new map<String, List <
                sObject>>();
            mapOutputVar.put(Constants.COMMUNICATIONUPDATES_RES_FG, lstCommKitForJSON);
            callCommunicationKitSend(mapOutputVar, sWhomToSend, null);
        }
        /* Akash's changes for Onramp URL */

    }

    private static void callCommunicationKitSend(map<String, List<sObject>>
        mapOutputVar, String sWhomToSend, String GpString) {
        String sResponse = JSONHandlerMethods.serialize(mapOutputVar, Constants.COMMUNICATIONUPDATES_RES_PN);
        system.debug('-----JSON STRUCTURE----' + sResponse);
        // Fixing type in outgoing JSON
        list<String> lstStrings = new list<String>();
        lstStrings = sResponse.split(Constants.SBC_TYPE_NAME);
        sResponse = '';
        for(Integer i = 0; i<lstStrings.size(); i++) {
            if(i == 0)
                sResponse = lstStrings[i];
            else {
                list<String> lstCommTypes = lstStrings[i].subStringBefore(',')
                    .remove(
                        '"')
                    .split(';');
                String sTempCommTypes = Constants.SBC_TYPE_NAME + '[';
                for(String sVar: lstCommTypes)
                    sTempCommTypes += '"' + sVar + '",';
                sTempCommTypes = sTempCommTypes.subStringBeforeLast(',') + '],';
                sResponse += sTempCommTypes + lstStrings[i].subStringAfter(',');
            }
        }

        sResponse = sResponse.replace(Constants.TRUE_WITH_QUOTES, Constants.TRUE_WITHOUT_QUOTES);
        sResponse = sResponse.replace(Constants.FALSE_WITH_QUOTES, Constants.FALSE_WITHOUT_QUOTES);
        sResponse = sResponse.replace('""', Constants.NULL_STRING);
        sResponse = sResponse.replace(Constants.NULL_IN_DOUBLE_QUOTES_STRING,
            Constants.NULL_STRING);
        system.debug('-----JSON STRUCTURE----' + sResponse);
        if(sWhomToSend != null) {
            system.enqueueJob(new CommunicationKitSend(sResponse,
                'SBCCommunicationUpdates_GP', Constants.POST_METHOD, GpString, true));

        }
    }

    /**
     * Method name  : populateInternalServerIntegrationError
     * Description  : This method populates the error and communicate the same
     * Return Type  : void
     * Parameter    : Exception, String, String
     **/
    private static void populateInternalServerIntegrationError(Exception oEx,
        String sMethodName, String sMessage) {
        RestContext.response.statusCode = 500;
        String sErrorMessage = (String.isBlank(sMessage)) ? oEx.getMessage() :
            sMessage;
        String sJsonResponse = Constants.CONTENT_FAILURE_RESPONSE + sErrorMessage +
            '"}}';
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo(Constants.FALIURE, Constants.INBOUND,
            Constants.CLASS_NAME_COMMUNICATIONUPDATES, sMethodName, Constants.SOURCE_SYSTEM_SFDC_CI,
            null, (String.isBlank(sMessage)) ? Constants.Commitment_Updates_LineNo +
            oEx.getLineNumber() +
            Constants.Commitment_Updates_Exec + oEx.getMessage() : sMessage,
            RestContext.request.requestBody
            .toString()
            .trim(), sJsonResponse, sJsonResponse, oEx);
    }
}