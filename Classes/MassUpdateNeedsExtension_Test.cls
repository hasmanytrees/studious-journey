/******************************************************************************************************
Class Name         : MassUpdateNeedsExtension_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     MassUpdateNeedsExtension
Created By         : Jeevan D 
Created On         : 16-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
private class MassUpdateNeedsExtension_Test 
{
    static testMethod void verifyMassUpdateNeedsExtension () 
    {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
         System.runAs(UserPF) {  
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        // to create Region test data
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
            insert lstRegionTestData ;   
        // to create test data for Field office 
        List<string> lstFieldOfficeName = new List<String> (  ) ; 
        lstFieldOfficeName.add( 'testFieldOffice' ) ; 
        list<Account> lstFieldOfficeData = TestDataUtility.fieldofficeTestData( lstFieldOfficeName ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;   
            insert lstFieldOfficeData ;   
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
         TriggerContextUtility.bSendToAMIntegFirstRun = false;      
        // To Create Territory test data 
        List<string> lstTerritoryName = new List<String> (  ) ; 
        lstTerritoryName.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.territoryTestData( lstTerritoryName ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
            insert lstTerritoryTestData ; 
        //// to create Cluster test data
        List<string> Clusternames = new List<String> (  ) ; 
        Clusternames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( Clusternames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;    
        // Creating test data For oICPAccnt - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccnt = TestDataUtility.ICPTestData() ;
        oICPAccnt.Cluster__c = lstClusterTestData[0].ID ;    
            insert oICPAccnt ;  
        // to create test data for FO ADministrator
        list<String> lstFieldOfficeAdminNames = new List<String> () ; 
        lstFieldOfficeAdminNames.add( 'lstFOAdminTestData' ) ; 
        List<FO_Administration__c> lstFOAdminTestData = TestDataUtility.FOAdministratorBOTestData(lstFieldOfficeAdminNames) ; 
        lstFOAdminTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        lstFOAdminTestData[0].Age_Group__c = '0-2' ; 
            insert lstFOAdminTestData ;
        List<Account> lstICP = new List<Account>() ;
        lstICP.add(oICPAccnt) ; 
        // To insert HouseholdTestData
        list<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
        insert lstHouseHoldData ;
        // To insert HouseholdMemberTestData
        list<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
        insert lstHouseHoldMemberData;
        // to insert CDSPBenficiaryData
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstICP , lstHouseHoldData , lstHouseHoldMemberData ) ;
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '0-2' ; 
        lstCDSPAccounts[0].ICP__c = oICPAccnt.ID ;  
        TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstCDSPAccounts ; 
        Global_Data__c oGlobalTestData =   TestDataUtility.globalDataNeeds ( 'Access to Potable Water' ,  Constants.BOTH , 'safety') ;   
            insert  oGlobalTestData ; 
        Global_Data__c oGlobalTestData1 =   TestDataUtility.globalDataNeeds ( 'Home-Based Caregiver Literacy' ,  Constants.BOTH , 'safety') ;   
            insert  oGlobalTestData1 ; 
        Global_Data__c oGlobalTestData2 =   TestDataUtility.globalDataNeeds ( 'Dental' ,  Constants.BOTH , 'safety') ;   
            insert  oGlobalTestData2 ; 
        Global_Data__c oGlobalTestData3 =   TestDataUtility.globalDataNeeds ( 'Home-Based Caregiver Literacy' ,  Constants.BOTH , 'safety') ;   
            insert  oGlobalTestData3 ;          
        Needs_Association__c oNeedsAssociationTestData =  TestDataUtility.NeedsAssociationTestData (lstCDSPAccounts[0].ID , 'Beneficiary Association' , false  , 'Other' , Date.Today() , 'Medium' )  ;
        oNeedsAssociationTestData.ICP__c = oICPAccnt.ID ; 
        oNeedsAssociationTestData.Need__c = oGlobalTestData.ID ;     
            insert oNeedsAssociationTestData  ; 
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( lstCDSPAccounts[0] ) ;
        
        Pagereference pg = new PageReference( '/apex/MassUpdateNeeds' ) ; 
        Test.setCurrentPage(pg) ;
        ApexPages.currentPage().getParameters().put( 'accid' , lstCDSPAccounts[0].ID );
            
        Test.StartTest() ; 
            MassUpdateNeedsExtension MUNCon = new MassUpdateNeedsExtension ( stdConAcc ) ; 
            system.Assert( MUNCon.cancel() != null  ) ; 
            MUNCon.lstCiv[0].bIsSelected = false ; 
            MUNCon.lstCiv[1].bIsSelected = true ; 
            MUNCon.lstCiv[1].oNeedAssociation.Severity__c = 'High' ; 
            MUNCon.updateList() ;
        Test.StopTest() ;    
        }
    } 
    
   static testMethod void verifyMassUpdateNeedsExtension1 () 
    {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
         System.runAs(UserPF) {  
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        // to create Region test data
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
            insert lstRegionTestData ;   
        // to create test data for Field office 
        List<string> lstFieldOfficeName = new List<String> (  ) ; 
        lstFieldOfficeName.add( 'testFieldOffice' ) ; 
        list<Account> lstFieldOfficeData = TestDataUtility.fieldofficeTestData( lstFieldOfficeName ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;   
            insert lstFieldOfficeData ;         
        // To Create Territory test data 
        List<string> lstTerritoryName = new List<String> (  ) ; 
        lstTerritoryName.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.territoryTestData( lstTerritoryName ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
            insert lstTerritoryTestData ; 
        //// to create Cluster test data
        List<string> Clusternames = new List<String> (  ) ; 
        Clusternames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( Clusternames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ; 
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
         TriggerContextUtility.bSendToAMIntegFirstRun = false;   
        // Creating test data For oICPAccnt - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccnt = TestDataUtility.ICPTestData() ;
        oICPAccnt.Cluster__c = lstClusterTestData[0].ID ;    
            insert oICPAccnt ;  
        // to create test data for FO ADministrator
        list<String> lstFieldOfficeAdminNames = new List<String> () ; 
        lstFieldOfficeAdminNames.add( 'lstFOAdminTestData' ) ; 
        List<FO_Administration__c> lstFOAdminTestData = TestDataUtility.FOAdministratorBOTestData(lstFieldOfficeAdminNames) ; 
        lstFOAdminTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        lstFOAdminTestData[0].Age_Group__c = '0-2' ; 
            insert lstFOAdminTestData ;
        List<Account> lstICP = new List<Account>() ;
        lstICP.add(oICPAccnt) ; 
        // To insert HouseholdTestData
        list<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
        insert lstHouseHoldData ;
        // To insert HouseholdMemberTestData
        list<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
        insert lstHouseHoldMemberData;
        // to insert CDSPBenficiaryData
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstICP , lstHouseHoldData , lstHouseHoldMemberData ) ;
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '0-2' ; 
        lstCDSPAccounts[0].ICP__c = oICPAccnt.ID ;  
        TriggerContextUtility.bPrimaryCaregiverFirstRun= true;
            insert lstCDSPAccounts ; 
        Global_Data__c oGlobalTestData =   TestDataUtility.globalDataNeeds ( 'Access to Potable Water' ,  Constants.BOTH , 'safety') ;   
            insert  oGlobalTestData ; 
        Global_Data__c oGlobalTestData1 =   TestDataUtility.globalDataNeeds ( 'Home-Based Caregiver Literacy' ,  Constants.BOTH , 'safety') ;   
            insert  oGlobalTestData1 ; 
        Global_Data__c oGlobalTestData2 =   TestDataUtility.globalDataNeeds ( 'Dental' ,  Constants.BOTH , 'safety') ;   
            insert  oGlobalTestData2 ; 
        Global_Data__c oGlobalTestData3 =   TestDataUtility.globalDataNeeds ( 'Home-Based Caregiver Literacy' ,  Constants.BOTH , 'safety') ;   
            insert  oGlobalTestData3 ;          
        Needs_Association__c oNeedsAssociationTestData =  TestDataUtility.NeedsAssociationTestData (lstCDSPAccounts[0].ID , 'Beneficiary Association' , false  , 'Other' , Date.Today() , 'Medium' )  ;
        oNeedsAssociationTestData.ICP__c = oICPAccnt.ID ; 
        oNeedsAssociationTestData.Need__c = oGlobalTestData.ID ;     
            insert oNeedsAssociationTestData  ; 
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( lstCDSPAccounts[0] ) ;
        
        Pagereference pg = new PageReference( '/apex/MassUpdateNeeds' ) ; 
        Test.setCurrentPage(pg) ;
        ApexPages.currentPage().getParameters().put( 'accid' , lstCDSPAccounts[0].ID );
            
        Test.StartTest() ; 
            MassUpdateNeedsExtension MUNCon = new MassUpdateNeedsExtension ( stdConAcc ) ; 
            system.Assert( MUNCon.cancel() != null  ) ; 
            MUNCon.lstCiv[0].bIsSelected = true ; 
            MUNCon.lstCiv[0].oNeedAssociation.Severity__c = 'High' ; 
            MUNCon.lstCiv[0].oNeedAssociation.comments__c = 'High' ; 
            MUNCon.lstCiv[1].bIsSelected = true ; 
            MUNCon.lstCiv[1].oNeedAssociation.Severity__c = 'High' ;
            MUNCon.lstCiv[1].oNeedAssociation.comments__c = 'High' ; 
            MUNCon.updateList() ;
        Test.StopTest() ;    
        }
    }  
}