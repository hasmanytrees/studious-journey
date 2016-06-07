/******************************************************************************************************
Class Name         : TaskTrigger
Deascription       : This is single trigger for Task which will cover all the trigger events.
                     All the functionality on Task should be called from this trigger. Methods 
                     to cover all account functionality will be defined in Handler class named
                     TaskHandler.
Created By         : Himanshu Raichandani 
Created On         : 13-Jan-2015 
******************************************************************************************************/

trigger TaskTrigger on Task(before insert, before update, after insert, after update, before delete) {


    TaskHandler handler = new TaskHandler();

    if(trigger.isInsert && trigger.isBefore) {
        handler.onBeforeInsert(trigger.new);
    }

    if(trigger.isUpdate && trigger.isBefore) {
        handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    
    if(trigger.isDelete && trigger.isBefore) {
        handler.onBeforeDelete(Trigger.old);
    }
    if(trigger.isInsert && trigger.isAfter) {
        handler.onAfterInsert(trigger.new);
    }
       if(trigger.isUpdate && trigger.isAfter) {
        handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}