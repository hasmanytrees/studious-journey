/******************************************************************************************************
Class Name         : ScheduleLetterWritingClass
Description        : A scheduler for Scheduled Letter Writing Batch
Created By         : Akashdeep 
Created On         : 07/16/2015
******************************************************************************************************/
global class ScheduleLetterWritingClass implements Schedulable
{
    /**
    * Method name  : execute
    * Description  : This method executes the call for batch operation
    * Return Type  : void
    * Parameter    : SchedulableContext
    **/
    global void execute(SchedulableContext SC) 
    {
        DateTime dtmNow = datetime.now();
        String sMonthName = dtmNow.format(Constants.PrintPortal_CurrMonth);
        Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);

        list<Account> lstICPs = new list<Account>();
        lstICPs = [select Id from Account where RecordTypeId = : icpRecTypeId AND (
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
        String query =
            'Select Id, Local_Beneficiary_Id__c, RecordTypeId, Beneficiary_Status__c from Account where ICP__c IN: setICPIds AND Beneficiary_Status__c = \'Active\' AND RecordTypeId =: cdspBenefRecTypeId AND BEN_Next_Allowed_Writing_Date__c <= TODAY';
        
        BatchLetterWritingClass lwb = new BatchLetterWritingClass(query, setICPIds, cdspBenefRecTypeId);
        database.executebatch(lwb,200);
        system.abortJob(SC.getTriggerId());
    }
}