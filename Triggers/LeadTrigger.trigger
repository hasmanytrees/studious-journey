/******************************************************************************************************
Class Name         : LeadTrigger
Deascription       : This is single trigger for Lead which will cover all the trigger events.
                     All the functionality on Lead should be called from this trigger. Methods 
                     to cover all Lead functionality will be defined in LeadHandler class named
                     LeadHandler.
Created By         : Shaik Manzoor
Created On         : 08-Oct-2014 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
trigger LeadTrigger on Lead(after update, before update, before insert, before delete) {

    if(trigger.isInsert && trigger.isBefore) {

        for(Lead l: trigger.new) {
            if(l.Partnership_Facilitator__c<> null)
                l.OwnerId = l.Partnership_Facilitator__c;
        }
    }

    LeadHandler handler = new LeadHandler();
    if(Trigger.isUpdate && Trigger.isAfter) {
        //handler.onAfterUpdate(Trigger.oldmap, Trigger.new);
        LeadHandler.ICPFieldsOnLeadConvert(trigger.new);
    } else if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
        handler.onBeforeInsertOrUpdate(Trigger.oldmap, Trigger.new);
        //LeadHandler.ICPFieldsOnLeadConvert(trigger.new);
    }
   /**
    if(Trigger.isBefore && Trigger.isDelete) {
        handler.onBeforeDelete(Trigger.old);
    }
    **/

}