/******************************************************************************************************
Class Name         : MassUpdateRecordsICPImpactExtension_Test
Description        : This class contains unit tests for validating the behavior of Extension class:
                     MassUpdateRecordsICPImpactExtension
Created By         : Sudipta Nayak
Created On         : 27-Oct-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest(SeeAllData=false)
private class MassUpdateRecordsICPImpactExtension_Test {
    static TestMethod void massCreateICPImpactsTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            list<Account> lstAccountICP = new list<Account>(); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            Test.startTest();
            insert lstLead;
            System.assertNotEquals(null,lstLead);
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
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
            
            PageReference p = new PageReference('MassUpdateRecordsICPImpact?disaster='+lstDisaster[0].Id);
            Test.setCurrentPage(p);
            
            ApexPages.StandardController standardController = new ApexPages.StandardController(new ICP_Impact__c());
            MassUpdateRecordsICPImpactExtension massUpdateExtension = new MassUpdateRecordsICPImpactExtension(standardController);
            
            massUpdateExtension.search();
            
            MassUpdateRecordsICPImpactExtension.AccountWrapper accountWr1 = new MassUpdateRecordsICPImpactExtension.AccountWrapper(lstAccountICP[0],false);
            accountWr1.bIsSelected = true;
            accountWr1.bAlreadyExists = false;
            accountWr1.oIcpImpactRecValues.Disaster_Impact_To_ICP_Infrastructure__c = 'Minor Damage';
            accountWr1.oIcpImpactRecValues.ICP_Disaster_Impact_Description__c = 'Test Desc';
            
            MassUpdateRecordsICPImpactExtension.AccountWrapper accountWr2 = new MassUpdateRecordsICPImpactExtension.AccountWrapper(lstAccountICP[1],false);
            accountWr2.bIsSelected = true;
            accountWr2.bAlreadyExists = true;
            accountWr2.oIcpImpactRecValues.Disaster_Impact_To_ICP_Infrastructure__c = 'Minor Damage';
            accountWr2.oIcpImpactRecValues.Disaster_Impact_On_ICP_Program__c = 'Temporarily Closed';
            accountWr2.oIcpImpactRecValues.ICP_Disaster_Impact_Description__c = 'Test Desc';
            
            list<MassUpdateRecordsICPImpactExtension.AccountWrapper> lstAccWr = new list<MassUpdateRecordsICPImpactExtension.AccountWrapper>();
            lstAccWr.add(accountWr1);
            lstAccWr.add(accountWr2);
             massUpdateExtension.lstICPWrapper = lstAccWr;
            
            massUpdateExtension.save();
            Test.stopTest();
        }
    }
    
    static TestMethod void massCreateICPImpactsTest1() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            list<Account> lstAccountICP = new list<Account>(); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            Test.startTest();
            insert lstLead;
            System.assertNotEquals(null,lstLead);
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
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
            List<ICP_Impact__c> lstICPImpact = new List<ICP_Impact__c>();
            lstICPImpact = TestDataUtility.icpImpactTestData(lstAccountICP,lstDisaster[0]);
            
            PageReference p = new PageReference('/MassUpdateRecordsICPImpact');
            Test.setCurrentPage(p);
               
        system.currentPageReference().getParameters().put('disaster', lstDisaster[0].Id);
            
            ApexPages.StandardController standardController = new ApexPages.StandardController(new ICP_Impact__c());
            MassUpdateRecordsICPImpactExtension massUpdateExtension = new MassUpdateRecordsICPImpactExtension(standardController);
            
            massUpdateExtension.sFilters = Constants.CLUSTER;
          
            massUpdateExtension.oFilter.Cluster__c = lstPMHierarchyCluster[0].Id;
            massUpdateExtension.search();
            
            MassUpdateRecordsICPImpactExtension.AccountWrapper accountWr1 = new MassUpdateRecordsICPImpactExtension.AccountWrapper(lstAccountICP[0],false);
            accountWr1.bIsSelected = true;
            accountWr1.bAlreadyExists = false;
            accountWr1.oIcpImpactRecValues.Disaster_Impact_To_ICP_Infrastructure__c = 'Minor Damage';
            
            MassUpdateRecordsICPImpactExtension.AccountWrapper accountWr2 = new MassUpdateRecordsICPImpactExtension.AccountWrapper(lstAccountICP[1],false);
            accountWr2.bIsSelected = true;
            accountWr2.bAlreadyExists = true;
            accountWr2.oIcpImpactRecValues.Disaster_Impact_To_ICP_Infrastructure__c = 'Minor Damage';
            accountWr2.oIcpImpactRecValues.Disaster_Impact_On_ICP_Program__c = 'Temporarily Closed';
            accountWr2.oIcpImpactRecValues.ICP_Disaster_Impact_Description__c = 'Test Desc';
            
            list<MassUpdateRecordsICPImpactExtension.AccountWrapper> lstAccWr = new list<MassUpdateRecordsICPImpactExtension.AccountWrapper>();
            lstAccWr.add(accountWr1);
            lstAccWr.add(accountWr2);
             massUpdateExtension.lstICPWrapper = lstAccWr;
            
            massUpdateExtension.save();
            massUpdateExtension.cancel();
            Test.stopTest();
        }
    }
    
    static TestMethod void massCreateICPImpactsTest2() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            list<Account> lstAccountICP = new list<Account>(); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            Test.startTest();
            insert lstLead;
            System.assertNotEquals(null,lstLead);
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
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
            
            PageReference p = new PageReference('MassUpdateRecordsICPImpact?disaster='+lstDisaster[0].Id);
            Test.setCurrentPage(p);
            
            ApexPages.StandardController standardController = new ApexPages.StandardController(new ICP_Impact__c());
            MassUpdateRecordsICPImpactExtension massUpdateExtension = new MassUpdateRecordsICPImpactExtension(standardController);
            
            massUpdateExtension.search();
          
            
            MassUpdateRecordsICPImpactExtension.AccountWrapper accountWr1 = new MassUpdateRecordsICPImpactExtension.AccountWrapper(lstAccountICP[0],false);
            accountWr1.bIsSelected = true;
            accountWr1.bAlreadyExists = false;
            accountWr1.oIcpImpactRecValues.Disaster_Impact_To_ICP_Infrastructure__c = 'Minor Damage';
            accountWr1.oIcpImpactRecValues.Disaster_Impact_On_ICP_Program__c = 'Permanently Closed';
            accountWr1.oIcpImpactRecValues.ICP_Disaster_Impact_Description__c = 'Test Desc';
            
            MassUpdateRecordsICPImpactExtension.AccountWrapper accountWr2 = new MassUpdateRecordsICPImpactExtension.AccountWrapper(lstAccountICP[1],false);
            accountWr2.bIsSelected = true;
            accountWr2.bAlreadyExists = false;
            accountWr2.oIcpImpactRecValues.Disaster_Impact_To_ICP_Infrastructure__c = 'Minor Damage';
            accountWr2.oIcpImpactRecValues.Disaster_Impact_On_ICP_Program__c = 'Temporarily Closed';
            accountWr2.oIcpImpactRecValues.ICP_Disaster_Impact_Description__c = 'Test Desc';
            
            list<MassUpdateRecordsICPImpactExtension.AccountWrapper> lstAccWr = new list<MassUpdateRecordsICPImpactExtension.AccountWrapper>();
            lstAccWr.add(accountWr1);
            lstAccWr.add(accountWr2);
             massUpdateExtension.lstICPWrapper = lstAccWr;
            
            massUpdateExtension.save();
            Test.stopTest();
        }
    }
}