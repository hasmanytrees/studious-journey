/******************************************************************************************************
Class Name         : ImpactListComponentController_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     ImpactListComponentController
Created By         : Sudipta Nayak
Created On         : 06-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false)
private class ImpactListComponentController_Test {
    static testMethod void verifyImpactListComponentController_1() 
    {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            list<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
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
            List<Id> AccountId = new List<Id>();
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(True);
            lc.setConvertedStatus('Converted');
            Test.startTest();
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
            update lstAccountICP;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            Test.stopTest();
            insert lstAccountCDSP;
            
            
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            
            List<Beneficiary_Impact__c> lstBeneficiaryImpact = TestDataUtility.beneficiaryImpactTestData(lstAccountCDSP,lstDisaster[0]);
            insert lstBeneficiaryImpact;
            
            Communication_Update__c oCommunicationUpdate = new Communication_Update__c();
            oCommunicationUpdate = TestDataUtility.commUpdateTestData(lstDisaster[0]);            
            insert oCommunicationUpdate;
            System.assertNotEquals(null,oCommunicationUpdate.id);
            ImpactListComponentController oImpactListComponentController  = new ImpactListComponentController();
            oImpactListComponentController.lstBeneficiaryToDisplay = lstBeneficiaryImpact;
        }
    }
    
    static testMethod void verifyImpactListComponentController_2() 
    {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            list<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
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
            List<Id> AccountId = new List<Id>();
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(True);
            lc.setConvertedStatus('Converted');
            Test.startTest();
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
            update lstAccountICP;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            
            list<ICP_Impact__c> lstICPImpact = new List<ICP_Impact__c>();
            lstICPImpact = TestDataUtility.icpImpactTestData(lstAccountICP,lstDisaster[0]);
            insert lstICPImpact;
            
            Communication_Update__c oCommUpdate = TestDataUtility.commUpdateTestData(lstDisaster[0]);            
            insert oCommUpdate;
            System.assertNotEquals(null,oCommUpdate.id);
            ImpactListComponentController oImpactListComponentController  = new ImpactListComponentController();
            oImpactListComponentController.lstICPToDisplay = lstICPImpact;
            
            Test.StopTest();
        }
    }
}