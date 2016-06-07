/******************************************************************************************************
Class Name         : CDSPBenefAttendanceTrackingExtensio_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CDSPBenefAttendanceTrackingExtension
Created By         : Himanshu R
Created On         : 29-Oct-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class CDSPBenefAttendanceTrackingExtensio_Test {

    @IsTest 
    static void CDSPAttendanceTest(){
        Test.starttest();
    
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
                    
        // to create Region test data
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        List<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
            insert lstRegionTestData ;  
        // to create test data for Field office 
        List<string> lstFieldOfficeNames = new List<String> (  ) ; 
        lstFieldOfficeNames.add( 'Ethiopia' ) ; 
        List<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;   
            insert lstFieldOfficeData ;  
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;    
        // To Create Territory test data 
        List<string> lstTerritoryNames = new List<String> (  ) ; 
        lstTerritoryNames.add( 'testRegion' ) ; 
        List<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
            insert lstTerritoryTestData ;  
        //// to create Cluster test data
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        List<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ;    
            insert oICPAccount ;
            System.assertNotEquals(null,oICPAccount.id); 
        /*// to create test data for FO ADministrator
        List<String> lstFieldOfficeAdminNames = new List<String> () ; 
        lstFieldOfficeAdminNames.add( 'lstFOAdminTestDAta' ) ; 
        List<FO_Administration__c> lstFOAdminTestDAta = TestDataUtility.FOAdministratorBOTestData(lstFieldOfficeAdminNames) ; 
        lstFOAdminTestDAta[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        lstFOAdminTestDAta[0].Age_Group__c = '0-2' ; 
            insert lstFOAdminTestDAta ;*/
        List<Account> lstICP = new List<Account>() ;
        lstICP.add(oICPAccount) ; 
        // To insert HouseholdTestData
        List<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
        insert lstHouseHoldData ;
        // To insert HouseholdMemberTestData
        List<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
        insert lstHouseHoldMemberData;
        // to insert CDSPBenficiaryData
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstICP , lstHouseHoldData , lstHouseHoldMemberData ) ;
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '0-2' ;  
        lstCDSPAccounts[0].ICP__c = oICPAccount.ID ; 
            insert lstCDSPAccounts;
            System.assertNotEquals(null,lstCDSPAccounts[0].id); 
            
            
        // move this below testdata to Test Utility Class    
        Contact ContactTestDAta = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID
                                    , Role_At_ICP__c = 'Tutor / Implementer' ) ; 
            insert contactTestData ;     
        Yearly_Class_Schedule__c testdata = new Yearly_Class_Schedule__c (  BEN_Cognitive_Age_Group__c = '0-2' , Tutor__c = contactTestData.ID , 
                                            ICP_Name__c =  oICPAccount.ID , Class_Type__c = 'Center-Based Class' , Starting_Month__c = 'Jan' , 
                                            Year__c = '2016') ; 
        insert testdata ; 
        System.assertNotEquals(null,testdata.id); 
        Monthly_Class_Schedule__c testmonthlyclassscheduleddata= new Monthly_Class_Schedule__c(BEN_Cognitive_Age_Group__c = '0-2',Yearly_Class__c=testdata.id,Month__c='Feb',Year__c='2014');
        insert testmonthlyclassscheduleddata;
        Daily_Class_Schedule__c oDailyClassSchedule= new Daily_Class_Schedule__c(Monthly_Class_Schedule__c= testmonthlyclassscheduleddata.id,Class_Date__c=System.Today(),Class_Hours__c=4);
        insert oDailyClassSchedule;
        Beneficiary_Class_Association__c oClassAssoc = TestDataUtility.beneficiaryClassAssociationTestData(lstCDSPAccounts[0], testmonthlyclassscheduleddata);
        insert oClassAssoc;
        Beneficiary_Class_Attendance__c oBeneficaryClassAttendance= new Beneficiary_Class_Attendance__c(Name='testattendance',BEN_Id__c=lstCDSPAccounts[0].id,Daily_Class_Schedule__c= oDailyClassSchedule.id,BEN_Attended__c=true);
        insert oBeneficaryClassAttendance;
        System.assertNotEquals(null,oBeneficaryClassAttendance.id);
        
        
        ApexPages.StandardController stdConMonthlySchedule1 = new ApexPages.StandardController( new Monthly_Class_Schedule__c () ) ;
        ApexPages.StandardController stdMonthlySchedule = new ApexPages.StandardController( testmonthlyclassscheduleddata ) ;
        Pagereference testVfPage= new Pagereference('/CDSPBenefAttendanceTrackingPage');
        Test.setCurrentPage(testVfPage); 
         system.currentPageReference().getParameters().put('iDay','5');
        CDSPBenefAttendanceTrackingExtension testMonthlyScheduleExt1 = new CDSPBenefAttendanceTrackingExtension (stdMonthlySchedule) ; 
        CDSPBenefAttendanceTrackingExtension testMonthlyScheduleExt2 = new CDSPBenefAttendanceTrackingExtension (stdConMonthlySchedule1) ; 
        list<CDSPBenefAttendanceTrackingExtension.DailyClassWrapper> lstDailScheduleWrapper = new list< CDSPBenefAttendanceTrackingExtension.DailyClassWrapper>();
        CDSPBenefAttendanceTrackingExtension.DailyClassWrapper DailScheduleWrapper = new CDSPBenefAttendanceTrackingExtension.DailyClassWrapper('Test',true, 4.00,
            4, oDailyClassSchedule.id,'Test');
        DailScheduleWrapper.iDate= 4;//System.Today();
        DailScheduleWrapper.dHours = 4;
        lstDailScheduleWrapper.add(DailScheduleWrapper);
        //testMonthlyScheduleExt1.BeneficiaryDataWrapper[0].BenefAttendance[0].bSelected = true ;
        lstDailScheduleWrapper.add(DailScheduleWrapper);
        testMonthlyScheduleExt1.selectAllBenefForDaily();
        testMonthlyScheduleExt1.saveAttendance(); 
        testMonthlyScheduleExt1.redirectToListPage();
        testMonthlyScheduleExt1.nextPage();
        testMonthlyScheduleExt1.previousPage();
        testMonthlyScheduleExt1.firstPage();
        testMonthlyScheduleExt1.lastPage();
        /*system.currentPageReference().getParameters().put('monthName', 'Dec');  
          
        testSconYearlClsExt1.redirectToPreviousPage();
        testSconYearlClsExt1.lstBeneficiaryWrapper[0].lstMonthWrapper[0].bselectedmonth = true ; 
        testSconYearlClsExt1.selectBeneficiaries();
        
        testSconYearlClsExt1.selectAllBenefForMonth();
        testSconYearlClsExt1.selectAllMonthForBenef();
        testSconYearlClsExt1.resetAllDataStructures();*/
         
        Test.stoptest(); 
    }
}