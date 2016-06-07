/******************************************************************************************************
Class Name         : QueueContentShare
Deascription       : This class is used to insert the Content__Share object records when community 
                     user becomes active.
Created By         : Danish Ahmed 
Created On         : 19-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class QueueContentShare implements Queueable {
    User oUser;
    List<Content__Share> lstContentShare;
    Integer iNoOfRceordsToShare;
    
    /**
    * Method name  : QueueContentShare
    * Description  : This is a construtor of this class.
    * Return Type  : 
    * Parameter    : User, List<Content__Share>
    **/
    public QueueContentShare(User oUser, List<Content__Share> lstContentShare, Integer iNoOfRceordsToShare){
        this.oUser = oUser;
        this.lstContentShare = lstContentShare;
        this.iNoOfRceordsToShare = iNoOfRceordsToShare;
    }
    
    /**
    * Method name  : execute
    * Description  : This method is used to insert Content__Share records.
    * Return Type  : void
    * Parameter    : QueueableContext
    **/
    public void execute(QueueableContext context) {
        List<Content__Share> lstContentShareToInsert = new List<Content__Share>();
        List<Content__Share> lstContentShareRemaining = new List<Content__Share>();
        Boolean bError = false;
        
        if(!lstContentShare.isEmpty()){
            if(lstContentShare.size() > iNoOfRceordsToShare){
                for(Integer i = 0; i < lstContentShare.size(); i++){
                    if(i < iNoOfRceordsToShare){
                        lstContentShareToInsert.add(lstContentShare[i]);
                    }else
                        lstContentShareRemaining.add(lstContentShare[i]);
                }
                bError = Utility.insertShareRecord(oUser, lstContentShareToInsert, Constants.CONTENT_SHARE_API_NAME);
                if(bError == false && !lstContentShareRemaining.isEmpty()){
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new QueueContentShare(oUser, lstContentShareRemaining, iNoOfRceordsToShare));
                    }
                }           
            }else{
                bError = Utility.insertShareRecord(oUser, lstContentShare, Constants.CONTENT_SHARE_API_NAME);
            }
        }
        if(bError == false){
            if(!Test.isRunningTest()){
                System.enqueueJob(new QueueAPAndAddressShare(oUser));
            }
        }
    }
}