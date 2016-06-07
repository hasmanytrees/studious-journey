/******************************************************************************************************
Class Name         : MassUpdateBeneficiaryNeedsExtension_Test
Description        : This class contains unit tests for validating the behavior of Apex class:
                     MassUpdateBeneficiaryNeedsExtension
Created By         : Shaik Manzoor
Created On         : 30-Mar-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class MassUpdateBeneficiaryNeedsExtension_Test  {
    static testMethod void MassUpdateBeneficiaryNeedsExtensionTest()  {

        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        //User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        //insert UserCD;
        list<Id> AccountId = new list<Id>(); 
        System.runAs(UserPF) {
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');           
            List<sObject> CustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
            Global_Data__c oGlobalTestData = TestDataUtility.globalDataNeeds('Access to Potable Water', 'Beneficiary Need', 'Medical/Health');
            insert oGlobalTestData; 
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;           
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            Test.startTest();    
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserPF);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(True);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();            
            AccountId.add(LeadId);
            Database.LeadConvert lc1 = new Database.LeadConvert();
            lc1.setLeadId(lstLead[1].id);
            lc1.setDoNotCreateOpportunity(True);
            lc1.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr1 = Database.convertLead(lc1);
            Id LeadId1 = lcr1.getAccountId();
            AccountId.add(LeadId1);                    
            list<Account> lstAccountICP = TestDataUtility.ICPTestData(AccountId);            
            lstAccountICP[0].ICP_Status__c = 'Active';
            update lstAccountICP;           
            //User UserNewPF = TestDataUtility.UserTestData('Partnership Facilitator','PFnewUser', 'Ethiopia Partnership Facilitator');
            //insert UserNewPF;
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            Test.stopTest();      
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;            
            list<Account> lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCDSP;
            list<Account> lstAccountCSP = TestDataUtility.CSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCSP;            
            Needs_Association__c NeedsAssociationTestData = TestDataUtility.NeedsAssociationTestData(lstAccountCDSP[0].id,'test',true,'test',System.today(),'Very High');
            insert NeedsAssociationTestData;                      
            NeedsAssociationTestData.Need__c = oGlobalTestData.id;
            update NeedsAssociationTestData;
            ApexPages.StandardController stdConAcc = new ApexPages.StandardController( lstAccountICP[0] ) ;
            Pagereference pg = new PageReference( '/apex/MassUpdateBeneficiaryNeeds' ) ; 
            Test.setCurrentPage(pg) ;
            ApexPages.currentPage().getParameters().put( 'Id' , lstAccountICP[0].ID );            
            
            MassUpdateBeneficiaryNeedsExtension MUBNCon = new MassUpdateBeneficiaryNeedsExtension (stdConAcc);
                    
            MUBNCon.setValueTypeMap();
            MUBNCon.sSelectedNeed = NeedsAssociationTestData.Need__c;
            MUBNCon.bensearch();
            MUBNCon.associateNeeds();
            system.assert(MUBNCon.lstNeedsList!=null);
            
        }
    }
}