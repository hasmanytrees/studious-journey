/******************************************************************************************************
Class Name         : TaskHandler
Description        : This is single Class for Task which will cover all the Task Functionality.
                     All Methods to cover Task functionality will be defined in this class. These methods
                     will be called from taskTrigger based on required trigger events.
Created By         : Danish Ahmed 
Created On         : 13-Feb-2014 
******************************************************************************************************/

public class TaskHandler {

  /**
   * Method name  : onBeforeInsert
   * Description  : This method will be called after any Task record is inserted
   * Return Type  : void
   * Parameter    : List<Task>
   **/
  public void onBeforeInsert(List<Task> lstNewRecords) {
    validateDueDate(lstNewRecords);
    preventTaskUpdateForCompletedFW(lstNewRecords);
    activityCompletionDateOnEmail(lstNewRecords);
  }

  /**
   * Method name  : onBeforeUpdate
   * Description  : This method will be called before any Task record is inserted
   * Return Type  : void
   * Parameter    : List<Task>, Map<Id,Task>
   **/
  public void onBeforeUpdate(List<Task> lstNewRecords, Map<Id, Task>
    mapOldRecords) {
    validateDueDate(lstNewRecords);
    preventTaskUpdateForCompletedFW(lstNewRecords);
    preventTaskFieldsUpdateForICPPartner(lstNewRecords, mapOldRecords);
    sendEmailToPFAndPFS(lstNewRecords, mapOldRecords);
  }
  /**
   * Method name  : onAfterInsert
   * Description  : This method will be called after any Task record is inserted
   * Return Type  : void
   * Parameter    : List<Task>
   **/
  public void onAfterInsert(List<Task> lstNewRecords) {
    UpdateSetupPlanTargetDate(lstNewRecords);
  }
   /**
   * Method name  : onAfterUpdate
   * Description  : This method will be called After any Task record is Updated
   * Return Type  : void
   * Parameter    : List<Task>, Map<Id,Task>
   **/
  public void onAfterUpdate(List<Task> lstNewRecords, Map<Id, Task>
    mapOldRecords) {
    updateActivityPlan(lstNewRecords);   
    
  }
  
    /**
    * Method name  : onBeforeDelete
    * Description  : This method will be called before any Task record is deleted
    * Return Type  : void
    * Parameter    : Map<Id,Task>
    **/
    public void onBeforeDelete(List<Task> lstOldRecords) {
        preventTaskDeletionByICPPartner(lstOldRecords);
    }

  /**
   * Method name  : validateDueDate
   * Description  : This method will validate the due date against the ICP Latest Agreement date
   * Return Type  : void
   * Parameter    : List<Task>
   **/
  private void validateDueDate(List<Task> lstNewRecords) {
    String sAccountPrefix = Schema.SObjectType.Account.getKeyPrefix();
    String sActivityPlanPrefix = Schema.SObjectType.Activity_Plan__c.getKeyPrefix();
    Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
      Constants.ICP_RT_API_NAME);
    Id setupPlanRecTypeId = Utility.getRecordTypeIdByDeveloperName(
      Activity_Plan__c.SObjectType, Constants.SETUP_PLAN_RT_API_NAME);
    Set<Id> setActivityPlanId = new Set<Id>();
    Set<Id> setAccId = new Set<Id>();
    for(Task oTask: lstNewRecords) {
      String sTaskWhatId = oTask.WhatId;
      if(oTask.WhatId != null && sTaskWhatId.startsWith(sActivityPlanPrefix) &&
        oTask.ActivityDate != null && oTask.Activity_Type__c == Constants.MILESTONE
      ) {
        setActivityPlanId.add(oTask.WhatId);
      }
    }
    if(!setActivityPlanId.isEmpty()) {
      Map<Id, Activity_Plan__c> mapIdToActivityPlan = null;
      mapIdToActivityPlan = new Map<Id, Activity_Plan__c> ([Select Id, Name,
        ICP__r.Id, ICP__r.Name, ICP__r.Partnership_Facilitator__r.Name, ICP__r.Partnership_Facilitator__c,
        ICP__r.Partnership_Facilitator_Supervisor__r.Name, ICP__r.Partnership_Facilitator_Supervisor__c,
        ICP__r.Agreement_Signed_Date__c from Activity_Plan__c
        where ICP__r.RecordTypeId = : icpRecTypeId AND RecordTypeId = :
        setupPlanRecTypeId AND Id in : setActivityPlanId AND ICP__r.ICP_Status__c = :
        Constants.ACTIVE
      ]);
      if(!mapIdToActivityPlan.isEmpty()) {
        for(Task oTask: lstNewRecords) {
          if(mapIdToActivityPlan.containsKey(oTask.WhatId)) {
            String sTaskWhatId = oTask.WhatId;
            if(oTask.WhatId != null && sTaskWhatId.startsWith(sActivityPlanPrefix) &&
              oTask.ActivityDate != null && oTask.Activity_Type__c == Constants.MILESTONE
            ) {
              if(mapIdToActivityPlan.get(oTask.WhatId)
                .ICP__r.Agreement_Signed_Date__c != null) {
                
                if( mapIdToActivityPlan.get(oTask.WhatId)  
                    .ICP__r.Agreement_Signed_Date__c.addMonths( 6 ) < 
                    oTask.ActivityDate  ) {
                  oTask.addError(System.Label.Task_Message);
                }
                
              }
            }
          }
        }
      }
    }
  }
   /**
   * Method name  : UpdateSetupPlanTargetDate
   * Description  : This method will Update Update Setup Plan TargetDate on task creation
   * Return Type  : void
   * Parameter    : List<Task>
   * Created By   : MV 
   **/
  private void UpdateSetupPlanTargetDate(List<Task> lstNewRecords) {
  
   List<Activity_Plan__c> lstActivityPlan =  new List<Activity_Plan__c>();
  List<Activity_Plan__c> lstActPlnToUpdate =  new List<Activity_Plan__c>();
   map<Id, Date> mapSetUptoTask =  new map<Id , date>();
   String sActivityPlanPrefix = Schema.SObjectType.Activity_Plan__c.getKeyPrefix();
                
     for(Task oTask: lstNewRecords) {
      String sTaskWhatId = oTask.WhatId;
      if(oTask.WhatId != null && sTaskWhatId.startsWith(sActivityPlanPrefix) &&
        oTask.ActivityDate != null && oTask.Activity_Type__c == Constants.MILESTONE &&
        oTask.Subject == Constants.Seventh_Task_Sub
      ) {
         if(!mapSetUptoTask.containskey(oTask.WhatId))
          mapSetUptoTask.put(oTask.WhatId ,oTask.ActivityDate); 
        }
      
    }
    lstActivityPlan = [Select id , Set_Up_Plan_Target_Date__c from Activity_Plan__c
                      where id in : mapSetUptoTask.keyset()];
         
           for(Activity_Plan__c oActplan : lstActivityPlan )
           {
              if(mapSetUptoTask.containskey(oActplan.id))
              {
              oActplan.Set_Up_Plan_Target_Date__c = mapSetUptoTask.get(oActplan.id); 
              }
              lstActPlnToUpdate .add(oActplan);
           }   

        
          if(!lstActPlnToUpdate.isEmpty()) {
          List<Database.SaveResult> lstUpdateResults = 
            Database.update(lstActPlnToUpdate , false);
          Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
            lstUpdateResults, lstActPlnToUpdate , 'Activity_Plan__c',
            'TaskHandler', 'UpdateSetupPlanTargetDate', 'SFDC CI', false);
        }    
  
  }

  /**
   * Method name  : sendEmailToPFAndPFS
   * Description  : This method will update task details in Account record related to Activity Plan
   * Return Type  : void
   * Parameter    : List<Task>, Map<Id,Task>
   **/
  private void sendEmailToPFAndPFS(List<Task> lstNewRecords, Map<Id, Task>
    mapOldRecords) {

    String sAccountPrefix = Schema.SObjectType.Account.getKeyPrefix();
    String sActivityPlanPrefix = Schema.SObjectType.Activity_Plan__c.getKeyPrefix();
    Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
      Constants.ICP_RT_API_NAME);
    id setupPlanRecTypeId = Utility.getRecordTypeIdByDeveloperName(
      Activity_Plan__c.SObjectType, Constants.SETUP_PLAN_RT_API_NAME);
    Set<Id> setActivityPlanId = new Set<Id>();
    Set<Id> setAccId = new Set<Id>();
    for(Task oTask: lstNewRecords) {
      String sTaskWhatId = oTask.WhatId;
      if(oTask.WhatId != null && sTaskWhatId.startsWith(sActivityPlanPrefix) &&
        oTask.ActivityDate != null && oTask.Activity_Type__c == Constants.MILESTONE
      ) {
        setActivityPlanId.add(oTask.WhatId);
      }
    }

    if(!setActivityPlanId.isEmpty()) {
      Map<Id, Activity_Plan__c> mapIdToActivityPlan = null;
      mapIdToActivityPlan = new Map<Id, Activity_Plan__c> ([Select Id, Name,
        ICP__r.Id, ICP__r.Name, ICP__r.Partnership_Facilitator__r.Name, ICP__r.Partnership_Facilitator__c,
        ICP__r.Partnership_Facilitator_Supervisor__r.Name, ICP__r.Partnership_Facilitator_Supervisor__c,
        ICP__r.Partnership_Start_Date__c from Activity_Plan__c
        where ICP__r.RecordTypeId = : icpRecTypeId AND RecordTypeId = :
        setupPlanRecTypeId AND Id in : setActivityPlanId AND ICP__r.ICP_Status__c = :
        Constants.ACTIVE
      ]);
      list<Account> lstAccountToUpdate = new List<Account>();
      if(!mapIdToActivityPlan.isEmpty()) {
        for(Task oTask: lstNewRecords) {
          if(mapIdToActivityPlan.containsKey(oTask.WhatId)) {
            String sTaskWhatId = oTask.WhatId;
            if(oTask.WhatId != null && sTaskWhatId.startsWith(sActivityPlanPrefix) &&
              oTask.IsTriggerFlag__c == true && oTask.Is_Trigger_Workflow__c == true &&
              oTask.ActivityDate != null && oTask.Activity_Completion_Date__c == null &&
              oTask.Activity_Type__c == Constants.MILESTONE) {
              Date dtTemp = Date.newInstance(oTask.ActivityDate.year(), oTask.ActivityDate
                .month(), oTask.ActivityDate.day());
              String sTaskDetail = Label.Mail_Header_For_PF_And_PFS + ' ' +
                mapIdToActivityPlan.get(oTask.WhatId)
                .ICP__r.Partnership_Facilitator__r.Name + '/' + mapIdToActivityPlan.get(
                  oTask.WhatId)
                .ICP__r.Partnership_Facilitator_Supervisor__r.Name + ',<br/><br/>' +
                Label.Mail_Body1_For_PF_And_PFS + ' ' + mapIdToActivityPlan.get(oTask.WhatId)
                .ICP__r.Name + ' ' + Label.Mail_Body2_For_PF_And_PFS + ' ' + Date.ValueOf(
                  oTask.ActivityDate)
                .format() + '. ' + Label.Mail_Body3_For_PF_And_PFS + '<br/>' +
                '<a href=https://' + System.URL.getSalesforceBaseUrl()
                .getHost() + '/' + oTask.Id + '>' +
                'Click to see Task</a><br/><br/><br/>' +
                Label.Mail_Footer1_For_PF_And_PFS + ',<br/>' +
                Label.Mail_Footer2_For_PF_And_PFS;
              Account oAcc = new Account();
              oAcc.id = mapIdToActivityPlan.get(oTask.WhatId)
                .ICP__r.Id;
              oAcc.Task_Detail__c = sTaskDetail;
              lstAccounttoUpdate.add(oAcc);
              oTask.IsTriggerFlag__c = false;
              oTask.Is_Trigger_Workflow__c = false;
            }
          } else {
            oTask.IsTriggerFlag__c = false;
            oTask.Is_Trigger_Workflow__c = false;
          }
          if(mapIdToActivityPlan.containsKey(oTask.WhatId)) {
            String sTaskWhatId = oTask.WhatId;
            if(oTask.WhatId != null && sTaskWhatId.startsWith(sActivityPlanPrefix) &&
              oTask.Is_Trigger_Flag_For_Today__c == true && oTask.Is_Trigger_Workflow_For_Today__c ==
              true && oTask.ActivityDate != null && oTask.Activity_Completion_Date__c ==
              null && oTask.Activity_Type__c == Constants.MILESTONE) {
              Date dtTemp = Date.newInstance(oTask.ActivityDate.year(), oTask.ActivityDate
                .month(), oTask.ActivityDate.day());
              String sTaskDetail = Label.Mail_Header_For_PF_And_PFS + ' ' +
                mapIdToActivityPlan.get(oTask.WhatId)
                .ICP__r.Partnership_Facilitator__r.Name + '/' + mapIdToActivityPlan.get(
                  oTask.WhatId)
                .ICP__r.Partnership_Facilitator_Supervisor__r.Name + ',<br/><br/>' +
                Label.Mail_Body1_For_PF_And_PFS + ' ' + mapIdToActivityPlan.get(oTask.WhatId)
                .ICP__r.Name + ' ' + Label.Mail_Body4_For_PF_and_PFS + ' ' + Date.ValueOf(
                  oTask.ActivityDate)
                .format() + '. ' + Label.Mail_Body3_For_PF_And_PFS + '<br/>' +
                '<a href=https://' + System.URL.getSalesforceBaseUrl()
                .getHost() + '/' + oTask.Id + '>' +
                'Click to see Task</a><br/><br/><br/>' +
                Label.Mail_Footer1_For_PF_And_PFS + ',<br/>' +
                Label.Mail_Footer2_For_PF_And_PFS;
              Account oAcc = new Account();
              oAcc.id = mapIdToActivityPlan.get(oTask.WhatId)
                .ICP__r.Id;
              oAcc.Task_Detail__c = sTaskDetail;
              lstAccounttoUpdate.add(oAcc);
              oTask.Is_Trigger_Flag_For_Today__c = false;
              oTask.Is_Trigger_Workflow_For_Today__c = false;
            }
          } else {
            oTask.Is_Trigger_Flag_For_Today__c = false;
            oTask.Is_Trigger_Workflow_For_Today__c = false;
          }
        }
        if(!lstAccountToUpdate.isEmpty()) {
          List<Database.SaveResult> lstUpdateResults = 
            Database.update(lstAccountToUpdate, false);
          Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
            lstUpdateResults, lstAccountToUpdate, 'Account',
            'TaskHandler', 'sendEmailToPFAndPFS', 'SFDC CI', false);
        }
      }
    }
  }

  /**
   * Method name  : activityCompletionDateOnEmail
   * Description  : This sets the Activity Completion Date for Emails
   * Return Type  : void
   * Parameter    : List<Task>
   **/
  public static void activityCompletionDateOnEmail(list<Task> lstNewRecords) {
    for(Task oTask: lstNewRecords) {
      if(oTask.Status <> null && oTask.Subject <> null && oTask.Status ==
        Constants.COMPLETED && oTask.Subject.startsWith(Constants.EMAIL_START)) {
        oTask.Activity_Completion_Date__c = System.today();
      }
    }
  }
  
   /**
    * Method name  : preventTaskUpdateForCompletedFW
    * Description  : This method will prevent user from editing tasks related to 
                     Completed Facilitation Workplan. 
    * Return Type  : void
    * Parameter    : List<Task>
    **/
    private void preventTaskUpdateForCompletedFW(List<Task> lstNewRecords){
        Id fwRecTypeId = Utility.getRecordTypeIdByDeveloperName(
          Activity_Plan__c.SObjectType, Constants.ACTIVITY_PLAN_FW_RT_API_NAME);
        Id taskRecTypeId = Utility.getRecordTypeIdByDeveloperName(
          Task.SObjectType, Constants.TASK_RT_API_NAME);
        Id setupPlanRecTypeId = Utility.getRecordTypeIdByDeveloperName(
          Activity_Plan__c.SObjectType, Constants.SETUP_PLAN_RT_API_NAME);
        String sActivityPlanPrefix = Schema.SObjectType.Activity_Plan__c.getKeyPrefix();
        Set<Id> setActivityPlanId = new Set<Id>();
        for(Task oTask: lstNewRecords) {
            String sTaskWhatId = oTask.WhatId;
            if(oTask.RecordTypeID == taskRecTypeId && oTask.WhatId != null && 
                sTaskWhatId.startsWith(sActivityPlanPrefix)){
                setActivityPlanId.add(oTask.WhatId);
            }
        }
        if(!setActivityPlanId.isEmpty()){
            Map<Id, Activity_Plan__c> mapIdtoActivityPlan = new Map<Id, Activity_Plan__c>([
                Select Id,Status__c,RecordTypeID from Activity_Plan__c where Id IN: setActivityPlanId]);
            if(!mapIdtoActivityPlan.isEmpty()){
                for(Task oTask: lstNewRecords){
                    if(mapIdtoActivityPlan.containsKey(oTask.WhatId)){                    
                        if(setupPlanRecTypeId.equals(mapIdtoActivityPlan.get(oTask.WhatId).RecordTypeId) && UserInfo.getUserType() == Constants.POWERPARTNER && trigger.isInsert){
                            oTask.addError(System.Label.TaskHandler_Error_On_Set_Up_Plan_Task);
                        }else if(fwRecTypeId.equals(mapIdtoActivityPlan.get(oTask.WhatId).RecordTypeId) && UserInfo.getUserType() == Constants.POWERPARTNER && trigger.isInsert){
                            oTask.addError(System.Label.TaskHandler_Error_On_Facilitation_Workplan_Task);
                        }else if(fwRecTypeId.equals(mapIdtoActivityPlan.get(oTask.WhatId).RecordTypeId) && mapIdtoActivityPlan.get(oTask.WhatId).Status__c == Constants.COMPLETED){
                            if(trigger.isInsert){
                                oTask.addError(System.Label.TaskHandler_Error_On_Comp_FW);
                            }else if(trigger.isUpdate){
                                oTask.addError(System.Label.TaskHandler_Error_On_Update_Of_Comp_FW);
                            }
                        }                                       
                    }
                }
            }
        } 
    }
    
    /**
    * Method name  : preventTaskFieldsUpdateForICPPartner
    * Description  : This method will prevent ICP Partner user from editing tasks 
                     related to setup plan and assigned to them.
    * Return Type  : void
    * Parameter    : List<Task>
    **/
    private void preventTaskFieldsUpdateForICPPartner(List<Task> lstNewRecords, Map<Id, Task> mapOldRecords){
        if(UserInfo.getUserType() == Constants.POWERPARTNER){
            Id userId = UserInfo.getUserId();
            Id taskRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                Task.SObjectType, Constants.TASK_RT_API_NAME);
            Map<String, Schema.SObjectField> mapLeadFields = Schema.SObjectType.Task.fields.getMap();
            List<String> lstFieldAPINames = Org_Level_Settings__c.getOrgDefaults().Task_Fields_For_Setup_Plan__c.split(Constants.COMMA);
            Set<String> setFieldAPINames = new Set<String>();
            for(String oFieldAPINames: lstFieldAPINames){
                setFieldAPINames.add(oFieldAPINames);
            }
            for(Task oTask: lstNewRecords){
                String sTaskWhatId = oTask.WhatId;
                if(oTask.RecordTypeId == taskRecTypeId &&
                    UserInfo.getUserType() == Constants.POWERPARTNER && 
                    oTask.createdById != userId && 
                    (oTask.OwnerId ==  userId || 
                    mapoldRecords.get(oTask.id).Ownerid == userId)){
                    for(String sField : mapLeadFields.keyset()){
                        if(setFieldAPINames.contains(sField) && oTask.get(sField) != mapoldRecords.get(oTask.id).get(sField)){
                            oTask.addError(System.Label.TaskHandler_Error_On_Task_For_Portal_Users);
                        }
                    }
                }
            }
        }
    }
    
    /**
    * Method name  : preventTaskDeletionByICPPartner
    * Description  : This method will prevent ICP Partner user from deleting tasks 
                     that are not created by them.
    * Return Type  : void
    * Parameter    : List<Task>
    **/
    private void preventTaskDeletionByICPPartner(List<Task> lstOldRecords){
        Id taskRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Task.SObjectType, Constants.TASK_RT_API_NAME);
        for(Task oTask: lstOldRecords){
            if(oTask.RecordTypeId == taskRecTypeId && 
                UserInfo.getUserType() == Constants.POWERPARTNER && 
                oTask.createdById != UserInfo.getUserId()){
                oTask.addError(System.Label.TaskHandler_Error_On_Task_Delete);
            
            }
        }
    }
   /**
   * Method name  : updateActivityPlan
   * Description  : This method will Update 'Activities Completed Before Due Date'
                     Field on Activity Plan if all the Activities of the Activity 
                     Plan are completed before Due Date.  
   * Return Type  : void
   * Parameter    : List<Task>
   **/
  private void updateActivityPlan(List<Task> lstNewRecords){
  
  Id fwRecTypeId = Utility.getRecordTypeIdByDeveloperName(
      Activity_Plan__c.SObjectType, Constants.SETUP_PLAN_RT_API_NAME);
    String sActivityPlanPrefix = Schema.SObjectType.Activity_Plan__c.getKeyPrefix();
    Set<Id> setFWId = new Set<Id>();
    for(Task oTask: lstNewRecords) {
        String sTaskWhatId = oTask.WhatId;
        if( oTask.WhatId != null && sTaskWhatId.startsWith(sActivityPlanPrefix)){
            setFWId.add(oTask.WhatId);
        }
    }
    List<Task> lstAllTask =  new List<Task>();
    Map<Id, List<Task>> mapActToTsk= new Map<Id, List<Task>>();
    lstAllTask = [select id ,Is_Completion_Date_Less_Than_Due_Date__c ,
                WhatId from task where WhatId in :setFWId ];  
    
    for(Task oTask : lstAllTask){
        if( oTask.WhatId != null ){           
            if(!mapActToTsk.containsKey(oTask.WhatId)){
                
                List<Task> lstTskToMap = new List<Task>();
                
                lstTskToMap.add(oTask);
               
                mapActToTsk.put(oTask.WhatId, lstTskToMap);
            }else{
                
                mapActToTsk.get(oTask.WhatId).add(oTask);
            }
        }
    }
    List<Activity_Plan__c> LstAccplanTrue=  new List<Activity_Plan__c>();
    List<Activity_Plan__c> lstActPlnToUpdate = new List<Activity_Plan__c>();    
    LstAccplanTrue = [Select id ,Activities_Completed_Before_Due_Date__c 
                         from Activity_Plan__c where id in :mapActToTsk.keyset()]; 
     
     For(Activity_Plan__c oActPln: LstAccplanTrue)
      {
      Boolean Flag = false;
      for(Task oTask : mapActToTsk.get(oActPln.Id))
      {                              
         If(oTask.Is_Completion_Date_Less_Than_Due_Date__c  == false)
         {
           Flag = False;
           Break;
         }
         Else
         {
           Flag = True;
         }
      }
     oActPln.Activities_Completed_Before_Due_Date__c = flag;
     lstActPlnToUpdate.add(oActPln) ;
              }

    if(!lstActPlnToUpdate.isempty())
    {
     List<Database.SaveResult> lstUpdateResults =
        Database.Update(lstActPlnToUpdate, false)   ;
         Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
          lstUpdateResults , lstActPlnToUpdate, 'Activity_Plan__c',
          'TaskHandler', 'updateActivityPlan', 'SFDC CI', false);
    }
  }
}