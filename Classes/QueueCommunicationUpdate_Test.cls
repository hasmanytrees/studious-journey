/******************************************************************************************************
Class Name         : QueueCommunicationUpdate_Test
Description        : This class contains unit tests for validating the behavior of 
                     class: QueueCommunicationUpdate                   
Created By         : Danish Ahmed
Created On         : 23-Dec-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest(SeeAllData=false)
private class QueueCommunicationUpdate_Test {
    static testMethod void verifyCommunicationKitHandler() {
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun = false;
        List < sObject > lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType,
            'Template_Sequencing');
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
        lstFieldOfficeData[0].Field_Office_Id__c = 'BO';
        insert lstFieldOfficeData;
        // To Create Territory test data 
        List < string > lstTerritoryNames = new List < String > ();
        lstTerritoryNames.add('testRegion');
        list < PM_Hierarchy__c > lstTerritoryTestData = TestDataUtility.TerritoryTestData(
            lstTerritoryNames);
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID;
        Insert lstTerritoryTestData;
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
        lstAccount[0].Frequency_Letter_Pickup_Delivery__c = 'Weekly';
        lstAccount[0].One_Way_Delivery_Time_to_ICP__c = ' 12';
        insert lstAccount;
        list < Household__c > lstHousehold = TestDataUtility.HouseholdTestData();
        insert lstHousehold;
        list < Household_Member__c > lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(
            lstHousehold);
        insert lstHouseholdMember;
    
        List < Account > lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData(
            lstAccount, lstHousehold, lstHouseholdMember);
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '3-8';
        lstCDSPAccounts[0].ICP__c = oICPAccount.ID;
        lstCDSPAccounts[0].PersonBirthdate = system.today() - 1000;
        lstCDSPAccounts[1].Beneficiary_Status__c = 'Active';
        lstCDSPAccounts[0].Formal_Education_Status__c = 'Primary';
        lstCDSPAccounts[1].Formal_Education_Status__c = 'Primary';
        lstCDSPAccounts[1].PersonBirthdate = system.today() - 1000;
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
        lstCDSPAccounts[2].PersonBirthdate = system.today() - 1000;
        lstCDSPAccounts.add(lstCDSPAccounts[0].clone());
        lstCDSPAccounts[3].Local_Beneficiary_Number__c = '6384';
        lstCDSPAccounts[3].Compass_Id__c = '63844';
        lstCDSPAccounts[3].PO_Number__c = '63844';
        lstCDSPAccounts[3].Local_Beneficiary_Id__c = 'EC3476384';
        lstCDSPAccounts[3].BEN_Last_Wrote__c = system.today() - 100;
        lstCDSPAccounts[3].PersonBirthdate = system.today() - 1000;
        lstCDSPAccounts.add(lstCDSPAccounts[0].clone());
        lstCDSPAccounts[4].Local_Beneficiary_Number__c = '6380';
        lstCDSPAccounts[4].Compass_Id__c = '63840';
        lstCDSPAccounts[4].PO_Number__c = '638440';
        lstCDSPAccounts[4].Local_Beneficiary_Id__c = 'EC3476380';
        lstCDSPAccounts[4].BEN_Last_Wrote__c = system.today() - 100;
        lstCDSPAccounts[4].PersonBirthdate = system.today() - 1000;
        insert lstCDSPAccounts;
        Account oGlobalpartner = TestDataUtility.globalPartnerTestData(Label.Compasssion_USA_Global_Partner_Name);
        insert oGlobalpartner;
        Account oSupporterAccount = TestDataUtility.supporterTestData(oGlobalpartner);
        insert oSupporterAccount;
        System.assertNotEquals(null,oSupporterAccount.id);
        Test.StartTest();
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
        //1 Test.StartTest();


        list < Communication_Kit__c > lstCommKit = new list < Communication_Kit__c >
            ();
        Communication_Kit__c oCommKitData = TestDataUtility.commKitTestData(
            lstCDSPAccounts[0], oSupporterAccount, oICPAccount);
        oCommKitData.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_B2S_RT);
        oCommKitData.Status__c = 'Ready to be printed';
        oCommKitData.Communication_Types__c = 'Large Gift Thank You Letter';
        oCommKitData.Print_Type_Selected__c = 'Template with Header';
        lstCommKit.add(oCommKitData);
        //2 Test.StartTest();
        Communication_Kit__c oCommKitData2 = TestDataUtility.commKitTestData(
            lstCDSPAccounts[1], oSupporterAccount, oICPAccount);
        oCommKitData2.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_B2S_RT);
        oCommKitData2.Status__c = 'Ready to be printed';
        oCommKitData2.Communication_Types__c = 'New Sponsor Letter';
        oCommKitData2.Print_Type_Selected__c = 'Header Only';
        lstCommKit.add(oCommKitData2);
        
        Communication_Kit__c oCommKitData3 = TestDataUtility.commKitTestData(
            lstCDSPAccounts[2], oSupporterAccount, oICPAccount);
        oCommKitData3.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_B2S_RT);
        oCommKitData3.Status__c = 'Ready to be printed';
        oCommKitData3.Communication_Types__c = 'Final Letter';
        oCommKitData3.Print_Type_Selected__c = 'Header Only';
        lstCommKit.add(oCommKitData3);
        
        Communication_Kit__c oCommKitData4 = TestDataUtility.commKitTestData(
            lstCDSPAccounts[3], oSupporterAccount, oICPAccount);
        oCommKitData4.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_B2S_RT);
        oCommKitData4.Status__c = 'Ready to be printed';
        oCommKitData4.Communication_Types__c = Null;
        oCommKitData4.Print_Type_Selected__c = 'Header Only';
        lstCommKit.add(oCommKitData4);

        insert lstCommKit;
        Set<Id> setCommKitId = new Set<Id>();
        setCommKitId.add(lstCommKit[0].Id);
        setCommKitId.add(lstCommKit[1].Id);
        setCommKitId.add(lstCommKit[2].Id);
        setCommKitId.add(lstCommKit[3].Id);
        lstCommKit = [Select id, Status__c, BEN_ID__c, BEN_ID__r.BEN_Last_Wrote__c, BEN_Id__r.ICP__r.Letters_Due_at_FO__c, BEN_Id__r.ICP__r.Gift_Letters_Due_at_FO__c,BEN_Id__r.Age_In_Months__c, BEN_Id__r.ICP__r.Cluster__r.Territory__r.Field_Office__r.Field_Office_Id__c, RecordType.Name, Communication_Types__c, Marked_For_Rework__c from Communication_Kit__c where id IN: setCommKitId];
        
        List<Template_Sequencing_Data__c> CurrTempSeq = new List <
        Template_Sequencing_Data__c>();
        DateTime d = datetime.now();
        //Noting the current month's name
        String sMonthName = d.format(Constants.PrintPortal_CurrMonth);    
        String sSearchMonth = '%'+sMonthName+'%';    
        CurrTempSeq = [Select id, Age_Min__c, Age_Max__c, FO_Id__c, Priority__c,
            Template_Id__c, Template_Last_Used_Date__c, Template_Months__c,
            Template_Order__c, Type_of_Letter__c from Template_Sequencing_Data__c 
            where Template_Months__c LIKE : sSearchMonth ORDER BY Priority__c,
            Template_Order__c ASC
        ];
        
        
        Map<String, Map<Integer, List<Template_Sequencing_Data__c>>>
                    mapOfFoKeys = new Map<String, Map<Integer, List <
                    Template_Sequencing_Data__c>>>();
                for(Template_Sequencing_Data__c CurrTS: CurrTempSeq) {
                    if(!mapOfFoKeys.containsKey(CurrTS.FO_Id__c)) {
                        List<Template_Sequencing_Data__c> lstTemp = new List <
                            Template_Sequencing_Data__c>();
                        lstTemp.add(CurrTS);
                        Map<Integer, List<Template_Sequencing_Data__c>> InnerMap = new Map <
                            Integer, List<Template_Sequencing_Data__c>>();
                        InnerMap.put(Integer.ValueOf(CurrTS.Priority__c), lstTemp);
                        mapOfFoKeys.put(CurrTS.FO_Id__c, InnerMap);
                    } else {
                        Map<Integer, List<Template_Sequencing_Data__c>> InnerMap =
                            mapOfFoKeys.get(CurrTS.FO_Id__c);
                        if(InnerMap.containsKey(Integer.ValueOf(CurrTS.Priority__c))) {
                            List<Template_Sequencing_Data__c> lstTemp = InnerMap.get(Integer.ValueOf(
                                CurrTS.Priority__c));
                            lstTemp.add(CurrTS);
                            InnerMap.put(Integer.ValueOf(CurrTS.Priority__c), lstTemp);
                            mapOfFoKeys.put(CurrTS.FO_Id__c, InnerMap);
                        } else {
                            List<Template_Sequencing_Data__c> lstTemp = new List <
                                Template_Sequencing_Data__c>();
                            lstTemp.add(CurrTS);
                            InnerMap.put(Integer.ValueOf(CurrTS.Priority__c), lstTemp);
                            mapOfFoKeys.put(CurrTS.FO_Id__c, InnerMap);
                        }
                    }
                }


        QueueCommunicationUpdate oQueueCommunicationUpdate = new QueueCommunicationUpdate('Header Only', lstCommKit, mapOfFoKeys, CurrTempSeq);
        Test.StopTest();        
        System.enqueueJob(oQueueCommunicationUpdate);
        
        //2 Test.StopTest();
        
    }
}