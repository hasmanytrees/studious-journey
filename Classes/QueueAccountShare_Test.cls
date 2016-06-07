/******************************************************************************************************
Class Name         : QueueAccountShare_Test
Description        : This class contains unit tests for validating the behavior of batch class: QueueAccountShare
                     
Created By         : Danish Ahmed
Created On         : 9-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@isTest(SeeAllData=false)
private class QueueAccountShare_Test{
    @testSetup static void setup() {
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
        insert lstRegionTestData ;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;  
        // to create test data for Field office 
        List<string> lstFieldOfficeNames = new List<String> (  ) ; 
        lstFieldOfficeNames.add( 'testFieldOffice' ) ; 
        list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;   
        insert lstFieldOfficeData ;      
        // To Create Territory test data 
        List<string> lstTerritoryNames = new List<String> (  ) ; 
        lstTerritoryNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        insert lstTerritoryTestData ;  
        // to create Cluster test data
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
        insert lstClusterTestData ;
        List<Account> lstAccount=new List<Account>();
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ;              
        lstAccount.add(oICPAccount);
        Account oICPAccountNew = TestDataUtility.ICPTestData() ;
        oICPAccountNew.Cluster__c = lstClusterTestData[0].ID ;
        oICPAccountNew.ICP_Id__c ='TU156';
        lstAccount.add(oICPAccountNew);
        insert lstAccount;
        Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccount[0].ID ) ; 
        Insert oConTest ;
        System.assertNotEquals(null,oConTest.id);
        list<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
        insert lstHouseHoldData ;
        // To insert HouseholdMemberTestData
        list<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
        insert lstHouseHoldMemberData;
         System.assertNotEquals(null,lstHouseHoldMemberData);           
    }
    
    static TestMethod void QueueAccountShareMethod1() {
        User oUser = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser;        
        
        System.runAs(oUser){
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;  
            Household__c oHousehold = [Select Id from Household__c Limit 1];
            List<Account> lstAccount = [Select id from Account where recordType.name = 'ICP' Limit 1];
            List<Account> lstCDSPAccounts = new List<Account>();
            Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME);
            for(Integer i=0; i <= 10; i++){
                Account oAccount = new Account();
                oAccount.LastName = 'Doe';
                oAccount.Local_Beneficiary_Number__c = String.ValueOf(i+1);
                oAccount.PersonBirthdate = System.Today()-1200;
                oAccount.Gender__c = 'Male';
                oAccount.Beneficiary_Confession_Of_Faith_Date__c = System.Today();
                oAccount.Active_Program__c = Constants.CDSP;
                oAccount.CDSP_Type__c = 'Center Based';
                oAccount.PO_Number__c='2354';
                oAccount.RecordTypeId = cdspRecTypeId;
                oAccount.Compass_Id__c = String.ValueOf(i+1);
                oAccount.Beneficiary_Status__c = 'Active';
                oAccount.ICP__c = lstAccount[0].id;
                oAccount.Review_Status__c='Approved';
                oAccount.CDSP_Start_Date__c = System.today() - 30;
                oAccount.Actual_Registration_Date__c = System.Today();
                oAccount.Country__c = 'Ecuador';
                oAccount.Formal_Education_Status__c='Primary';
                oAccount.Local_Grade_Level__c = 'Primary 5B';
                oAccount.Type_Of_Vocational_Education__c='Not enrolled';
                oAccount.Not_Enrolled_In_Education_Reason__c='Testing Not Enrolled in Education';
                oAccount.Height_Cm__c = 100;
                oAccount.Weight_Kg__c = 20;
                oAccount.BEN_Chore_List__c = 'Cleaning';
                oAccount.Fun_Things_To_Do__c = 'Baseball';
                oAccount.Planned_Completion_Date__c = System.Today() + 20;
                oAccount.Household__c = oHousehold.id;
                oAccount.FirstName = 'John';
                lstCDSPAccounts.add(oAccount);
            }
            insert lstCDSPAccounts;
            System.assertNotEquals(null,lstCDSPAccounts);
            Contact oContact = [Select Id from Contact Limit 1];
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = oContact.Id ; 
            oUser2.PortalRole = 'Manager' ;
            oUser2.Is_Sharing_Completed__c = false ;
            insert oUser2;
            System.assertEquals(false,oUser2.Is_Sharing_Completed__c);
            List<AccountShare> lstAccountShare = new List<AccountShare>();
            for(Account oAccount: lstCDSPAccounts){
                AccountShare oAccountShare = new AccountShare();
                oAccountShare.Accountid = oAccount.Id;            
                oAccountShare.UserOrGroupId = oUser2.Id;
                oAccountShare.AccountAccesslevel = Constants.EDIT_ACCESS;
                oAccountShare.OpportunityAccesslevel = 'None';
                lstAccountShare.add(oAccountShare);
            }
            
            Test.startTest();
            QueueAccountShare oQueueAccountShare = new QueueAccountShare(oUser2,lstAccountShare, null, null, 50);
            System.enqueueJob(oQueueAccountShare);
            Test.stopTest();
            List<AccountShare> lstAccountShareInserted = [Select Id from AccountShare where UserOrGroupId =: oUser2.Id and RowCause = 'Manual' And AccountId IN: lstCDSPAccounts];
            System.assertEquals(lstCDSPAccounts.size(), lstAccountShareInserted.size());
        }
    }
    
    static TestMethod void QueueAccountShareMethod2() {
        User oUser = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser;      
        
        System.runAs(oUser){
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;  
            Household__c oHousehold = [Select Id from Household__c Limit 1];
            List<Account> lstAccount = [Select id,CDSP_Capacity__c from Account where recordType.name = 'ICP' Limit 1];
            List<Account> lstCDSPAccounts = new List<Account>();
            Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME);
            for(Integer i=0; i <= 50; i++){
                Account oAccount = new Account();
                oAccount.LastName = 'Doe';
                oAccount.Local_Beneficiary_Number__c = String.ValueOf(i+1);
                oAccount.PersonBirthdate = System.Today()-1200;
                oAccount.Gender__c = 'Male';
                oAccount.Beneficiary_Confession_Of_Faith_Date__c = System.Today();
                oAccount.Active_Program__c = Constants.CDSP;
                oAccount.CDSP_Type__c = 'Center Based';
                oAccount.PO_Number__c='2354';
                oAccount.RecordTypeId = cdspRecTypeId;
                oAccount.Compass_Id__c = String.ValueOf(i+1);
                oAccount.Beneficiary_Status__c = 'Active';
                oAccount.ICP__c = lstAccount[0].id;
                oAccount.Review_Status__c='Approved';
                oAccount.CDSP_Start_Date__c = System.today() - 30;
                oAccount.Actual_Registration_Date__c = System.Today();
                oAccount.Country__c = 'Ecuador';
                oAccount.Formal_Education_Status__c='Primary';
                oAccount.Local_Grade_Level__c = 'Primary 5B';
                oAccount.Type_Of_Vocational_Education__c='Not enrolled';
                oAccount.Not_Enrolled_In_Education_Reason__c='Testing Not Enrolled in Education';
                oAccount.Height_Cm__c = 100;
                oAccount.Weight_Kg__c = 20;
                oAccount.BEN_Chore_List__c = 'Cleaning';
                oAccount.Fun_Things_To_Do__c = 'Baseball';
                oAccount.Planned_Completion_Date__c = System.Today() + 20;
                oAccount.Household__c = oHousehold.id;
                oAccount.FirstName = 'John';
                lstCDSPAccounts.add(oAccount);
            }
            insert lstCDSPAccounts;
            System.assertNotEquals(null,lstCDSPAccounts);
            Contact oContact = [Select Id from Contact Limit 1];
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = oContact.Id ; 
            oUser2.PortalRole = 'Manager' ;
            oUser2.Is_Sharing_Completed__c = false ;
            insert oUser2;
              System.assertEquals('Manager',oUser2.PortalRole);          
            List<AccountShare> lstAccountShare = new List<AccountShare>();
            for(Account oAccount: lstCDSPAccounts){
                AccountShare oAccountShare = new AccountShare();
                oAccountShare.Accountid = oAccount.Id;            
                oAccountShare.UserOrGroupId = oUser2.Id;
                oAccountShare.AccountAccesslevel = Constants.EDIT_ACCESS;
                oAccountShare.OpportunityAccesslevel = 'None';
                lstAccountShare.add(oAccountShare);
            }
            
            Test.startTest();
            QueueAccountShare oQueueAccountShare = new QueueAccountShare(oUser2,lstAccountShare, null, null, 40);
            System.enqueueJob(oQueueAccountShare);
            Test.stopTest();
            
            List<AccountShare> lstAccountShareInserted = [Select Id from AccountShare where UserOrGroupId =: oUser2.Id and RowCause = 'Manual' And AccountId IN: lstCDSPAccounts];
            System.assertEquals(40, lstAccountShareInserted.size());
        }
    }

}