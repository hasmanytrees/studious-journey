/******************************************************************************************************
Class Name         : CommunicationKitSearchPageController_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CommunicationKitSearchPageController
Created By         : Akashdeep 
Created On         : 8-Oct-2015 
*******************************************************************************************************/
@
IsTest(SeeAllData = false)
public class BatchMergeCommunications_Test {

    static testMethod void verifyBatchMergeCommunications() {
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
        TriggerContextUtility.bFlagForTestDataBLEInsertion = False;
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
        Test.StartTest();
        Commitment__c oCommitment = TestDataUtility.commitmentTestData(
            lstCDSPAccounts[0], oSupporterAccount);
        oCommitment.Status__c = 'Active';
        insert oCommitment;
        Id B2SRecordType = [Select Id from RecordType where DeveloperName = 'B2S'
            AND SObjectType = 'Communication_Kit__c'
            limit 1
        ].Id;
        Commitment__c oCommitmentnew = TestDataUtility.commitmentTestData(
            lstCDSPAccounts[1], oSupporterAccount);
        oCommitmentnew.Status__c = 'Active';
        insert oCommitmentnew;
        
        
        list < Communication_Kit__c > lstCommKitData = new List <
            Communication_Kit__c > ();
        Communication_Kit__c oCommKitData = TestDataUtility.commKitTestData(
            lstCDSPAccounts[0], oSupporterAccount, oICPAccount);
        oCommKitData.RecordTypeId = B2SRecordType;
        oCommKitData.Status__c = 'Ready to be printed';
        oCommKitData.Communication_Types__c = 'New Sponsor Letter';
        
        Communication_Kit__c oCommKitDatanew = TestDataUtility.commKitTestData(
            lstCDSPAccounts[1], oSupporterAccount, oICPAccount);
        oCommKitDatanew.RecordTypeId = B2SRecordType;
        oCommKitDatanew.Status__c = 'Ready to be printed';
        oCommKitDatanew.Communication_Types__c = 'New Sponsor Letter';
        lstCommKitData.add(oCommKitDatanew);
        
        Communication_Kit__c oCommKitDatanew2 = TestDataUtility.commKitTestData(
            lstCDSPAccounts[1], oSupporterAccount, oICPAccount);
        oCommKitDatanew2.RecordTypeId = B2SRecordType;
        oCommKitDatanew2.Status__c = 'Ready to be printed';
        oCommKitDatanew2.Communication_Types__c = 'New Sponsor Letter';
        lstCommKitData.add(oCommKitDatanew2);
        
        Communication_Kit__c oCommKitDatanew3 = TestDataUtility.commKitTestData(
            lstCDSPAccounts[1], oSupporterAccount, oICPAccount);
        oCommKitDatanew3.RecordTypeId = B2SRecordType;
        oCommKitDatanew3.Status__c = 'Ready to be printed';
        oCommKitDatanew3.Communication_Types__c = 'New Sponsor Letter';
        lstCommKitData.add(oCommKitDatanew3);
        
        insert lstCommKitData;
        Contact contactGP = new Contact(FirstName = 'Bob', LastName = 'Phillip',
            AccountId = lstAccount[0].Id);
        insert contactGP;
        Global_Data__c globalDataMalnutrition = new Global_Data__c(Age_In_Months__c =
            60, Length__c = 100,
            SD1__c = 16.799000, SD2__c = 18.589000, SD3neg__c = 12.155000, SD2neg__c =
            11.257000, Gender__c = 'Male',
            Malnutrition_Data_Type__c = 'BMI');
        insert globalDataMalnutrition;
        Id globaldataCommKitRecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Global_Data__c.SObjectType, Constants.GLOBAL_DATA_COMM_KIT_DATA_RT_API_NAME
        );
        

        Global_Data__c globalDataEducation = new Global_Data__c(
            US_Equivalent_Grade_Level__c = '5',
            Local_Grade_Level__c = 'Primary 5B', Country__c = 'Ecuador');
        insert globalDataEducation;
        System.assertNotEquals(null,globalDataEducation);
        BatchMergeCommunications bmc = new BatchMergeCommunications();
        Database.executeBatch(bmc);
    }
}