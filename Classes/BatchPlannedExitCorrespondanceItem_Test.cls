/******************************************************************************************************
Class Name         : BatchPlannedExitCorrespondanceItem_Test
Description        : This class contains unit tests for validating the behavior of Apex class: BatchPlannedExitCorrespondanceItem
Created By         : Rahul Agarwal 
Created On         : 11-Nov-2015 
*******************************************************************************************************/
@
IsTest(SeeAllData = false)
public class BatchPlannedExitCorrespondanceItem_Test {
    static testMethod void verifyBatchPlannedExitCorrespondanceItem() {
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
        lstCDSPAccounts[0].Planned_Completion_Date__c = system.today().addDays(Integer.ValueOf(Label.Planned_Completion_Thank_You_Letter));
        insert lstCDSPAccounts;
        
        System.assertEquals(2,lstCDSPAccounts.size());        
        BatchPlannedExitCorrespondanceItem b = new BatchPlannedExitCorrespondanceItem();
        database.executeBatch(b);
        Test.StopTest();
    }
}