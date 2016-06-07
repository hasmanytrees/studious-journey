/******************************************************************************************************
Class Name         : BatchLetterWritingClass
Description        : A batch for creating Scheduled Letter Writing communications 
Created By         : Akashdeep 
Created On         : 07/16/2015
******************************************************************************************************/
global class BatchLetterWritingClass implements Database.Batchable<sObject> {
    global String query;
    global set<Id> setICPIds = new set<Id>();
    global Id cdspBenefRecTypeId;
    
    
    global BatchLetterWritingClass(String query, set<Id> setICPIds, Id cdspBenefRecTypeId){
        this.query = query;
        this.setICPIds = setICPIds;
        this.cdspBenefRecTypeId = cdspBenefRecTypeId;
    }
    /**
     * Method name  : start
     * Description  : This method fetches all beneficiaries that need to write letters
     * Return Type  : Database.QueryLocator
     * Parameter    : Database.BatchableContext
     **/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        /*DateTime dtmNow = datetime.now();
        String sMonthName = dtmNow.format(Constants.PrintPortal_CurrMonth);
        Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);

        list<Account> lstICPs = new list<Account>();
        lstICPs = [select Id from Account where RecordTypeId = : icpRecTypeId AND(
            ICP_Schedule_Second_Letter_Writing_Month__c = : sMonthName OR ICP_Schedule_First_Letter_Writing_Month__c = :
            sMonthName)];
        System.debug('>>> lstICPs : ' + lstICPs);
        set<Id> setICPIds = new set<Id>();

        for(Account oAcc: lstICPs) {
            setICPIds.add(oAcc.Id);
        }
        System.debug('>>> setICPIds: ' + setICPIds);
        Id cdspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        query =
            'Select Id, Local_Beneficiary_Id__c, RecordTypeId, Beneficiary_Status__c from Account where ICP__c IN: setICPIds AND Beneficiary_Status__c = \'Active\' AND RecordTypeId =: cdspBenefRecTypeId ';
        System.debug('>>> query: ' + query);*/

        return Database.getQueryLocator(query);
    }

    /**
     * Method name  : execute
     * Description  : This method creates the Scheduled Letters
     * Return Type  : void
     * Parameter    : Database.BatchableContext, List<Account>
     **/
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        system.debug(scope + '****');
        map<String, String> mapLocalBenIdCommType = new map<String, String>();
        Id cdspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        for(Account oAcc: scope) {
            if(oAcc.Local_Beneficiary_Id__c != null)
                mapLocalBenIdCommType.put(String.ValueOf(oAcc.Local_Beneficiary_ID__c),
                    Constants.CORRESPONDENCE_ITEM_TYPE_SCHEDULED_LETTER);
        }
        system.debug(mapLocalBenIdCommType + '****');
        CommunicationKitHandler.findOrCreateCommKitRecord(mapLocalBenIdCommType,
            null);
    }

    /**
     * Method name  : finish
     * Description  : This method executes upon completion of the batch process
     * Return Type  : void
     * Parameter    : Database.BatchableContext
     **/
    global void finish(Database.BatchableContext BC) {

    }
}