/******************************************************************************************************
Class Name         : HouseholdMemberTrigger
Deascription       : This is single trigger for Household_Member__c which will cover all the trigger events.
                     All the functionality on Household_Member__c should be called from this trigger. Methods 
                     to cover all global data functionality will be defined in class named HouseholdMemberHandler.
Created By         : Himanshu Raichandani 
Created On         : 24-Nov-2014 
******************************************************************************************************/
trigger HouseholdMemberTrigger on Household_Member__c(before insert, before update,
    after update , after insert) {

    HouseholdMemberHandler handler = new HouseholdMemberHandler();
    if(Trigger.isBefore && Trigger.isInsert) {
        handler.onBeforeInsert(Trigger.new);
    } else if(Trigger.isBefore && Trigger.isUpdate) {
        handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }else if(Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert(Trigger.new);
    }else if(Trigger.isAfter && Trigger.isUpdate) {
        handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}