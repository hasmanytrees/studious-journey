/******************************************************************************************************
Class Name         : CDPRAssessmentEditViewExtension_Test
Description        : This class contains unit tests for validating the behavior of Apex class:
                     CDPRAssessmentEditViewExtension
Created By         : Jeevan D
Created On         : 16-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
private class CDPRAssessmentEditViewExtension_Test {
    static testMethod void verifyCDPRAssessmentEditViewExtension() 
    {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF ;
        list<Account> lstAccountICP =  new List<Account>();
         list<Id> AccountId = new List<Id>();
         System.RunAs(UserPF){
        List<sObject> lstMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data'); 
        List<sObject> lstGlobalConstantsData = Test.loadData(Global_Constants__c.sObjectType, 'GlobalConstantsData'); 
        List<sObject> lstPointsStatus = Test.loadData(PointsStatusList__c.sObjectType, 'PointsStatusData');
        List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
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
        

         
                            
        // to create Region test data
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
            insert lstRegionTestData ;  
        // to create test data for Field office 
        
        List<string> lstFieldOfficeNames = new List<String> (  ) ; 
        lstFieldOfficeNames.add( 'Ecuador' ) ; 
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
       
        
        // to create test data for FO ADministrator
        list<String> lstFieldOfficeAdminNames = new List<String> () ; 
        lstFieldOfficeAdminNames.add( 'lstFOAdminTestDAta' ) ; 
        List<FO_Administration__c> lstFOAdminTestDAta = TestDataUtility.FOAdministratorBOTestData(lstFieldOfficeAdminNames) ; 
        lstFOAdminTestDAta[0].Field_Office__c = lstFieldOfficeData[0].ID ; 
        lstFOAdminTestDAta[0].Age_Group__c = '0-2' ; 
            insert lstFOAdminTestDAta ;
             List<Account> lstAccount=new List<Account>();
        Account oICPAccount = TestDataUtility.ICPTestData() ;
       
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ;
        lstAccount.add(oICPAccount) ;
        insert lstAccount;
       
           
        
        list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
            insert lstHousehold;
            list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
            insert lstHouseholdMember;
            
        // to insert CDSPBenficiaryData
        Set<id> setBenefIDToUpdate= new Set<id>();
        List<Account> lstCDSPAccounts = TestDataUtility.CDSPBeneficiaryTestData( lstAccount , lstHousehold , lstHouseholdMember ) ;
         lstCDSPAccounts[0].Cognitive_Age_Group__c = '0-2' ; 
        lstCDSPAccounts[0].ICP__c = lstAccount[0].ID ;  
        lstCDSPAccounts[1].ICP__c = lstAccount[0].ID ; 

        lstCDSPAccounts[0].Beneficiary_Status__c='Draft';
        lstCDSPAccounts[1].Beneficiary_Status__c='Draft';
        lstCDSPAccounts[1].Cognitive_Age_Group__c = '0-2' ; 
        lstCDSPAccounts[1].Local_Grade_Level__c='PreSchool';
        lstCDSPAccounts[0].Local_Grade_Level__c='PreSchool';
        insert lstCDSPAccounts;
       
        if(!lstCDSPAccounts.IsEmpty()){
            for(Account acc: lstCDSPAccounts){
                setBenefIDToUpdate.add(acc.id);
                
            }
        }
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
        System.enqueueJob(new SendBenefInfoToUS(setBenefIDToUpdate));
        // to create Beneficiary assesment data
        Beneficiary_Assessment__c oBenAssmntTestData = TestDataUtility.BenficiaryAssmntTestData() ;
        oBenAssmntTestData.Beneficiary__c = lstCDSPAccounts[0].ID ; 
            insert oBenAssmntTestData ;
        Responses__c oResponseData = TestDataUtility.responsTestData (  'Test comment' , '1' ,'test' ,'test progress' ,'Exceeds Expectations'  ) ; 
        oResponseData.CDPR_ID__c = oBenAssmntTestData.ID ; 
            insert oResponseData ;  
        Org_Level_Settings__c oOrgDefaults = Org_Level_Settings__c.getOrgDefaults();                
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController( oBenAssmntTestData ) ;
        Pagereference pg = new PageReference( '/apex/CDPRAssessmentEditViewPage' ) ; 
        Test.setCurrentPage(pg) ;
        ApexPages.currentPage().getParameters().put(Constants.CF_STRING+oOrgDefaults.Account_BenAssessment_Id__c+ Constants.LOOKUP_ID_STRING , lstCDSPAccounts[0].ID );
        ApexPages.currentPage().getParameters().put(Constants.RECORD_TYPE , lstCDSPAccounts[0].RecordtypeID );
        Test.StartTest();
            CDPRAssessmentEditViewExtension testExtnURLCDPREditViewAssmnt = new CDPRAssessmentEditViewExtension( stdConAcc ) ; 
            ApexPages.currentPage().getParameters().put(Constants.RETURL , Constants.RETURL );
            CDPRAssessmentEditViewExtension testExtnCDPREditViewAssmnt = new CDPRAssessmentEditViewExtension( stdConAcc ) ; 
            testExtnCDPREditViewAssmnt.cancel() ; 
            testExtnCDPREditViewAssmnt.Redirect() ;
            testExtnCDPREditViewAssmnt.cdprRtId = NULL ; 
            testExtnCDPREditViewAssmnt.Redirect() ;
            testExtnCDPREditViewAssmnt.sViewEditButton = NULL ; 
            testExtnCDPREditViewAssmnt.Redirect() ;
            testExtnCDPREditViewAssmnt.oBeneficiaryAssessment.Assessment_Completion_Date__c = system.Today () ; 
            System.debug( '***system mapResponses' + testExtnCDPREditViewAssmnt.mapResponse ) ; 
            For( String key : testExtnCDPREditViewAssmnt.mapResponse.KeySet() ) {
                For( Responses__c oResp : testExtnCDPREditViewAssmnt.mapResponse.get( key )  ) {
                    oResp.Points__c = '2' ; 
                    oResp.Comments__c = 'test comment' ;    
                }
            }
            testExtnCDPREditViewAssmnt.saveForm() ;
            system.Assert ( testExtnCDPREditViewAssmnt.mapResponse != NULL ) ; 
            system.Assert ( testExtnCDPREditViewAssmnt.lstExistingResponse.size() > 0 ) ;  
            system.Assert ( testExtnCDPREditViewAssmnt.oBeneficiaryAssessment.ID == oBenAssmntTestData.ID  ) ; 
        Test.StopTest() ;  
        }
                  
    }
}