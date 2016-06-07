/******************************************************************************************************
Class Name         : CommunicationKitSend_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CommunicationKitSend
Created By         : Raghavendra sharma A N
Created On         : 30-Nov-2015 
*******************************************************************************************************/
@
IsTest(SeeAllData = false)
Private class CommunicationKitSend_Test
{
    static testMethod void testComKitSend()   
    {
       
List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
            List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
            
           
            List<sObject> customSettingTransferValidation = Test.loadData(Prevent_Validation_Rule_For_Transfer__c.sObjectType, 'Prevent_Validation_for_Transfer');
    List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData'); 
        List < sObject > lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType,
            'Malnutrition_Data');
        List < sObject > lstTemplateSequencing = Test.loadData(
            Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');

        List < string > lstRegionNames = new List < String > ();
        lstRegionNames.add('testRegion');
        list < PM_Hierarchy__c > lstRegionTestData = TestDataUtility.regionTestData(
            lstRegionNames);
        insert lstRegionTestData;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun = false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        // to create test data for Field office 
        List < string > lstFieldOfficeNames = new List < String > ();
        lstFieldOfficeNames.add('Ecuador');
        list < Account > lstFieldOfficeData = TestDataUtility.FieldofficeTestData(
            lstFieldOfficeNames);
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID;
        lstFieldOfficeData[0].FO_Next_Schedule_Print_Date__c = System.Today() + 4;
        lstFieldOfficeData[0].Field_Office_Id__c = 'EC';
        insert lstFieldOfficeData;
        // To Create Territory test data 
        List < string > lstTerritoryNames = new List < String > ();
        lstTerritoryNames.add('testRegion');
        list < PM_Hierarchy__c > lstTerritoryTestData = TestDataUtility.TerritoryTestData(
            lstTerritoryNames);
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID;
        insert lstTerritoryTestData;
        List < string > lstClusterNames = new List < String > ();
        lstClusterNames.add('testCluster');
        list < PM_Hierarchy__c > lstClusterTestData = TestDataUtility.ClusterTestData(
            lstClusterNames);
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID;
        insert lstClusterTestData;
        List < Account > lstAccount = new List < Account > ();
        Account oICPAccount = TestDataUtility.ICPTestData();

        oICPAccount.Cluster__c = lstClusterTestData[0].ID;
        lstAccount.add(oICPAccount);
        insert lstAccount;



        list < Household__c > lstHousehold = TestDataUtility.HouseholdTestData();
        insert lstHousehold;
        list < Household_Member__c > lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(
            lstHousehold);
        insert lstHouseholdMember;
        Test.StartTest();

        List < Account > lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData(
            lstAccount, lstHousehold, lstHouseholdMember);
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '3-8';
        lstCDSPAccounts[0].ICP__c = lstAccount[0].ID;
        lstCDSPAccounts[1].ICP__c = lstAccount[0].ID;
        lstCDSPAccounts[1].Beneficiary_Status__c = 'Active';
        lstCDSPAccounts[0].Formal_Education_Status__c = 'Primary';
        lstCDSPAccounts[1].Formal_Education_Status__c = 'Primary';
        lstCDSPAccounts[0].Type_Of_Vocational_Education__c = 'Agriculture';
        lstCDSPAccounts[1].Type_Of_Vocational_Education__c = 'Agriculture';
        lstCDSPAccounts[0].Beneficiary_Status__c = 'Active';
        lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2';
        lstCDSPAccounts[1].Local_Grade_Level__c = 'PreSchool';
        lstCDSPAccounts[0].Local_Grade_Level__c = 'PreSchool';
        insert lstCDSPAccounts;

        Account oGlobalpartner = TestDataUtility.globalPartnerTestData(Label.Compasssion_USA_Global_Partner_Name);
        insert oGlobalpartner;
        Account oSupporterAccount = TestDataUtility.supporterTestData(oGlobalpartner);
        insert oSupporterAccount;
         System.assertNotEquals(null,oSupporterAccount);

        Send_Communication_Kit_On_Status_Change__c oCustSetting = new Send_Communication_Kit_On_Status_Change__c();
        oCustSetting.Class_to_call__c = 'CommunicationUpdates';
        oCustSetting.Communication_Kit_Status__c = 'Composition process';
        //oCustSetting.RecordType_Developer_Name__c = 'B2S';
        oCustSetting.Whom_To_Send__c = 'GP';
        oCustSetting.Name = '1';
        insert oCustSetting;
        
        String testEndPoint='SBCCommunicationDetails_GP';
        CommunicationKitSend testCommunicationKitsend = new CommunicationKitSend('res',testEndPoint,'PUT','US',true);
        QueueableContext sQueueableCOn; 
        testCommunicationKitsend.execute(sQueueableCOn);
        Test.StopTest();
        }
        
static testMethod void testComKitSendNgtve()   
    {
       
    List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
            List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
            
           
            List<sObject> customSettingTransferValidation = Test.loadData(Prevent_Validation_Rule_For_Transfer__c.sObjectType, 'Prevent_Validation_for_Transfer');
    List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBNegativeTesting'); 
        List < sObject > lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType,
            'Malnutrition_Data');
        List < sObject > lstTemplateSequencing = Test.loadData(
            Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');

        List < string > lstRegionNames = new List < String > ();
        lstRegionNames.add('testRegion');
        list < PM_Hierarchy__c > lstRegionTestData = TestDataUtility.regionTestData(
            lstRegionNames);
        insert lstRegionTestData;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun = false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        // to create test data for Field office 
        List < string > lstFieldOfficeNames = new List < String > ();
        lstFieldOfficeNames.add('Ecuador');
        list < Account > lstFieldOfficeData = TestDataUtility.FieldofficeTestData(
            lstFieldOfficeNames);
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID;
        lstFieldOfficeData[0].FO_Next_Schedule_Print_Date__c = System.Today() + 4;
        lstFieldOfficeData[0].Field_Office_Id__c = 'EC';
        insert lstFieldOfficeData;
        // To Create Territory test data 
        List < string > lstTerritoryNames = new List < String > ();
        lstTerritoryNames.add('testRegion');
        list < PM_Hierarchy__c > lstTerritoryTestData = TestDataUtility.TerritoryTestData(
            lstTerritoryNames);
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID;
        insert lstTerritoryTestData;
        List < string > lstClusterNames = new List < String > ();
        lstClusterNames.add('testCluster');
        list < PM_Hierarchy__c > lstClusterTestData = TestDataUtility.ClusterTestData(
            lstClusterNames);
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID;
        insert lstClusterTestData;
        List < Account > lstAccount = new List < Account > ();
        Account oICPAccount = TestDataUtility.ICPTestData();

        oICPAccount.Cluster__c = lstClusterTestData[0].ID;
        lstAccount.add(oICPAccount);
        insert lstAccount;



        list < Household__c > lstHousehold = TestDataUtility.HouseholdTestData();
        insert lstHousehold;
        list < Household_Member__c > lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(
            lstHousehold);
        insert lstHouseholdMember;
        Test.StartTest();

        List < Account > lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData(
            lstAccount, lstHousehold, lstHouseholdMember);
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '3-8';
        lstCDSPAccounts[0].ICP__c = lstAccount[0].ID;
        lstCDSPAccounts[1].ICP__c = lstAccount[0].ID;
        lstCDSPAccounts[1].Beneficiary_Status__c = 'Active';
        lstCDSPAccounts[0].Formal_Education_Status__c = 'Primary';
        lstCDSPAccounts[1].Formal_Education_Status__c = 'Primary';
        lstCDSPAccounts[0].Type_Of_Vocational_Education__c = 'Agriculture';
        lstCDSPAccounts[1].Type_Of_Vocational_Education__c = 'Agriculture';
        lstCDSPAccounts[0].Beneficiary_Status__c = 'Active';
        lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2';
        lstCDSPAccounts[1].Local_Grade_Level__c = 'PreSchool';
        lstCDSPAccounts[0].Local_Grade_Level__c = 'PreSchool';
        insert lstCDSPAccounts;

        Account oGlobalpartner = TestDataUtility.globalPartnerTestData(Label.Compasssion_USA_Global_Partner_Name);
        insert oGlobalpartner;
        Account oSupporterAccount = TestDataUtility.supporterTestData(oGlobalpartner);
        insert oSupporterAccount;
        System.assertNotEquals(null,oSupporterAccount);

        Send_Communication_Kit_On_Status_Change__c oCustSetting = new Send_Communication_Kit_On_Status_Change__c();
        oCustSetting.Class_to_call__c = 'CommunicationUpdates';
        oCustSetting.Communication_Kit_Status__c = 'Composition process';
        //oCustSetting.RecordType_Developer_Name__c = 'B2S';
        oCustSetting.Whom_To_Send__c = 'GP';
        oCustSetting.Name = '1';
        insert oCustSetting;
        
        CommunicationKitSend testCommunicationKitsend = new CommunicationKitSend('res',null,'POST','US',true);
        QueueableContext sQueueableCOn; 
        testCommunicationKitsend.execute(sQueueableCOn);
        Test.StopTest();
        
               
        
        
    }        
}