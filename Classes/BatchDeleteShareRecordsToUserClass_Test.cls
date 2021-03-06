/******************************************************************************************************
Class Name         : BatchDeleteShareRecordsToUserClass_Test
Description        : This class contains unit tests for validating the behavior of Apex class: BatchDeleteShareRecordsToUserClass
Created By         : Danish Ahmed
Created On         : 30-Oct-2015 
*******************************************************************************************************/

@IsTest(SeeAllData = false)
public class BatchDeleteShareRecordsToUserClass_Test{
    static TestMethod void BatchDeleteShareRecordsToUserClassMethod(){
    User oUser = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser; 
        //User oUser = new User(Id = UserInfo.getUserId());
        System.debug('@@@%%%');
        System.runAs(oUser){
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
            List<sObject> lstOrgLevelSettingData = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
            List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
            List<sObject> lstPreventValidationRuleForTransitiont = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'PreventValidationRuleForTransition');
            List<Account_Prevent_Validation_on_Transition__c> lst = [Select id,createddate from Account_Prevent_Validation_on_Transition__c limit 10];
            System.debug('@@@lst'+lst[0].createddate);
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
            //// to create Cluster test data
            List<string> lstClusterNames = new List<String> (  ) ; 
            lstClusterNames.add( 'testCluster' ) ; 
            list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
            lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;
            List<Account> lstAccount=new List<Account>();
            // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstClusterTestData[0].ID ; 
             
            lstAccount.add(oICPAccount);
            Account oICPAccountNew = TestDataUtility.ICPTestData() ;
            oICPAccountNew.Cluster__c = lstClusterTestData[0].ID ;
            oICPAccountNew.ICP_Id__c ='TU156';
            lstAccount.add(oICPAccountNew);
            insert lstAccount;
            Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccount[0].ID ) ; 
            Insert oConTest ;
            list<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
            insert lstHouseHoldData ;
            // To insert HouseholdMemberTestData
            list<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
            insert lstHouseHoldMemberData;
            // to insert CDSPBenficiaryData
           
            Integer i=0;
            
            List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccount , lstHouseHoldData , lstHouseHoldMemberData ) ;
         
            insert lstCDSPAccounts;
            System.assertNotEquals(null,lstCDSPAccounts);
            System.assertEquals(2,lstCDSPAccounts.size());
            
             User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
             oUser2.ContactId = oConTest.Id ; 
             oUser2.PortalRole = 'Manager' ;
             oUser2.Is_Sharing_Completed__c = false ;
             insert oUser2;
             
             oUser2.isActive =  false;
             update oUser2;
             Set<Id> setUserId = new Set<Id>();
             setUserId.add(oUser2.Id);
             Set<Id> setUsersId = new Set<Id>();
             Test.StartTest();
              System.debug('@@@22lst'+lst[0].createddate);
             BatchDeleteShareRecordsToUserClass oBtachDelete = new BatchDeleteShareRecordsToUserClass(setUserId);
             Database.executeBatch(oBtachDelete);
             BatchDeleteShareRecordsToUserClass oBtachDeleteShare = new BatchDeleteShareRecordsToUserClass(setUsersId);
             Database.executeBatch(oBtachDeleteShare);
             Test.StopTest();
        }
    }

}