/******************************************************************************************************
Class Name         : ContentDownloadExtension_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     ContentDownloadExtension
Created By         : Shaik Manzoor
Created On         : 27-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false)
private class ContentDownloadExtension_Test  {
    static testMethod void verifyContentDownloadExtension()  {
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        List<Content__c> lstContents = new List<Content__c>();    
        FeedItem oFeedItem = new FeedItem(); 
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.assertNotEquals(null,UserCD);
        System.runAs(UserPF) {
            List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
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
            lstContent[0].Content_Link__c = 'http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY';
            insert lstContact;
            insert lstContent;
            System.assertNotEquals(null,lstContent);
            Test.StartTest();
            System.debug('REsults: '+[Select Id from Content__c where Id=:lstContent[0].Id]);
            ApexPages.StandardController controller = new ApexPages.StandardController([Select Id,Content_Link__c from Content__c where Id=:lstContent[0].Id]);
            ContentDownloadExtension oContentDownloadExtension = new ContentDownloadExtension(controller);
            String sJSONString = '{"ContentList": [{"ContentLink" : "http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY"}]}';
            SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', sJSONString, null);
            HTTPRequest req = new HTTPRequest();
            req.setBody(sJSONString);
            SendRequestToNeuron.oHttpResponse = fakeResponse.respond(req);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            system.Assert( oContentDownloadExtension.sContentType != NULL ) ;
            oContentDownloadExtension.sImageData = '';
            oContentDownloadExtension.calloutForImageDwnld();
            Test.StopTest();
        }
    }
    
    static testMethod void negativeContentDownloadExtension()  {
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
            List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
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
            lstContent[0].Content_Link__c = 'http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY';
            lstContent[0].Content_Download_Type__c = null;
            insert lstContact;
            insert lstContent;
            Test.StartTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(lstContent[0]);
            ContentDownloadExtension oContentDownloadExtension = new ContentDownloadExtension(controller);
            system.Assert( oContentDownloadExtension.oContRecord.ID == lstContent[0].ID ) ; 
            system.Assert( oContentDownloadExtension.sContentType != NULL ) ;
            String sJSONString = '{"ContentList": [{"ContentLink" : "http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY"}]}';
            SingleRequestMock fakeResponse = new SingleRequestMock(0, 'FAIL', sJSONString, null);
            HTTPRequest req = new HTTPRequest();
            req.setBody(sJSONString);
            SendRequestToNeuron.oHttpResponse = fakeResponse.respond(req);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            oContentDownloadExtension.calloutForImageDwnld();
            Test.StopTest();
        }
    }
    
    static testMethod void negativeContentDownloadExtension2()  {
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
            List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
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
            lstContent[0].Content_Link__c = null;
            lstContent[0].Content_Download_Type__c = null;
            insert lstContact;
            insert lstContent;
            Test.StartTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(lstContent[0]);
            ContentDownloadExtension oContentDownloadExtension = new ContentDownloadExtension(controller);
            system.Assert( oContentDownloadExtension.oContRecord.ID == lstContent[0].ID ) ; 
            system.Assert( oContentDownloadExtension.sContentType != NULL ) ;
            String sJSONString = '{"ContentList": [{"ContentLink" : "http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY"}]}';
            SingleRequestMock fakeResponse = new SingleRequestMock(0, 'FAIL', sJSONString, null);
            HTTPRequest req = new HTTPRequest();
            req.setBody(sJSONString);
            SendRequestToNeuron.oHttpResponse = fakeResponse.respond(req);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            oContentDownloadExtension.calloutForImageDwnld();
            Test.StopTest();
        }
    }   
    static testMethod void ContentDownloadNegativeJsonExtension()  {
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        List<Content__c> lstContents = new List<Content__c>();    
        FeedItem oFeedItem = new FeedItem(); 
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.assertNotEquals(null,UserCD);
        System.runAs(UserPF) {
              List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBNegativeTesting');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
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
            lstContent[0].Content_Link__c = 'http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY';
            insert lstContact;
            insert lstContent;
            System.assertNotEquals(null,lstContent);
            Test.StartTest();
            System.debug('REsults: '+[Select Id from Content__c where Id=:lstContent[0].Id]);
            ApexPages.StandardController controller = new ApexPages.StandardController([Select Id,Content_Link__c from Content__c where Id=:lstContent[0].Id]);
            ContentDownloadExtension oContentDownloadExtension = new ContentDownloadExtension(controller);
            String sJSONString = '{"ContentList": [{"ContentLink" : "http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY"}]}';
            SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', sJSONString, null);
            HTTPRequest req = new HTTPRequest();
            req.setBody(sJSONString);
            SendRequestToNeuron.oHttpResponse = fakeResponse.respond(req);
                       oContentDownloadExtension.sImageData = '';
            oContentDownloadExtension.calloutForImageDwnld();
            Test.StopTest();
        }
    } 
}