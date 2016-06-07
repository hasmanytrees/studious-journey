/******************************************************************************************************
Class Name         : CreateSupporterProfile_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CreateSupporterProfile
Created By         : Nayana Prabhakar
Created On         : 24-March-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false)
private class CreateSupporterProfile_Test {
    static testMethod void positiveTest() {
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>(); 
        user userPF = new User(Id = UserInfo.getUserId());
        user userCD = new User(Id = UserInfo.getUserId());
        
        System.runAs(UserPF) {
            JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('SupporterMiniProfileRequestProcess', 'SupporterProfile', true);
            insert oJsonProcess;
            Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SupporterRequestGroup', 'Account');
            insert oFieldGroup;
            JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('SupporterProfile', oFieldGroup.Id, false, oJsonProcess.Id);
            insert oJsonStructure;
            List<Field_Group_Element__c> lstFGE = TestDataUtility.createSupporterProfileFieldGroupElementTestData(oFieldGroup.Id);
            insert lstFGE;
            List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
                       
            Account oAcc = TestDataUtility.createGlobalPartnerData('USA');
            insert oAcc;
            System.assertNotEquals(null,oAcc.id);
            
            String sRequestURI = System.URL.getSalesforceBaseUrl()+'/services/apexrest/CreateSupporter';
            
            String sTestJson = '{"SupporterProfile":[{"GPID":"7-3889508","FirstName":"Theo","LastName":"Wheeler","Language":null,"Gender":"M","GlobalPartner":"Compassion USA","PreferredName":"Theo","Status":"Active","StatusReason":null}]}';
            //String sTestJson = '{"SupporterProfile":[{"GPID":"33857756","FirstName":"Theo","LastName":"Wheeler","Language":null,"Gender":"M","GlobalPartner":"USA"}]}';
            
            Test.startTest();
            
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = sRequestURI;
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(sTestJson);
            RestContext.request = req;
            RestContext.response = res;
            System.debug('---RestContext.request--'+RestContext.request+'--response-'+RestContext.response);
            CreateSupporterProfile.createSupporterProfile();
            System.debug('@@@RestContext.response.responsebody'+String.valueOf(RestContext.response.responsebody));
            System.debug('@@@RestContext.response.responsebody###'+EncodingUtil.base64Encode(RestContext.response.responsebody));
            System.debug('@@@###RestContext.response.responsebody###'+res);
            
            String sTestJsonMissingGPID = '{"SupporterProfile":[{"GPID":null,"FirstName":"","LastName":"","Language":null,"Gender":"","GlobalPartner":"USA"}]}';
            req.requestBody = Blob.valueof(sTestJsonMissingGPID);
            RestContext.request = req;
            CreateSupporterProfile.createSupporterProfile();
            /*
            String sTestInvalidJson = '{"":[{"Language":null,ergeg"Gender":"","GlobalPartner":""}]}';
            req.requestBody = Blob.valueof(sTestInvalidJson);
            RestContext.request = req;
            CreateSupporterProfile.createSupporterProfile();
            */
            Test.stopTest();
        }
        
    }
}