/******************************************************************************************************
Class Name         : ActivityPlanTrigger
Deascription       : This is single trigger for ActivityPlan which will cover all the trigger events.
                     All the functionality on ActivityPlan should be called from this trigger. Methods 
                     to cover all ActivityPlan functionality will be defined in ActivityPlan Handler class 
                     named ActivityPlanHandler.
Created By         : Jeevan D 
Created On         : 11-Jun-2014 
******************************************************************************************************/

trigger ActivityPlanTrigger on Activity_Plan__c (before insert, after insert, before update, after update) {
    
    ActivityPlanHandler oActivityPlanHandler = new ActivityPlanHandler () ;
    if(Trigger.isInsert && Trigger.isBefore){
        oActivityPlanHandler.onBeforeInsert(Trigger.new);
    } 
    if( Trigger.isInsert && Trigger.isAfter ) {
        oActivityPlanHandler.onAfterInsert(Trigger.New, Trigger.NewMap, trigger.oldMap) ;     
    }
    if( Trigger.isUpdate && Trigger.isAfter ) {
        oActivityPlanHandler.onAfterUpdate(Trigger.New,trigger.oldMap) ;     
    }
}