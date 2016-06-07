/******************************************************************************************************
Class Name         : LetterDownloadExtension_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CommunicationKitSearchPageController
Created By         : Akashdeep 
Created On         : 18-Nov-2015 
*******************************************************************************************************/
@IsTest(SeeAllData=false) 
public class LetterDownloadExtension_Test 
{
    static testMethod void verifyCLetterDownloadExtension() 
    {
    TriggerContextUtility.bSendToAMIntegFirstRun = false;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
        List<sObject> ESBURLSettings = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLResource');
         
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
        lstCDSPAccounts[0].ICP__c = lstAccount[0].ID ;  
        lstCDSPAccounts[1].ICP__c = lstAccount[0].ID ; 
        lstCDSPAccounts[1].Beneficiary_Status__c='Active';
        lstCDSPAccounts[0].Formal_Education_Status__c='Primary';
        lstCDSPAccounts[1].Formal_Education_Status__c='Primary';
        lstCDSPAccounts[0].Type_Of_Vocational_Education__c='Agriculture';
        lstCDSPAccounts[1].Type_Of_Vocational_Education__c='Agriculture';
        lstCDSPAccounts[0].Beneficiary_Status__c='Active';
        lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2' ; 
        lstCDSPAccounts[1].Local_Grade_Level__c='PreSchool';
        lstCDSPAccounts[0].Local_Grade_Level__c='PreSchool';
        insert lstCDSPAccounts;
        
        Account oGlobalpartner= TestDataUtility.globalPartnerTestData( Label.Compasssion_USA_Global_Partner_Name);
        insert oGlobalpartner;
        System.assertNotEquals(null,oGlobalpartner.id);
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
        oCommKitData.Final_Composed_Letter_Link__c = 'https://api2.compassion.com/test/ci/v2/images/321YZ9X_00RJQ51WV00009J/page/321YZ9X_00RJQ51WV00009N.tiff';
        oCommKitData.Original_Letter_Link__c = 'https://api2.compassion.com/test/ci/v2/images/321YZ9X_00RJQ51WV00009J/page/321YZ9X_00RJQ51WV00009N.tiff';
        insert oCommKitData;
        
        
        
        
        Pagereference pg = new PageReference( '/apex/LetterDownload?id='+oCommKitData.id+'&type=Original') ; 
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('contentId', oCommKitData.id);
        ApexPages.currentPage().getParameters().put('type', 'Original');
        LetterDownloadExtension oCDTC = new LetterDownloadExtension();        
        ApexPages.currentPage().getParameters().put('type', 'Final');
        oCDTC = new LetterDownloadExtension();
        oCommKitData.Final_Composed_Letter_Link__c = null;
        oCommKitData.Original_Letter_Link__c = null;
        UPDATE oCommKitData;
        oCDTC = new LetterDownloadExtension();
        ApexPages.currentPage().getParameters().put('type', 'Original');
        oCDTC = new LetterDownloadExtension();
        ApexPages.currentPage().getParameters().put('type', 'Final');
        oCDTC = new LetterDownloadExtension();
        
        oCommKitData.Final_Composed_Letter_Link__c = 'https://api2.compassion.com/test/ci/v2/images/321YZ9X_00RJQ51WV00009J/document/page/321YZ9X_00RJQ51WV00009N.tiff';
        oCommKitData.Original_Letter_Link__c = 'https://api2.compassion.com/test/ci/v2/images/321YZ9X_00RJQ51WV00009J/document/page/321YZ9X_00RJQ51WV00009N.tiff';
        UPDATE oCommKitData;
        System.assertNotEquals(null,oCommKitData.id);
        oCDTC = new LetterDownloadExtension();
        ApexPages.currentPage().getParameters().put('type', 'Original');
        oCDTC = new LetterDownloadExtension();
        ApexPages.currentPage().getParameters().put('type', 'Final');
        oCDTC = new LetterDownloadExtension();
    }
}