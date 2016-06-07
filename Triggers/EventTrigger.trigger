/******************************************************************************************************
Class Name         : EventTrigger
Deascription       : This is single trigger for Event which will cover all the trigger events.
                     All the functionality on Event should be called from this trigger. Methods 
                     to cover all Event functionality will be defined in Handler class named
                     EventHandler.
Created By         : Danish Ahmed
Created On         : 20-Oct-2015 
******************************************************************************************************/
trigger EventTrigger on Event (before delete) {

    EventHandler oEventHandler = new EventHandler();
    
    if(trigger.isDelete && trigger.isBefore) {
        oEventHandler.onBeforeDelete(Trigger.old);
    }
}