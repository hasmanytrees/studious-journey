/******************************************************************************************************
Class Name         : ICPLifeCycleEventTrigger
Deascription       : This is single trigger for ICPLifecycleEvents which will cover all the trigger events.
                     All the functionality on ICPLifecycleEvents should be called from this trigger. Methods 
                     to cover all ICPLifecycleEvents functionality will be defined in ICPLifecycleEvent Handler class named
                     ICPLifecycleEventHandler.
Created By         : Danish Ahmed 
Created On         : 30-Jan-2015
******************************************************************************************************/

trigger ICPLifeCycleEventTrigger on ICP_Lifecycle_Events__c(before insert,
    before update,after update) {

    ICPLifecycleEventHandler oICPLifecycleEventHandler = new ICPLifecycleEventHandler();
    if(trigger.isInsert && trigger.isBefore) {
        oICPLifecycleEventHandler.onBeforeInsert(trigger.new);
    }

    if(trigger.isUpdate && trigger.isBefore) {
        oICPLifecycleEventHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    }
    
    if(trigger.isUpdate && trigger.isAfter) {
        oICPLifecycleEventHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    }
}