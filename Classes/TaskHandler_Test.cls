/******************************************************************************************************
Class Name         : TaskHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: TaskHandler
                     and TaskTrigger
Created By         : Rahul Agarwal
Created On         : 04-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(seeAllData = false)
Private Class TaskHandler_Test{
    static testmethod void tasks(){
        Test.startTest();
        Id icpRecTypeId= Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,Constants.ICP_RT_API_NAME);
        Id setupPlanRecTypeId = Utility.getRecordTypeIdByDeveloperName(Activity_Plan__c.SObjectType,Constants.SETUP_PLAN_RT_API_NAME);
        
        Account ICP = new Account(Name = 'ICP', RecordTypeId = icpRecTypeId, BillingCountry = 'India', BillingStreet = 'Street', BillingCity = 'Delhi', Partnership_Facilitator__c = UserInfo.getuserId(), Partnership_Facilitator_Supervisor__c = UserInfo.getuserId(), ICP_Status__c = Constants.ACTIVE, Partnership_Start_Date__c = System.today()-180);
        insert ICP;
        
        Activity_Plan__c aPlan = new Activity_Plan__c(Name = 'ActivityPlan', ICP__c = ICP.Id, RecordTypeid = setupPlanRecTypeId );
        insert aPlan;
        list<Task> newTasks = new list<Task>();
            newTasks.add(new Task(Subject = 'Subject', WhatId = aPlan.id, ActivityDate = System.today(), Activity_Type__c = Constants.MILESTONE, IsTriggerFlag__c = true, Is_Trigger_Workflow__c = true, Is_Trigger_Flag_For_Today__c = false, Is_Trigger_Workflow_For_Today__c = false));
            newTasks.add(new Task(Status = 'Completed', Subject = Constants.EMAIL_START, WhatId = aPlan.id, ActivityDate = System.today(), Activity_Type__c = Constants.MILESTONE, IsTriggerFlag__c = false, Is_Trigger_Workflow__c = false, Is_Trigger_Flag_For_Today__c = true, Is_Trigger_Workflow_For_Today__c = true));
        insert newTasks;
        System.assert(newTasks[0].id != NULL);
        newTasks[0].ActivityDate = System.today() - 1;
        newTasks[1].ActivityDate = System.today() - 1;
        update newTasks;
        Test.stopTest();
    }
    
    static testmethod void activityPlan(){
        Test.startTest();
        Id icpRecTypeId= Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,Constants.ICP_RT_API_NAME);
        Id setupPlanRecTypeId = Utility.getRecordTypeIdByDeveloperName(Activity_Plan__c.SObjectType,Constants.SETUP_PLAN_RT_API_NAME);
        
        Account ICP = new Account(Name = 'ICP', RecordTypeId = icpRecTypeId, BillingCountry = 'India', BillingStreet = 'Street', BillingCity = 'Delhi', Partnership_Facilitator__c = UserInfo.getuserId(),
                                  Partnership_Facilitator_Supervisor__c = UserInfo.getuserId(), ICP_Status__c = Constants.ACTIVE, Partnership_Start_Date__c = System.today()-180);
        insert ICP;
        
        Activity_Plan__c aPlan = new Activity_Plan__c(Name = 'ActivityPlan', ICP__c = ICP.Id, RecordTypeid = setupPlanRecTypeId );
        insert aPlan;
        list<Task> newTasks = new list<Task>();
        newTasks.add(new Task(Subject = 'Subject_test', WhatId = aPlan.id, Is_Trigger_Flag_For_Today__c = true, Is_Trigger_Workflow_For_Today__c = true, ActivityDate = System.today(), Activity_Completion_Date__c = null, Activity_Type__c = Constants.MILESTONE, IsTriggerFlag__c = false, Is_Trigger_Workflow__c = false));        
        insert newTasks;
        System.assert(newTasks[0].id != NULL);
        newTasks[0].ActivityDate = System.today() - 1;
        update newTasks;
        Test.stopTest();
    }
}