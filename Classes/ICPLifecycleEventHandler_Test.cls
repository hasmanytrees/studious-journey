/******************************************************************************************************
Class Name         : ICPLifecycleEventHandler_Test
Deascription       : This class contains unit tests for validating the behavior of Apex class: ICPLifecycleEventHandler
                     and ICPLifecycleEventTrigger
Created By         : Sudipta Nayak
Created On         : 10-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class ICPLifecycleEventHandler_Test {
    static testMethod void ileTestMethod() {
        
        list<Account> lstAccountICP = new list<Account>();
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> accId = new list<Id>();
        list<ICP_Lifecycle_Events__c> lstILE = new List<ICP_Lifecycle_Events__c>();
        list<ICP_Lifecycle_Events__c> lstILEUpdate = new List<ICP_Lifecycle_Events__c>();
        System.runAs(UserPF) {
            
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
            List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
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
            List<Account> lstAccount=new List<Account>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstClusterTestData[0].ID ;
            lstAccount.add(oICPAccount) ;
            Account oICPAccount1 = TestDataUtility.ICPTestData() ;
            oICPAccount1.Cluster__c = lstClusterTestData[0].ID ;
            oICPAccount1.ICP_Id__c = 'TD159';
            lstAccount.add(oICPAccount1) ;
            insert lstAccount;

            lstILE = TestDataUtility.ILETestData(lstAccount);
            Test.StartTest();
            insert lstILE[0];
            insert lstILE[1];
            insert lstILE[3];
            for(ICP_Lifecycle_Events__c ILE : [Select id,Status__c, Transition_Complete__c, Actual_Transition_Date__c from ICP_Lifecycle_Events__c where Status__c='Pending Approval' and id in:lstILE])  {
                ILE.Status__c = 'Approved';
                //ILE.Transition_Complete__c = true;
                //ILE.Actual_Transition_Date__c = System.today();
                lstILEUpdate.add(ILE);  
                }
            for(ICP_Lifecycle_Events__c ILE : [Select id,Status__c, Transition_Complete__c, Actual_Transition_Date__c from ICP_Lifecycle_Events__c where Status__c='Approved' and id in:lstILE])  {
                ILE.Status__c = 'Completed';
                ILE.Transition_Complete__c = true;
                ILE.Actual_Transition_Date__c = System.today();
                lstILEUpdate.add(ILE);  
                }
            update lstILEUpdate;
            system.assertequals('Approved',lstILEUpdate[0].Status__c);
            Test.StopTest();
        }
    }
}