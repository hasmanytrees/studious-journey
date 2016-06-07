/******************************************************************************************************
Class Name         : ContactHandler
Description        : This is single Class for Contact which will cover all it's trigger functionality.
                     These methods will be called from ContactTrigger based on required trigger events.
Created By         : Himanshu Raichandani 
Created On         : 07-Jan-2015 
******************************************************************************************************/

public class ContactHandler {

    /**********************************
    Method Name : onBeforeInsert
    Description : This method is called after any Contact record is inserted.
    Return type : void
    Parameter   : List<Contact> 
    ************************************/
    public void onBeforeInsert(List<Contact> lstNewRecords) {
        errorMaximumCountReached(lstNewRecords,null);   
    }
    
    /**********************************
    Method Name : onBeforeUpdate
    Description : This method is called after any Contact record is inserted.
    Return type : void
    Parameter   : List<Contact> 
    ************************************/
    public void onBeforeUpdate(List<Contact> lstNewRecords,Map<Id, Contact> mapOldRecords) {
        errorMaximumCountReached(lstNewRecords,mapOldRecords);
    }
    
    /**********************************
    Method Name : onAfterInsert
    Description : This method is called after any Contact record is inserted.
    Return type : void
    Parameter   : List<Contact> 
    ************************************/
    public void onAfterInsert(List<Contact> lstNewRecords) {
        updateGlobalPartner(lstNewRecords);
        updateActiveConnectUserCount(lstNewRecords,null);
    }
    
    /**********************************
    Method Name : onAfterUpdate
    Description : This method is called after any Contact record is updated.
    Return type : void
    Parameter   : List<Contact> , Map<Id, Contact>
    ************************************/
    public void onAfterUpdate(List<Contact> lstNewRecords, Map<Id, Contact> mapOldRecords) {
        updateActiveConnectUserCount(lstNewRecords,mapOldRecords);
        inactivateUsers(lstNewRecords,mapOldRecords);
    }
    
    /**********************************
    Method Name : onBeforeDelete
    Description : This method is called before any Contact record is deleted.
    Return type : void
    Parameter   : List<Contact> 
    ************************************/
    public void onBeforeDelete(List<Contact> lstOldRecords) {
        restrictActiveContactDeletion(lstOldRecords);
    }

    /**********************************
    Method Name : updateGlobalPartner
    Description : This method updates Account with the association as soon as GLobal Partner Contact is inserted.
    Return type : void
    Parameter   : List<Contact> 
    ************************************/
    private void updateGlobalPartner(List<Contact> lstNewRecords) {
        set<Id> setNewContactIds = new set<Id>();

        Id globalPartnerRecTypeId = Utility.getRecordTypeIdByDeveloperName(Contact.SObjectType,
            Constants.CONTACT_GLOB_PART_RT_API_NAME);
        Id globalPartnerAccRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Account.SObjectType, Constants.GLOBAL_PARTNER_RT_API_NAME);
        Set<Id> setGPsIds = new Set<Id>();
        List<Account> lstAccntToUpdate = new List<Account>();
        Map<Id, Contact> mapAccIdToConObj = new Map <
            Id, Contact>();

        for(Contact oContact: lstNewRecords) {
            if(oContact.RecordTypeId.equals(globalPartnerRecTypeId)) {
                setGPsIds.add(oContact.AccountId);
            }
        }

        if(!setGPsIds.isEmpty()) {
            Map<Id, Account> mapIdToAccount = null;
                mapIdToAccount = new Map<Id, Account> ([Select Id,
                    RecordTypeId, IsPartner from Account where RecordTypeId = :
                    globalPartnerAccRecTypeId AND Id in : setGPsIds
                ]);
            Set<Id> setAccntId = new Set<Id>();
            if(!mapIdToAccount.isEmpty()) {
                for(Contact oContact: lstNewRecords) {
                    if(mapIdToAccount.containsKey(oContact.AccountId)) {
                        Account oAcc = new Account();
                        oAcc.id = oContact.AccountId;
                        oAcc.IsPartner = true;
                        if(!setAccntId.contains(oAcc.id)){
                            lstAccntToUpdate.add(oAcc);
                            setAccntId.add(oAcc.Id);
                        }
                        setNewContactIds.add(oContact.Id);
                        if(!mapAccIdToConObj.containsKey(oContact.AccountId)) {
                            mapAccIdToConObj.put(oContact.AccountId, oContact);
                        }
                    }
                }
            }
        }
        if(!lstAccntToUpdate.isEmpty()) {
            List<Database.SaveResult> lstUpdateResults =
                Database.update(lstAccntToUpdate, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstAccntToUpdate, 'Account',
                'ContactHandler', 'updateGlobalPartner', 'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                for(Id accountId: mapIdToErrorMsg.keySet()) {
                    if(mapAccIdToConObj.containsKey(accountId)) {
                        Contact oContact = mapAccIdToConObj.get(
                            accountId);
                        for(String sErrorMsg: mapIdToErrorMsg.get(accountId)) {
                            oContact.addError(System.Label.Error_on_Account + sErrorMsg);
                        }
                    }
                }
            }
        }
        if(!setNewContactIds.isEmpty()) {
            createPartnerCommunityUser(setNewContactIds);
        }
    }

    /**********************************
    Method Name : createPartnerCommunityUser
    Description : This method creates Partner Community User with Global Partner Profile and default locale & timezone.
    Return type : void
    Parameter   : set<Id> 
    ************************************/
    @future
    public static void createPartnerCommunityUser(set<Id> setNewContactIds) {
        Database.DMLOptions oDmo = new Database.DMLOptions();
        oDmo.EmailHeader.triggerUserEmail = true;
        list<User> lstNewPartnerusers = new list<User>();
        map<Id, Contact> mapNewContact = new map<Id, Contact>();
        Id GlobalPartnerProfileId = null;
        try {
                GlobalPartnerProfileId = [select id from Profile where Name = :
                    System.Label.Global_Partner_Profile_Name limit 1
                ].Id;
                mapNewContact = new map<Id, Contact> ([select Id, FirstName, LastName,
                    Email, Title from Contact where Id IN: setNewContactIds
                ]);
            for(Contact c: mapNewContact.Values()) {
                User oUser = new User(FirstName = c.FirstName, LastName = c.LastName,
                    Email = c.Email, ContactId = c.Id, EmailEncodingKey = Constants.UTF_8_ENCODING,
                    LanguageLocaleKey = Constants.ENGLISH_US_LOCALE, LocaleSidKey =
                    Constants.ENGLISH_US_LOCALE, ProfileId = GlobalPartnerProfileId,
                    timezonesidkey = Constants.AMERICA_LA_TIMEZONE, username = c.email +
                    Constants.GLOBAL_PARTNER_EMAIL_SUFFIX, Title = c.Title);
                    String sAlias = c.FirstName.subString(0, 1);
                    if(c.LastName.length() > 7){
                        sAlias = sAlias + c.LastName.subString(0, 7);
                    }else{
                        sAlias = sAlias + c.LastName;
                    }
                    oUser.alias = sAlias;
                oUser.setOptions(oDmo);
                lstNewPartnerusers.add(oUser);
            }
            if(!lstNewPartnerusers.isEmpty()) {
                List<Database.SaveResult> lstInsertResults =
                    Database.insert(lstNewPartnerusers, false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstInsertResults, lstNewPartnerusers, 'User',
                    'ContactHandler', 'createPartnerCommunityUser', 'SFDC CI', false);
            }
        } catch(Exception oEx) {
            ErrorLogUtility.logGeneralError(oEx, 'ContactHandler',
                'createPartnerCommunityUser', 'SFDC CI');
            return;
        }
    }
    
    /**********************************
    Method Name : updateActiveConnectUserCount
    Description : This method is will update the Active Connect User Count on the 
                  associated ICP record.
    Return type : void
    Parameter   : List<Contact> , Map<Id, Contact>
    ************************************/
    private void updateActiveConnectUserCount(List<Contact> lstNewRecords, Map<Id, Contact> mapOldRecords) {
        map<Id, list<Contact>> mapICPToContacts = new map<Id, list<Contact>>();
        map<Id, Account> mapICPToUpdate = new map<Id, Account>();
        list<Contact> lstContacts = new list<Contact>();
        set<Id> setICPIds = new set<Id>();
        if(TriggerContextUtility.bUpdateActiveConnectUserCountFirstRun) {
            TriggerContextUtility.bUpdateActiveConnectUserCountFirstRun = false;
            for(Contact oContact : lstNewRecords) {
                if((null == mapOldRecords && oContact.Connect_Status__c == Constants.ACTIVE) || ( null != mapOldRecords
                && oContact.Connect_Status__c != mapOldRecords.get(oContact.Id).Connect_Status__c 
                && (oContact.Connect_Status__c == Constants.ACTIVE || mapOldRecords.get(oContact.Id).Connect_Status__c == Constants.ACTIVE))) {
                    setICPIds.add(oContact.AccountId);
                }
            }
            if(!setICPIds.isEmpty()) {
                lstContacts = [SELECT Id, AccountId, Account.Active_Connect_User_Count__c, Connect_Status__c 
                               from Contact where AccountId in: setICPIds];
            }
            System.debug('lstContacts:'+lstContacts);
            if(!lstContacts.isEmpty()) {
                for(Contact oAllContact : lstContacts) {
                    if(!mapICPToContacts.containsKey(oAllContact.AccountId) && oAllContact.Connect_Status__c == Constants.ACTIVE) {
                        list<Contact> lstContactToAdd = new list<Contact>();
                        lstContactToAdd.add(oAllContact);
                        mapICPToContacts.put(oAllContact.AccountId, lstContactToAdd);
                    }
                    else if(mapICPToContacts.containsKey(oAllContact.AccountId) && oAllContact.Connect_Status__c == Constants.ACTIVE) {
                        mapICPToContacts.get(oAllContact.AccountId).add(oAllContact);
                    }
                }
                for(Contact oContactToUpdate : lstNewRecords) {
                    if(!mapICPToUpdate.containsKey(oContactToUpdate.AccountId) && mapICPToContacts.containsKey(oContactToUpdate.AccountId)) {
                        Account oAccount = new Account();
                        oAccount.Id = oContactToUpdate.AccountId;
                        oAccount.Active_Connect_User_Count__c = mapICPToContacts.get(oContactToUpdate.AccountId).size();
                        System.debug('oAccount.Active_Connect_User_Count__c:'+oAccount.Active_Connect_User_Count__c);
                        mapICPToUpdate.put(oContactToUpdate.AccountId, oAccount);
                    }
                    else if(setICPIds.contains(oContactToUpdate.AccountId) && !mapICPToContacts.containsKey(oContactToUpdate.AccountId)) {
                        Account oAccount = new Account();
                        oAccount.Id = oContactToUpdate.AccountId;
                        oAccount.Active_Connect_User_Count__c = 0;
                        System.debug('oAccount.Active_Connect_User_Count__c:'+oAccount.Active_Connect_User_Count__c);
                        mapICPToUpdate.put(oContactToUpdate.AccountId, oAccount);
                    }
                }
            }
            if(!mapICPToUpdate.isEmpty()) {
                List<Database.SaveResult> lstUpdateResults =
                    Database.update(mapICPToUpdate.values(), false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, mapICPToUpdate.values(), 'Account',
                    'ContactHandler', 'updateActiveConnectUserCount', 'SFDC CI', false);
            }
        }
    }
    
    /**********************************
    Method Name : inactivateUsers
    Description : This method is will inactivate the User associated to the Contact
                  whose Connect Status is changed from Active to Inactive by calling
                  the future method updatePartnerUser.
    Return type : void
    Parameter   : List<Contact> , Map<Id, Contact>
    ************************************/
    private void inactivateUsers(List<Contact> lstNewRecords, Map<Id, Contact> mapOldRecords) {
        System.debug('In inactivateUsers');
        set<Id> setContactIds = new set<Id>();
        if(TriggerContextUtility.bInactivateUsers) {
            TriggerContextUtility.bInactivateUsers = false;
            for(Contact oContact: lstNewRecords) {
                if(oContact.Connect_Status__c == Constants.INACTIVE && mapOldRecords.get(oContact.Id).Connect_Status__c == Constants.ACTIVE) {
                    setContactIds.add(oContact.Id);
                }
            }
            System.debug('setContactIds: '+setContactIds);
            if(!setContactIds.isEmpty()) {
                System.enqueueJob(new QueueInactivatepartnerUser(setContactIds));
            }
        }
    }
    
    /**********************************
    Method Name : restrictActiveContactDeletion
    Description : This method is will restrict the users from deleting records with Connect Status
                  as Active
    Return type : void
    Parameter   : list<Contact> 
    ************************************/
    private void restrictActiveContactDeletion(list<Contact> lstOldRecords) {
        for(Contact oContact: lstOldRecords) {
            if(oContact.Connect_Status__c == Constants.ACTIVE) 
                oContact.addError(System.Label.Contact_Create_Error);
        }
    }
    
    /**********************************
    Method Name : errorMaximumCountReached
    Description : This method is will restrict the users from deleting records with Connect Status
                  as Active
    Return type : void
    Parameter   : list<Contact> 
    ************************************/
    private void errorMaximumCountReached(list<Contact> lstNewRecords,Map<Id, Contact> mapOldRecords) {
        set<Id> setICPIds = new set<Id>();
        map<Id, Account> mapICPs = new map<Id, Account>();
        
        if(TriggerContextUtility.bFlagForActiveConnectUserCount) {  // KN: Defect fix to prevent validation rule from firing twice
         TriggerContextUtility.bFlagForActiveConnectUserCount= false;         
      
        for(Contact oContact: lstNewRecords) {
                if((mapOldRecords== null && oContact.Connect_Status__c == Constants.ACTIVE)||(mapOldRecords!= null  && 
                oContact.Connect_Status__c == Constants.ACTIVE&& mapOldRecords.get(oContact.Id).Connect_Status__c != oContact.Connect_Status__c)) {
                setICPIds.add(oContact.AccountId);   
            }
        }
        
        if(!setICPIds.isEmpty()) {
            mapICPs = new map<Id, Account>([SELECT Id, Active_Connect_User_Count__c , Max_Connect_User_Count__c from Account where Id in: setICPIds]);
        }
        if(!mapICPs.isEmpty()) {
            for(Contact oContact: lstNewRecords) { // KN: Defect fix to check for Connect status change on update before evaluating validation
                if(mapICPs.get(oContact.AccountId).Active_Connect_User_Count__c >= mapICPs.get(oContact.AccountId).Max_Connect_User_Count__c) {
                   oContact.addError(System.Label.Contact_Limit_Error);
                }
            }
        }
    }
    }
    
}