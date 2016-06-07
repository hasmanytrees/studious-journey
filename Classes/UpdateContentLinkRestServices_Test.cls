/******************************************************************************************************
Class Name         : UpdateContentLinkRestServices_Test
Description        : This class contains unit tests for validating the behavior of Apex class: UpdateContentLinkRestServices
Created By         : Nayana Prabhakar
Created On         : 24-March-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class UpdateContentLinkRestServices_Test{
    static testMethod void positiveTest() {
        List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        List<Id> feedContentLst = new List<Id>();
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        List<Content__c> lstContents = new List<Content__c>();    
        FeedItem oFeedItem = new FeedItem(); 
        user userPF = new User(Id = UserInfo.getUserId());
        user userCD = new User(Id = UserInfo.getUserId());
        System.runAs(UserPF) {
            JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('ContentLinkRequestProcess', '', false);
            insert oJsonProcess;
            Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('ContentLinkRequestGroup', 'Content__c');
            insert oFieldGroup;
            JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('ImageExport', oFieldGroup.Id, true, oJsonProcess.Id);
            insert oJsonStructure;
            List<Field_Group_Element__c> lstFGE = TestDataUtility.contentfieldGroupElementTestData(oFieldGroup.Id);
            insert lstFGE;
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
            insert lstContact;
            insert lstContent;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
         TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
            Id LeadId1 = lcr1.getAccountId();
            AccountId.add(LeadId1);
            
            lstAccountICP = TestDataUtility.ICPTestData(AccountId);
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            list<Account> lstAccountCDSP = new list<Account>();
            lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            insert lstAccountCDSP;
            
            lstContents = TestDataUtility.ContentTestData(lstAccountCDSP);
            insert lstContents;
            
            String sImage = 'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACAgMAAAAP2OW3AAAADFBMVEWxf2/KgHhvwEfedoetG6yMAAAADElEQVQI12NoYCgAAAH0APFbzVilAAAAAElFTkSuQmCC';
            Blob blobBody = EncodingUtil.base64Decode(sImage);
            oFeedItem.body = '[Welcome to test Knowledge]';
            oFeedItem.parentid = lstContents[0].Id; 
            oFeedItem.Type = Constants.FEED_ITEM_TYPE;
            oFeedItem.ContentFileName = 'image.jpg';
            oFeedItem.ContentData = blobBody;
            
            insert oFeedItem;
            
            String sRequestURI = System.URL.getSalesforceBaseUrl()+'/services/apexrest/UpdateContentLink';
            String sTestJson = '{"ImageExport":[ {"ContentID" : "'+lstContents[0].Id+'","ParentID" : "","CaptureDT" : "","DocumentType" : "","PerceptiveURI": "http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY","AttachmentID" : "'+oFeedItem.Id+'","ChildKey" : ""}]}';
            
            
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = sRequestURI;
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(sTestJson);
            RestContext.request = req;
            RestContext.response = res;
            UpdateContentLinkRestServices.updateContent();
            List<Content__c> lstNewContent = [Select Id, Content_Link__c from Content__c where id =: lstContents[0].Id];
            System.assertEquals('http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY',lstNewContent[0].Content_Link__c);
            
            String sTestJsonBlankContentId = '{"ImageExport":[ {"ContentID" : "","ParentID" : "","CaptureDT" : "","DocumentType" : "","PerceptiveURI": "http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY","AttachmentID" : "'+oFeedItem.Id+'","ChildKey" : ""}]}';
            req.requestBody = Blob.valueof(sTestJsonBlankContentId);
            RestContext.request = req;
            RestContext.response = res;
            UpdateContentLinkRestServices.updateContent();
            
            String sTestJsonBlankAttachmentId = '{"ImageExport":[ {"ContentID" : "'+lstContents[0].Id+'","ParentID" : "","CaptureDT" : "","DocumentType" : "","PerceptiveURI": "http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY","AttachmentID" : "","ChildKey" : ""}]}';
            req.requestBody = Blob.valueof(sTestJsonBlankAttachmentId);
            RestContext.request = req;
            RestContext.response = res;
            UpdateContentLinkRestServices.updateContent();
            
            String sTestJsonInvalidAttachmentId = '{"ImageExport":[ {"ContentID" : "'+lstContents[0].Id+'","ParentID" : "","CaptureDT" : "","DocumentType" : "","PerceptiveURI": "http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY","AttachmentID" : "12345678901234567890123456","ChildKey\'" : ""}]}';
            req.requestBody = Blob.valueof(sTestJsonInvalidAttachmentId);
            RestContext.request = req;
            RestContext.response = res;
            UpdateContentLinkRestServices.updateContent();
            
            String sTestJsonDeleteContent = '{"ImageExport":[ {"ContentID" : "'+lstContents[0].Id+'","ParentID" : "","CaptureDT" : "","DocumentType" : "","PerceptiveURI": "http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY","AttachmentID" : "'+oFeedItem.Id+'","ChildKey" : ""}]}';
            req.requestBody = Blob.valueof(sTestJsonDeleteContent);
            RestContext.request = req;
            RestContext.response = res;     
            delete lstContents;
            UpdateContentLinkRestServices.updateContent();
            
            String sTestInvalidJson = '{"ImageExport":[ {"ParentID" : "",,/"CaptureDT" : "","DocumentType" : "","PerceptiveURI": "http://hdc1107:8080/integrationserver/v1/document/321YZ29_0003MPYKW0000WT/page/321YZ29_0003MPYKW0000WY","ChildKey" : ""}]}';
            req.requestBody = Blob.valueof(sTestInvalidJson);
            RestContext.request = req;
            RestContext.response = res;
            UpdateContentLinkRestServices.updateContent();  
            
            Test.stopTest();
        }
    }
}