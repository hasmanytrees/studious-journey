/******************************************************************************************************
Class Name         : QueueHouseholdShareDelete
Deascription       : This class is used to delete the household share object records when community 
                     user becomes inactive.
Created By         : Danish Ahmed 
Created On         : 18-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class QueueHouseholdShareDelete implements Queueable {
    
    User oUser;
    List<Household__Share> lstHouseholdShare;
    Integer iNoOfRceordsToShare;
    
    /**
    * Method name  : QueueHouseholdShareDelete
    * Description  : This is a construtor of this class.
    * Return Type  : 
    * Parameter    : User, List<Household__Share>
    **/
    public QueueHouseholdShareDelete(User oUser, List<Household__Share> lstHouseholdShare, Integer iNoOfRceordsToShare){
        this.oUser = oUser;
        this.lstHouseholdShare = lstHouseholdShare;
        this.iNoOfRceordsToShare = iNoOfRceordsToShare;
    }
    
    /**
    * Method name  : execute
    * Description  : This method is used to delete Household__Share records and prepare list
                     of Content__Share records. 
    * Return Type  : void
    * Parameter    : QueueableContext
    **/
    public void execute(QueueableContext context) {
        List<Household__Share> lstHouseholdShareToDelete = new List<Household__Share>();
        List<Household__Share> lstHouseholdShareRemaining = new List<Household__Share>();
        Boolean bError = false;
        if(!lstHouseholdShare.isEmpty()){
             if(lstHouseholdShare.size() > iNoOfRceordsToShare){
                for(Integer i = 0; i < lstHouseholdShare.size(); i++){
                    if(i < iNoOfRceordsToShare){
                        lstHouseholdShareToDelete.add(lstHouseholdShare[i]);
                    }else
                        lstHouseholdShareRemaining.add(lstHouseholdShare[i]);
                }
                bError = Utility.deleteShareRecord(oUser, lstHouseholdShareToDelete, Constants.HOUSEHOLD_SHARE_API_NAME);
                if(bError == false && !lstHouseholdShareRemaining.isEmpty()){
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new QueueHouseholdShareDelete(oUser, lstHouseholdShareRemaining, iNoOfRceordsToShare));
                    }
                }           
            }else{
                bError = Utility.deleteShareRecord(oUser, lstHouseholdShare, Constants.HOUSEHOLD_SHARE_API_NAME);
            }           
         }
         if(bError == false){
             List<Content__Share> lstContentShare = new List<Content__Share>();
             lstContentShare = [Select Id from Content__Share where UserOrGroupId =: oUser.Id And RowCause=: Constants.APEX_BASED_SHARING];
             if(!Test.isRunningTest()){
                 System.enqueueJob(new QueueContentShareDelete(oUser, lstContentShare, 10000));
             }
         }
    }
}