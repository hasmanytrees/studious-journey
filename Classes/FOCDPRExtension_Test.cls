/******************************************************************************************************
Class Name         : FOCDPRExtension
Description        : This class contains unit tests for validating the behavior of Apex class: FOCDPRExtension
Created By         : Jeevan D
Created On         : 19-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class FOCDPRExtension_Test {
        static testMethod void verifyFOCDPRExtension () 
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
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
        // to create test data for FO ADministrator
        list<String> lstFieldOfficeAdminNames = new List<String> () ; 
        lstFieldOfficeAdminNames.add( 'lstFOAdminTestData' ) ; 
        List<FO_Administration__c> lstFOAdminTestData = TestDataUtility.FOAdministratorBOTestData(lstFieldOfficeAdminNames) ; 
        lstFOAdminTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        lstFOAdminTestData[0].Age_Group__c = '0-2' ; 
            insert lstFOAdminTestData ;
        List<Account> lstICP = new List<Account>() ;
        lstICP.add(oICPAccnt) ; 
        // To insert HouseholdTestData
        list<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
        insert lstHouseHoldData ;
        // To insert HouseholdMemberTestData
        list<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
        insert lstHouseHoldMemberData;
        // to insert CDSPBenficiaryData
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstICP , lstHouseHoldData , lstHouseHoldMemberData ) ;
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '0-2' ; 
        lstCDSPAccounts[0].ICP__c = oICPAccnt.ID ;  
            insert lstCDSPAccounts ;
        Org_Level_Settings__c oOrgDefaults = Org_Level_Settings__c.getOrgDefaults();                
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( lstCDSPAccounts[0] ) ;
        Pagereference pg = new PageReference( '/apex/CDPRAssessment' ) ; 
        Test.setCurrentPage(pg) ;   
        ApexPages.currentPage().getParameters().put('id' , lstFieldOfficeData[0].ID );
        
        Test.StartTest() ;
            FOCDPRExtension testFOCDPRExt = new FOCDPRExtension( stdConAcc ) ;  
            testFOCDPRExt.getOutcome () ; 
            testFOCDPRExt.oCreateFOA.Age_Group__c  = '0-2' ;
            testFOCDPRExt.doSearch () ; 
            system.Assert( testFOCDPRExt.oCreateFOA.Age_Group__c  != NULL  ) ; 
            testFOCDPRExt.save() ;
            testFOCDPRExt.oAcc = lstCDSPAccounts[0] ;
            Account acc = testFOCDPRExt.oAcc ;  
            system.Assert( acc  != NULL  ) ; 
            testFOCDPRExt.lstFOA = lstFOAdminTestData ; 
            List<FO_Administration__c> lstFOATest = testFOCDPRExt.lstFOA ; 
            system.Assert( lstFOATest  != NULL  ) ;
            testFOCDPRExt.doSearch () ; 
        Test.StopTest() ; 
        
        }
}