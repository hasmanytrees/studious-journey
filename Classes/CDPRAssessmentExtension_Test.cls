/******************************************************************************************************
Class Name         : CDPRAssessmentExtension_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
Created By         : Jeevan D 
Created On         : 16-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
private class CDPRAssessmentExtension_Test 
{
    static testMethod void verifyCDPRAssessmentExtension () 
    {
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstants = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData');
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
        insert oFieldGroup;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup.Id);
        insert lstFGE;
        
        // to create Region test data
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
         TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
        // to create test data for FO ADministrator
        list<String> lstFieldOfficeAdminNames = new List<String> () ; 
        lstFieldOfficeAdminNames.add( 'lstFOAdminTestData' ) ; 
        // Global data 
        Global_Data__c oGlobalTestData = TestDataUtility.globalDataFrequency (  'Test'  , 3) ; 
        oGlobalTestData.Indicator__c = 'Test' ; 
            insert oGlobalTestData ; 
        
        List<FO_Administration__c> lstFOAdminTestData = TestDataUtility.FOAdministratorBOTestData(lstFieldOfficeAdminNames) ; 
        lstFOAdminTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        lstFOAdminTestData[0].Global_Data__c = oGlobalTestData.ID ; 
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
        
        Beneficiary_Assessment__c oTestBenAssementData = TestDataUtility.BenficiaryAssmntTestData () ;  
        oTestBenAssementData.Beneficiary__c = lstCDSPAccounts[0].ID ; 
            insert oTestBenAssementData ; 
        // Response data 
        Responses__c testResponseData = TestDataUtility.ResponsTestData ( 'test comment' , '2' , 'test' , 'test' , 'Meets Expectations'  ) ; 
        testResponseData.Indicator__c = 'test' ;
        testResponseData.CDPR_ID__c = oTestBenAssementData.ID ; 
        insert testResponseData ; 
        list<Responses__c> lstResponse = new list<Responses__c>();
        lstResponse.add(testResponseData);
        Org_Level_Settings__c oOrgDefaults = Org_Level_Settings__c.getOrgDefaults();                
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( lstCDSPAccounts[0] ) ;
        Pagereference pg = new PageReference( '/apex/CDPRAssessment' ) ; 
        Test.setCurrentPage(pg) ;
        ApexPages.currentPage().getParameters().put(Constants.CF_STRING+oOrgDefaults.Account_BenAssessment_Id__c+ Constants.LOOKUP_ID_STRING , lstCDSPAccounts[0].ID );
        ApexPages.currentPage().getParameters().put(Constants.RECORD_TYPE , lstCDSPAccounts[0].RecordtypeID );
        Test.StartTest() ; 
            CDPRAssessmentExtension testCDRPAsmExtn = new CDPRAssessmentExtension(stdConAcc) ; 
          //testCDPRAsmExtn.mapResponses.put('Physical', lstResponse);
            testCDRPAsmExtn.saveForm () ;
            testCDRPAsmExtn.fieldOfficeId = NULL ;
            testCDRPAsmExtn.saveForm () ;
            testCDRPAsmExtn.fieldOfficeId = lstFieldOfficeData[0].ID ;
            testCDRPAsmExtn.sAgeGroup = NULL ;
            For( String key : testCDRPAsmExtn.mapResponses.KeySet() ) {
                For( Responses__c oResp : testCDRPAsmExtn.mapResponses.get( key )  ) {
                    oResp.Points__c = '2' ; 
                    oResp.Comments__c = 'test comment' ;    
                }
            }
            testCDRPAsmExtn.saveForm () ;
            testCDRPAsmExtn.Redirect() ; 
            testCDRPAsmExtn.cancel() ;
            system.Assert ( testCDRPAsmExtn.mapResponses != NULL ) ; 
            system.Assert ( testCDRPAsmExtn.mapResponses.keySet().size() > 0 ) ;
            system.Assert ( testCDRPAsmExtn.recordtypeId == lstCDSPAccounts[0].RecordtypeID ) ;
        Test.StopTest() ;       
    }   
    static testMethod void verifyCDPRAssessmentExtension1 () 
    {
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
        insert oFieldGroup;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup.Id);
        insert lstFGE;
        List<sObject> lstGlobalConstants = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData');
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
        // to create Region test data
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
         TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
        // to create test data for FO ADministrator
        list<String> lstFieldOfficeAdminNames = new List<String> () ; 
        lstFieldOfficeAdminNames.add( 'lstFOAdminTestData' ) ; 
        // Global data 
        Global_Data__c oGlobalTestData = TestDataUtility.globalDataFrequency (  'Test'  , 3) ; 
        oGlobalTestData.Indicator__c = 'Test' ; 
            insert oGlobalTestData ; 
        
        List<FO_Administration__c> lstFOAdminTestData = TestDataUtility.FOAdministratorBOTestData(lstFieldOfficeAdminNames) ; 
        lstFOAdminTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        lstFOAdminTestData[0].Global_Data__c = oGlobalTestData.ID ; 
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
        
        Beneficiary_Assessment__c oTestBenAssementData = TestDataUtility.BenficiaryAssmntTestData () ;  
        oTestBenAssementData.Beneficiary__c = lstCDSPAccounts[0].ID ; 
            insert oTestBenAssementData ; 
        // Response data 
        Responses__c testResponseData = TestDataUtility.ResponsTestData ( 'test comment' , '2' , 'test' , 'test' , 'Meets Expectations'  ) ; 
        testResponseData.Indicator__c = 'test' ;
        testResponseData.CDPR_ID__c = oTestBenAssementData.ID ; 
        insert testResponseData ; 
        list<Responses__c> lstResponse = new list<Responses__c>();
        lstResponse.add(testResponseData);
        Org_Level_Settings__c oOrgDefaults = Org_Level_Settings__c.getOrgDefaults();                
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( lstCDSPAccounts[0] ) ;
        Pagereference pg = new PageReference( '/apex/CDPRAssessment' ) ; 
        Test.setCurrentPage(pg) ;
        ApexPages.currentPage().getParameters().put(Constants.CF_STRING+oOrgDefaults.Account_BenAssessment_Id__c+ Constants.LOOKUP_ID_STRING , lstCDSPAccounts[0].ID );
        ApexPages.currentPage().getParameters().put(Constants.RECORD_TYPE , lstCDSPAccounts[0].RecordtypeID );
        Test.StartTest() ; 
            CDPRAssessmentExtension testCDRPAsmExtn = new CDPRAssessmentExtension(stdConAcc) ; 
            testCDRPAsmExtn.oBeneficiaryAssessment.Assessment_Completion_Date__c = system.Today () ; 
            
            System.debug( '***system mapResponses' + testCDRPAsmExtn.mapResponses ) ; 
            For( String key : testCDRPAsmExtn.mapResponses.KeySet() ) {
                For( Responses__c oResp : testCDRPAsmExtn.mapResponses.get( key )  ) {
                    oResp.Points__c = '2' ; 
                    oResp.Comments__c = 'test comment' ;    
                }
            }
            System.debug( '###system mapResponses' + testCDRPAsmExtn.mapResponses ) ; 
            testCDRPAsmExtn.saveForm () ;
            testCDRPAsmExtn.Redirect() ;
            system.Assert ( testCDRPAsmExtn.mapResponses != NULL ) ; 
            system.Assert ( testCDRPAsmExtn.mapResponses.keySet().size() > 0 ) ;   
            system.Assert ( testCDRPAsmExtn.recordtypeId == lstCDSPAccounts[0].RecordtypeID ) ;
            testCDRPAsmExtn.cancel() ;
        Test.StopTest() ;       
    }
}