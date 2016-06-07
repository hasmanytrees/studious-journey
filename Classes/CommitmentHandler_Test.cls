/******************************************************************************************************
Class Name         : CommitmentHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     CommitmentHandler
Created By         : Sudipta Nayak
Created On         : 03-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false)
private class CommitmentHandler_Test {
    static testMethod void verifyCommitmentHandler()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
            List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
            List<string> lstRegionNames = new List<String> (  ) ; 
            lstRegionNames.add( 'testRegion' ) ; 
            list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
                insert lstRegionTestData ;  
            // to create test data for Field office 
            List<string> lstFieldOfficeNames = new List<String> (  ) ; 
            lstFieldOfficeNames.add( 'Ecuador' ) ; 
            list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
            lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;  
            lstFieldOfficeData[0].FO_Next_Schedule_Print_Date__c =System.Today()+4;
            lstFieldOfficeData[0].Field_Office_Id__c='EC';
            insert lstFieldOfficeData ;      
            // To Create Territory test data 
            List<string> lstTerritoryNames = new List<String> (  ) ; 
            lstTerritoryNames.add( 'testRegion' ) ; 
            list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
            lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ;
             insert lstTerritoryTestData;
            List<string> lstClusterNames = new List<String> (  ) ; 
            lstClusterNames.add( 'testCluster' ) ; 
            list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
            lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;
            List<Account> lstAccount=new List<Account>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstClusterTestData[0].ID ;
            lstAccount.add(oICPAccount) ;
            insert lstAccount;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccount, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Sponsorship_Status__pc = 'Sponsored';
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Beneficiary_Status__c = 'Draft';
            //Test.startTest();
            insert lstAccountCDSP;
            Test.startTest();
            Account oGlobalPartnerUSA = TestDataUtility.globalPartnerTestData('Compassion USA');
            insert oGlobalPartnerUSA;
            Account oSupporter = TestDataUtility.supporterTestData(oGlobalPartnerUSA);
            insert oSupporter;
            
            Commitment__c oCommitment = TestDataUtility.commitmentTestData(lstAccountCDSP[0],oSupporter);
            oCommitment.Relationship_Type__c = 'Sponsor';
            oCommitment.Status__c = 'Inactive';
            oCommitment.New_Sponsor_Letter_Required__c = true;
            insert oCommitment;
            oCommitment.Status__c = 'Active';
            update oCommitment;
            
            Commitment__c oCommitment1 = TestDataUtility.commitmentTestData(lstAccountCDSP[0],oSupporter);
            oCommitment1.Relationship_Type__c = 'Correspondent';
            oCommitment1.Status__c = 'Active';
            insert oCommitment1;
            
            Commitment__c oCommitment2 = TestDataUtility.commitmentTestData(lstAccountCDSP[1],oSupporter);
            oCommitment2.Relationship_Type__c = 'Sponsor';
            oCommitment2.Status__c = 'Active';
            try {
                insert oCommitment2;
            }
            catch(Exception oEx) {
                System.assert(oEx.getMessage().contains(System.Label.Commitment_No_Active_Beneficiary_Error));
            }            
            Test.stopTest();
        }
    }
    
    static testMethod void verifyCommitmentHandler1()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
            List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
            List<string> lstRegionNames = new List<String> (  ) ; 
            lstRegionNames.add( 'testRegion' ) ; 
            list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
                insert lstRegionTestData ;  
            // to create test data for Field office 
            List<string> lstFieldOfficeNames = new List<String> (  ) ; 
            lstFieldOfficeNames.add( 'Ecuador' ) ; 
            list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
            lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;  
            lstFieldOfficeData[0].FO_Next_Schedule_Print_Date__c =System.Today()+4;
            lstFieldOfficeData[0].Field_Office_Id__c='EC';
            insert lstFieldOfficeData ;      
            // To Create Territory test data 
            List<string> lstTerritoryNames = new List<String> (  ) ; 
            lstTerritoryNames.add( 'testRegion' ) ; 
            list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
            lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ;
             insert lstTerritoryTestData;
            List<string> lstClusterNames = new List<String> (  ) ; 
            lstClusterNames.add( 'testCluster' ) ; 
            list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
            lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;
            List<Account> lstAccount=new List<Account>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstClusterTestData[0].ID ;
            lstAccount.add(oICPAccount) ;
            insert lstAccount;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccount, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Sponsorship_Status__pc = 'Sponsored';
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Beneficiary_Status__c = 'Draft';
            Test.startTest();
            insert lstAccountCDSP;
            Account oGlobalPartnerUSA = TestDataUtility.globalPartnerTestData('Compassion USA');
            insert oGlobalPartnerUSA;
            Account oSupporter = TestDataUtility.supporterTestData(oGlobalPartnerUSA);
            insert oSupporter;
            
            Commitment__c oCommitment = TestDataUtility.commitmentTestData(lstAccountCDSP[0],oSupporter);
            oCommitment.Relationship_Type__c = 'Sponsor';
            oCommitment.Status__c = 'Active';
            oCommitment.New_Sponsor_Letter_Required__c = true;
            insert oCommitment;
            Test.stopTest();
            Commitment__c oCommitment1 = TestDataUtility.commitmentTestData(lstAccountCDSP[0],oSupporter);
            oCommitment1.Relationship_Type__c = 'Sponsor';
            oCommitment1.Status__c = 'Active';           
            oCommitment1.Relationship_Type__c = 'Correspondent';
            oCommitment1.Status__c = 'Active';
            insert oCommitment1;

        }
    }
}