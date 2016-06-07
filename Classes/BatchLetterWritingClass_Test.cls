/******************************************************************************************************
Class Name         : BatchLetterWritingClass_Test
Description        : This class contains unit tests for validating the behavior of Apex class: BatchLetterWritingClass
Created By         : Sfurti Pandey
Created On         : 30-Oct-2015 
*******************************************************************************************************/
@IsTest(SeeAllData=false) 
public class BatchLetterWritingClass_Test 
{
    
    static testMethod void verifyBatchLetterWritingClass1() 
    
    {
        
         List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
         List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
         List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
         List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
         
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
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
        // To Create Territory test data 
        List<string> lstTerritoryNames = new List<String> (  ) ; 
        lstTerritoryNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ;
         insert lstTerritoryTestData;
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
        insert lstClusterTestData ;
        List<Account> lstAccount=new List<Account>();
        Account oICPAccount = TestDataUtility.ICPTestData() ;
       
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ;
        /* DateTime d = datetime.now();
        Date dateToday = Date.Today();
        String monthName = d.format('MMMMMM'); */
        oICPAccount.ICP_Schedule_First_Letter_Writing_Month__c= 'January';
        oICPAccount.ICP_Schedule_Second_Letter_Writing_Month__c= 'February';
        lstAccount.add(oICPAccount) ;
        insert lstAccount;
         list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
        Test.StartTest();
       
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccount , lstHousehold, lstHouseholdMember) ;
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '3-8' ; 
        lstCDSPAccounts[0].ICP__c = lstAccount[0].ID ;  
        lstCDSPAccounts[1].ICP__c = lstAccount[0].ID ; 
        
       // lstCDSPAccounts[0].Formal_Education_Status__c='Primary';
        //lstCDSPAccounts[1].Formal_Education_Status__c='Primary';
        //lstCDSPAccounts[0].Type_Of_Vocational_Education__c='Agriculture';
        //lstCDSPAccounts[1].Type_Of_Vocational_Education__c='Agriculture';
        lstCDSPAccounts[0].Beneficiary_Status__c='Active';
        lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2' ; 
        lstCDSPAccounts[1].Local_Grade_Level__c='PreSchool';
        lstCDSPAccounts[0].Local_Grade_Level__c='PreSchool';
        insert lstCDSPAccounts;
        System.assertNotEquals(null,lstCDSPAccounts);
        lstHouseholdMember[0].Existing_Beneficiary__c=lstCDSPAccounts[1].id;
        update  lstHouseholdMember;
        set<Id> setICPIds = new set<Id>();
        setICPIds.add(lstAccount[0].id);
        Id cdspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,Constants.CDSP_BENEFICIARY_RT_API_NAME);
        String query = 'Select Id, Local_Beneficiary_Id__c, RecordTypeId, Beneficiary_Status__c from Account where ICP__c IN: setICPIds AND Beneficiary_Status__c = \'Active\' AND RecordTypeId =: cdspBenefRecTypeId limit 10';
        
        System.assertEquals(lstHouseholdMember[0].Existing_Beneficiary__c,lstCDSPAccounts[1].id);
        BatchLetterWritingClass b = new BatchLetterWritingClass(query,setICPIds,cdspBenefRecTypeId);
            Database.executeBatch(b);
        Test.StopTest();
      }
}