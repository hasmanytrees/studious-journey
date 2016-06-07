/******************************************************************************************************
Class Name         : BatchCaseArchive_Test
Description        : This class contains unit tests for validating the behavior of Apex class: AccountHandler
                     and AccountTrigger
Created By         : Jeevan D
Created On         : 27-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class BatchCaseArchive_Test {
   static testMethod void positiveTest() {
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
        list<Case> lstCaseTestData = TestDataUtility.CaseTestData (lstFieldOfficeData ) ; 
            insert lstCaseTestData ;
        System.assert(lstCaseTestData[0].id != NULL);
        Database.BatchableContext BC ;     
        Test.StartTest() ;        
        BatchCaseArchive testBatchCaseArchive = new BatchCaseArchive () ;
        Database.executeBatch(testBatchCaseArchive);
        testBatchCaseArchive.execute( BC , lstCaseTestData ) ;
        system.Assert( testBatchCaseArchive != NULL ) ;
        Test.StopTest() ;
   }
}