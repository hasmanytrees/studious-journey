/******************************************************************************************************
Class Name         : EventHandler
Description        : This is single Class for Event which will cover all the Event Functionality.
                     All Methods to cover Event functionality will be defined in this class. These methods
                     will be called from EventTrigger based on required trigger events.
Created By         : Danish Ahmed 
Created On         : 20-Oct-2015 
******************************************************************************************************/

public class EventHandler {

    /**
    * Method name  : onBeforeDelete
    * Description  : This method will be called before any Task record is deleted
    * Return Type  : void
    * Parameter    : Map<Id,Task>
    **/
    public void onBeforeDelete(List<Event> lstOldRecords) {
        preventEventDeletionByICPPartner(lstOldRecords);
    }
    
    /**
    * Method name  : preventEventDeletionByICPPartner
    * Description  : This method will prevent ICP Partner user from deleting events
                     that are not created by them.
    * Return Type  : void
    * Parameter    : List<Task>
    **/
    private void preventEventDeletionByICPPartner(List<Event> lstOldRecords){
        
        for(Event oEvent: lstOldRecords){
            if(UserInfo.getUserType() == Constants.POWERPARTNER && 
                oEvent.createdById != UserInfo.getUserId()){
                oEvent.addError(System.Label.EventHandler_Error_On_Task_Delete);
            
            }
        }
    }
}