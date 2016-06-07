/******************************************************************************************************
Class Name         : BatchDeleteShareRecordsToUserClass
Deascription       : This batch class will be invoked whenever community user is made inactive.
                     This class is used to delete the data from the Share object for the users 
                     who are made inactive.
Created By         : Danish Ahmed 
Created On         : 18-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class BatchDeleteShareRecordsToUserClass implements Database.Batchable<SObject>, Database.Stateful{
    
    Set<Id> setUserId = new Set<Id>();
        
    /**
    * Method name  : DeleteShareRecordsToUserBatch
    * Description  : This is a construtor for this batch class.
    * Return Type  : 
    * Parameter    : Set<Id> 
    **/
    public BatchDeleteShareRecordsToUserClass(Set<Id> setUserId){
        this.setUserId = setUserId;
    }
    
    /**
    * Method name  : start
    * Description  : This method will query the user to prepare data for execute
    * Return Type  : Database.Querylocator
    * Parameter    : Database.BatchableContext
    **/
    public Database.Querylocator start(Database.BatchableContext oBC) {
        String sQuery = '';
        try{
            if(setUserId.isEmpty()){
                sQuery = 'Select ProfileId ,Id,AccountId,'+
                    'Account.Field_Office__c,Account.Cluster__c,Account.Cluster__r.Territory__c,'+
                    'Account.Cluster__r.Territory__r.Field_Office__c,Is_Sharing_Completed__c'+
                    ' from User where IsActive = false And (Profile.Name =\''+
                    Constants.ICP_FULL_ACCESS_PROFILE+'\' OR Profile.Name =\''+
                    Constants.ICP_READ_ONLY_PROFILE+'\' OR Profile.Name =\''+
                    Constants.ICP_PROGRAM_IMPLEMENTER_PROFILE+'\')';
            }else{
                sQuery = 'Select ProfileId ,Id,AccountId,'+
                    'Account.Field_Office__c,Account.Cluster__c,Account.Cluster__r.Territory__c,'+
                    'Account.Cluster__r.Territory__r.Field_Office__c,Is_Sharing_Completed__c'+
                    ' from User where Id IN: setUserId';
            }
        }
        catch(Exception oEx){
            ErrorLogUtility.logGeneralError(oEx, 'BatchDeleteShareRecordsToUserClass',
            'start', 'SFDC CI');
         }
        
        return Database.getQueryLocator(sQuery);
    }
    
    /**
    * Method name  : execute
    * Description  : This method will prepare the list of share object records to be deleted.
    * Return Type  : void
    * Parameter    : Database.BatchableContext, List<sObject>
    **/    
    public void execute(Database.BatchableContext oBC, List<sObject> lstScope) {
        List<User> lstUser = (List <User>)lstScope;
        List<AccountShare> lstAccountShare = new List<AccountShare>();
        lstAccountShare = [Select Id from AccountShare where UserOrGroupId =: lstUser[0].Id And RowCause=: Constants.Manual];
        If(!Test.isRunningTest()){
            System.enqueueJob(new QueueAccountShareDelete(lstUser[0], lstAccountShare, 10000));
        }
        
    }
    
    /**
    * Method name  : finish
    * Description  : This method will be called after execute method.
    * Return Type  : void
    * Parameter    : Database.BatchableContext
    **/
    public void finish(Database.BatchableContext oBC) {
    
    }
}