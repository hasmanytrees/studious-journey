/******************************************************************************************************
Class Name         : ICPImpactListController_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     ICPImpactListController
Created By         : Sudipta Nayak
Created On         : 02-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=true) 
/* SeeAllData is set to true as we are querying Reports to implement the export
   functionaility on the Page, and test data for reports can not be created. */
private class ICPImpactListController_Test {
    static testMethod void icpImpactListTest()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            //List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
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
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            
            List<ICP_Impact__c> lstICPImpact = new List<ICP_Impact__c>();
            lstICPImpact = TestDataUtility.icpImpactTestData(lstAccountICP,lstDisaster[0]);
            insert lstICPImpact;
             Test.stopTest();

            Communication_Update__c oCommUpdate = TestDataUtility.commUpdateTestData(lstDisaster[0]);
            oCommUpdate.Communication_Updates_From__c = System.today() - 1;
            insert oCommUpdate;
            System.assertNotEquals(null,oCommUpdate);
            System.debug('oCommUpdate'+oCommUpdate);
            
            PageReference p = new PageReference('ICPImpactList?id='+oCommUpdate.Id);
            Test.setCurrentPage(p);
            ICPImpactListController oICPImpactListController = new ICPImpactListController();
            
            /*ImpactListComponentController oImpactListCompController = new ImpactListComponentController();
            oImpactListCompController.sObjectName = 'ICP';
            oImpactListCompController.bIsCreated = true;
            oImpactListCompController.lstICPToDisplay = lstICPImpact;
            
            oICPImpactListController.oImpactListComponentController = oImpactListCompController;*/
            
        }
    }
}