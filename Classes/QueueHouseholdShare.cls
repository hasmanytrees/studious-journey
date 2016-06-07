/******************************************************************************************************
Class Name         : QueueHouseholdShare
Deascription       : This class is used to insert the Household__Share object records when community 
                     user becomes active.
Created By         : Danish Ahmed 
Created On         : 19-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class QueueHouseholdShare implements Queueable {
    
    User oUser;
    List<Household__Share> lstHouseholdShare;
    Set<Id> setBeneficiariesId;
    Integer iNoOfRceordsToShare;
    
    /**
    * Method name  : QueueHouseholdShare
    * Description  : This is a construtor of this class.
    * Return Type  : 
    * Parameter    : User, List<Household__Share>, Set<Id>
    **/
    public QueueHouseholdShare(User oUser, List<Household__Share> lstHouseholdShare,  Set<Id> setBeneficiariesId, Integer iNoOfRceordsToShare){
        this.oUser = oUser;
        this.lstHouseholdShare = lstHouseholdShare;
        this.setBeneficiariesId = setBeneficiariesId;
        this.iNoOfRceordsToShare = iNoOfRceordsToShare;
    }
    
    /**
    * Method name  : execute
    * Description  : This method is used to insert Household__Share records.
    * Return Type  : void
    * Parameter    : QueueableContext
    **/
    public void execute(QueueableContext context) {
        List<Household__Share> lstHouseholdShareToInsert = new List<Household__Share>();
        List<Household__Share> lstHouseholdShareRemaining = new List<Household__Share>();
        Boolean bError = false;
        if(!lstHouseholdShare.isEmpty()){
            if(lstHouseholdShare.size() > iNoOfRceordsToShare){
                for(Integer i = 0; i < lstHouseholdShare.size(); i++){
                    if(i < iNoOfRceordsToShare){
                        lstHouseholdShareToInsert.add(lstHouseholdShare[i]);
                    }else
                        lstHouseholdShareRemaining.add(lstHouseholdShare[i]);
                }
                bError = Utility.insertShareRecord(oUser, lstHouseholdShareToInsert, Constants.HOUSEHOLD_SHARE_API_NAME);
                if(bError == false && !lstHouseholdShareRemaining.isEmpty()){
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new QueueHouseholdShare(oUser, lstHouseholdShareRemaining, setBeneficiariesId, iNoOfRceordsToShare));
                    }
                }           
            }else{
                bError = Utility.insertShareRecord(oUser, lstHouseholdShare, Constants.HOUSEHOLD_SHARE_API_NAME);
            }
        }
        if(bError == false){
            List<Content__Share> lstContentShare = new List<Content__Share>();
            List<Content__c> lstContent = [Select Id,OwnerId, ICP__c, Beneficiary__c From Content__c Where ICP__c =: oUser.AccountId 
                OR Beneficiary__c IN: setBeneficiariesId OR Beneficiary_Assessment__r.Beneficiary__c IN: setBeneficiariesId OR 
                Beneficiary_Lifecycle_Event__r.Beneficiary__c IN: setBeneficiariesId];
            if(!lstContent.isEmpty()){
                for(Content__c oContent: lstContent){ 
                    if(oContent.OwnerId != oUser.Id){
                        lstContentShare.add((Content__Share)Utility.createShareRecord(oContent.Id,oUser.Id,Constants.CONTENT_OBJ_API_NAME,Constants.EDIT_ACCESS)); 
                    }                
                }
            }
            if(!Test.isRunningTest()){
                System.enqueueJob(new QueueContentShare(oUser, lstContentShare, 10000));
            }
        }
    }
}