/******************************************************************************************************
Class Name         : BeneficiaryAssessmentHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: BeneficiaryAssessmentHandler
                     and BeneficiaryAssessmentTrigger
Created By         : Jeevan D
Created On         : 19-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class BeneficiaryAssessmentHandler_Test {
    static testMethod void healthAssessmentTest() {
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
        insert oFieldGroup;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup.Id);
        insert lstFGE;
        List<sObject> lstGlobalConstants = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData');
        // to create Region test data
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
        insert lstRegionTestData ;   
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
        Global_Data__c oGlobalData = TestDataUtility.globalDataFrequency ( 'test frequency' , 3) ;    
        insert oGlobalData ; 
        Beneficiary_Assessment__c oBeneficiaryHealthAssessmentData =  TestDataUtility.BeneficiaryHealthAssessmentTestData( 'test health assessment' , lstCDSPAccounts[0].ID , 50 , 5 ) ;   
        Beneficiary_Assessment__c oBeneficiaryHealthAssessmentICP =  TestDataUtility.BeneficiaryHealthAssessmentTestData( 'test health assessment' , oICPAccnt.ID , 50 , 5 ) ;   
        
        Test.StartTest() ; 
        insert oBeneficiaryHealthAssessmentData ; 
        oBeneficiaryHealthAssessmentData.Next_Assessment_Due_Date__c = System.Today () ;
        update oBeneficiaryHealthAssessmentData ;
        system.assert( oBeneficiaryHealthAssessmentData.Next_Assessment_Due_Date__c == System.Today() ) ; 
        Test.StopTest() ;  
    }
    
    static testMethod void developmentPlanTest() {
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
        insert oFieldGroup;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup.Id);
        insert lstFGE;
        List<sObject> lstGlobalConstants = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData');
        // to create Region test data
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
        insert lstRegionTestData ;   
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
        Account oICPAccnt = TestDataUtility.ICPTestData() ;
        oICPAccnt.Cluster__c = lstClusterTestData[0].ID ;    
        insert oICPAccnt ;  
        // to create test data for FO Administrator
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
        Global_Data__c oGlobalData = TestDataUtility.globalDataFrequency ( 'test frequency' , 3) ;    
        insert oGlobalData ; 
        Beneficiary_Assessment__c developmentPlanData = new Beneficiary_Assessment__c(
            Beneficiary__c = lstCDSPAccounts[0].id, Name = 'DevelopmentPlan', Assessment_Completion_Date__c = System.today());
        Test.StartTest() ; 
        insert developmentPlanData ; 
        developmentPlanData.Next_Assessment_Due_Date__c = System.Today () ;
        update developmentPlanData ;
        system.assert( developmentPlanData.Next_Assessment_Due_Date__c == System.Today() ) ; 
        Test.StopTest() ;  
    }
    
    static testMethod void cdprTest() {
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
        insert oFieldGroup;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup.Id);
        insert lstFGE; 
        List<sObject> lstGlobalConstants = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData');
        // to create Region test data
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
        insert lstRegionTestData ;   
        // to create test data for Field office 
        List<string> lstFieldOfficeName = new List<String> (  ) ; 
        lstFieldOfficeName.add( 'testFieldOffice' ) ;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false; 
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
        Account oICPAccnt = TestDataUtility.ICPTestData() ;
        oICPAccnt.Cluster__c = lstClusterTestData[0].ID ;    
        insert oICPAccnt ;  
        // to create test data for FO Administrator
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
        Global_Data__c oGlobalData = TestDataUtility.globalDataFrequency ( 'CDPR_Frequency_Name' , 3) ;    
        insert oGlobalData ; 
        Beneficiary_Assessment__c cdprData = new Beneficiary_Assessment__c(Name = 'TestBenAssmentData' , Assessment_Completion_Date__c = System.Today() , Height__c = 55 ,
                                                                           Beneficiary__c = lstCDSPAccounts[0].id , Physical_Outcome_Score__c = 'Meets Expectations' ,
                                                                           Cognitive_Outcome_Score__c = 'Meets Expectations' , Socio_emotional_Outcome_Score__c = 'Meets Expectations' , 
                                                                           Spiritual_Outcome_Score__c = 'Meets Expectations' , recordtypeId = Utility.getRecordTypeIdByDeveloperName
                                                                           (Beneficiary_Assessment__c.SObjectType,Constants.CDPR_BA_RT_API_NAME)) ; 
        Test.StartTest() ; 
        insert cdprData ; 
        cdprData.Next_Assessment_Due_Date__c = System.Today () ;
        update cdprData ;
        system.Assert ( cdprData.Next_Assessment_Due_Date__c != NULL ) ; 
        Test.StopTest() ;  
    }
}