/******************************************************************************************************
Class Name         : FetchBeneficiaryStatus_Test
Description        : This class contains unit tests for validating the behavior of Apex class: FetchBeneficiaryStatus
Created By         : Shaik Manzoor
Created On         : 27-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class FetchBeneficiaryStatus_Test {
    static testMethod void positiveTest() {
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        List<Content__c> lstContents = new List<Content__c>();    
        FeedItem oFeedItem = new FeedItem(); 
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('FetchBenefStatusRequestProcess', '', false);
            insert oJsonProcess;
            Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('FetchBenefStatusRequestFieldGroup', 'Account');
            insert oFieldGroup;
            JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('BeneficiaryList', oFieldGroup.Id, true, oJsonProcess.Id);
            insert oJsonStructure;
            List<Field_Group_Element__c> lstFGE = TestDataUtility.fetchBenefStatusRequestFGElementTestData(oFieldGroup.Id);
            insert lstFGE;
            JSON_Process__c oJsonProcess2 = TestDataUtility.jsonProcessTestData('FetchBenefStatusResponseProcess', '', false);
            insert oJsonProcess2;
            Field_Group__c oFieldGroup2 = TestDataUtility.fieldGroupTestData('FetchBenefStatusResponseFieldGroup', 'Account');
            insert oFieldGroup2;
            JSON_Structure__c oJsonStructure2 = TestDataUtility.jsonStructureTestData('BeneficiaryList', oFieldGroup2.Id, true, oJsonProcess2.Id);
            insert oJsonStructure2;
            List<Field_Group_Element__c> lstFGE2 = TestDataUtility.fetchBenefStatusResponseFGElementTestData(oFieldGroup2.Id);
            insert lstFGE2;
            List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            lstLead[0].ICP_ID__c = 'XY989';
            insert lstLead;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
            lstAccountICP[0].ICP_ID__c = 'XY989';
            /*lstAccountICP = [Select Id, ICP_Status__c from Account where Id IN: AccountId];
            lstAccountICP[0].ICP_Status__c = 'Active';*/
            update lstAccountICP;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            list<Account> lstAccountCDSP = new list<Account>();
            TriggerContextUtility.bFirstRun=true;
            
            Test.startTest();
            lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Local_Beneficiary_Number__c = '8888';
            lstAccountCDSP[0].Compass_Id__c = 'XY9898888';
            lstAccountCDSP[1].Local_Beneficiary_Number__c = '9891';
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCDSP;
            String sRequestURI = System.URL.getSalesforceBaseUrl()+'/services/apexrest/FetchBeneficiaryStatus'; 
            String sTestJson = '{"BeneficiaryList": [{"CompassChildKey": "XY9898888"}]}';
            

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = sRequestURI;
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(sTestJson);
            RestContext.request = req;
            RestContext.response = res;
            FetchBeneficiaryStatus.fetchBeneficiaryStatusValue();
            
            String sTestJsonInsert = '{"BeneficiaryList": [{"CompassChildKey": "XY9898828"}]}';
            req.requestBody = Blob.valueof(sTestJsonInsert);
            RestContext.request = req;
            FetchBeneficiaryStatus.fetchBeneficiaryStatusValue();
            
            String sTestInvalidJson = '{"BeneficiaryList": [{"CompassChildKey": $%$"XY9898888"}]}';
            req.requestBody = Blob.valueof(sTestInvalidJson);
            RestContext.request = req;
            FetchBeneficiaryStatus.fetchBeneficiaryStatusValue();
            
            List<Account> lstAccs = [Select id from Account where ID IN: lstAccountCDSP ] ; 
            System.Assert(lstAccs.size () > 0  ) ;
             
            Test.stopTest();
            }
    }
    
    
}