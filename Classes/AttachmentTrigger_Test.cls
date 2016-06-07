/******************************************************************************************************
Class Name         : AttachmentTrigger_Test
Description        : This class contains unit tests for validating the behavior of Apex trigger: AttachmentTrigger
Created By         : Nayana Prabhakar
Created On         : 24-March-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@isTest(SeeAllData=false) 
private class AttachmentTrigger_Test {
    static testMethod void positiveTest() {
        Test.StartTest();
        try{
            Contact oContact = new Contact(FirstName = 'FirstName', LastName = 'LastName');
            insert oCOntact;
            Attachment oAtt = new Attachment(Name = 'Name', Body = Blob.ValueOf(''), ParentId = oContact.Id);
            insert oAtt;
        }
        catch(DMLException oDMLExp){
            System.assert(oDMLExp.getMessage().contains('You are not allowed to upload the attachment here. Please use Content to upload any attachments'), 'message=' + oDMLExp.getMessage());
        }
        Case oCase = new Case();
        insert oCase;
        Attachment oAtt = new Attachment(Name = 'Name', Body = Blob.ValueOf(''), ParentId = oCase.Id);
        insert oAtt;
        Test.StopTest();
        
    }
}