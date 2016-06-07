/******************************************************************************************************
Class Name         : QueueAPAndAddressShare_Test
Description        : This class contains unit tests for validating the behavior of class: QueueAPAndAddressShare
                     
Created By         : Danish Ahmed
Created On         : 12-Oct-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest(SeeAllData=false)
private class QueueAPAndAddressShare_Test{
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
        List<Account> lstAccount = new List<Account>();
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccountNew = TestDataUtility.ICPTestData() ;
        oICPAccountNew.Cluster__c = lstClusterTestData[0].ID ;
        oICPAccountNew.ICP_Id__c ='TU156';
        lstAccount.add(oICPAccountNew);
        insert lstAccount;
        System.assertNotEquals(null,lstAccount);
        Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccount[0].Id, Role_At_ICP__c = 'Tutor / Implementer') ; 
        Insert oConTest ;
         System.assertNotEquals(null,oConTest.id);
    }
    
    static TestMethod void QueueAPAndAddressShareMethod() {
        User oUser = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser;
        
        System.runAs(oUser){
            List<Account> lstICP = [Select Id from Account where recordType.Name = 'ICP' limit 1];
            List<Contact> lstContact = [Select Id,AccountId from Contact Limit 1];
            List<Activity_Plan__c> lstAPPlan = TestdataUtility.APTestData(lstICP,  oUser);
            insert lstAPPlan;
            
            Id icpAddressRecTypeId = Utility.getRecordTypeIdByDeveloperName(Address__c.SObjectType,
                Constants.ICP_ADDRESS_RT_API_NAME);
            Address__c oAddress = new Address__c();
            oAddress.Account__c = lstICP[0].Id;
            oAddress.City__c = 'NY';
            oAddress.Street__c = '123';
            oAddress.Country__c = 'USA';
            oAddress.State__c = 'NY';
            oAddress.Zip_Code__c = '11111';
            oAddress.Status__c = 'Active';
            oAddress.Address_Type__c = 'Mail Address';
            oAddress.RecordTypeId = icpAddressRecTypeId;            
            insert oAddress;
            
            Yearly_Class_Schedule__c oYearlyClass = TestDataUtility.yearlyClassScheduleTestData(lstICP[0], lstContact[0]);
            insert oYearlyClass;
            
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = lstContact[0].Id;
            oUser2.PortalRole = 'Manager' ;
            oUser2.Is_Sharing_Completed__c = false ;
            insert oUser2;
            
            Test.startTest();
            user ouser3 = [Select Id, accountid from user where id=: ouser2.Id];
            QueueAPAndAddressShare oQueueAPAndAddressShare = new QueueAPAndAddressShare(oUser3);
            System.enqueueJob(oQueueAPAndAddressShare);
            Test.stopTest();
            
            List<Activity_Plan__Share> lstAPShareInserted = [Select Id from Activity_Plan__Share where UserOrGroupId =: oUser2.Id and RowCause =: Constants.APEX_BASED_SHARING And ParentId IN: lstAPPlan];
            System.assert(lstAPShareInserted.size() > 0);
            
            List<Address__Share> lstAddressShareInserted = [Select Id from Address__Share where UserOrGroupId =: oUser2.Id and RowCause =: Constants.APEX_BASED_SHARING And ParentId =: oAddress.Id];
            System.assert(lstAPShareInserted.size() > 0);
            
            List<Yearly_Class_Schedule__Share> lstYearlyClassInserted = [Select Id from Yearly_Class_Schedule__Share where UserOrGroupId =: oUser2.Id and RowCause =: Constants.APEX_BASED_SHARING And ParentId =: oYearlyClass.Id];
            System.assert(lstAPShareInserted.size() > 0);
            
            
        }
    }
}