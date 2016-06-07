/******************************************************************************************************
Class Name         : HouseholdHandler
Deascription       : This is single Class for Household__c which will cover all it's trigger functionality.
These methods will be called from HouseholdTrigger based on required trigger events.
Created By         : Nayana Prabhakar 
Created On         : 26-02-2014 
******************************************************************************************************/
public class HouseholdHandler {
    /**
     * Method name  : onAfterUpdate
     * Description  : This method will be called after any Household record is updated
     * Return Type  : void
     * Parameter    : List<Household__c>, Map<Id, Household__c>, Map<Id, Household__c>
     **/
    public void onAfterUpdate(List<Household__c> lstNewRecords, Map<Id,
        Household__c> mapOldRecords, Map<Id, Household__c> mapNewRecords) {
        updateRelatedBeneficiary(lstNewRecords, mapOldRecords, mapNewRecords);
        updateIsOrphanOnAccount(lstNewRecords);
    }
    
    /**
     * Method name  : onBeforeInsert
     * Description  : This method will be called before any Household record is inserted
     * Return Type  : void
     * Parameter    : List<Household__c>
     **/
    public void onBeforeInsert(List<Household__c> lstNewRecords) {
        updateFieldOfficeForSharingRule(lstNewRecords);
        shareHouseholdWithInternalUsers(lstNewRecords);
        updateIsOrphanOnAccount(lstNewRecords);
    }
    
    /**
     * Method name  : onAfterInsert
     * Description  : This method will be called after any Household record is inserted
     * Return Type  : void
     * Parameter    : List<Household__c>
     **/
    public void onAfterInsert(List<Household__c> lstNewRecords, Map<Id, Household__c> mapOldRecords) {
        shareHHWithPartnerUsers(lstNewRecords);
    }

    /**
    * Method name  : updateRelatedBeneficiary
    * Description  : This method updates HouseholdUpdateDate backend field of Account which are 
                     associated to this Household. 
    * Return Type  : void
    * Parameter    : List<Household__c>
    **/
    private void updateRelatedBeneficiary(List<Household__c> lstNewRecords, Map <
        Id, Household__c> mapOldRecords, Map<Id, Household__c> mapNewRecords) {
        List<Id> lstHouseHoldIds = new List<Id>();

        for(Household__c oHousehold: lstNewRecords) {
            if((oHousehold.Natural_Father_IsAlive__c<> null && !oHousehold.Natural_Father_IsAlive__c
                    .equals(mapOldRecords.get(oHousehold.Id)
                        .Natural_Father_IsAlive__c)) || (oHousehold.Natural_Mother_IsAlive__c <> null 
                        && !oHousehold.Natural_Mother_IsAlive__c.equals(mapOldRecords.get(
                            oHousehold.Id)
                        .Natural_Mother_IsAlive__c)) || (oHousehold.Marital_Status__c<> null &&
                    !oHousehold.Marital_Status__c.equals(mapOldRecords.get(oHousehold.Id)
                        .Marital_Status__c))) {
                lstHouseHoldIds.add(oHousehold.Id);
            }
        }

        if(!lstHouseHoldIds.isEmpty()) {
            List<Account> lstBenef = new List<Account>();
            try {
                lstBenef = [Select Id, Household__c, Household_Update_Mail_Text__c,
                    LastName, RecordType.DeveloperName from Account where Household__c IN:lstHouseHoldIds 
                    AND(RecordType.DeveloperName = :Constants.CDSP_BENEFICIARY_RT_API_NAME OR 
                    RecordType.DeveloperName=:Constants.CSP_BENEFICIARY_RT_API_NAME) AND
                    Beneficiary_Status__c = : Constants.ACTIVE
                ];
            } catch(System.QueryException oQe) {
                ErrorLogUtility.logGeneralError(oQe, 'HouseholdHandler',
                    'fetchRelatedBeneficiary', 'SFDC CI');
                return;
            }
            if(!lstBenef.isEmpty()) {
                Household__c oHousehold = null;
                for(Account oBeneficiary: lstBenef) {
                    oHousehold = mapNewRecords.get(oBeneficiary.Household__c);
                    oBeneficiary.Household_Update_Mail_Text__c = Label.Update_Household_Mail_Body_1 +
                        oHousehold.Name + Label.Update_Household_Mail_Body_2 + oHousehold.Natural_Father_IsAlive__c +
                        Label.Update_Household_Mail_Body_3 + oHousehold.Natural_Mother_IsAlive__c +
                        Label.Update_Household_Mail_Body_4 + oHousehold.Marital_Status__c +
                        Label.Update_Household_Mail_Body_5 + System.URL.getSalesforceBaseUrl()
                                .getHost()+ Constants.BACKSLASH +oBeneficiary.Household__c;
                }
                List<Database.SaveResult> lstUpdateResults =
                    Database.update(lstBenef, false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, lstBenef, 'Account',
                    'HouseholdHandler', 'updateRelatedBeneficiary', 'SFDC CI', false);
            }
        }
    }
    
    /**
    * Method name  : updateFieldOfficeForSharingRule
    * Description  : This method updates FO for Sharing Rule backend field of Household which determines
                     the security settings of the record.
    * Return Type  : void
    * Parameter    : List<Household__c>
    **/
    private void updateFieldOfficeForSharingRule(List<Household__c> lstNewRecords) {
        Id currentUserId = UserInfo.getUserId();
        User currentUserInfo = [SELECT id, Field_Office__c from User where id =: currentUserId];
        for(Household__c household: lstNewRecords) {
            household.Field_Office_For_Sharing_Rule__c = currentUserInfo.Field_Office__c; 
        }
    }
    
    /**
    * Method name  : shareHouseholdWithInternalUsers
    * Description  : This method updates Field Office for Sharing rules 
                     when Household is created by Partner Users.
    * Return Type  : void
    * Parameter    : List<Household__c>
    **/
    private void shareHouseholdWithInternalUsers(List<Household__c> lstNewRecords){   
        Set<Id> setICPUserId = new Set<Id>();
        for(Household__c oHousehold: lstNewRecords){
            if(UserInfo.getUserType() == Constants.POWERPARTNER){
                setICPUserId.add(oHousehold.OwnerId);
            }
        }
        if(!setICPUserId.isEmpty()){
            Map<Id, User> mapIdToUser = new Map<Id, user>([Select id, AccountId, Account.Field_Office__c from User where Id IN: setICPUserId]);
            If(!mapIdToUser.isEmpty()){
                for(Household__c oHousehold: lstNewRecords){
                    if(mapIdToUser.containsKey(oHousehold.OwnerId)){
                        oHousehold.Field_Office_For_Sharing_Rule__c = mapIdToUser.get(oHousehold.OwnerId).Account.Field_Office__c;
                    }
                }
            }
        }
    }
    
    /**
    * Method name  : shareHHWithPartnerUsers
    * Description  : This method share Household records with other ICP users.
    * Return Type  : void
    * Parameter    : List<Household__c>
    **/
    private void shareHHWithPartnerUsers(List<Household__c> lstNewRecords){ 
        Set<Id> setHouseholdId = new Set<Id>();
        Set<Id> setOwnerId = new Set<Id>();
        Set<Id> setICPId = new Set<Id>();
        Map<Id, Id> mapHouseholdIdToOwnerId = new Map<Id, Id>();
        List<User> lstUser = new List<User>();
        List<Household__Share> lstHouseholdShare = new List<Household__Share>();
        for(Household__c oHousehold: lstNewRecords){
            if(UserInfo.getUserType() == Constants.POWERPARTNER){
                setHouseholdId.add(oHousehold.Id);
                setOwnerId.add(oHousehold.OwnerId);
                mapHouseholdIdToOwnerId.put(oHousehold.Id, oHousehold.OwnerId);               
            }       
        }
        if(!setOwnerId.isEmpty()){
            for(User oUser: [Select Id, AccountId from User where Id IN: setOwnerId]){
                setICPId.add(oUser.AccountId);   
            }
            if(!setICPId.isEmpty()){
                lstUser = [Select Id, AccountId from User where isActive = true And AccountId IN: setICPId];
            }
            for(Id householdId: setHouseholdId){
                for(User oUser: lstUser){
                    if(mapHouseholdIdToOwnerId.containsKey(householdId) && mapHouseholdIdToOwnerId.get(householdId) != oUser.Id){
                        lstHouseholdShare.add((Household__Share)Utility.createShareRecord(householdId,oUser.Id,Constants.HOUSEHOLD_OBJ_API_NAME,Constants.EDIT_ACCESS));
                    }
                }
            }
            if(!lstHouseholdShare.isEmpty()){
                List<Database.SaveResult> lstInsertResults =
                    Database.Insert(lstHouseholdShare, false);
                Map<Id,List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstInsertResults, lstHouseholdShare,
                    'Household__Share',
                    'HouseholdHandler', 'shareHHWithPartnerUsers', 'SFDC CI', false, true
                );
            }
        }
    }
    
     /**
     * Method name  : updateIsOrphanOnAccount
     * Description  : This method updates Is Orphan checkbox on Account, if parents of the beneficiary are not alive.
     * Return Type  : void
     * Parameter    : List<Household__c>
     **/
     private void updateIsOrphanOnAccount(List<Household__c> lstNewRecords){
        Map<ID,List<Account>> mapIDAccount = new Map<ID, List<Account>>();
        List<Account> lstAccounts = new List<Account>();
        try{
            for(Household__c oHousehold: [SELECT id,(SELECT id,Is_Orphan__c FROM Household__r) 
                FROM Household__c WHERE id in : lstNewRecords]){            
                mapIDAccount.put(oHousehold.id,oHousehold.Household__r);
            }
            for(Household__c oHousehold: lstNewRecords){                
                if(mapIDAccount.containskey(oHousehold.id)){
                    for(Account oAccount : mapIDAccount.get(oHousehold.id)){
                        if(oHousehold.Natural_Father_IsAlive__c == Constants.NO && 
                           oHousehold.Natural_Mother_IsAlive__c == Constants.NO){
                            oAccount.Is_Orphan__c = True;
                            lstAccounts.add(oAccount);
                        }
                        else{
                            oAccount.Is_Orphan__c = False;
                            lstAccounts.add(oAccount);
                        }
                    }                  
                }
            }
            if(!lstAccounts.isEmpty())
                update lstAccounts;
        }catch (Exception e) {
            ErrorLogUtility.logGeneralError(e, 'HouseholdHandler',
                'updateIsOrphanOnAccount', 'SFDC CI');
        }
    }
    
}