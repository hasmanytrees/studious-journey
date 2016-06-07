/******************************************************************************************************
Class Name         : QueueDeleteRecordsBeforeBenefShare_Test
Description        : This class contains unit tests for validating the behavior of 
                     class: QueueDeleteRecordsBeforeBenefShare                    
Created By         : Danish Ahmed
Created On         : 12-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest(SeeAllData=false)
private class QueueDeleteRecordsBeforeBenefShare_Test{
    @testSetup static void setup() {
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
        List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
        insert lstRegionTestData ;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;  
        // to create test data for Field office 
        List<string> lstFieldOfficeNames = new List<String> (  ) ; 
        lstFieldOfficeNames.add( 'Ecuador' ) ; 
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
        List<Contact> lstContact = new List<Contact>();
        Contact oConTest1 = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccount[0].ID ) ; 
        Contact oConTest2 = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccount[1].ID ) ; 
        lstContact.add(oConTest1);
        lstContact.add(oConTest2);
        Insert lstContact;
        System.assertNotEquals(null,lstContact);
        /*list<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
        insert lstHouseHoldData ;
        // To insert HouseholdMemberTestData
        list<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
        insert lstHouseHoldMemberData;
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccount , lstHouseHoldData , lstHouseHoldMemberData);
        insert lstCDSPAccounts;*/
                  
    }
    
    /*static TestMethod void QueueDeleteRecordsBeforeBenefShareMethod1() {
        User oUser = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser;        
        
        System.runAs(oUser){
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<Account> lstAccount = [Select id from Account where recordType.name = 'ICP' Limit 2];
            Set<Id> setICPId = new Set<Id>();
            setICPId.add(lstAccount[0].Id);
            List<Household__c> lstHousehold = new List<Household__c>();
            List<Household__c> lstHouseholdToInsert = new List<Household__c>();
            for(Integer i=0; i < 2; i++){
                lstHousehold =  TestDataUtility.HouseholdTestData();
                lstHouseholdToInsert.addAll(lstHousehold);
            } 
            insert lstHouseholdToInsert;
            Map<Id,Id> mapHouseholdIdToICPid = new Map<Id,Id>();
            List<Household_Member__c> lstHoseholdMember = new List<Household_Member__c>();
            List<Household_Member__c> lstHoseholdMemberToInsert = new List<Household_Member__c>();
            for(Integer j = 0; j < lstHouseholdToInsert.size(); j++){
                List<Household__c> lstHouseholdtemp = new List<Household__c>();
                lstHouseholdtemp.add(lstHouseholdToInsert[j]);
                lstHoseholdMember = TestDataUtility.HouseholdMemberTestData(lstHouseholdToInsert);
                lstHoseholdMemberToInsert.addAll(lstHoseholdMember);
                mapHouseholdIdToICPid.put(lstAccount[0].Id,lstHouseholdToInsert[j].Id);
            }
            insert lstHoseholdMemberToInsert;
            
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
                oAccount.Household__c = lstHouseholdToInsert[k].id;
                oAccount.FirstName = 'John';
                lstCDSPAccounts.add(oAccount);
            }
            insert lstCDSPAccounts;
            List<Content__c> lstContentTestData1 = TestDataUtility.ContentTestData (lstCDSPAccounts); 
            insert lstContentTestData1; 
            Contact oContact = [Select Id from Contact Limit 1];
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
            Test.startTest();
            QueueDeleteRecordsBeforeBenefShare oQueueDeleteRecordsBeforeBenefShare = new QueueDeleteRecordsBeforeBenefShare(lstCDSPAccounts, null,true,setICPId, null, mapHouseholdIdToICPid, null, null);
            System.enqueueJob(oQueueDeleteRecordsBeforeBenefShare);
            Test.stopTest();
           
        }
    }*/
    
    static TestMethod void QueueDeleteRecordsBeforeBenefShareMethod2() {
        User oUser = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser;        
        
        System.runAs(oUser){
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<Account> lstAccount = [Select id from Account where recordType.name = 'ICP' Limit 2];
            Set<Id> setICPId = new Set<Id>();
            setICPId.add(lstAccount[0].Id);
            List<Household__c> lstHousehold = new List<Household__c>();
            List<Household__c> lstHouseholdToInsert = new List<Household__c>();
            for(Integer i=0; i < 2; i++){
                lstHousehold =  TestDataUtility.HouseholdTestData();
                lstHouseholdToInsert.addAll(lstHousehold);
            } 
            insert lstHouseholdToInsert;
            Map<Id,Id> mapHouseholdIdToICPid = new Map<Id,Id>();
            List<Household_Member__c> lstHoseholdMember = new List<Household_Member__c>();
            List<Household_Member__c> lstHoseholdMemberToInsert = new List<Household_Member__c>();
            for(Integer j = 0; j < lstHouseholdToInsert.size(); j++){
                List<Household__c> lstHouseholdtemp = new List<Household__c>();
                lstHouseholdtemp.add(lstHouseholdToInsert[j]);
                lstHoseholdMember = TestDataUtility.HouseholdMemberTestData(lstHouseholdToInsert);
                lstHoseholdMemberToInsert.addAll(lstHoseholdMember);
                mapHouseholdIdToICPid.put(lstAccount[0].Id,lstHouseholdToInsert[j].Id);
            }
            insert lstHoseholdMemberToInsert;
            Set<Id> setHouseholdIdToDelete = new Set<Id>();
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
                oAccount.Household__c = lstHouseholdToInsert[k].id;
                oAccount.FirstName = 'John';
                oAccount.Correspondence_Country__c = 'Ecuador';
                lstCDSPAccounts.add(oAccount);
                setHouseholdIdToDelete.add(lstHouseholdToInsert[k].id);
            }
            insert lstCDSPAccounts;
            System.assertNotEquals(null,lstCDSPAccounts);
            Set<Id> setPreviousICP = new Set<Id>();
            Set<Id> setBenefIdForDelete = new Set<Id>();
            Map<Id, Account> mapOldrecords = new Map<Id,Account>();
            for(Account oAccount: lstCDSPAccounts){
                mapOldrecords.put(oAccount.Id, oAccount);
                setPreviousICP.add(oAccount.ICP__c);
                oAccount.ICP__c = lstAccount[1].Id;
                setBenefIdForDelete.add(oAccount.Id);                
            }
            //update lstCDSPAccounts;
            List<Content__c> lstContentTestData1 = TestDataUtility.ContentTestData (lstCDSPAccounts); 
            insert lstContentTestData1; 
            List<Contact> lstContacts = [Select Id from Contact Limit 2];
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = lstContacts[0].Id ; 
            oUser2.PortalRole = 'Manager' ;
            oUser2.Is_Sharing_Completed__c = false ;
            insert oUser2;
            User oUser3 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser3.ContactId = lstContacts[1].Id ; 
            oUser3.PortalRole = 'Manager' ;
            oUser3.Is_Sharing_Completed__c = false ;
            insert oUser3;
            List<Household__Share> lstHouseholdShare = new List<Household__Share>();
            for(Household__c oHousehold: lstHouseholdToInsert){
                Household__Share oHouseholdShare = new Household__Share();
                oHouseholdShare.ParentId = oHousehold.Id;
                oHouseholdShare.UserOrGroupId = oUser2.id;
                oHouseholdShare.AccessLevel = Constants.EDIT_ACCESS;
                oHouseholdShare.RowCause = Constants.APEX_BASED_SHARING;
                lstHouseholdShare.add(oHouseholdShare);
            }
            insert lstHouseholdShare;
            List<AccountShare> lstAccountShare = new List<AccountShare>();
            for(Account oAccount: lstCDSPAccounts){
                AccountShare oAccountShare = new AccountShare();
                oAccountShare.Accountid = oAccount.Id;            
                oAccountShare.UserOrGroupId = oUser2.Id;
                oAccountShare.AccountAccesslevel = Constants.EDIT_ACCESS;
                oAccountShare.OpportunityAccesslevel = 'None';
                lstAccountShare.add(oAccountShare);
            }
            insert lstAccountShare;
            List<Content__Share> lstContentShare=new list<Content__Share>();
            for(Content__c oContent: lstContentTestData1){
                Content__Share oContentShare = new Content__Share();
                oContentShare.parentid= oContent.id;
                oContentShare.userorgroupid = oUser2.id;
                oContentShare.accesslevel = 'Edit';
                oContentShare.RowCause = Constants.APEX_BASED_SHARING;
                lstContentShare.add(oContentShare);
            } 
            insert lstContentShare;
            System.assertNotEquals(null,lstContentShare);
            Test.startTest();
            QueueDeleteRecordsBeforeBenefShare oQueueDeleteRecordsBeforeBenefShare = new QueueDeleteRecordsBeforeBenefShare(lstCDSPAccounts, mapOldRecords,false,setICPId, setHouseholdIdToDelete, mapHouseholdIdToICPid, setPreviousICP, setBenefIdForDelete);
            System.enqueueJob(oQueueDeleteRecordsBeforeBenefShare);
            Test.stopTest();
           
        }
    }
    
    static TestMethod void QueueDeleteRecordsBeforeBenefShareMethod3() {
        List<Contact> lstContacts = [Select Id from Contact Limit 2];
        User oUser = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
        oUser.ContactId = lstContacts[0].Id ; 
        oUser.PortalRole = 'Manager' ;
        oUser.Is_Sharing_Completed__c = false ;
        insert oUser;
        User oUser3 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
        oUser3.ContactId = lstContacts[1].Id ; 
        oUser3.PortalRole = 'Manager' ;
        oUser3.Is_Sharing_Completed__c = false ;
        insert oUser3;       
        
        System.runAs(oUser){
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            List<Account> lstAccount = [Select id from Account where recordType.name = 'ICP' Limit 2];
            Set<Id> setICPId = new Set<Id>();
            setICPId.add(lstAccount[0].Id);
            List<Household__c> lstHousehold = new List<Household__c>();
            List<Household__c> lstHouseholdToInsert = new List<Household__c>();
            for(Integer i=0; i < 2; i++){
                lstHousehold =  TestDataUtility.HouseholdTestData();
                lstHouseholdToInsert.addAll(lstHousehold);
            } 
            insert lstHouseholdToInsert;
            Map<Id,Id> mapHouseholdIdToICPid = new Map<Id,Id>();
            List<Household_Member__c> lstHoseholdMember = new List<Household_Member__c>();
            /*List<Household_Member__c> lstHoseholdMemberToInsert = TestDataUtility.HouseholdMemberTestData(lstHouseholdToInsert);
            for(Integer j = 0; j < lstHouseholdToInsert.size(); j++){
                List<Household__c> lstHouseholdtemp = new List<Household__c>();
                lstHouseholdtemp.add(lstHouseholdToInsert[j]);
                lstHoseholdMember = TestDataUtility.HouseholdMemberTestData(lstHouseholdToInsert);
                lstHoseholdMemberToInsert.addAll(lstHoseholdMember);
                mapHouseholdIdToICPid.put(lstAccount[0].Id,lstHouseholdToInsert[j].Id);
            }*/
            List<Household_Member__c> lstHoseholdMemberToInsert = new List<Household_Member__c>();
            for(Household__c ohousehold: lstHouseholdToInsert){
                Household_Member__c oHouseholdMember = new Household_Member__c();
                oHouseholdMember.Household__c = ohousehold.id;
                oHouseholdMember.Role__c = 'Mother';
                oHouseholdMember.Is_Caregiver__c = true;
                oHouseholdMember.Is_Primary_Caregiver__c = true;
                lstHoseholdMemberToInsert.add(oHouseholdMember);
                mapHouseholdIdToICPid.put(lstAccount[0].Id,ohousehold.Id);
            }
            insert lstHoseholdMemberToInsert;
            
            Set<Id> setHouseholdIdToDelete = new Set<Id>();
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
                oAccount.Beneficiary_Status__c = 'Draft';
                oAccount.ICP__c = lstAccount[0].id;
                oAccount.Review_Status__c='Submitted';
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
                oAccount.Household__c = lstHouseholdToInsert[k].id;
                oAccount.FirstName = 'John';
                lstCDSPAccounts.add(oAccount);
                setHouseholdIdToDelete.add(lstHouseholdToInsert[k].id);
            }
            insert lstCDSPAccounts;
            System.assertNotEquals(null,lstCDSPAccounts);
            Set<Id> setPreviousICP = new Set<Id>();
            Set<Id> setBenefIdForDelete = new Set<Id>();
            Map<Id, Account> mapOldrecords = new Map<Id,Account>();
            for(Account oAccount: lstCDSPAccounts){
                mapOldrecords.put(oAccount.Id, oAccount);
                setPreviousICP.add(oAccount.ICP__c);
                oAccount.ICP__c = lstAccount[0].Id;
                setBenefIdForDelete.add(oAccount.Id);                
            }
            //update lstCDSPAccounts;
            List<Content__c> lstContentTestData1 = TestDataUtility.ContentTestData (lstCDSPAccounts); 
            insert lstContentTestData1; 
            System.assertNotEquals(null,lstContentTestData1);
            /*User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = lstContacts[0].Id ; 
            oUser2.PortalRole = 'Manager' ;
            oUser2.Is_Sharing_Completed__c = false ;
            insert oUser2;
            User oUser3 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser3.ContactId = lstContacts[1].Id ; 
            oUser3.PortalRole = 'Manager' ;
            oUser3.Is_Sharing_Completed__c = false ;
            insert oUser3;*/
            /*List<Household__Share> lstHouseholdShare = new List<Household__Share>();
            for(Household__c oHousehold: lstHouseholdToInsert){
                Household__Share oHouseholdShare = new Household__Share();
                oHouseholdShare.ParentId = oHousehold.Id;
                oHouseholdShare.UserOrGroupId = oUser.id;
                oHouseholdShare.AccessLevel = Constants.EDIT_ACCESS;
                //oHouseholdShare.RowCause = Constants.APEX_BASED_SHARING;
                lstHouseholdShare.add(oHouseholdShare);
            }
            insert lstHouseholdShare;
            List<AccountShare> lstAccountShare = new List<AccountShare>();
            for(Account oAccount: lstCDSPAccounts){
                AccountShare oAccountShare = new AccountShare();
                oAccountShare.Accountid = oAccount.Id;            
                oAccountShare.UserOrGroupId = oUser.Id;
                oAccountShare.AccountAccesslevel = Constants.EDIT_ACCESS;
                oAccountShare.OpportunityAccesslevel = 'None';
                lstAccountShare.add(oAccountShare);
            }
            insert lstAccountShare;
            List<Content__Share> lstContentShare=new list<Content__Share>();
            for(Content__c oContent: lstContentTestData1){
                Content__Share oContentShare = new Content__Share();
                oContentShare.parentid= oContent.id;
                oContentShare.userorgroupid = oUser.id;
                oContentShare.accesslevel = 'Edit';
                oContentShare.RowCause = Constants.APEX_BASED_SHARING;
                lstContentShare.add(oContentShare);
            } 
            insert lstContentShare;*/
            Test.startTest();
            QueueDeleteRecordsBeforeBenefShare oQueueDeleteRecordsBeforeBenefShare = new QueueDeleteRecordsBeforeBenefShare(lstCDSPAccounts, mapOldRecords,false,setICPId, setHouseholdIdToDelete, mapHouseholdIdToICPid, setPreviousICP, setBenefIdForDelete);
            System.enqueueJob(oQueueDeleteRecordsBeforeBenefShare);
            Test.stopTest();
           
        }
    }
}