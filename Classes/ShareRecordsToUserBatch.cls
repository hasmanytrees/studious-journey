/******************************************************************************************************
Class Name         : ShareRecordsToUserBatch
Deascription       : This batch class will be invoked whenever community user is made Active.
                     This class is used to insert the data in Share objects for the users 
                     who are made Active.
Created By         : Danish Ahmed 
Created On         : 17-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class ShareRecordsToUserBatch implements Database.Batchable<SObject>, Database.Stateful{
    
    Set<Id> setUserId = new Set<Id>();
    
    /**
    * Method name  : ShareRecordsToUserBatch
    * Description  : This is a construtor for this batch class.
    * Return Type  : 
    * Parameter    : Set<Id> 
    **/
    public ShareRecordsToUserBatch(Set<Id> setUserId){
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
        if(setUserId.isEmpty()){
            sQuery = 'Select ProfileId ,Id,AccountId,'+
                'Account.Field_Office__c,Account.Cluster__c,Account.Cluster__r.Territory__c,'+
                'Account.Cluster__r.Territory__r.Field_Office__c,Is_Sharing_Completed__c'+
                ' from User where Is_Sharing_Completed__c = false AND IsActive = true And (Profile.Name =\''+
                Constants.ICP_FULL_ACCESS_PROFILE+'\' OR Profile.Name =\''+
                Constants.ICP_READ_ONLY_PROFILE+'\' OR Profile.Name =\''+
                Constants.ICP_PROGRAM_IMPLEMENTER_PROFILE+'\')';
        }else{
             sQuery = 'Select ProfileId ,Id,AccountId,'+
                'Account.Field_Office__c,Account.Cluster__c,Account.Cluster__r.Territory__c,'+
                'Account.Cluster__r.Territory__r.Field_Office__c,Is_Sharing_Completed__c'+
                ' from User where Id IN: setUserId';
        }
        
        return Database.getQueryLocator(sQuery);
    }
    
    /**
    * Method name  : execute
    * Description  : This method will prepare the list of share object records to be inserted.
    * Return Type  : void
    * Parameter    : Database.BatchableContext, List<sObject>
    **/
    public void execute(Database.BatchableContext oBC, List<sObject> lstScope) {
        Boolean bError = false;
        List<User> lstUser = (List <User>)lstScope;
        List<Account> lstBeneficiaries = new List<Account>();
        List<Household__Share> lstHouseholdShare = new List<Household__Share>();
        Set<Id> setBeneficiariesId = new Set<Id>();
        List<AccountShare> lstAccountShare = new List<AccountShare>();
        if(!lstScope.isEmpty()){
            lstAccountShare.add((AccountShare)Utility.createShareRecord(lstUser[0].AccountId,lstUser[0].Id,Constants.ACCOUNT_OBJ_API_NAME,Constants.EDIT_ACCESS)); // Own ICP Share     
            lstAccountShare.add((AccountShare)Utility.createShareRecord(lstUser[0].Account.Cluster__r.Territory__r.Field_Office__c,lstUser[0].Id,Constants.ACCOUNT_OBJ_API_NAME,Constants.READ_ACCESS)); //Field Office share
            
            lstBeneficiaries = [Select Id,OwnerId, ICP__c,HouseHold__c,Household__r.OwnerId from Account Where ICP__c =: lstUser[0].AccountId];
            if(!lstBeneficiaries.isEmpty()){
                for(Account oAccount: lstBeneficiaries){
                    setBeneficiariesId.add(oAccount.Id);
                    if(oAccount.Ownerid != lstUser[0].Id){
                        lstAccountShare.add((AccountShare)Utility.createShareRecord(oAccount.Id,lstUser[0].Id,Constants.ACCOUNT_OBJ_API_NAME,Constants.EDIT_ACCESS));
                    }
                    if(!String.isEmpty(oAccount.Household__c) && oAccount.Household__r.OwnerId != lstUser[0].Id){ 
                        lstHouseholdShare.add((Household__Share)Utility.createShareRecord(oAccount.Household__c,lstUser[0].Id,Constants.HOUSEHOLD_OBJ_API_NAME,Constants.EDIT_ACCESS)); 
                    }                   
                }
            }
            if(!lstAccountShare.ISEmpty() && bError == false && !Test.isRunningTest()){
                System.enqueueJob(new QueueAccountShare(lstUser[0], lstAccountShare, lstHouseholdShare, setBeneficiariesId, 10000));
            }           
        }
        
    }
    
    /**
    * Method name  : finish
    * Description  : This method will be called after execute method.
    * Return Type  : void
    * Parameter    : Database.BatchableContext
    **/
    public void finish(Database.BatchableContext oBC) {}

}