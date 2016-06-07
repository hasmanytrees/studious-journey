/******************************************************************************************************
Class Name         : HouseholdMemberHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: HouseholdMemberHandler
                     and HouseholdMemberTrigger
Created By         : Sudipta Nayak
Created On         : 24-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class HouseholdMemberHandler_Test {
    static testMethod void householdMemberTest()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        system.debug('#######');
        System.runAs(UserPF) {
            system.debug('^^^^^^^');
           TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
           TriggerContextUtility.bSendToAMIntegFirstRun = false;
           List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Account> lstAccountICP = new List<Account>();
            //User UserNewPF = TestDataUtility.UserTestData('Partnership Facilitator','PFnewUser', 'Ethiopia Partnership Facilitator');
            //insert UserNewPF;
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
            oICPAccount.ICP_Status__c='Active';
            lstAccountICP.add(oICPAccount) ;
            insert lstAccountICP;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            System.debug( 'lstHousehold???' + lstHousehold) ;
            Test.startTest();
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            System.debug( 'lstHouseholdMember???' + lstHouseholdMember) ;
            list<Account> lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            System.debug( 'lstAccountCDSP???' + lstAccountCDSP) ;
            System.debug( 'lstAccountCDSP???' + lstAccountCDSP[0].Primary_Caregiver__c) ;
            System.debug( 'lstAccountCDSP???' + lstAccountCDSP[1].Primary_Caregiver__c) ;
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCDSP;
            list<Account> lstAccountCSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCSP;
            update lstHouseholdMember;
            lstHousehold[0].Natural_Father_IsAlive__c = 'No';
            update lstHousehold;
            system.assertequals('No',lstHousehold[0].Natural_Father_IsAlive__c);
            Test.stopTest();
        }
    }
    static testMethod void householdMemberChangeTest()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        system.debug('#######');
        System.runAs(UserPF) {
            system.debug('^^^^^^^');
           TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
           TriggerContextUtility.bSendToAMIntegFirstRun = false;
           List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
             list<Account> lstAccountICP = new List<Account>();
            //User UserNewPF = TestDataUtility.UserTestData('Partnership Facilitator','PFnewUser', 'Ethiopia Partnership Facilitator');
            //insert UserNewPF;
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
            oICPAccount.ICP_Status__c='Active';
            lstAccountICP.add(oICPAccount) ;
            insert lstAccountICP;
            //User UserNewPF = TestDataUtility.UserTestData('Partnership Facilitator','PFnewUser', 'Ethiopia Partnership Facilitator');
            //insert UserNewPF;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            
            System.debug( 'lstHousehold???' + lstHousehold) ;
            Test.startTest();
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            list<Household__c> lstHouseholdNew = TestDataUtility.HouseholdTestData();
            lstHouseholdNew[0].Name = 'HouseholdNew';
            insert lstHouseholdNew;
            list<Household_Member__c> lstHouseholdMemberNew =TestDataUtility.HouseholdMemberTestData(lstHouseholdNew);
            lstHouseholdMemberNew[0].Role__c = 'father';
            insert lstHouseholdMemberNew;
            System.debug( 'lstHouseholdMember???' + lstHouseholdMember) ;
            list<Account> lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            System.debug( 'lstAccountCDSP???' + lstAccountCDSP) ;
            System.debug( 'lstAccountCDSP???' + lstAccountCDSP[0].Primary_Caregiver__c) ;
            System.debug( 'lstAccountCDSP???' + lstAccountCDSP[1].Primary_Caregiver__c) ;
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCDSP;
            System.assertNotEquals(null,lstAccountCDSP);
            lstAccountCDSP[0].Household__c =lstHouseholdNew[0].id;
            update lstAccountCDSP;
            lstHouseholdMemberNew[0].Is_Primary_Caregiver__c = false;
            update lstHouseholdMemberNew;
            lstHouseholdMemberNew[0].Existing_Beneficiary__c = lstAccountCDSP[0].id;
            update lstHouseholdMemberNew;
            lstHouseholdMemberNew[0].Is_Primary_Caregiver__c = true;
             
            
            update lstHouseholdMemberNew;
            System.assertEquals(true,lstHouseholdMemberNew[0].Is_Primary_Caregiver__c);
            
            
            Test.stopTest();
        }
    }
     static testMethod void householdMemberRestrictMultipleTest()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new list<Id>();
        system.debug('#######');
        System.runAs(UserPF) {
            system.debug('^^^^^^^');
           TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
           TriggerContextUtility.bSendToAMIntegFirstRun = false;
           List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Account> lstAccountICP = new List<Account>();
            //User UserNewPF = TestDataUtility.UserTestData('Partnership Facilitator','PFnewUser', 'Ethiopia Partnership Facilitator');
            //insert UserNewPF;
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
            oICPAccount.ICP_Status__c='Active';
            lstAccountICP.add(oICPAccount) ;
            insert lstAccountICP;
            //User UserNewPF = TestDataUtility.UserTestData('Partnership Facilitator','PFnewUser', 'Ethiopia Partnership Facilitator');
            //insert UserNewPF;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            
            System.debug( 'lstHousehold???' + lstHousehold) ;
            Test.startTest();
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            list<Household__c> lstHouseholdNew = TestDataUtility.HouseholdTestData();
            lstHouseholdNew[0].Name = 'HouseholdNew';
            insert lstHouseholdNew;
            list<Household_Member__c> lstHouseholdMemberNew =TestDataUtility.HouseholdMemberTestData(lstHousehold );
            lstHouseholdMemberNew[0].Role__c = 'father';
            try{
                insert lstHouseholdMemberNew;
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Error_multiple_Primary_Caregivers ) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            
            
            
            
            Test.stopTest();
        }
    }
}