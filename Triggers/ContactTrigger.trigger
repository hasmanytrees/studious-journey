/******************************************************************************************************
Class Name         : ContactTrigger
Deascription       : This is single trigger for Contact which will cover all the trigger events.
                     All the functionality on Contact should be called from this trigger. Methods 
                     to cover all global data functionality will be defined in class named ContactHandler.
Created By         : Himanshu Raichandani 
Created On         : 07-Jan-2015 
******************************************************************************************************/

trigger ContactTrigger on Contact(after insert, after update, before delete, before insert, before update) {

    ContactHandler oContactHandler = new ContactHandler();
    if(Trigger.isAfter && Trigger.isInsert) {
        oContactHandler.onAfterInsert(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isUpdate) {
        oContactHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isBefore && Trigger.isDelete) {
        oContactHandler.onBeforeDelete(Trigger.old);
    }
    if(Trigger.isBefore && Trigger.isInsert) {
        oContactHandler.onBeforeInsert(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate) {
        oContactHandler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
    }
}