/******************************************************************************************************
Class Name         : PmatFormNewExtension_Test
Description        : This class contains unit tests for validating the behavior of Apex class: PmatFormNewExtension
Created By         : Akashdeep 
Created On         : 7-Oct-2015 
*******************************************************************************************************/
@IsTest(SeeAllData = false)
private class PmatFormNewExtension_Test {
    static testMethod void verifyPmatFormNewExtension() {
        List<string> lstRegionNames = new List<String>();
        lstRegionNames.add('testRegion');
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData(
            lstRegionNames);
        insert lstRegionTestData;
        List<string> lstFieldOfficeNames = new List<String>();
        lstFieldOfficeNames.add('testFieldOffice');
        list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData(
            lstFieldOfficeNames);
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID;
        insert lstFieldOfficeData;
        List<string> lstTerritoryNames = new List<String>();
        lstTerritoryNames.add('testRegion');
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData(
            lstTerritoryNames);
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID;
        List<string> lstClusterNames = new List<String>();
        lstClusterNames.add('testCluster');
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData(
            lstClusterNames);
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID;
        insert lstClusterTestData;
        Account oICPAccount = TestDataUtility.ICPTestData();
        oICPAccount.Cluster__c = lstClusterTestData[0].ID;
        insert oICPAccount;

        Contact contactGP = new Contact(FirstName = 'Bob', LastName = 'Phillip',
            AccountId = oICPAccount.Id);
        insert contactGP;

        Pagereference pg = new PageReference('/apex/PMATFormNew?Accid=' +
            oICPAccount.id);
        Test.setCurrentPage(pg);

        PMAT_Cluster_Measure__c PCM = new PMAT_Cluster_Measure__c();
        PCM.Outcome_Number__c = '1: Demonstrate Effective Vision and Leadership';
        PCM.Indicator_Number__c =
            '1.1: ICP reflects strong partner church vision and values.';
        PCM.Measure_Number__c = 'Measure 1.1.1';
        PCM.Text_Position__c = 'Developing Partnership Stage Text';
        PCM.Measurement_Label__c = null;
        PCM.Field_Hierarchy__c = oICPAccount.Cluster__c;

        PMAT_Cluster_Measure__c PCM2 = new PMAT_Cluster_Measure__c();
        PCM2.Outcome_Number__c = '1: Demonstrate Effective Vision and Leadership';
        PCM2.Indicator_Number__c =
            '1.1: ICP reflects strong partner church vision and values.';
        PCM2.Measure_Number__c = 'Measure 1.1.1';
        PCM2.Text_Position__c = 'Developing Partnership Stage Text';
        PCM2.Measurement_Label__c = 'Test';
        PCM2.Field_Hierarchy__c = oICPAccount.Cluster__c;

        List<PMAT_Cluster_Measure__c> lstPCM = new List<PMAT_Cluster_Measure__c>
            ();
        lstPCM.add(PCM);
        lstPCM.add(PCM2);
        insert lstPCM;

        ApexPages.StandardController stdConAcc = new ApexPages.StandardController(
            new PMAT_Assessment__c());

        Test.StartTest();

        PmatFormNewExtension testPMATExtn = new PmatFormNewExtension(stdConAcc);
        testPMATExtn.oCurrPMAT = new PMAT_Assessment__c();
        testPMATExtn.clickCancel();
        testPMATExtn.oCurrPMAT.PMAT_Assessment_Start_Date__c = Date.newInstance(2015,
            10, 10);
        testPMATExtn.oCurrPMAT.PMAT_Assessment_End_Date__c = Date.newInstance(2015,
            10, 20);
        testPMATExtn.oCurrPMAT.PMAT_ICP_Representative__c = contactGP.id;
        testPMATExtn.oCurrPMAT.Account_Name__c = oICPAccount.id;
        insert testPMATExtn.oCurrPMAT;
        testPMATExtn.recordSave();
        testPMATExtn.clickCancel();
        testPMATExtn.clickSave();
        testPMATExtn.ClickPrint();

        Pagereference pg1 = new PageReference('/apex/PMATFormNew?id=' + testPMATExtn
            .oCurrPMAT.id + '&retUrl');
        Test.setCurrentPage(pg1);
        testPMATExtn.clickEdit();
        testPMATExtn.createICPForm();
        testPMATExtn.formTwo();
        testPMATExtn.programCapacity();
        testPMATExtn.programCapacity2();
        testPMATExtn.clickCancel();

        testPMATExtn.ShowNextAssessDateField();
        testPMATExtn.oChildRecCI = new PMAT__c();
        testPMATExtn.oChildRecCI.PMAT_Status__c = Constants.PMAT_Discussion;
        testPMATExtn.oChildRecCI.PMAT_Type__c = Constants.Comp_Label;
        testPMATExtn.oChildRecCI.PMAT_Assessment__c = testPMATExtn.oCurrPMAT.id;
        insert testPMATExtn.oChildRecCI;

        testPMATExtn.oChildRecCI.Christ_Mutual_Identity_Church__c = '3';
        testPMATExtn.oChildRecCI.Christ_Mutual_Identity_Compassion__c = '1';
        testPMATExtn.oChildRecCI.Mutual_Respect_Benefit_Compassion__c = '3';
        testPMATExtn.oChildRecCI.Mutual_Respect_Benefit_Church__c = '4';
        testPMATExtn.oChildRecCI.Responsibilty_Commitment_Compassion__c = '5';
        testPMATExtn.oChildRecCI.Responsibilty_Commitment_Church__c = '1';
        testPMATExtn.oChildRecCI.Transformation_Outcomes_Compassion__c = '4';
        testPMATExtn.oChildRecCI.Transformation_Outcomes_Church__c = '6';
        testPMATExtn.oChildRecCI.Address_Outcomes_Standards_M1__c = '5';
        testPMATExtn.oChildRecCI.Address_Outcomes_Standards_M2__c = '4';
        testPMATExtn.oChildRecCI.Address_Outcomes_Standards_M3__c = '3';
        testPMATExtn.oChildRecCI.Effective_Annual_Plans_M1__c = '2';
        testPMATExtn.oChildRecCI.Effective_Annual_Plans_M2__c = '1';
        testPMATExtn.oChildRecCI.Effective_Annual_Plans_M3__c = '2';
        testPMATExtn.oChildRecCI.Implements_Curriculum_Effectively_M1__c = '4';
        testPMATExtn.oChildRecCI.Implements_Curriculum_Effectively_M2__c = '5';
        testPMATExtn.oChildRecCI.Implements_Curriculum_Effectively_M3__c = '6';
        testPMATExtn.oChildRecCI.Advocates_Children_Caregiver_M1__c = '1';
        testPMATExtn.oChildRecCI.Advocates_Children_Caregiver_M2__c = '3';
        testPMATExtn.oChildRecCI.Advocates_Children_Caregiver_M3__c = '2';
        testPMATExtn.oChildRecCI.Demonstrates_Learning_And_Improvement_M1__c = '4';
        testPMATExtn.oChildRecCI.Demonstrates_Learning_And_Improvement_M2__c = '2';
        testPMATExtn.oChildRecCI.Demonstrates_Learning_And_Improvement_M3__c = '5';
        testPMATExtn.oChildRecCI.Mobilize_Technical_Financial_Assist_M1__c = '2';
        testPMATExtn.oChildRecCI.Mobilize_Technical_Financial_Assist_M2__c = '5';
        testPMATExtn.oChildRecCI.Mobilize_Technical_Financial_Assist_M3__c = '6';
        testPMATExtn.oChildRecCI.Quality_Training_ICP_Staff__c = '1';
        testPMATExtn.oChildRecCI.Encourage_ICP_Innovate_Personalize__c = '2';
        testPMATExtn.oChildRecCI.Sufficient_Time_Project_Needs__c = '6';
        testPMATExtn.oChildRecCI.Unique_Challenges_Project__c = '5';
        testPMATExtn.oChildRecCI.ICP_Autonomy_Decision_Making__c = '3';
        testPMATExtn.oChildRecCI.Natural_Extension_ICP_Ministry__c = '2';
        testPMATExtn.oChildRecCI.Compassion_Demonstrated_Sensitivity__c = '4';
        testPMATExtn.oChildRecCI.Compassion_Requirement_Reasonable__c = '6';
        update testPMATExtn.oChildRecCI;


        testPMATExtn.recordSave();
        testPMATExtn.LoadPageInstance();
        testPMATExtn.ShowNextAssessDateField();

        PmatFormNewExtension testPMATExtn2 = new PmatFormNewExtension(stdConAcc);
        testPMATExtn2.oCurrPMAT = new PMAT_Assessment__c();
        testPMATExtn2.oCurrPMAT.PMAT_Assessment_Start_Date__c = Date.newInstance(
            2015, 10, 10);
        testPMATExtn2.oCurrPMAT.PMAT_Assessment_End_Date__c = Date.newInstance(2015,
            10, 20);
        testPMATExtn2.oCurrPMAT.PMAT_ICP_Representative__c = contactGP.id;
        testPMATExtn2.oCurrPMAT.Account_Name__c = oICPAccount.id;
        testPMATExtn2.recordSave();

        testPMATExtn.oChildRecICP = new PMAT__c();
        testPMATExtn.oChildRecICP.PMAT_Type__c = Constants.ICP_Label;
        testPMATExtn.oChildRecICP.PMAT_Assessment__c = testPMATExtn.oCurrPMAT.id;
        testPMATExtn.oChildRecICP.PMAT_Status__c = Constants.PMAT_Discussion;
        insert testPMATExtn.oChildRecICP;

        testPMATExtn.oChildRecICP.Christ_Mutual_Identity_Church__c = '3';
        testPMATExtn.oChildRecICP.Christ_Mutual_Identity_Compassion__c = '1';
        testPMATExtn.oChildRecICP.Mutual_Respect_Benefit_Compassion__c = '3';
        testPMATExtn.oChildRecICP.Mutual_Respect_Benefit_Church__c = '4';
        testPMATExtn.oChildRecICP.Responsibilty_Commitment_Compassion__c = '5';
        testPMATExtn.oChildRecICP.Responsibilty_Commitment_Church__c = '1';
        testPMATExtn.oChildRecICP.Transformation_Outcomes_Compassion__c = '4';
        testPMATExtn.oChildRecICP.Transformation_Outcomes_Church__c = '6';
        testPMATExtn.oChildRecICP.Address_Outcomes_Standards_M1__c = '5';
        testPMATExtn.oChildRecICP.Address_Outcomes_Standards_M2__c = '4';
        testPMATExtn.oChildRecICP.Address_Outcomes_Standards_M3__c = '3';
        testPMATExtn.oChildRecICP.Effective_Annual_Plans_M1__c = '2';
        testPMATExtn.oChildRecICP.Effective_Annual_Plans_M2__c = '1';
        testPMATExtn.oChildRecICP.Effective_Annual_Plans_M3__c = '2';
        testPMATExtn.oChildRecICP.Implements_Curriculum_Effectively_M1__c = '4';
        testPMATExtn.oChildRecICP.Implements_Curriculum_Effectively_M2__c = '5';
        testPMATExtn.oChildRecICP.Implements_Curriculum_Effectively_M3__c = '6';
        testPMATExtn.oChildRecICP.Advocates_Children_Caregiver_M1__c = '1';
        testPMATExtn.oChildRecICP.Advocates_Children_Caregiver_M2__c = '3';
        testPMATExtn.oChildRecICP.Advocates_Children_Caregiver_M3__c = '2';
        testPMATExtn.oChildRecICP.Demonstrates_Learning_And_Improvement_M1__c = '4';
        testPMATExtn.oChildRecICP.Demonstrates_Learning_And_Improvement_M2__c = '2';
        testPMATExtn.oChildRecICP.Demonstrates_Learning_And_Improvement_M3__c = '5';
        testPMATExtn.oChildRecICP.Mobilize_Technical_Financial_Assist_M1__c = '2';
        testPMATExtn.oChildRecICP.Mobilize_Technical_Financial_Assist_M2__c = '5';
        testPMATExtn.oChildRecICP.Mobilize_Technical_Financial_Assist_M3__c = '6';
        testPMATExtn.oChildRecICP.Quality_Training_ICP_Staff__c = '1';
        testPMATExtn.oChildRecICP.Encourage_ICP_Innovate_Personalize__c = '2';
        testPMATExtn.oChildRecICP.Sufficient_Time_Project_Needs__c = '6';
        testPMATExtn.oChildRecICP.Unique_Challenges_Project__c = '5';
        testPMATExtn.oChildRecICP.ICP_Autonomy_Decision_Making__c = '3';
        testPMATExtn.oChildRecICP.Natural_Extension_ICP_Ministry__c = '2';
        testPMATExtn.oChildRecICP.Compassion_Demonstrated_Sensitivity__c = '4';
        testPMATExtn.oChildRecICP.Compassion_Requirement_Reasonable__c = '6';
        testPMATExtn.oChildRecICP.Compassion_Requirement_Relevant__c = '1';
        testPMATExtn.clickSave();
        update testPMATExtn.oChildRecICP;

        testPMATExtn.LoadPageInstance();
        testPMATExtn.oChildRecCI.PMAT_Status__c = Constants.PMAT_Complete;
        testPMATExtn.oChildRecICP.PMAT_Status__c = Constants.PMAT_Complete;
        update testPMATExtn.oChildRecICP;
        update testPMATExtn.oChildRecCI;
        testPMATExtn.recordSave();
        testPMATExtn.LoadPageInstance();
        testPMATExtn.sPageMode = Constants.PMAT_Edit;
        testPMATExtn.ShowNextAssessDateField();
        testPMATExtn.LoadPageInstance();

        testPMATExtn = new PmatFormNewExtension(stdConAcc);
        testPMATExtn.oCurrPMAT = new PMAT_Assessment__c();
        testPMATExtn.oCurrPMAT.PMAT_Assessment_Start_Date__c = Date.newInstance(2015,
            10, 10);
        testPMATExtn.oCurrPMAT.PMAT_Assessment_End_Date__c = Date.newInstance(2015,
            10, 20);
        testPMATExtn.oCurrPMAT.PMAT_ICP_Representative__c = contactGP.id;
        testPMATExtn.oCurrPMAT.Account_Name__c = oICPAccount.id;
        insert testPMATExtn.oCurrPMAT;
        testPMATExtn.clickSave();


        PageReference pageRef = Page.PMATFormNew;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller stdConAcc1 = new ApexPages.Standardcontroller(
            testPMATExtn.oCurrPMAT);
        ApexPages.currentPage()
            .getParameters()
            .put('id', testPMATExtn.oCurrPMAT.id);
        PmatFormNewExtension testPMATExtn1 = new PmatFormNewExtension(stdConAcc1);
        ApexPages.currentPage()
            .getParameters()
            .put('retUrl', testPMATExtn.oCurrPMAT.id);
        testPMATExtn1 = new PmatFormNewExtension(stdConAcc1);

        Test.StopTest();
    }

    static testMethod void verifyPmatFormNewExtensionAsICP() {
        Account oICPAccount1 = TestDataUtility.ICPTestData();
        oICPAccount1.Ownerid = UserInfo.getUserId();
        insert oICPAccount1;
        System.assertNotEquals(null, oICPAccount1.id);
        Contact oConTestnew = new Contact(LastName = 'test contactnew', FirstName =
            'test', AccountID = oICPAccount1.ID);
        Insert oConTestnew;
        System.assertNotEquals(null, oConTestnew.id);
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController(
            new PMAT_Assessment__c());



        Test.StartTest();
        PmatFormNewExtension testPMATExtn = new PmatFormNewExtension(stdConAcc);
        testPMATExtn.oCurrPMAT = new PMAT_Assessment__c();

        testPMATExtn.oCurrPMAT.PMAT_Assessment_Start_Date__c = Date.newInstance(2015,
            10, 10);
        testPMATExtn.oCurrPMAT.PMAT_Assessment_End_Date__c = Date.newInstance(2015,
            10, 20);
        testPMATExtn.oCurrPMAT.PMAT_ICP_Representative__c = oConTestnew.id;
        testPMATExtn.oCurrPMAT.Account_Name__c = oICPAccount1.id;
        insert testPMATExtn.oCurrPMAT;

        Pagereference pg1 = new PageReference('/apex/PMATFormNew?id=' + testPMATExtn
            .oCurrPMAT.id + '&retUrl');
        Test.setCurrentPage(pg1);


        testPMATExtn.oChildRecICP = new PMAT__c();
        testPMATExtn.oChildRecICP.PMAT_Type__c = Constants.ICP_Label;
        testPMATExtn.oChildRecICP.PMAT_Assessment__c = testPMATExtn.oCurrPMAT.id;
        testPMATExtn.oChildRecICP.PMAT_Status__c = Constants.PMAT_Discussion;
        insert testPMATExtn.oChildRecICP;

        testPMATExtn.ProfileName.Name = Constants.ICP_Admin;

        testPMATExtn.recordSave();
        testPMATExtn.LoadPageInstance();

        testPMATExtn.oChildRecICP.Christ_Mutual_Identity_Church__c = '3';
        testPMATExtn.oChildRecICP.Christ_Mutual_Identity_Compassion__c = '1';
        testPMATExtn.oChildRecICP.Mutual_Respect_Benefit_Compassion__c = '3';
        testPMATExtn.oChildRecICP.Mutual_Respect_Benefit_Church__c = '4';
        testPMATExtn.oChildRecICP.Responsibilty_Commitment_Compassion__c = '5';
        testPMATExtn.oChildRecICP.Responsibilty_Commitment_Church__c = '1';
        testPMATExtn.oChildRecICP.Transformation_Outcomes_Compassion__c = '4';
        testPMATExtn.oChildRecICP.Transformation_Outcomes_Church__c = '6';
        testPMATExtn.oChildRecICP.Address_Outcomes_Standards_M1__c = '5';
        testPMATExtn.oChildRecICP.Address_Outcomes_Standards_M2__c = '4';
        testPMATExtn.oChildRecICP.Address_Outcomes_Standards_M3__c = '3';
        testPMATExtn.oChildRecICP.Effective_Annual_Plans_M1__c = '2';
        testPMATExtn.oChildRecICP.Effective_Annual_Plans_M2__c = '1';
        testPMATExtn.oChildRecICP.Effective_Annual_Plans_M3__c = '2';
        testPMATExtn.oChildRecICP.Implements_Curriculum_Effectively_M1__c = '4';
        testPMATExtn.oChildRecICP.Implements_Curriculum_Effectively_M2__c = '5';
        testPMATExtn.oChildRecICP.Implements_Curriculum_Effectively_M3__c = '6';
        testPMATExtn.oChildRecICP.Advocates_Children_Caregiver_M1__c = '1';
        testPMATExtn.oChildRecICP.Advocates_Children_Caregiver_M2__c = '3';
        testPMATExtn.oChildRecICP.Advocates_Children_Caregiver_M3__c = '2';
        testPMATExtn.oChildRecICP.Demonstrates_Learning_And_Improvement_M1__c = '4';
        testPMATExtn.oChildRecICP.Demonstrates_Learning_And_Improvement_M2__c = '2';
        testPMATExtn.oChildRecICP.Demonstrates_Learning_And_Improvement_M3__c = '5';
        testPMATExtn.oChildRecICP.Mobilize_Technical_Financial_Assist_M1__c = '2';
        testPMATExtn.oChildRecICP.Mobilize_Technical_Financial_Assist_M2__c = '5';
        testPMATExtn.oChildRecICP.Mobilize_Technical_Financial_Assist_M3__c = '6';
        testPMATExtn.oChildRecICP.Quality_Training_ICP_Staff__c = '1';
        testPMATExtn.oChildRecICP.Encourage_ICP_Innovate_Personalize__c = '2';
        testPMATExtn.oChildRecICP.Sufficient_Time_Project_Needs__c = '6';
        testPMATExtn.oChildRecICP.Unique_Challenges_Project__c = '5';
        testPMATExtn.oChildRecICP.ICP_Autonomy_Decision_Making__c = '3';
        testPMATExtn.oChildRecICP.Natural_Extension_ICP_Ministry__c = '2';
        testPMATExtn.oChildRecICP.Compassion_Demonstrated_Sensitivity__c = '4';
        testPMATExtn.oChildRecICP.Compassion_Requirement_Reasonable__c = '6';
        testPMATExtn.oChildRecICP.Compassion_Requirement_Relevant__c = '1';
        testPMATExtn.clickSave();
        testPMATExtn.oChildRecCI.PMAT_Status__c = Constants.PMAT_Discussion;
        testPMATExtn.oChildRecICP.PMAT_Status__c = Constants.PMAT_Discussion;
        testPMATExtn.ProfileName.Name = Constants.ICP_Admin;
        testPMATExtn.LoadPageInstance();

        testPMATExtn.oChildRecCI.PMAT_Status__c = Constants.PMAT_Complete;
        testPMATExtn.oChildRecICP.PMAT_Status__c = Constants.PMAT_Complete;
        testPMATExtn.ProfileName.Name = Constants.ICP_Admin;
        testPMATExtn.clickSave();
        testPMATExtn.sPageMode = Constants.PMAT_Edit;
        testPMATExtn.ShowNextAssessDateField();
        testPMATExtn.LoadPageInstance();

        testPMATExtn.oChildRecCI = new PMAT__c();
        testPMATExtn.oChildRecCI.PMAT_Status__c = Constants.PMAT_Discussion;
        testPMATExtn.oChildRecCI.PMAT_Type__c = Constants.Comp_Label;
        testPMATExtn.oChildRecCI.PMAT_Assessment__c = testPMATExtn.oCurrPMAT.id;
        insert testPMATExtn.oChildRecCI;

        testPMATExtn.oChildRecCI.Christ_Mutual_Identity_Church__c = '3';
        testPMATExtn.oChildRecCI.Christ_Mutual_Identity_Compassion__c = '1';
        testPMATExtn.oChildRecCI.Mutual_Respect_Benefit_Compassion__c = '3';
        testPMATExtn.oChildRecCI.Mutual_Respect_Benefit_Church__c = '4';
        testPMATExtn.oChildRecCI.Responsibilty_Commitment_Compassion__c = '5';
        testPMATExtn.oChildRecCI.Responsibilty_Commitment_Church__c = '1';
        testPMATExtn.oChildRecCI.Transformation_Outcomes_Compassion__c = '4';
        testPMATExtn.oChildRecCI.Transformation_Outcomes_Church__c = '6';
        testPMATExtn.oChildRecCI.Address_Outcomes_Standards_M1__c = '5';
        testPMATExtn.oChildRecCI.Address_Outcomes_Standards_M2__c = '4';
        testPMATExtn.oChildRecCI.Address_Outcomes_Standards_M3__c = '3';
        testPMATExtn.oChildRecCI.Effective_Annual_Plans_M1__c = '2';
        testPMATExtn.oChildRecCI.Effective_Annual_Plans_M2__c = '1';
        testPMATExtn.oChildRecCI.Effective_Annual_Plans_M3__c = '2';
        testPMATExtn.oChildRecCI.Implements_Curriculum_Effectively_M1__c = '4';
        testPMATExtn.oChildRecCI.Implements_Curriculum_Effectively_M2__c = '5';
        testPMATExtn.oChildRecCI.Implements_Curriculum_Effectively_M3__c = '6';
        testPMATExtn.oChildRecCI.Advocates_Children_Caregiver_M1__c = '1';
        testPMATExtn.oChildRecCI.Advocates_Children_Caregiver_M2__c = '3';
        testPMATExtn.oChildRecCI.Advocates_Children_Caregiver_M3__c = '2';
        testPMATExtn.oChildRecCI.Demonstrates_Learning_And_Improvement_M1__c = '4';
        testPMATExtn.oChildRecCI.Demonstrates_Learning_And_Improvement_M2__c = '2';
        testPMATExtn.oChildRecCI.Demonstrates_Learning_And_Improvement_M3__c = '5';
        testPMATExtn.oChildRecCI.Mobilize_Technical_Financial_Assist_M1__c = '2';
        testPMATExtn.oChildRecCI.Mobilize_Technical_Financial_Assist_M2__c = '5';
        testPMATExtn.oChildRecCI.Mobilize_Technical_Financial_Assist_M3__c = '6';
        testPMATExtn.oChildRecCI.Quality_Training_ICP_Staff__c = '1';
        testPMATExtn.oChildRecCI.Encourage_ICP_Innovate_Personalize__c = '2';
        testPMATExtn.oChildRecCI.Sufficient_Time_Project_Needs__c = '6';
        testPMATExtn.oChildRecCI.Unique_Challenges_Project__c = '5';
        testPMATExtn.oChildRecCI.ICP_Autonomy_Decision_Making__c = '3';
        testPMATExtn.oChildRecCI.Natural_Extension_ICP_Ministry__c = '2';
        testPMATExtn.oChildRecCI.Compassion_Demonstrated_Sensitivity__c = '4';
        testPMATExtn.oChildRecCI.Compassion_Requirement_Reasonable__c = '6';
        update testPMATExtn.oChildRecCI;


        Test.StopTest();
    }

}