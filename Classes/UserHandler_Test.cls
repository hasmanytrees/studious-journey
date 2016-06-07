/******************************************************************************************************
Class Name         : UserHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: UserHandler
                     and UserTrigger
Created By         : Sudipta Nayak
Created On         : 29-Apr-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest(SeeAllData=false)
private class UserHandler_Test {
    static TestMethod void userHandlerTestMethod() {
        List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
        Id userId = Org_Level_Settings__c.getOrgDefaults().One_Login_User_Id__c;
        User OneLoginUser = [ select Id from User where Id = :userId];
        System.runAs(OneLoginUser) {
            User testUser = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
            insert testUser;
            testUser.TimeZoneSidKey = 'Asia/Kolkata';
            testUser.LocaleSidKey  = 'en_IN';
            update testUser;
            User oUser = [Select id,TimeZoneSidKey,LocaleSidKey from User where id =: testUser.Id Limit 1];
            System.assert(oUser.TimeZoneSidKey == 'America/Los_Angeles');
            System.assert(oUser.LocaleSidKey == 'en_US');
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
        // To Create Territory test data 
        List<string> lstTerritoryNames = new List<String> (  ) ; 
        lstTerritoryNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
            insert lstTerritoryTestData ;  
        //// to create Cluster test data
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ; 
            insert oICPAccount ; 
         Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID ) ; 
            Insert oConTest ;
            Contact oConTestnew = new Contact (LastName = 'test contactnew', FirstName = 'test' , AccountID = oICPAccount.ID ) ; 
            Insert oConTestnew ;
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = oConTest.Id ; 
         oUser2.PortalRole = 'Manager' ;
            insert oUser2;
            User usr=[select Account.Field_Office__c ,Contact.Name,Account.Name from User where id=:oUser2.id];
            system.debug('########usracc'+usr.Account.Name);
             system.debug('########usrcon'+usr.Contact.Name);
            
             system.debug('########usr.Account.Field_office__c'+usr.Account.Field_office__c);
             Test.StartTest();
            User oUser3 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser3.ContactId = oConTestnew.Id ; 
         oUser3.PortalRole = 'Manager' ;
         
            insert oUser3;
            Test.Stoptest();
            system.assertnotequals(null,oUser3.id);
            
       
        }
    }
    
    static TestMethod void userHandlerPortalSharingTestMethod() {
        List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
        Id userId = Org_Level_Settings__c.getOrgDefaults().One_Login_User_Id__c;
        User OneLoginUser = [ select Id from User where Id = :userId];
        System.runAs(OneLoginUser) {
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
        // To Create Territory test data 
        List<string> lstTerritoryNames = new List<String> (  ) ; 
        lstTerritoryNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
            insert lstTerritoryTestData ;  
        //// to create Cluster test data
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ; 
            insert oICPAccount ; 
         Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID ) ; 
            Insert oConTest ;
            System.assertNotEquals(null,oConTest.id);
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = oConTest.Id ; 
         oUser2.PortalRole = 'Manager' ;
            insert oUser2;
            System.assertEquals('Manager',oUser2.PortalRole);
            }
            }
      static TestMethod void userHandlerPortalTestMethod() {
        List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
        Id userId = Org_Level_Settings__c.getOrgDefaults().One_Login_User_Id__c;
        User OneLoginUser = [ select Id from User where Id = :userId];
        System.runAs(OneLoginUser) {
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
        // To Create Territory test data 
        List<string> lstTerritoryNames = new List<String> (  ) ; 
        lstTerritoryNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
            insert lstTerritoryTestData ;  
        //// to create Cluster test data
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ; 
            insert oICPAccount ; 
         Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID ) ; 
            Insert oConTest ;
             System.assertNotEquals(null,oConTest.id);
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = oConTest.Id ; 
         oUser2.PortalRole = 'Manager' ;
         
            insert oUser2;
            oUser2.Is_Sharing_Completed__c = false ;
            update oUser2;
            System.assertEquals('Manager',oUser2.PortalRole);
            }
            }
            static TestMethod void userHandlerPortalNotSharedTestMethod() {
        List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
        Id userId = Org_Level_Settings__c.getOrgDefaults().One_Login_User_Id__c;
        User OneLoginUser = [ select Id from User where Id = :userId];
        System.runAs(OneLoginUser) {
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
        // To Create Territory test data 
        List<string> lstTerritoryNames = new List<String> (  ) ; 
        lstTerritoryNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
            insert lstTerritoryTestData ;  
        //// to create Cluster test data
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ; 
            insert oICPAccount ; 
         Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID ) ; 
            Insert oConTest ;
           
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = oConTest.Id ; 
         oUser2.PortalRole = 'Manager' ;
         
            insert oUser2;
            Test.StartTest();
           
            
            oUser2.Is_Sharing_Completed__c = true ;
            oUser2.isActive=False;
            
            update oUser2;
            system.assertnotequals(null,oUser2.id);
            Test.StopTest();
            
            }
            }
            static TestMethod void userHandlerTestGroupMethod() {
              User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser1;  
            
        System.RunAs( oUser1 ) {   
        List<string> lstRegionNames = new List<String> () ; 
             lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
            insert lstRegionTestData ;  
        // to create test data for Field office 
        List<string> lstFieldOfficeNames = new List<String> () ; 
        lstFieldOfficeNames.add( 'El Salvador' ) ; 
        list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;   
            insert lstFieldOfficeData ;      
        // To Create Territory test data
        List<string> lstTerritoryNames = new List<String> () ; 
        List<Group> lstGroup = [Select id, Name from Group where Name Like : Constants.ALL_PARTNER_COMMUNITY_USERS];
        system.debug('@@@@@@@lstGroup'+lstGroup);
        lstTerritoryNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
            insert lstTerritoryTestData ;  
        //// to create Cluster test data
        List<string> lstClusterNames = new List<String> () ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ; 
            insert oICPAccount ; 
         Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID ) ; 
            Insert oConTest ;
            Group testGroup = new Group(Name='testField'+Constants.ALL_PARTNER_COMMUNITY_USERS);
          insert testGroup;
            Contact oConTestnew = new Contact (LastName = 'test contactnew', FirstName = 'test' , AccountID = oICPAccount.ID ) ; 
            Insert oConTestnew ;
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = oConTest.Id ; 
         oUser2.PortalRole = 'Manager' ;
            insert oUser2;
            User usr=[select Account.Field_Office__c ,Contact.Name,Account.Name from User where id=:oUser2.id];
            system.debug('########usracc'+usr.Account.Name);
             system.debug('########usrcon'+usr.Contact.Name);
            
             system.debug('########usr.Account.Field_office__c'+usr.Account.Field_office__c);
             Test.StartTest();
            User oUser3 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser3.ContactId = oConTestnew.Id ; 
         oUser3.PortalRole = 'Manager' ;
         
         
            insert oUser3;
            System.assertnotequals(null,oUser3.id);
            Test.Stoptest();
            }
            }
             

}