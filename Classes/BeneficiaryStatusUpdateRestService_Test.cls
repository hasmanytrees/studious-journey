/******************************************************************************************************
Class Name         : BeneficiaryStatusUpdateRestService_Test
Description        : This class contains unit tests for validating the behavior of Apex class: BeneficiaryStatusUpdateRestService
Created By         : Danish Ahmed
Created On         : 30-March-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@isTest(SeeAllData=false) 
private class BeneficiaryStatusUpdateRestService_Test {

    static testMethod void positiveTest() {
        List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        List<Content__c> lstContents = new List<Content__c>();    
        FeedItem oFeedItem = new FeedItem(); 
        user userPF = new User(Id = UserInfo.getUserId());
        user userCD = new User(Id = UserInfo.getUserId());
        System.runAs(UserPF) {
            Field_Group__c oFieldGroup1 = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
            insert oFieldGroup1;
            List<Field_Group_Element__c> lstFGE1 = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup1.Id);
            insert lstFGE1;
            JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('UpdateBenefStatusDataRequestProcess', '', false);
            insert oJsonProcess;
            Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('UpdateBenefStatusRequestFieldGroup', 'Account');
            insert oFieldGroup;
            JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('BeneficiaryList', oFieldGroup.Id, true, oJsonProcess.Id);
            insert oJsonStructure;
            List<Field_Group_Element__c> lstFGE = TestDataUtility.updateBenefStatusFGElementsTestData(oFieldGroup.Id);
            insert lstFGE;
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
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;  
            oICPAccount.ICP_Id__c = 'XY989';
            lstAccountICP.add(oICPAccount);
            insert lstAccountICP;
            
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            list<Account> lstAccountCDSP = new list<Account>();
            TriggerContextUtility.bFirstRun=true;
            lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Local_Beneficiary_Number__c = '9899';
            lstAccountCDSP[0].Compass_Id__c = 'XY9899899';
            lstAccountCDSP[1].Local_Beneficiary_Number__c = '9891';
            lstAccountCDSP[1].Compass_Id__c = null;
            insert lstAccountCDSP;
            
            String sRequestURI = System.URL.getSalesforceBaseUrl()+'/services/apexrest/BeneficiaryStatusUpdate';
            String sTestJson = '{"BeneficiaryList": [{"ChildKey": "XY9899899","CompassChildKey": "XY9899899","SponsorshipStatus": "Sponsored"},{"ChildKey": "XY9899891","CompassChildKey": "XY9899891","SponsorshipStatus": "Sponsored"}]}';
            
            Test.startTest();
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = sRequestURI;
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(sTestJson);
            RestContext.request = req;
            RestContext.response = res;
            BeneficiaryStatusUpdateRestService.updateBenefeciaryStatus();
            
            String sTestInvalidJson = '{"BeneficiaryList": [{"ChildKey": ..///$$%"XY9899899","CompassChildKey": "XY9899899","SponsorshipStatus": "Sponsored"}]}';
            req.requestBody = Blob.valueof(sTestInvalidJson);
            RestContext.request = req;
            BeneficiaryStatusUpdateRestService.updateBenefeciaryStatus();
            
            Account oAccnt = [ Select Sponsorship_Status__pc  , Compass_Id__c from Account where ID=: lstAccountCDSP[0].ID ] ;  
            System.Assert ( lstAccountCDSP[0] != NULL ) ;
            
            String sTestDeleteJson = '{"BeneficiaryList": [{"ChildKey": "XY9899899","CompassChildKey": "XY9899899","SponsorshipStatus": "Sponsored"}]}';
            req.requestBody = Blob.valueof(sTestDeleteJson);
            RestContext.request = req;
            delete lstAccountCDSP;
            BeneficiaryStatusUpdateRestService.updateBenefeciaryStatus();
            System.Assert ( lstAccountCDSP[0].id != NULL ) ;
            
            Test.stopTest();
        }
    }
}