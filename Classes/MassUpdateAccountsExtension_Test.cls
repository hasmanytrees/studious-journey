/******************************************************************************************************
Class Name         : MassUpdateAccountsExtension_Test
Description        : This class contains unit tests for validating the behavior of Controller class:
                     MassUpdateAccountsExtension
Created By         : Sudipta Nayak
Created On         : 26-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@isTest(SeeAllData=false)
Private Class MassUpdateAccountsExtension_Test {
    
    static list<Account> lstAccountICP = new list<Account>();
    static list<Account> lstAccountCDSP = new list<Account>();
    static list<Account> lstAccountCSP = new list<Account>();
    
    static TestMethod void massUpdateAccountsBENTest(){
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            Try{
                List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
                list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
                insert  lstPMHierarchyReg;
                list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
                insert lstAccountFO[0];
                list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
                insert lstPMHierarchyTer;
                TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
                TriggerContextUtility.bSendToAMIntegFirstRun = false;
                list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
                insert lstPMHierarchyCluster;
                list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
                insert lstLead;
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
                Test.startTest();
                lstAccountICP = TestDataUtility.ICPTestData(AccountId);
                update lstAccountICP;
                 
                User UserNewPF = TestDataUtility.UserTestData('Partnership Facilitator','PFnewUser', 'Ethiopia Partnership Facilitator');
                insert UserNewPF;
                list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
                insert lstHousehold;
                list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
                insert lstHouseholdMember;
                lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
                TriggerContextUtility.bPrimaryCaregiverFirstRun= true;                
                insert lstAccountCDSP;        
                
                lstAccountCSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
                TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
                insert lstAccountCSP;  
                    
                Global_Data__c globalData = new Global_Data__c(
                    Need_Type__c = 'Beneficiary Need', Need_Category__c = 'Special/Mental' );
                insert globalData;
                Needs_Association__c needs = TestDataUtility.NeedsAssociationTestData(
                    lstAccountCDSP[0].Id, 'Beneficiary Association', false, 'Local Resources', System.today(), 'High');
                insert needs;
                Needs_Association__c needs1 = TestDataUtility.NeedsAssociationTestData(
                    lstAccountCDSP[1].Id, 'Beneficiary Association', false, 'Local Resources', System.today()+1, 'Medium');
                insert needs1;

                    PageReference p = new PageReference('MassUpdateAccounts');
                    Test.setCurrentPage(p);
                    ApexPages.StandardController standardController = new ApexPages.StandardController( needs ) ;
                    MassUpdateAccountsExtension massUpdateAccounts = new MassUpdateAccountsExtension(standardController);
                    massUpdateAccounts.oTempAssociation.ICP__c = lstAccountICP[0].id;
                    massUpdateAccounts.sAccType = Constants.BEN_TOKEN;
                    list<MassUpdateAccountsExtension.AccountWrapper> lstAccWrapper = new list<MassUpdateAccountsExtension.AccountWrapper>();
                    MassUpdateAccountsExtension.AccountWrapper accountWr = new MassUpdateAccountsExtension.AccountWrapper(lstAccountCDSP[0]);
                    accountWr.bAlreadyExists = false;
                    accountWr.bIsSelected = true;
                    lstAccWrapper.add(accountWr);
                    Test.stopTest();
                    MassUpdateAccountsExtension.AccountWrapper accountWr1 = new MassUpdateAccountsExtension.AccountWrapper(lstAccountCDSP[0]);
                    accountWr1.bAlreadyExists = true;
                    accountWr1.bIsSelected = false;
                    accountWr1.sOldPriority = 'Medium';
                    accountWr1.oNeedAssociation = needs1;
                    lstAccWrapper.add(accountWr1);
                    MassUpdateAccountsExtension.AccountWrapper accountWr2 = new MassUpdateAccountsExtension.AccountWrapper(lstAccountCDSP[0]);
                    accountWr2.bAlreadyExists = false;
                    accountWr2.bIsSelected = false;
                    lstAccWrapper.add(accountWr2);
                    MassUpdateAccountsExtension.AccountWrapper accountW = new MassUpdateAccountsExtension.AccountWrapper(lstAccountCDSP[0]);
                    accountW.bAlreadyExists = true;
                    accountW.bIsSelected = true;
                    accountWr1.sOldPriority = 'Medium';
                    accountWr1.oNeedAssociation = needs;
                    lstAccWrapper.add(accountW);
                    massUpdateAccounts.lstAccount = lstAccWrapper;
                    massUpdateAccounts.updateList();                    
                    massUpdateAccounts.gatherRelatedData();                    
                    PageReference cancel = massUpdateAccounts.Cancel();
                    System.assertequals(lstAccountCDSP[0].id,needs.Account__c);
              }Catch(Exception e){
              }
        }
    }
    
    static TestMethod void massUpdateAccountsICPTest(){
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
             Test.startTest();
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;           
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            
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
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            update lstAccountICP;
            Test.stopTest();
            User UserNewPF = TestDataUtility.UserTestData('Partnership Facilitator','PFnewUser', 'Ethiopia Partnership Facilitator');
            insert UserNewPF;
            
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
                
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            
            insert lstAccountCDSP;
            lstAccountCSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCSP;
            Global_Data__c globalData = new Global_Data__c(
                Need_Type__c = 'Beneficiary Need', Need_Category__c = 'Special/Mental' );
            insert globalData;
            Needs_Association__c needs = TestDataUtility.NeedsAssociationTestData(
                lstAccountCDSP[0].Id, 'Beneficiary Association', false, 'Local Resources', System.today(), 'High');
            insert needs;

            PageReference p = new PageReference('MassUpdateAccounts');
            Test.setCurrentPage(p);            
            ApexPages.StandardController standardController = new ApexPages.StandardController( needs ) ;
            MassUpdateAccountsExtension massUpdateAccounts = new MassUpdateAccountsExtension(standardController);
       
            massUpdateAccounts.oTempAssociation.ICP__c = lstAccountICP[0].id;
            massUpdateAccounts.sAccType = Constants.ICP_TOKEN;
            list<MassUpdateAccountsExtension.AccountWrapper> lstAccWrapper = new list<MassUpdateAccountsExtension.AccountWrapper>();
            
            MassUpdateAccountsExtension.AccountWrapper accountWr = new MassUpdateAccountsExtension.AccountWrapper(lstAccountCDSP[0]);
            accountWr.bAlreadyExists = false;
            accountWr.bIsSelected = true;
            lstAccWrapper.add(accountWr);            
            massUpdateAccounts.lstAccount = lstAccWrapper;
            massUpdateAccounts.gatherRelatedData();            
            massUpdateAccounts.updateList();            
            PageReference cancel = massUpdateAccounts.Cancel();
            System.assertequals(lstAccountCDSP[0].id,needs.Account__c);
        }
    }
    
    static TestMethod void massUpdateAccountsNegativeTest(){
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            Test.startTest();
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            update lstAccountICP;  
            Test.stopTest();         
            User UserNewPF = TestDataUtility.UserTestData('Partnership Facilitator','PFnewUser', 'Ethiopia Partnership Facilitator');
            insert UserNewPF;            
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCDSP;
            lstAccountCSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCSP;
            Global_Data__c globalData = new Global_Data__c(
                Need_Type__c = 'Beneficiary Need', Need_Category__c = 'Special/Mental' );
            insert globalData;
            Needs_Association__c needs = new Needs_Association__c(Account__c = lstAccountCSP[0].id);
            insert needs;
            
            PageReference p = new PageReference('MassUpdateAccounts');
            Test.setCurrentPage(p);
            ApexPages.StandardController standardController = new ApexPages.StandardController( needs ) ;
            MassUpdateAccountsExtension massUpdateAccounts = new MassUpdateAccountsExtension(standardController);
            massUpdateAccounts.oTempAssociation.ICP__c = lstAccountICP[0].id;
            massUpdateAccounts.sAccType = Constants.ICP_TOKEN;
            list<MassUpdateAccountsExtension.AccountWrapper> lstAccWrapper = new list<MassUpdateAccountsExtension.AccountWrapper>();
          
            MassUpdateAccountsExtension.AccountWrapper accountWr = new MassUpdateAccountsExtension.AccountWrapper(lstAccountCDSP[0]);
            accountWr.bAlreadyExists = false;
            accountWr.bIsSelected = true;
            lstAccWrapper.add(accountWr);
            massUpdateAccounts.lstAccount = lstAccWrapper;
            massUpdateAccounts.gatherRelatedData();            
            massUpdateAccounts.updateList();            
            PageReference cancel = massUpdateAccounts.Cancel();
            System.assertequals(lstAccountCSP[0].id,needs.Account__c);
        }
    }
}