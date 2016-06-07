/******************************************************************************************************
Class Name         : EventHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: EventHandler
                     and EventTrigger
Created By         : Sfurti Pandey
Created On         : 03-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
public class EventHandler_Test{
    static testMethod void verifyEventhandler() 
    
    {
           User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
           insert oUser1;  
          System.RunAs( oUser1 ) {    
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
        Test.StartTest();   
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
        lstAccount.add(oICPAccount) ;
        insert lstAccount;
        Datetime dThreeYearsBack = DateTime.newInstance(System.Now().Year() -
            3, System.Now().Month(), System.Now().Day(), System.Now()
            .Hour(), System.Now().Minute(), System.Now().Second());
          
        Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccount[0].ID ) ; 
            Insert oConTest ;
         Profile oProfile = [select id from profile where name =: Constants.ICP_FULL_ACCESS_PROFILE LIMIT 1]; 
         
         User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = oConTest.Id ; 
         oUser2.PortalRole = 'Manager' ;
            insert oUser2;
            Event oEventTask=TestDataUtility.EventTestData( oUser2, lstAccount[0]);
            insert oEventTask;
            Test.StopTest();
            system.debug('@@@@@@@@@@@oEventTask'+oEventTask);
            System.RunAs( oUser2 ) { 
            
            try{
                delete oEventTask;
                system.debug('@@@@@@@@@@afterdeleteoEventTask'+oEventTask);
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.EventHandler_Error_On_Task_Delete) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
                }
            
            
            }
        }
        }
    
}