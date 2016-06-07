/******************************************************************************************************
Class Name         : BeneficiaryAndHMInsertion_Test
Description        : This class contains unit tests for validating the behavior of Apex class: BeneficiaryAndHMInsertion
Created By         : Nayana Prabhakar
Created On         : 26-March-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class BeneficiaryAndHMInsertion_Test{
    static testMethod void testOne() {
        
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('CreateBeneficiaryProcess', 'BeneficiaryList', true);
        insert oJsonProcess;
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('CreateBeneficiaryFieldGroup', 'Account');
        insert oFieldGroup;
        
        Field_Group__c oFieldGroup2 = TestDataUtility.fieldGroupTestData('CreateHouseholdMemberFieldGroup', 'Household_Member__c');
        insert oFieldGroup2;
        JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('BeneficiaryList', oFieldGroup.Id, false, oJsonProcess.Id);
        insert oJsonStructure;
        JSON_Structure__c oJsonStructure2 = TestDataUtility.jsonStructureTestData('HouseholdMembersList', oFieldGroup2.Id, true, oJsonProcess.Id);
        insert oJsonStructure2;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.createBeneficiaryFieldGroupElementTestData(oFieldGroup.Id);
        insert lstFGE;
        List<Field_Group_Element__c> lstFGE2 = TestDataUtility.createHMElementsTestData(oFieldGroup2.Id);
        insert lstFGE2;
        Field_Group__c oFieldGroup3 = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
        insert oFieldGroup3;
        List<sObject> lstFieldsMapping = Test.loadData(Fields_for_relationship_mapping__c.sObjectType, 'FieldsForRelationshipMapping');
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        List<Field_Group_Element__c> lstFGE3 = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup3.Id);
        insert lstFGE3;
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
        List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        String sTestJson = '{"BeneficiaryList": [{"AccountName": "Test Integration ","AccountOwner": "rchamaca","CDSPType": "Center Based","AccountRecordType": "CDSP Beneficiary","ActiveProgram": "CDSP","AgreementRenewalDate": "2015-03-04 09:59:50","AgreementSignedDate": null,"ActualRegistrationDate": "2015-03-04 00:00:00Z","AlternateAddressExpiryDate": null,"AvailableforMarketingDate": null,"BeneficiaryLastBibleDistributedDate": null,"BeneficiaryChoreList": "Child Care;Cleaning;Kitchen Help;Making Beds;Running Errands;Washing Clothes;","BeneficiaryConfessionofFaithDate": null,"BeneficiaryHobbyList": "Bicycling;Group Games;Running;Singing;Story Telling;Soccer or Football;","COMPASSId": null,"BeneficiaryStatus": "Active","Birthdate": "2000-05-24 00:00:00Z","BMIforAgeWHO": null,"CaregiverName": "Mummy","CaregiverId": null,"CDSPProgramEndDate": null,"ChristianActivities": "Sunday School and Church;Camp;","ChronicIllness": null,"ClusterName": null,"CognitiveAgeGroup": null,"Disabilities": null,"ExistingBeneficiaryId": null,"ExistingBeneficiaryName": "Test","Country": "Bolivia","FormalEducationStatus": null,"Gender": "Male","LocalGradeLevel": "Middle 2","HeightInCm": null,"HouseholdName": "Integration Household 711","ICPId": "ET090","IncidentDate": null,"IncidentNumber": null,"IsAlternateAddressinUse": null,"IsBeneficiaryAttendingSchool": "true","Language": null,"LastReviewedDate": null,"MentalDevelopmentConditions": null,"Phone": null,"PlannedCompletionDate": "2018-10-01 00:00:00Z","PlannedCompletionDateChangeReason": null,"PreferredName": "toni","ProgramFieldManualExemption": null,"ReligiousAffiliation": null,"TutorImplementerName": "Test","WeightInKg": null,"CompassChild": "ET0901000","BeneficiaryEducationalAssessment": "Average","NaturalFatherLivingWithChild": "True","NaturalMotherLivingWithChild": "True","NaturalFatherIsAlive": "Yes","NaturalMotherIsAlive": "Yes","FemaleOccupation": "Other","MaleOccupation": "Other","FemaleEmploymentStatus": "Sometimes Employed","MaleEmploymentStatus": "Sometimes Employed","MaritalStatus": "Married","CurrentUniversityYearOfStudy": null,"TypeOfVocationalEducation": null,"MajorOrCourseOfStudy": null,"TogetherNow": "Yes","LocalBeneficiaryNumber":"1000","HouseholdMembersList": [{"CompassionBeneficiaryId": null,"Role": "Mother","HouseholdMemberName": "Mummy","IsCaregiver": "true","Household": null},{"CompassionBeneficiaryId": null,"Role": "Father","HouseholdMemberName": "Unknown","IsCaregiver": "true","Household": null}]}]}';
        String sTestJson2 = '{"BeneficiaryList": [{"AccountName": "Test Integration ","AccountOwner": "rchamaca","CDSPType": "Center Based","AccountRecordType": "CDSP Beneficiary","ActiveProgram": "CDSP","AgreementRenewalDate": "2015-03-04 09:59:50","AgreementSignedDate": null,"ActualRegistrationDate": "2015-03-04 00:00:00Z","AlternateAddressExpiryDate": null,"AvailableforMarketingDate": null,"BeneficiaryLastBibleDistributedDate": null,"BeneficiaryChoreList": "Child Care;Cleaning;Kitchen Help;Making Beds;Running Errands;Washing Clothes;","BeneficiaryConfessionofFaithDate": null,"BeneficiaryHobbyList": "Bicycling;Group Games;Running;Singing;Story Telling;Soccer or Football;","COMPASSId": null,"BeneficiaryStatus": "Active","Birthdate": "2000-05-24 00:00:00Z","BMIforAgeWHO": null,"CaregiverName": "Mummy","CaregiverId": null,"CDSPProgramEndDate": null,"ChristianActivities": "Sunday School and Church;Camp;","ChronicIllness": null,"ClusterName": null,"CognitiveAgeGroup": null,"Disabilities": null,"ExistingBeneficiaryId": null,"ExistingBeneficiaryName": "Test","Country": "Bolivia","FormalEducationStatus": null,"Gender": "Male","LocalGradeLevel": "Middle 2","HeightInCm": null,"HouseholdName": "Integration Household 711","ICPId": "ET090","IncidentDate": null,"IncidentNumber": null,"IsAlternateAddressinUse": null,"IsBeneficiaryAttendingSchool": "true","Language": null,"LastReviewedDate": null,"MentalDevelopmentConditions": null,"Phone": null,"PlannedCompletionDate": "2018-10-01 00:00:00Z","PlannedCompletionDateChangeReason": null,"PreferredName": "toni","ProgramFieldManualExemption": null,"ReligiousAffiliation": null,"TutorImplementerName": "Test","WeightInKg": null,"CompassChild": "","BeneficiaryEducationalAssessment": "Average","NaturalFatherLivingWithChild": "True","NaturalMotherLivingWithChild": "True","NaturalFatherIsAlive": "Yes","NaturalMotherIsAlive": "Yes","FemaleOccupation": "Other","MaleOccupation": "Other","FemaleEmploymentStatus": "Sometimes Employed","MaleEmploymentStatus": "Sometimes Employed","MaritalStatus": "Married","CurrentUniversityYearOfStudy": null,"TypeOfVocationalEducation": null,"MajorOrCourseOfStudy": null,"TogetherNow": "Yes","LocalBeneficiaryNumber":"1000","HouseholdMembersList": [{"CompassionBeneficiaryId": null,"Role": "Mother","HouseholdMemberName": "Mummy","IsCaregiver": "true","Household": null},{"CompassionBeneficiaryId": null,"Role": "Father","HouseholdMemberName": "Unknown","IsCaregiver": "true","Household": null}]}]}';
        String sTestJson3 = '';
        String sTestJson4 = '{"BeneficiaryList": [{"AccountName": "M S Dhoni wwwwww","AccountOwner": "rchamaca","CDSPType": "Center Based","AccountRecordType": "CDSP Beneficiary","ActiveProgram": "CDSP","AgreementRenewalDate": "2015-03-04 09:59:50","AgreementSignedDate": null,"ActualRegistrationDate": "2015-03-04 00:00:00Z","AlternateAddressExpiryDate": null,"AvailableforMarketingDate": null,"BeneficiaryLastBibleDistributedDate": null,"BeneficiaryChoreList": "Child Care;Cleaning;Kitchen Help;Making Beds;Running Errands;Washing Clothes;","BeneficiaryConfessionofFaithDate": null,"BeneficiaryHobbyList": "Bicycling;Group Games;Running;Singing;Story Telling;Soccer or Football;","COMPASSId": null,"BeneficiaryStatus": "Active","Birthdate": "2000-05-24 00:00:00Z","BMIforAgeWHO": null,"CaregiverName": null,"CaregiverId": null,"CDSPProgramEndDate": null,"ChristianActivities": "Sunday School and Church;Camp;","ChronicIllness": null,"ClusterName": null,"CognitiveAgeGroup": null,"Disabilities": null,"ExistingBeneficiaryId": null,"ExistingBeneficiaryName": null,"Country": "Bolivia","FormalEducationStatus": null,"Gender": "Male","LocalGradeLevel": "Middle 2","HeightInCm": null,"HouseholdName": "Dhoni household wwwwww, S","ICPId": "BO103","IncidentDate": null,"IncidentNumber": null,"IsAlternateAddressinUse": null,"IsBeneficiaryAttendingSchool": "true","Language": null,"LastReviewedDate": null,"MentalDevelopmentConditions": null,"Phone": null,"PlannedCompletionDate": "2018-10-01 00:00:00Z","PlannedCompletionDateChangeReason": null,"PreferredName": "toni","ProgramFieldManualExemption": null,"ReligiousAffiliation": null,"TutorImplementerName": null,"WeightInKg": null,"CompassChild": "BO1031927","BeneficiaryEducationalAssessment": "Average","NaturalFatherLivingWithChild": "True","NaturalMotherLivingWithChild": "True","NaturalFatherIsAlive": "Yes","NaturalMotherIsAlive": "Yes","FemaleOccupation": "Other","MaleOccupation": "Other","FemaleEmploymentStatus": "Sometimes Employed","MaleEmploymentStatus": "Sometimes Employed","MaritalStatus": "Married","CurrentUniversityYearOfStudy": null,"TypeOfVocationalEducation": null,"MajorOrCourseOfStudy": null,"TogetherNow": "Yes","HouseholdMembersList": [{"CompassionBeneficiaryId": null,"Role": "Mother","HouseholdMemberName": "Unknown","IsCaregiver": "true","Household": null}, {"CompassionBeneficiaryId": null,"Role": "Father","HouseholdMemberName": "Unknown","IsCaregiver": "true","Household": null}]}]}';
        
        
        User UserPF = [select Id, Name from User where Id =: UserInfo.getUserId()];
        //User UserCD = [select Id, Name from User where Id =: UserInfo.getUserId()];
        System.assert(UserPF.Name != null);
        list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
        insert lstPMHierarchyReg;
        list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserPF);
        insert lstAccountFO;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
        insert lstPMHierarchyTer;
        list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
        insert lstPMHierarchyCluster;
        Test.StartTest();
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
        oICPAccount.ICP_Status__c='Active';
        oICPAccount.ICP_Id__c = 'ET090';
        lstAccountICP.add(oICPAccount) ;
        insert lstAccountICP;
        list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
        lstHousehold[0].Name = 'Integration Household 711';
        insert lstHousehold;
        list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
        insert lstHouseholdMember;
        list<Account> lstAccountCDSP = new list<Account>();
        lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
        lstAccountCDSP[0].Local_beneficiary_Number__c = '1000';
        try{
            insert lstAccountCDSP;
            System.assertNotEquals(null,lstAccountCDSP[0].id);
        }catch(Exception e) {
        }
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //req.requestURI = 'https://cs9.salesforce.com/services/apexrest/CreateBeneficiary';
        req.requestURI = System.URL.getSalesforceBaseUrl()+'services/apexrest/CreateBeneficiary';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(sTestJson);
        RestContext.request = req;
        RestContext.response = res;
        try{
            BeneficiaryAndHMInsertion.createBenefAndHM();
        
        req.requestBody = Blob.valueof(sTestJson2);
        RestContext.request = req;
        RestContext.response = res;
        BeneficiaryAndHMInsertion.createBenefAndHM();
        }
        Catch(Exception e){
        }
        Test.stopTest();
    }
    
    static testmethod void testSecond(){
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('CreateBeneficiaryProcess', 'BeneficiaryList', true);
        insert oJsonProcess;
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('CreateBeneficiaryFieldGroup', 'Account');
        insert oFieldGroup;
        Field_Group__c oFieldGroup2 = TestDataUtility.fieldGroupTestData('CreateHouseholdMemberFieldGroup', 'Household_Member__c');
        insert oFieldGroup2;
        JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('BeneficiaryList', oFieldGroup.Id, false, oJsonProcess.Id);
        insert oJsonStructure;
        JSON_Structure__c oJsonStructure2 = TestDataUtility.jsonStructureTestData('HouseholdMembersList', oFieldGroup2.Id, true, oJsonProcess.Id);
        insert oJsonStructure2;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.createBeneficiaryFieldGroupElementTestData(oFieldGroup.Id);
        insert lstFGE;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        List<Field_Group_Element__c> lstFGE2 = TestDataUtility.createHMElementsTestData(oFieldGroup2.Id);
        insert lstFGE2;
        Field_Group__c oFieldGroup3 = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
        insert oFieldGroup3;
        List<Field_Group_Element__c> lstFGE3 = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup3.Id);
        insert lstFGE3;
        List<sObject> lstFieldsMapping = Test.loadData(Fields_for_relationship_mapping__c.sObjectType, 'FieldsForRelationshipMapping');
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
        List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        String sTestJson3 = '';
        String sTestJson4 = '{"BeneficiaryList": [{"AccountName": "M S Dhoni wwwwww","AccountOwner": "rchamaca","CDSPType": "Center Based","AccountRecordType": "CDSP Beneficiary","ActiveProgram": "CDSP","AgreementRenewalDate": "2015-03-04 09:59:50","AgreementSignedDate": null,"ActualRegistrationDate": "2015-03-04 00:00:00Z","AlternateAddressExpiryDate": null,"AvailableforMarketingDate": null,"BeneficiaryLastBibleDistributedDate": null,"BeneficiaryChoreList": "Child Care;Cleaning;Kitchen Help;Making Beds;Running Errands;Washing Clothes;","BeneficiaryConfessionofFaithDate": null,"BeneficiaryHobbyList": "Bicycling;Group Games;Running;Singing;Story Telling;Soccer or Football;","COMPASSId": null,"BeneficiaryStatus": "Active","Birthdate": "2000-05-24 00:00:00Z","BMIforAgeWHO": null,"CaregiverName": null,"CaregiverId": null,"CDSPProgramEndDate": null,"ChristianActivities": "Sunday School and Church;Camp;","ChronicIllness": null,"ClusterName": null,"CognitiveAgeGroup": null,"Disabilities": null,"ExistingBeneficiaryId": null,"ExistingBeneficiaryName": null,"Country": "Bolivia","FormalEducationStatus": null,"Gender": "Male","LocalGradeLevel": "Middle 2","HeightInCm": null,"HouseholdName": "Dhoni household wwwwww, S","ICPId": "BO103","IncidentDate": null,"IncidentNumber": null,"IsAlternateAddressinUse": null,"IsBeneficiaryAttendingSchool": "true","Language": null,"LastReviewedDate": null,"MentalDevelopmentConditions": null,"Phone": null,"PlannedCompletionDate": "2018-10-01 00:00:00Z","PlannedCompletionDateChangeReason": null,"PreferredName": "toni","ProgramFieldManualExemption": null,"ReligiousAffiliation": null,"TutorImplementerName": null,"WeightInKg": null,"CompassChild": "BO1031927","BeneficiaryEducationalAssessment": "Average","NaturalFatherLivingWithChild": "True","NaturalMotherLivingWithChild": "True","NaturalFatherIsAlive": "Yes","NaturalMotherIsAlive": "Yes","FemaleOccupation": "Other","MaleOccupation": "Other","FemaleEmploymentStatus": "Sometimes Employed","MaleEmploymentStatus": "Sometimes Employed","MaritalStatus": "Married","CurrentUniversityYearOfStudy": null,"TypeOfVocationalEducation": null,"MajorOrCourseOfStudy": null,"TogetherNow": "Yes","HouseholdMembersList": [{"CompassionBeneficiaryId": null,"Role": "Mother","HouseholdMemberName": "Unknown","IsCaregiver": "true","Household": null}, {"CompassionBeneficiaryId": null,"Role": "Father","HouseholdMemberName": "Unknown","IsCaregiver": "true","Household": null}]}]}';
        
        User UserPF = [select Id, Name from User where Id =: UserInfo.getUserId()];
        
        list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
        insert lstPMHierarchyReg;
        list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserPF);
        insert lstAccountFO;
        list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
        insert lstPMHierarchyTer;
        list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
        insert lstPMHierarchyCluster;
        list<Lead> lstLead = TestDataUtility.LeadTestData(lstPMHierarchyCluster, UserPF, UserPF);
        lstLead[0].ICP_ID__c = 'ET090';
        insert lstLead;
        list<Contact> lstContact = TestDataUtility.ConTestData(lstLead);
        list<Content__c> lstContent = TestDataUtility.ContentTestData(lstLead);
        insert lstContact;
        insert lstContent;
        
        Test.startTest();
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
        oICPAccount.ICP_Status__c='Active';
        lstAccountICP.add(oICPAccount) ;
        Account oICPAccountNew =TestDataUtility.ICPTestData() ;
        oICPAccountNew.ICP_Id__c = 'TD155';
        lstAccountICP.add(oICPAccountNew) ;
        insert lstAccountICP;
       
        list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
        insert lstHousehold;
        list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
        insert lstHouseholdMember;
        list<Account> lstAccountCDSP = new list<Account>();
        lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
        lstAccountCDSP[0].Local_beneficiary_Number__c = '1829';
         System.assertNotEquals(null,lstAccountCDSP);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl()+'services/apexrest/CreateBeneficiary';
        req.httpMethod = 'POST';
        
        req.requestBody = Blob.valueof(sTestJson3);
        RestContext.request = req;
        RestContext.response = res;
        BeneficiaryAndHMInsertion.createBenefAndHM();
        
        req.requestBody = Blob.valueof(sTestJson4);
        RestContext.request = req;
        RestContext.response = res;
        BeneficiaryAndHMInsertion.createBenefAndHM();
        
        Test.stopTest();
    }
    
    static testMethod void testThird() {
        
        JSON_Process__c oJsonProcess = TestDataUtility.jsonProcessTestData('CreateBeneficiaryProcess', 'BeneficiaryList', true);
        insert oJsonProcess;
        Field_Group__c oFieldGroup = TestDataUtility.fieldGroupTestData('CreateBeneficiaryFieldGroup', 'Account');
        insert oFieldGroup;
        
        Field_Group__c oFieldGroup2 = TestDataUtility.fieldGroupTestData('CreateHouseholdMemberFieldGroup', 'Household_Member__c');
        insert oFieldGroup2;
        JSON_Structure__c oJsonStructure = TestDataUtility.jsonStructureTestData('BeneficiaryList', oFieldGroup.Id, false, oJsonProcess.Id);
        insert oJsonStructure;
        JSON_Structure__c oJsonStructure2 = TestDataUtility.jsonStructureTestData('HouseholdMembersList', oFieldGroup2.Id, true, oJsonProcess.Id);
        insert oJsonStructure2;
        List<Field_Group_Element__c> lstFGE = TestDataUtility.createBeneficiaryFieldGroupElementTestData(oFieldGroup.Id);
        insert lstFGE;
        List<Field_Group_Element__c> lstFGE2 = TestDataUtility.createHMElementsTestData(oFieldGroup2.Id);
        insert lstFGE2;
        Field_Group__c oFieldGroup3 = TestDataUtility.fieldGroupTestData('SendICPILEInfoToAM', 'Account');
        insert oFieldGroup3;
        List<sObject> lstFieldsMapping = Test.loadData(Fields_for_relationship_mapping__c.sObjectType, 'FieldsForRelationshipMapping');
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        List<Field_Group_Element__c> lstFGE3 = TestDataUtility.sendICPInforToAMFGElementsTestData(oFieldGroup3.Id);
        insert lstFGE3;
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
        List<sObject> lstBenMalnutritionData = Test.loadData(Malnutrition_Data__c.sObjectType, 'Malnutrition_Data');
        String sTestJson = '{"BeneficiaryList": [{"AccountName": "Test Integration ","AccountOwner": "rchamaca","CDSPType": "Center Based","AccountRecordType": "CDSP Beneficiary","ActiveProgram": "CDSP","AgreementRenewalDate": "2015-03-04 09:59:50","AgreementSignedDate": null,"ActualRegistrationDate": "2015-03-04 00:00:00Z","AlternateAddressExpiryDate": null,"AvailableforMarketingDate": null,"BeneficiaryLastBibleDistributedDate": null,"BeneficiaryChoreList": "Child Care;Cleaning;Kitchen Help;Making Beds;Running Errands;Washing Clothes;","BeneficiaryConfessionofFaithDate": null,"BeneficiaryHobbyList": "Bicycling;Group Games;Running;Singing;Story Telling;Soccer or Football;","COMPASSId": null,"BeneficiaryStatus": "Active","Birthdate": "2000-05-24 00:00:00Z","BMIforAgeWHO": null,"CaregiverName": "Mummy","CaregiverId": null,"CDSPProgramEndDate": null,"ChristianActivities": "Sunday School and Church;Camp;","ChronicIllness": null,"ClusterName": null,"CognitiveAgeGroup": null,"Disabilities": null,"ExistingBeneficiaryId": null,"ExistingBeneficiaryName": "Test","Country": "Bolivia","FormalEducationStatus": null,"Gender": "Male","LocalGradeLevel": "Middle 2","HeightInCm": null,"HouseholdName": "","ICPId": "ET090","IncidentDate": null,"IncidentNumber": null,"IsAlternateAddressinUse": null,"IsBeneficiaryAttendingSchool": "true","Language": null,"LastReviewedDate": null,"MentalDevelopmentConditions": null,"Phone": null,"PlannedCompletionDate": "2018-10-01 00:00:00Z","PlannedCompletionDateChangeReason": null,"PreferredName": "toni","ProgramFieldManualExemption": null,"ReligiousAffiliation": null,"TutorImplementerName": "Test","WeightInKg": null,"CompassChild": "ET0901828","BeneficiaryEducationalAssessment": "Average","NaturalFatherLivingWithChild": "True","NaturalMotherLivingWithChild": "True","NaturalFatherIsAlive": "Yes","NaturalMotherIsAlive": "Yes","FemaleOccupation": "Other","MaleOccupation": "Other","FemaleEmploymentStatus": "Sometimes Employed","MaleEmploymentStatus": "Sometimes Employed","MaritalStatus": "Married","CurrentUniversityYearOfStudy": null,"TypeOfVocationalEducation": null,"MajorOrCourseOfStudy": null,"TogetherNow": "Yes","LocalBeneficiaryNumber":"1828","HouseholdMembersList": [{"CompassionBeneficiaryId": null,"Role": "Mother","HouseholdMemberName": "Mummy","IsCaregiver": "true","Household": null},{"CompassionBeneficiaryId": null,"Role": "Father","HouseholdMemberName": "Unknown","IsCaregiver": "true","Household": null}]}]}';
        String sTestJson2 = '{"BeneficiaryList": [{"AccountName": "Test Integration ","AccountOwner": "rchamaca","CDSPType": "Center Based","AccountRecordType": "CDSP Beneficiary","ActiveProgram": "CDSP","AgreementRenewalDate": "2015-03-04 09:59:50","AgreementSignedDate": null,"ActualRegistrationDate": "2015-03-04 00:00:00Z","AlternateAddressExpiryDate": null,"AvailableforMarketingDate": null,"BeneficiaryLastBibleDistributedDate": null,"BeneficiaryChoreList": "Child Care;Cleaning;Kitchen Help;Making Beds;Running Errands;Washing Clothes;","BeneficiaryConfessionofFaithDate": null,"BeneficiaryHobbyList": "Bicycling;Group Games;Running;Singing;Story Telling;Soccer or Football;","COMPASSId": "12345","BeneficiaryStatus": "Active","Birthdate": "2000-05-24 00:00:00Z","BMIforAgeWHO": null,"CaregiverName": "Mummy","CaregiverId": null,"CDSPProgramEndDate": null,"ChristianActivities": "Sunday School and Church;Camp;","ChronicIllness": null,"ClusterName": null,"CognitiveAgeGroup": null,"Disabilities": null,"ExistingBeneficiaryId": null,"ExistingBeneficiaryName": "Test","Country": "Bolivia","FormalEducationStatus": null,"Gender": "Male","LocalGradeLevel": "Middle 2","HeightInCm": null,"HouseholdName": "Integration Household 711","ICPId": "ET090","IncidentDate": null,"IncidentNumber": null,"IsAlternateAddressinUse": null,"IsBeneficiaryAttendingSchool": "true","Language": null,"LastReviewedDate": null,"MentalDevelopmentConditions": null,"Phone": null,"PlannedCompletionDate": "2018-10-01 00:00:00Z","PlannedCompletionDateChangeReason": null,"PreferredName": "toni","ProgramFieldManualExemption": null,"ReligiousAffiliation": null,"TutorImplementerName": "Test","WeightInKg": null,"CompassChild": "ET0901828","BeneficiaryEducationalAssessment": "Average","NaturalFatherLivingWithChild": "True","NaturalMotherLivingWithChild": "True","NaturalFatherIsAlive": "Yes","NaturalMotherIsAlive": "Yes","FemaleOccupation": "Other","MaleOccupation": "Other","FemaleEmploymentStatus": "Sometimes Employed","MaleEmploymentStatus": "Sometimes Employed","MaritalStatus": "Married","CurrentUniversityYearOfStudy": null,"TypeOfVocationalEducation": null,"MajorOrCourseOfStudy": null,"TogetherNow": "Yes","LocalBeneficiaryNumber":"1000","HouseholdMembersList": [{"CompassionBeneficiaryId": null,"Role": "Mother","HouseholdMemberName": "Mummy","IsCaregiver": "true","Household": null},{"CompassionBeneficiaryId": null,"Role": "Father","HouseholdMemberName": "Unknown","IsCaregiver": "true","Household": null}]}]}';
        
        
        User UserPF = [select Id, Name from User where Id =: UserInfo.getUserId()];
        System.assert(UserPF.Name != null);
        list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
        insert lstPMHierarchyReg;
        list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserPF);
        insert lstAccountFO;
        TriggerContextUtility.bSendICPBenefTestToAMIntegFirstRun =false;
        TriggerContextUtility.bSendToAMIntegFirstRun = false;
        list<PM_Hierarchy__c> lstPMHierarchyTer = TestDataUtility.TerritoryTestData(lstAccountFO);
        insert lstPMHierarchyTer;
        list<PM_Hierarchy__c> lstPMHierarchyCluster = TestDataUtility.ClusterTestData(lstPMHierarchyTer, UserPF);
        insert lstPMHierarchyCluster;
        Test.StartTest();
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstPMHierarchyCluster[0].ID ;
        oICPAccount.ICP_Status__c='Active';
        oICPAccount.ICP_Id__c = 'ET090';
        lstAccountICP.add(oICPAccount) ;
        insert lstAccountICP;
        list<Household__c> lstHousehold = TestDataUtility.HouseholdTestData();
        lstHousehold[0].Name = 'Integration Household 711';
        insert lstHousehold;
        list<Household_Member__c> lstHouseholdMember = TestDataUtility.HouseholdMemberTestData(lstHousehold);
        insert lstHouseholdMember;
        list<Account> lstAccountCDSP = new list<Account>();
        lstAccountCDSP = TestDataUtility.CDSPBeneficiaryTestData(lstAccountICP, lstHousehold, lstHouseholdMember);
        lstAccountCDSP[0].Local_beneficiary_Number__c = '1000';
        try{
            insert lstAccountCDSP;
            System.assertNotEquals(null,lstAccountCDSP[0].id);
        }catch(Exception e) {
        }
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl()+'services/apexrest/CreateBeneficiary';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(sTestJson);
        RestContext.request = req;
        RestContext.response = res;
        try{
            BeneficiaryAndHMInsertion.createBenefAndHM();
        
        req.requestBody = Blob.valueof(sTestJson2);
        RestContext.request = req;
        RestContext.response = res;
        BeneficiaryAndHMInsertion.createBenefAndHM();
        }
        Catch(Exception e){
        }
        Test.stopTest();
    }
}