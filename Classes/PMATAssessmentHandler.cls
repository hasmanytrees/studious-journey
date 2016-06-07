/******************************************************************************************************
Class Name         : PMATAssessmentHandler
Description        : This is single Class for PMAT Assessment which will cover all the PMAT Assessment Functionality.
                     All Methods to cover PMAT Assessment functionality will be defined in this class. These methods
                     will be called from PMATAssessmentTrigger based on required trigger events.
Created By         : Sudipta Nayak
Created On         : 14-Jul-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class PMATAssessmentHandler {
    /**
     * Method name  : onAfterInsert
     * Description  : This method will be called after any PMAT Assessment record is inserted
     * Return Type  : void
     * Parameter    : List<PMAT_Assessment__c>
     **/
    public void onAfterInsert(List<PMAT_Assessment__c> lstNewRecords) {
        if(System.Label.Disable_for_Data_Load_R3 != 'true')
        {
            createTaskForICPOnPMATInsert(lstNewRecords);
        }
    }

    /**
     * Method name  : onAfterUpdate
     * Description  : This method will be called after any PMAT Assessment record is updated
     * Return Type  : void
     * Parameter    : List<PMAT_Assessment__c>, Map<Id, PMAT_Assessment__c>
     **/
    public void onAfterUpdate(List<PMAT_Assessment__c> lstNewRecords, Map<Id,
        PMAT_Assessment__c> mapOldRecords) {
        if(System.Label.Disable_for_Data_Load_R3 != 'true')
        {
            createTaskForICPOnPMATUpdate(lstNewRecords, mapOldRecords);
        }
        updateICPMaturityField(lstNewRecords, mapOldRecords);
    }

    /**
     * Method name  : updateICPMaturityField
     * Description  : This method will update the ICP's Maturity level once the PMAT Assessment is complete
     * Return Type  : void
     * Parameter    : List<PMAT_Assessment__c>, Map<Id, PMAT_Assessment__c>
     **/
    public void updateICPMaturityField(List<PMAT_Assessment__c> lstNewRecords,
        Map<Id, PMAT_Assessment__c> mapOldRecords) {
        Map<id, String> mapOfMaturityValues = new Map<id, String>();
        for (PMAT_Assessment__c oCurrRec: lstNewRecords) 
        {
            if (oCurrRec.PMAT_Completion_Date__c != null) {
                mapOfMaturityValues.put(oCurrRec.Account_Name__c, oCurrRec.PMAT_Combined_Maturity_Level__c);
            }
        }
        
        List<Account> lstOfAcc = [Select id, Initial_Maturity_Level__c from Account where id IN:
            mapOfMaturityValues.keyset()
        ];
        for (Account oCurrAcc: lstOfAcc) 
        {
            if (mapOfMaturityValues.get(oCurrAcc.id) == Constants.PMAT_Developing_Partnership) {
                oCurrAcc.Initial_Maturity_Level__c = Constants.ICP_Maturity_Developing;
            } else if (mapOfMaturityValues.get(oCurrAcc.id) == Constants.PMAT_Established_Partnership) {
                oCurrAcc.Initial_Maturity_Level__c = Constants.ICP_Maturity_Established;
            } else if (mapOfMaturityValues.get(oCurrAcc.id) == Constants.PMAT_Mature_Partnership) {
                oCurrAcc.Initial_Maturity_Level__c = Constants.ICP_Maturity_Mature;
            }
        }
        List < Database.SaveResult > lstUpdateResults = new List<Database.SaveResult>();
        lstUpdateResults = Database.update(lstOfAcc, false);  
        Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(lstUpdateResults, lstOfAcc, 'Account', 'PMATAssessmentHandler', 'updateICPMaturityField','SFDC CI', false);
        
    }

    /**
     * Method name  : createTaskForICPOnPMATInsert
     * Description  : This method will create a task on the ICP for which the PMAT
                      Assessment record is created
     * Return Type  : void
     * Parameter    : List<PMAT_Assessment__c>
     **/
    private void createTaskForICPOnPMATInsert(List<PMAT_Assessment__c>
        lstNewRecords) {
        Set<Id> setICPIds = new Set<Id>();
        List<Task> lstTaskToInsert = new List<Task>();
        List<Contact> lstContacts = new List<Contact>();
        Map<Id, Contact> mapICPToContact = new Map<Id, Contact>();
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        Id taskRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Task.SObjectType,
            Constants.TASK_GN_RT_API_NAME);
        for (PMAT_Assessment__c oPMAT: lstNewRecords) {
            setICPIds.add(oPMAT.Account_Name__c);
        }
        System.debug('setICPIds:' + setICPIds);
        if (!setICPIds.isEmpty()) {
            lstContacts = [SELECT id, AccountId, Role_At_ICP__c from Contact
                where AccountId in : setICPIds AND Role_At_ICP__c = 'Project Director'
            ];
            for(Account oAccount: [Select Id, Partnership_Facilitator__c from Account Where Id IN: setICPIds]){
                if(!mapAccount.containsKey(oAccount.Id)){
                    mapAccount.put(oAccount.Id, oAccount);
                }
            }
        }
        System.debug('lstContacts:' + lstContacts);
        for (PMAT_Assessment__c oPMAT: lstNewRecords) {
            Task oTask = new Task();
            oTask.RecordTypeId = taskRecordTypeId;
            oTask.Activity_Type__c = System.Label.PMAT_Task_Activity_Type;
            oTask.Subject = System.Label.PMAT_Task_New_Subject;
            oTask.Description = System.Label.PMAT_Task_New_Description;
            oTask.WhoId = oPMAT.PMAT_ICP_Representative__c;
            oTask.ActivityDate = oPMAT.PMAT_Assessment_End_Date__c + 60;
            oTask.ReminderDateTime = oTask.ActivityDate - 21;
            oTask.IsReminderSet = TRUE;
            oTask.Activity_Source__c = System.Label.PMAT_Task_Activity_Source;
            oTask.WhatId = oPMAT.id;
            if(!mapAccount.isEmpty() && mapAccount.containsKey(oPMAT.Account_Name__c)){
                oTask.OwnerId = mapAccount.get(oPMAT.Account_Name__c).Partnership_Facilitator__c;
            }
            lstTaskToInsert.add(oTask);
        }
        System.debug('lstTaskToInsert:' + lstTaskToInsert);
        if (!lstTaskToInsert.isEmpty()) {
            List<Database.SaveResult> lstInsertResults =
                Database.insert(lstTaskToInsert, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstInsertResults, lstTaskToInsert, 'PMAT_Assessment__c',
                'PMATAssessmentHandler', 'createTaskForICPOnPMATInsert', 'SFDC CI', false
            );
            System.debug('After Insert');
        }
        System.debug('END');
    }

    /**
     * Method name  : createTaskForICPOnPMATUpdate
     * Description  : This method will create a task on the ICP when the Next Assessment Date
     *                of the PMAT Assessment record is updated
     * Return Type  : void
     * Parameter    : List<PMAT_Assessment__c>, Map<Id, PMAT_Assessment__c>
     **/
    private void createTaskForICPOnPMATUpdate(List<PMAT_Assessment__c>
        lstNewRecords, Map<Id, PMAT_Assessment__c> mapOldRecords) {
        Set<Id> setICPIds = new Set<Id>();
        List<Task> lstTaskToInsert = new List<Task>();
        List<Contact> lstContacts = new List<Contact>();
        Map<Id, Contact> mapICPToContact = new Map<Id, Contact>();
        Id taskRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Task.SObjectType,
            Constants.TASK_GN_RT_API_NAME);
        for (PMAT_Assessment__c oPMAT: lstNewRecords) {
            if (mapOldRecords.get(oPMAT.id)
                .PMAT_Next_Assessment_Date__c != oPMAT.PMAT_Next_Assessment_Date__c) {
                setICPIds.add(oPMAT.Account_Name__c);
            }
        }
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        System.debug('setICPIds:' + setICPIds);
        if (!setICPIds.isEmpty()) {
            lstContacts = [SELECT id, AccountId, Role_At_ICP__c from Contact
                where AccountId in : setICPIds AND Role_At_ICP__c = 'Project Director'
            ];
            for(Account oAccount: [Select Id, Partnership_Facilitator__c from Account Where Id IN: setICPIds]){
                if(!mapAccount.containsKey(oAccount.Id)){
                    mapAccount.put(oAccount.Id, oAccount);
                }
            }
        }
        System.debug('lstContacts:' + lstContacts);
        if (!setICPIds.isEmpty()) {
            for (PMAT_Assessment__c oPMAT: lstNewRecords) {
                Task oTask = new Task();
                oTask.RecordTypeId = taskRecordTypeId;
                oTask.Activity_Type__c = System.Label.PMAT_Task_Activity_Type;
                oTask.Subject = System.Label.PMAT_Task_Complete_Subject;
                oTask.Description = System.Label.PMAT_Task_Complete_Description;
                oTask.WhoId = oPMAT.PMAT_ICP_Representative__c;
                oTask.ActivityDate = oPMAT.PMAT_Next_Assessment_Date__c.addMonths(-2);
                oTask.Activity_Source__c = System.Label.PMAT_Task_Activity_Source;
                oTask.WhatId = oPMAT.Account_Name__c;
                if(!mapAccount.isEmpty() && mapAccount.containsKey(oPMAT.Account_Name__c)){
                    oTask.OwnerId = mapAccount.get(oPMAT.Account_Name__c).Partnership_Facilitator__c;
                }
                lstTaskToInsert.add(oTask);
            }
        }
        System.debug('lstTaskToInsert:' + lstTaskToInsert);
        if (!lstTaskToInsert.isEmpty()) {
            List<Database.SaveResult> lstInsertResults =
                Database.insert(lstTaskToInsert, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstInsertResults, lstTaskToInsert, 'PMAT_Assessment__c',
                'PMATAssessmentHandler', 'createTaskForICPOnPMATUpdate', 'SFDC CI', false
            );
            System.debug('After Insert');
        }
        System.debug('END');
    }
}