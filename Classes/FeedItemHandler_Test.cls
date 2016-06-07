/******************************************************************************************************
Class Name         : FeedItemHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     FilterListCompController
Created By         : Jeevan D
Created On         : 27-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false)
private class FeedItemHandler_Test 
{
    static testMethod void verifyFeedItemHandler() 
    {   
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('ContentLinkRequestProcess', '', false);
        insert oJsonProcess;        
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('ContentLinkRequestGroup', 'Content__c');
        insert oFieldGroup;
        JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('ImageExport', oFieldGroup.Id, true, oJsonProcess.Id);
        insert oJsonStructure;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.contentfieldGroupElementTestData(oFieldGroup.Id);
        insert lstFGE;
        List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
            insert lstRegionTestData ;  
        // to create test data for Field office 
        List<string> lstFieldOfficeNames = new List<String> (  ) ; 
        lstFieldOfficeNames.add( 'testFieldOffice' ) ; 
        list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;   
            insert lstFieldOfficeData ; 
        // to move below test data to utility    
        Content__c oContent = new Content__c ( Field_Office__c = lstFieldOfficeData[0].ID,Content_Type__c = 'test' ) ; 
        insert oContent ;
       
        Blob bBody=[Select Name, ContentType, Body From StaticResource where name='UpdateContentLinkTest'].body;
        FeedItem oFeedItem = new FeedItem();
        oFeedItem.body = '[Welcome to test Knowledge]';
        oFeedItem.parentid = oContent.ID; 
        oFeedItem.Type = Constants.FEED_ITEM_TYPE;
        oFeedItem.ContentFileName = 'image.jpg';
        oFeedItem.ContentData = bBody;
        //Insert oFeedItem;
        Test.startTest();
        
         SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"ImageExport":{"ContentID": "a06K000000BHlyWIAT","ParentID": "001K0000018J7p7IAC","CaptureDT": "2015-02-26 15:31:26","DocumentType": "Photo - BeneficiaryHeadshot","PerceptiveURI": "","AttachmentID": "0D5K000000Sbo2aKAB","ChildKey": ""}}',null);
         HTTPRequest req = new HTTPRequest();
         req.setBody('{"ImageExport":{"ContentID": "a06K000000BHlyWIAT","ParentID": "001K0000018J7p7IAC","CaptureDT": "2015-02-26 15:31:26","DocumentType": "Photo - BeneficiaryHeadshot","PerceptiveURI": "","AttachmentID": "0D5K000000Sbo2aKAB","ChildKey": ""}}');
         SendRequestToNeuron.oHttpResponse = fakeResponse.respond(req);
         Test.setMock(HttpCalloutMock.class, fakeResponse);
         System.assert( SendRequestToNeuron.oHttpResponse.getBody () != NULL ) ; 
         system.debug('@@fakeResponse' +fakeResponse);
         Test.StopTest() ;
         
         
         
         
    }
}