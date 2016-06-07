/******************************************************************************************************
Class Name         : DemoAutoComplete_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     DemoAutoComplete
Created By         : Jeevan D 
Created On         : 26-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
private class DemoAutoComplete_Test {
    static testMethod void verifyDemoAutoComplete () 
    {
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        // to create Region test data
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
            insert lstRegionTestData ;   
        // to create test data for Field office 
        List<string> lstFieldOfficeName = new List<String> (  ) ; 
        lstFieldOfficeName.add( 'testFieldOffice' ) ; 
        list<Account> lstFieldOfficeData = TestDataUtility.fieldofficeTestData( lstFieldOfficeName ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;   
            insert lstFieldOfficeData ;         
        // To Create Territory test data 
        List<string> lstTerritoryName = new List<String> (  ) ; 
        lstTerritoryName.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.territoryTestData( lstTerritoryName ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
            insert lstTerritoryTestData ; 
        //// to create Cluster test data
        List<string> Clusternames = new List<String> (  ) ; 
        Clusternames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( Clusternames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;    
        // Creating test data For oICPAccnt - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccnt = TestDataUtility.ICPTestData() ;
        oICPAccnt.Cluster__c = lstClusterTestData[0].ID ;    
            insert oICPAccnt ; 
            
        Test.StartTest() ; 
        
                DemoAutoComplete testDemoAutoComplete =  new DemoAutoComplete () ;
                List<Account> lstAccs = DemoAutoComplete.getAccounts('Account' , 'test' , 'ICP') ; 
                system.assert( lstAccs.Size () > 0 ) ; 
                testDemoAutoComplete.refresh() ;  
                testDemoAutoComplete.sAccName = 'test' ; 
                String Name = testDemoAutoComplete.sAccName ;
                testDemoAutoComplete.sAccountType = 'test' ; 
                String sAccountType = testDemoAutoComplete.sAccountType;
                testDemoAutoComplete.sObjName = 'test' ; 
                String sObjName = testDemoAutoComplete.sObjName ; 
                testDemoAutoComplete.accId = oICPAccnt .ID  ; 
                ID sccID = testDemoAutoComplete.accId ;
        Test.StopTest() ;
    }
}