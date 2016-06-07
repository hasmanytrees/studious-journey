/******************************************************************************************************
Class Name         : FetchBeneficiaryStatus_Test
Description        : This class contains unit tests for validating the behavior of Apex class: FetchBeneficiaryStatus
Created By         : Shaik Manzoor
Created On         : 27-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false)
private class FetchBeneficiaryInformation_Test {

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
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('FetchBenefInfoRequestProcess', '', false);
        insert oJsonProcess;
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('FetchBenefInfoRequestFieldGroup', 'Account');
        insert oFieldGroup;
        JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('BeneficiaryList', oFieldGroup.Id, true, oJsonProcess.Id);
        insert oJsonStructure;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.fetchBenefInfoRequestFGElementTestData(oFieldGroup.Id);
        insert lstFGE;
        
        JSON_Process__c oJsonProcess2 = TestDataUtility.jsonProcessTestData('BenefAndHMDataResponseProcess', 'BeneficiaryList', true);
        insert oJsonProcess2;
        Field_Group__c oFieldGroup2 = TestDataUtility.fieldGroupTestData('BeneficiaryResponseFieldGroup', 'Account');
        insert oFieldGroup2;
        Field_Group__c oFieldGroup3 = TestDataUtility.fieldGroupTestData('HouseholdMemWithBenefResponseFieldGroup', 'Household_Member__c');
        insert oFieldGroup3;
         JSON_Structure__c oJsonStructure2 = TestDataUtility.jsonStructureTestData('BeneficiaryList', oFieldGroup2.Id, false, oJsonProcess2.Id);
        insert oJsonStructure2;
        JSON_Structure__c oJsonStructure3 = TestDataUtility.jsonStructureTestData('HouseholdMembersList', oFieldGroup3.Id, true, oJsonProcess2.Id);
        insert oJsonStructure3;
        List<Field_Group_Element__c> lstFGE2 = TestDataUtility.benefResponseFGElementsTestData(oFieldGroup2.Id);
        insert lstFGE2;
        List<Field_Group_Element__c> lstFGE3 = TestDataUtility.hmWithBenefResponseFGElementsTestData(oFieldGroup3.Id);
        insert lstFGE3;
         
        
        List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
        List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
           
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
             
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
             system.debug('*****lstPMHierarchyCluster[0].Territory__r.Field_Office__r.Name'+lstPMHierarchyCluster[0].Territory__r.Field_Office__r.Name);
            system.debug('*****lstPMHierarchyCluster[0].Field_Office1__c'+lstPMHierarchyCluster[0].Field_Office1__c);
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            lstLead[0].ICP_ID__c = 'XY989';
             system.debug('****lstLead[0].Field_Office_For_Denominations__c'+lstLead[0].Field_Office_For_Denominations__c);
            system.debug('****lstLead[0].Field_Office__c'+lstLead[0].Field_Office__c);
            system.debug('****lstLead[0].Denomination_Church__c'+lstLead[0].Denomination_Church__c);
            
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
            lstAccountICP[0].ICP_ID__c = 'EC347';
            update lstAccountICP;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            System.assertNotEquals(null,lstHousehold[0].id);
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            System.assertNotEquals(null,lstHouseholdMember[0].id);
            list<Account> lstAccountCDSP = new list<Account>();
            TriggerContextUtility.bFirstRun=true;
            Test.startTest();
            
            lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Local_Beneficiary_Number__c = '8926';
            lstAccountCDSP[0].Compass_Id__c = '99894';
            lstAccountCDSP[1].Local_Beneficiary_Number__c = '8925';
            lstAccountCDSP[1].Compass_Id__c = '98';
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCDSP;
            System.assert(lstAccountCDSP[1].Local_Beneficiary_ID__c == 'EC3478925');

            List<Content__c> lstContentAcc = TestDataUtility.ContentTestDataSameAccount(lstAccountCDSP[0]);
            insert lstContentAcc;
            System.assertNotEquals(null,lstContentAcc);
            
            String sRequestURI = System.URL.getSalesforceBaseUrl()+'/services/apexrest/FetchBeneficiaryInformation';    
            String sTestJson = '{"BeneficiaryList": [{"CompassChildKey": "EC3478925","CompassId": "99891"}]}';
            
           
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = sRequestURI;
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(sTestJson);
            RestContext.request = req;
            RestContext.response = res;
            FetchBeneficiaryInformation.fetchBeneficiaryInfo();
            System.debug('@@@RestContext.response'+RestContext.response.responsebody);
            System.debug('@@@RestContext.response'+EncodingUtil.base64Encode(RestContext.response.responsebody));
            System.debug('@@@RestContext.response.responsebody###'+RestContext.response.statuscode);
            
            String sTestJsonBlankId = '{"BeneficiaryList": [{"CompassChildKey": "XY980987","CompassId": "98980987"}]}';
            req.requestBody = Blob.valueof(sTestJsonBlankId);
            RestContext.request = req;
            FetchBeneficiaryInformation.fetchBeneficiaryInfo();
            
            String sTestJsonInvalidQuery = '{"BeneficiaryList": [{"CompassChildKey": "XY9809@#$89","CompassId": "98980987"}]}';
            req.requestBody = Blob.valueof(sTestJsonInvalidQuery);
            RestContext.request = req;
            FetchBeneficiaryInformation.fetchBeneficiaryInfo();
            Test.stopTest();
            
            String sTestJsonDelete = '{"BeneficiaryList": [{"CompassChildKey": "XY9898888","CompassId": "9898888"}]}';
            req.requestBody = Blob.valueof(sTestJsonDelete);
            RestContext.request = req;
            delete lstAccountCDSP;
            FetchBeneficiaryInformation.fetchBeneficiaryInfo();
            
            String sTestJsonMultipleContent = '{"BeneficiaryList": [{"CompassChildKey": "XY9899891","CompassId": "9899891"}]}';
            req.requestBody = Blob.valueof(sTestJsonMultipleContent);
            RestContext.request = req;
            FetchBeneficiaryInformation.fetchBeneficiaryInfo();
            
            String sTestInvalidJson = '{"BeneficiaryList": ..&&///[{"CompassChildKey": "XY9898888","CompassId": "9898888"}]}';
            req.requestBody = Blob.valueof(sTestInvalidJson);
            RestContext.request = req;
            FetchBeneficiaryInformation.fetchBeneficiaryInfo();
            
            
            
        }
    }
}