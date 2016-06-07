/******************************************************************************************************
Class Name         : AccountTrigger
Deascription       : This is single trigger for Account which will cover all the trigger events.
                     All the functionality on account should be called from this trigger. Methods 
                     to cover all account functionality will be defined in AccountHandler class named
                     AccountHandler.
Created By         : Vishal Katyare 
Created On         : 14-Oct-2014 
******************************************************************************************************/

trigger AccountTrigger on Account(before update, after insert, after update,
    before insert) {

    AccountHandler oAccountHandler = new AccountHandler();
    if(Label.Disable_Account_Trigger=='true'){
       //This implies we need not run anything and Trigger should be disabled.
    }
    else if(Trigger.isInsert && Trigger.isAfter) {
        oAccountHandler.onAfterInsert(Trigger.new);
    } else if(Trigger.isUpdate && Trigger.isAfter) {
        if(TriggerContextUtility.bSwitchOnAccountTrigger == true)
        {
            oAccountHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap, Trigger.new);
        }
    } else if(Trigger.isBefore && Trigger.isUpdate) {
        if(TriggerContextUtility.bSwitchOnAccountTrigger == true)
        {
            oAccountHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap, Trigger.new);
        }
    } else if(Trigger.isBefore && Trigger.isInsert) {
        oAccountHandler.onBeforeInsert(Trigger.new);
    }
}