/******************************************************************************************************
Class Name         : CommunicationUpdates_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CommunicationUpdates
Created By         : Rahul Agarwal 
Created On         : 11-Nov-2015 
*******************************************************************************************************/
@
IsTest(SeeAllData = false)
public class CommunicationUpdates_Test {
    static testMethod void CommunicationUpdatesRes() {
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
        lstTerritoryNames.add('East Ethiopia');
        list < PM_Hierarchy__c > lstTerritoryTestData = TestDataUtility.TerritoryTestData(
            lstTerritoryNames);
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID;
        insert lstTerritoryTestData;
        List < string > lstClusterNames = new List < String > ();
        lstClusterNames.add('East Ethiopia Cluster');
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
        lstCDSPAccounts[0].Correspondence_Country__c = 'Ethiopia';
        lstCDSPAccounts[0].Correspondence_Language__c= 'Amharic';
        lstCDSPAccounts[1].Correspondence_Country__c = 'Ethiopia';
        lstCDSPAccounts[1].Correspondence_Language__c= 'Amharic';
        insert lstCDSPAccounts;

        Account oGlobalpartner = TestDataUtility.globalPartnerTestData(Label.Compasssion_USA_Global_Partner_Name);
        insert oGlobalpartner;
        Account oSupporterAccount = TestDataUtility.supporterTestData(oGlobalpartner);
        insert oSupporterAccount;

        Send_Communication_Kit_On_Status_Change__c oCustSetting = new Send_Communication_Kit_On_Status_Change__c();
        oCustSetting.Class_to_call__c = 'CommunicationUpdates';
        oCustSetting.Communication_Kit_Status__c = 'Composition process';
        //oCustSetting.RecordType_Developer_Name__c = 'B2S';
        oCustSetting.Whom_To_Send__c = 'GP';
        oCustSetting.Name = '1';
        insert oCustSetting;

        //TestDataUtility.insertJSONProcessDetailsForSBC();
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData(
            'CommunicationUpdates_Res_PN', null, false);
        insert oJsonProcess;

        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData(
            'CommunicationUpdates_Res_FG', 'Communication_Kit__c');
        insert oFieldGroup;

        JSON_Structure__c oJSONStructure = TestDataUtility.jsonStructureTestData(
            'CommunicationUpdates', oFieldGroup.Id, true, oJsonProcess.Id);
        insert oJSONStructure;

        list < Field_Group_Element__c > lstFieldGrpElement = new list <
            Field_Group_Element__c > ();
        lstFieldGrpElement = TestDataUtility.insertFieldGroupElementForSBC(
            oFieldGroup.Id);
        insert lstFieldGrpElement;

        TestDataUtility.insertRecTypeMappingCustSetting();

        Test.StartTest();
        Commitment__c oCommitment = TestDataUtility.commitmentTestData(
            lstCDSPAccounts[0], oSupporterAccount);
        oCommitment.Status__c = 'Active';
        insert oCommitment;
        System.assertNotEquals(null,oCommitment.id);

        list < RecordType > lstRecordType = [Select Id, DeveloperName from RecordType where SObjectType =
            'Communication_Kit__c'
        ];
        map < String, RecordType > mapNameRT = new map < String, RecordType > ();
        for (RecordType oRT: lstRecordType)
            mapNameRT.put(oRT.DeveloperName, oRT);

        list < Communication_Kit__c > lstCommKitData = new List <
            Communication_Kit__c > ();
        Communication_Kit__c oCommKitData = TestDataUtility.commKitTestData(
            lstCDSPAccounts[0], oSupporterAccount, oICPAccount);
        oCommKitData.RecordTypeId = mapNameRT.get('B2S').Id;
        oCommKitData.Status__c = 'Composition process';
        oCommKitData.Communication_Types__c = 'New Sponsor Letter';
        lstCommKitData.add(oCommKitData);

        Communication_Kit__c oCommKitData2 = TestDataUtility.commKitTestData(
            lstCDSPAccounts[0], oSupporterAccount, oICPAccount);
        oCommKitData2.RecordTypeId = mapNameRT.get('S2B').Id;
        oCommKitData2.Status__c = 'Composition process';
        oCommKitData2.Communication_Types__c = 'New Sponsor Letter';
        lstCommKitData.add(oCommKitData2);
        insert lstCommKitData;
        System.assertNotEquals(null,lstCommKitData);
        Test.StopTest();
    }
    
    static testMethod void CommunicationUpdatesReq() {
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
        lstTerritoryNames.add('East Ethiopia');
        list < PM_Hierarchy__c > lstTerritoryTestData = TestDataUtility.TerritoryTestData(
            lstTerritoryNames);
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID;
        insert lstTerritoryTestData;
        List < string > lstClusterNames = new List < String > ();
        lstClusterNames.add('East Ethiopia Cluster');
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
        lstCDSPAccounts[0].Compass_Id__c = '12345';
        lstCDSPAccounts[1].Compass_Id__c = '123456';
        lstCDSPAccounts[0].Correspondence_Country__c = 'Ethiopia';
        lstCDSPAccounts[0].Correspondence_Language__c= 'Amharic';
        lstCDSPAccounts[1].Correspondence_Country__c = 'Ethiopia';
        lstCDSPAccounts[1].Correspondence_Language__c= 'Amharic';
        insert lstCDSPAccounts;

        Account oGlobalpartner = TestDataUtility.globalPartnerTestData(Label.Compasssion_USA_Global_Partner_Name);
        insert oGlobalpartner;
        Account oSupporterAccount = TestDataUtility.supporterTestData(oGlobalpartner);
        oSupporterAccount.GP_Supporter_ID__c = '12345';
        insert oSupporterAccount;

        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData(
            'CommunicationUpdates_Req_PN', null, false);
        insert oJsonProcess;

        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData(
            'CommunicationUpdates_Req_FG', 'Communication_Kit__c');
        insert oFieldGroup;

        JSON_Structure__c oJSONStructure = TestDataUtility.jsonStructureTestData(
            'CommunicationUpdates', oFieldGroup.id, true, oJsonProcess.Id);
        insert oJSONStructure;

        list < Field_Group_Element__c > lstFGE = new list < Field_Group_Element__c >
            ();
        lstFGE = TestDataUtility.insertFieldGroupElementForSBC2(oFieldGroup.id);
        insert lstFGE;

        TestDataUtility.insertRecTypeMappingCustSetting();

        Commitment__c oCommitment = TestDataUtility.commitmentTestData(
            lstCDSPAccounts[0], oSupporterAccount);
        oCommitment.Status__c = 'Active';
        oCommitment.Relationship_Type__c = 'Sponsor';
        oCommitment.Supporter_Correspondence_Language__c = 'Spanish';
        insert oCommitment;
        System.assertNotEquals(null,oCommitment.id);
        test.stopTest();
        list < Account > lstBenef = [select Id, Global_Number__c,
            Local_Beneficiary_ID__c, Compass_Id__c from Account where ICP__c != '' Limit 1
        ];

        Account oSup = [select Id, Global_Number__c, GP_Supporter_ID__c from Account where Global_Partner__c !=
            ''
            limit 1
        ];
        String sJSON1 =
            '{"CommunicationUpdates": [{"Direction":"Supporter To Beneficiary", "SBCGlobalStatus":"ABC", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "Perceptive", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';
        String sJSON2 =
            '{"CommunicationUpdates": [{"SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive", "' + Constants.SBC_TYPE_NAME + '":["A","B","C"]}]}';
        String sJSON3 =
            '{"CommunicationUpdates": [{"SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive","Template":"12345"}]}';
        String sJSON4 =
            '{"CommunicationUpdates": [{"SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive","Template":"12345", "Internal_Perceptive_TransactionId":"12345"}]}';
        String sJSON5 = '{"CommunicationUpdates": [{}]}';
        String sJSON6 =
            '{"CommunicationUpdates": [{"SourceSystem": "Perceptive"}]}';
        String sJSON7 =
            '{"CommunicationUpdates": [{"CompassionSBCId":" ","SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive","Template":"12345", "Internal_Perceptive_TransactionId":"12345","OriginalLetterURL":"www.www.com"}]}';
        String sJSON8 =
            '{"CommunicationUpdates": [{"Direction":"ABC","SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive","Template":"12345", "Internal_Perceptive_TransactionId":"12345","OriginalLetterURL":"www.www.com"}]}';
        String sJSON9 =
            '{"CommunicationUpdates": [{"Direction":null,"SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive","Template":"12345", "Internal_Perceptive_TransactionId":"12345","OriginalLetterURL":"www.www.com"}]}';
        String sJSON10 =
            '{"CommunicationUpdates": [{"Direction":"Supporter To Beneficiary", "SBCGlobalStatus":"ABC", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "Perceptive", "Beneficiary_GlobalId":"112233", "Beneficiary_LocalId": "' +
            lstBenef[0].Local_Beneficiary_ID__c + '", "Beneficiary_CompassId":"' +
            lstBenef[0].Compass_Id__c + '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';
        String sJSON11 =
            '{"CommunicationUpdates": [{"OriginalText":"OriginalText", "RelationshipType":"Sponsor","Direction":"Supporter To Beneficiary", "SBCGlobalStatus":"ABC", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "Perceptive", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl() +
            'services/apexrest/CommunicationUpdates';
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueof(sJSON1);
        RestContext.request = req;
        RestContext.response = res;
        CommunicationUpdates.reqCommunicationUpdates();

        req.requestBody = Blob.valueof(sJSON2);
        RestContext.request = req;
        RestContext.response = res;
        CommunicationUpdates.reqCommunicationUpdates();

        req.requestBody = Blob.valueof(sJSON3);
        RestContext.request = req;
        RestContext.response = res;
        CommunicationUpdates.reqCommunicationUpdates();

        req.requestBody = Blob.valueof(sJSON4);
        RestContext.request = req;
        RestContext.response = res;
        CommunicationUpdates.reqCommunicationUpdates();

        req.requestBody = Blob.valueof(sJSON5);
        RestContext.request = req;
        RestContext.response = res;
        CommunicationUpdates.reqCommunicationUpdates();

        req.requestBody = Blob.valueof(sJSON6);
        RestContext.request = req;
        RestContext.response = res;
        CommunicationUpdates.reqCommunicationUpdates();

        req.requestBody = Blob.valueof(sJSON7);
        RestContext.request = req;
        RestContext.response = res;
        CommunicationUpdates.reqCommunicationUpdates();

        req.requestBody = Blob.valueof(sJSON8);
        RestContext.request = req;
        RestContext.response = res;
        CommunicationUpdates.reqCommunicationUpdates();

        req.requestBody = Blob.valueof(sJSON9);
        RestContext.request = req;
        RestContext.response = res;
        CommunicationUpdates.reqCommunicationUpdates();

        req.requestBody = Blob.valueof(sJSON10);
        RestContext.request = req;
        RestContext.response = res;
        CommunicationUpdates.reqCommunicationUpdates();

        req.requestBody = Blob.valueof(sJSON11);
        RestContext.request = req;
        RestContext.response = res;
        CommunicationUpdates.reqCommunicationUpdates();

        
    }
}