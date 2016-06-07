/******************************************************************************************************
Class Name         : AccountHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: YearlyClassScheduleHandler
                      and YearlyClassScheduleTrigger
Created By         :Sfurti Pandey
Created On         : 10-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class YearlyClassScheduleHandler_Test {
   static testMethod void YearlyClassScheduleHandlerTest1() {
        
        //System.RunAs(UserPF){
        List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
        List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'lstAccountId' ) ; 
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
       
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
        insert lstRegionTestData ;  
        // to create test data for Field office 
        List<string> lstFieldOfficeNames = new List<String> (  ) ; 
        lstFieldOfficeNames.add( 'Ecuador' ) ; 
        list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;  
        lstFieldOfficeData[0].FO_Next_Schedule_Print_Date__c =System.Today()+4;
        lstFieldOfficeData[0].Field_Office_Id__c='EC';
        insert lstFieldOfficeData ;      
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        // To Create Territory test data 
        List<string> lstTerritoryNames = new List<String> (  ) ; 
        lstTerritoryNames.add( 'lstAccountId' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ;
        insert lstTerritoryTestData;
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
        insert lstClusterTestData ;
        Test.Starttest();
        List<Account> lstAccount=new List<Account>();
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ;
        oICPAccount.ICP_Status__c='Active';
        lstAccount.add(oICPAccount) ;
        Account oICPAccountNew =TestDataUtility.ICPTestData() ;
        oICPAccountNew.ICP_Id__c = 'TD155';
        lstAccount.add(oICPAccountNew) ;
        insert lstAccount;
        // To insert HouseholdTestData
        list<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
        insert lstHouseHoldData ;
        list<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
        insert lstHouseHoldMemberData;
        // to insert CDSPBenficiaryData
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccount , lstHouseHoldData , lstHouseHoldMemberData ) ;
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '0-2' ;  
        lstCDSPAccounts[0].ICP__c = lstAccount[0].ID ; 
            insert lstCDSPAccounts ;
            
        // move this below testdata to Test Utility Class    
        Contact contactTestDAta = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccount[0].ID
                                    , Role_At_ICP__c = 'Tutor / Implementer' ) ; 
            insert contactTestData ;
             User oUser1 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
                    oUser1.ContactId = contactTestDAta .Id ; 
                    oUser1.PortalRole = 'Manager' ;
                    oUser1.Is_Sharing_Completed__c = false ;
                    insert oUser1;
         Contact contactTestDAtaNew = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccount[1].ID
                                    , Role_At_ICP__c = 'Tutor / Implementer' ) ; 
            insert contactTestDataNew ;    
       
        
         Yearly_Class_Schedule__c testdatahomebased = new Yearly_Class_Schedule__c (  BEN_Cognitive_Age_Group__c = '0-2' , Tutor__c = contactTestData.ID , 
                                            ICP_Name__c =  lstAccount[0].ID , Class_Type__c = 'Center-Based Class' , Starting_Month__c = 'Jan' , 
                                            Year__c = '2016',BEN_Program_Delivery__c='Home Based') ; 
         insert testdatahomebased;
         List<Yearly_Class_Schedule__Share> lstYearlyCLassShare=new list<Yearly_Class_Schedule__Share>();
                    Yearly_Class_Schedule__Share oYearlyCLassShare = new Yearly_Class_Schedule__Share();
                    oYearlyCLassShare.parentid= testdatahomebased.id;
                    oYearlyCLassShare.userorgroupid = oUser1.id;
                    oYearlyCLassShare.accesslevel = 'Edit';
                    oYearlyCLassShare.RowCause = Constants.APEX_BASED_SHARING;
                    lstYearlyCLassShare.add(oYearlyCLassShare);
                    insert lstYearlyCLassShare;
         testdatahomebased.ICP_Name__c =  lstAccount[1].ID;
         testdatahomebased.Tutor__c =  contactTestDataNew.ID;
         update testdatahomebased;
         system.assertequals(contactTestDataNew.ID,testdatahomebased.Tutor__c);
         
         Test.Stoptest();
       // }
    }
}