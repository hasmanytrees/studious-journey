/******************************************************************************************************
Class Name         : CommitmentUpdates_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CommitmentUpdates
Created By         : Sfurti Pandey 
Created On         : 26-Nov-2015 
*******************************************************************************************************/
@
IsTest(SeeAllData = false)
public class CommitmentUpdates_Test {
    static testMethod void verifyCommitmentUpdates() {
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
        lstCDSPAccounts[3].Local_Beneficiary_Number__c = '3453';
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
        oSupporterAccount.GP_Supporter_ID__c = 'FR1022';
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
        lstCommitment[1].COMPASS_cm_pk__c='234234234';
        lstCommitment[1].Status__c = 'Active';
        lstCommitment[1].BEN_INT_Global_ID__c='06448417';
        lstCommitment[1].COMPASS_child_id__c='345345';
        lstCommitment[2].Relationship_Type__c = 'Sponsor';
        lstCommitment[2].Status__c = 'Active';
        lstCommitment[3].Relationship_Type__c = 'Correspondent';
        lstCommitment[3].Status__c = 'Active';
        insert lstCommitment;
       System.assertEquals('Sponsor', lstCommitment[2].Relationship_Type__c);
       


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
        //TestDataUtility.insertJSONProcessDetailsForSBC();
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData(
            'CommitmentUpdates_Req_PN', null, false);
        insert oJsonProcess;

        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData(
            'CommitmentUpdates_Res_FG', 'Commitment__c');
        insert oFieldGroup;

        JSON_Structure__c oJSONStructure = TestDataUtility.jsonStructureTestData(
            'CommitmentUpdates', oFieldGroup.Id, true, oJsonProcess.Id);
        insert oJSONStructure;

        list < Field_Group_Element__c > lstFieldGrpElement = new list <
            Field_Group_Element__c > ();
        lstFieldGrpElement = TestDataUtility.CommitmentUpdatesFGElementsTestData(
            oFieldGroup.Id);
        insert lstFieldGrpElement;
        System.assertNotEquals(null,lstFieldGrpElement);
        
        
        
        
        String sJSON1 ='{ "CommitmentUpdates": [ { "LegacyCommitmentId": "234234234", "LegacySupporterId": "FR1022", "LegacyBeneficiaryId": "63899", "GlobalBeneficiaryId": "06448417", "RelationshipType": "Sponsor", "GlobalSupporterId": "' + oSupporterAccount.Global_Number__c + '", "StartDate": "2015-09-23", "EndDate": "", "CorrespondenceLanguage": "", "NewSponsorLetterRequired": true } ] }';
        
        String sJSON2 ='{ "CommitmentUpdates": [ { "LegacyCommitmentId": "234234234", "LegacySupporterId": "FR1022", "GlobalBeneficiaryId": "06448417", "RelationshipType": "Sponsor", "GlobalSupporterId": "' + oSupporterAccount.Global_Number__c + '", "StartDate": "2015-09-23", "EndDate": "", "CorrespondenceLanguage": "", "NewSponsorLetterRequired": true } ] }';
        
        String sJSON3 ='{ "CommitmentUpdates": [ { "LegacyCommitmentId": "234234234", "LegacySupporterId": "FR1022", "LegacyBeneficiaryId": "63899", "RelationshipType": "Sponsor", "GlobalSupporterId": "' + oSupporterAccount.Global_Number__c + '", "StartDate": "2015-09-23", "EndDate": "", "CorrespondenceLanguage": "", "NewSponsorLetterRequired": true } ] }';
        
        String sJSON4 ='{ "CommitmentUpdates": [ { "LegacyCommitmentId": "234234234", "LegacySupporterId": "FR1022", "RelationshipType": "Sponsor", "GlobalSupporterId": "' + oSupporterAccount.Global_Number__c + '", "StartDate": "2015-09-23", "EndDate": "", "CorrespondenceLanguage": "", "NewSponsorLetterRequired": true } ] }';
        
        String sJSON5 ='{ "CommitmentUpdates": [ { "LegacyCommitmentId": "234234234", "LegacySupporterId": "FR1022", "RelationshipType": "Sponsor", "GlobalSupporterId": "' + oSupporterAccount.Global_Number__c + '", "StartDate": "", "EndDate": "", "CorrespondenceLanguage": "", "NewSponsorLetterRequired": true, "LegacyBeneficiaryId": "63899" } ] }';
        
        String sJSON6 ='{ "CommitmentUpdates": [ { "LegacyCommitmentId": "234234234", "LegacySupporterId": "FR1022", "RelationshipType": "Sponsor", "GlobalSupporterId": "' + oSupporterAccount.Global_Number__c + '", "StartDate": "2015-09-23", "EndDate": "2015-09-23", "CorrespondenceLanguage": "", "NewSponsorLetterRequired": true, "LegacyBeneficiaryId": "63899" } ] }';
        
        String sJSON7 ='{ "CommitmentUpdates": [ { "LegacyCommitmentId": "2342342345", "LegacySupporterId": "FR1022", "LegacyBeneficiaryId": "63899", "RelationshipType": "Sponsor", "GlobalSupporterId": "' + oSupporterAccount.Global_Number__c + '", "StartDate": "2015-09-23", "EndDate": "", "CorrespondenceLanguage": "", "NewSponsorLetterRequired": true } ] }';
        
        String sJSON8 ='{ "CommitmentUpdates": [ { "LegacyCommitmentId": "2342342345", "LegacySupporterId": "FR1022", "LegacyBeneficiaryId": "63899", "RelationshipType": "Sponsor", "GlobalSupporterId": "' + oSupporterAccount.Global_Number__c + '", "StartDate": "2015-09-23", "EndDate": "2015-09-23", "CorrespondenceLanguage": "", "NewSponsorLetterRequired": true } ] }';
        
        String sJSON9 ='{ "CommitmentUpdates": [ { "LegacyCommitmentId": "2342342345", "LegacySupporterId": "FR1022", "LegacyBeneficiaryId": "63899", "RelationshipType": "Sponsor", "GlobalSupporterId": "' + oSupporterAccount.Global_Number__c + '", "StartDate": "", "EndDate": "", "CorrespondenceLanguage": "", "NewSponsorLetterRequired": true } ] }';
        
        test.startTest();
         CommunicationKitHandler.responseForValidationWrapper oDesJSON =CommunicationKitHandler.deserializeJson(sJSON1, true, Constants.SBCCOMMUNICATIONDETAILS_REQ_PN);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl() +
            'services/apexrest/CommitmentUpdates';
        req.httpMethod = 'POST';
         req.requestBody = Blob.valueof(sJSON1);
        RestContext.request = req;
        RestContext.response = res;
        CommitmentUpdates.reqCommitmentUpdates();
        
        req.requestBody = Blob.valueof(sJSON2);
        RestContext.request = req;
        RestContext.response = res;
        CommitmentUpdates.reqCommitmentUpdates();
        
        req.requestBody = Blob.valueof(sJSON3);
        RestContext.request = req;
        RestContext.response = res;
        CommitmentUpdates.reqCommitmentUpdates();
        
        req.requestBody = Blob.valueof(sJSON4);
        RestContext.request = req;
        RestContext.response = res;
        CommitmentUpdates.reqCommitmentUpdates();
        
        req.requestBody = Blob.valueof(sJSON5);
        RestContext.request = req;
        RestContext.response = res;
        CommitmentUpdates.reqCommitmentUpdates();
        
        req.requestBody = Blob.valueof(sJSON6);
        RestContext.request = req;
        RestContext.response = res;
        CommitmentUpdates.reqCommitmentUpdates();
        
        req.requestBody = Blob.valueof(sJSON7);
        RestContext.request = req;
        RestContext.response = res;
        CommitmentUpdates.reqCommitmentUpdates();
        
        req.requestBody = Blob.valueof(sJSON8);
        RestContext.request = req;
        RestContext.response = res;
        CommitmentUpdates.reqCommitmentUpdates();
        
        req.requestBody = Blob.valueof(sJSON9);
        RestContext.request = req;
        RestContext.response = res;
        CommitmentUpdates.reqCommitmentUpdates();
        Test.StopTest();
    }
}