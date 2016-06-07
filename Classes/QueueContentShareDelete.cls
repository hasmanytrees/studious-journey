/******************************************************************************************************
Class Name         : QueueContentShareDelete
Deascription       : This class is used to delete the Content_Share object records when community 
                     user becomes inactive.
Created By         : Danish Ahmed 
Created On         : 18-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class QueueContentShareDelete implements Queueable {
    User oUser;
    List<Content__Share> lstContentShare;
    Integer iNoOfRceordsToShare;
    
    /**
    * Method name  : QueueAccountShare
    * Description  : This is a construtor of this class.
    * Return Type  : 
    * Parameter    : User, List<Content__Share>
    **/
    public QueueContentShareDelete(User oUser, List<Content__Share> lstContentShare, Integer iNoOfRceordsToShare){
        this.oUser = oUser;
        this.lstContentShare = lstContentShare;
        this.iNoOfRceordsToShare = iNoOfRceordsToShare;
    }
    
    /**
    * Method name  : execute
    * Description  : This method is used to delete Content__Share records.
    * Return Type  : void
    * Parameter    : QueueableContext
    **/
    public void execute(QueueableContext context) {
        List<Content__Share> lstContentShareToDelete = new List<Content__Share>();
        List<Content__Share> lstContentShareRemaining = new List<Content__Share>();
        Boolean bError = false;
        if(!lstContentShare.isEmpty()){
            if(lstContentShare.size() > iNoOfRceordsToShare){
                for(Integer i = 0; i < lstContentShare.size(); i++){
                    if(i < iNoOfRceordsToShare){
                        lstContentShareToDelete.add(lstContentShare[i]);
                    }else
                        lstContentShareRemaining.add(lstContentShare[i]);
                }
                bError = Utility.deleteShareRecord(oUser, lstContentShareToDelete, Constants.CONTENT_SHARE_API_NAME);
                if(bError == false && !lstContentShareRemaining.isEmpty()){
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new QueueContentShareDelete(oUser, lstContentShareToDelete, iNoOfRceordsToShare));
                    }
                }           
            }else{
                bError = Utility.deleteShareRecord(oUser, lstContentShare, Constants.CONTENT_SHARE_API_NAME);
            }           
         }
         if(bError == false){
             if(!Test.isRunningTest()){
                 System.enqueueJob(new QueueAPAndAddressShareDelete(oUser));
             }
         }
    }
}