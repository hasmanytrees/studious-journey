/******************************************************************************************************
Class Name         : ActivityPlanHandler 
Description        : This is single Class for Activity Plan which will cover all the Activity Plan 
                     Functionality. All Methods to cover Activity Plan functionality will be 
                     defined in this class. These methods will be called from ActivityPlanTrigger 
                     based on required trigger events.
Created By         : Jeevan Devraj
Created On         : 14-Oct-2014 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

Public class ActivityPlanHandler {

    /**
    * Method name  : onBeforeInsert
    * Description  : This method will be called before any Activity Plan record is inserted
    * Return Type  : void
    * Parameter    : List<Activity_Plan__c>
    **/ 
    public void onBeforeInsert(List<Activity_Plan__c> lstNewRecords) {
        updateCurrentPMATForFacilitationWP(lstNewRecords);
    }
    
    /**
    * Method name  : onAfterInsert
    * Description  : This method will be called after any Activity Plan record is inserted
    * Return Type  : void
    * Parameter    : List<Activity_Plan__c> , Map<ID , Activity_Plan__c>
    **/
    Public void onAfterInsert ( List<Activity_Plan__c> lstNewRecords , Map<ID , Activity_Plan__c> mapNewActivityPlans, Map<ID , Activity_Plan__c> mapOldRecords) {
         createMilestoneTask (lstNewRecords , mapNewActivityPlans  ) ;
         shareActivityPlan( lstNewRecords, mapOldRecords);
     }
     
     /**
    * Method name  : onAfterInsert
    * Description  : This method will be called after any Activity Plan record is inserted
    * Return Type  : void
    * Parameter    : List<Activity_Plan__c> , Map<ID , Activity_Plan__c>
    **/
    Public void onAfterUpdate ( List<Activity_Plan__c> lstNewRecords , Map<ID , Activity_Plan__c> mapOldRecords) {
         shareActivityPlan(lstNewRecords, mapOldRecords);
     }
     
    /**
    * Method name  : createMilestoneTask
    * Description  : This method will be called before any Activity Plan record is inserted
    * Return Type  : void
    * Parameter    : List<Activity_Plan__c>
    **/ 
     public void createMilestoneTask (List<Activity_Plan__c> lstNewRecords , Map<ID , Activity_Plan__c> mapNewActivityPlans ) {
         
          Id setupplanRecId = Utility.getRecordTypeIdByDeveloperName(
            Activity_Plan__c.SObjectType, Constants.SETUP_PLAN_RT_API_NAME
            );
         Set<ID> accIds = new Set<ID> () ;
         List<Task> lstInsertTask = new List<Task> () ; 
         for ( Activity_Plan__c oActivityPlan : lstNewRecords ) {
             if( oActivityPlan.RecordtypeID == setupplanRecId) {
                 accIds.add( oActivityPlan.ICP__c ) ; 
             }    
         }
         
         if(accIds != null && accIds.size() > 0 ){
             Map<ID , Account > mapAcc = new Map<ID , Account > ( [Select ID , Partnership_Facilitator__c , Agreement_Signed_Date__c
                                                                  from Account where ID IN:accIds ] ) ; 
                      
             for ( Activity_Plan__c oActivityPlan : lstNewRecords ) {
                   if( oActivityPlan.RecordtypeID == setupplanRecId) {
                       List<Task> lstNewTask = CreateSetupPlanTask ( oActivityPlan.ID , mapAcc.get( oActivityPlan.ICP__c ).Partnership_Facilitator__c ,
                                               mapAcc.get( oActivityPlan.ICP__c ).Agreement_Signed_Date__c ,mapNewActivityPlans  ) ;
                       if( lstNewTask != NULL ){
                           for( Task oTask : lstNewTask ) { 
                             lstInsertTask.add( oTask ) ;     
                           } 
                       }    
                   }
             }
             if(!lstInsertTask.isEmpty()) {
                List<Database.SaveResult> lstInsertResults =
                    Database.Insert(lstInsertTask, false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstInsertResults , lstInsertTask, 'Activity_Plan__c',
                    'ActivityPlanHandler', 'createMilestoneTask', 'SFDC CI',
                    false);
                    
                 // Error display on Activity records    
                 for(Integer i = 0; i<lstInsertResults .size(); i++) {
                  if(!lstInsertResults .get(i)
                      .isSuccess()) {
                      Activity_Plan__c oActivityPlan = mapNewActivityPlans.get( lstInsertTask.get(i).WhatId ) ; 
                      Database.SaveResult sr = lstInsertResults [i];
                      for(Database.Error error: sr.getErrors()) {                        
                              oActivityPlan.addError(System.Label.Activity_Plan+ 
                                Constants.SPACE_STRING + error.getMessage());
                      }
                  }    
                
                    
            }
         }
     }    
}
    
    /**
     * Method name  : CreateSetupPlanTask
     * Description  : generates seven different milestone tasks for each set up plan
     * Return Type  : List<Task>
     * Parameter    : ID , ID , Date , Map<ID , Activity_Plan__c>
     **/

    Private List<Task> CreateSetupPlanTask(ID recordID, ID pfID, Date dtAgreement,
        Map<ID, Activity_Plan__c> mapNewActivityPlans) {

        List<Task> lstInsertTask = new List<Task>();
        try {
            Map<String, Milestones_Setup_Task__c> mapMileStoneTask =
                Milestones_Setup_Task__c.getAll();

            For(Milestones_Setup_Task__c oMilestoneTask: mapMileStoneTask.values()) {
                Task oTaskRec = new Task();
                oTaskRec.subject = oMilestoneTask.Subject__c;
                oTaskRec.Activity_Type__c = oMilestoneTask.Activity_Type__c;
                oTaskRec.Description = oMilestoneTask.Description1__c + oMilestoneTask.Description2__c;
                oTaskRec.status = oMilestoneTask.Status__c;
                oTaskRec.Priority = oMilestoneTask.Priority__c;
                oTaskRec.ActivityDate = dtAgreement.addDays(Integer.ValueOf(
                    oMilestoneTask.Add_Days_To_Duedate__c));
                oTaskRec.ReminderDateTime = dtAgreement.addDays(Integer.ValueOf(
                    oMilestoneTask.Add_Days_To_Duedate__c) - Integer.ValueOf(
                    oMilestoneTask.Add_Days_To_ReminderDateTime__c) + 1); // 2 and 1

                oTaskRec.WhatId = recordID;
                oTaskRec.IsReminderSet = oMilestoneTask.IsReminderSet__c;
                oTaskRec.OwnerId = pfID;
                lstInsertTask.add(oTaskRec);
            }
        }
        Catch(Exception oQEx) {
            ErrorLogUtility.logGeneralError(oQEx, 'ActivityPlanHandler',
                'CreateSetupPlanTask', 'SFDC CI');
            if(oQEx.getMessage() != null && !String.isEmpty(oQEx.getMessage())) {
                mapNewActivityPlans.get(recordID)
                    .addError(oQEx.getMessage());
            }
            return null;
        }
        return lstInsertTask;

    }
       
    /**
    * Method name  : updateCurrentPMATForFacilitationWP
    * Description  : This method will update Current PMAT with the PMAT URL. Part of R3 Prototype.
    * Return Type  : void
    * Parameter    : List<Activity_PLan__c>
    **/ 
    
    private void updateCurrentPMATForFacilitationWP(List<Activity_PLan__c> lstNewRecords){
        
        Id facilitationWorkplanRecTypeId = Utility.getRecordTypeIdByDeveloperName(Activity_PLan__c.SObjectType,
            Constants.ACTIVITY_PLAN_FW_RT_API_NAME);
        Set<Id> setICPId = new Set<ID>();
        Map<Id,Account> mapICP = new Map<Id,Account>();
        for(Activity_PLan__c oActivityPlan: lstNewRecords){
            if(facilitationWorkplanRecTypeId.equals(oActivityPlan.RecordTypeId) && String.isEmpty(oActivityPlan.Current_PMAT_Assessment__c)){
                setICPId.add(oActivityPlan.ICP__c);
            }        
        }
        if(!setICPId.isEmpty()){
            mapICP = new Map<Id,Account>([Select Id,(
                Select Id From PMAT_Assessments__r order by createddate desc limit 1) From Account 
                where Id IN: setICPId]);
            
            if(!mapICP.isEmpty()){
                for(Activity_PLan__c oActivityPlan: lstNewRecords){
                    if(mapICP.containsKey(oActivityPlan.ICP__c) && !mapICP.get(oActivityPlan.ICP__c).PMAT_Assessments__r.isEmpty()){
                        oActivityPlan.Current_PMAT_Assessment__c = mapICP.get(oActivityPlan.ICP__c).PMAT_Assessments__r[0].Id;
                    }
                }
            }
        }       
    }
    
    /**
    * Method name  : shareActivityPlan
    * Description  : This method will share Activity Plan of type set up plan Records with Partner users.
    * Return Type  : void
    * Parameter    : List<Activity_Plan__c>
    **/
    
    public void  shareActivityPlan(List<Activity_Plan__c> lstNewRecords, Map<Id,Activity_Plan__c> mapOldRecords) {
        
        Id setUpPlanRecTypeId = Utility.getRecordTypeIdByDeveloperName(Activity_Plan__c.SObjectType,
            Constants.SETUP_PLAN_RT_API_NAME);
        Id fwRecTypeId = Utility.getRecordTypeIdByDeveloperName(Activity_Plan__c.SObjectType,
            Constants.ACTIVITY_PLAN_FW_RT_API_NAME);        
        Set<Id> setICPId = new Set<Id>();
        Set<Id> setAPShareToDelete = new Set<Id>();
        List<Activity_Plan__Share> lstAPShare = new List<Activity_Plan__Share>();
        List<Activity_Plan__Share> lstAPShareToDelete = new List<Activity_Plan__Share>();
        map<Id,List<Id>> mapICPIdToUsersLstId = new map<Id,List<Id>>();
        for(Activity_Plan__c oActivityPlan: lstNewRecords){
            if(((setUpPlanRecTypeId.equals(oActivityPlan.RecordTypeId) || fwRecTypeId.equals(oActivityPlan.RecordTypeId)) && !String.isEmpty(oActivityPlan.ICP__c)) && (trigger.isInsert || (trigger.isUpdate && oActivityPlan.ICP__c != mapOldRecords.get(oActivityPlan.Id).ICP__c))){
                setICPId.add(oActivityPlan.ICP__c);
                if(trigger.isUpdate){
                    setAPShareToDelete.add(oActivityPlan.Id);
                }
            }
        }
        if(!setAPShareToDelete.isEmpty()){
            lstAPShareToDelete = [Select Id from Activity_Plan__Share where ParentId IN: setAPShareToDelete and RowCause=: Constants.APEX_BASED_SHARING];
            if(!lstAPShareToDelete.isEmpty()){
                List<Database.DeleteResult> lstDeleteResults = 
                    Database.delete(lstAPShareToDelete,false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstDeleteResults, lstAPShareToDelete, 
                    'Activity_Plan__Share','ActivityPlanHandler', 'shareActivityPlan','SFDC CI',true);
            }
        }
        if(!setICPId.isEmpty()){
            for(User oUser: [Select id,AccountId  from user where AccountId IN: setICPId and IsActive = true]){
                if(mapICPIdToUsersLstId.containsKey(oUser.AccountId)){
                    mapICPIdToUsersLstId.get(oUser.AccountId).add(oUser.Id);
                }   
                else
                    mapICPIdToUsersLstId.put(oUser.AccountId,new List<Id> {oUser.Id});
            }
            for(Activity_Plan__c oActivityPlan: lstNewRecords){
                if(mapICPIdToUsersLstId.containsKey(oActivityPlan.ICP__c)){
                    for(Id userId: mapICPIdToUsersLstId.get(oActivityPlan.ICP__c)){
                        lstAPShare.add((Activity_Plan__Share)Utility.createShareRecord(oActivityPlan.Id,userId,Constants.ACTIVITY_PLAN_OBJ_API_NAME,Constants.READ_ACCESS));
                    }
                    
                }
            }
            If(!lstAPShare.ISEmpty()){
                List<Database.SaveResult> lstInsertResults =
                    Database.Insert(lstAPShare, false);
                Map<Id,List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstInsertResults, lstAPShare,
                    'Activity_Plan__Share',
                    'ActivityPlanHandler', 'shareActivityPlan', 'SFDC CI', false, true
                );
            }
        }            
    }
}