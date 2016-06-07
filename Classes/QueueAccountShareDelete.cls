/******************************************************************************************************
Class Name         : QueueAccountShareDelete
Deascription       : This class is used to delete the AccountShare object records when community 
                     user becomes inactive.
Created By         : Danish Ahmed 
Created On         : 18-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class QueueAccountShareDelete implements Queueable {

    User oUser;
    List<AccountShare> lstAccountShare;
    Integer iNoOfRceordsToShare;
     
    /**
    * Method name  : QueueAccountShareDelete
    * Description  : This is a construtor of this class.
    * Return Type  : 
    * Parameter    : User, List<AccountShare>, Integer 
    **/
    public QueueAccountShareDelete(User oUser, List<AccountShare> lstAccountShare, Integer iNoOfRceordsToShare){
        this.oUser = oUser;
        this.lstAccountShare = lstAccountShare;
        this.iNoOfRceordsToShare = iNoOfRceordsToShare;
    }
    
    /**
    * Method name  : execute
    * Description  : This method is used to delete AccountShare records and prepare list
                     of Household__Share records. 
    * Return Type  : void
    * Parameter    : QueueableContext
    **/ 
    public void execute(QueueableContext context) {
        List<AccountShare> lstAccShareToDelete = new List<AccountShare>();
        List<AccountShare> lstAccShareRemaining = new List<AccountShare>();
        Boolean bError = false;
        if(!lstAccountShare.isEmpty()){
            if(lstAccountShare.size() > iNoOfRceordsToShare){
                for(Integer i = 0; i < lstAccountShare.size(); i++){
                    if(i < iNoOfRceordsToShare){
                        lstAccShareToDelete.add(lstAccountShare[i]);
                    }else
                        lstAccShareRemaining.add(lstAccountShare[i]);
                }
                bError = Utility.deleteShareRecord(oUser, lstAccShareToDelete, Constants.ACCOUNTSHARE_API_NAME);
                if(bError == false && !lstAccShareRemaining.isEmpty()){
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new QueueAccountShareDelete(oUser, lstAccShareRemaining, iNoOfRceordsToShare));
                    }
                }           
            }else{
                bError = Utility.deleteShareRecord(oUser, lstAccountShare, Constants.ACCOUNTSHARE_API_NAME);
            }
        }
        if(bError == false){
            List<Household__Share> lstHouseholdShare = new List<Household__Share>();
            lstHouseholdShare = [Select Id from Household__Share where UserOrGroupId =: oUser.Id And RowCause =: Constants.APEX_BASED_SHARING];
            if(!Test.isRunningTest()){
                System.enqueueJob(new QueueHouseholdShareDelete(oUser, lstHouseholdShare, 10000));
            }
        }
     }
}