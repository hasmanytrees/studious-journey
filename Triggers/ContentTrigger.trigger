/******************************************************************************************************
Class Name         : ContentTrigger
Deascription       : This is single trigger for Content which will cover all the trigger events.
                     All the functionality on Content should be called from this trigger. Methods 
                     to cover all Content functionality will be defined in ContentHandler class.
Created By         : Danish Ahmed
Created On         : 03-Aug-2015 
******************************************************************************************************/
trigger ContentTrigger on Content__c (after insert, after update) {

    ContentHandler oContentHandler = new ContentHandler();
    if(Trigger.isInsert && Trigger.isAfter) {
        oContentHandler.onAfterInsert(Trigger.new, Trigger.oldMap);
    }else If(Trigger.isUpdate && Trigger.isAfter){
        oContentHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}