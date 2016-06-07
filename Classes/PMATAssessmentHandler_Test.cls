/******************************************************************************************************
Class Name         : PMATAssessmentHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: PMATAssessmentHandler
                     and PMATAssessmentTrigger
Created By         : Sfurti Pandey
Created On         : 20-Oct-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
public class PMATAssessmentHandler_Test {    
     static testMethod void verifyPMATAssessment()
     {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        System.RunAs(UserPF){
            List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
            List<sObject> lstTemplateSequencing = Test.loadData(Template_Sequencing_Data__c.sObjectType, 'Template_Sequencing');
             
            List<string> lstRegionNames = new List<String> (  ) ; 
            lstRegionNames.add( 'testRegion' ) ; 
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
            Contact contactGP = new Contact(FirstName = 'Bob', LastName = 'Phillip', AccountId =lstAccount[0].Id);
            insert contactGP;
              
               
            
            list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
                insert lstHousehold;
                list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
                insert lstHouseholdMember;
            Test.Starttest();

            List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccount , lstHousehold, lstHouseholdMember) ;
            lstCDSPAccounts[0].Cognitive_Age_Group__c = '3-8' ; 
            lstCDSPAccounts[0].ICP__c = lstAccount[0].ID ;  
            lstCDSPAccounts[1].ICP__c = lstAccount[0].ID ; 
            lstCDSPAccounts[1].Beneficiary_Status__c='Draft';
            lstCDSPAccounts[0].Formal_Education_Status__c='Primary';
            lstCDSPAccounts[1].Formal_Education_Status__c='Primary';
            lstCDSPAccounts[0].Type_Of_Vocational_Education__c='Agriculture';
            lstCDSPAccounts[1].Type_Of_Vocational_Education__c='Agriculture';
            lstCDSPAccounts[0].Beneficiary_Status__c='Draft';
            lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2' ; 
            lstCDSPAccounts[1].Local_Grade_Level__c='PreSchool';
            lstCDSPAccounts[0].Local_Grade_Level__c='PreSchool';
            insert lstCDSPAccounts;
            PMAT_Assessment__c oPMAT = new PMAT_Assessment__c();
            oPMAT.Account_Name__c=lstAccount[0].id;
            oPMAT.PMAT_Assessment_Start_Date__c= System.Today();
            oPMAT.PMAT_Assessment_End_Date__c= System.Today()+10;
            oPMAT.Email_Recipent__c= 'test@test.com';
            oPMAT.PMAT_ICP_Representative__c=contactGP.id;
            oPMAT.PMAT_Next_Assessment_Date__c=System.Today()+12;
            insert oPMAT;
            oPMAT.PMAT_Next_Assessment_Date__c=System.Today()+15;
            update oPMAT;
            System.Assert (oPMAT.PMAT_Next_Assessment_Date__c== ( System.Today()+15 ));
            Test.Stoptest();

            
            }
      }
}