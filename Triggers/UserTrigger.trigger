/******************************************************************************************************
Class Name         : UserTrigger
Deascription       : This is single trigger for User which will cover all the trigger events.
                     All the functionality on user should be called from this trigger. Methods 
                     to cover all user functionality will be defined in UserHandler class named
                     UserHandler.
Created By         : Danish Ahmed 
Created On         : 27-Apr-2015 
******************************************************************************************************/

trigger UserTrigger on User (after insert,before Update,after update,before Insert) {
    
    
    UserHandler oUserHandler = new UserHandler();
     
    if(Trigger.isBefore && Trigger.isInsert){
        oUserHandler.onBeforeInsert(Trigger.new);
    }
    else if(Trigger.isBefore && Trigger.isUpdate) {
        oUserHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }      
    else if(Trigger.isAfter && Trigger.isInsert){
        oUserHandler.onAfterInsert(Trigger.new, Trigger.oldMap);
    }    
    else if(Trigger.isAfter && Trigger.isUpdate){
        oUserHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    
}