/******************************************************************************************************
Class Name         : QueueAPAndAddressShare
Deascription       : This class is used to insert the Activity_Plan__Share and Address__Share object 
                     records when community user becomes active.
Created By         : Danish Ahmed 
Created On         : 19-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class QueueAPAndAddressShare implements Queueable {

    User oUser;
    
    /**
    * Method name  : QueueAPAndAddressShare
    * Description  : This is a construtor of this class.
    * Return Type  : 
    * Parameter    : User
    **/
    public QueueAPAndAddressShare(User oUser){
        this.oUser = oUser;
    }
    
    /**
    * Method name  : execute
    * Description  : This method is used to insert Activity_Plan__Share and Address__Share records.
    * Return Type  : void
    * Parameter    : QueueableContext
    **/
    public void execute(QueueableContext context) {       
        Boolean bError = false;
        List<Activity_Plan__Share> lstActivityPlanShare = new List<Activity_Plan__Share>();
        List<Address__Share> lstAddressShare = new List<Address__Share>();
        List<Yearly_Class_Schedule__Share> lstYearlyClassShare = new List<Yearly_Class_Schedule__Share>();
        List<Activity_Plan__c> lstActivityPlan = [Select Id, OwnerId, ICP__c from Activity_Plan__c  Where ICP__c =: oUser.AccountId And OwnerId !=: oUser.Id];
        if(!lstActivityPlan.isEmpty()){
            for(Activity_Plan__c oActivityPlan: lstActivityPlan){
               lstActivityPlanShare.add((Activity_Plan__Share)Utility.createShareRecord(oActivityPlan.Id,oUser.Id,Constants.ACTIVITY_PLAN_OBJ_API_NAME,Constants.READ_ACCESS));
                           
            }
        }
        
        List<Address__c> lstAddress = [Select Id,Account__c from Address__c  Where Account__c =: oUser.AccountId And OwnerId !=: oUser.Id];
        if(!lstAddress.isEmpty()){
            for(Address__c oAddress: lstAddress){
                lstAddressShare.add((Address__Share)Utility.createShareRecord(oAddress.Id,oUser.Id,Constants.ADDRESS_OBJ_API_NAME,Constants.READ_ACCESS));                                            
            }
        }
        
        List<Yearly_Class_Schedule__c> lstYearlyClass = [Select id,ICP_Name__c from Yearly_Class_Schedule__c where ICP_Name__c =: oUser.AccountId And OwnerId !=: oUser.Id];
        if(!lstYearlyClass.isEmpty()){
            for(Yearly_Class_Schedule__c oYearlyClass: lstYearlyClass){
                lstYearlyClassShare.add((Yearly_Class_Schedule__Share)Utility.createShareRecord(oYearlyClass.Id,oUser.Id,Constants.YEALY_CLASS_OBJ_API_NAME,Constants.EDIT_ACCESS));
            }
        }
        if(!lstActivityPlanShare.ISEmpty()){
            bError = Utility.insertShareRecord(oUser, lstActivityPlanShare, Constants.ACTIVITY_PLAN_SHARE_API_NAME);
        }
        
        if(!lstAddressShare.ISEmpty() && bError == false){
            bError = Utility.insertShareRecord(oUser, lstAddressShare, Constants.ADDRESS_SHARE_API_NAME);
        }
        
        if(!lstYearlyClassShare.isEmpty() && bError == false){
            bError = Utility.insertShareRecord(oUser, lstYearlyClassShare, Constants.YEARLY_CLASS_SHARE_API_NAME);
        }
        
        if(bError == false){
            oUser.Is_Sharing_Completed__c = true;
            try{
                Update oUser;
            }catch(Exception oEx){
                ErrorLogUtility.logGeneralError(oEx,'QueueAPAndAddressShare','execute','SFDC CI');
            }
        }
    }
}