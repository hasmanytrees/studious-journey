/******************************************************************************************************
Class Name         : ContentHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: ContentHandler
                     and ContentTrigger
Created By         : Jeevan D
Created On         : 14-09-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class ContentHandler_Test {
    
    @IsTest static  void ContentTest(){ 
            
        User oUser1 = TestDataUtility.UserTestData('System Administrator','PFTer', 'Ethiopia Partnership Facilitator');
            insert oUser1;  
            
        System.RunAs( oUser1 ) {     
        
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('SendICPILEInfoToAM_JSONProcess', 'ICPProfile', false);
        insert oJsonProcess;
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
        insert oFieldGroup;
        JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('ICPProfile', oFieldGroup.Id, true, oJsonProcess.Id);
        insert oJsonStructure;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup.Id);
        insert lstFGE;
        String jsonICPString = '{"ICPProfile" :[{"Id":"ET090","ICP":"Tewahedo Church","Denomination":"","InternationalDenominationAffiliation":"","NewBeneficiaryRequestPriority":"","ProgramStartDate":"2014-09-14 00:00:00","PartnershipFacilitator":"Vishal Katyare","Phone":"6789088","Fax":"56432178","FieldOffice":"Ecuador","Region":"Latin America & Caribbean","Cluster":"Cluster 1","Country":"Ecuador","Territory":"Territory 2","AirportDistance":"30","ClosestMajorCityEnglish":"Guayaquil","AirportTravelTime":"50","ICPStatus":"Active","CurrentCDSPCapacity":"500","MinimumNBRQuantity":"null","NumberOfCDSPBeneficiaries":"3","RemainingCDSPCapacity":"497","AddressStreet":"1234 Lane","City":"Guayaquil","CountryDivision":"Guayas","PostalCode":"560098"}]}';
        HTTPRequest req = new HTTPRequest();
         req.setBody(jsonICPString);
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', '', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        JSON_Process__c oJsonProcess1 = TestDataUtility.jsonProcessTestData('sendBenefInforToAM_JSONProcess', 'BenefProfile', false);
        insert oJsonProcess1;
        Field_Group__c oFieldGroup1 = TestDataUtility.fieldGroupTestData('sendBenefInforToAM', 'Account');
        insert oFieldGroup1;
        JSON_Structure__c oJsonStructure1 = TestDataUtility.jsonStructureTestData('BenefProfile', oFieldGroup1.Id, true, oJsonProcess1.Id);
        insert oJsonStructure1;
        List<Field_Group_Element__c> lstFGE1 = TestDataUtility.sendBenefInforToAMFGElementsTestData(oFieldGroup1.Id);
        insert lstFGE1;
        String jsonBenefString = '{ "BeneficiaryProfileList": [ { "SFDCBeneficiaryLink": "001q000000NGxzQAAT", "Thumbnail": "", "PlannedCompletionDate": "2034-10-09 00:00:00", "Country": "", "IsTransitioned": "false", "NumberOfSistersUnder18": "1", "OrderNumber": "", "ParentsMaritalStatus": "Were Married, Now Separated By Death", "Gender": "Male", "PhysicalDisability": "", "BeneficiaryLocalId": "ET2023734", "FirstName": "Danish", "RegistrationEffectiveDate": "2015-10-15 00:00:00", "NaturalMotherAlive": "No", "ReinstatementEffectiveDate": "", "TransitionEffectiveDate": "", "LastName": "Ahmed2", "NumberOfBrothersUnder18": "0", "ReligiousAffiliation": "", "ExitEffectiveDate": "", "LetterLastWrittenDate": "", "Cluster": "Ethiopia Cluster 1", "NaturalFatherAlive": "Yes", "Territory": "Ethiopia Territory", "IsOrphan": "false", "BeneficiaryGlobalId": "06449151", "FieldOffice_Name": "Ethiopia", "AvailableForMarketingDate": "", "LastReviewDate": "2015-10-15 00:00:00", "TransferStatus": "", "ICP_Id": "ET202", "BirthDate": "2012-10-09 00:00:00", "ChronicIllness": "", "BLERequestReason": "", "CorrespondenceLanguage": "", "PreferredlName": "daniahmed" } ] } ';
           
        HTTPRequest req1 = new HTTPRequest();
         req1.setBody(jsonBenefString);
        SingleRequestMock fakeResponse1 = new SingleRequestMock(200, 'OK', '', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse1);
                    
        // to create Region test data
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
            insert lstTerritoryTestData ;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
         TriggerContextUtility.bSendToAMIntegFirstRun = false;  
        //// to create Cluster test data
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
            insert lstClusterTestData ;
        // Creating test data For oICPAccount - to move this test data to Utility class $$$$$$JEEVAN 
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ;    
            insert oICPAccount ; 
        // to create test data for FO ADministrator
        list<String> lstFieldOfficeAdminNames = new List<String> () ; 
        lstFieldOfficeAdminNames.add( 'lstFOAdminTestDAta' ) ; 
        List<FO_Administration__c> lstFOAdminTestDAta = TestDataUtility.FOAdministratorBOTestData(lstFieldOfficeAdminNames) ; 
        lstFOAdminTestDAta[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        lstFOAdminTestDAta[0].Age_Group__c = '0-2' ; 
            insert lstFOAdminTestDAta ;
        List<Account> lstICP = new List<Account>() ;
        lstICP.add(oICPAccount) ; 
        // To insert HouseholdTestData
        list<Household__c> lstHouseHoldData =  TestDataUtility.HouseholdTestData() ; 
        insert lstHouseHoldData ;
        // To insert HouseholdMemberTestData
        list<Household_Member__c> lstHouseHoldMemberData = TestDataUtility.HouseholdMemberTestData( lstHouseHoldData ) ;
        insert lstHouseHoldMemberData;
        // to insert CDSPBenficiaryData
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstICP , lstHouseHoldData , lstHouseHoldMemberData ) ;
        lstCDSPAccounts[0].Cognitive_Age_Group__c = '0-2' ;  
        lstCDSPAccounts[0].ICP__c = oICPAccount.ID ; 
            insert lstCDSPAccounts ;
        
        // to move this code to Test data utility    
        Contact oConTest = TestDataUtility.ContactTestData ( 'test contact' ) ;
        oConTest.FirstName = 'test'; 
        oConTest.AccountID = oICPAccount.ID ;  
            Insert oConTest ;
            System.assertNotEquals(null,oConTest.id);
        
         Beneficiary_Assessment__c oBentestData = TestDataUtility.BeneficiaryHealthAssessmentTestData( 'test',lstCDSPAccounts[0].ID , 15 , 45) ; 
             insert oBentestData ; 
             System.assertNotEquals(null,oBentestData.id);   
             
         //list<Beneficiary_Lifecycle_Event__c> lstCDSPBleData = TestDataUtility.CDSPBLETestData( lstCDSPAccounts, lstICP ) ;
           //  insert lstCDSPBleData ;  
               
         Profile oProfile = [select id from profile where name =: Constants.ICP_FULL_ACCESS_PROFILE LIMIT 1]; 
         
         User oUser2 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
         oUser2.ContactId = oConTest.Id ; 
         oUser2.PortalRole = 'Manager' ;
            insert oUser2;
        
        test.starttest();
            
         List<Content__c> lstContentTestData1 = TestDataUtility.ContentTestData ( lstCDSPAccounts ) ; 
         List<Content__c> lstContentTestData2 = TestDataUtility.ContentTestData ( lstCDSPAccounts ) ;
         lstContentTestData2[0].ICP__c = oICPAccount.ID ; 
         
         List<Content__c> lstContentTestData3 = TestDataUtility.ContentTestData ( lstCDSPAccounts ) ;
         lstContentTestData3[0].Beneficiary_Assessment__c= oBentestData.ID ;
         
         
         List<Content__c> lstContentTestData4 = TestDataUtility.ContentTestData ( lstCDSPAccounts ) ;
       //  lstContentTestData4[0].Beneficiary_Lifecycle_Event__c = oICPAccount.ID ;
         
         List<Content__c> lstContentRecords = new  List<Content__c> () ; 
         lstContentRecords.addAll (lstContentTestData1 ) ;
         lstContentRecords.addAll (lstContentTestData2 )  ;
         lstContentRecords.addAll (lstContentTestData3 )  ;
     //    lstContentRecords = lstContentRecords.addAll (lstContentTestData4 )  ;
         
             insert lstContentRecords ;
             
          lstContentTestData2[0].ICP__c = NULL ;
          lstContentTestData1[0].Beneficiary__c = NULL ; 
          lstContentTestData3[0].Beneficiary_Assessment__c= NULL ;
        
        Update lstContentRecords ;
        System.assertNotEquals(null,lstContentRecords);    
        test.stoptest(); 
        }

    }
}