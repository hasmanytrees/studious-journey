/******************************************************************************************************
Class Name         : DisasterTrigger
Deascription       : This is single trigger for Disaster which will cover all the trigger events.
                     All the functionality on Disaster should be called from this trigger. Methods 
                     to cover all Disaster functionality will be defined in Disaster Handler class 
                     named DisasterHandler.
Created By         : Jeevan D 
Created On         : 24-Jun-2014 
******************************************************************************************************/
trigger DisasterTrigger on Disaster__c ( before update , before insert) {
    
    DisasterHandler disasterHandler = new DisasterHandler();
    if( Trigger.Isbefore && Trigger.IsInsert ) {
        disasterHandler.onBeforeInsert(trigger.new);
    }
    else  if( Trigger.Isbefore && Trigger.IsUpdate ) {
        disasterHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
    }    
}