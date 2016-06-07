/******************************************************************************************************
Class Name         : BeneficiaryImpactHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     BeneficiaryImpactHandler and BeneficiaryImpactTrigger
Created By         : Sudipta Nayak
Created On         : 11-Sep-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class BeneficiaryImpactHandler_Test {
    /*@testSetup static void setup() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            List<Account> lstAccountICP=new List<Account>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
            oICPAccount.ICP_Status__c='Active';
            lstAccountICP.add(oICPAccount) ;
            Account oICPAccountNew =TestDataUtility.ICPTestData() ;
            oICPAccountNew.ICP_Id__c = 'TD155';
            lstAccountICP.add(oICPAccountNew) ;
            insert lstAccountICP;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            test.startTest();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Sponsorship_Status__pc = 'Sponsored';
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            insert lstAccountCDSP;
            test.stopTest();
            System.assertNotEquals(null,lstAccountCDSP);
        }
    }*/
    
    static testMethod void beneficiaryImpactTest()  {
        
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            List<Account> lstAccountICP=new List<Account>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
            oICPAccount.ICP_Status__c='Active';
            lstAccountICP.add(oICPAccount) ;
            Account oICPAccountNew =TestDataUtility.ICPTestData() ;
            oICPAccountNew.ICP_Id__c = 'TD155';
            lstAccountICP.add(oICPAccountNew) ;
            insert lstAccountICP;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Sponsorship_Status__pc = 'Sponsored';
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            insert lstAccountCDSP;
            test.startTest();
            Account oGlobalPartnerUSA = TestDataUtility.globalPartnerTestData('Compassion USA');
            insert oGlobalPartnerUSA;
            Account oSupporter1 = TestDataUtility.supporterTestData(oGlobalPartnerUSA);
            insert oSupporter1;
            Account oGlobalPartnerAus = TestDataUtility.globalPartnerTestData('Compassion Australia');
            insert oGlobalPartnerAus;
            Account oSupporter2 = TestDataUtility.supporterTestData(oGlobalPartnerAus);
            insert oSupporter2;
            
            Commitment__c oCommitment1 = TestDataUtility.commitmentTestData(lstAccountCDSP[0],oSupporter1);
            oCommitment1.Relationship_Type__c = 'Sponsor';
            oCommitment1.Status__c = 'Active';
            insert oCommitment1;
            Commitment__c oCommitment2 = TestDataUtility.commitmentTestData(lstAccountCDSP[0],oSupporter2);
            oCommitment2.Relationship_Type__c = 'Correspondent';
            oCommitment2.Status__c = 'Active';
            insert oCommitment2;
            List<Beneficiary_Impact__c> lstBeneficiaryImpact = TestDataUtility.beneficiaryImpactTestData(lstAccountCDSP,lstDisaster[0]);
            insert lstBeneficiaryImpact;
            
            Beneficiary_Impact__c oBenImpact = [Select Id, Sponsor_Country__c, Sponsorship_Status__c from Beneficiary_Impact__c where Id =: lstBeneficiaryImpact[0].Id];
            System.assertEquals('Compassion USA', oBenImpact.Sponsor_Country__c);   
            System.assertEquals('Sponsored', oBenImpact.Sponsorship_Status__c);
            Test.stopTest();
        }
            
    }
    
    static testMethod void beneficiaryImpactTest1()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            List<Account> lstAccountICP=new List<Account>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
            oICPAccount.ICP_Status__c='Active';
            lstAccountICP.add(oICPAccount) ;
            Account oICPAccountNew =TestDataUtility.ICPTestData() ;
            oICPAccountNew.ICP_Id__c = 'TD155';
            lstAccountICP.add(oICPAccountNew) ;
            insert lstAccountICP;
            test.startTest();
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Sponsorship_Status__pc = 'Sponsored';
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            
            insert lstAccountCDSP;
            Account oGlobalPartnerUSA = TestDataUtility.globalPartnerTestData('Compassion USA');
            insert oGlobalPartnerUSA;
            Account oSupporter1 = TestDataUtility.supporterTestData(oGlobalPartnerUSA);
            insert oSupporter1;
            Commitment__c oCommitment1 = TestDataUtility.commitmentTestData(lstAccountCDSP[0],oSupporter1);
            oCommitment1.Relationship_Type__c = 'Sponsor';
            oCommitment1.Status__c = 'Active';
            insert oCommitment1;
            List<Beneficiary_Impact__c> lstBeneficiaryImpact = TestDataUtility.beneficiaryImpactTestData(lstAccountCDSP,lstDisaster[0]);
            insert lstBeneficiaryImpact;
             System.assertNotEquals(null,lstBeneficiaryImpact);
             System.assertNotEquals(null,lstBeneficiaryImpact[0].Id);
            Beneficiary_Impact__c oBenImpact = [Select Id, Sponsor_Country__c, Sponsorship_Status__c from Beneficiary_Impact__c where Id =: lstBeneficiaryImpact[0].Id];
            Test.stopTest();
        }
    }
    
    static testMethod void beneficiaryImpactTest2()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            List<Account> lstAccountICP=new List<Account>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
            oICPAccount.ICP_Status__c='Active';
            lstAccountICP.add(oICPAccount) ;
            Account oICPAccountNew =TestDataUtility.ICPTestData() ;
            oICPAccountNew.ICP_Id__c = 'TD155';
            lstAccountICP.add(oICPAccountNew) ;
            insert lstAccountICP;
            test.startTest();
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Sponsorship_Status__pc = 'Sponsored';
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            
            insert lstAccountCDSP;
            Account oGlobalPartnerAus = TestDataUtility.globalPartnerTestData('Compassion Australia');
            insert oGlobalPartnerAus;
            Account oSupporter2 = TestDataUtility.supporterTestData(oGlobalPartnerAus);
            insert oSupporter2;
            Commitment__c oCommitment2 = TestDataUtility.commitmentTestData(lstAccountCDSP[0],oSupporter2);
            oCommitment2.Relationship_Type__c = 'Correspondent';
            oCommitment2.Status__c = 'Active';
            insert oCommitment2;
            List<Beneficiary_Impact__c> lstBeneficiaryImpact = TestDataUtility.beneficiaryImpactTestData(lstAccountCDSP,lstDisaster[0]);
            insert lstBeneficiaryImpact;
             System.assertNotEquals(null,lstBeneficiaryImpact);
             System.assertNotEquals(null,lstBeneficiaryImpact[0].Id);
            Beneficiary_Impact__c oBenImpact = [Select Id, Sponsor_Country__c, Sponsorship_Status__c from Beneficiary_Impact__c where Id =: lstBeneficiaryImpact[0].Id];
            Test.stopTest();
        }
    }
    
    static testMethod void beneficiaryImpactTest3()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            insert lstDisaster;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            List<Account> lstAccountICP=new List<Account>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
            oICPAccount.ICP_Status__c='Active';
            lstAccountICP.add(oICPAccount) ;
            Account oICPAccountNew =TestDataUtility.ICPTestData() ;
            oICPAccountNew.ICP_Id__c = 'TD155';
            lstAccountICP.add(oICPAccountNew) ;
            insert lstAccountICP;
            
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            List<Account> lstAccountCDSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            lstAccountCDSP[0].Sponsorship_Status__pc = 'Sponsored';
            lstAccountCDSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCDSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            
            insert lstAccountCDSP;
            Test.startTest();
            Account oGlobalPartnerUSA = TestDataUtility.globalPartnerTestData('Compassion USA');
            insert oGlobalPartnerUSA;
            Account oSupporter1 = TestDataUtility.supporterTestData(oGlobalPartnerUSA);
            insert oSupporter1;
            Account oGlobalPartnerAus = TestDataUtility.globalPartnerTestData('Compassion Australia');
            insert oGlobalPartnerAus;
            Account oSupporter2 = TestDataUtility.supporterTestData(oGlobalPartnerAus);
            insert oSupporter2;
         
            Commitment__c oCommitment1 = TestDataUtility.commitmentTestData(lstAccountCDSP[0],oSupporter1);
            oCommitment1.Relationship_Type__c = 'Correspondent';
            oCommitment1.Status__c = 'Active';
            insert oCommitment1;
            
            Commitment__c oCommitment2 = TestDataUtility.commitmentTestData(lstAccountCDSP[0],oSupporter2);
            oCommitment2.Relationship_Type__c = 'Sponsor';
            oCommitment2.Status__c = 'Active';
            insert oCommitment2;
            List<Beneficiary_Impact__c> lstBeneficiaryImpact = TestDataUtility.beneficiaryImpactTestData(lstAccountCDSP,lstDisaster[0]);
            
            insert lstBeneficiaryImpact[0];
             System.assertNotEquals(null,lstBeneficiaryImpact);
             System.assertNotEquals(null,lstBeneficiaryImpact[0].Id);
            Beneficiary_Impact__c oBenImpact = [Select Id, Sponsor_Country__c, Sponsorship_Status__c from Beneficiary_Impact__c where Id =: lstBeneficiaryImpact[0].Id];
            Test.stopTest();  
        }
    }
}