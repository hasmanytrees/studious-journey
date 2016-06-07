/******************************************************************************************************
Class Name         : CommunicationUpdatesTrigger
Description        : This is single trigger for Communication Updates which will cover all the trigger events.
                     All the functionality on Communication Updates should be called from this trigger. Methods 
                     to cover all account functionality will be defined in Communication Updates Handler class named
                     CommunicationUpdatesHandler.
Created By         : Sudipta Nayak
Created On         : 15-Jul-2015
******************************************************************************************************/

trigger CommunicationUpdatesTrigger on Communication_Update__c (before insert) {
    
    CommunicationUpdatesHandler oCommUpdateHandler = new CommunicationUpdatesHandler();
    if(Trigger.isBefore && Trigger.isInsert) {
        oCommUpdateHandler.onBeforeInsert(Trigger.new);
    }
}