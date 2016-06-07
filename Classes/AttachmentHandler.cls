/******************************************************************************************************
Class Name         : AttachmentHandler
Description        : This is single Class for Attachment which will cover all the Attachment Functionality.
                     All Methods to cover Attachment functionality will be defined in this class. These methods
                     will be called from AttachmentTrigger based on required trigger events.
Created By         : Danish Ahmed
Created On         : 06-Jun-2014 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class AttachmentHandler {

     /**
     * Method name  : onBeforeInsert
     * Description  : This method will be called before any Attachment is inserted
     * Return Type  : void
     * Parameter    : List<Attachment>
     **/
     
     public void onBeforeInsert(List<Attachment> lstNewRecords) {
         checkAttachmentSize(lstNewRecords);
     }
     
     /**
     * Method name  : checkAttachmentSize
     * Description  : This method will not allow attachment of more than 2 mb for case
     * Return Type  : void
     * Parameter    : List<Attachment>
     **/
     private void checkAttachmentSize(List<Attachment> lstNewRecords){
         for(Attachment a: lstNewRecords) {
             if(a.parentId <> null && String.ValueOf(a.parentId).SubString(0,3) == '500' && a.body.size() > 2097152){
                 a.addError(System.Label.Attachment_Size_Limit);
             }
         }
     }
}