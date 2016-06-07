/******************************************************************************************************
Class Name         : YearlyClassExtension_Test
Description        : This class contains unit tests for validating the behavior of Apex class: YearlyClassExtension
                     
Created By         : Jeevan D
Created On         : 14-sep-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class YearlyClassExtension_Test {

    @IsTest static  void YearlyClassExtensionTest(){
    test.starttest();
    
         List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
                    
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
        Yearly_Class_Schedule__c testdata = new Yearly_Class_Schedule__c (  BEN_Cognitive_Age_Group__c = '0-2' , Tutor__c = contactTestData.ID , 
                                            ICP_Name__c =  oICPAccount.ID , Class_Type__c = 'Center-Based Class' , Starting_Month__c = 'Jan' , 
                                            Year__c = '2016') ; 
        insert testdata ; 
        
        
        ApexPages.StandardController stdConAcc1 = new ApexPages.StandardController( new Yearly_Class_Schedule__c () ) ;
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( testdata ) ;
         
        YearlyClassExtension testSconYearlClsExt1 = new YearlyClassExtension (stdConAcc) ; 
        YearlyClassExtension testSconYearlClsExt2 = new YearlyClassExtension (stdConAcc1) ; 
        Pagereference testVfPage= new Pagereference('/YearlyClassPage');
        Test.setCurrentPage(testVfPage);   
        system.currentPageReference().getParameters().put('monthName', 'Dec');  
          
       
        testSconYearlClsExt1.redirectToPreviousPage();
        testSconYearlClsExt1.lstBeneficiaryWrapper[0].lstMonthWrapper[0].bselectedmonth = true ; 
        testSconYearlClsExt1.selectBeneficiaries();
        
        testSconYearlClsExt1.selectAllBenefForMonth();
        testSconYearlClsExt1.selectAllMonthForBenef();
         testSconYearlClsExt1.resetAllDataStructures();
          system.assertnotequals(null,testdata.id); 
         
        test.stoptest(); 
    }
     @IsTest static  void YearlyClassExtensionmethodsTest(){
    test.starttest();
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
                    
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
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
         TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
       
        
         Yearly_Class_Schedule__c testdatahomebased = new Yearly_Class_Schedule__c (  BEN_Cognitive_Age_Group__c = '0-2' , Tutor__c = contactTestData.ID , 
                                            ICP_Name__c =  oICPAccount.ID , Class_Type__c = 'Center-Based Class' , Starting_Month__c = 'Jan' , 
                                            Year__c = '2016',BEN_Program_Delivery__c='Home Based') ; 
         insert testdatahomebased;
         Monthly_Class_Schedule__c testmonthlyclassscheduleddata= new Monthly_Class_Schedule__c(BEN_Cognitive_Age_Group__c = '0-2',Yearly_Class__c=testdatahomebased.id);
        insert testmonthlyclassscheduleddata;
        
        Beneficiary_Class_Association__c testbenefclassassodata= new Beneficiary_Class_Association__c(BEN_Id__c = lstCDSPAccounts[0].id,Monthly_Class_Schedule__c=testmonthlyclassscheduleddata.id);
        insert testbenefclassassodata;
        ApexPages.StandardController stdConAcc1 = new ApexPages.StandardController( new Yearly_Class_Schedule__c () ) ;
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( testdatahomebased ) ;
        
       //  testSconYearlClsExt1.lstBeneficiaryWrapper[0].sBeneficiaryId = lstCDSPAccounts[0].id ; 
         
        YearlyClassExtension testSconYearlClsExt1 = new YearlyClassExtension (stdConAcc) ; 
        
      
        YearlyClassExtension testSconYearlClsExt2 = new YearlyClassExtension (stdConAcc1) ;
        system.assertnotequals(null,testdatahomebased.id); 
      
       
    test.stoptest();
    }
    
    @IsTest static  void YearlyClassExtensionbenefdeleteTest(){
    test.starttest();
    
         List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
                    
        // to create Region test data
        List<string> lstRegionNames = new List<String> (  ) ; 
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
         TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
        Yearly_Class_Schedule__c testdata = new Yearly_Class_Schedule__c (  BEN_Cognitive_Age_Group__c = '0-2' , Tutor__c = contactTestData.ID , 
                                            ICP_Name__c =  oICPAccount.ID , Class_Type__c = 'Center-Based Class' , Starting_Month__c = 'Jan' , 
                                            Year__c = '2016') ; 
        insert testdata ; 
        Monthly_Class_Schedule__c testmonthlyclassscheduleddata= new Monthly_Class_Schedule__c(BEN_Cognitive_Age_Group__c = '0-2',Yearly_Class__c=testdata.id,Month__c='Dec');
        insert testmonthlyclassscheduleddata;
        
        Beneficiary_Class_Association__c testbenefclassassodata= new Beneficiary_Class_Association__c(BEN_Id__c = lstCDSPAccounts[0].id,Monthly_Class_Schedule__c=testmonthlyclassscheduleddata.id);
        insert testbenefclassassodata;
        
        
        ApexPages.StandardController stdConAcc1 = new ApexPages.StandardController( new Yearly_Class_Schedule__c () ) ;
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( testdata ) ;
         
        YearlyClassExtension testSconYearlClsExt1 = new YearlyClassExtension (stdConAcc) ; 
        YearlyClassExtension testSconYearlClsExt2 = new YearlyClassExtension (stdConAcc1) ; 
        Pagereference testVfPage= new Pagereference('/YearlyClassPage');
        Test.setCurrentPage(testVfPage);   
        system.currentPageReference().getParameters().put('monthName', 'Dec');  
          
       
        testSconYearlClsExt1.redirectToPreviousPage();
        testSconYearlClsExt1.lstBeneficiaryWrapper[0].lstMonthWrapper[0].bselectedmonth = false ; 
        testSconYearlClsExt1.selectBeneficiaries();
        
        testSconYearlClsExt1.selectAllBenefForMonth();
        testSconYearlClsExt1.selectAllMonthForBenef();
         testSconYearlClsExt1.resetAllDataStructures();
         system.assertnotequals(null,testdata.id);
         
        test.stoptest(); 
    }
     @IsTest static  void YearlyClassExtensioncheckforallmonthTest(){
    test.starttest();
    
       User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser1;  
            
        System.RunAs( oUser1 ) { 
       
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
                    
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
           
        
             List<String> lstHelperForFirstRow = new List<String> (Label.Yearly_Class_Month_Names
            .split(','));
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
          
        Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID ) ; 
            Insert oConTest ;
            
         Profile oProfile = [select id from profile where name =: Constants.ICP_FULL_ACCESS_PROFILE LIMIT 1]; 
         
         User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = oConTest.Id ; 
         oUser2.PortalRole = 'Manager' ;
            insert oUser2;
                
                
        Yearly_Class_Schedule__c testdata = new Yearly_Class_Schedule__c (  BEN_Cognitive_Age_Group__c = '0-2' , Tutor__c = contactTestData.ID , 
                                            ICP_Name__c =  oICPAccount.ID , Class_Type__c = 'Center-Based Class' , Starting_Month__c = 'Feb' , 
                                            Year__c = '2016') ; 
        insert testdata ; 
        Monthly_Class_Schedule__c testmonthlyclassscheduleddata= new Monthly_Class_Schedule__c(BEN_Cognitive_Age_Group__c = '0-2',Yearly_Class__c=testdata.id,Month__c='',Year__c = '2016');
        insert testmonthlyclassscheduleddata;
        
        Beneficiary_Class_Association__c testbenefclassassodata= new Beneficiary_Class_Association__c(BEN_Id__c = lstCDSPAccounts[0].id,Monthly_Class_Schedule__c=testmonthlyclassscheduleddata.id);
        insert testbenefclassassodata;
        
        
        ApexPages.StandardController stdConAcc1 = new ApexPages.StandardController( new Yearly_Class_Schedule__c () ) ;
         
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( testdata ) ;
        YearlyClassExtension testSconYearlClsExt2 ; 
        
        YearlyClassExtension testSconYearlClsExt1 = new YearlyClassExtension (stdConAcc) ; 
        
       
         
        testSconYearlClsExt1 .lstBeneficiaryWrapper[0].lstMonthWrapper[0].bselectedmonth = false ; 
        Pagereference testVfPage= new Pagereference('/YearlyClassPage');
        Test.setCurrentPage(testVfPage); 
       // testSconYearlClsExt1.selectBeneficiaries();
        testSconYearlClsExt1.lstBeneficiaryWrapper[0].sBeneficiaryId=lstCDSPAccounts[0].id  ;   
        system.currentPageReference().getParameters().put('sBenefId', lstCDSPAccounts[0].id);  
          
       
        testSconYearlClsExt1.redirectToPreviousPage();
        testSconYearlClsExt1.lstBeneficiaryWrapper[0].sBeneficiaryId=lstCDSPAccounts[0].id  ; 
        //testSconYearlClsExt1.lstBeneficiaryWrapper[0].lstMonthWrapper[0].bselectedmonth = false  ;
       testSconYearlClsExt1.lstBeneficiaryWrapper.sort();
        testSconYearlClsExt1.selectBeneficiaries();
       
        testSconYearlClsExt1.selectAllMonthForBenef();
         testSconYearlClsExt1.resetAllDataStructures();
         system.assertnotequals(null,testdata.id);
              
        
        test.stoptest(); 
        }
    }
    
    
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
         Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID ) ; 
            Insert oConTest ;
            
         Profile oProfile = [select id from profile where name =: Constants.ICP_FULL_ACCESS_PROFILE LIMIT 1]; 
         
         User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = oConTest.Id ; 
         oUser2.PortalRole = 'Manager' ;
            insert oUser2;
        
        test.starttest();
             System.RunAs ( oUser2 ) {
              ApexPages.StandardController stdConAcc1 = new ApexPages.StandardController( new Yearly_Class_Schedule__c () ) ;
              YearlyClassExtension  testSconYearlClsExt2  = new YearlyClassExtension (stdConAcc1) ;
        }  
        system.assertnotequals(null,oConTest.id);
        test.stoptest(); 
        }
             
                    
    }   

    
    @IsTest static  void YearlyClassExtensioncheckforbenefdeleteTest(){
    test.starttest();
    
         List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
                    
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
           
        
             List<String> lstHelperForFirstRow = new List<String> (Label.Yearly_Class_Month_Names
            .split(','));
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
        lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2' ;  
        lstCDSPAccounts[1].ICP__c = oICPAccount.ID ; 
            insert lstCDSPAccounts ;
            
        // move this below testdata to Test Utility Class    
        Contact ContactTestDAta = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = oICPAccount.ID
                                    , Role_At_ICP__c = 'Tutor / Implementer' ) ; 
            insert contactTestData ;     
        Yearly_Class_Schedule__c testdata = new Yearly_Class_Schedule__c (  BEN_Cognitive_Age_Group__c = '0-2' , Tutor__c = contactTestData.ID , 
                                            ICP_Name__c =  oICPAccount.ID , Class_Type__c = 'Center-Based Class' , Starting_Month__c = 'Feb' , 
                                            Year__c = '2016') ; 
        insert testdata ; 
        Monthly_Class_Schedule__c testmonthlyclassscheduleddata= new Monthly_Class_Schedule__c(BEN_Cognitive_Age_Group__c = '0-2',Yearly_Class__c=testdata.id,Month__c='',Year__c = '2016');
        insert testmonthlyclassscheduleddata;
        
        Beneficiary_Class_Association__c testbenefclassassodata= new Beneficiary_Class_Association__c(BEN_Id__c = lstCDSPAccounts[0].id,Monthly_Class_Schedule__c=testmonthlyclassscheduleddata.id);
        insert testbenefclassassodata;
        
        Beneficiary_Class_Association__c testbenefclassassodatanew= new Beneficiary_Class_Association__c(BEN_Id__c = lstCDSPAccounts[1].id,Monthly_Class_Schedule__c=testmonthlyclassscheduleddata.id);
        insert testbenefclassassodatanew;
        
        YearlyClassExtension.BeneficiaryDataWrapper oBenWapVar = new YearlyClassExtension.BeneficiaryDataWrapper();
        oBenWapVar.sBeneficiaryName = lstCDSPAccounts[1].Name;
        oBenWapVar.sBeneficiaryId = lstCDSPAccounts[1].id;
        oBenWapVar.sLocalBeneficiaryId = lstCDSPAccounts[1].Local_Beneficiary_ID__c;
        oBenWapVar.sLocalBeneficiaryNum = lstCDSPAccounts[1].Local_Beneficiary_Number__c;
        oBenWapVar.sLocalBeneficiaryAge = '5' ;
        
        
        ApexPages.StandardController stdConAcc1 = new ApexPages.StandardController( new Yearly_Class_Schedule__c () ) ;
         
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( testdata ) ;
        
         
        YearlyClassExtension testSconYearlClsExt1 = new YearlyClassExtension (stdConAcc) ; 
        YearlyClassExtension testSconYearlClsExt2 = new YearlyClassExtension (stdConAcc1) ;
        testSconYearlClsExt1 .lstBeneficiaryWrapper[0].lstMonthWrapper[0].bselectedmonth = true ; 
        Pagereference testVfPage= new Pagereference('/YearlyClassPage');
        Test.setCurrentPage(testVfPage); 
        testSconYearlClsExt1.selectBeneficiaries();
        testSconYearlClsExt1.lstBeneficiaryWrapper[0].sBeneficiaryId=lstCDSPAccounts[0].id  ;   
        system.currentPageReference().getParameters().put('sBenefId', lstCDSPAccounts[0].id);  
          
       
        //testSconYearlClsExt1.redirectToPreviousPage();
        testSconYearlClsExt1.lstBeneficiaryWrapper[0].sBeneficiaryId=lstCDSPAccounts[0].id  ;
        system.debug('****lstCDSPAccounts[1]'+lstCDSPAccounts[1].id ); 
        testSconYearlClsExt1.lstBeneficiaryWrapper[0].sLocalBeneficiaryAge = '5' ; 
        testSconYearlClsExt1.lstBeneficiaryWrapper[0].sBeneficiaryId=lstCDSPAccounts[1].id  ; 
        testSconYearlClsExt1.lstBeneficiaryWrapper[0].lstMonthWrapper[0].bselectedmonth = false  ;
        
        System.Assert ( testSconYearlClsExt1.lstBeneficiaryWrapper[0] != NULL ) ; 
        ID assID = testSconYearlClsExt1.lstBeneficiaryWrapper[0].lstMonthWrapper[0].associationId; 
        testSconYearlClsExt1.selectBeneficiaries();
       
        testSconYearlClsExt1.selectAllMonthForBenef();
        testSconYearlClsExt1.lstBeneficiaryWrapper.Add ( oBenWapVar ) ; 
        testSconYearlClsExt1.lstBeneficiaryWrapper.Add ( testSconYearlClsExt1.lstBeneficiaryWrapper[0]) ; 
        testSconYearlClsExt1.lstBeneficiaryWrapper.sort();
        //system.assertequals(testSconYearlClsExt1.lstBeneficiaryWrapper[0]!=null,true);
        
         testSconYearlClsExt1.resetAllDataStructures();
         system.assertnotequals(null,testdata.id);
              
        
        test.stoptest(); 
    }
        
}