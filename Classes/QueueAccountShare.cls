/******************************************************************************************************
Class Name         : QueueAccountShare
Deascription       : This class is used to insert the AccountShare object records when community 
                     user becomes active.
Created By         : Danish Ahmed 
Created On         : 19-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class QueueAccountShare implements Queueable {
    
    User oUser;
    List<AccountShare> lstAccountShare;
    List<Household__Share> lstHouseholdShare;
    Set<Id> setBeneficiariesId;
    Integer iNoOfRceordsToShare;
    
    /**
    * Method name  : QueueAccountShare
    * Description  : This is a construtor of this class.
    * Return Type  : 
    * Parameter    : User, List<AccountShare>, List<Household__Share>, Set<Id>
    **/
    public QueueAccountShare(User oUser, List<AccountShare> lstAccountShare, List<Household__Share> lstHouseholdShare, Set<Id> setBeneficiariesId, Integer iNoOfRceordsToShare){
        this.oUser = oUser;
        this.lstAccountShare = lstAccountShare;
        this.lstHouseholdShare = lstHouseholdShare;
        this.setBeneficiariesId = setBeneficiariesId;
        this.iNoOfRceordsToShare = iNoOfRceordsToShare;
    }
    
    /**
    * Method name  : execute
    * Description  : This method is used to insert AccountShare records.
    * Return Type  : void
    * Parameter    : QueueableContext
    **/
    public void execute(QueueableContext context) {
        List<AccountShare> lstAccShareToInsert = new List<AccountShare>();
        List<AccountShare> lstAccShareRemaining = new List<AccountShare>();
        Boolean bError = false;
        if(!lstAccountShare.isEmpty()){
            if(lstAccountShare.size() > iNoOfRceordsToShare){
                for(Integer i = 0; i < lstAccountShare.size(); i++){
                    if(i < iNoOfRceordsToShare){
                        lstAccShareToInsert.add(lstAccountShare[i]);
                    }else
                        lstAccShareRemaining.add(lstAccountShare[i]);
                }
                bError = Utility.insertShareRecord(oUser, lstAccShareToInsert, Constants.ACCOUNTSHARE_API_NAME);
                if(bError == false && !lstAccShareRemaining.isEmpty()){
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new QueueAccountShare(oUser, lstAccShareRemaining, lstHouseholdShare, setBeneficiariesId, iNoOfRceordsToShare));
                    }
                }           
            }else{
                bError = Utility.insertShareRecord(oUser, lstAccountShare, Constants.ACCOUNTSHARE_API_NAME);
            }
        }
        if(bError == false){
            if(!Test.isRunningTest()){
                System.enqueueJob(new QueueHouseholdShare(oUser, lstHouseholdShare, setBeneficiariesId, 10000));
            }
        }
    }
}