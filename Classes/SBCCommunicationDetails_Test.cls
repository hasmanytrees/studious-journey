@isTest(SeeAllData = false)
private class SBCCommunicationDetails_Test {
    
    
    
    static testMethod void SBCCommunicationDetailsRes() {
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false; 
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

        Send_Communication_Kit_On_Status_Change__c oCustSetting = new Send_Communication_Kit_On_Status_Change__c();
        oCustSetting.Class_to_call__c = 'SBCCommunicationDetails';
        oCustSetting.Communication_Kit_Status__c = 'Composition process';
        //oCustSetting.RecordType_Developer_Name__c = 'B2S';
        oCustSetting.Whom_To_Send__c = 'GP';
        oCustSetting.Name = '1';
        insert oCustSetting;

        //TestDataUtility.insertJSONProcessDetailsForSBC();
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData(
            'SBCCommunicationDetails_Res_PN', null, false);
        insert oJsonProcess;

        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData(
            'SBCCommunicationDetails_Res_FG', 'Communication_Kit__c');
        insert oFieldGroup;

        JSON_Structure__c oJSONStructure = TestDataUtility.jsonStructureTestData(
            'SBCCommunicationDetails', oFieldGroup.Id, true, oJsonProcess.Id);
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
        oCommKitData.RecordTypeId = mapNameRT.get('S2B').Id;
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
     /*
    static testMethod void SBCCommunicationDetailsReq() {
        
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false; 
    
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
        lstCDSPAccounts[0].Compass_Id__c = '12345';
        lstCDSPAccounts[1].Compass_Id__c = '123456';
        insert lstCDSPAccounts;

        Account oGlobalpartner = TestDataUtility.globalPartnerTestData(Label.Compasssion_USA_Global_Partner_Name);
        insert oGlobalpartner;
        Account oSupporterAccount = TestDataUtility.supporterTestData(oGlobalpartner);
        oSupporterAccount.GP_Supporter_ID__c = '12345';
        insert oSupporterAccount;

        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData(
            'SBCCommunicationDetails_Req_PN', null, false);
        insert oJsonProcess;

        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData(
            'SBCCommunicationDetails_Req_FG', 'Communication_Kit__c');
        insert oFieldGroup;

        JSON_Structure__c oJSONStructure = TestDataUtility.jsonStructureTestData(
            'SBCCommunicationDetails', oFieldGroup.id, true, oJsonProcess.Id);
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
         test.startTest();
        list < Account > lstBenef = [select Id, Global_Number__c,
            Local_Beneficiary_ID__c, Compass_Id__c from Account where ICP__c != ''
        ];
       
        Account oSup = [select Id, Global_Number__c, GP_Supporter_ID__c from Account where Global_Partner__c !=
            ''
            limit 1
        ];
        String sJSON1 =
            '{"SBCCommunicationDetails": [{"Direction":"Supporter To Beneficiary", "SBCGlobalStatus":"ABC", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "Perceptive", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';
        String sJSON2 =
            '{"SBCCommunicationDetails": [{"SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive"}]}';
        String sJSON3 =
            '{"SBCCommunicationDetails": [{"SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive","Template":"12345"}]}';
        String sJSON4 =
            '{"SBCCommunicationDetails": [{"SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive","Template":"12345", "Internal_Perceptive_TransactionId":"12345"}]}';
        String sJSON5 = '{"SBCCommunicationDetails": [{}]}';
        String sJSON6 =
            '{"SBCCommunicationDetails": [{"SourceSystem": "Perceptive"}]}';
        String sJSON7 =
            '{"SBCCommunicationDetails": [{"CompassionSBCId":" ","SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive","Template":"12345", "Internal_Perceptive_TransactionId":"12345","OriginalLetterURL":"www.www.com"}]}';
        String sJSON8 =
            '{"SBCCommunicationDetails": [{"Direction":"ABC","SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive","Template":"12345", "Internal_Perceptive_TransactionId":"12345","OriginalLetterURL":"www.www.com"}]}';
        String sJSON9 =
            '{"SBCCommunicationDetails": [{"Direction":null,"SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive","Template":"12345", "Internal_Perceptive_TransactionId":"12345","OriginalLetterURL":"www.www.com"}]}';
        String sJSON10 =
            '{"SBCCommunicationDetails": [{"Direction":"Supporter To Beneficiary", "SBCGlobalStatus":"ABC", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "Perceptive", "Beneficiary_GlobalId":"112233", "Beneficiary_LocalId": "' +
            lstBenef[0].Local_Beneficiary_ID__c + '", "Beneficiary_CompassId":"' +
            lstBenef[0].Compass_Id__c + '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';
        String sJSON11 =
            '{"SBCCommunicationDetails": [{"OriginalText":"OriginalText", "RelationshipType":"Sponsor","Direction":"Supporter To Beneficiary", "SBCGlobalStatus":"ABC", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "Perceptive", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';


        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl() +
            'services/apexrest/SBCCommunicationDetails';
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueof(sJSON1);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON2);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON3);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON4);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON5);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON6);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON7);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON8);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON9);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON10);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON11);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();
        test.stopTest();
    }

    static testMethod void SBCCommunicationDetailsReq2() {
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false; 
        
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
        lstCDSPAccounts[0].Compass_Id__c = '12345';
        lstCDSPAccounts[1].Compass_Id__c = '123456';
        insert lstCDSPAccounts;

        Account oGlobalpartner = TestDataUtility.globalPartnerTestData(Label.Compasssion_USA_Global_Partner_Name);
        oGlobalpartner.Opted_in_for_SDL__c = true;
        insert oGlobalpartner;
        Account oSupporterAccount = TestDataUtility.supporterTestData(oGlobalpartner);
        oSupporterAccount.GP_Supporter_ID__c = '12345';
        insert oSupporterAccount;

        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData(
            'SBCCommunicationDetails_Req_PN', null, false);
        insert oJsonProcess;

        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData(
            'SBCCommunicationDetails_Req_FG', 'Communication_Kit__c');
        insert oFieldGroup;

        JSON_Structure__c oJSONStructure = TestDataUtility.jsonStructureTestData(
            'SBCCommunicationDetails', oFieldGroup.id, true, oJsonProcess.Id);
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
        
        list < Account > lstBenef = [select Id, Global_Number__c,
            Local_Beneficiary_ID__c, Compass_Id__c from Account where ICP__c != ''
        ];
  Test.StartTest();
        Account oSup = [select Id, Global_Number__c, GP_Supporter_ID__c from Account where Global_Partner__c !=
            ''
            limit 1
        ];
        String sJSON11 =
            '{"SBCCommunicationDetails": [{"Direction":"Beneficiary To Supporter", "SBCGlobalStatus":"ABC", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "Perceptive", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c + '"}]}';
        String sJSON12 =
            '{"SBCCommunicationDetails": [{"RelationshipType":"Sponsor","Direction":"Supporter To Beneficiary", "SBCGlobalStatus":"ABC", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "Perceptive", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';
        String sJSON13 =
            '{"SBCCommunicationDetails": [{"RelationshipType":"Correspondent","Direction":"Supporter To Beneficiary", "SBCGlobalStatus":"ABC", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "Perceptive", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';
        String sJSON14 =
            '{"SBCCommunicationDetails": [{"OriginalText":"OriginalText", "RelationshipType":"Sponsor","Direction":"Supporter To Beneficiary", "SBCGlobalStatus":"ABC", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "Perceptive", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';

       
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl() +
            'services/apexrest/SBCCommunicationDetails';
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueof(sJSON11);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON12);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON13);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON14);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

         test.stopTest();
        
    }*/

    static testMethod void SBCCommunicationDetailsReq3() 
    {    
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false; 
        
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
        lstCDSPAccounts[0].Compass_Id__c = '12345';
        lstCDSPAccounts[1].Compass_Id__c = '123456';
        insert lstCDSPAccounts;

        Account oGlobalpartner = TestDataUtility.globalPartnerTestData(Label.Compasssion_USA_Global_Partner_Name);
        oGlobalpartner.Opted_in_for_SDL__c = true;
        insert oGlobalpartner;
        Account oSupporterAccount = TestDataUtility.supporterTestData(oGlobalpartner);
        oSupporterAccount.GP_Supporter_ID__c = '12345';
        insert oSupporterAccount;

        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData(
            'SBCCommunicationDetails_Req_PN', null, false);
        insert oJsonProcess;

        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData(
            'SBCCommunicationDetails_Req_FG', 'Communication_Kit__c');
        insert oFieldGroup;

        JSON_Structure__c oJSONStructure = TestDataUtility.jsonStructureTestData(
            'SBCCommunicationDetails', oFieldGroup.id, true, oJsonProcess.Id);
        insert oJSONStructure;

        list < Field_Group_Element__c > lstFGE = new list < Field_Group_Element__c >
            ();
        lstFGE = TestDataUtility.insertFieldGroupElementForSBC2(oFieldGroup.id);
        insert lstFGE;

        TestDataUtility.insertRecTypeMappingCustSetting();
        test.starttest();

        Commitment__c oCommitment = TestDataUtility.commitmentTestData(
            lstCDSPAccounts[0], oSupporterAccount);
        oCommitment.Status__c = 'Active';
        oCommitment.Relationship_Type__c = 'Sponsor';
        oCommitment.Supporter_Correspondence_Language__c = 'Spanish';
        insert oCommitment;
        System.assertNotEquals(null,oCommitment.id);
        System.assertNotEquals(null,oCommitment.id);
        list < Account > lstBenef = [select Id, Global_Number__c,
            Local_Beneficiary_ID__c, Compass_Id__c from Account where ICP__c != ''
        ];

        Account oSup = [select Id, Global_Number__c, GP_Supporter_ID__c from Account where Global_Partner__c !=
            ''
            limit 1
        ];

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
        

        list < Communication_Kit__c > lstCommKit = [select Id, Name from Communication_Kit__c limit 5];
        String sJSON15 = '{"SBCCommunicationDetails": [{"CompassionSBCId":"' +
            lstCommKit[1].Name +
            '", "OriginalText":"OriginalText", "RelationshipType":"Sponsor","Direction":"Supporter To Beneficiary", "SBCGlobalStatus":"Translation and quality check complete", "NumberOfPages":"2","OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "SDL", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';
        String sJSON16 = '{"SBCCommunicationDetails": [{"CompassionSBCId":"' +
            lstCommKit[1].Name +
            '", "TranslatedText":"TranslatedText", "OriginalText":"OriginalText", "RelationshipType":"Sponsor","Direction":"Supporter To Beneficiary", "SBCGlobalStatus":"Translation and quality check complete", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "SDL", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';
        String sJSON17 = '{"SBCCommunicationDetails": [{"CompassionSBCId":"' +
            lstCommKit[0].Name +
            '", "OriginalText":"OriginalText", "RelationshipType":"Sponsor","Direction":"Beneficiary To Supporter", "SBCGlobalStatus":"Translation and quality check complete", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "SDL", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';
        String sJSON18 = '{"SBCCommunicationDetails": [{"CompassionSBCId":"' +
            lstCommKit[0].Name +
            '", "TranslatedText":"TranslatedText", "OriginalText":"OriginalText", "RelationshipType":"Sponsor","Direction":"Beneficiary To Supporter", "SBCGlobalStatus":"Translation and quality check complete", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "SDL", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';
        String sJSON19 =
            '{"SBCCommunicationDetails": [{"TranslatedText":"TranslatedText", "OriginalText":"OriginalText", "RelationshipType":"Sponsor","Direction":"Beneficiary To Supporter", "SBCGlobalStatus":"Translation and quality check complete", "OriginalLetterURL":"www.www.com", "Internal_Perceptive_TransactionId":"12345","Template":"12345", "SourceSystem": "SDL", "Beneficiary_GlobalId":"' +
            lstBenef[0].Global_Number__c + '", "Beneficiary_LocalId": "' + lstBenef[0].Local_Beneficiary_ID__c +
            '", "Beneficiary_CompassId":"' + lstBenef[0].Compass_Id__c +
            '", "Supporter_CompassConstituentId":"' + oSup.GP_Supporter_ID__c +
            '", "Supporter_GlobalId":"' + oSup.Global_Number__c + '"}]}';


        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl() +
            'services/apexrest/SBCCommunicationDetails';
        req.httpMethod = 'POST';
        
        req.requestBody = Blob.valueof(sJSON15);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();
        test.stopTest();
        /*
        req.requestBody = Blob.valueof(sJSON16);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();
        
        req.requestBody = Blob.valueof(sJSON17);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON18);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();

        req.requestBody = Blob.valueof(sJSON19);
        RestContext.request = req;
        RestContext.response = res;
        SBCCommunicationDetails.reqSBCCommunicationDetails();
        */
        
    }
}