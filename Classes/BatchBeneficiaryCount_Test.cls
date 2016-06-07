/******************************************************************************************************
Class Name         : BatchBeneficiaryCount_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     BatchBeneficiaryCount
Created By         : Rahul Agarwal
Created On         : 20-May-2015 
******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class BatchBeneficiaryCount_Test{
     
    @testSetup
    static void setup() {
        User UserPF = TestDataUtility.UserTestData('System Administrator','PF', 'GMC');
        insert UserPF;
        TriggerContextUtility.bFlagForTestDataBLEInsertion = false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        System.RunAs(UserPF){
        
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
            List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
            List<sObject> customSettingTransferValidation = Test.loadData(Prevent_Validation_Rule_For_Transfer__c.sObjectType, 'Prevent_Validation_for_Transfer');
            Test.loadData(Max_Connect_User_Count_Data__c.sObjectType, 'MaxConnectUserCountData');
            List<string> lstRegionNames = new List<String> (  ) ; 
            lstRegionNames.add( 'testRegion' ) ; 
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
            try{
            List<Account> lstAccount=new List<Account>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstClusterTestData[0].ID ;
            oICPAccount.Implemented_Programs__c = 'Survival';
            lstAccount.add(oICPAccount) ;
            Account oICPAccount1 = TestDataUtility.ICPTestData() ;
            oICPAccount1.Cluster__c = lstClusterTestData[0].ID ;
            oICPAccount1.ICP_Id__c = 'TD159';
            oICPAccount1.Implemented_Programs__c = 'Survival';
            lstAccount.add(oICPAccount1) ;
            insert lstAccount;
            Test.StartTest();
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            List<Account> lstToBeUpdated = new List<Account>();
            List<Account> lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccount, lstHousehold, lstHouseholdMember);
            lstToBeUpdated.addAll(lstAccountCDSP);
            
            List<Account> lstAccountCSP = TestDataUtility.CSPBeneficiaryTestData(lstAccount, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            system.debug('lstAccountCSP-->'+lstAccountCSP);
            lstToBeUpdated.addAll(lstAccountCSP);
            insert lstToBeUpdated;
            Test.stopTest();
            }
            catch(Exception e){
                System.debug('Exception in setup: '+e.getMessage());
            }
         }
       }
    
  /*  static testMethod void verifyBatchClass(){
            
        User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];  
        Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.ICP_RT_API_NAME);
        List<Account> lstAccountICP = [Select No_Of_CSP_Beneficiaries__c,No_Of_CDSP_Beneficiaries__c from Account where RecordTypeId = :icpRecTypeId]; 
        System.runAs(UserPF) {
            Test.startTest();
            BatchBeneficiaryCount b = new BatchBeneficiaryCount();
            Database.executeBatch(b);
            //System.assertEquals(2, lstAccountICP[0].No_Of_CSP_Beneficiaries__c);
            Test.StopTest() ;
        }
    } */

}