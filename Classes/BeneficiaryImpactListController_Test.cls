/******************************************************************************************************
Class Name         : BeneficiaryImpactListController_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     BeneficiaryImpactListController
Created By         : Sudipta Nayak
Created On         : 15-Sep-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=true) 
/* SeeAllData is set to true as we are querying Reports to implement the export
   functionaility on the Page, and test data for reports can not be created. */
private class BeneficiaryImpactListController_Test {
    static testMethod void beneficiaryImpactListTest()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            //list<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            //list<Report> lstReport = Test.loadData(Report.sObjectType, 'Disaster_Reports');
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
            Test.startTest();
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
            update lstAccountICP;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            Test.stopTest();
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            insert lstAccountCDSP;
            
            
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
             System.assertNotEquals(null,lstDisaster);
            System.debug('Disaster Created Date'+lstDisaster[0].CreatedDate);
            
            List<Beneficiary_Impact__c> lstBeneficiaryImpact = TestDataUtility.beneficiaryImpactTestData(lstAccountCDSP,lstDisaster[0]);
            insert lstBeneficiaryImpact;
            System.assertNotEquals(null,lstBeneficiaryImpact);
            
            Communication_Update__c oCommUpdate = TestDataUtility.commUpdateTestData(lstDisaster[0]);            
            insert oCommUpdate;
            System.assertNotEquals(null,oCommUpdate.id);
            System.debug('oCommUpdate: '+oCommUpdate);
            
            /*Communication_Update__c oCommUpdateForUpdate = [SELECT Id, Disaster_Name__c, Communication_Updates_From__c, 
                 Communication_Updates_To__c, CreatedDate from Communication_Update__c];
            oCommUpdate.Communication_Updates_From__c = System.today() - 1;
            update oCommUpdate;
            System.debug('oCommUpdateForUpdate: '+oCommUpdateForUpdate);*/
            
            PageReference p = new PageReference('BeneficiaryImpactList?id='+oCommUpdate.Id);
            Test.setCurrentPage(p);
            BeneficiaryImpactListController oBeneficiaryImpactListController = new BeneficiaryImpactListController();
            
            /*ImpactListComponentController oImpactListCompController = new ImpactListComponentController();
            oImpactListCompController.sObjectName = 'Beneficiary';
            oImpactListCompController.bIsCreated = true;
            oImpactListCompController.lstBeneficiaryToDisplay = lstBeneficiaryImpact;
            
            oBeneficiaryImpactListController.oImpactListComponentController = oImpactListCompController;*/
          
        }
    }
}