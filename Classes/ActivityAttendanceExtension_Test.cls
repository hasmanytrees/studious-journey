/******************************************************************************************************
Class Name         : ActivityAttendanceExtension_Test
Description        : This class contains unit tests for validating the behavior of Apex class: ActivityAttendanceExtension 
                     
Created By         : Jeevan D
Created On         : 14-sep-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class ActivityAttendanceExtension_Test{

    @IsTest static  void ActivityAttendanceExtensionTest(){
    test.starttest();
    
         List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
        insert oFieldGroup;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup.Id);
        insert lstFGE;
         List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData');            
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
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ;    
            insert oICPAccount ; 
        // to create test data for FO ADministrator
        list<String> lstFieldOfficeAdminNames = new List<String> () ; 
        lstFieldOfficeAdminNames.add( 'lstFOAdminTestDAta' ) ; 
        List<FO_Administration__c> lstFOAdminTestDAta = TestDataUtility.FOAdministratorBOTestData(lstFieldOfficeAdminNames) ; 
        lstFOAdminTestDAta[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        lstFOAdminTestDAta[0].Age_Group__c = '0-2' ; 
            insert lstFOAdminTestDAta ;
        List<Account> lstICP = new List<Account>() ;
        lstICP.add(oICPAccount) ; 
        // To insert HouseholdTestData
        list<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
        insert lstHouseHoldData ;
        // To insert HouseholdMemberTestData
        list<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
        insert lstHouseHoldMemberData;
        // to insert CDSPBenficiaryData
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstICP , lstHouseHoldData , lstHouseHoldMemberData ) ;
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '0-2' ;  
        lstCDSPAccounts[0].ICP__c = oICPAccount.ID ; 
            insert lstCDSPAccounts ;
        
        //ActivityAttendanceExtension  testSconYearlClsExt1 = new ActivityAttendanceExtension (stdConAcc) ; 
        // move this below testdata to Test Utility Class    
        Contact ContactTestDAta = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID
                                    , Role_At_ICP__c = 'Tutor / Implementer' ) ; 
            insert contactTestData ;     
       
        ApexPages.StandardController stdConAcc2 = new ApexPages.StandardController( new Activity_Attendance__c ( Name = 'test2', Activity_Date__c = System.Today(), BEN_Program_Type__c = 'Center-Based',
            Activity_Type__c = 'Literacy Class', ICP__c = oICPAccount.ID , Tutor__c = contactTestData.ID ));
        ActivityAttendanceExtension  testSconYearlClsExt3 = new ActivityAttendanceExtension (stdConAcc2);
        testSconYearlClsExt3.createActivityAttendance() ; 
            
        Activity_Attendance__c oTestActivityTestData = new Activity_Attendance__c ( Name = 'test', Activity_Date__c = System.Today(), BEN_Program_Type__c = 'Center-Based',
            Activity_Type__c = 'Literacy Class', ICP__c = oICPAccount.ID ,
            Tutor__c = contactTestData.ID ) ; 
            insert oTestActivityTestData ; 
        
        Beneficiary_Activity_Association__c oBenAssnData = new Beneficiary_Activity_Association__c ( BEN_Id__c = lstCDSPAccounts[0].ID , Activity__c = oTestActivityTestData.ID ) ;
            insert oBenAssnData ;
        
        ApexPages.StandardController stdConAcc1 = new ApexPages.StandardController( new Activity_Attendance__c () ) ;
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( oTestActivityTestData ) ;
         
        ActivityAttendanceExtension  testSconYearlClsExt1 = new ActivityAttendanceExtension (stdConAcc) ; 
        ActivityAttendanceExtension testSconYearlClsExt2 = new ActivityAttendanceExtension (stdConAcc1) ; 
        System.assertNotEquals(null,testSconYearlClsExt1);
        System.assertNotEquals(null,testSconYearlClsExt2);
        
     //   testSconYearlClsExt1.oActivityAttendance.ICP__c = oICPAccount.ID ; 
        testSconYearlClsExt1.search() ; 
        testSconYearlClsExt1.closePopupPage() ;
        testSconYearlClsExt1.checkAllAttendance() ;
        testSconYearlClsExt1.backToListPage() ;
        testSconYearlClsExt1.redirectToPrintPage() ;
        testSconYearlClsExt1.showPopup() ;
        testSconYearlClsExt1.selectBeneficiaries() ;
        testSconYearlClsExt1.saveBeneficiaryAttendance() ;
        testSconYearlClsExt1.createActivityAttendance() ;
        testSconYearlClsExt1.mapBenefIdToBenefWrapper.values()[0].bAttended = true ; 
        testSconYearlClsExt1.calculateHours() ;
        
        
        Test.StopTest() ; 
        
        }
        
        @IsTest static  void ActivityAttendanceExtension2Test(){
         
         
         User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser1; 
            System.assertNotEquals(null,oUser1); 
            
        System.RunAs( oUser1 ) { 
    
         List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
        insert oFieldGroup;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup.Id);
        insert lstFGE;
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
         List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData');            
        // to create Region test data
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
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;     
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
        // to create test data for FO ADministrator
        list<String> lstFieldOfficeAdminNames = new List<String> () ; 
        lstFieldOfficeAdminNames.add( 'lstFOAdminTestDAta' ) ; 
        List<FO_Administration__c> lstFOAdminTestDAta = TestDataUtility.FOAdministratorBOTestData(lstFieldOfficeAdminNames) ; 
        lstFOAdminTestDAta[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        lstFOAdminTestDAta[0].Age_Group__c = '0-2' ; 
            insert lstFOAdminTestDAta ;
        List<Account> lstICP = new List<Account>() ;
        lstICP.add(oICPAccount) ; 
        // To insert HouseholdTestData
        list<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
        insert lstHouseHoldData ;
        // To insert HouseholdMemberTestData
        list<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
        insert lstHouseHoldMemberData;
        // to insert CDSPBenficiaryData
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstICP , lstHouseHoldData , lstHouseHoldMemberData ) ;
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '0-2' ;  
        lstCDSPAccounts[0].ICP__c = oICPAccount.ID ; 
            insert lstCDSPAccounts ;
            
        // move this below testdata to Test Utility Class    
        Contact ContactTestDAta = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID
                                    , Role_At_ICP__c = 'Tutor / Implementer' ) ; 
            insert contactTestData ;     
       
        Activity_Attendance__c oTestActivityTestData = new Activity_Attendance__c ( Name = 'test', Activity_Date__c = System.Today(), BEN_Program_Type__c = 'Center-Based',
            Activity_Type__c = 'Literacy Class', ICP__c = oICPAccount.ID ,
            Tutor__c = contactTestData.ID ) ; 
            insert oTestActivityTestData ; 
        
        Beneficiary_Activity_Association__c oBenAssnData = new Beneficiary_Activity_Association__c ( BEN_Id__c = lstCDSPAccounts[0].ID , Activity__c = oTestActivityTestData.ID ) ;
            insert oBenAssnData ;
        
         Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID ) ; 
            Insert oConTest ;
            
         Profile oProfile = [select id from profile where name =: Constants.ICP_FULL_ACCESS_PROFILE LIMIT 1]; 
         
         User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = oConTest.Id ; 
         oUser2.PortalRole = 'Manager' ;
            insert oUser2;
              System.assertNotEquals(null,oUser2);
        
        test.starttest();
             System.RunAs ( oUser2 ) {
        
        ApexPages.StandardController stdConAcc1 = new ApexPages.StandardController( new Activity_Attendance__c () ) ;
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( oTestActivityTestData ) ;
         
        ActivityAttendanceExtension  testSconYearlClsExt1 = new ActivityAttendanceExtension (stdConAcc) ; 
        ActivityAttendanceExtension testSconYearlClsExt2 = new ActivityAttendanceExtension (stdConAcc1) ; 
        
        testSconYearlClsExt1.oActivityAttendance.BEN_Program_Type__c = LABEL.Program_Stage_Home_Based; 
        testSconYearlClsExt1.search() ;
        
        }
        Test.StopTest() ; 
        }
        }
}