/******************************************************************************************************
Class Name         : AccountHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: AccountHandler
and AccountTrigger
Created By         : Sudipta Nayak
Created On         : 16-Feb-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class AccountHandler_Test {
    @testSetup static void setup() {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        System.RunAs(UserPF){
        List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
        List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'lstAccountId' ) ; 
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        TriggerContextUtility.bFlagForTestDataBLEInsertion=False;
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
        insert lstRegionTestData ;  
        // to create test data for Field office 
        List<string> lstFieldOfficeNames = new List<String> (  ) ; 
        lstFieldOfficeNames.add( 'Ethiopia' ) ; 
        list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;  
        lstFieldOfficeData[0].FO_Next_Schedule_Print_Date__c =System.Today()+4;
        lstFieldOfficeData[0].Field_Office_Id__c='ET';
        insert lstFieldOfficeData ;      
        // To Create Territory test data 
        List<string> lstTerritoryNames = new List<String> (  ) ; 
        lstTerritoryNames.add( 'lstAccountId' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ;
        insert lstTerritoryTestData;
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'Ethiopia' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
        insert lstClusterTestData ;
        List<Account> lstAccount=new List<Account>();
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ;
        oICPAccount.ICP_Status__c='Active';
        lstAccount.add(oICPAccount) ;
        Account oICPAccountNew =TestDataUtility.ICPTestData() ;
        oICPAccountNew.ICP_Id__c = 'TD155';
        lstAccount.add(oICPAccountNew) ;
        insert lstAccount;
        System.assertNotEquals(null,lstAccount);
        }
    }
    static testMethod void accountCDSPTest(){
        User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];
        //insert UserPF;
        User UserCD = [Select id from user where LastName=:'TestingTCPT Read Only'];
        System.runAs(UserPF) {
            Test.startTest();
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bFlagForTestDataBLEInsertion=False;
            Id icpRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);
            list<Account> lstAccountICP =  new List<Account>();
            list<Account> lstAccountICPUpdate = new list<Account>();
            list<Id> AccountId = new List<Id>();
            list<Account> lstAccountId  =[Select id from aCCOUNT Where RecordTypeid=:icpRecordTypeId limit 10];
            list<Lead> lstLead =[Select id from Lead limit 10];
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccountId , lstHousehold, lstHouseholdMember) ;
            lstCDSPAccounts[0].Cognitive_Age_Group__c = '3-8' ; 
            lstCDSPAccounts[0].ICP__c = lstAccountId[0].ID ;  
            lstCDSPAccounts[1].ICP__c = lstAccountId[0].ID ; 
            lstCDSPAccounts[0].Beneficiary_Status__c='Active';
            lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2' ; 
            lstCDSPAccounts[1].Local_Grade_Level__c='PreSchool';
            lstCDSPAccounts[0].Local_Grade_Level__c='PreSchool';
            insert lstCDSPAccounts;
            lstCDSPAccounts[0].Gender__c='female';
            lstCDSPAccounts[1].Gender__c='Male';
            update lstCDSPAccounts;
            Global_Data__c globalDataMalnutrition = new Global_Data__c(Age_In_Months__c = 60, Length__c = 100,
            SD1__c = 16.799000, SD2__c = 18.589000, SD3neg__c = 12.155000, SD2neg__c = 11.257000, Gender__c = 'Male',
            Malnutrition_Data_Type__c = 'BMI');
            insert globalDataMalnutrition;
            Global_Data__c globalDataEducation = new Global_Data__c(US_Equivalent_Grade_Level__c = '5',
            Local_Grade_Level__c = 'Primary 5B', Country__c = 'Ecuador');
            insert globalDataEducation;
             system.assertequals('female',lstCDSPAccounts[0].Gender__c);
            Test.stopTest();
        }
    }
    static testMethod void accountCDSPSuspendedTest(){
        User oUser = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
        insert oUser;  
        User UserCD = [Select id from user where LastName=:'TestingTCPT Read Only'];
        System.runAs(oUser) {
            Test.startTest();
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bFlagForTestDataBLEInsertion=False;
            Id icpRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);
            list<Account> lstAccountICP =  new List<Account>();
            list<Account> lstAccountICPUpdate = new list<Account>();


            list<Account> lstAccount =[Select id from aCCOUNT Where RecordTypeid=:icpRecordTypeId limit 10];
            System.debug('######lstAccount'+lstAccount);
            List<ICP_Lifecycle_Events__c> lstICPLE = TestDataUtility.ILESuspensionTestData(lstAccount);
            insert lstICPLE[0];
            System.debug('##lstICPLE'+lstICPLE);

            lstAccount[0].ICP_Status__c='Suspended';
            update lstAccount;
            System.debug('$$$$$$lstAccount'+lstAccount);
            lstAccount[0].ICP_Status__c = Constants.ICP_STATUS_TRANSITIONED;
            update lstAccount;
            system.assertequals(Constants.ICP_STATUS_TRANSITIONED,lstAccount[0].ICP_Status__c);
            Test.stopTest();
        }
    }
    static testMethod void  benefCSPTest(){
        User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];
        //insert UserPF;
        User UserCD = [Select id from user where LastName=:'TestingTCPT Read Only'];
        System.runAs(UserPF) {
            Test.startTest();
            Id icpRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bFlagForTestDataBLEInsertion=False;

            list<Account> lstAccount =[Select id from aCCOUNT Where RecordTypeid=:icpRecordTypeId limit 10];
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            list<Account> lstAccountICPUpdate  =new list<Account>();
            User UserNewPF = TestDataUtility.UserTestData('Partnership Facilitator','PFnewUser', 'Ethiopia Partnership Facilitator');
            insert UserNewPF;

            for(Account ICP : [Select id,Partnership_Facilitator__c, RecordTypeId from Account where id in: lstAccount])  {
            ICP.Partnership_Facilitator__c = UserNewPF.Id;
            ICP.ICP_Status__c = 'Active';
            ICP.CSP_Capacity__c = 33;
            lstAccountICPUpdate.add(ICP);
            }
            update lstAccountICPUpdate;
            list<Account> lstAccountCSP = new list<Account>();
            lstAccountCSP = TestDataUtility.CSPBeneficiaryTestData( lstAccount, lstHousehold, lstHouseholdMember);
            TriggerContextUtility.bFirstRun = true;
            lstAccountCSP[0].ICP__c =  lstAccount[1].id;
            lstAccountCSP[1].ICP__c =  lstAccount[1].id;
            //  lstAccountCSP[0].Existing_Beneficiary__c = lstAccountCDSP[0].Id;
            lstAccountCSP[1].Actual_Registration_Date__c = System.today();
            lstAccountCSP[0].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            lstAccountCSP[1].Primary_Caregiver__c = lstHouseholdMember[0].id;
            TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstAccountCSP;
            system.assertnotequals(null,lstAccountCSP[0].id);
            Test.StopTest();
        }
    }
        static testMethod void  accountLeadTest(){
    User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];
    //insert UserPF;

    User UserCD = [Select id from user where LastName=:'TestingTCPT Read Only'];
    list<Id> AccountId = new List<Id>();
    list<Account> lstAccountICP =  new List<Account>();
    list<Account> lstAccountICPUpdate = new list<Account>();
        System.runAs(UserPF) {
            Test.startTest();
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bFlagForTestDataBLEInsertion=False;
            List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
            List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
            List<string> lstRegionNames = new List<String> (  ) ; 
            lstRegionNames.add( 'Ethiopia' ) ; 
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bFlagForTestDataBLEInsertion=False;
            list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
            insert lstRegionTestData ;  
            // to create test data for Field office 
            List<string> lstFieldOfficeNames = new List<String> (  ) ; 
            lstFieldOfficeNames.add( 'Ethiopia' ) ; 
            list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
            lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;  
            lstFieldOfficeData[0].FO_Next_Schedule_Print_Date__c =System.Today()+4;
            lstFieldOfficeData[0].Field_Office_Id__c='ET';
            insert lstFieldOfficeData ;      
            // To Create Territory test data 
            List<string> lstTerritoryNames = new List<String> (  ) ; 
            lstTerritoryNames.add( 'Ethiopia' ) ; 
            list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
            lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ;
            insert lstTerritoryTestData;
            List<string> lstClusterNames = new List<String> (  ) ; 
            lstClusterNames.add( 'Ethiopia' ) ; 
            list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
            lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            lstClusterTestData[0].Name = 'Ethiopia';
            insert lstClusterTestData ;
            list<id> IdsAccount=new list<id>();
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstClusterTestData, UserPF, UserPF);
            lstLead[0].ICP_ID__c = 'ET090';
            system.debug('****lstLead[0].Field_Office_For_Denominations__c'+lstLead[0].Field_Office_For_Denominations__c);
            system.debug('****lstLead[0].Field_Office__c'+lstLead[0].Field_Office__c);
            system.debug('****lstLead[0].Denomination_Church__c'+lstLead[0].Denomination_Church__c);
            
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Address__c oAddress=TestDataUtility.addressTestData(lstLead[0].id);

            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Id LeadId = lcr.getAccountId();
            IdsAccount.add(LeadId);
            lstAccountICP = TestDataUtility.ICPTestData(IdsAccount);
            Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccountICP[0].ID ) ; 
            Insert oConTest ;
            system.assertnotequals(null,oConTest.id);
            /*User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = oConTest.Id ; 
            oUser2.PortalRole = 'Manager' ;
            insert oUser2;*/
            test.Stoptest();
        }
    }
    static testMethod void accountCDSPInactiveTest(){
        User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];
        //insert UserPF;

        User UserCD = [Select id from user where LastName=:'TestingTCPT Read Only'];

        System.runAs(UserPF) {
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bFlagForTestDataBLEInsertion=False;
            Id icpRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);

            list<Account> lstAccountICP =  new List<Account>();
            list<Account> lstAccountICPUpdate = new list<Account>();
            list<Id> AccountId = new List<Id>();

            list<Account> lstAccountId  =[Select id from aCCOUNT Where RecordTypeid=:icpRecordTypeId limit 10];
            System.debug('######lstAccountId'+lstAccountId);

            list<Lead> lstLead =[Select id from Lead limit 10];
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;


            List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccountId , lstHousehold, lstHouseholdMember) ;
            lstCDSPAccounts[0].Cognitive_Age_Group__c = '3-8' ; 
            lstCDSPAccounts[0].ICP__c = lstAccountId[0].ID ;  
            lstCDSPAccounts[1].ICP__c = lstAccountId[0].ID ; 

            // lstCDSPAccounts[0].Formal_Education_Status__c='Primary';
            //lstCDSPAccounts[1].Formal_Education_Status__c='Primary';
            //lstCDSPAccounts[0].Type_Of_Vocational_Education__c='Agriculture';
            //lstCDSPAccounts[1].Type_Of_Vocational_Education__c='Agriculture';
            lstCDSPAccounts[0].Beneficiary_Status__c='Active';
            lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2' ; 
            lstCDSPAccounts[1].Local_Grade_Level__c='PreSchool';
            lstCDSPAccounts[0].Local_Grade_Level__c='PreSchool';
            insert lstCDSPAccounts;
            Test.startTest();
            Account oGlobalpartner= TestDataUtility.globalPartnerTestData( Label.Compasssion_USA_Global_Partner_Name);
            insert oGlobalpartner;
            Account oSupporterAccount= TestDataUtility.supporterTestData(oGlobalpartner);

            oSupporterAccount.SUP_Status__c='Active';
            insert oSupporterAccount;

            Commitment__c oCommitment =TestDataUtility.commitmentTestData(lstCDSPAccounts[0],oSupporterAccount);
            oCommitment.Status__c='Active';
            insert oCommitment;
            Contact contactGP = new Contact(FirstName = 'Bob', LastName = 'Phillip', AccountId =lstAccountId[0].Id);
            insert contactGP;
            Communication_Kit__c oCommKitData= TestDataUtility.commKitTestData(lstCDSPAccounts[0],oSupporterAccount,lstAccountId[0]);
            oCommKitData.Status__c =  Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED;
            oCommKitData.RecordTypeId = CommunicationKitHandler.sRecordTypeB2S;
            insert oCommKitData;
            oSupporterAccount.SUP_Status__c='Inactive';
            update oSupporterAccount;
            try{
                lstCDSPAccounts[0].Beneficiary_Status__c=Constants.INACTIVE;
                lstCDSPAccounts[0].Local_Beneficiary_Number__c='';
                update lstCDSPAccounts;
               
            }
            catch(Exception e){
            }
            system.assertequals(Constants.INACTIVE,lstCDSPAccounts[0].Beneficiary_Status__c);
            Test.stopTest();
        }
    }
    static testMethod void accountCDSPICPChangeTest(){
        User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];
        //insert UserPF;

        User UserCD = [Select id from user where LastName=:'TestingTCPT Read Only'];

        System.runAs(UserPF) {
            Test.startTest();
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bFlagForTestDataBLEInsertion=False;
            Id icpRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);

            list<Account> lstAccountICP =  new List<Account>();
            list<Account> lstAccountICPUpdate = new list<Account>();
            list<Id> AccountId = new List<Id>();

            list<Account> lstAccountId  =[Select id from aCCOUNT Where RecordTypeid=:icpRecordTypeId limit 10];
            System.debug('######lstAccountId'+lstAccountId);

            list<Lead> lstLead =[Select id from Lead limit 10];
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;

            List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccountId , lstHousehold, lstHouseholdMember) ;
            lstCDSPAccounts[0].Cognitive_Age_Group__c = '3-8' ; 
            lstCDSPAccounts[0].ICP__c = lstAccountId[0].ID ;  
            lstCDSPAccounts[1].ICP__c = lstAccountId[0].ID ; 

            // lstCDSPAccounts[0].Formal_Education_Status__c='Primary';
            //lstCDSPAccounts[1].Formal_Education_Status__c='Primary';
            //lstCDSPAccounts[0].Type_Of_Vocational_Education__c='Agriculture';
            //lstCDSPAccounts[1].Type_Of_Vocational_Education__c='Agriculture';
            lstCDSPAccounts[0].Beneficiary_Status__c='Active';
            lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2' ; 
            lstCDSPAccounts[1].Local_Grade_Level__c='PreSchool';
            lstCDSPAccounts[0].Local_Grade_Level__c='PreSchool';
            insert lstCDSPAccounts;

            Contact oConTest = new Contact (LastName = 'test contact', FirstName = 'test' , AccountID = lstAccountId[0].ID ) ; 
            Insert oConTest ;
            system.assertnotequals(null,oConTest.id);
            Test.StopTest();
        }

        
    }
    static testMethod void accountCDSPHouseHoldChangeTest(){
        User UserPF =[Select id from user where LastName=:'TestingPartnership Facilitator'];
        //insert UserPF;

        User UserCD = [Select id from user where LastName=:'TestingTCPT Read Only'];

        System.runAs(UserPF) {
            Test.startTest();
            TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
            TriggerContextUtility.bSendToAMIntegFirstRun = false;
            TriggerContextUtility.bFlagForTestDataBLEInsertion=False;
            Id icpRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);
            Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);


            list<Account> lstAccountICP =  new List<Account>();
            list<Account> lstAccountICPUpdate = new list<Account>();
            list<Id> AccountId = new List<Id>();

            list<Account> lstAccountId  =[Select id from aCCOUNT Where RecordTypeid=:icpRecordTypeId limit 10];
            System.debug('######lstAccountId'+lstAccountId);

            list<Lead> lstLead =[Select id from Lead limit 10];
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household__c> lstHouseholdNew = TestDataUtility.HouseholdTestData();
            lstHouseholdNew[0].Name = 'HouseholdNew';
            insert lstHouseholdNew;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            list<Household_Member__c> lstHouseholdMemberNew = TestDataUtility.HouseholdMemberTestData(lstHouseholdNew);
            lstHouseholdMemberNew[0].Role__c = 'father';
            insert lstHouseholdMemberNew;

            List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccountId , lstHousehold, lstHouseholdMember) ;
            lstCDSPAccounts[0].Cognitive_Age_Group__c = '3-8' ; 
            lstCDSPAccounts[0].ICP__c = lstAccountId[0].ID ;  
            lstCDSPAccounts[1].ICP__c = lstAccountId[0].ID ; 

            // lstCDSPAccounts[0].Formal_Education_Status__c='Primary';
            //lstCDSPAccounts[1].Formal_Education_Status__c='Primary';
            //lstCDSPAccounts[0].Type_Of_Vocational_Education__c='Agriculture';
            //lstCDSPAccounts[1].Type_Of_Vocational_Education__c='Agriculture';
            lstCDSPAccounts[0].Beneficiary_Status__c='Active';
            lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2' ; 
            lstCDSPAccounts[1].Local_Grade_Level__c='PreSchool';
            lstCDSPAccounts[0].Local_Grade_Level__c='PreSchool';
            insert lstCDSPAccounts;
            try{
            lstCDSPAccounts[0].Household__c =lstHouseholdNew[0].id;

            update lstCDSPAccounts;
            }catch(Exception e){
            }
            lstAccountId[0].ICP_Status__c = Constants.ICP_STATUS_TRANSITIONED;
            update lstAccountId;
            system.assertequals(Constants.ICP_STATUS_TRANSITIONED,lstAccountId[0].ICP_Status__c);


            Test.stopTest();
        }
    }
}