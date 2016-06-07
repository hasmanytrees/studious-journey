/******************************************************************************************************
Trigger Name       : CommunicationKitTrigger
Description        : This is single trigger for Communication Kit Object which will call CommunicationJitHandler
                     for different functionalities.
Created By         : Rahul Agarwal 
Created On         : 13-Jul-2015
******************************************************************************************************/
trigger CommunicationKitTrigger on Communication_Kit__c(before insert, after insert, before update, after update, after delete) 
{

    CommunicationKitHandler oCommunicationKitHandler = new CommunicationKitHandler();
    if(Trigger.isInsert && Trigger.isBefore){
        oCommunicationKitHandler.onBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter) {
        oCommunicationKitHandler.onAfterInsert(Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        if(TriggerContextUtility.bSwitchOnCommunicationTrigger == true)
        {
            oCommunicationKitHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    else if(Trigger.isUpdate && Trigger.isAfter) {
        if(TriggerContextUtility.bSwitchOnCommunicationTrigger == true)
        {
            oCommunicationKitHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }
    else if(Trigger.isDelete && Trigger.isAfter) {
        oCommunicationKitHandler.onAfterDelete(Trigger.oldMap);
    }
}