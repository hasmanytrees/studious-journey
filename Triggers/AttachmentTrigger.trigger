/******************************************************************************************************
Class Name         : AttachmentTrigger
Deascription       : This trigger is used to take care that the users attach document/images only throgh content object
Created By         : Rahul Agarwal
Created On         : 03-Feb-2015 
******************************************************************************************************/

trigger AttachmentTrigger on Attachment(before insert) {
    
    AttachmentHandler oAttachmentHandler = new AttachmentHandler();
    if(trigger.isBefore && trigger.isInsert){        
        oAttachmentHandler.onBeforeInsert(trigger.new);
    }
    for(Attachment a: trigger.new) {
        if(a.parentId <> null && String.ValueOf(a.parentId).SubString(0,3) <> '500')
            a.AddError(System.Label.Attachment_Not_Allowed);
    }
}