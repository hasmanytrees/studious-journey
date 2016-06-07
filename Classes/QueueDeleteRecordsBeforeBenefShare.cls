/******************************************************************************************************
Class Name         : QueueDeleteRecordsBeforeBenefShare
Deascription       : This class is used to delete and change owner of records for community users in case of
                     transfer of beneficiary.
Created By         : Danish Ahmed 
Created On         : 24-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class QueueDeleteRecordsBeforeBenefShare implements Queueable {

    List<Account> lstNewRecords;
    Map<Id, Account> mapOldRecords;
    Boolean bInsert;
    Set<Id> setICPId;
    Set<Id> setHouseholdIdToDelete;
    Map<Id, Id> mapHouseholdIdToICPId;
    Set<Id> setPreviousICP;
    Set<Id> setBenefIdForDelete;
    
    /**
    * Method name  : QueueDeleteRecordsBeforeBenefShare
    * Description  : This is a construtor of this class.
    * Return Type  : 
    * Parameter    : List<Account>, Map<Id, Account>, Boolean, Set<Id>, Set<Id>, Map<Id, Id>, Set<Id>, Set<Id>
    **/
    public QueueDeleteRecordsBeforeBenefShare(List<Account> lstNewRecords, Map<Id, Account> mapOldRecords, Boolean bInsert, Set<Id> setICPId, Set<Id> setHouseholdIdToDelete, Map<Id, Id> mapHouseholdIdToICPId, Set<Id> setPreviousICP, Set<Id> setBenefIdForDelete){
        this.lstNewRecords = lstNewRecords;
        this.mapOldRecords= mapOldRecords;
        this.bInsert = bInsert;
        this.setICPId = setICPId;
        this.setHouseholdIdToDelete = setHouseholdIdToDelete;
        this.mapHouseholdIdToICPId = mapHouseholdIdToICPId;
        this.setPreviousICP = setPreviousICP;
        this.setBenefIdForDelete = setBenefIdForDelete;
    }
    
    /**
    * Method name  : execute
    * Description  : This method is used to delete various Share object records and change
                     owner of those records which are created by ICP users and getting transfered
                     to another ICP.
    * Return Type  : void
    * Parameter    : QueueableContext
    **/
    public void execute(QueueableContext oQueueableContext) {
        map<Id,List<Id>> mapICPIdToUsersLstId = new map<Id,List<Id>>();
        List<AccountShare> lstAccountShare = new List<AccountShare>();
        List<Household__Share> lstHouseholdShare = new List<Household__Share>();
        Set<Id> setHouseholdToRemove = new Set<Id>();
        List<Content__Share> lstContentToShare = new List<Content__Share>();
        List<Content__c> lstContent = new List<Content__c> ();
        List<sObject> lstOwnersToUpdate = new List<sObject>();
        List<Account> lstBeneficiary = new List<Account>();
        List<User> lstUser = new List<User>();
        User oDefaultUser = new User();
        
        oDefaultUser = [Select Id from User where UserName =: Org_Level_Settings__c.getOrgDefaults().Global_User_For_Transfer__c];
        lstBeneficiary = [Select Id,OwnerId,Owner.profile.UserLicense.Name,ICP__c,Household__c,Household__r.OwnerId,Household__r.Owner.profile.UserLicense.Name from Account Where Id IN: lstNewRecords];
        if(!setHouseholdIdToDelete.isEmpty()){
            if(!lstBeneficiary.isEmpty()){
                for(Account oAccount: lstBeneficiary){
                    if(setHouseholdIdToDelete.contains(oAccount.Household__c) && oAccount.ICP__c == mapHouseholdIdToICPId.get(oAccount.Household__c)){
                        setHouseholdToRemove.add(oAccount.Household__c);
                    }
                }
            }
            if(!setHouseholdToRemove.isEmpty()){
                setHouseholdIdToDelete.removeAll(setHouseholdToRemove);
            }
        }
        if(!setHouseholdIdToDelete.isEmpty()){
            lstUser = [Select Id, AccountId from User Where IsActive = true And AccountId IN: setPreviousICP];
            List<Household__Share> lstHouseholdToDelete = [Select Id from Household__Share where ParentId IN: setHouseholdIdToDelete and UserOrGroupId IN: lstUser and RowCause =: Constants.APEX_BASED_SHARING];
            if(!lstHouseholdToDelete.isEmpty()){
                List<Database.DeleteResult> lstDeleteResults = Database.delete(lstHouseholdToDelete, false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstDeleteResults, lstHouseholdToDelete, 
                    'Household__Share','QueueDeleteRecordsBeforeBenefShare', 'execute', 'SFDC CI', true);
            }
        }
        if (!setBenefIdForDelete.isEmpty()){
            List<AccountShare> lstAccountShareToDelete = new List<AccountShare>();
            
            lstAccountShareToDelete = [Select Id From AccountShare where AccountId IN: setBenefIdForDelete and RowCause =: Constants.MANUAL];
            if(!lstAccountShareToDelete.isEmpty()){
                List<Database.DeleteResult> lstDeleteResults = Database.delete(lstAccountShareToDelete, false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstDeleteResults, lstAccountShareToDelete, 
                    'AccountShare','QueueDeleteRecordsBeforeBenefShare', 'execute', 'SFDC CI', true);
            }
            lstContent = [Select Id,OwnerId, Owner.profile.UserLicense.Name, Beneficiary__r.ICP__c,Beneficiary_Assessment__r.Beneficiary__r.ICP__c,Beneficiary_Lifecycle_Event__r.Beneficiary__r.ICP__c from Content__c where Beneficiary__c IN: setBenefIdForDelete OR Beneficiary_Assessment__r.Beneficiary__c IN: setBenefIdForDelete OR Beneficiary_Lifecycle_Event__r.Beneficiary__c IN: setBenefIdForDelete];
            if(!lstContent.isEmpty()){
                List<Content__Share> lstContentShareToDelete = new List<Content__Share>();
                lstContentShareToDelete = [Select Id From Content__Share where ParentId IN: lstContent and RowCause =: Constants.APEX_BASED_SHARING];                
                if(!lstContentShareToDelete.isEmpty()){
                    List<Database.DeleteResult> lstDeleteResults =
                        Database.delete(lstContentShareToDelete, false);
                        Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                            lstDeleteResults, lstContentShareToDelete, 
                            'Content__Share','QueueDeleteRecordsBeforeBenefShare', 'execute','SFDC CI',true);
                }              
            }
        }
        if(!setICPId.isEmpty()){
            for(User oUser: [Select Id, AccountId from User where IsActive = true And AccountId IN: setICPId]){ 
                if(mapICPIdToUsersLstId.containsKey(oUser.AccountId)){
                    mapICPIdToUsersLstId.get(oUser.AccountId).add(oUser.Id);
                }else
                    mapICPIdToUsersLstId.put(oUser.AccountId,new List<Id>{oUser.Id});
            }
            if(!mapICPIdToUsersLstId.isEmpty()){
                for (Account oAccount: lstBeneficiary){
                    if(mapICPIdToUsersLstId.containsKey(oAccount.ICP__c)){
                        if(bInsert == false && oAccount.ICP__c != mapoldRecords.get(oAccount.Id).ICP__c){
                            if(oAccount.Owner.profile.UserLicense.Name == Constants.PARTNER_COMMUNITY){
                                Account oBeneficiary = new Account();
                                oBeneficiary.Id = oAccount.Id;
                                oBeneficiary.OwnerId=oDefaultUser.Id;
                                lstOwnersToUpdate.add(oBeneficiary);
                            }
                            if(!String.isEmpty(oAccount.Household__c) && setHouseholdIdToDelete.contains(oAccount.Household__c) && oAccount.Household__r.Owner.profile.UserLicense.Name == Constants.PARTNER_COMMUNITY ){
                                Household__c oHousehold = new Household__c();
                                oHousehold.Id = oAccount.Household__c;
                                oHousehold.OwnerId=oDefaultUser.Id;
                                lstOwnersToUpdate.add(oHousehold);
                            }
                        }                                               
                        for(Id userId: mapICPIdToUsersLstId.get(oAccount.ICP__c)){
                            if(oAccount.OwnerId != userId && (bInsert == true || (bInsert == false && oAccount.ICP__c != mapoldRecords.get(oAccount.Id).ICP__c))){                               
                                lstAccountShare.add((AccountShare) Utility.createShareRecord(oAccount.Id,userId, Constants.ACCOUNT_OBJ_API_NAME, Constants.EDIT_ACCESS));
                            }
                            if(!String.isEmpty(oAccount.Household__c) && oAccount.Household__r.OwnerId != userId){
                                lstHouseholdShare.add((Household__Share) Utility.createShareRecord(
                                    oAccount.Household__c, userId, Constants.HOUSEHOLD_OBJ_API_NAME, Constants.EDIT_ACCESS));
                            }                           
                        }                                                            
                    }
                }
                if(!lstContent.isEmpty()){
                    for(Content__c oContent: lstContent){
                        if(oContent.Owner.profile.UserLicense.Name == Constants.PARTNER_COMMUNITY){
                            Content__c oContentToUpdate = new Content__c();
                            oContentToUpdate.Id = oContent.Id;
                            oContentToUpdate.OwnerId=oDefaultUser.Id;
                            lstOwnersToUpdate.add(oContentToUpdate);
                        }
                        if(mapICPIdToUsersLstId.containsKey(oContent.Beneficiary__r.ICP__c)){
                            for(Id userId: mapICPIdToUsersLstId.get(oContent.Beneficiary__r.ICP__c)){
                                lstContentToShare.add((Content__Share)Utility.createShareRecord(oContent.Id, userId, Constants.CONTENT_OBJ_API_NAME, Constants.EDIT_ACCESS));
                            }
                        }
                        else if(mapICPIdToUsersLstId.containsKey(oContent.Beneficiary_Assessment__r.Beneficiary__r.ICP__c)){
                            for(Id userId: mapICPIdToUsersLstId.get(oContent.Beneficiary_Assessment__r.Beneficiary__r.ICP__c)){
                                lstContentToShare.add((Content__Share)Utility.createShareRecord(oContent.Id, userId, Constants.CONTENT_OBJ_API_NAME, Constants.EDIT_ACCESS));
                            }
                        }
                        else if(mapICPIdToUsersLstId.containsKey(oContent.Beneficiary_Lifecycle_Event__r.Beneficiary__r.ICP__c)){
                            for(Id userId: mapICPIdToUsersLstId.get(oContent.Beneficiary_Lifecycle_Event__r.Beneficiary__r.ICP__c)){
                                lstContentToShare.add((Content__Share)Utility.createShareRecord(oContent.Id, userId, Constants.CONTENT_OBJ_API_NAME, Constants.EDIT_ACCESS));
                            }
                        }
                                       
                    }
                }
                
            }
            if(!lstOwnersToUpdate.isEmpty()){
                List<Database.SaveResult> lstUpdateResults =
                    Database.Update(lstOwnersToUpdate, false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, lstOwnersToUpdate,
                    'sObject',
                     'QueueDeleteRecordsBeforeBenefShare', 'execute', 'SFDC CI', false
                );
            }
        }
        if(!Test.IsRunningTest()){
            System.enqueueJob(new QueueInsertRecordsForBenefShare(lstAccountShare, lstHouseholdShare, lstContentToShare));
        }
        
    }

}