/******************************************************************************************************
Class Name         : HouseholdTrigger
Deascription       : This is single trigger for Household__c which will cover all the trigger events.
                     All the functionality on Household__c should be called from this trigger. Methods 
                     to cover all global data functionality will be defined in class named HouseholdHandler.
Created By         : Himanshu Raichandani 
Created On         : 24-Nov-2014 
******************************************************************************************************/
trigger HouseholdTrigger on Household__c(before insert, after insert, after update) {

    HouseholdHandler handler = new HouseholdHandler();
    if(Trigger.isAfter && Trigger.isUpdate) {
        handler.onAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    else if(Trigger.isBefore && Trigger.isInsert) {
        handler.onBeforeInsert(Trigger.new);
    }
    else if(Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert(Trigger.new, Trigger.oldMap);
    }
}