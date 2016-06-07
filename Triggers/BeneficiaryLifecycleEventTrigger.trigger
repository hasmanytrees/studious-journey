/******************************************************************************************************
Class Name         : BeneficiaryLifecycleEventTrigger
Description       : This is single trigger for Beneficiary_Lifecycle_Event__c which will cover all the trigger events.
                     All the functionality on Beneficiary_Lifecycle_Event__c should be called from this trigger. Methods 
                     to cover all Beneficiary Lifecycle Event functionality will be defined in class named
                     BeneficiaryLifecycleEventHandler.
Created By         : Himanshu Raichandani 
Created On         : 18-Nov-2014 
******************************************************************************************************/
trigger BeneficiaryLifecycleEventTrigger on Beneficiary_Lifecycle_Event__c(
    after update, before update, before insert) {

    BeneficiaryLifecycleEventHandler handler = new BeneficiaryLifecycleEventHandler();
    
    if(Label.Disable_For_Data_Load.equalsIgnoreCase('true')){
       //This implies we need not run anything and Trigger should be disabled.
    }else if(Trigger.isAfter && Trigger.isUpdate) {
        handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    } else if(Trigger.isBefore && Trigger.isUpdate) {
        handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    } else if(Trigger.isBefore && Trigger.isInsert) {
        handler.onBeforeInsert(Trigger.new);
    }
}