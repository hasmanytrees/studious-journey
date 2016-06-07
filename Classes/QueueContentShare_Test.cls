/******************************************************************************************************
Class Name         : QueueContentShare_Test
Description        : This class contains unit tests for validating the behavior of class: QueueContentShare
                     
Created By         : Sfurti Pandey
Created On         : 02-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest(SeeAllData=false)
private class QueueContentShare_Test {
    @testSetup static void setup() {
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
        insert lstRegionTestData ;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;  
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
        // to create Cluster test data
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
        insert lstClusterTestData ;
        List<Account> lstAccount = new List<Account>();
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ;              
        lstAccount.add(oICPAccount);
        Account oICPAccountNew = TestDataUtility.ICPTestData() ;
        oICPAccountNew.Cluster__c = lstClusterTestData[0].ID ;
        oICPAccountNew.ICP_Id__c ='TU156';
        lstAccount.add(oICPAccountNew);
        insert lstAccount;
        Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountId = lstAccount[0].Id); 
        Insert oConTest; 
        System.assertNotEquals(null,oConTest.id);   
        list<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
        insert lstHouseHoldData ;
        System.assertNotEquals(null,lstHouseHoldData);
        // To insert HouseholdMemberTestData
        list<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
        insert lstHouseHoldMemberData;
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccount , lstHouseHoldData , lstHouseHoldMemberData);
        insert lstCDSPAccounts;
        System.assertNotEquals(null,lstCDSPAccounts);
                  
    }
    
    static TestMethod void QueueContentShareMethod1() {
        User oUser = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser;
        
        System.runAs(oUser){
            Contact oContact = [Select Id from Contact Limit 1];
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = oContact.Id ; 
            oUser2.PortalRole = 'Manager' ;
            oUser2.Is_Sharing_Completed__c = false ;
            insert oUser2;
            Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME);
            List<Account> lstCDSPAccount = [Select id from Account where recordTypeId =: cdspRecTypeId Limit 2];
            List<Content__c> lstContentTestData = new List<Content__c>();
            List<Content__c> lstContentToinsert = new List<Content__c>();
            for(Integer i=0; i < 5; i++){
                lstContentTestData = TestDataUtility.ContentTestData(lstCDSPAccount);
                lstContentToinsert.addAll(lstContentTestData);
            }             
            insert lstContentToinsert;
            List<Content__Share> lstContentShare=new list<Content__Share>();
            for(Content__c oContent: lstContentToinsert){
                Content__Share oContentShare = new Content__Share();
                oContentShare.parentid= oContent.id;
                oContentShare.userorgroupid = oUser2.id;
                oContentShare.accesslevel = 'Edit';
                oContentShare.RowCause = Constants.APEX_BASED_SHARING;
                lstContentShare.add(oContentShare);
            }
            
            Test.startTest();
            QueueContentShare oQueueContentShare = new QueueContentShare(oUser2,lstContentShare,50);
            System.enqueueJob(oQueueContentShare);
            Test.stopTest();
            List<Content__Share> lstContentShareInserted = [Select Id from Content__Share where UserOrGroupId =: oUser2.Id And RowCause =: Constants.APEX_BASED_SHARING And ParentId IN: lstContentToinsert];
            System.assertEquals(lstContentToinsert.size(), lstContentShareInserted.size());
        }        
             
    }
    
    static TestMethod void QueueContentShareMethod2() {
        User oUser = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser;
        
        System.runAs(oUser){
            Contact oContact = [Select Id from Contact Limit 1];
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = oContact.Id ; 
            oUser2.PortalRole = 'Manager' ;
            oUser2.Is_Sharing_Completed__c = false ;
            insert oUser2;
            Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME);
            List<Account> lstCDSPAccount = [Select id from Account where recordTypeId =: cdspRecTypeId Limit 2];
            List<Content__c> lstContentTestData = new List<Content__c>();
            List<Content__c> lstContentToinsert = new List<Content__c>();
            for(Integer i=0; i < 10; i++){
                lstContentTestData = TestDataUtility.ContentTestData(lstCDSPAccount);
                lstContentToinsert.addAll(lstContentTestData);
            }             
            insert lstContentToinsert;
            List<Content__Share> lstContentShare=new list<Content__Share>();
            for(Content__c oContent: lstContentToinsert){
                Content__Share oContentShare = new Content__Share();
                oContentShare.parentid= oContent.id;
                oContentShare.userorgroupid = oUser2.id;
                oContentShare.accesslevel = 'Edit';
                oContentShare.RowCause = Constants.APEX_BASED_SHARING;
                lstContentShare.add(oContentShare);
            }   
                     
            Test.startTest();
            QueueContentShare oQueueContentShare = new QueueContentShare(oUser2,lstContentShare,10);
            System.enqueueJob(oQueueContentShare);
            Test.stopTest();
            List<Content__Share> lstContentShareInserted = [Select Id from Content__Share where UserOrGroupId =: oUser2.Id And RowCause =: Constants.APEX_BASED_SHARING And ParentId IN: lstContentToinsert];
            System.assertEquals(20, lstContentShareInserted.size());
        }        
             
    }
}