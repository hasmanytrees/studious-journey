/******************************************************************************************************
Class Name         : CommunicationKitSearchPageController_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CommunicationKitSearchPageController
Created By         : Akashdeep 
Created On         : 8-Oct-2015 
*******************************************************************************************************/
@IsTest(SeeAllData=false) 
public class CommunicationSearchPageController_Test 
{
       
    static testMethod void verifyCommunicationKitSearchPageController() 
    {
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;

        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        List<sObject> lstTempSeqData = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
         
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
            insert lstRegionTestData ;  
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
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
        insert lstClusterTestData ;
        List<Account> lstAccount=new List<Account>();
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        lstAccount.add(oICPAccount);
          
        lstAccount[0].Cluster__c = lstClusterTestData[0].ID ;    
        
        list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
       
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccount , lstHousehold, lstHouseholdMember) ;
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '3=8' ; 
        lstCDSPAccounts[0].ICP__c = oICPAccount.ID ;  
        lstCDSPAccounts[1].Beneficiary_Status__c='Active';
        lstCDSPAccounts[0].Formal_Education_Status__c='Primary';
        lstCDSPAccounts[1].Formal_Education_Status__c='Primary';
        lstCDSPAccounts[0].Type_Of_Vocational_Education__c='Agriculture';
        lstCDSPAccounts[1].Type_Of_Vocational_Education__c='Agriculture';
        lstCDSPAccounts[0].Beneficiary_Status__c='Active';
        lstCDSPAccounts[1].Local_Grade_Level__c='PreSchool';
        lstCDSPAccounts[0].Local_Grade_Level__c='PreSchool';
        insert lstCDSPAccounts;
        
        
        
        
        update lstCDSPAccounts;
        
        Contact contactGP = new Contact(FirstName = 'Bob', LastName = 'Phillip', AccountId =lstAccount[0].Id);
        insert contactGP;
         System.assertNotEquals(null,contactGP.id);
        Pagereference pg = new PageReference( '/apex/CommunicationKitSearchPage'); 
        Test.setCurrentPage(pg) ;
        
        Test.StartTest() ; 
            CommunicationKitSearchPageController Ck = new CommunicationKitSearchPageController();
            Ck.search();
            
            Ck.getID();
            Ck.reRenderDependentPanel();
            Ck.sRecordType = Ck.lstCommKitRecordTypeNames[1].getValue();
            Ck.reRenderDependentPanel();
            Ck.sRecordType = Ck.lstCommKitRecordTypeNames[2].getValue();
            Ck.reRenderDependentPanel();
            Ck.sPrintOutput = Constants.VAR_Select;
            Ck.sRecordType = Ck.lstCommKitRecordTypeNames[1].getValue();
            Ck.getID();
            Ck.sPrintOutput = Constants.Print_Option_Header;
            Ck.sRecordType = Ck.lstCommKitRecordTypeNames[1].getValue();
            Ck.getID();
            For(SelectOption oSO : Ck.lstAgeGroupValues)
            {
                Ck.lstAgeGroup.add(oSO.getValue());
            }
                 
            Ck.sPrintOutput = Constants.Print_Option_Header;
            Ck.sRecordType = Ck.lstCommKitRecordTypeNames[1].getValue();
            Ck.search();
            
        Test.StopTest() ;       
    }  
    static testMethod void verifyCommunicationKitSearchPageController1() 
    {
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        List<sObject> lstTempSeqData = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
         
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
       
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccount , lstHousehold, lstHouseholdMember) ;
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '3-8' ;
        lstCDSPAccounts[0].PersonBirthdate = Date.newinstance(System.Today().year()-3,System.Today().month(),System.Today().day());
        lstCDSPAccounts[0].ICP__c = lstAccount[0].ID ;  
        lstCDSPAccounts[1].ICP__c = lstAccount[0].ID ; 
        lstCDSPAccounts[1].Beneficiary_Status__c='Active';
        lstCDSPAccounts[0].Formal_Education_Status__c='Primary';
        lstCDSPAccounts[1].Formal_Education_Status__c='Primary';
        lstCDSPAccounts[0].Type_Of_Vocational_Education__c='Agriculture';
        lstCDSPAccounts[1].Type_Of_Vocational_Education__c='Agriculture';
        lstCDSPAccounts[0].Beneficiary_Status__c='Active';
        lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2' ;
        lstCDSPAccounts[1].PersonBirthdate = Date.newinstance(System.Today().year()-1,System.Today().month(),System.Today().day()); 
        lstCDSPAccounts[1].Local_Grade_Level__c='PreSchool';
        lstCDSPAccounts[0].Local_Grade_Level__c='PreSchool';
        insert lstCDSPAccounts;
        
         Account oGlobalpartner= TestDataUtility.globalPartnerTestData( Label.Compasssion_USA_Global_Partner_Name);
         insert oGlobalpartner;
         Account oSupporterAccount= TestDataUtility.supporterTestData(oGlobalpartner);
         insert oSupporterAccount;
         Test.StartTest() ; 
         Commitment__c oCommitment =TestDataUtility.commitmentTestData(lstCDSPAccounts[0],oSupporterAccount);
         oCommitment.Status__c='Active';
         insert oCommitment;
         Commitment__c oCommitmentnew =TestDataUtility.commitmentTestData(lstCDSPAccounts[1],oSupporterAccount);
         oCommitmentnew.Status__c='Active';
         insert oCommitmentnew;
         Communication_Kit__c oCommKitData= TestDataUtility.commKitTestData(lstCDSPAccounts[0],oSupporterAccount,oICPAccount);
         insert oCommKitData;
         CommunicationKitSearchPageController Ck = new CommunicationKitSearchPageController();
         CommunicationKitSearchPageController Cknew = new CommunicationKitSearchPageController();
         Ck.lstCommKitRecordTypeNames.add(new SelectOption(Constants.Both_CONSTANT, Constants.Both_CONSTANT));
         Map<String, Schema.RecordTypeInfo> mapOfRecordTypeNames = 
         Schema.SObjectType.Communication_Kit__c.getRecordTypeInfosByName();
         for (String picklistEntry: mapOfRecordTypeNames.keyset()) 
         {
            if (picklistEntry != Constants.MASTER) {
                Ck.lstCommKitRecordTypeNames.add(new SelectOption(picklistEntry,
                    picklistEntry));
            }
         }
           
        Communication_Kit__c oCommKitDatanew= TestDataUtility.commKitTestData(lstCDSPAccounts[1],oSupporterAccount,oICPAccount);
        oCommKitDatanew.Communication_Types__c='New Sponsor Letter';
        oCommKitDatanew.RecordTypeid = Utility.getRecordTypeIdByDeveloperName(
        Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_B2S_RT);
        insert oCommKitDatanew;
        System.assertNotEquals(null,oCommKitDatanew.id);
           
           
        
        Contact contactGP = new Contact(FirstName = 'Bob', LastName = 'Phillip', AccountId =lstAccount[0].Id);
        insert contactGP;
        System.assertNotEquals(null,contactGP.id);
        Pagereference pg = new PageReference( '/apex/CommunicationKitSearchPage'); 
        Test.setCurrentPage(pg) ;
        
        
        
        Global_Data__c globalDataMalnutrition = new Global_Data__c(Age_In_Months__c = 60, Length__c = 100,
                    SD1__c = 16.799000, SD2__c = 18.589000, SD3neg__c = 12.155000, SD2neg__c = 11.257000, Gender__c = 'Male',
                    Malnutrition_Data_Type__c = 'BMI');
            insert globalDataMalnutrition;
            System.assertNotEquals(null,globalDataMalnutrition.id);
            
            Global_Data__c globalDataEducation = new Global_Data__c(US_Equivalent_Grade_Level__c = '5',
                        Local_Grade_Level__c = 'Primary 5B', Country__c = 'Ecuador');
            insert globalDataEducation;
            System.assertNotEquals(null,globalDataEducation.id);
           
             
             
             Ck.bShowResTbl=true;
        
            CommunicationKitSearchPageController.WrapperObj commWr1 = new CommunicationKitSearchPageController.WrapperObj(false,oCommKitData);
             CommunicationKitSearchPageController.WrapperObj commWr2 = new CommunicationKitSearchPageController.WrapperObj(false,oCommKitDatanew);
            list<CommunicationKitSearchPageController.WrapperObj> lstcommrapper = new list<CommunicationKitSearchPageController.WrapperObj>();
          commWr1.bIsSelected=true;
          commWr1.oCKRec =oCommKitData;
          Ck.oUtilityObj =oCommKitData;
          commWr2.oCKRec =oCommKitDatanew;
          Ck.oUtilityObj =oCommKitDatanew;
          Set<String> setString= new set<String>{'New Sponsor Letter','Large Gift Thank You Letter'};
          
          lstcommrapper.add(commWr1);
          lstcommrapper.add(commWr2);
          lstcommrapper[0].bIsSelected=true;
          lstcommrapper[1].bIsSelected=true;
          
          Ck.sCorrType='New Sponsor Letter;Large Gift Thank You Letter';
          Ck.reRenderDependentPanel();
           
            Ck.sPrintOutput  = Ck.lstPrintOptions[2].getValue();
            Cknew.sPrintOutput  = Cknew.lstPrintOptions[1].getValue();
            Ck.sRecordType = 'Select';
            
            For(SelectOption oSO : Ck.lstAgeGroupValues)
            {
                Ck.lstAgeGroup.add(oSO.getValue());
            }
            Ck.search();
            //Ck.lstResultList.addall(lstcommrapper);
            Ck.refreshList();
            Ck.checkSelectAll();
            Ck.next(); Ck.last(); Ck.first(); Ck.previous(); Ck.refresh();
            Ck.addSetUpdateCommKit();Ck.checkSelectAll();
            Ck.setOfChosenIds.add(oCommKitDatanew.id);Ck.getID();
            Ck.inClausify(setString);
                   
            
        Test.StopTest() ;       
    }   
}