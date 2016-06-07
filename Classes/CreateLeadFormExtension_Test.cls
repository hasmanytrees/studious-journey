/************************************************************************************************** 
Class Name   : CreateLeadFormExtension_Test
Created By   : Sfurti Pandey
Created Date : 15-Sept-2015
Description  : This class contains unit tests for validating the behavior of Apex class: CreateLeadFormExtension.
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
public class CreateLeadFormExtension_Test {
     static TestMethod void CreateLeadFormExtensionMethod(){
        User oUser = new User(Id = UserInfo.getUserId());
        System.RunAs(oUser){
            // to create Region test data
            List<string> lstRegionNames = new List<String>(); 
            lstRegionNames.add('Ethiopia Reggion');
            list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData(lstRegionNames);
            insert lstRegionTestData;
            
            // to create test data for Field office 
            List<string> lstFieldOfficeNames = new List<String> (  ) ; 
            lstFieldOfficeNames.add('Ethiopia'); 
            list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData(lstFieldOfficeNames);
            lstFieldOfficeData[0].Region__c = lstRegionTestData[0].Id;   
            insert lstFieldOfficeData;
            
            // To Create Territory test data 
            List<string> lstTerritoryNames = new List<String>(); 
            lstTerritoryNames.add('Ethiopia Territory'); 
            list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames );
            lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].Id; 
            insert lstTerritoryTestData;
            
            // to create Cluster test data
            List<string> lstClusterNames = new List<String>(); 
            lstClusterNames.add('No Cluster - Ethiopia'); 
            list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData(lstClusterNames);
            lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].Id;
            insert lstClusterTestData;
            System.assertNotEquals(null,lstClusterTestData[0].id);
            //ApexPages.StandardController stdLeadAcc1 = new ApexPages.StandardController(new Lead()) ;
            
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstClusterTestData, oUser, oUser);
            lstLead[0].Church_Name_Local_Language__c = 'Test Church';
            lstLead[0].Primary_Contact_s_Phone_Number__c = '75765765';
            lstLead[0].LeadSource = 'Other';
            lstLead[0].Other_Lead_Source__c = 'Test';
            lstLead[0].CountryCode = 'ET';
            lstLead[0].Closest_Major_City_Local_Language__c = 'City';
            lstLead[0].Street = 'Street';
            lstLead[0].City = 'City';
            lstLead[0].StateCode = 'AA';
            lstLead[0].PostalCode = '45234234';
            lstLead[0].Ministries__c = 'Child Camp';
            lstLead[0].International_Mission_Affiliation__c = 'Baptist';
            lstLead[0].Number_Of_Active_Church_Members__c = 1;
            lstLead[0].Comments__c = 'Test'; 
            
            PageReference oPageRef = Page.CreateLeadForm;
            System.Test.setCurrentPage(oPageRef);
            ApexPages.currentPage().getParameters().put(Constants.Lang, 'pt');
            system.currentPageReference().getParameters().put(Constants.FO, 'Ethiopia');
            
            ApexPages.StandardController oStandardController = new ApexPages.StandardController(lstLead[0]);
            
            CreateLeadFormExtension oCreateLeadFormExtension = new CreateLeadFormExtension(oStandardController);
            
            
            
            oCreateLeadFormExtension.sLastName = 'Church';
            oCreateLeadFormExtension.sPastorEmail = 'abc@xyz.com';
            oCreateLeadFormExtension.sChurchInterest = 'Test';
            oCreateLeadFormExtension.sChurchMinistry = 'Y';
            oCreateLeadFormExtension.sChurchMinistryDemo = 'Demo';
            oCreateLeadFormExtension.sChurchAgreementToFaith = 'Y';
            oCreateLeadFormExtension.sOtherBeliefs = 'Test';
            
            oCreateLeadFormExtension.sContactSalutation = null;
            oCreateLeadFormExtension.sYourFirstName = 'Test';
            oCreateLeadFormExtension.sYourLastName = 'Test1';
            oCreateLeadFormExtension.sYourEmail = 'email@email.com';
            oCreateLeadFormExtension.sYourPhone = '7657657';
            oCreateLeadFormExtension.sYourRole = null;
            
            Integer iNum1 = oCreateLeadFormExtension.getINum1();
            Integer iNum2 = oCreateLeadFormExtension.getINum2();
            String sOperator = oCreateLeadFormExtension.getSOperator();
            
            if(sOperator == '+'){
                oCreateLeadFormExtension.sInput = String.valueOf(iNum1 + iNum2);
            }
            else if(sOperator == '*'){
                oCreateLeadFormExtension.sInput = String.valueOf(iNum1 * iNum2);
            }
            
            oCreateLeadFormExtension.getSalutations();
            oCreateLeadFormExtension.getYourRoles();
            oCreateLeadFormExtension.getOneGodOptions();
            oCreateLeadFormExtension.validateWebLead();
            oCreateLeadFormExtension.cancel();
            
            lstLead[0].CountryCode = 'Ethiopia';
            ApexPages.StandardController oStandardController2 = new ApexPages.StandardController(lstLead[0]);
            
            CreateLeadFormExtension oCreateLeadFormExtension2 = new CreateLeadFormExtension(oStandardController2);
            oCreateLeadFormExtension2.sContactSalutation = null;
            oCreateLeadFormExtension2.sYourRole = null;
            oCreateLeadFormExtension2.sChurchAgreementToFaith = 'N';
            oCreateLeadFormExtension2.validateWebLead();
            
            lstLead[0].Other_Lead_Source__c = '';
            oCreateLeadFormExtension.sChurchMinistry = '';
            oCreateLeadFormExtension.sYourLastName = '';
            oCreateLeadFormExtension.sPastorEmail = 'abc@xyz@77@.com';
            oCreateLeadFormExtension.sYourEmail = 'abc@xyz@77@.com';
            lstLead[0].CountryCode = 'Ethiopia';
            oCreateLeadFormExtension.sChurchAgreementToFaith = 'N';
            oCreateLeadFormExtension.validateWebLead();
            
            oCreateLeadFormExtension.sInput = String.valueOf(iNum1 - iNum2);
            oCreateLeadFormExtension.validateWebLead();
            
            oCreateLeadFormExtension.sInput = '';
            oCreateLeadFormExtension.validateWebLead();
            
            
            PageReference oPageRef2 = Page.CreateLeadForm;
            System.Test.setCurrentPage(oPageRef2);           
            ApexPages.currentPage().getParameters().put(Constants.Lang, '');
            system.currentPageReference().getParameters().put(Constants.FO, '');
            
            ApexPages.StandardController oStandardController3 = new ApexPages.StandardController(lstLead[0]);
            
            CreateLeadFormExtension oCreateLeadFormExtension3 = new CreateLeadFormExtension(oStandardController3);
            
            
            
        }
     }
     
     static TestMethod void CreateLeadFormExtensionMethod2(){
        User oUser = new User(Id = UserInfo.getUserId());
        System.RunAs(oUser){
            // to create Region test data
            List<string> lstRegionNames = new List<String>(); 
            lstRegionNames.add('Ethiopia Reggion');
            list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData(lstRegionNames);
            insert lstRegionTestData;
            
            // to create test data for Field office 
            List<string> lstFieldOfficeNames = new List<String> (  ) ; 
            lstFieldOfficeNames.add('Ethiopia'); 
            list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData(lstFieldOfficeNames);
            lstFieldOfficeData[0].Region__c = lstRegionTestData[0].Id;   
            insert lstFieldOfficeData;
            
            // To Create Territory test data 
            List<string> lstTerritoryNames = new List<String>(); 
            lstTerritoryNames.add('Ethiopia Territory'); 
            list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames );
            lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].Id; 
            insert lstTerritoryTestData;
            
            // to create Cluster test data
            List<string> lstClusterNames = new List<String>(); 
            lstClusterNames.add('No Cluster - Ethiopia'); 
            list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData(lstClusterNames);
            lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].Id;
            insert lstClusterTestData;
            System.assertNotEquals(null,lstClusterTestData[0].id);
            //ApexPages.StandardController stdLeadAcc1 = new ApexPages.StandardController(new Lead()) ;
            
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstClusterTestData, oUser, oUser);
            lstLead[0].Church_Name_Local_Language__c = 'Test Church';
            lstLead[0].Primary_Contact_s_Phone_Number__c = '75765765';
            lstLead[0].LeadSource = 'Other';
            lstLead[0].Other_Lead_Source__c = 'Test';
            lstLead[0].CountryCode = 'Ethiopia';
            lstLead[0].Closest_Major_City_Local_Language__c = 'City';
            lstLead[0].Street = 'Street';
            lstLead[0].City = 'City';
            lstLead[0].StateCode = 'AA';
            lstLead[0].PostalCode = '45234234';
            lstLead[0].Ministries__c = 'Child Camp';
            lstLead[0].International_Mission_Affiliation__c = 'Baptist';
            lstLead[0].Number_Of_Active_Church_Members__c = 1;
            lstLead[0].Comments__c = 'Test'; 
            
            PageReference oPageRef = Page.CreateLeadForm;
            System.Test.setCurrentPage(oPageRef);
            ApexPages.currentPage().getParameters().put(Constants.Lang, 'pt');
            system.currentPageReference().getParameters().put(Constants.FO, 'Ethiopia');
            
            ApexPages.StandardController oStandardController = new ApexPages.StandardController(lstLead[0]);
            
            CreateLeadFormExtension oCreateLeadFormExtension = new CreateLeadFormExtension(oStandardController);
            
            
            
            oCreateLeadFormExtension.sLastName = 'Church';
            oCreateLeadFormExtension.sPastorEmail = 'abc@xyz.com';
            oCreateLeadFormExtension.sChurchInterest = 'Test';
            oCreateLeadFormExtension.sChurchMinistry = 'Y';
            oCreateLeadFormExtension.sChurchMinistryDemo = 'Demo';
            oCreateLeadFormExtension.sChurchAgreementToFaith = 'Y';
            oCreateLeadFormExtension.sOtherBeliefs = 'Test';
            
            oCreateLeadFormExtension.sContactSalutation = 'Mr';
            oCreateLeadFormExtension.sYourFirstName = 'Test';
            oCreateLeadFormExtension.sYourLastName = 'Test1';
            oCreateLeadFormExtension.sYourEmail = 'email@email.com';
            oCreateLeadFormExtension.sYourPhone = '7657657';
            oCreateLeadFormExtension.sYourRole = 'Elder';
            
            Integer iNum1 = oCreateLeadFormExtension.getINum1();
            Integer iNum2 = oCreateLeadFormExtension.getINum2();
            String sOperator = oCreateLeadFormExtension.getSOperator();
            
            if(sOperator == '+'){
                oCreateLeadFormExtension.sInput = String.valueOf(iNum1 + iNum2);
            }
            else if(sOperator == '*'){
                oCreateLeadFormExtension.sInput = String.valueOf(iNum1 * iNum2);
            }
            
            oCreateLeadFormExtension.getSalutations();
            oCreateLeadFormExtension.getYourRoles();
            oCreateLeadFormExtension.getOneGodOptions();
            oCreateLeadFormExtension.validateWebLead();           
        }
     }
     
     static TestMethod void CreateLeadFormExtensionMethod3(){
        User oUser = new User(Id = UserInfo.getUserId());
        System.RunAs(oUser){
            // to create Region test data
            List<string> lstRegionNames = new List<String>(); 
            lstRegionNames.add('Ethiopia Reggion');
            list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData(lstRegionNames);
            insert lstRegionTestData;
            
            // to create test data for Field office 
            List<string> lstFieldOfficeNames = new List<String> (  ) ; 
            lstFieldOfficeNames.add('Ethiopia'); 
            list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData(lstFieldOfficeNames);
            lstFieldOfficeData[0].Region__c = lstRegionTestData[0].Id;   
            insert lstFieldOfficeData;
            
            // To Create Territory test data 
            List<string> lstTerritoryNames = new List<String>(); 
            lstTerritoryNames.add('Ethiopia Territory'); 
            list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames );
            lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].Id; 
            insert lstTerritoryTestData;
            
            // to create Cluster test data
            List<string> lstClusterNames = new List<String>(); 
            lstClusterNames.add('No Cluster - Ethiopia'); 
            list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData(lstClusterNames);
            lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].Id;
            insert lstClusterTestData;
            System.assertNotEquals(null,lstClusterTestData[0].id);
            //ApexPages.StandardController stdLeadAcc1 = new ApexPages.StandardController(new Lead()) ;
            
            list<Lead> lstLead = TestDataUtility.LeadTestData(lstClusterTestData, oUser, oUser);
            lstLead[0].Church_Name_Local_Language__c = 'Test Church';
            lstLead[0].Primary_Contact_s_Phone_Number__c = '75765765';
            lstLead[0].LeadSource = 'Other';
            lstLead[0].Other_Lead_Source__c = 'Test';
            lstLead[0].CountryCode = 'ET';
            lstLead[0].Closest_Major_City_Local_Language__c = 'City';
            lstLead[0].Street = 'Street';
            lstLead[0].City = 'City';
            lstLead[0].StateCode = '--';
            lstLead[0].PostalCode = '45234234';
            lstLead[0].Ministries__c = 'Child Camp';
            lstLead[0].International_Mission_Affiliation__c = 'Baptist';
            lstLead[0].Number_Of_Active_Church_Members__c = 1;
            lstLead[0].Comments__c = 'Test'; 
            
            PageReference oPageRef = Page.CreateLeadForm;
            System.Test.setCurrentPage(oPageRef);
            ApexPages.currentPage().getParameters().put(Constants.Lang, '');
            system.currentPageReference().getParameters().put(Constants.FO, '');
            
            ApexPages.StandardController oStandardController = new ApexPages.StandardController(lstLead[0]);
            
            CreateLeadFormExtension oCreateLeadFormExtension = new CreateLeadFormExtension(oStandardController);
            
            
            
            oCreateLeadFormExtension.sLastName = 'Church';
            oCreateLeadFormExtension.sPastorEmail = 'abc@xyz.com';
            oCreateLeadFormExtension.sChurchInterest = 'Test';
            oCreateLeadFormExtension.sChurchMinistry = 'Y';
            oCreateLeadFormExtension.sChurchMinistryDemo = 'Demo';
            oCreateLeadFormExtension.sChurchAgreementToFaith = 'No';
            oCreateLeadFormExtension.sOtherBeliefs = 'Test';
            
            oCreateLeadFormExtension.sContactSalutation = 'Mr';
            oCreateLeadFormExtension.sYourFirstName = 'Test';
            oCreateLeadFormExtension.sYourLastName = 'Test1';
            oCreateLeadFormExtension.sYourEmail = 'email@email.com';
            oCreateLeadFormExtension.sYourPhone = '7657657';
            oCreateLeadFormExtension.sYourRole = 'Elder';
            
            Integer iNum1 = oCreateLeadFormExtension.getINum1();
            Integer iNum2 = oCreateLeadFormExtension.getINum2();
            String sOperator = oCreateLeadFormExtension.getSOperator();
            
            if(sOperator == '+'){
                oCreateLeadFormExtension.sInput = String.valueOf(iNum1 + iNum2);
            }
            else if(sOperator == '*'){
                oCreateLeadFormExtension.sInput = String.valueOf(iNum1 * iNum2);
            }
            
            oCreateLeadFormExtension.getSalutations();
            oCreateLeadFormExtension.getYourRoles();
            oCreateLeadFormExtension.getOneGodOptions();
            oCreateLeadFormExtension.validateWebLead();           
            
        }
     }
}