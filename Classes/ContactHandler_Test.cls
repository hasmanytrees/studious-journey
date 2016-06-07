/******************************************************************************************************
Class Name         : ContactHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: ContactHandler
                     and ContactTrigger
Created By         : Sudipta Nayak
Created On         : 05-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class ContactHandler_Test {
    static testMethod void contactPositiveTestMethod() {
        Id globalPartnerRecTypeId = Utility.getRecordTypeIdByDeveloperName(Contact.SObjectType,Constants.CONTACT_GLOB_PART_RT_API_NAME);
        Id globalPartnerAccRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.GLOBAL_PARTNER_RT_API_NAME);
        set<Id> setContactId = new set<Id>();
        Account globalPartnerAccount = new Account( Name = 'Global Partner Test', RecordTypeId = globalPartnerAccRecTypeId);
        insert globalPartnerAccount;
        Contact contactGP = new Contact(FirstName = 'Bob', LastName = 'Phillip', RecordTypeId = globalPartnerRecTypeId, 
                                        AccountId = globalPartnerAccount.Id, Email = 'phillip@bob.com', Title = 'test');
        insert contactGP;
        setContactId.add(contactGP.id);
        Test.startTest();
        ContactHandler.createPartnerCommunityUser(setContactId);
        
     //   List<User> lstUser = [ Select ID from User where ContactId =:contactGP.ID ] ; 
        Account acc = [ Select ispartner from account where id =: globalPartnerAccount.ID ] ; 
        system.assert( acc.ispartner == true ) ; 
        Test.stopTest();
    }    
    
    static testMethod void contactMethod() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        System.runAs(UserPF) {
            test.starttest();
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserPF );
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF); 
            insert lstLead;
            List<Id> AccountId = new List<Id>();
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(True);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            Database.LeadConvert lc1 = new Database.LeadConvert();
            lc1.setLeadId(lstLead[1].id);
            lc1.setDoNotCreateOpportunity(True);
            lc1.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr1 = Database.convertLead(lc1);
            Id LeadId1 = lcr1.getAccountId();
            AccountId.add(LeadId1);
            List<Account> lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            lstAccountICP[0].IsPartner=true;
            lstAccountICP[1].IsPartner=true;
            update lstAccountICP;
            
            Contact oContact = TestDataUtility.ContactTestData('LastName');
            oContact.FirstName = 'FirstName';
            oContact.Contact_Status__c = 'No Access';
            oContact.Connect_Status__c = 'No Role';
            oContact.Connect_Role__c = 'ICP Full Access';
            oContact.Email = 'test@test.com';
            oContact.AccountID = lstAccountICP[0].id;
            insert oContact;
            
            oContact.Connect_Status__c = 'Active';
            oContact.Connect_Role__c = 'ICP Full Access';
            update oContact;
            
            try{
                delete oContact;
            }
            catch(Exception oEx) {
                System.assert(oEx.getMessage().contains(System.Label.Contact_Create_Error));
            }
        }
    }
    
    static testMethod void contactCountMethod() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        System.runAs(UserPF) {
            test.starttest();
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserPF );
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
           
            List<Id> AccountId = new List<Id>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ; 
           
            List<Account> lstAccountICP = new List<Account>();
            lstAccountICP.add(oICPAccount);            
            //lstAccountICP[0].IsPartner=true;
            //lstAccountICP[1].IsPartner=true;
            insert lstAccountICP;
            system.debug('^^^^^lstAccountICP'+lstAccountICP);
            
            Contact oContact = TestDataUtility.ContactTestData('LastName');
            oContact.FirstName = 'FirstName';
            oContact.Connect_Status__c = 'Active';
             oContact.Contact_Status__c = 'Active';
            oContact.FirstName = 'firstname';
            oContact.Connect_Role__c = 'ICP Full Access';
            oContact.Email = 'test@test.com';
            oContact.AccountID = lstAccountICP[0].id;
            insert oContact;
            system.debug('^^^^^oContact'+oContact);
           
        }
    }
}