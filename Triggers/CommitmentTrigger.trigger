/******************************************************************************************************
Trigger Name       : CommitmentTrigger
Deascription       : This is single trigger for Commitment which will cover all the trigger events.
                     All the functionality on commitment should be called from this trigger. Methods 
                     to cover all account functionality will be defined in CommitmentHandler class named
                     CommitmentHandler.
Created By         : Rahul Agarwal 
Created On         : 13 Aug, 2015
******************************************************************************************************/
trigger CommitmentTrigger on Commitment__c(before insert, before update, after insert, after update) {
    if (trigger.isInsert && trigger.isBefore) {
        CommitmentHandler.onBeforeInsert(trigger.new);
    }
    if (trigger.isUpdate && trigger.isBefore) {
        CommitmentHandler.onBeforeUpdate(trigger.new);
    }
    if (trigger.isInsert && trigger.isAfter) {
        CommitmentHandler.onAfterInsert(trigger.newMap);
    }
    if (trigger.isUpdate && trigger.isAfter) {
        CommitmentHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
    }
}