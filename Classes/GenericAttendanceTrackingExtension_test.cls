/*Class Name         : GenericAttendanceTrackingExtension_Test
*Description        :  This class contains unit tests for validating the behavior of Apex class:GenericAttendanceTrackingExtension
*Created By         : Sfurti Pandey 
*Created On         : 09/11/2015
********************************************************************************/
@IsTest(SeeAllData=false) 
public  class GenericAttendanceTrackingExtension_test{
         static testMethod void positiveTest() {

        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
        
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add('lstAccountId');
          list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
            insert lstRegionTestData ;  
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
        Test.StartTest(); 
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
            System.assertNotEquals(null,lstCDSPAccounts);
            
        // move this below testdata to Test Utility Class    
        Contact ContactTestDAta = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID
                                    , Role_At_ICP__c = 'Tutor / Implementer' ) ; 
            insert contactTestData ;     
        Yearly_Class_Schedule__c testdata = new Yearly_Class_Schedule__c (  BEN_Cognitive_Age_Group__c = '0-2' , Tutor__c = contactTestData.ID , 
                                            ICP_Name__c =  oICPAccount.ID , Class_Type__c = 'Center-Based Class' , Starting_Month__c = 'Jan' , 
                                            Year__c = '2016') ;
                  insert testdata;
         Yearly_Class_Schedule__c testdatanew = new Yearly_Class_Schedule__c (  BEN_Cognitive_Age_Group__c = '0-2' , Tutor__c = contactTestData.ID , 
                                            ICP_Name__c =  oICPAccount.ID , Class_Type__c = 'Home Visits' , Starting_Month__c = 'Jan' , 
                                            Year__c = '2016') ;
                  insert testdatanew;
                  System.assertNotEquals(null,testdatanew.id);
         Monthly_Class_Schedule__c testmonthlyclassschedulednew= new Monthly_Class_Schedule__c(BEN_Cognitive_Age_Group__c = '0-2',Yearly_Class__c=testdatanew.id,Month__c='Dec');
        insert testmonthlyclassschedulednew;
         System.assertNotEquals(null,testmonthlyclassschedulednew.id);
        Monthly_Class_Schedule__c testmonthlyclassscheduleddata= new Monthly_Class_Schedule__c(BEN_Cognitive_Age_Group__c = '0-2',Yearly_Class__c=testdata.id,Month__c='Dec');
        insert testmonthlyclassscheduleddata;
        System.assertNotEquals(null,testmonthlyclassscheduleddata.id);
        Monthly_Class_Schedule__c oMothlyclass=[Select id,Class_Type__c from Monthly_Class_Schedule__c where id =:testmonthlyclassscheduleddata.id];
         Monthly_Class_Schedule__c oMothlyclassnew=[Select id,Class_Type__c from Monthly_Class_Schedule__c where id =:testmonthlyclassschedulednew.id];
       
        
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( oMothlyclass ) ;
        GenericAttendanceTrackingExtension testSconGenericAttExt1 = new GenericAttendanceTrackingExtension (stdConAcc) ;
        testSconGenericAttExt1.redirectToActualPage();
        ApexPages.StandardController stdConAccnew = new ApexPages.StandardController( oMothlyclassnew ) ;
        GenericAttendanceTrackingExtension testSconGenericAttExt2 = new GenericAttendanceTrackingExtension (stdConAccnew) ;
        testSconGenericAttExt2.redirectToActualPage();
        Test.StopTest(); 
        
        }
       
       
}