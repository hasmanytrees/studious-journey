/******************************************************************************************************
Class Name         : LeadHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: LeadHandler
                     and LeadTrigger
Created By         : Jeevan D
Created On         : 16-Feb-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
private class LeadHandler_Test 
{
    static testMethod void verifyLeadHandler() 
    {
    
        User oUser1 = TestDataUtility.UserTestData('Partnership Facilitator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser1;    
        system.RunAs(oUser1) {
            list<PM_Hierarchy__c> lstRegions = TestDataUtility.RegionTestData();
                insert lstRegions;
            list<Account> lstFieldOffice = TestDataUtility.FOTestData(lstRegions ,  oUser1) ;
                insert lstFieldOffice;
            list<PM_Hierarchy__c> lstTerritory = TestDataUtility.TerritoryTestData(lstFieldOffice );
                insert lstTerritory;
            list<PM_Hierarchy__c> lstCluster = TestDataUtility.ClusterTestData(lstTerritory , oUser1);
                insert lstCluster;
            Global_Data__c oGlobalTestData = TestDataUtility.globalDataRanking (  'Ranking Data for Child Enrollment Capacity N' , 'Child Enrollment Capacity' , 'Y' , 1 ) ; 
                insert oGlobalTestData ;    
            list<Ranking_Administration__c> lstRankAdmin = TestDataUtility.RankingAdministrationTestData ( lstFieldOffice ) ; 
                insert lstRankAdmin ;
                System.assertNotEquals(null,lstRankAdmin[0].id);
                
            Test.StartTest() ; 
                list<Lead> lstLead = TestDataUtility.LeadTestData(lstCluster , oUser1, oUser1);
                    insert lstLead;
                list<Lead> lstLead1 = TestDataUtility.LeadTestData(lstCluster , oUser1 , oUser1);
                lstLead1[0].ICP_ID__c  = 'ET092';
                lstLead1[1].ICP_ID__c  = 'ET093';
                    insert lstLead1 ;
                    System.assertEquals('ET092',lstLead1[0].ICP_ID__c);    
                lstLead1[1].status = 'Working' ; 
                map<id , Lead> mapLead = new map<id , Lead> () ; 
                For(Lead ld : lstLead1 ){
                    mapLead.put( ld.ID , new LEAD ( Status = 'Working' ) ) ; 
                }
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(lstLead[0].id);
                lc.setDoNotCreateOpportunity(false);
                lc.setConvertedStatus('Converted');
                Database.LeadConvertResult lcr = Database.convertLead(lc , false );
                LeadHandler leadhandlerobj = new leadhandler() ; 
                leadhandlerobj.OnAfterUpdate ( mapLead , lstLead1 ) ; // to check if this method is used 
                try{
                    delete lstLead;
                }
                catch(DMLException oDMLExp){
                    System.assert(oDMLExp.getMessage().contains('Insufficient Privileges. You do not have the level of access necessary to perform the operation you requested.'), 'message=' + oDMLExp.getMessage());
                }
            Test.StopTest() ; 
        }       
    }
    static testMethod void verifyLeadHandlerQualified() 
    {
    
        User oUser1 = TestDataUtility.UserTestData('Partnership Facilitator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser1;    
        system.RunAs(oUser1) {
            list<PM_Hierarchy__c> lstRegions = TestDataUtility.RegionTestData();
                insert lstRegions;
            list<Account> lstFieldOffice = TestDataUtility.FOTestData(lstRegions ,  oUser1) ;
                insert lstFieldOffice;
            list<PM_Hierarchy__c> lstTerritory = TestDataUtility.TerritoryTestData(lstFieldOffice );
                insert lstTerritory;
            list<PM_Hierarchy__c> lstCluster = TestDataUtility.ClusterTestData(lstTerritory , oUser1);
                insert lstCluster;
            Global_Data__c oGlobalTestData = TestDataUtility.globalDataRanking (  'Ranking Data for Child Enrollment Capacity N' , 'Child Enrollment Capacity' , 'Y' , 1 ) ; 
                insert oGlobalTestData ;    
            list<Ranking_Administration__c> lstRankAdmin = TestDataUtility.RankingAdministrationTestData ( lstFieldOffice ) ; 
                insert lstRankAdmin ;
               System.assertNotEquals(null,lstRankAdmin[0].id); 
            Test.StartTest() ; 
                list<Lead> lstLead = TestDataUtility.LeadTestData(lstCluster , oUser1, oUser1);
                    insert lstLead;
                list<Lead> lstLead1 = TestDataUtility.LeadTestData(lstCluster , oUser1 , oUser1);
                lstLead1[0].ICP_ID__c  = 'ET092';
                lstLead1[1].ICP_ID__c  = 'ET093';
                    insert lstLead1 ;    
                System.assertEquals('ET092',lstLead1[0].ICP_ID__c); 
                try{
                delete lstLead1;
                } 
                catch(Exception e){
                }
                
            Test.StopTest() ; 
        }       
    }
    static testMethod void verifyLeadHandlerDuplication() 
    {
    
        User oUser1 = TestDataUtility.UserTestData('Partnership Facilitator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser1;    
        system.RunAs(oUser1) {
            List<sObject> orgLevelSettings = Test.loadData(Org_Level_Settings__c.sObjectType, 'OrgLevelSettings');
                List<sObject> customSettingTransitionValidation = Test.loadData(Account_Prevent_Validation_on_Transition__c.sObjectType, 'Prevent_Validation_Rule_For_Transition');
                List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
                List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
                 
                List<string> lstRegionNames = new List<String> (  ) ; 
                lstRegionNames.add( 'testRegion' ) ; 
                TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
                TriggerContextUtility.bSendToAMIntegFirstRun = false;
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
                Test.StartTest();
                List<Account> lstAccount=new List<Account>();
                Account oICPAccount = TestDataUtility.ICPTestData() ;
               
                oICPAccount.Cluster__c = lstClusterTestData[0].ID ;
                oICPAccount.ICP_ID__c  = 'ET093'; 
                lstAccount.add(oICPAccount) ;
                insert lstAccount;
               System.assertNotEquals(null,lstAccount);
                list<Lead> lstLead2 = TestDataUtility.LeadTestData(lstClusterTestData , oUser1 , oUser1);
               
                lstLead2[1].ICP_ID__c  = 'ET093';   
                
                try{
                    insert lstLead2;
                } 
                    catch(Exception e){
                }
            
            Test.StopTest() ; 
        }       
    }
    static testMethod void leadICPTest() {
        list<Id> AccountId = new List<Id>();
        list<Id> AccountIdNew = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPNew =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
       User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser1;
        System.runAs(oUser1) {
        test.starttest();
            List<sObject> MilestonesSetupTaskData = Test.loadData(Milestones_Setup_Task__c.sObjectType, 'Milestones_Setup_Task');
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
            insert oFieldGroup;
            List<Field_Group_Element__c> lstFGE = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup.Id);
            insert lstFGE;

            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
            insert lstLead;
            list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Database.LeadConvert lcnew = new Database.LeadConvert();
            lcnew.setLeadId(lstLead[1].id);
            lcnew.setDoNotCreateOpportunity(true);
            lcnew.setConvertedStatus('Converted');
            test.stoptest();
            Database.LeadConvertResult lcrnew = Database.convertLead(lcnew);
            Id LeadId = lcr.getAccountId();
            Id LeadIdNew = lcrnew.getAccountId();
            AccountId.add(LeadId);
            AccountIdNew.add(LeadIdNew);
            Profile oProfile = [select id from profile where name =: Constants.ICP_FULL_ACCESS_PROFILE LIMIT 1]; 
            User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
            oUser2.ContactId = lstContact[0].Id ; 
            oUser2.PortalRole = 'Manager' ;
            insert oUser2;
            System.assertEquals('Manager',oUser2.PortalRole);
            
            
            
        }
    }
    static testMethod void leadDuplicationTest() {
        list<Id> AccountId = new List<Id>();
        list<Id> AccountIdNew = new List<Id>();
       
        list<Account> lstAccountICPNew =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
       User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser1;
        System.runAs(oUser1) {
        test.starttest();
            List<sObject> MilestonesSetupTaskData = Test.loadData(Milestones_Setup_Task__c.sObjectType, 'Milestones_Setup_Task');
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert lstPMHierarchyReg;
            Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
            insert oFieldGroup;
            List<Field_Group_Element__c> lstFGE = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup.Id);
            insert lstFGE;

            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
            insert lstPMHierarchyTer;
            list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
            insert lstPMHierarchyCluster;
            Account oAccountICP = TestDataUtility.ICPTestData();
            insert oAccountICP;
            System.assertNotEquals(null,oAccountICP.id);
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
             lstLead[0].ICP_Id__c = 'TD157';
             try{
             insert lstLead;
             }
             Catch(Exception e){
             }
            /*list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
            list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
            insert lstContact;
            insert lstContent;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Database.LeadConvert lcnew = new Database.LeadConvert();
            lcnew.setLeadId(lstLead[1].id);
            lcnew.setDoNotCreateOpportunity(true);
            lcnew.setConvertedStatus('Converted');*/
            test.stoptest();
           
            
            
            
            
        }
    }
}