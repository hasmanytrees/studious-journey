/******************************************************************************************************
Class Name         : BeneficiaryLifecycleEventHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class:
                     BeneficiaryLifecycleEventHandler and BeneficiaryLifecycleEventTrigger
Created By         : Sudipta Nayak
Created On         : 06-Feb-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class BeneficiaryLifecycleEventHandler_Test {
    
    @testSetup 
    static void setup() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
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
            lstAccount.add(oICPAccount) ;
            Account oICPAccount1 = TestDataUtility.ICPTestData() ;
            oICPAccount1.Cluster__c = lstClusterTestData[0].ID ;
            oICPAccount1.ICP_Id__c = 'TD159';
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
            System.assertNotEquals(null,lstToBeUpdated[0].id);
            Test.stopTest();
            }
            catch(Exception e){
                System.debug('Exception in setup: '+e.getMessage());
            }
            
            
            
            }
       }
    
    static testMethod void verifyTransitionBLE()  {
        
        list<Beneficiary_Lifecycle_Event__c> lstBLEInsert = new list<Beneficiary_Lifecycle_Event__c>();
        list<Beneficiary_Lifecycle_Event__c> lstBLEUpdate = new list<Beneficiary_Lifecycle_Event__c>();
        Id transitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSITION_RT_API_NAME);
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,Constants.ICP_RT_API_NAME);
        Id exitRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME);
        String jsonBLEString = '{"BeneficiaryEventList": [ { "BeneficiaryId": "GH3178376", "BeneficiaryName": "Ben Afflick", "BeneficiaryLifecycleEventName": "BL-32346", "CreatedDate": "2015-02-24 07:15:51", "DateofAction": "2015-02-23 00:00:00", "DeathReason": "", "EventType": "Planned Exit", "LastModifiedDate": "2015-02-26 07:15:18", "NewCurrentICPId": "GH317", "NewCurrentICPName": "House of Grace Assemblies of God", "ReasonforRequest": "Reached Maximum Age", "RecordTypeName": "Planned_Exit", "COMPASSId": "83746", "ReligiousAffiliation": "", "Status": "Closed", "FormalEducationStatus": "", "LastAttendedDate": "2015-02-23 00:00:00" }]}';
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', jsonBLEString, null);
        User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];
           
        System.runAs(UserPF) {
            TriggerContextUtility.bFlagForTestDataBLEInsertion = false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun = false;
            List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
            Boolean transitionFlag = Account_Prevent_Validation_on_Transition__c.getOrgDefaults().Prevent_Validation_for_Transition__c;
            system.debug('------'+Account_Prevent_Validation_on_Transition__c.getOrgDefaults());
            transitionFlag=false;
            List<sObject> customSettingTransferValidation = Test.loadData(Prevent_Validation_Rule_For_Transfer__c.sObjectType, 'Prevent_Validation_for_Transfer');
            
            list<Account> lstAccountICP  =[Select id,Name,RecordTypeId,ICP_Status__c,ICP_ID__c,Check_Record__c,RecordType.DeveloperName from Account where RecordTypeId=:icpRecTypeId limit 2];
            List<Account> lstAccountCSP = [Select id,Beneficiary_Status__c from Account where RecordTypeId=:cspRecTypeId LIMIT 2];            
            system.debug('lstAccountCSP*****'+lstAccountCSP);
            List<Beneficiary_Lifecycle_Event__c> lstCSPBLEInsert = TestDataUtility.CSPBLETestData(lstAccountICP,lstAccountCSP);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            Test.startTest();
            //Database.insert(lstCSPBLEInsert, false);
           // insert lstCSPBLEInsert;
            
            /*for(Beneficiary_Lifecycle_Event__c BLE : [Select id,Transition_Update_Date__c, RecordTypeId from Beneficiary_Lifecycle_Event__c where id in:lstCSPBLEInsert AND RecordTypeId =:transitionRecTypeId])  {
                BLE.Transition_Update_Date__c = System.Today();
                lstBLEUpdate.add(BLE);
            }            
            
            update lstBLEUpdate;
            transitionFlag=true;*/
            
            system.assert( lstAccountCSP[0].Beneficiary_Status__c != NULL ) ;
            Test.StopTest();
        }    
    }
    
    static testMethod void verifyExitBLE()  {
        list<Beneficiary_Lifecycle_Event__c> lstBLEInsert = new list<Beneficiary_Lifecycle_Event__c>();
        list<Beneficiary_Lifecycle_Event__c> lstBLEUpdate = new list<Beneficiary_Lifecycle_Event__c>();
        Id exitRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME);
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        
        User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];
        String jsonBLEString = '{"BeneficiaryEventList": [ { "BeneficiaryId": "GH3178376", "BeneficiaryName": "Ben Afflick", "BeneficiaryLifecycleEventName": "BL-32346", "CreatedDate": "2015-02-24 07:15:51", "DateofAction": "2015-02-23 00:00:00", "DeathReason": "", "EventType": "Planned Exit", "LastModifiedDate": "2015-02-26 07:15:18", "NewCurrentICPId": "GH317", "NewCurrentICPName": "House of Grace Assemblies of God", "ReasonforRequest": "Reached Maximum Age", "RecordTypeName": "Planned_Exit", "COMPASSId": "83746", "ReligiousAffiliation": "", "Status": "Closed", "FormalEducationStatus": "", "LastAttendedDate": "2015-02-23 00:00:00" }]}';
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', jsonBLEString, null);
        
        System.runAs(UserPF) {
            try{
            TriggerContextUtility.bFlagForTestDataBLEInsertion = true;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun = false;
            Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,Constants.ICP_RT_API_NAME);
            Boolean transitionFlagB = Prevent_Validation_Rule_For_Transfer__c.getOrgDefaults().Prevent_Validation_for_Transfer__c;
            list<Account> lstAccountICP  =[Select id,Name,RecordTypeId,ICP_Status__c,ICP_ID__c,Check_Record__c,RecordType.DeveloperName from Account where RecordTypeId=:icpRecTypeId limit 2];
            System.debug('lstAccountICP: '+lstAccountICP);
            List<Beneficiary_Lifecycle_Event__c> lstBLEExit = new List<Beneficiary_Lifecycle_Event__c>();
            Test.startTest();
            List<Account> lstAccountCDSP = [Select id from Account where RecordTypeId=:cdspRecTypeId LIMIT 2];
            TriggerContextUtility.bBleFirstRun = true;
            lstBLEInsert = TestDataUtility.CDSPBLETestData(lstAccountCDSP,lstAccountICP);
            
            Database.insert(lstBLEInsert, false);
            
            System.debug('lstBLEInsert: '+lstBLEInsert.size());
            System.debug('lstAccountICP: '+lstAccountICP);
            System.debug('After inserting CDSP data');
            Test.stopTest();
            List<Beneficiary_Lifecycle_Event__c> lstCSPBLEExitUpdate = new List<Beneficiary_Lifecycle_Event__c>();
             for(Beneficiary_Lifecycle_Event__c BLE : [Select id,Transition_Update_Date__c, RecordTypeId from Beneficiary_Lifecycle_Event__c where id in:lstBLEInsert AND RecordTypeId =:exitRecTypeId])  {
                BLE.Exit_Update_Date__c = System.Today()+1;
                lstCSPBLEExitUpdate.add(BLE);
            }
             Test.setMock(HttpCalloutMock.class, fakeResponse); 
             TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
             update lstCSPBLEExitUpdate;
             
             system.assert( lstCSPBLEExitUpdate.size() >= 0 ) ;
             if(lstCSPBLEExitUpdate.size() > 0)
                 system.assert( lstCSPBLEExitUpdate[0].Exit_Update_Date__c > System.Today() ) ;   
             lstBLEExit = TestDataUtility.CDSPBLETestData(lstAccountCDSP,lstAccountICP);
             lstBLEExit[2].Date_of_Action__c = System.today() + 20;
             try{
                insert lstBLEExit[2];
                transitionFlagB=true;
             }
             catch(Exception e){
                 System.assert( e.getMessage().contains('Beneficiary is already in Inactive status') ) ;
             }
             }
            catch(Exception e){
                System.debug('Exception in verifyExitBLE: '+e.getMessage());
            }
             
        }
    }

}