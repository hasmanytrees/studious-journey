/******************************************************************************************************
Class Name         : BatchUpdateCommunications
Description        : This class queries all the B2S communication with Ready To Be Prinetd status and
                     merge them based on beneficiary and supporter combination
Created By         : Rahul Agarwal
Created On         : 12-Oct-2015 
******************************************************************************************************/
global class BatchUpdateCommunications implements database.batchable < SObject > {
        
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
                'Select Id, Status__c, Communication_Types__c, BEN_ID__c, SUP_ID__c, Relationship_Type__c from Communication_Kit__c where RecordTypeId =: B2SRecordType AND Status__c = \'Ready to be printed\' AND Relationship_Type__c = \'Sponsor\' Order By BEN_ID__c, SUP_ID__c, CreatedDate';
            Database.Querylocator oQueryLocator = Database.getQueryLocator(sQuery);
            return oQueryLocator;
        }

        /**
         * Method name  : execute
         * Description  : This method merges all the communications
         * Return Type  : void
         * Parameter    : Database.BatchableContext
         **/
        public void execute(Database.BatchableContext BC, List < sObject > scope) 
        {
            List < Communication_Kit__c > lstScope = new List < Communication_Kit__c >();
            lstScope = (list < Communication_Kit__c > ) scope;
            List<Communication_Kit__c> lstToUpdate = new List<Communication_Kit__c>();
            Set<id> setOfBeneficiaries = new Set<id>();
            for(Communication_Kit__c oCommRec :  lstScope)
            {
                setOfBeneficiaries.add(oCommRec.BEN_ID__c);
            }   
            
            Map<Id, Commitment__c> mapofComms = new Map<Id, Commitment__c>();
            List<Commitment__c> lstCommit = new List<Commitment__c>();
            lstCommit = [Select id, BEN_Id__c, SUP_Id__c, Relationship_Type__c from Commitment__c where Status__c = 'Active' AND Relationship_Type__c = 'Correspondent' AND BEN_Id__c IN : setOfBeneficiaries ];
            
            if(lstCommit.size() > 0)
            {
                for(Commitment__c oCommitRec : lstCommit)
                {
                    mapofComms.put(oCommitRec.BEN_Id__c, oCommitRec);
                }
            }   
            
            
            for(Communication_Kit__c oCommRec :  lstScope)
            {
                if(mapofComms.containsKey(oCommRec.BEN_ID__c))
                {
                    oCommRec.SUP_ID__c = mapofComms.get(oCommRec.BEN_ID__c).SUP_Id__c;
                    oCommRec.Relationship_Type__c = mapofComms.get(oCommRec.BEN_ID__c).Relationship_Type__c;
                    lstToUpdate.add(oCommRec);
                }
            }
            
            List<Database.SaveResult> lstUpdateResults = new List<Database.SaveResult>();
            if(lstToUpdate.size() > 0)
            {
                 try {
                 lstUpdateResults = Database.update(lstToUpdate, false);
                 } catch(DmlException ex) {
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, lstToUpdate, 'Communication_Kit__c',
                    'CommunicationKitSearchPageController', 'getID', 'SFDC CI', false);
                }
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