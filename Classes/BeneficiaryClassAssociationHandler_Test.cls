/******************************************************************************************************
Class Name         : BeneficiaryClassAssociationHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
BeneficiaryClassAssociationHandler
Created By         : Sudipta Nayak
Created On         : 05-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class BeneficiaryClassAssociationHandler_Test {
    static testMethod void classAssociationTest()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;   
             Test.starttest();                
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
            lstContact[0].Role_At_ICP__c = 'Tutor / Implementer';
            insert lstContact;
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
            lstContact[0].AccountId = lstAccountICP[0].Id;
            lstContact[0].Lead__c = null;
            Update lstContact[0];
            Test.stoptest();
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;            
            insert lstAccountCDSP;
            
            Yearly_Class_Schedule__c oYearlyClass = TestDataUtility.yearlyClassScheduleTestData(lstAccountICP[0], lstContact[0]);
            insert oYearlyClass;
             System.assertNotEquals(null,oYearlyClass.id);
            Monthly_Class_Schedule__c oMonthlyClass = TestDataUtility.monthlyClassScheduleTestData(oYearlyClass);
            insert oMonthlyClass;
            System.assertNotEquals(null,oMonthlyClass.id);
            Beneficiary_Class_Association__c oClassAssoc = TestDataUtility.beneficiaryClassAssociationTestData(lstAccountCDSP[0], oMonthlyClass);
            insert oClassAssoc;       
             System.assertNotEquals(null,oClassAssoc.id);
            delete oClassAssoc;
            System.assertNotEquals(null,oClassAssoc);
            
        }
    }
}