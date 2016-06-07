/******************************************************************************************************
Class Name         : QueueAPAndAddressShareDelete
Deascription       : This class is used to delete the Activity_Plan__Share and Address__Share object 
                     records when community user becomes inactive.
Created By         : Danish Ahmed 
Created On         : 18-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class QueueAPAndAddressShareDelete implements Queueable {
    
    User oUser;
    
    /**
    * Method name  : QueueAPAndAddressShareDelete
    * Description  : This is a construtor of this class.
    * Return Type  : 
    * Parameter    : User
    **/
    public QueueAPAndAddressShareDelete(User oUser){
        this.oUser = oUser;
    }
    
    /**
    * Method name  : execute
    * Description  : This method is used to delete Activity_Plan__Share and Address__Share records.
    * Return Type  : void
    * Parameter    : QueueableContext
    **/
    public void execute(QueueableContext context) {
        List<Activity_Plan__share> lstActivityPlanShareToDelete = new List<Activity_Plan__Share>();
        List<Address__Share> lstAddressShareToDelete = new List<Address__Share>();
        List<Yearly_Class_Schedule__Share> lstYearlyClassShareToDelete = new List<Yearly_Class_Schedule__Share>();
        Boolean bError = false;
        
        lstActivityPlanShareToDelete = [Select Id from Activity_Plan__share where UserOrGroupId =: oUser.Id And RowCause=: Constants.APEX_BASED_SHARING];
        lstAddressShareToDelete = [Select Id from Address__Share where UserOrGroupId =: oUser.Id And RowCause=: Constants.APEX_BASED_SHARING];
        lstYearlyClassShareToDelete = [Select Id from Yearly_Class_Schedule__Share where UserOrGroupId =: oUser.Id And RowCause=: Constants.APEX_BASED_SHARING];
        
        if(!lstActivityPlanShareToDelete.isEmpty()){
            bError = Utility.deleteShareRecord(oUser, lstActivityPlanShareToDelete, Constants.ACTIVITY_PLAN_SHARE_API_NAME);
        }
        
        if(!lstAddressShareToDelete.isEmpty()){
            bError = Utility.deleteShareRecord(oUser, lstAddressShareToDelete, Constants.ADDRESS_SHARE_API_NAME);
        }
        if(!lstYearlyClassShareToDelete.isEmpty()){
            bError = Utility.deleteShareRecord(oUser, lstYearlyClassShareToDelete, Constants.YEARLY_CLASS_SHARE_API_NAME);
        }
        
        if(bError == false){
            oUser.Is_Sharing_Completed__c = false;
            try{
                Update oUser;
            }catch(Exception oEx){
                ErrorLogUtility.logGeneralError(oEx,'QueueAPAndAddressShare','execute','SFDC CI');
            }
        }
    }
}