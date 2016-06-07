/******************************************************************************************************
Class Name         : AddressHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: AddressHandler
                     and AddressTrigger
Created By         : Jeevan D
Created On         : 14-09-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class AddressHandler_Test {
    
    @IsTest static  void AddressTest(){ 
         
          
        User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser1;  
            
        System.RunAs( oUser1 ) {     
        
        // to create Region test data
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
            System.assertNotEquals(null,oConTest.AccountID);
            
         Profile oProfile = [select id from profile where name =: Constants.ICP_FULL_ACCESS_PROFILE LIMIT 1]; 
         
         User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = oConTest.Id ; 
         oUser2.PortalRole = 'Manager' ;
            insert oUser2;
        
        test.starttest();
            Address__c oAddressTestData = TestDataUtility.addressTestData ( oICPAccount.ID ) ;
            oAddressTestData.Lead__c = NULL ; 
            oAddressTestData.Account__c = oICPAccount.ID ;
                insert oAddressTestData ;
               System.assertNotEquals(null,oAddressTestData);
                
            oAddressTestData.Account__c = lstFieldOfficeData[0].ID ;     
                update oAddressTestData ;
               System.assertEquals(lstFieldOfficeData[0].ID, oAddressTestData.Account__c); 
            
        test.stoptest(); 
        }
             
                    
    }   

    
}