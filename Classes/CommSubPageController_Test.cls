/******************************************************************************************************
Class Name         : CommSubPageController_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CommSubPageController
Created By         : Akashdeep 
Created On         : 16-Nov-2015 
*******************************************************************************************************/
@IsTest(SeeAllData=false) 
public class CommSubPageController_Test 
{
       
    static testMethod void verifyCommSubPageController() 
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
         
        List<string> lstFieldOfficeNames = new List<String> (  ) ; 
        lstFieldOfficeNames.add( 'Ecuador' ) ; 
        list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;  
        lstFieldOfficeData[0].FO_Next_Schedule_Print_Date__c =System.Today()+4;
        lstFieldOfficeData[0].Field_Office_Id__c='EC';
        insert lstFieldOfficeData ;      
        
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
        Account oCurrAcc = [Select Local_Beneficiary_ID__c, Compass_Id__c from Account where id =: lstCDSPAccounts[0].id];    
            
            Account oGlobalpartner= TestDataUtility.globalPartnerTestData( Label.Compasssion_USA_Global_Partner_Name);
            insert oGlobalpartner;
            Account oSupporterAccount= TestDataUtility.supporterTestData(oGlobalpartner);
            oSupporterAccount.GP_Supporter_ID__c = '7-1360689';
            insert oSupporterAccount;
            Account oSupporterAccountCorres= TestDataUtility.supporterTestData(oGlobalpartner);
            oSupporterAccountCorres.GP_Supporter_ID__c = '7-1360688';
            insert oSupporterAccountCorres;
             System.assertNotEquals(null,oSupporterAccountCorres.id);
            Pagereference pg = new PageReference( '/apex/CommSubPage'); 
            Test.setCurrentPage(pg) ;
            Test.StartTest() ; 
            Commitment__c oCommitment =TestDataUtility.commitmentTestData(lstCDSPAccounts[0],oSupporterAccount);
            oCommitment.Status__c='Active';
            oCommitment.Relationship_Type__c = 'Sponsor';
            insert oCommitment;
            System.assertNotEquals(null,oCommitment.id);
            System.debug('oCommitment.Relationship_Type__c: ' + oCommitment.Relationship_Type__c);
            
            Commitment__c oCommitmentnew =TestDataUtility.commitmentTestData(lstCDSPAccounts[1],oSupporterAccount);
            oCommitmentnew.Status__c='Active';
            insert oCommitmentnew;
            System.assertNotEquals(null,oCommitmentnew.id);
            
            CommSubPageController oCommSubPage = new CommSubPageController();
            oCommSubPage.sBenLocalID = '';
            oCommSubPage.sBenLegacyID = '';
            oCommSubPage.sBenGlobalID = '';
            oCommSubPage.clickSave();
            
            oCommSubPage.sBenLocalID = oCurrAcc.Local_Beneficiary_ID__c;
            oCommSubPage.sBenLegacyID = oCurrAcc.Compass_Id__c;
            oCommSubPage.sSupGlobalID = '';
            oCommSubPage.sSupCompassID = '';
            oCommSubPage.clickSave();
            oCommSubPage.sSupCompassID = oSupporterAccount.GP_Supporter_ID__c;
            oCommSubPage.sChosenTemplate = oCommSubPage.lstTemplatePicklist[0].getValue();
            oCommSubPage.clickSave();
            oCommSubPage.sChosenTemplate = oCommSubPage.lstTemplatePicklist[2].getValue();
            oCommSubPage.clickSave();
            oCommSubPage.sBenLegacyID = '';
            oCommSubPage.clickSave();
            
            oCommSubPage.clickUpload();
            oCommSubPage.oAttach = Blob.valueOf('Unit Test Attachment Body');
            oCommSubPage.clickUpload();
            
            oCommSubPage.sBenLocalID = 'XYZ123';
            oCommSubPage.sBenLegacyID = 'ABC987';
            oCommSubPage.clickSave();
            
            
            
            oCommSubPage.sBenLocalID = oCurrAcc.Local_Beneficiary_ID__c;
            oCommSubPage.sBenLegacyID = oCurrAcc.Compass_Id__c;
            oCommSubPage.clickSave();
            
            
            
            
        Test.StopTest() ;  
    }

}