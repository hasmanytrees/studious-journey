/******************************************************************************************************
Class Name         : CreateGiftResponses_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CreateGiftResponses
Created By         : Raghavendra sharma A N
Created On         : 26-Nov-2015 
*******************************************************************************************************/
@
IsTest(SeeAllData = false)
public class CreateGiftResponses_Test{
    static testMethod void CreateGiftResponsesRes() {
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
        lstFieldOfficeNames.add('Ethiopia');
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
        test.startTest(); 
        list < Household_Member__c > lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(
            lstHousehold);
        insert lstHouseholdMember;

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
         lstCDSPAccounts[0].Correspondence_Country__c = 'Ethiopia';
        lstCDSPAccounts[0].Correspondence_Language__c= 'Amharic';
        lstCDSPAccounts[1].Correspondence_Country__c = 'Ethiopia';
        lstCDSPAccounts[1].Correspondence_Language__c= 'Amharic';
        insert lstCDSPAccounts;

        Account oGlobalpartner = TestDataUtility.globalPartnerTestData(Label.Compasssion_USA_Global_Partner_Name);
        insert oGlobalpartner;
        Account oSupporterAccount = TestDataUtility.supporterTestData(oGlobalpartner);
        insert oSupporterAccount;
        System.assertNotEquals(null,oSupporterAccount.id);
        Send_Communication_Kit_On_Status_Change__c oCustSetting = new Send_Communication_Kit_On_Status_Change__c();
        oCustSetting.Class_to_call__c = 'CommunicationUpdates';
        oCustSetting.Communication_Kit_Status__c = 'Composition process';
        //oCustSetting.RecordType_Developer_Name__c = 'B2S';
        oCustSetting.Whom_To_Send__c = 'GP';
        oCustSetting.Name = '1';
        insert oCustSetting;
        
         JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData(
            'CreateGiftResponses_Res_PN',null,false);
        insert oJsonProcess;

        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData(
            'CreateGiftResponses_Res_FG', 'Communication_Kit__c');
        insert oFieldGroup;

        JSON_Structure__c oJSONStructure = TestDataUtility.jsonStructureTestData(
            'CreateGiftResponses', oFieldGroup.Id, true, oJsonProcess.Id);
        insert oJSONStructure;

        list < Field_Group_Element__c > lstFieldGrpElement = new list <Field_Group_Element__c > ();
        
        lstFieldGrpElement = TestDataUtility.CreateGiftResponsesFieldGroupElementForSBC(oFieldGroup.Id);
        system.debug('@@@'+oFieldGroup.Id);
        insert lstFieldGrpElement;
        System.assertNotEquals(null,lstFieldGrpElement);
        
        TestDataUtility.insertRecTypeMappingCustSetting();

        Commitment__c oCommitment = TestDataUtility.commitmentTestData(
            lstCDSPAccounts[0], oSupporterAccount);
        oCommitment.Status__c = 'Active';
        oCommitment.Relationship_Type__c = 'Sponsor';
        oCommitment.Supporter_Correspondence_Language__c = 'Spanish';
        insert oCommitment;
        test.stopTest();
        list < Account > lstBenef = [select Id, Global_Number__c,Local_Beneficiary_ID__c, Compass_Id__c from Account where ICP__c != '' limit 1];

        Account oSup = [select Id, Global_Number__c, GP_Supporter_ID__c from Account where Global_Partner__c !=''limit 1];
        String sJSON1 ='{ "BeneficiaryGifts": [ { "LegacySupporterId": null, "LegacyBeneficiaryId": null, "GiftAmount": "123", "GlobalSupporterId": "06448474", "GlobalBeneficiaryId": "06448417", "LocalBeneficiaryId": "EC4210642" } ] } ';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl() +
            'services/apexrest/CreateGiftResponses';
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueof(sJSON1);
        RestContext.request = req;
        RestContext.response = res;
        CreateGiftResponses.createGiftResponsesJSON();
} 
}