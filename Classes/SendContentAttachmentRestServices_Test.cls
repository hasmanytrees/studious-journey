/******************************************************************************************************
Class Name         : SendContentAttachmentRestServices_Test
Description        : This class contains unit tests for validating the behavior of Apex class: SendContentAttachmentRestServices
Created By         : Danish Ahmed
Created On         : 26-March-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@isTest(SeeAllData=false) 
private class SendContentAttachmentRestServices_Test {

    static testMethod void positiveTest() {
        List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        List<Content__c> lstContents = new List<Content__c>();        
        FeedItem oFeedItem = new FeedItem();
        user userPF = new User(Id = UserInfo.getUserId());
        user userCD = new User(Id = UserInfo.getUserId());
        String sImage = '';
        System.runAs(userPF) {
            JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('ContentLinkRequestProcess', '', false);
            insert oJsonProcess;
            Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('ContentLinkRequestGroup', 'Content__c');
            insert oFieldGroup;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            AccountId.add(LeadId);
            Database.LeadConvert lc1 = new Database.LeadConvert();
            lc1.setLeadId(lstLead[1].id);
            lc1.setDoNotCreateOpportunity(true);
            lc1.setConvertedStatus('Converted');
            Test.startTest();
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
        
        sImage = 'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACAgMAAAAP2OW3AAAADFBMVEWxf2/KgHhvwEfedoetG6yMAAAADElEQVQI12NoYCgAAAH0APFbzVilAAAAAElFTkSuQmCC';
        Blob blobBody = EncodingUtil.base64Decode(sImage);
        oFeedItem.body = '[Welcome to test Knowledge]';
        oFeedItem.parentid = lstContents[0].Id; 
        oFeedItem.Type = Constants.FEED_ITEM_TYPE;
        oFeedItem.ContentFileName = 'image.jpg';
        oFeedItem.ContentData = blobBody;
        insert oFeedItem;
        }
        String sTestJson = '{"ImageExport":[ {"ContentID" : "'+lstContents[0].Id+'","ParentID" : "123456789012345678","CaptureDT" : "2014-12-10 00:00:00","DocumentType" : "Beneficiary Lifecycle Web","PerceptiveURI": "","AttachmentID" : "'+oFeedItem.Id+'","ChildKey" : ""}]}';
        String sRequestURI = System.URL.getSalesforceBaseUrl()+'/services/apexrest/ExportAttachment';
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = sRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(sTestJson);
        RestContext.request = req;
        RestContext.response = res;
        SendContentAttachmentRestServices.sendContentAttachment();
        System.assertEquals(sImage,EncodingUtil.base64Encode(RestContext.response.responsebody));
        
        String sTestJsonInvalidContentId = '{"ImageExport":[ {"ContentID" : "","ParentID" : "123456789012345678","CaptureDT" : "2014-12-10 00:00:00","DocumentType" : "Beneficiary Lifecycle Web","PerceptiveURI": "","AttachmentID" : "'+oFeedItem.Id+'","ChildKey" : ""}]}';
        req.requestBody = Blob.valueof(sTestJsonInvalidContentId);
        RestContext.request = req;
        RestContext.response = res;
        SendContentAttachmentRestServices.sendContentAttachment();
        
        
        String sTestJsonInvalidAttachmentId = '{"ImageExport":[ {"ContentID" : "'+lstContents[0].Id+'","ParentID" : "123456789012345678","CaptureDT" : "2014-12-10 00:00:00","DocumentType" : "Beneficiary Lifecycle Web","PerceptiveURI": "","AttachmentID" : "","ChildKey" : ""}]}';
        req.requestBody = Blob.valueof(sTestJsonInvalidAttachmentId);
        RestContext.request = req;
        RestContext.response = res;
        SendContentAttachmentRestServices.sendContentAttachment();
        
        String sTestInvalidJson = '{"ImageExport":[ {"ContentID" : "'+lstContents[0].Id+'",,/,"ParentID" : "123456789012345678","CaptureDT" : "2014-12-10 00:00:00","DocumentType" : "Beneficiary Lifecycle Web","PerceptiveURI": "","AttachmentID" : "","ChildKey" : ""}]}';
        req.requestBody = Blob.valueof(sTestInvalidJson);
        RestContext.request = req;
        RestContext.response = res;
        SendContentAttachmentRestServices.sendContentAttachment();
        
        String sTestInvalidJson2 = '{"ImageExport":[ {"ContentID" : "&%&%&*%&%&%@@@'+',"ParentID" : "123456789012345678","CaptureDT" : "2014-12-10 00:00:00","DocumentType" : "Beneficiary Lifecycle Web","PerceptiveURI": "","AttachmentID" : "&%&%&*%&%&%&%&%&%","ChildKey" : ""}]}';
        req.requestBody = Blob.valueof(sTestInvalidJson2);
        RestContext.request = req;
        RestContext.response = res;
        SendContentAttachmentRestServices.sendContentAttachment();
        
        String sTestJsonDeleteFeed = '{"ImageExport":[ {"ContentID" : "'+lstContents[0].Id+'","ParentID" : "123456789012345678","CaptureDT" : "2014-12-10 00:00:00","DocumentType" : "Beneficiary Lifecycle Web","PerceptiveURI": "","AttachmentID" : "'+oFeedItem.Id+'","ChildKey" : ""}]}';
        req.requestBody = Blob.valueof(sTestJsonDeleteFeed);
        RestContext.request = req;
        RestContext.response = res;
        delete oFeedItem;
        SendContentAttachmentRestServices.sendContentAttachment();
        
        Test.stopTest();
        
    }
}