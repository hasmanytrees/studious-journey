/******************************************************************************************************
Class Name         : MassUpdateController_Test
Description        : This class contains unit tests for validating the behavior of Controller class:
                     MassUpdateController
Created By         : Sudipta Nayak
Created On         : 05-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest(SeeAllData=false)
Private Class MassUpdateController_Test {
    static list<Account> lstAccountICP = new list<Account>(); 
      
    static TestMethod void massUpdateInjuryTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Injury';
            massUpdateController.oMedIncident.Injury__c = 'Poisoning';
            massUpdateController.oMedIncident.Optional_Comment__c = 'Food Poisoning';
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            massUpdateController.oFilterListHandler.oCompControllerRef = null;
            massUpdateController.oFilterListHandler.sObjectType = '';
            massUpdateController.oFilterListHandler.sObjectName = '';
            massUpdateController.oFilterListHandler.resetSelectedValue();
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.oAccount = lstAccountICP[0];
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
        }
    }
    
    static TestMethod void massUpdateTransferTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Transfer';
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            FilterListCompController oFilterCriteria = new FilterListCompController();
            oFilterCriteria.sSelectedFirstParam = 'Gender';
            oFilterCriteria.sSelectedSecondParam = 'equals';
            oFilterCriteria.sSelectedThirdParam = 'Male';
            massUpdateController.oFilterListHandler.oCompControllerRef = oFilterCriteria;
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.oAccount = lstAccountICP[0];
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
        }
    }
    
    static TestMethod void massUpdateATTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Age Transition';
            massUpdateController.oIcpAccount.Cognitive_Age_Group__c = '0 - 2';
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            massUpdateController.oFilterListHandler.oCompControllerRef = null;
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.oAccount = lstAccountICP[0];
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
        }
    }
    
    static TestMethod void massUpdateBenTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Beneficiary';
            massUpdateController.oIcpAccount.Beneficiary_Confession_Of_Faith_Date__c = System.today();
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            massUpdateController.oFilterListHandler.oCompControllerRef = null;
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.oAccount = lstAccountICP[0];
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
        }
    }
    
    static TestMethod void massUpdateImmunizationTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Immunization';
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            massUpdateController.oFilterListHandler.oCompControllerRef = null;
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.oAccount = lstAccountICP[0];
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
        }
    }
    
    static TestMethod void massUpdateIllnessTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Illness';
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            massUpdateController.oFilterListHandler.oCompControllerRef = null;
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.oAccount = lstAccountICP[0];
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
        }
    }
    
    static TestMethod void massUpdateTransitionTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Transition';
            massUpdateController.oBledisplay.Transition_Type__c = System.Label.CSP_To_CDSP_Home;
            massUpdateController.oBledisplay.Date_Of_Action__c = System.today();
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            massUpdateController.oFilterListHandler.oCompControllerRef = null;
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.oAccount = lstAccountICP[0];
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
        }
    }
    static TestMethod void massUpdateHealthAssessmentTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Health_Assessment';
            massUpdateController.oBenefAssessment.Name='Test Assessment';
            massUpdateController.oBenefAssessment.Assessment_Completion_Date__c=System.today();
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            massUpdateController.oFilterListHandler.oCompControllerRef = null;
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.dWeight = 80;
            accountWr.dHeight =80;
            accountWr.oAccount = lstAccountICP[0];
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
        }
    }
    static TestMethod void massUpdateGrowthMonitoringTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Growth_Monitoring';
            massUpdateController.oBenefAssessment.Name='Test Assessment';
            massUpdateController.oBenefAssessment.Assessment_Completion_Date__c=System.today();
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            massUpdateController.oFilterListHandler.oCompControllerRef = null;
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.dWeight = 80;
            accountWr.dHeight =80;
            accountWr.oAccount = lstAccountICP[0];
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            massUpdateController.getAccWrapSets();
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
        }
    }
    static TestMethod void massUpdatePortalGrowthMonitoringTest() {
        User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser1;  
            
        System.RunAs( oUser1 ) {  
        List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
        insert lstRegionTestData ;  
        // to create test data for Field office 
        List<string> lstFieldOfficeNames = new List<String> (  ) ; 
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        lstFieldOfficeNames.add( 'testField' ) ; 
        list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;   
        insert lstFieldOfficeData ;      
        // To Create Territory test data 
        List<string> lstTerritoryNames = new List<String> (  ) ; 
        lstTerritoryNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        insert lstTerritoryTestData ;  
        //// to create Cluster test data
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
        insert lstClusterTestData ;
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ; 
        insert oICPAccount ; 
        Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID ) ; 
        Insert oConTest ;
        User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
        oUser2.ContactId = oConTest.Id ; 
        oUser2.PortalRole = 'Manager' ;
        insert oUser2;
        System.RunAs( oUser2 ) {
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Growth_Monitoring';
            massUpdateController.oBenefAssessment.Name='Test Assessment';
            massUpdateController.oBenefAssessment.Assessment_Completion_Date__c=System.today();
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            massUpdateController.oFilterListHandler.oCompControllerRef = null;
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.dWeight = 80;
            accountWr.dHeight =80;
            accountWr.oAccount = oICPAccount;
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            massUpdateController.getAccWrapSets();
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
         }
      
       }
    }
    static TestMethod void massUpdateTransitionTypeEmptyTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Transition';
            massUpdateController.oBledisplay.Transition_Type__c = '';
            massUpdateController.oBledisplay.Date_Of_Action__c = System.today();
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            massUpdateController.oFilterListHandler.oCompControllerRef = null;
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.oAccount = lstAccountICP[0];
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
        }
    }
    static TestMethod void massUpdateGrowthMonitoringEmptyHeightTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            List<sObject> lstMassUpdateData = Test.loadData(Mass_Update__c.sObjectType, 'MassUpdateData');
            List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            Test.startTest();
            PageReference p = new PageReference('MassUpdateRecords');
            Test.setCurrentPage(p);
            MassUpdateController massUpdateController = new MassUpdateController();
            massUpdateController.sObjectType = 'Growth_Monitoring';
            massUpdateController.oBenefAssessment.Name='Test Assessment';
            massUpdateController.oBenefAssessment.Assessment_Completion_Date__c=System.today();
            massUpdateController.fetchUpdateFields();
            massUpdateController.setvalueTypeMap();
            massUpdateController.oFilterListHandler.oCompControllerRef = null;
            massUpdateController.bensearch();
            massUpdateController.AccountWrapper accountWr = new massUpdateController.AccountWrapper();
            accountWr.bIsChecked = true;
            accountWr.dWeight = 80;
            accountWr.dHeight =00;
            accountWr.oAccount = lstAccountICP[0];
            list<massUpdateController.AccountWrapper> lstAccWr = new list<massUpdateController.AccountWrapper>();
            lstAccWr.add(accountWr);
            massUpdateController.lstAccntWrapper = lstAccWr;
            massUpdateController.getAccWrapSets();
            PageReference benList = massUpdateController.createUpdateRecords();
            system.assert(massUpdateController.lstAccntWrapper[0].oAccount.id!=null);
            Test.stopTest();
        }
    }
             
}