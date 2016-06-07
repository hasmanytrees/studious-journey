/******************************************************************************************************
Class Name         : MassUpdateRecordsBenImpactExtension_Test
Description        : This class contains unit tests for validating the behavior of Extension class:
                     MassUpdateRecordsICPImpactExtension
Created By         : Sudipta Nayak
Created On         : 27-Oct-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest(SeeAllData=false)
private class MassUpdateRecordsBenImpactExtension_Test {
    static TestMethod void massCreateBenImpactsTest() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.assertNotEquals(null,UserCD);
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<Account> lstAccountICP = new list<Account>(); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            
            insert lstPMHierarchyReg;
            
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            
            insert lstLead;
            Test.startTest();
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
            Test.stopTest();

            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
             System.assertNotEquals(null,lstHouseholdMember);
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[0].ICP__c = lstAccountICP[0].Id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].ICP__c = lstAccountICP[0].Id;
            insert lstAccountCDSP;
             
            System.assertNotEquals(null,lstAccountCDSP);
            PageReference p = new PageReference('MassUpdateRecordsICPImpact?disaster='+lstDisaster[0].Id);
            Test.setCurrentPage(p);
            
            ApexPages.StandardController standardController = new ApexPages.StandardController(new Beneficiary_Impact__c());
            MassUpdateRecordsBenImpactExtension massUpdateExtension = new MassUpdateRecordsBenImpactExtension(standardController);
            
            massUpdateExtension.oFilter.ICP__c = lstAccountICP[0].Id;
            massUpdateExtension.search();
            
            MassUpdateRecordsBenImpactExtension.AccountWrapper accountWr1 = new MassUpdateRecordsBenImpactExtension.AccountWrapper(lstAccountCDSP[0],false);
            accountWr1.bIsSelected = true;
            accountWr1.bAlreadyExists = false;
            accountWr1.oBenImpactRecValues.BEN_Location__c = 'At Home';
            accountWr1.oBenImpactRecValues.BEN_Physical_Condition__c = 'Beneficiary Seriously Injured';
            accountWr1.oBenImpactRecValues.BEN_Phy_Condition_Description__c = 'Serious Injuries';
            accountWr1.oBenImpactRecValues.Number_Caregivers_Died__c = 1;
            accountWr1.oBenImpactRecValues.Number_Of_Caregivers_Seriously_Injured__c = 2;
            accountWr1.oBenImpactRecValues.Number_Siblings_Died__c = 1;
            accountWr1.oBenImpactRecValues.Number_Of_Siblings_Seriously_Injured__c = 0;
            accountWr1.oBenImpactRecValues.Loss_Of_Livelihood__c = false;
            
            
            MassUpdateRecordsBenImpactExtension.AccountWrapper accountWr2 = new MassUpdateRecordsBenImpactExtension.AccountWrapper(lstAccountCDSP[1],false);
            accountWr2.bIsSelected = true;
            accountWr2.bAlreadyExists = false;
            accountWr2.oBenImpactRecValues.BEN_Location__c = 'At Home';
            accountWr2.oBenImpactRecValues.BEN_Physical_Condition__c = 'Beneficiary Seriously Injured';
            accountWr2.oBenImpactRecValues.BEN_Phy_Condition_Description__c = 'Serious Injuries';
            accountWr2.oBenImpactRecValues.Number_Of_Caregivers_Seriously_Injured__c = 0;
            accountWr2.oBenImpactRecValues.Number_Caregivers_Died__c = 1;
            accountWr2.oBenImpactRecValues.Number_Siblings_Died__c = 3;
            accountWr2.oBenImpactRecValues.Number_Of_Siblings_Seriously_Injured__c = 1;
            accountWr2.oBenImpactRecValues.House_Condition__c = 'Destroyed';
            accountWr2.oBenImpactRecValues.Lost_Personal_Effects__c = 'Lost School Supplies; Lost Clothing; Lost Household Items';
            accountWr2.oBenImpactRecValues.Loss_Of_Livelihood__c = true;
            
            list<MassUpdateRecordsBenImpactExtension.AccountWrapper> lstAccWr = new list<MassUpdateRecordsBenImpactExtension.AccountWrapper>();
            lstAccWr.add(accountWr1);
            lstAccWr.add(accountWr2);
            massUpdateExtension.lstBeneficiaryWrapper = lstAccWr;
            
            massUpdateExtension.save();

        }
    }
    
    static TestMethod void massCreateBenImpactsTest1() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.assertNotEquals(null,UserCD);
        list<Id> AccountId = new list<Id>();
        System.runAs(UserPF) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<Account> lstAccountICP = new list<Account>(); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            
            insert lstPMHierarchyReg;            
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            
            insert lstLead;
            Test.startTest();
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
            Test.stopTest();
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            insert lstAccountCDSP;

            System.assertNotEquals(null,lstAccountCDSP);
            List<Beneficiary_Impact__c> lstBeneficiaryImpact = TestDataUtility.beneficiaryImpactTestData(lstAccountCDSP,lstDisaster[0]);
            insert lstBeneficiaryImpact;
            System.assertNotEquals(null,lstBeneficiaryImpact);
            PageReference p = new PageReference('MassUpdateRecordsICPImpact?disaster='+lstDisaster[0].Id);
            Test.setCurrentPage(p);
            
            ApexPages.StandardController standardController = new ApexPages.StandardController(new Beneficiary_Impact__c());
            MassUpdateRecordsBenImpactExtension massUpdateExtension = new MassUpdateRecordsBenImpactExtension(standardController);
            
            massUpdateExtension.sFilters = 'ICP';
            massUpdateExtension.oFilter.ICP__c = lstAccountICP[0].Id;
            massUpdateExtension.search();
            
            MassUpdateRecordsBenImpactExtension.AccountWrapper accountWr1 = new MassUpdateRecordsBenImpactExtension.AccountWrapper(lstAccountCDSP[0],false);
            accountWr1.bIsSelected = true;
            accountWr1.bAlreadyExists = false;
            accountWr1.oBenImpactRecValues.BEN_Location__c = 'Missing';
            accountWr1.oBenImpactRecValues.BEN_Physical_Condition__c = 'Unknown';
            accountWr1.oBenImpactRecValues.Number_Caregivers_Died__c = 1;
            accountWr1.oBenImpactRecValues.Number_Of_Caregivers_Seriously_Injured__c = 2;
            accountWr1.oBenImpactRecValues.Number_Siblings_Died__c = 1;
            accountWr1.oBenImpactRecValues.Number_Of_Siblings_Seriously_Injured__c = 0;
            accountWr1.oBenImpactRecValues.House_Condition__c = 'Unknown';
            accountWr1.oBenImpactRecValues.Lost_Personal_Effects__c = 'None';
            accountWr1.oBenImpactRecValues.Loss_Of_Livelihood__c = false;
            
            
            MassUpdateRecordsBenImpactExtension.AccountWrapper accountWr2 = new MassUpdateRecordsBenImpactExtension.AccountWrapper(lstAccountCDSP[1],false);
            accountWr2.bIsSelected = true;
            accountWr2.bAlreadyExists = false;
            accountWr2.oBenImpactRecValues.BEN_Location__c = 'At Home';
            accountWr2.oBenImpactRecValues.BEN_Physical_Condition__c = 'Beneficiary Seriously Injured';
            accountWr2.oBenImpactRecValues.BEN_Phy_Condition_Description__c = 'Serious Injuries';
            accountWr2.oBenImpactRecValues.House_Condition__c = 'Destroyed';
            accountWr2.oBenImpactRecValues.Lost_Personal_Effects__c = 'Lost School Supplies; Lost Clothing; Lost Household Items';
            accountWr2.oBenImpactRecValues.Loss_Of_Livelihood__c = true;
            
            list<MassUpdateRecordsBenImpactExtension.AccountWrapper> lstAccWr = new list<MassUpdateRecordsBenImpactExtension.AccountWrapper>();
            lstAccWr.add(accountWr1);
            lstAccWr.add(accountWr2);
            massUpdateExtension.lstBeneficiaryWrapper = lstAccWr;
            
            massUpdateExtension.defaultFields();
            massUpdateExtension.save();
            massUpdateExtension.cancel();

        }
    }
}