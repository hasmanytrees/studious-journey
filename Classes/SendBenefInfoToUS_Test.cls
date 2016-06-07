/******************************************************************************************************
Class Name         :SendBenefInfoToUS_Test
Description        : This class contains unit tests for validating the behavior of Apex class:
                     SendBenefInfoToUS_Test
Created By         :Sfurti Pandey
Created On         : 13-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class SendBenefInfoToUS_Test{
    
    @testSetup 
    static void setup() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        System.RunAs(UserPF){
        
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
            System.assertNotEquals(null,lstAccount);
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
            System.assertNotEquals(null,lstToBeUpdated);
            Test.stopTest();
            }
            catch(Exception e){
                System.debug('Exception in setup: '+e.getMessage());
            }
            
            
            
            }
       }
    
    static testMethod void verifyCSPBenef()  {
        List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('SendBenefInfoToUSProcess', 'BeneficaryProfile', false);
        insert oJsonProcess;
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData(Constants.SEND_BENEF_INFO_TO_US_FIELD_GROUP, 'Account');
        insert oFieldGroup;
        JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('BeneficiaryProfile', oFieldGroup.Id, true, oJsonProcess.Id);
        insert oJsonStructure;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.sendBenefInfoToUSFGElementsTestData(oFieldGroup.Id);
        insert lstFGE;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
        List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
        List<sObject> customSettingTransferValidation = Test.loadData(Prevent_Validation_Rule_For_Transfer__c.sObjectType, 'Prevent_Validation_for_Transfer');
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,Constants.ICP_RT_API_NAME);
        
        //SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', jsonBLEString, null);
        User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];
           
        System.runAs(UserPF) {
           
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun = false;
            Boolean transitionFlag = Account_Prevent_Validation_on_Transition__c.getOrgDefaults().Prevent_Validation_for_Transition__c;
            system.debug('------'+Account_Prevent_Validation_on_Transition__c.getOrgDefaults());
            transitionFlag=false;
            list<Account> lstAccountICP  =[Select id,Name,RecordTypeId,ICP_Status__c,ICP_ID__c,Check_Record__c,RecordType.DeveloperName from Account where RecordTypeId=:icpRecTypeId limit 2];
            List<Account> lstAccountCSP = [Select id,Beneficiary_Status__c from Account where RecordTypeId=:cspRecTypeId LIMIT 2];  
            Set<id>  setBenefIds= new Set<id>();
            for(Account acc:lstAccountCSP){
                setBenefIds.add(acc.id);
            }
            Test.startTest();
            SendBenefInfoToUS oQueueSendBenefToUS = new SendBenefInfoToUS(setBenefIds);
            System.enqueueJob(oQueueSendBenefToUS);
            Test.stopTest();
            Account acct = [SELECT Name,Phone FROM Account WHERE id=:lstAccountCSP[0].id];
            System.assertNotEquals(null, acct);
            
            
        }
    }
     static testMethod void verifyCSPBenefNegative1()  {
        List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('SendBenefInfoToUSProcess', 'BeneficaryProfile', false);
        insert oJsonProcess;
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData(Constants.SEND_BENEF_INFO_TO_US_FIELD_GROUP, 'Account');
        insert oFieldGroup;
        JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('BeneficiaryProfile', oFieldGroup.Id, true, oJsonProcess.Id);
        insert oJsonStructure;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.sendBLEfInforToAMFGElementsTestData(oFieldGroup.Id);
        insert lstFGE;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
        List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
        List<sObject> customSettingTransferValidation = Test.loadData(Prevent_Validation_Rule_For_Transfer__c.sObjectType, 'Prevent_Validation_for_Transfer');
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,Constants.ICP_RT_API_NAME);
        
        //SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', jsonBLEString, null);
        User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];
           
        System.runAs(UserPF) {
           
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun = false;
            Boolean transitionFlag = Account_Prevent_Validation_on_Transition__c.getOrgDefaults().Prevent_Validation_for_Transition__c;
            system.debug('------'+Account_Prevent_Validation_on_Transition__c.getOrgDefaults());
            transitionFlag=false;
            
            list<Account> lstAccountICP  =[Select id,Name,RecordTypeId,ICP_Status__c,ICP_ID__c,Check_Record__c,RecordType.DeveloperName from Account where RecordTypeId=:icpRecTypeId limit 2];
            List<Account> lstAccountCSP = [Select id,Beneficiary_Status__c from Account where RecordTypeId=:cspRecTypeId LIMIT 2];  
            Set<id>  setBenefIds= new Set<id>();
            for(Account acc:lstAccountCSP){
                setBenefIds.add(acc.id);
            }
            Test.startTest();
            SendBenefInfoToUS oQueueSendBenefToUS = new SendBenefInfoToUS(setBenefIds);
            System.enqueueJob(oQueueSendBenefToUS);
            Test.stopTest();
            Account acct = [SELECT Name,Phone FROM Account WHERE id=:lstAccountCSP[0].id];
            System.assertNotEquals(null, acct);
            
            
        }
    }
    static testMethod void verifyCSPBenefNegative2()  {
        List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBNegativeTesting');
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('SendBenefInfoToUSProcess', 'BeneficaryProfile', false);
        insert oJsonProcess;
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData(Constants.SEND_BENEF_INFO_TO_US_FIELD_GROUP, 'Account');
        insert oFieldGroup;
        JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('BeneficiaryProfile', oFieldGroup.Id, true, oJsonProcess.Id);
        insert oJsonStructure;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.sendBenefInfoToUSFGElementsTestData(oFieldGroup.Id);
        insert lstFGE;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
        List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
        List<sObject> customSettingTransferValidation = Test.loadData(Prevent_Validation_Rule_For_Transfer__c.sObjectType, 'Prevent_Validation_for_Transfer');
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,Constants.ICP_RT_API_NAME);
        
        //SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', jsonBLEString, null);
        User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];
           
        System.runAs(UserPF) {
           
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun = false;
            Boolean transitionFlag = Account_Prevent_Validation_on_Transition__c.getOrgDefaults().Prevent_Validation_for_Transition__c;
            system.debug('------'+Account_Prevent_Validation_on_Transition__c.getOrgDefaults());
            transitionFlag=false;
            
            list<Account> lstAccountICP  =[Select id,Name,RecordTypeId,ICP_Status__c,ICP_ID__c,Check_Record__c,RecordType.DeveloperName from Account where RecordTypeId=:icpRecTypeId limit 2];
            List<Account> lstAccountCSP = [Select id,Beneficiary_Status__c from Account where RecordTypeId=:cspRecTypeId LIMIT 2];  
            Set<id>  setBenefIds= new Set<id>();
            for(Account acc:lstAccountCSP){
                setBenefIds.add(acc.id);
            }
            Test.startTest();
                SendBenefInfoToUS oQueueSendBenefToUS = new SendBenefInfoToUS(setBenefIds);
                System.enqueueJob(oQueueSendBenefToUS);

            Test.stopTest();
                Account acct = [SELECT Name,Phone FROM Account WHERE id=:lstAccountCSP[0].id];
                System.assertNotEquals(null, acct);

                
            
        }
    }
}