/******************************************************************************************************
Class Name         : QueueInsertRecordsForBenefShare
Deascription       : This class is used to insert and share records for community users in case of
                     transfer of beneficiary.
Created By         : Danish Ahmed 
Created On         : 24-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class QueueInsertRecordsForBenefShare implements Queueable {
    
    List<AccountShare> lstAccountShare;
    List<Household__Share> lstHouseholdShare;
    List<Content__Share> lstContentShare;
    
    /**
    * Method name  : QueueDeleteRecordsBeforeBenefShare
    * Description  : This is a construtor of this class.
    * Return Type  : 
    * Parameter    : List<AccountShare>, List<Household__Share>, List<Content__Share>
    **/
    public QueueInsertRecordsForBenefShare(List<AccountShare> lstAccountShare, List<Household__Share> lstHouseholdShare, List<Content__Share> lstContentShare){
        this.lstAccountShare = lstAccountShare;
        this.lstHouseholdShare = lstHouseholdShare;
        this.lstContentShare = lstContentShare;
    }
    
    /**
    * Method name  : execute
    * Description  : This method is used to insert various Share object records during transfer.
    * Return Type  : void
    * Parameter    : QueueableContext
    **/
    public void execute(QueueableContext oQueueableContext){
        
        if(!lstAccountShare.isEmpty()){
            List<Database.SaveResult> lstInsertResults =
                Database.Insert(lstAccountShare, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstInsertResults, lstAccountShare,
                'AccountShare',
                 'QueueInsertRecordsForBenefShare', 'execute', 'SFDC CI', false, true
            );
        }
        
        if(!lstHouseholdShare.isEmpty()){
            List<Database.SaveResult> lstInsertResults =
                Database.Insert(lstHouseholdShare, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstInsertResults, lstHouseholdShare,
                'Household__Share',
                 'QueueInsertRecordsForBenefShare', 'execute', 'SFDC CI', false, true
            );
        }
        
        if(!lstContentShare.isEmpty()){
            List<Database.SaveResult> lstInsertResults =
                Database.Insert(lstContentShare, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstInsertResults, lstContentShare,
                'Content__Share',
                 'QueueInsertRecordsForBenefShare', 'execute', 'SFDC CI', false, true
            );
        }
    }
}