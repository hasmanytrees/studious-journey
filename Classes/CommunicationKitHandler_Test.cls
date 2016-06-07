/******************************************************************************************************
Class Name         : CommunicationKitSearchPageController_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CommunicationKitSearchPageController
Created By         : Akashdeep 
Created On         : 8-Oct-2015 
*******************************************************************************************************/
@
IsTest(SeeAllData = false)
public class CommunicationKitHandler_Test {
    static testMethod void verifyCommunicationKitHandler() {
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun = false;
        List < sObject > lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType,
            'Malnutrition_Data');
        List < string > lstRegionNames = new List < String > ();
        lstRegionNames.add('testRegion');
        list < PM_Hierarchy__c > lstRegionTestData = TestDataUtility.regionTestData(
            lstRegionNames);
        insert lstRegionTestData;
        // to create test data for Field office 
        List < string > lstFieldOfficeNames = new List < String > ();
        lstFieldOfficeNames.add('testFieldOffice');
        list < Account > lstFieldOfficeData = TestDataUtility.FieldofficeTestData(
            lstFieldOfficeNames);
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID;
        insert lstFieldOfficeData;
        // To Create Territory test data 
        List < string > lstTerritoryNames = new List < String > ();
        lstTerritoryNames.add('testRegion');
        list < PM_Hierarchy__c > lstTerritoryTestData = TestDataUtility.TerritoryTestData(
            lstTerritoryNames);
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID;
        List < string > lstClusterNames = new List < String > ();
        lstClusterNames.add('testCluster');
        list < PM_Hierarchy__c > lstClusterTestData = TestDataUtility.ClusterTestData(
            lstClusterNames);
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID;
        insert lstClusterTestData;
        List < Account > lstAccount = new List < Account > ();
        Account oICPAccount = TestDataUtility.ICPTestData();
        lstAccount.add(oICPAccount);

        lstAccount[0].Cluster__c = lstClusterTestData[0].ID;

        list < Household__c > lstHousehold = TestDataUtility.HouseholdTestData();
        insert lstHousehold;
        list < Household_Member__c > lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(
            lstHousehold);
        insert lstHouseholdMember;

        List < Account > lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData(
            lstAccount, lstHousehold, lstHouseholdMember);
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '3=8';
        lstCDSPAccounts[0].ICP__c = oICPAccount.ID;
        lstCDSPAccounts[1].Beneficiary_Status__c = 'Active';
        lstCDSPAccounts[0].Formal_Education_Status__c = 'Primary';
        lstCDSPAccounts[1].Formal_Education_Status__c = 'Primary';
        lstCDSPAccounts[0].Type_Of_Vocational_Education__c = 'Agriculture';
        lstCDSPAccounts[1].Type_Of_Vocational_Education__c = 'Agriculture';
        lstCDSPAccounts[0].Beneficiary_Status__c = 'Active';
        lstCDSPAccounts[1].Local_Grade_Level__c = 'PreSchool';
        lstCDSPAccounts[0].Local_Grade_Level__c = 'PreSchool';
        lstCDSPAccounts.add(lstCDSPAccounts[0].clone());
        lstCDSPAccounts[2].Local_Beneficiary_Number__c = '6389';
        lstCDSPAccounts[2].Compass_Id__c = '63899';
        lstCDSPAccounts[2].PO_Number__c = '63899';
        lstCDSPAccounts[2].Local_Beneficiary_Id__c = 'EC3476389';
        lstCDSPAccounts[2].BEN_Last_Wrote__c = system.today() + 1;
        lstCDSPAccounts.add(lstCDSPAccounts[0].clone());
        lstCDSPAccounts[3].Local_Beneficiary_Number__c = '6384';
        lstCDSPAccounts[3].Compass_Id__c = '63844';
        lstCDSPAccounts[3].PO_Number__c = '63844';
        lstCDSPAccounts[3].Local_Beneficiary_Id__c = 'EC3476384';
        lstCDSPAccounts[3].BEN_Last_Wrote__c = system.today() - 100;
        lstCDSPAccounts.add(lstCDSPAccounts[0].clone());
        lstCDSPAccounts[4].Local_Beneficiary_Number__c = '6380';
        lstCDSPAccounts[4].Compass_Id__c = '63840';
        lstCDSPAccounts[4].PO_Number__c = '638440';
        lstCDSPAccounts[4].Local_Beneficiary_Id__c = 'EC3476380';
        lstCDSPAccounts[4].BEN_Last_Wrote__c = system.today() - 100;
        insert lstCDSPAccounts;
        Account oGlobalpartner = TestDataUtility.globalPartnerTestData(Label.Compasssion_USA_Global_Partner_Name);
        insert oGlobalpartner;
        Account oSupporterAccount = TestDataUtility.supporterTestData(oGlobalpartner);
        insert oSupporterAccount;
        System.assertNotEquals(null,oSupporterAccount.id);

        list < Commitment__c > lstCommitment = new list < Commitment__c > ();
        lstCommitment.add(TestDataUtility.commitmentTestData(lstCDSPAccounts[0],
            oSupporterAccount));
        lstCommitment.add(TestDataUtility.commitmentTestData(lstCDSPAccounts[1],
            oSupporterAccount));
        lstCommitment.add(TestDataUtility.commitmentTestData(lstCDSPAccounts[2],
            oSupporterAccount));
        lstCommitment.add(TestDataUtility.commitmentTestData(lstCDSPAccounts[3],
            oSupporterAccount));
        lstCommitment[0].Status__c = 'Active';
        lstCommitment[1].Relationship_Type__c = 'Correspondent';
        lstCommitment[1].Status__c = 'Active';
        lstCommitment[2].Relationship_Type__c = 'Sponsor';
        lstCommitment[2].Status__c = 'Active';
        lstCommitment[3].Relationship_Type__c = 'Correspondent';
        lstCommitment[3].Status__c = 'Active';
        insert lstCommitment;
        System.assertEquals(4,lstCommitment.size());
        Test.StartTest();


        list < Communication_Kit__c > lstCommKit = new list < Communication_Kit__c >
            ();
        Communication_Kit__c oCommKitData = TestDataUtility.commKitTestData(
            lstCDSPAccounts[0], oSupporterAccount, oICPAccount);
        oCommKitData.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_B2S_RT);
        oCommKitData.Status__c = 'Ready to be printed';
        oCommKitData.Communication_Types__c =
            'New Sponsor;New Sponsor;Response;Response';
        lstCommKit.add(oCommKitData);

        Communication_Kit__c oCommKitData2 = TestDataUtility.commKitTestData(
            lstCDSPAccounts[1], oSupporterAccount, oICPAccount);
        oCommKitData2.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_B2S_RT);
        oCommKitData2.Status__c = 'Ready to be printed';
        oCommKitData2.Communication_Types__c = null;
        lstCommKit.add(oCommKitData2);

        insert lstCommKit;
        CommunicationKitHandler oCKH = new CommunicationKitHandler();
        CommunicationKitHandler.findOrCreateCommKitRecord(new map < String, String > {
            lstCDSPAccounts[0].Local_Beneficiary_Id__c => 'New Sponsor',
                lstCDSPAccounts[1].Local_Beneficiary_Id__c => 'New Sponsor',
                lstCDSPAccounts[2].Local_Beneficiary_Id__c => 'New Sponsor',
                lstCDSPAccounts[3].Local_Beneficiary_Id__c => 'New Sponsor'
        },null);

        String sJSON =
            '{"SBCCommunicationDetails": [{"SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive",  "SBCTypes": ["A","B"]}]}';
        CommunicationKitHandler.responseForValidationWrapper oDesJSON =
            CommunicationKitHandler.deserializeJson(sJSON, true, Constants.SBCCOMMUNICATIONDETAILS_REQ_PN);

        map < String, map < String, Account >> mapAccount = new map < String, map <
            String, Account >> ();
        mapAccount.put(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID, new map < String, Account > {
            '123' => new Account(), 'XX123' => new Account(Id = lstCDSPAccounts[3].Id)
        });
        mapAccount.put(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID, new map < String, Account > {
            '123' => new Account(), 'XX123' => new Account(Id = lstCDSPAccounts[3].Id)
        });
        mapAccount.put(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID, new map <
            String, Account > {
                '123' => new Account(), 'XX123' => new Account(Id = lstCDSPAccounts[3].Id)
            });
        mapAccount.put(Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID, new map < String,
            Account > {
                '123' => new Account(), 'XX123' => new Account(Id = lstCDSPAccounts[3].Id)
            });
            mapAccount.put(Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID, new map < String,
            Account > {
                '123' => new Account(), 'XX123' => new Account(Id = lstCDSPAccounts[3].Id)
            });
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            '123', null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            'X123', null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            '123', null, null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            'X123', null, null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            null, '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            null, 'X123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            '123', '123', '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            '123', '123', 'XX123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            '123', '123', null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            'XX123', '123', null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            '123', null, '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            'XX123', null, '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            '123', '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            'XX123', '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            null, null, mapAccount);

        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations(null,
            null, '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations('123',
            null, '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations(null,
            '123', '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations('X123',
            null, '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations(null,
            'X123', '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations('123',
            '123', '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations(
            'XX123', '123', '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations('123',
            'XX123', '', mapAccount);

        list < Send_Communication_Kit_On_Status_Change__c > lstCustomSetting = new list <
            Send_Communication_Kit_On_Status_Change__c > ();
        lstCustomSetting.add(new Send_Communication_Kit_On_Status_Change__c(Name =
            '1', Communication_Kit_Status__c = 'XYZ', Whom_To_Send__c = 'GP'));
        lstCustomSetting.add(new Send_Communication_Kit_On_Status_Change__c(Name =
            '2', Communication_Kit_Status__c = 'Received in the system',
            Whom_To_Send__c = 'GP'));
        lstCustomSetting.add(new Send_Communication_Kit_On_Status_Change__c(Name =
            '3', Communication_Kit_Status__c = 'XYZ', Whom_To_Send__c = 'SDL'));
        lstCustomSetting.add(new Send_Communication_Kit_On_Status_Change__c(Name =
            '4', Communication_Kit_Status__c = 'Received in the system',
            Whom_To_Send__c = 'SDL'));
        insert lstCustomSetting;
        System.assertEquals(4,lstCustomSetting.size());




        oCommKitData2.RecordTypeId = CommunicationKitHandler.sRecordTypeB2S;
        oCommKitData2.Status__c = 'Received in the system';
        list < Communication_Kit__c > newCommKit = new list < Communication_Kit__c >
            ();
        newCommKit.add(oCommKitData2);
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = null));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = null, RecordTypeId = CommunicationKitHandler.sRecordTypeB2S));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = null, RecordTypeId = CommunicationKitHandler.sRecordTypeS2B));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = null, RecordTypeId = CommunicationKitHandler.sRecordTypeS2B,
            Relationship_Type__c = 'Sponsor'));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[4].Id,
            SUP_ID__c = oSupporterAccount.Id, RecordTypeId = CommunicationKitHandler.sRecordTypeS2B,
            Relationship_Type__c = 'Sponsor'));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = lstCDSPAccounts[4].Id, RecordTypeId = CommunicationKitHandler.sRecordTypeB2S, Relationship_Type__c = 'Sponsor', Status__c = 'XYZ'));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = lstCDSPAccounts[4].Id, RecordTypeId = CommunicationKitHandler.sRecordTypeS2B, Relationship_Type__c = 'Sponsor', Status__c = 'XYZ'));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = oSupporterAccount.Id, RecordTypeId = CommunicationKitHandler.sRecordTypeS2B,
            Relationship_Type__c = 'Sponsor', Status__c = 'Ready to be printed'));

        CommunicationKitHandler c = new CommunicationKitHandler();
        c.onBeforeInsert(newCommKit);
        c.onAfterInsert(new map < Id, Communication_Kit__c > {
            null => newCommKit[0]
        });
        c.onAfterInsert(new map < Id, Communication_Kit__c > {
            null => newCommKit[1]
        });
        c.onAfterInsert(new map < Id, Communication_Kit__c > {
            null => newCommKit[2]
        });
        c.onAfterInsert(new map < Id, Communication_Kit__c > {
            null => newCommKit[3]
        });
        c.onAfterInsert(new map < Id, Communication_Kit__c > {
            null => newCommKit[4]
        });
        delete lstCommKit;
        Test.StopTest();
        
    }
    
    static testMethod void verifyCommunicationKitHandler2() {
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun = false;
        List < sObject > lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType,
            'Malnutrition_Data');
        List < string > lstRegionNames = new List < String > ();
        lstRegionNames.add('testRegion');
        list < PM_Hierarchy__c > lstRegionTestData = TestDataUtility.regionTestData(
            lstRegionNames);
        insert lstRegionTestData;
        // to create test data for Field office 
        List < string > lstFieldOfficeNames = new List < String > ();
        lstFieldOfficeNames.add('testFieldOffice');
        list < Account > lstFieldOfficeData = TestDataUtility.FieldofficeTestData(
            lstFieldOfficeNames);
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID;
        insert lstFieldOfficeData;
        // To Create Territory test data 
        List < string > lstTerritoryNames = new List < String > ();
        lstTerritoryNames.add('testRegion');
        list < PM_Hierarchy__c > lstTerritoryTestData = TestDataUtility.TerritoryTestData(
            lstTerritoryNames);
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID;
        List < string > lstClusterNames = new List < String > ();
        lstClusterNames.add('testCluster');
        list < PM_Hierarchy__c > lstClusterTestData = TestDataUtility.ClusterTestData(
            lstClusterNames);
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID;
        insert lstClusterTestData;
        List < Account > lstAccount = new List < Account > ();
        Account oICPAccount = TestDataUtility.ICPTestData();
        lstAccount.add(oICPAccount);

        lstAccount[0].Cluster__c = lstClusterTestData[0].ID;

        list < Household__c > lstHousehold = TestDataUtility.HouseholdTestData();
        insert lstHousehold;
        list < Household_Member__c > lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(
            lstHousehold);
        insert lstHouseholdMember;

        List < Account > lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData(
            lstAccount, lstHousehold, lstHouseholdMember);
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '3=8';
        lstCDSPAccounts[0].ICP__c = oICPAccount.ID;
        lstCDSPAccounts[1].Beneficiary_Status__c = 'Active';
        lstCDSPAccounts[0].Formal_Education_Status__c = 'Primary';
        lstCDSPAccounts[1].Formal_Education_Status__c = 'Primary';
        lstCDSPAccounts[0].Type_Of_Vocational_Education__c = 'Agriculture';
        lstCDSPAccounts[1].Type_Of_Vocational_Education__c = 'Agriculture';
        lstCDSPAccounts[0].Beneficiary_Status__c = 'Active';
        lstCDSPAccounts[1].Local_Grade_Level__c = 'PreSchool';
        lstCDSPAccounts[0].Local_Grade_Level__c = 'PreSchool';
        lstCDSPAccounts.add(lstCDSPAccounts[0].clone());
        lstCDSPAccounts[2].Local_Beneficiary_Number__c = '6389';
        lstCDSPAccounts[2].Compass_Id__c = '63899';
        lstCDSPAccounts[2].PO_Number__c = '63899';
        lstCDSPAccounts[2].Local_Beneficiary_Id__c = 'EC3476389';
        lstCDSPAccounts[2].BEN_Last_Wrote__c = system.today() + 1;
        lstCDSPAccounts.add(lstCDSPAccounts[0].clone());
        lstCDSPAccounts[3].Local_Beneficiary_Number__c = '6384';
        lstCDSPAccounts[3].Compass_Id__c = '63844';
        lstCDSPAccounts[3].PO_Number__c = '63844';
        lstCDSPAccounts[3].Local_Beneficiary_Id__c = 'EC3476384';
        lstCDSPAccounts[3].BEN_Last_Wrote__c = system.today() - 100;
        lstCDSPAccounts.add(lstCDSPAccounts[0].clone());
        lstCDSPAccounts[4].Local_Beneficiary_Number__c = '6380';
        lstCDSPAccounts[4].Compass_Id__c = '63840';
        lstCDSPAccounts[4].PO_Number__c = '638440';
        lstCDSPAccounts[4].Local_Beneficiary_Id__c = 'EC3476380';
        lstCDSPAccounts[4].BEN_Last_Wrote__c = system.today() - 100;
        insert lstCDSPAccounts;
        Account oGlobalpartner = TestDataUtility.globalPartnerTestData(Label.Compasssion_USA_Global_Partner_Name);
        insert oGlobalpartner;
        Account oSupporterAccount = TestDataUtility.supporterTestData(oGlobalpartner);
        insert oSupporterAccount;

        list < Commitment__c > lstCommitment = new list < Commitment__c > ();
        lstCommitment.add(TestDataUtility.commitmentTestData(lstCDSPAccounts[0],
            oSupporterAccount));
        lstCommitment.add(TestDataUtility.commitmentTestData(lstCDSPAccounts[1],
            oSupporterAccount));
        lstCommitment.add(TestDataUtility.commitmentTestData(lstCDSPAccounts[2],
            oSupporterAccount));
        lstCommitment.add(TestDataUtility.commitmentTestData(lstCDSPAccounts[3],
            oSupporterAccount));
        lstCommitment[0].Status__c = 'Active';
        lstCommitment[1].Relationship_Type__c = 'Correspondent';
        lstCommitment[1].Status__c = 'Active';
        lstCommitment[2].Relationship_Type__c = 'Sponsor';
        lstCommitment[2].Status__c = 'Active';
        lstCommitment[3].Relationship_Type__c = 'Correspondent';
        lstCommitment[3].Status__c = 'Active';
        insert lstCommitment;
         System.assertEquals(4,lstCommitment.size());
        Test.StartTest();


        list < Communication_Kit__c > lstCommKit = new list < Communication_Kit__c >
            ();
        Communication_Kit__c oCommKitData = TestDataUtility.commKitTestData(
            lstCDSPAccounts[0], oSupporterAccount, oICPAccount);
        oCommKitData.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_B2S_RT);
        oCommKitData.Status__c = 'Ready to be printed';
        oCommKitData.Communication_Types__c =
            'New Sponsor;New Sponsor;Response;Response';
        lstCommKit.add(oCommKitData);

        Communication_Kit__c oCommKitData2 = TestDataUtility.commKitTestData(
            lstCDSPAccounts[1], oSupporterAccount, oICPAccount);
        oCommKitData2.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_B2S_RT);
        oCommKitData2.Status__c = 'Ready to be printed';
        oCommKitData2.Communication_Types__c = null;
        lstCommKit.add(oCommKitData2);

        insert lstCommKit;
        CommunicationKitHandler oCKH = new CommunicationKitHandler();
        CommunicationKitHandler.findOrCreateCommKitRecord(new map < String, String > {
            lstCDSPAccounts[0].Local_Beneficiary_Id__c => 'New Sponsor',
                lstCDSPAccounts[1].Local_Beneficiary_Id__c => 'New Sponsor',
                lstCDSPAccounts[2].Local_Beneficiary_Id__c => 'New Sponsor',
                lstCDSPAccounts[3].Local_Beneficiary_Id__c => 'New Sponsor'
        },null);

        String sJSON =
            '{"SBCCommunicationDetails": [{"SBCGlobalStatus":"ABC", "SourceSystem": "Perceptive",  "SBCTypes": ["A","B"]}]}';
        CommunicationKitHandler.responseForValidationWrapper oDesJSON =
            CommunicationKitHandler.deserializeJson(sJSON, true, Constants.SBCCOMMUNICATIONDETAILS_REQ_PN);

        map < String, map < String, Account >> mapAccount = new map < String, map <
            String, Account >> ();
        mapAccount.put(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID, new map < String, Account > {
            '123' => new Account(), 'XX123' => new Account(Id = lstCDSPAccounts[3].Id)
        });
        mapAccount.put(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID, new map < String, Account > {
            '123' => new Account(), 'XX123' => new Account(Id = lstCDSPAccounts[3].Id)
        });
        mapAccount.put(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID, new map <
            String, Account > {
                '123' => new Account(), 'XX123' => new Account(Id = lstCDSPAccounts[3].Id)
            });
        mapAccount.put(Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID, new map < String,
            Account > {
                '123' => new Account(), 'XX123' => new Account(Id = lstCDSPAccounts[3].Id)
            });
            mapAccount.put(Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID, new map < String,
            Account > {
                '123' => new Account(), 'XX123' => new Account(Id = lstCDSPAccounts[3].Id)
            });
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            '123', null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            'X123', null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            '123', null, null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            'X123', null, null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            null, '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            null, 'X123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            '123', '123', '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            '123', '123', 'XX123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            '123', '123', null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            'XX123', '123', null, mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            '123', null, '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(
            'XX123', null, '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            '123', '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            'XX123', '123', mapAccount);
        oDesJSON = CommunicationKitHandler.BeneficiaryValidationForIntegrations(null,
            null, null, mapAccount);

        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations(null,
            null, '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations('123',
            null, '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations(null,
            '123', '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations('X123',
            null, '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations(null,
            'X123', '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations('123',
            '123', '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations(
            'XX123', '123', '', mapAccount);
        oDesJSON = CommunicationKitHandler.SupporterValidationForIntegrations('123',
            'XX123', '', mapAccount);

        list < Send_Communication_Kit_On_Status_Change__c > lstCustomSetting = new list <
            Send_Communication_Kit_On_Status_Change__c > ();
        lstCustomSetting.add(new Send_Communication_Kit_On_Status_Change__c(Name =
            '1', Communication_Kit_Status__c = 'XYZ', Whom_To_Send__c = 'GP'));
        lstCustomSetting.add(new Send_Communication_Kit_On_Status_Change__c(Name =
            '2', Communication_Kit_Status__c = 'Received in the system',
            Whom_To_Send__c = 'GP'));
        lstCustomSetting.add(new Send_Communication_Kit_On_Status_Change__c(Name =
            '3', Communication_Kit_Status__c = 'XYZ', Whom_To_Send__c = 'SDL'));
        lstCustomSetting.add(new Send_Communication_Kit_On_Status_Change__c(Name =
            '4', Communication_Kit_Status__c = 'Received in the system',
            Whom_To_Send__c = 'SDL'));
        insert lstCustomSetting;
         System.assertEquals(4,lstCustomSetting.size());




        oCommKitData2.RecordTypeId = CommunicationKitHandler.sRecordTypeB2S;
        oCommKitData2.Status__c = 'Received in the system';
        list < Communication_Kit__c > newCommKit = new list < Communication_Kit__c >
            ();
        newCommKit.add(oCommKitData2);
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = null));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = null, RecordTypeId = CommunicationKitHandler.sRecordTypeB2S));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = null, RecordTypeId = CommunicationKitHandler.sRecordTypeS2B));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = null, RecordTypeId = CommunicationKitHandler.sRecordTypeS2B,
            Relationship_Type__c = 'Sponsor'));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[4].Id,
            SUP_ID__c = oSupporterAccount.Id, RecordTypeId = CommunicationKitHandler.sRecordTypeS2B,
            Relationship_Type__c = 'Sponsor'));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = lstCDSPAccounts[4].Id, RecordTypeId = CommunicationKitHandler.sRecordTypeB2S, Relationship_Type__c = 'Sponsor', Status__c = 'XYZ'));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = lstCDSPAccounts[4].Id, RecordTypeId = CommunicationKitHandler.sRecordTypeS2B, Relationship_Type__c = 'Sponsor', Status__c = 'XYZ'));
        newCommKit.add(new Communication_Kit__c(BEN_Id__c = lstCDSPAccounts[3].Id,
            SUP_ID__c = oSupporterAccount.Id, RecordTypeId = CommunicationKitHandler.sRecordTypeS2B,
            Relationship_Type__c = 'Sponsor', Status__c = 'Ready to be printed'));

        CommunicationKitHandler c = new CommunicationKitHandler();
        c.onBeforeInsert(newCommKit);
        c.onAfterInsert(new map < Id, Communication_Kit__c > {
            null => newCommKit[5]
        });
        c.onAfterInsert(new map < Id, Communication_Kit__c > {
            null => newCommKit[6]
        });
        c.onAfterInsert(new map < Id, Communication_Kit__c > {
            null => newCommKit[7]
        });
        c.onAfterInsert(new map < Id, Communication_Kit__c > {
            null => newCommKit[8]
        });
        Test.StopTest();
    }
}