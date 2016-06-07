/******************************************************************************************************
Class Name         : BulkImageLoading_Test
Description        : This class contains unit tests for validating the behavior of Apex class: BulkImageLoading
Created By         : Jeevan D
Created On         : 19-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class BulkImageLoading_Test {
    static testMethod void positiveTest() {
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();  
        list<Account> lstAccountCDSP = new list<Account>();
        user userPF = new User(Id = UserInfo.getUserId());
        user userCD = new User(Id = UserInfo.getUserId());
        System.runAs(UserPF) {
            Field_Group__c oFieldGroup1 = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
            insert oFieldGroup1;
            List<Field_Group_Element__c> lstFGE1 = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup1.Id);
            insert lstFGE1;
            JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('BulkImageResponseProcess', '', false);
            insert oJsonProcess;
            Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('BulkImageResponseFieldGroup', 'Content__c');
            insert oFieldGroup;
            JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('ContentList', oFieldGroup.Id, true, oJsonProcess.Id);
            insert oJsonStructure;
            List<Field_Group_Element__c> lstFGE = TestDataUtility.bulkImageResponseFGElementsTestData(oFieldGroup.Id);
            insert lstFGE;
            JSON_Process__c oJsonProcess2 = TestDataUtility.jsonProcessTestData('ContentLinkRequestProcess', '', false);
            insert oJsonProcess2;
            Field_Group__c oFieldGroup2 = TestDataUtility.fieldGroupTestData('ContentLinkRequestGroup', 'Content__c');
            insert oFieldGroup2;
            JSON_Structure__c oJsonStructure2 = TestDataUtility.jsonStructureTestData('ImageExport', oFieldGroup2.Id, true, oJsonProcess2.Id);
            insert oJsonStructure2;
            List<Field_Group_Element__c> lstFGE2 = TestDataUtility.contentfieldGroupElementTestData(oFieldGroup.Id);
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
            lstLead[0].ICP_ID__c = 'ET090';
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
            Database.LeadConvert lc1 = new Database.LeadConvert();
            lc1.setLeadId(lstLead[1].id);
            Test.startTest();
            lc1.setDoNotCreateOpportunity(true);
            lc1.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr1 = Database.convertLead(lc1);
            lstAccountICP = [Select id from Account Where Id IN: AccountId];
            
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;            
            lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);       
            lstAccountCDSP[0].Local_beneficiary_Number__c = '1234' ; 
            insert lstAccountCDSP ; 
        
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME);
        String sRequestURI = System.URL.getSalesforceBaseUrl()+'/services/apexrest/BulkImageLoad';
        String sTestJson = '{"ContentList":[ {"ChildKey": "ET0901234","DocumentType": "Photo-BeneficiaryHeadshot"}]}';        
        String JsonMsg=JSON.serialize(sTestJson);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        
        req.requestBody = Blob.valueof(sTestJson);
        RestContext.request = req;
        RestContext.response = res;
        BulkImageLoading.createContentForBen();
        
        List<Content__c> lstContentFrBen = [Select ID from Content__c Where Beneficiary__c =: lstAccountCDSP[0].Id] ; 
        system.Assert(lstContentFrBen.size() > 0); 
        
        String sTestJson2 = '{"ContentList":[ {"ChildKey": "ET0901265","DocumentType": "Photo-BeneficiaryHeadshot"}]}';
        req.requestBody = Blob.valueof(sTestJson2);
        RestContext.request = req;
        RestContext.response = res;
        BulkImageLoading.createContentForBen();
        
        String sTestInvalidJson = '{"ContentList":[ {"ChildKey":/$% "EC3478925","DocumentType": "Photo-BeneficiaryHeadshot"}]}';
        req.requestBody = Blob.valueof(sTestInvalidJson);
        RestContext.request = req;
        RestContext.response = res;
        BulkImageLoading.createContentForBen();
        
        String sTestInvalidJson2 = '{"ContentList":[ {"ChildKey": "","DocumentType": "Photo-BeneficiaryHeadshot"}]}';
        req.requestBody = Blob.valueof(sTestInvalidJson2);
        RestContext.request = req;
        RestContext.response = res;
        BulkImageLoading.createContentForBen();
        Test.stopTest();
       }
        
    
    }
}