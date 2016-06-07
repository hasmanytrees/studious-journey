/******************************************************************************************************
Class Name         : BatchRetryMechanism_Test
Description        : This class contains unit tests for validating the behavior of Apex class: BatchRetryMechanism
Created By         : Sfurti Pandey
Created On         : 26-Oct-2015 
*******************************************************************************************************/
@IsTest(SeeAllData=false) 
public class BatchRetryMechanism_Test 
{
    
    static testMethod void verifyBatchRetryMechanism1() 
    {
         List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
         List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
         List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
         List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
         Test.StartTest();
         Error_Log__c oErrorLog=new  Error_Log__c();
         oErrorLog.Error_Body__c='Testing Error';
         oErrorLog.Error_Occurred_at_Line_Number__c='52';
         oErrorLog.Error_Occurred_in_Class__c='SendBenefInfoToUS';
         oErrorLog.Error_Occurred_in_Method__c='sendBenefInfo';
         oErrorLog.HTTP_Verb__c='';
         oErrorLog.Logged_In_User__c='Sfurti Pandey';
         oErrorLog.Number_of_times_retried__c=1;
         oErrorLog.Object__c='Account';
         oErrorLog.Record_Id__c='AEWWRED00001';
         oErrorLog.Request_Body__c='{"BeneficiaryList" :[{"FirstName":"Danish","LastName":"Ahmed","LocalBeneficiaryId":"ET2193783","BeneficiaryRecordID":"001q000000NGxzQAAT","CompassID":"363839","SponsorshipStatus":"Sponsored","Birthdate":"2011-10-09 00:00:00","Country":"","FieldOffice":"Ethiopia","Gender":"Male","CorrespondenceLanguage":"English","ICP":"Little Helping Hands CDC","BeneficiaryStatus":"Active","SupporterGlobalPartner":""}]}';
         oErrorLog.Response_Body__c='TestingJSONResponse';
         oErrorLog.Response_Message__c='Source Error';
         oErrorLog.Source_System__c='SFDC-USA';
          oErrorLog.ESB_URL__c='https://api2.compassion.com/test/us/v2/communications?api_key=cnmv58dutyhwex8z2nmud4fb';
         oErrorLog.Stack_Trace__c='TestingJSONRequest';
         oErrorLog.Status__c='Awaiting Retry';
         oErrorLog.Status_Code__c=404;
         oErrorLog.Type__c='Inbound';
         oErrorLog.User_Id__c='45feert66';
         insert oErrorLog;
         System.assertNotEquals(null,oErrorLog.id);
         String jsonBLEString = '{"BeneficiaryList" :[{"FirstName":"Danish","LastName":"Ahmed","LocalBeneficiaryId":"ET2193783","BeneficiaryRecordID":"001q000000NGxzQAAT","CompassID":"363839","SponsorshipStatus":"Sponsored","Birthdate":"2011-10-09 00:00:00","Country":"","FieldOffice":"Ethiopia","Gender":"Male","CorrespondenceLanguage":"English","ICP":"Little Helping Hands CDC","BeneficiaryStatus":"Active","SupporterGlobalPartner":""}]}';
             HTTPRequest req = new HTTPRequest();
             req.setBody(jsonBLEString);
          
        
        
        
        
          JSONParserForToken oJsonParserToken= JSONParserForToken.getJSONParserForToken();
          system.debug('@@@@@@@@oJsonParserToken'+oJsonParserToken);
         BatchRetryMechanism brm = new BatchRetryMechanism();
         //brm.mapResponse.values()[0].setStatusCode(200);
         Database.executeBatch(brm);
         Test.StopTest();
         
         
    }
     static testMethod void verifyBatchRetryMechanism2() 
    {
         
         List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
         List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
         List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
          Test.StartTest();
         Error_Log__c oErrorLog=new  Error_Log__c();
         oErrorLog.Error_Body__c='Testing Error';
         oErrorLog.Error_Occurred_at_Line_Number__c='52';
         oErrorLog.Error_Occurred_in_Class__c='SendBenefInfoToUS';
         oErrorLog.Error_Occurred_in_Method__c='sendBenefInfo';
         oErrorLog.HTTP_Verb__c='';
         oErrorLog.Logged_In_User__c='Sfurti Pandey';
         oErrorLog.Number_of_times_retried__c=0;
         oErrorLog.Object__c='Account';
         oErrorLog.Record_Id__c='AEWWRED00001';
         oErrorLog.Request_Body__c='{"BeneficiaryList" :[{"FirstName":"Danish","LastName":"Ahmed","LocalBeneficiaryId":"ET2193783","BeneficiaryRecordID":"001q000000NGxzQAAT","CompassID":"363839","SponsorshipStatus":"Sponsored","Birthdate":"2011-10-09 00:00:00","Country":"","FieldOffice":"Ethiopia","Gender":"Male","CorrespondenceLanguage":"English","ICP":"Little Helping Hands CDC","BeneficiaryStatus":"Active","SupporterGlobalPartner":""}]}';
         oErrorLog.Response_Body__c='TestingJSONResponse';
         oErrorLog.Response_Message__c='Source Error';
         oErrorLog.Source_System__c='SFDC-USA';
          //oErrorLog.ESB_URL__c='https://api2.compassion.com/test/us/v2/communications?api_key=cnmv58dutyhwex8z2nmud4fb';
         oErrorLog.Stack_Trace__c='TestingJSONRequest';
         oErrorLog.Status__c='Awaiting Retry';
         oErrorLog.Status_Code__c=200;
         oErrorLog.Type__c='Inbound';
         oErrorLog.User_Id__c='45feert66';
         insert oErrorLog;
         System.assertNotEquals(null,oErrorLog.id);
         //String sTestJson = '{"ImageExport":[ {"ParentID" : "123456789012345678","CaptureDT" : "2014-12-10 00:00:00","DocumentType" : "Beneficiary Lifecycle Web","PerceptiveURI": "","ChildKey" : ""}]}';
        //sRequestURI = System.URL.getSalesforceBaseUrl()+'/services/apexrest/ExportAttachment';
        
        
        
          JSONParserForToken oJsonParserToken= JSONParserForToken.getJSONParserForToken();
          system.debug('@@@@@@@@oJsonParserToken'+oJsonParserToken);
         BatchRetryMechanism brm = new BatchRetryMechanism();
         Test.StopTest();
         Database.executeBatch(brm);
        
         
         
    }
    static testMethod void verifyBatchRetryMechanism3() 
    {
         List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
         List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
         List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
         List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
         Test.StartTest();
         Error_Log__c oErrorLog=new  Error_Log__c();
         oErrorLog.Error_Body__c='Testing Error';
         oErrorLog.Error_Occurred_at_Line_Number__c='52';
         oErrorLog.Error_Occurred_in_Class__c='SendBenefInfoToUS';
         oErrorLog.Error_Occurred_in_Method__c='sendBenefInfo';
         oErrorLog.HTTP_Verb__c='';
         oErrorLog.Logged_In_User__c='Sfurti Pandey';
         oErrorLog.Number_of_times_retried__c=null;
         oErrorLog.Object__c='Account';
         oErrorLog.Record_Id__c='AEWWRED00001';
         oErrorLog.Request_Body__c='falied Json';
         oErrorLog.Response_Body__c='';
         oErrorLog.Response_Message__c='';
         oErrorLog.Source_System__c='SFDC-USA';
          oErrorLog.ESB_URL__c='https://api2.compassion.com/test/us/v2/communications?api_key=cnmv58dutyhwex8z2nmud4fb';
         oErrorLog.Stack_Trace__c='TestingJSONRequest';
         oErrorLog.Status__c='Awaiting Retry';
         oErrorLog.Status_Code__c=201;
         oErrorLog.Type__c='Inbound';
         oErrorLog.User_Id__c='45feert66';
         insert oErrorLog;
         System.assertNotEquals(null,oErrorLog.id);
         TriggerContextUtility.bRetryMechanism=false;
         
         //String sTestJson = '{"ImageExport":[ {"ParentID" : "123456789012345678","CaptureDT" : "2014-12-10 00:00:00","DocumentType" : "Beneficiary Lifecycle Web","PerceptiveURI": "","ChildKey" : ""}]}';
        //sRequestURI = System.URL.getSalesforceBaseUrl()+'/services/apexrest/ExportAttachment';
        SingleRequestMock fakeResponse = new SingleRequestMock(404, 'OK', '', null);
         Test.setMock(HttpCalloutMock.class, fakeResponse);
         //BatchRetryMechanism.mapResponse[0].values().setStatusCode() = 200;
        
          
         
         BatchRetryMechanism brm = new BatchRetryMechanism();
         HttpResponse oHttpres= new httpresponse();
       //  brm.mapResponse.values()[0].setStatusCode(200);
        
         
         
         
         Database.executeBatch(brm,2);
         Test.StopTest();
         
         
    }
}