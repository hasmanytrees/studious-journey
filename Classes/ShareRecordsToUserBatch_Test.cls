/******************************************************************************************************
Class Name         : ShareRecordsToUserBatch_Test
Description        : This class contains unit tests for validating the behavior of batch class: ShareRecordsToUserBatch
                     
Created By         : Sfurti Pandey
Created On         : 22-Sept-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest(SeeAllData=false)
private class ShareRecordsToUserBatch_Test {
    static TestMethod void ShareRecordsToUserBatchMethod() {
        User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser1;  
            
        System.RunAs( oUser1 ) {   
         String sQuery = 'Select ProfileId ,Id,AccountId,'+
                'Account.Field_Office__c,Account.Cluster__c,Account.Cluster__r.Territory__c,'+
                'Account.Cluster__r.Territory__r.Field_Office__c,Is_Sharing_Completed__c'+
                ' from User where Is_Sharing_Completed__c = false AND IsActive = true And (Profile.Name =\''+
                Constants.ICP_FULL_ACCESS_PROFILE+'\' OR Profile.Name =\''+
                Constants.ICP_READ_ONLY_PROFILE+'\' OR Profile.Name =\''+
                Constants.ICP_PROGRAM_IMPLEMENTER_PROFILE+'\')';
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
            System.assertNotEquals(null,oConTest.id);
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
            List<User> lstUser=new List<User>();
                

                    User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
                    oUser2.ContactId = oConTest.Id ; 
                    oUser2.PortalRole = 'Manager' ;
                    oUser2.Is_Sharing_Completed__c = false ;
                    insert oUser2;
                    
                
            
             Test.startTest();
                 ShareRecordsToUserBatch c = new ShareRecordsToUserBatch(New set<id>());
                 Database.executeBatch(c);
              Test.stopTest();
              //Integer i = [SELECT COUNT() FROM Merchandise__c];
              //System.assertEquals(i, 9);

            
             
        }
    }
}