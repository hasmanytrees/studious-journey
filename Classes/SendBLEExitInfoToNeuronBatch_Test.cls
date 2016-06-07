/******************************************************************************************************
Class Name         : SendBLEExitInfoToNeuronBatch_Test
Description        : This class contains unit tests for validating the behavior of Apex class:
                     SendBLEExitInfoToNeuronBatch
Created By         : Himanshu Raichandani
Created On         : 09-Jun-2015 
******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class SendBLEExitInfoToNeuronBatch_Test {
    
    static list<Account> lstAccountICP = new list<Account>();
    static list<Account> lstAccountCDSP = new list<Account>();
    
    static testMethod void verifyExitBLE()  {
         list<Beneficiary_Lifecycle_Event__c> lstBLEInsert = new list<Beneficiary_Lifecycle_Event__c>();
 
        list<Beneficiary_Lifecycle_Event__c> lstBLEUpdate = new list<Beneficiary_Lifecycle_Event__c>();
        Id exitRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME);
        User UserPF = new User(Id = UserInfo.getUserId());
        User UserCD = new User(Id = UserInfo.getUserId());
        list<Id> AccountId = new list<Id>();
        
        
        System.runAs(UserPF) {
            List<sObject> customSettingTransferValidation = Test.loadData(Prevent_Validation_Rule_For_Transfer__c.sObjectType, 'Prevent_Validation_for_Transfer');
            Boolean transitionFlagB = Prevent_Validation_Rule_For_Transfer__c.getOrgDefaults().Prevent_Validation_for_Transfer__c;        
            List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
            Boolean transitionFlag = Account_Prevent_Validation_on_Transition__c.getOrgDefaults().Prevent_Validation_for_Transition__c;
            List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
            JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('ExitBLEDataResponseProcess', '', false);
            insert oJsonProcess;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            //TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bFlagForTestDataBLEInsertion = false;
            Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('ExitBLEResponseFieldGroup', 'Beneficiary_Lifecycle_Event__c');
            insert oFieldGroup;
            JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('BeneficiaryEventList', oFieldGroup.Id, true, oJsonProcess.Id);
            insert oJsonStructure;
            List<Field_Group_Element__c> lstFGE = TestDataUtility.updateExitBLEFGElementsTestData(oFieldGroup.Id);
            insert lstFGE;
            List<Beneficiary_Lifecycle_Event__c> lstBLEExit = new List<Beneficiary_Lifecycle_Event__c>();
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            List<Account> lstAccount=new List<Account>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
            oICPAccount.ICP_Status__c='Active';
            lstAccount.add(oICPAccount) ;
            Account oICPAccountNew =TestDataUtility.ICPTestData() ;
            oICPAccountNew.ICP_Status__c='Active';
            oICPAccountNew.ICP_Id__c = 'TD155';
             lstAccount.add(oICPAccountNew) ;
            insert lstAccount;
            Test.startTest();
            
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            
            lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccount, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true; 
           
            insert lstAccountCDSP;
            TriggerContextUtility.bBleFirstRun = true;
            lstBLEInsert = TestDataUtility.CDSPBLETestData(lstAccountCDSP,lstAccount);
            
            insert lstBLEInsert[0];
            
            
            system.debug('###'+lstBLEInsert[0]);
            
            List<Beneficiary_Lifecycle_Event__c> lstCdSPBLEExitUpdate = new List<Beneficiary_Lifecycle_Event__c>();
             for(Beneficiary_Lifecycle_Event__c BLE : [Select id,Transition_Update_Date__c, RecordTypeId from Beneficiary_Lifecycle_Event__c where id in:lstBLEInsert AND RecordTypeId =:exitRecTypeId])  {
                BLE.Exit_Update_Date__c = System.Today()+1;
                BLE.Compass_Update_Pending__c=true;
                lstCDSPBLEExitUpdate.add(BLE);
            }
          
           
             TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
             String jsonBLEString = '{"BeneficiaryEventList": [ { "BeneficiaryId": "GH3178376", "BeneficiaryName": "Ben Afflick", "BeneficiaryLifecycleEventName": "BL-32346","RecordTypeName": "Planned_Exit", "COMPASSId": "83746", "Status": "Closed"}]}';
             HTTPRequest req = new HTTPRequest();
             req.setBody(jsonBLEString);
             SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', jsonBLEString, null);
             Test.setMock(HttpCalloutMock.class, fakeResponse);
             update lstCDSPBLEExitUpdate;
             
             SendBLEExitInfoToNeuronBatch oBatch = new SendBLEExitInfoToNeuronBatch();
             String jobId = database.executeBatch(oBatch,1);
             
             String status = [SELECT Status FROM AsyncApexJob where Id = :jobId limit 1][0].status;
             System.assert(status!='Failed');
             transitionFlagB=true;
             Test.stopTest();
        }
    }
}