/******************************************************************************************************
Class Name         : BatchMergeCommunications
Description        : This class queries all the B2S communication with Ready To Be Prinetd status and
                     merge them based on beneficiary and supporter combination
Created By         : Rahul Agarwal
Created On         : 12-Oct-2015 
******************************************************************************************************/
global class BatchMergeCommunications implements database.batchable < SObject > ,
    database.stateful {
        global map < Id, map < Id, Communication_Kit__c >>
            mapLastUpdatedCommunication = new map < Id, map < Id, Communication_Kit__c >>
            ();
        /**
         * Method name  : start
         * Description  : This method queries all the communications
         * Return Type  : Database.Querylocator
         * Parameter    : Database.BatchableContext
         **/
        public Database.Querylocator start(Database.BatchableContext bc) {
            Id B2SRecordType = [Select Id from RecordType where DeveloperName = 'B2S'
                AND SObjectType = 'Communication_Kit__c'
                limit 1
            ].Id;
            String sQuery;
            sQuery =
                'Select Id, Status__c, Communication_Types__c, BEN_ID__c, SUP_ID__c from Communication_Kit__c where RecordTypeId =: B2SRecordType AND Status__c = \'Ready to be printed\' Order By BEN_ID__c, SUP_ID__c, CreatedDate';
            Database.Querylocator oQueryLocator = Database.getQueryLocator(sQuery);
            return oQueryLocator;
        }

        /**
         * Method name  : execute
         * Description  : This method merges all the communications
         * Return Type  : void
         * Parameter    : Database.BatchableContext
         **/
        public void execute(Database.BatchableContext BC, List < sObject > scope) {
            // Parsing scope to a communication kit list
            list < Communication_Kit__c > lstCommKits = new list < Communication_Kit__c >
                ();
            lstCommKits = (list < Communication_Kit__c > ) scope;
            Integer iNoOfCommKits = lstCommKits.size();
            Integer iNoReached = 0;
            // Map to order the communication kits based on beneficiary and supporter
            map < Id, map < Id, Communication_Kit__c >> mapCommunications = new map <
                Id, map < Id, Communication_Kit__c >> ();
            map < Id, Communication_Kit__c > mapCommKitUpdate = new map <
                Id, Communication_Kit__c > ();
            list < Communication_Kit__c > lstCommKitDelete = new list <
                Communication_Kit__c > ();
            for (Communication_Kit__c oCommKit: lstCommKits) {
                if(oCommKit.BEN_ID__c != null && oCommKit.SUP_ID__c != null && oCommKit.Communication_Types__c != '' &&  
                oCommKit.Communication_Types__c != null)
                {                
                    iNoReached++;
                    // checking for beneficiary id
                    if (!mapCommunications.containsKey(oCommKit.BEN_ID__c))
                        mapCommunications.put(oCommKit.BEN_ID__c, new map < Id,
                            Communication_Kit__c > ());
    
                    //Checking for BEN and SUP combination
                    if (mapLastUpdatedCommunication.containsKey(oCommKit.BEN_ID__c) &&
                        mapLastUpdatedCommunication.get(oCommKit.BEN_ID__c).containsKey(
                            oCommKit.SUP_ID__c)) {
    
                        mapCommunications.get(oCommKit.BEN_ID__c).put(oCommKit.SUP_ID__c,
                            mapLastUpdatedCommunication.get(oCommKit.BEN_ID__c).get(oCommKit.SUP_ID__c)
                        );
                        // reinitiating the map so that it does not contain any records any more
                        mapLastUpdatedCommunication = new map < Id, map < Id,
                            Communication_Kit__c >> ();
                    }
    
                    // checking for supporter id
                    if (!mapCommunications.get(oCommKit.BEN_ID__c).containsKey(oCommKit.SUP_ID__c))
                        mapCommunications.get(oCommKit.BEN_ID__c).put(oCommKit.SUP_ID__c,
                            oCommKit);
                    // if communication kit already present, then merging it
                    else if (mapCommunications.get(oCommKit.BEN_ID__c).containsKey(oCommKit.SUP_ID__c)) {
                        Communication_Kit__c oOldRecord = mapCommunications.get(oCommKit.BEN_ID__c)
                            .get(oCommKit.SUP_ID__c);
                        if (oOldRecord.Communication_Types__c != null)
                            oOldRecord.Communication_Types__c += ';' + oCommKit.Communication_Types__c;
                        else
                            oOldRecord.Communication_Types__c = oCommKit.Communication_Types__c;
    
                        list < String > lstCommTypes = new list < String > ();
                        lstCommTypes = oOldRecord.Communication_Types__c.split(';');
                        
                        oOldRecord.Communication_Types__c = '';
                        system.debug('<><><><> ' + lstCommTypes);
                        for (String sVar: lstCommTypes) {
                            system.debug('<><><> ' + oOldRecord.Communication_Types__c);
                            if (!oOldRecord.Communication_Types__c.contains(sVar))
                                oOldRecord.Communication_Types__c += sVar + ';';
                            system.debug('<><><> ' + oOldRecord.Communication_Types__c);
                        }
                        
                        oOldRecord.Communication_Types__c = oOldRecord.Communication_Types__c.subStringBeforeLast(
                        ';');
                        system.debug('<><><> ' + oOldRecord.Communication_Types__c);
                        mapCommKitUpdate.put(oOldRecord.Id, oOldRecord);
                        lstCommKitDelete.add(oCommKit);
                    }
                    if (iNoReached == iNoOfCommKits) {
                        mapLastUpdatedCommunication = new map < Id, map < Id,
                            Communication_Kit__c >> ();
                        mapLastUpdatedCommunication.put(oCommKit.BEN_ID__c, new map < Id,
                            Communication_Kit__c > {
                                oCommKit.SUP_ID__c => mapCommunications.get(oCommKit.BEN_ID__c).get(oCommKit.SUP_ID__c)
                            });
                    }
                }
            }
            if (mapCommKitUpdate.Values().size() > 0) {
                update mapCommKitUpdate.Values();
            }
            if (lstCommKitDelete.size() > 0) {
                delete lstCommKitDelete;
            }
        }

        /**
         * Method name  : finish
         * Description  : This method schedules the next job for archiving the future cases
         * Return Type  : void
         * Parameter    : Database.BatchableContext
         **/
        public void finish(Database.BatchableContext BC) {

        }
    }