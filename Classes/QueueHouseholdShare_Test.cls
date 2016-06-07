/******************************************************************************************************
Class Name         : QueueHouseholdShare_Test
Description        : This class contains unit tests for validating the behavior of class: QueueHouseholdShare
                     
Created By         : Sfurti Pandey
Created On         : 22-Sept-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest(SeeAllData=false)
private class QueueHouseholdShare_Test {
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
        lstFieldOfficeNames.add( 'Ethiopia' ) ; 
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
        List<Account> lstAccount = new List<Account>();
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ;              
        lstAccount.add(oICPAccount);
        Account oICPAccountNew = TestDataUtility.ICPTestData() ;
        oICPAccountNew.Cluster__c = lstClusterTestData[0].ID ;
        oICPAccountNew.ICP_Id__c ='TU156';
        lstAccount.add(oICPAccountNew);
        insert lstAccount;
        System.assertNotEquals(null,lstAccount);
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
    
    static TestMethod void QueueHouseholdShareMethod1() {
        User oUser = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser;        
        
        System.runAs(oUser){
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<Household__c> lstHousehold = new List<Household__c>();
            List<Household__c> lstHouseholdToInsert = new List<Household__c>();
            for(Integer i=0; i < 10; i++){
                lstHousehold =  TestDataUtility.HouseholdTestData();
                lstHouseholdToInsert.addAll(lstHousehold);
            } 
            insert lstHouseholdToInsert;
            Test.startTest();
            List<Household_Member__c> lstHoseholdMember = new List<Household_Member__c>();
            List<Household_Member__c> lstHoseholdMemberToInsert = new List<Household_Member__c>();
            for(Integer j = 0; j < lstHouseholdToInsert.size(); j++){
                List<Household__c> lstHouseholdtemp = new List<Household__c>();
                lstHouseholdtemp.add(lstHouseholdToInsert[j]);
                lstHoseholdMember = TestDataUtility.HouseholdMemberTestData(lstHouseholdToInsert);
                lstHoseholdMemberToInsert.addAll(lstHoseholdMember);
            }
            insert lstHoseholdMemberToInsert;
            List<Account> lstAccount = [Select id from Account where recordType.name = 'ICP' Limit 1];
            List<Account> lstCDSPAccounts = new List<Account>();
            Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME);
            for(Integer k=0; k < lstHouseholdToInsert.size(); k++){
                Account oAccount = new Account();
                oAccount.LastName = 'Doe';
                oAccount.Local_Beneficiary_Number__c = String.ValueOf(k+1);
                oAccount.PersonBirthdate = System.Today()-1200;
                oAccount.Gender__c = 'Male';
                oAccount.Beneficiary_Confession_Of_Faith_Date__c = System.Today();
                oAccount.Active_Program__c = 'CDSP';
                oAccount.CDSP_Type__c = 'Center Based';
                oAccount.PO_Number__c='2354';
                oAccount.RecordTypeId = cdspRecTypeId;
                oAccount.Compass_Id__c = String.ValueOf(k+1);
                oAccount.Beneficiary_Status__c = 'Active';
                oAccount.ICP__c = lstAccount[0].id;
                oAccount.Review_Status__c='Approved';
                oAccount.CDSP_Start_Date__c = System.today() - 30;
                oAccount.Actual_Registration_Date__c = System.Today();
                oAccount.Country__c = 'Ethiopia';
                oAccount.Formal_Education_Status__c='Primary';
                oAccount.Local_Grade_Level__c = 'Primary 5B';
                oAccount.Type_Of_Vocational_Education__c='Not enrolled';
                oAccount.Not_Enrolled_In_Education_Reason__c='Testing Not Enrolled in Education';
                oAccount.Height_Cm__c = 100;
                oAccount.Weight_Kg__c = 20;
                oAccount.BEN_Chore_List__c = 'Cleaning';
                oAccount.Fun_Things_To_Do__c = 'Baseball';
                oAccount.Planned_Completion_Date__c = System.Today() + 20;
                oAccount.Household__c = lstHouseholdToInsert[k].id;
                oAccount.FirstName = 'John';
                oAccount.Correspondence_Country__c = 'Ethiopia';
                oAccount.Correspondence_Language__c= 'Amharic';
                lstCDSPAccounts.add(oAccount);
            }
            insert lstCDSPAccounts;
            List<Content__c> lstContentTestData1 = TestDataUtility.ContentTestData (lstCDSPAccounts); 
            insert lstContentTestData1; 
            Contact oContact = [Select Id from Contact Limit 1];
            Test.stopTest();
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = oContact.Id ; 
            oUser2.PortalRole = 'Manager' ;
            oUser2.Is_Sharing_Completed__c = false ;
            insert oUser2;
            List<Household__Share> lstHouseholdShare = new List<Household__Share>();
            for(Household__c oHousehold: lstHouseholdToInsert){
                Household__Share oHouseholdShare = new Household__Share();
                oHouseholdShare.ParentId = oHousehold.Id;
                oHouseholdShare.UserOrGroupId = oUser2.id;
                oHouseholdShare.AccessLevel = Constants.EDIT_ACCESS;
                oHouseholdShare.RowCause = Constants.APEX_BASED_SHARING;
                lstHouseholdShare.add(oHouseholdShare);
            }
            
            QueueHouseholdShare oQueueHouseholdShare = new QueueHouseholdShare(oUser2, lstHouseholdShare, null, 50);
            System.enqueueJob(oQueueHouseholdShare);            
            List<Household__Share> lstHouseholdShareInserted = [Select Id from Household__Share where UserOrGroupId =: oUser2.Id And RowCause =: Constants.APEX_BASED_SHARING And ParentId IN: lstHouseholdToInsert];
           // System.assertEquals(lstHouseholdToInsert.size(), lstHouseholdShareInserted.size());
        }
    }
    
    static TestMethod void QueueHouseholdShareMethod2() {
        User oUser = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser;
               
        System.runAs(oUser){
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<Household__c> lstHousehold = new List<Household__c>();
            List<Household__c> lstHouseholdToInsert = new List<Household__c>();
            for(Integer i=0; i < 10; i++){
                lstHousehold =  TestDataUtility.HouseholdTestData();
                lstHouseholdToInsert.addAll(lstHousehold);
            } 
            insert lstHouseholdToInsert;
             Test.startTest();
            List<Household_Member__c> lstHoseholdMember = new List<Household_Member__c>();
            List<Household_Member__c> lstHoseholdMemberToInsert = new List<Household_Member__c>();
            for(Integer j = 0; j < lstHouseholdToInsert.size(); j++){
                List<Household__c> lstHouseholdtemp = new List<Household__c>();
                lstHouseholdtemp.add(lstHouseholdToInsert[j]);
                lstHoseholdMember = TestDataUtility.HouseholdMemberTestData(lstHouseholdToInsert);
                lstHoseholdMemberToInsert.addAll(lstHoseholdMember);
            }
            insert lstHoseholdMemberToInsert;
            List<Account> lstAccount = [Select id from Account where recordType.name = 'ICP' Limit 1];
            List<Account> lstCDSPAccounts = new List<Account>();
            Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME);
            for(Integer k=0; k < lstHouseholdToInsert.size(); k++){
                Account oAccount = new Account();
                oAccount.LastName = 'Doe';
                oAccount.Local_Beneficiary_Number__c = String.ValueOf(k+1);
                oAccount.PersonBirthdate = System.Today()-1200;
                oAccount.Gender__c = 'Male';
                oAccount.Beneficiary_Confession_Of_Faith_Date__c = System.Today();
                oAccount.Active_Program__c = 'CDSP';
                oAccount.CDSP_Type__c = 'Center Based';
                oAccount.PO_Number__c='2354';
                oAccount.RecordTypeId = cdspRecTypeId;
                oAccount.Compass_Id__c = String.ValueOf(k+1);
                oAccount.Beneficiary_Status__c = 'Active';
                oAccount.ICP__c = lstAccount[0].id;
                oAccount.Review_Status__c='Approved';
                oAccount.CDSP_Start_Date__c = System.today() - 30;
                oAccount.Actual_Registration_Date__c = System.Today();
                oAccount.Country__c = 'Ethiopia';
                oAccount.Formal_Education_Status__c='Primary';
                oAccount.Local_Grade_Level__c = 'Primary 5B';
                oAccount.Type_Of_Vocational_Education__c='Not enrolled';
                oAccount.Not_Enrolled_In_Education_Reason__c='Testing Not Enrolled in Education';
                oAccount.Height_Cm__c = 100;
                oAccount.Weight_Kg__c = 20;
                oAccount.BEN_Chore_List__c = 'Cleaning';
                oAccount.Fun_Things_To_Do__c = 'Baseball';
                oAccount.Planned_Completion_Date__c = System.Today() + 20;
                oAccount.Household__c = lstHouseholdToInsert[k].id;
                oAccount.FirstName = 'John';
                oAccount.Correspondence_Country__c = 'Ethiopia';
                oAccount.Correspondence_Language__c= 'Amharic';
                lstCDSPAccounts.add(oAccount);
            }
            insert lstCDSPAccounts;
            List<Content__c> lstContentTestData1 = TestDataUtility.ContentTestData (lstCDSPAccounts); 
            insert lstContentTestData1;
            Contact oContact = [Select Id from Contact Limit 1];
            Test.stopTest();
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = oContact.Id ; 
            oUser2.PortalRole = 'Manager' ;
            oUser2.Is_Sharing_Completed__c = false ;
            insert oUser2;
            List<Household__Share> lstHouseholdShare = new List<Household__Share>();
            for(Household__c oHousehold: lstHouseholdToInsert){
                Household__Share oHouseholdShare = new Household__Share();
                oHouseholdShare.ParentId = oHousehold.Id;
                oHouseholdShare.UserOrGroupId = oUser2.id;
                oHouseholdShare.AccessLevel = Constants.EDIT_ACCESS;
                oHouseholdShare.RowCause = Constants.APEX_BASED_SHARING;
                lstHouseholdShare.add(oHouseholdShare);
            }
           
            QueueHouseholdShare oQueueHouseholdShare = new QueueHouseholdShare(oUser2, lstHouseholdShare, null, 5);
            System.enqueueJob(oQueueHouseholdShare);
            
            List<Household__Share> lstHouseholdShareInserted = [Select Id from Household__Share where UserOrGroupId =: oUser2.Id and RowCause =: Constants.APEX_BASED_SHARING And ParentId IN: lstHouseholdToInsert];
           // System.assertEquals(5, lstHouseholdShareInserted.size());
        }
    }
}