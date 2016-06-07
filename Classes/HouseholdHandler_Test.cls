/******************************************************************************************************
Class Name         : HouseholdHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: HouseholdHandler
                     and HouseholdTrigger
Created By         : Sfurti Pandey
Created On         : 16-Sep-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class HouseholdHandler_Test {
    static testMethod void householdTest()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser1;
        list<Id> AccountId = new list<Id>();
        System.runAs(oUser1) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;  
            
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            Test.startTest();
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;            
            List<Account> lstAccount=new List<Account>();
            Account oICPAccount = TestDataUtility.ICPTestData() ;
            oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
            lstAccount.add(oICPAccount) ;
            Account oICPAccount1 = TestDataUtility.ICPTestData() ;
            oICPAccount1.Cluster__c = lstPMHierarchyCluster[0].ID ;
            oICPAccount1.ICP_Id__c = 'TD159';
            lstAccount.add(oICPAccount1) ;
            insert lstAccount;
            Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccount[0].ID ) ; 
            Insert oConTest ;
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = oConTest.Id ; 
            oUser2.PortalRole = 'Manager' ;
            insert oUser2;
            
            //User UserNewPF = TestDataUtility.UserTestData('Partnership Facilitator','PFnewUser', 'Ethiopia Partnership Facilitator');
            //insert UserNewPF;
            
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            System.debug( 'lstHousehold???' + lstHousehold) ;
            Test.stopTest();
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            list<Account> lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData( lstAccount, lstHousehold, lstHouseholdMember);
            insert lstAccountCDSP;
           
            list<Account> lstAccountCSP = TestDataUtility.CSPBeneficiaryTestData(lstAccount, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCSP;
            
            update lstHouseholdMember;
            lstHousehold[0].Natural_Father_IsAlive__c = 'No';
            update lstHousehold;
            
            system.assertequals('No',lstHousehold[0].Natural_Father_IsAlive__c);
            
        }
    }
    
  /*  static testMethod void householdTestportaluser()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser1;
        list<Id> AccountId = new list<Id>();
        User oUser2 ;
        //User oUser3 ;
        System.runAs(oUser1) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            
            //ist<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
         //   lstContact[1].Lead__c  = lstLead[0].ID ;
          //  insert lstContact ;
            
           TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
            List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
            
            List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
            List<string> lstRegionNames = new List<String> (  ) ; 
            lstRegionNames.add( 'testRegion' ) ; 
            list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
                insert lstRegionTestData ;  
            // to create test data for Field office 
           List<string> lstFieldOfficeNames = new List<String> (  ) ; 
            lstFieldOfficeNames.add( 'Ethiopia' ) ; 
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
            oICPAccount.Review_Status__c = lstClusterTestData[0].ID ;
            lstAccount.add(oICPAccount) ;
            
            Account oICPAccount1 = TestDataUtility.ICPTestData() ;
            oICPAccount1.Cluster__c = lstClusterTestData[0].ID ;
            oICPAccount1.ICP_Id__c = 'TD159';
            lstAccount.add(oICPAccount1) ;
            insert lstAccount;
            Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccount[0].ID ) ; 
            Insert oConTest ;
             Contact oConTestNew = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccount[1].ID ) ; 
            Insert oConTestNew ;
            Test.startTest();
            
            oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = oConTest.Id ; 
            oUser2.PortalRole = 'Manager' ;
            insert oUser2;
             User oUser3 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser3.ContactId = oConTestNew.Id ; 
            oUser3.PortalRole = 'Manager' ;
            insert oUser3;
           
            
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            System.debug( 'lstHousehold???' + lstHousehold) ;
           
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            list<Account> lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccount, lstHousehold, lstHouseholdMember);
            insert lstAccountCDSP;
            
            list<Account> lstAccountCSP = TestDataUtility.CSPBeneficiaryTestData(lstAccount, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCSP;
            
            update lstHouseholdMember;
             Test.stopTest();
            lstHousehold[0].Natural_Father_IsAlive__c = 'No';
            lstHousehold[0].Natural_Mother_IsAlive__c = 'No';
            update lstHousehold;            
            system.assertequals('No',lstHousehold[0].Natural_Father_IsAlive__c);
            
        }
        
        system.RunAs(oUser2){
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            System.debug( 'lstHousehold???' + lstHousehold) ;
        
        }
        
        
    }*/
}