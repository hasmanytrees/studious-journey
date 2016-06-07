/******************************************************************************************************
Class Name         : ActivityPlanHandler_Test 
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     ActivityPlanHandler and ActivityPlanTrigger
Created By         : Sudipta Nayak
Created On         : 03-Jul-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class ActivityPlanHandler_Test {
 
    static testMethod void activityPlanHandlerUpdateTest() {
        list<Id> AccountId = new List<Id>();
        list<Id> AccountIdNew = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPNew =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
       User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'GMC');
            insert oUser1;
        System.runAs(oUser1) {
       
            List<sObject> MilestonesSetupTaskData = Test.loadData(Milestones_Setup_Task__c.sObjectType, 'Milestones_Setup_Task');
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
            insert oFieldGroup;
            List<Field_Group_Element__c> lstFGE = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup.Id);
            insert lstFGE;

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
            Database.LeadConvert lcnew = new Database.LeadConvert();
            lcnew.setLeadId(lstLead[1].id);
            lcnew.setDoNotCreateOpportunity(true);
            lcnew.setConvertedStatus('Converted');
            test.starttest();
            
            Database.LeadConvertResult lcrnew = Database.convertLead(lcnew);
            Id LeadId = lcr.getAccountId();
            Id LeadIdNew = lcrnew.getAccountId();
            AccountId.add(LeadId);
            AccountIdNew.add(LeadIdNew);
              Profile oProfile = [select id from profile where name =: Constants.ICP_FULL_ACCESS_PROFILE LIMIT 1]; 
         
         User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = lstContact[0].Id ; 
         oUser2.PortalRole = 'Manager' ;
            insert oUser2;
             
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            //update lstAccountICP;
            lstAccountICPNew  = TestDataUtility.ICPTestData(AccountIdNew);
            //update lstAccountICPNew;
            list<Activity_Plan__c> lstActivityPlans = TestDataUtility.APTestData(lstAccountICP,  UserPF);
            insert lstActivityPlans[0];
            insert lstActivityPlans[1];
            
            list<Activity_Plan__c> lstActivityPlansNew = TestDataUtility.APTestData(lstAccountICPNew  ,  UserPF);
            insert lstActivityPlansNew[1];
            lstActivityPlans[1].ICP__c=lstActivityPlansNew[1].ICP__c;
            update lstActivityPlans[1];
            system.assert(lstActivityPlans.size()>0);
            test.stoptest();
            
        }
    }
}