/******************************************************************************************************
    Class Name         : BatchPlannedExitCorrespondanceItem
    Description        : This class is used to create correspondence events for planned exites. This class 
                        will run everyday at the same time.
    Created By         : Rahul Agarwal
    Created On         : 20-Jul-2015 
    ******************************************************************************************************
    Modification History:
    
    *******************************************************************************************************/
    global class BatchPlannedExitCorrespondanceItem implements Database.batchable <
        SObject > {
            /**
             * Method name  : start
             * Description  : This method queries all the beneficiaries with planned completion date
                              60 days from today
             * Return Type  : Database.Querylocator
             * Parameter    : Database.BatchableContext
             **/
            public Database.Querylocator start(Database.BatchableContext bc) {
                    Date dPlannedCompletionDate = system.today().addDays(Integer.ValueOf(Label.Planned_Completion_Thank_You_Letter));
                    system.debug('<><><> ' + dPlannedCompletionDate);
                    Id RecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME);
                    String sQuery =
                        'Select Id, Local_Beneficiary_Id__c,Beneficiary_Status__c from Account where RecordTypeId =: RecordTypeId AND Planned_Completion_Date__c =: dPlannedCompletionDate AND Beneficiary_Status__c = \'Active\'';
                    Database.Querylocator oQueryLocator = Database.getQueryLocator(sQuery);
                    return oQueryLocator;
                }
                /**
                 * Method name  : execute
                 * Description  : This method creates correspondence events
                 * Return Type  : void
                 * Parameter    : Database.BatchableContext
                 **/
            public void execute(Database.BatchableContext BC, List < sObject >
                scope) {
                list < Account > lstBen = (list < Account > ) scope;
                map < String, String > mapLocalBenIdCommType = new map < String, String > ();
                for (Account oAcc: lstBen){
                    if(oAcc.Local_Beneficiary_Id__c != null)
                    mapLocalBenIdCommType.put(oAcc.Local_Beneficiary_Id__c, Constants.CORRESPONDENCE_ITEM_TYPE);
                }
                CommunicationKitHandler.findOrCreateCommKitRecord(mapLocalBenIdCommType,null);
            }
            /**
                 * Method name  : finish
                 * Description  : This method is called at the end of the batch class
                 * Return Type  : void
                 * Parameter    : Database.BatchableContext
                 **/
            public void finish(Database.BatchableContext BC) {
    
            }
        }