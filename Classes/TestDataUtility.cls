/********************************************************************************
Class Name         : TestDataUtility
Description        : This class is a utility class that handles creation of data for test classes
Created By         : Sudipta Nayak
Created On         : 06-Feb-2015 
********************************************************************************/

global class TestDataUtility {

    /**
    * Method name  : UserTestData
    * Description  : This method creates Test Data for User which helps in creating
                     test data for other objects.
    * Return Type  : User
    * Parameter    : String ,String , Id , String
    **/
    public static User UserTestData(String profilename,String alias, String roleName){
        //Create a User Record in Test Class
        Profile p = [SELECT Id FROM Profile WHERE Name=:profilename ];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User(  LastName='Testing'+profilename,
                            email = uniqueName + '@test' + orgId + '.org',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = p.Id,
                            IsActive = true 
                          );  
        if(roleName<> null)
        {      
            List<UserRole> rl = [Select id, name from UserRole where Name=:roleName limit 1 ];
            if(!rl.isEmpty()){
                u.UserRoleId = rl[0].Id;
            }   
        }
        return u;
    }
    
    /**
    * Method name  : LeadTestData
    * Description  : This method creates Test Data for ICP Leads
    * Return Type  : list<Lead>
    * Parameter    : list<PM_Hierarchy__c>, User, User
    **/
    public static list<Lead> LeadTestData(list<PM_Hierarchy__c> Cluster, User UserPF, User UserPFS)
    {
        list<Lead> LeadList = new list<Lead>();
        Id leadRecTypeId = Utility.getRecordTypeIdByDeveloperName(Lead.SObjectType, Constants.ICP_LEAD_RT_API_NAME);
        list<PM_Hierarchy__c> Cl = [select id, name from PM_Hierarchy__c where id in:Cluster];
        Lead Lead1 = new Lead();
        Lead1.Company = 'Tewahedo Church';
        Lead1.FirstName = 'Monica';
        Lead1.LastName = 'Geller';
        Lead1.LeadSource = 'Campaign';
        Lead1.Status = 'Working';
        Lead1.Programs_Of_Interest__c = 'Center Based Sponsorship';
        Lead1.Partnership_Facilitator__c = UserPF.id;
        Lead1.Partnership_Facilitator_Supervisor__c = UserPFS.id;
        Lead1.Cluster__c = Cl[0].id;
        Lead1.ICP_ID__c = 'ET090';
        Lead1.Country = 'Ethiopia';
        Lead1.Street= '12th Main';
        Lead1.City = 'Ethiopia';
        Lead1.Statement_Of_Faith_Compatibility__c = 'Y';
        Lead1.Commitment_To_Child_Ministry__c = 'Y';
        Lead1.Commitment_To_Recruiting_Christians__c = 'N';
        Lead1.Commitment_To_Use_Local_Resources__c = 'N';
        Lead1.Location__c = 'Y';
        Lead1.Child_Enrollment_Capacity__c = 'Y';
        Lead1.Physical_Environment__c = 'N';
        Lead1.Agreement_Signed_Date__c = System.today();
        Lead1.RecordTypeId = leadRecTypeId;
        //Lead1.Lead_Score__c = 100;
        Lead1.Child_Dev_Center_Name_English__c = 'Test';
        Lead1.Partnership_Start_Date__c = System.today();
    Lead1.Field_Office_For_Denominations__c = 'Ethiopia';
        Lead1.Denomination_Church__c = 'Independent';
        LeadList.add(Lead1);
        Lead Lead2 = new Lead();
        Lead2.Company = 'Catedral Nueva';
        Lead2.FirstName = 'Rachel';
        Lead2.LastName = 'Green';
        Lead2.LeadSource = 'Campaign';
        Lead2.Status = 'Working';
        Lead2.Programs_Of_Interest__c = 'Center Based Sponsorship';
        Lead2.Partnership_Facilitator__c = UserPF.id;
        Lead2.Partnership_Facilitator_Supervisor__c = UserPFS.id;
        Lead2.Cluster__c = Cl[0].id;
        Lead2.ICP_ID__c = 'ET091';
        Lead2.Country = 'Ethiopia';
        Lead2.Street= '12th Main';
        Lead2.City = 'Ethiopia';
        Lead2.Statement_Of_Faith_Compatibility__c = 'Y';
        Lead2.Commitment_To_Child_Ministry__c = 'Y';
        Lead2.Commitment_To_Recruiting_Christians__c = 'N';
        Lead2.Commitment_To_Use_Local_Resources__c = 'N';
        Lead2.Location__c = 'Y';
        Lead2.Child_Enrollment_Capacity__c = 'Y';
        Lead2.Physical_Environment__c = 'N';
        Lead2.RecordTypeId = leadRecTypeId;
        //Lead2.Lead_Score__c = 100;
        Lead2.Child_Dev_Center_Name_English__c = 'Test';
        Lead2.Agreement_Signed_Date__c = System.today();
        Lead2.Partnership_Start_Date__c = System.today();
     Lead2.Field_Office_For_Denominations__c = 'Ethiopia';
        Lead2.Denomination_Church__c = 'Independent';
        LeadList.add(Lead2);
        return LeadList;    
    }
    
    /**
    * Method name  : ICPTestData
    * Description  : This method creates Test Data for ICP Account
    * Return Type  : list<Account>
    * Parameter    : list<Id>
    **/
    public static list<Account> ICPTestData(list<id> icpId)
    {
    
        list<Account> icpList = new list<Account>();
        list<Account> AccountList = new list<Account>();
        icpList = [Select id, Name, RecordTypeId, ICP_Status__c,
        Child_Dev_Center_Name_English__c, Spiritual_Activities_1_5__c,
        Spiritual_Activities_6_11__c, Spiritual_Activities_12__c,
        Cognitive_Activities_1_5__c, Cognitive_Activities_12__c,
        Cognitive_Activities_6_11__c, Physical_Activities_1_5__c,
        Physical_Activities_12__c, Physical_Activities_6_11__c,
        Socio_Emotional_Activities_1_5__c, Socio_Emotional_Activities_12__c,
        Socio_Emotional_Activities_6_11__c, Community_Name__c, Population__c,
        Primary_Ethnic_Group_Name__c, Primary_Language__c,
        Primary_Adults_Occupation_In_Community__c, Average_Family_Monthly_Income__c,
        Unemployment_Rate__c, Closest_Major_City__c, Locale__c, Climate__c,
        Terrain__c, Typical_Home_Roof__c, Typical_Home_Wall__c, Typical_Home_Floor__c,
        Average_Coolest_Temperature__c, Average_Month_Coolest_Temperature__c,
        Average_Warmest_Temperature__c, Average_Month_Warmest_Temperature__c,
        Cultural_Description_Context_Needs__c, Economic_Description_Context_Needs__c,
        Health_Description_Context_Needs__c, Educational_Description_Context_Needs__c,
        Spiritual_Description_Context_Needs__c, Social_Context_and_Needs__c,
        Primary_Diet__c, Distance_To_Closest_Intl_Airport__c, Travel_Time_To_Intl_Airport_In_Hours__c,
        ICP_NBR_Priority__c, Minimum_Number_of_NBRs__c from Account where id in : icpId
        ];
        icpList[0].ICP_Id__c = 'ET873';
        icpList[0].Name= 'Test Class1';        
        icpList[0].Child_Dev_Center_Name_English__c= 'Test';
        icpList[0].Distance_To_Closest_Intl_Airport__c = 40;
        icpList[0].Travel_Time_To_Intl_Airport_In_Hours__c = 1;
        icpList[0].ICP_NBR_Priority__c = 'High';
        icpList[0].Minimum_Number_of_NBRs__c = '20';
        icpList[0].Spiritual_Activities_1_5__c = 'Bible Memory Verse Club';
        icpList[0].Spiritual_Activities_6_11__c= 'Bible Memory Verse Club';
        icpList[0].Spiritual_Activities_12__c  = 'Bible Memory Verse Club';
        icpList[0].Cognitive_Activities_1_5__c = 'Basic Life-skill training';
        icpList[0].Cognitive_Activities_12__c = 'Basic Life-skill training';
        icpList[0].Cognitive_Activities_6_11__c = 'Basic Life-skill training';
        icpList[0].Physical_Activities_1_5__c='Health kits';
        icpList[0].Physical_Activities_12__c ='Health kits';
        icpList[0].Physical_Activities_6_11__c ='Health kits';
        icpList[0].Socio_Emotional_Activities_1_5__c= 'Counseling and Testing for HIV / AIDS';
        icpList[0].Socio_Emotional_Activities_12__c = 'Counseling and Testing for HIV / AIDS';
        icpList[0].Socio_Emotional_Activities_6_11__c = 'Counseling and Testing for HIV / AIDS';
        icpList[0].Community_Name__c ='Test';
        icpList[0].Population__c = 77;
        icpList[0].Primary_Ethnic_Group_Name__c = 'Test';
        icpList[0].Primary_Language__c = 'English';
        icpList[0].Primary_Adults_Occupation_In_Community__c = 'Day Labor';
        icpList[0].Average_Family_Monthly_Income__c = '99';
        icpList[0].Unemployment_Rate__c = 9;
        icpList[0].Closest_Major_City__c= 'Test';
        icpList[0].Locale__c = 'City';
        icpList[0].Climate__c= 'Moderate';
        icpList[0].Terrain__c= 'Plains/Flat Land';
        icpList[0].Typical_Home_Roof__c= 'Bamboo';
        icpList[0].Typical_Home_Wall__c= 'Mud/Earth/Clay/Adobe';
        icpList[0].Typical_Home_Floor__c= 'Cardboard';
        icpList[0].Average_Coolest_Temperature__c= '9';
        icpList[0].Average_Month_Coolest_Temperature__c='Jan';
        icpList[0].Average_Warmest_Temperature__c = '80';
        icpList[0].Average_Month_Warmest_Temperature__c='May';
        icpList[0].Cultural_Description_Context_Needs__c = 'test';
        icpList[0].Economic_Description_Context_Needs__c= 'Test';
        icpList[0].Health_Description_Context_Needs__c='Test';
        icpList[0].Educational_Description_Context_Needs__c='test';
        icpList[0].Spiritual_Description_Context_Needs__c ='test';
        icpList[0].Social_Context_and_Needs__c='test';
        icpList[0].Primary_Diet__c ='Bananas';
        icpList[0].ICP_Status__c = 'Active';
        icpList[0].Implemented_Programs__c= 'Center Based Sponsorship';

        if(icpList.size()>1)
        {
        icpList[1].ICP_Id__c = 'ET872';
        icpList[1].Name= 'Test Class2';
        icpList[1].Child_Dev_Center_Name_English__c= 'Test';
        icpList[1].Distance_To_Closest_Intl_Airport__c = 40;
        icpList[1].Travel_Time_To_Intl_Airport_In_Hours__c = 1;
        icpList[1].ICP_NBR_Priority__c = 'High';
        icpList[1].Minimum_Number_of_NBRs__c = '20';
        icpList[1].Spiritual_Activities_1_5__c = 'Bible Memory Verse Club';
        icpList[1].Spiritual_Activities_6_11__c= 'Bible Memory Verse Club';
        icpList[1].Spiritual_Activities_12__c  = 'Bible Memory Verse Club';
        icpList[1].Cognitive_Activities_1_5__c = 'Basic Life-skill training';
        icpList[1].Cognitive_Activities_12__c = 'Basic Life-skill training';
        icpList[1].Cognitive_Activities_6_11__c = 'Basic Life-skill training';
        icpList[1].Physical_Activities_1_5__c='Health kits';
        icpList[1].Physical_Activities_12__c ='Health kits';
        icpList[1].Physical_Activities_6_11__c ='Health kits';
        icpList[1].Socio_Emotional_Activities_1_5__c= 'Counseling and Testing for HIV / AIDS';
        icpList[1].Socio_Emotional_Activities_12__c = 'Counseling and Testing for HIV / AIDS';
        icpList[1].Socio_Emotional_Activities_6_11__c = 'Counseling and Testing for HIV / AIDS';
        icpList[1].Community_Name__c ='Test';
        icpList[1].Population__c = 77;
        icpList[1].Primary_Ethnic_Group_Name__c = 'Test';
        icpList[1].Primary_Language__c = 'English';
        icpList[1].Primary_Adults_Occupation_In_Community__c = 'Day Labor';
        icpList[1].Average_Family_Monthly_Income__c = '82';
        icpList[1].Unemployment_Rate__c = 9;
        icpList[1].Closest_Major_City__c= 'Test';
        icpList[1].Locale__c = 'City';
        icpList[1].Climate__c= 'Moderate';
        icpList[1].Terrain__c= 'Plains/Flat Land';
        icpList[1].Typical_Home_Roof__c= 'Bamboo';
        icpList[1].Typical_Home_Wall__c= 'Mud/Earth/Clay/Adobe';
        icpList[1].Typical_Home_Floor__c= 'Cardboard';
        icpList[1].Average_Coolest_Temperature__c= '9';
        icpList[1].Average_Month_Coolest_Temperature__c='Jan';
        icpList[1].Average_Warmest_Temperature__c = '80';
        icpList[1].Average_Month_Warmest_Temperature__c='May';
        icpList[1].Cultural_Description_Context_Needs__c = 'test';
        icpList[1].Economic_Description_Context_Needs__c= 'Test';
        icpList[1].Health_Description_Context_Needs__c='Test';
        icpList[1].Educational_Description_Context_Needs__c='test';
        icpList[1].Spiritual_Description_Context_Needs__c ='test';
        icpList[1].Social_Context_and_Needs__c='test';
        icpList[1].Primary_Diet__c ='Bananas';
        icpList[1].ICP_Status__c = 'Active';
        icpList[1].Implemented_Programs__c= 'Center Based Sponsorship';
        }
        else{
            system.debug('Only one ICP is inserted');
        }
        return icpList;
    
    /*
        list<Account> icpList = new list<Account>();
        icpList = [Select id,Name,RecordTypeId,ICP_Status__c,ICP_ID__c,Check_Record__c,RecordType.DeveloperName from Account where id in: icpId];
        return icpList;
    */
    }

    /**
    * Method name  : CDSPBeneficiaryTestData
    * Description  : This method creates Test Data for CDSP Beneficiary record type of Account
    * Return Type  : list<Account>
    * Parameter    : list<Account>, list<Household__c>, list<Household_Member__c> 
    **/ 
    public static list<Account> CDSPBeneficiaryTestData(list<Account> icpTestData, list<Household__c> lstHousehold, list<Household_Member__c> lstHM)
    {
        list<Account> BenList = new list<Account>();
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Account b = new Account();
        Account c = new Account();
        list<Account> icp = new list<Account>();
        icp = [Select id, Name from Account where id in: icpTestData];
        //list<Household__c> lstHouseholdM = [Select id, Name from Household__c where id in:lstHousehold];
        //<Household_Member__c> lstHouseholdMember = [Select id, Name from Household_Member__c where id in:lstHM];
        //Beneficiary: John Doe
        b.LastName = 'Doe';
        b.Local_Beneficiary_Number__c = '1022';
        b.PersonBirthdate = System.Today()-1500;
        b.Gender__c = 'Male';
        b.Beneficiary_Confession_Of_Faith_Date__c = System.Today();
        b.Active_Program__c = Constants.CDSP;
        b.CDSP_Type__c = 'Center Based';
        b.PO_Number__c='2354';
        b.RecordTypeId = cdspRecTypeId;
        b.Compass_Id__c = '880122';
        b.Beneficiary_Status__c = 'Active';
        b.ICP__c = icpTestData[0].id;
        b.Review_Status__c='Approved';
        b.CDSP_Start_Date__c = System.today() - 30;
        b.Actual_Registration_Date__c = System.Today();
        b.Country__c = 'Ethiopia';
        b.Formal_Education_Status__c='Primary';
        b.Local_Grade_Level__c = 'Primary 5B';
        b.Type_Of_Vocational_Education__c='Not enrolled';
        b.Not_Enrolled_In_Education_Reason__c='Testing Not Enrolled in Education';
        b.Height_Cm__c = 100;
        b.Weight_Kg__c = 20;
        b.BEN_Chore_List__c = 'Cleaning';
        b.Fun_Things_To_Do__c = 'Baseball';
        b.Planned_Completion_Date__c = System.Today() + 20;
        b.Household__c = lstHousehold[0].id;
        //b.Primary_Caregiver__c = lstHouseholdMember[0].id;
        b.FirstName = 'John';
        b.Beneficiary_Confesses_Jesus_as_Savior__c= False;
        b.Correspondence_Country__c = 'Ethiopia';
       b.Correspondence_Language__c= 'Amharic';
        BenList.add(b);
        //Beneficiary: Emily Winters
        c.LastName = 'Winters';
        c.Local_Beneficiary_Number__c = '1021';
        c.PersonBirthdate = System.Today()-1800;
        c.Review_Status__c='Approved';
        
        c.Gender__c = 'Female';
        c.Formal_Education_Status__c='Primary';
        c.Beneficiary_Confession_Of_Faith_Date__c = System.Today();
        c.Local_Grade_Level__c = 'Primary 5B';
        c.Active_Program__c = Constants.CDSP;
        c.CDSP_Type__c = 'Home Based';
        c.RecordTypeId = cdspRecTypeId;
        c.Beneficiary_Status__c = 'Inactive';
        c.Compass_Id__c = '56794';
        c.ICP__c = icpTestData[0].id;
        c.Type_Of_Vocational_Education__c='Not enrolled';
        c.Not_Enrolled_In_Education_Reason__c='Testing Not Enrolled in Education';        
        c.CDSP_Start_Date__c = System.today() - 30;
        c.Actual_Registration_Date__c = System.Today();
        c.Height_Cm__c = 150;
        c.PO_Number__c='23577';
        c.Weight_Kg__c = 40;
        c.BEN_Chore_List__c = 'Cleaning';
        c.Fun_Things_To_Do__c = 'Baseball';
        c.Planned_Completion_Date__c = System.Today() + 20;
        c.Household__c = lstHousehold[0].id;
        //c.Primary_Caregiver__c = lstHouseholdMember[0].id;
        c.FirstName = 'Emily';
        c.Beneficiary_Confesses_Jesus_as_Savior__c= False;
        c.Local_Beneficiary_Id__c = 'EC3478925';
        c.Correspondence_Country__c = 'Ethiopia';
        c.Correspondence_Language__c= 'Amharic';
        BenList.add(c);
        return BenList;
    }
    
    /**
    * Method name  : CSPBeneficiaryTestData
    * Description  : This method creates Test Data for CSP Beneficiary record type of Account
    * Return Type  : list<Account>
    * Parameter    : list<Account>, list<Household_Member__c>
    **/ 
    public static list<Account> CSPBeneficiaryTestData(list<Account> icpTestData, list<Household__c> lstHousehold, list<Household_Member__c> lstHM)
    {
        list<Account> BenList = new list<Account>();
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CSP_BENEFICIARY_RT_API_NAME);
        Account b = new Account();
        Account c = new Account();
        list<Account> icp = new list<Account>();
        icp = [Select id, Name, RecordTypeId from Account where id in: icpTestData];
        ////list<Household__c> lstHouseholdM = [Select id, Name from Household__c where id in:lstHousehold];
        list<Household_Member__c> lstHouseholdMember = [Select id, Name from Household_Member__c where id in:lstHM];
        //Beneficiary: Jim Hill
        b.LastName = 'Hill';
        b.Local_Beneficiary_Number__c = '7800';
        b.PersonBirthdate = System.Today()-500;
        b.Gender__c = 'Male';
        b.Active_Program__c = Constants.CSP;
        b.RecordTypeId = cspRecTypeId;
        b.Beneficiary_Status__c = 'Active';
        b.Compass_Id__c = '7655809';
        b.ICP__c = icp[0].Id;
        b.Height_Cm__c = 150;
        b.Formal_Education_Status__c='Primary';
        b.Type_Of_Vocational_Education__c='Not enrolled';
        b.Not_Enrolled_In_Education_Reason__c='Testing Not Enrolled in Education';
        b.Review_Status__c='Approved';
        b.Weight_Kg__c = 8;
        b.Birth_Weight_Kg__c = 3;
        b.Review_Status__c='Submitted';
        b.Local_Grade_Level__c = 'Primary 5B';
        b.Actual_Registration_Date__c = System.Today();
        b.Household__c=lstHousehold[0].id;
        //b.Primary_Caregiver__c = lstHouseholdMember[0].id;
        b.FirstName = 'Jim';
        BenList.add(b);
        //Beneficiary: Nick Halden
        c.LastName = 'Halden';
        c.Local_Beneficiary_Number__c = '7890';
        c.PersonBirthdate = System.Today()-600;
        c.Gender__c = 'Male';
        c.Active_Program__c = Constants.CSP;
        c.RecordTypeId = cspRecTypeId;
        c.Beneficiary_Status__c = 'Active';
        c.Compass_Id__c = '66557788';
        c.Review_Status__c='Approved';
        c.Type_Of_Vocational_Education__c='Not enrolled';
        c.Not_Enrolled_In_Education_Reason__c='Testing Not Enrolled in Education';
        c.Formal_Education_Status__c='Primary';
        c.Local_Grade_Level__c = 'Primary 5B';
        c.Review_Status__c='Submitted';
        c.ICP__c = icp[0].Id;
        c.Height_Cm__c = 150;
        c.Weight_Kg__c = 10;
        c.Birth_Weight_Kg__c = 4;
        c.Actual_Registration_Date__c = System.Today();
        c.Household__c = lstHousehold[0].id;
        //c.Primary_Caregiver__c = lstHouseholdMember[0].id;
        c.FirstName = 'Nick';
        BenList.add(c);
        return BenList;
    }
    
    /**
    * Method name  : CDSPBLETestData
    * Description  : This method creates Test Data for Beneficiary Lifecycle Events for CDSP Beneficiary
    * Return Type  : list<Beneficiary_Lifecycle_Event__c>
    * Parameter    : list<Account>, list<Account>, Integer
    **/
    public static list<Beneficiary_Lifecycle_Event__c> CDSPBLETestData(list<Account> benTestData, list<Account> icpTestData)
    {
        list<Beneficiary_Lifecycle_Event__c> lstBLE = new list<Beneficiary_Lifecycle_Event__c>();
        Id transitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSITION_RT_API_NAME);
        Id reinstatementRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_REINSTATEMENT_RETURN_RT_API_NAME);
        Id exitRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME);
        Id transferRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSFER_RT_API_NAME
        );
        Id caregiverDeathRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_CRGVR_DEATH_RT_API_NAME);
        Beneficiary_Lifecycle_Event__c bleExit = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleTransition1 = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleTransition2 = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleReinstatement = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleTransfer = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleCaregiverDeath = new Beneficiary_Lifecycle_Event__c();
        //list<Account> ben1 = [Select id, LastName from Account where id in: benTestData];
        //list<Account> lstICP = [Select id, LastName from Account where id in: icpTestData];
        //Creating Transition Record Type BLE Test Data with CDSP Beneficiary
        //bleTransition1.Review_Status__c='Approved';
        /*bleTransition1.Beneficiary__c = benTestData[0].id;
        bleTransition1.RecordTypeId = transitionRecTypeId;
        bleTransition1.Transition_Type__c = 'CDSP - CSP';
        bleTransition1.Date_of_Action__c = System.Today() - 3;
        bleTransition1.Transition_Update_Date__c = System.Today() - 2;
        lstBLE.add(bleTransition1);*/
        //Creating Planned Exit Record Type BLE Test Data with CDSP Beneficiary
        bleExit.Review_Status__c='Approved';
        bleExit.Beneficiary__c = benTestData[0].id;
        bleExit.RecordTypeId = exitRecTypeId;
        bleExit.Date_of_Action__c = System.today();
        bleExit.Exit_Update_Date__c = System.today();
        bleExit.Beneficiary_Confesses_Jesus_as_Savior__c= True;
        bleExit.Reason_For_Request__c = 'Reached the end of relevant programs available at ICP';
        lstBLE.add(bleExit); 
        //Creating Transition Record Type BLE Test Data with CDSP Beneficiary
        bleTransition2.Review_Status__c='Approved';
        bleTransition2.Beneficiary__c = benTestData[1].id;
        bleTransition2.RecordTypeId = transitionRecTypeId;
        bleTransition2.Transition_Type__c = System.Label.CDSP_Home_To_CDSP_Center;
        bleTransition2.Date_of_Action__c = System.Today();
        bleTransition2.Transition_Update_Date__c = System.Today();
        lstBLE.add(bleTransition2);
        
        
        //Creating Transfer Record Type BLE Test Data with CDSP Beneficiary
        bleTransfer.Review_Status__c='Approved';
        bleTransfer.Beneficiary__c = benTestData[1].id;
        bleTransfer.RecordTypeId = transferRecTypeId;
        bleTransfer.Date_of_Action__c = System.today();
        bleTransfer.Reason_For_Request__c = 'Family circumstances have changed positively';
        bleTransfer.New_Local_Beneficiary_Number__c = '9855';
        bleTransfer.New_Current_ICP__c = icpTestData[1].Id;
        bleTransfer.Status__c = 'CLOSED';
        lstBLE.add(bleTransfer);
        //Creating Caregiver Death BLE
        bleCaregiverDeath.Beneficiary__c = benTestData[1].id;
        bleCaregiverDeath.RecordTypeId = caregiverDeathRecTypeId;
        bleCaregiverDeath.Date_Of_Death__c = System.Today();
        bleCaregiverDeath.Death_Category__c = 'Abuse';
        bleCaregiverDeath.Death_Sub_Category__c = 'Physical';
        lstBLE.add(bleCaregiverDeath);
        //Creating Reinstatement Record Type BLE Test Data with CDSP Beneficiary
        bleReinstatement.Review_Status__c='Approved';
        bleReinstatement.Beneficiary__c = benTestData[0].id;
        bleReinstatement.RecordTypeId = reinstatementRecTypeId;
        bleReinstatement.Date_of_Action__c = System.today();
        bleReinstatement.Reason_For_Request__c = 'Family circumstances have changed positively';
        //bleReinstatement.New_Local_Beneficiary_Number__c = '9897';
        lstBLE.add(bleReinstatement);
        
        return lstBLE;
    }
    
    /**
    * Method name  : CDSPBLETestDataOneICP
    * Description  : This method creates Test Data for Beneficiary Lifecycle Events for CDSP Beneficiary
    * Return Type  : list<Beneficiary_Lifecycle_Event__c>
    * Parameter    : list<Account>, list<Account>, Integer
    **/
    public static list<Beneficiary_Lifecycle_Event__c> CDSPBLETestDataOneICP(list<Account> benTestData)
    {
        list<Beneficiary_Lifecycle_Event__c> lstBLE = new list<Beneficiary_Lifecycle_Event__c>();
        Id transitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSITION_RT_API_NAME);
        Id reinstatementRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_REINSTATEMENT_RETURN_RT_API_NAME);
        Id exitRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME);
        Id transferRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSFER_RT_API_NAME
        );
        Beneficiary_Lifecycle_Event__c bleExit = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleTransition1 = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleTransition2 = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleReinstatement = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleTransfer = new Beneficiary_Lifecycle_Event__c();
        //list<Account> ben1 = [Select id, LastName from Account where id in: benTestData];
        //list<Account> lstICP = [Select id, LastName from Account where id in: icpTestData];
        //Creating Transition Record Type BLE Test Data with CDSP Beneficiary
        /*bleTransition1.Review_Status__c='Approved';
        bleTransition1.Beneficiary__c = benTestData[0].id;
        bleTransition1.RecordTypeId = transitionRecTypeId;
        bleTransition1.Transition_Type__c = 'CDSP - CSP';
        bleTransition1.Date_of_Action__c = System.Today() - 3;
        bleTransition1.Transition_Update_Date__c = System.Today() - 2;
        lstBLE.add(bleTransition1);*/
        //Creating Transition Record Type BLE Test Data with CDSP Beneficiary
        bleTransition2.Review_Status__c='Approved';
        bleTransition2.Beneficiary__c = benTestData[0].id;
        bleTransition2.RecordTypeId = transitionRecTypeId;
        bleTransition2.Transition_Type__c = System.Label.CDSP_Home_To_CDSP_Center;
        bleTransition2.Date_of_Action__c = System.Today() - 3;
        bleTransition2.Transition_Update_Date__c = System.Today() - 2;
        lstBLE.add(bleTransition2);
        //Creating Planned Exit Record Type BLE Test Data with CDSP Beneficiary
        bleExit.Review_Status__c='Approved';
        bleExit.Beneficiary__c = benTestData[0].id;
        bleExit.RecordTypeId = exitRecTypeId;
        bleExit.Date_of_Action__c = System.today();
        bleExit.Exit_Update_Date__c = System.today();
        bleExit.Reason_For_Request__c = 'Reached the end of relevant programs available at ICP';
        lstBLE.add(bleExit); 
        //Creating Reinstatement Record Type BLE Test Data with CDSP Beneficiary
        bleReinstatement.Review_Status__c='Approved';
        bleReinstatement.Beneficiary__c = benTestData[0].id;
        bleReinstatement.RecordTypeId = reinstatementRecTypeId;
        bleReinstatement.Date_of_Action__c = System.today() - 3;
        bleReinstatement.Reason_For_Request__c = 'Family circumstances have changed positively';
        //bleReinstatement.New_Local_Beneficiary_Number__c = '9897';
        lstBLE.add(bleReinstatement);
        return lstBLE;
    }
    
    /**
    * Method name  : CSPBLETestData
    * Description  : This method creates Test Data for Beneficiary Lifecycle Events for CSP Beneficiary
    * Return Type  : list<Beneficiary_Lifecycle_Event__c>
    * Parameter    : list<Account>, list<Account>, Integer
    **/
    public static list<Beneficiary_Lifecycle_Event__c> CSPBLETestData(list<Account> icpTestData, list<Account> benTestData)
    {
        list<Beneficiary_Lifecycle_Event__c> lstBLE = new list<Beneficiary_Lifecycle_Event__c>();
        Id transitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSITION_RT_API_NAME);
        Id transferRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSFER_RT_API_NAME);
        Id exitRecTypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_RT_API_NAME);
        Id caregiverDeathRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_CRGVR_DEATH_RT_API_NAME);
        Beneficiary_Lifecycle_Event__c bleCaregiverDeath = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleTransfer = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleTransfer2 = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleTransition1 = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleTransition2 = new Beneficiary_Lifecycle_Event__c();
        Beneficiary_Lifecycle_Event__c bleExit = new Beneficiary_Lifecycle_Event__c();
        list<Account> ben1 = [Select id,LastName from Account where id in:benTestData];
        list<Account> icp = [Select id, Name from Account where id in: icpTestData];
        //Creating Caregiver Death BLE
        bleCaregiverDeath.Beneficiary__c = ben1[0].id;
        bleCaregiverDeath.RecordTypeId = caregiverDeathRecTypeId;
        bleCaregiverDeath.Date_Of_Death__c = System.Today();
        bleCaregiverDeath.Death_Category__c = 'Abuse';
        bleCaregiverDeath.Death_Sub_Category__c = 'Physical';
        lstBLE.add(bleCaregiverDeath);
        //Creating Transition Record Type BLE Test Data with CSP Beneficiary
        bleTransition1.Beneficiary__c = ben1[0].id;
        bleTransition1.RecordTypeId = transitionRecTypeId;
        bleTransition1.Transition_Type__c = System.Label.CSP_To_CDSP_Home;
        bleTransition1.Date_of_Action__c = System.Today();
        bleTransition1.Transition_Update_Date__c = System.Today() - 2;
        lstBLE.add(bleTransition1);
        //Creating Transition Record Type BLE Test Data with CSP Beneficiary
        bleTransition2.Beneficiary__c = ben1[1].id;
        bleTransition2.RecordTypeId = transitionRecTypeId;
        bleTransition2.Transition_Type__c = System.Label.CSP_to_CDSP_Center_Transition_Value;
        bleTransition2.Date_of_Action__c = System.Today();
        bleTransition2.Transition_Update_Date__c = System.Today() - 2;
        lstBLE.add(bleTransition2);
        //Creating Transfer Record Type BLE Test Data with CSP Beneficiary
        bleTransfer.Beneficiary__c = ben1[0].id;
        bleTransfer.RecordTypeId = transferRecTypeId;
        bleTransfer.Date_of_Action__c = System.today() + 10;
        bleTransfer.Reason_For_Request__c = 'Relocation: Parent?s Work.';
        bleTransfer.New_Current_ICP__c = icp.get(1).id;
        bleTransfer.Status__c = 'Closed';
        bleTransfer.New_Local_Beneficiary_Number__c = '707';
        lstBLE.add(bleTransfer);
        
        //Creating Planned Exit Record Type BLE Test Data with CDSP Beneficiary
        /*bleExit.Review_Status__c='Approved';
        bleExit.Beneficiary__c = ben1[0].id;
        bleExit.RecordTypeId = exitRecTypeId;
        bleExit.Date_of_Action__c = System.today();
        bleExit.Last_Attended_Date__c = System.today();
        bleExit.Beneficiary_Confesses_Jesus_as_Savior__c= True;
        bleExit.Reason_For_Request__c = 'Reached the end of relevant programs available at ICP';
        lstBLE.add(bleExit); */
        return lstBLE;
    }
    
    /**
    * Method name  : RegionTestData
    * Description  : This method creates Test Data for Region
    * Return Type  : list<PM_Hierarchy__c>
    * Parameter    : void
    **/
    public static list<PM_Hierarchy__c> RegionTestData()
    {
        list<PM_Hierarchy__c> lstPMHierarchyRegion = new list<PM_Hierarchy__c>();
        Id PMHierarchyRecTypeId = Utility.getRecordTypeIdByDeveloperName(PM_Hierarchy__c.SObjectType, 'Region');
        PM_Hierarchy__c Reg1 = new PM_Hierarchy__c();
        Reg1.Name = 'Ethiopia';
        Reg1.RecordTypeId = PMHierarchyRecTypeId;
        lstPMHierarchyRegion.add(Reg1);
        return lstPMHierarchyRegion;
    }
    
    /**
    * Method name  : FOTestData
    * Description  : This method creates Test Data for Field Office
    * Return Type  : list<Account>
    * Parameter    : list<PM_Hierarchy__c>, User
    **/
    public static list<Account> FOTestData(list<PM_Hierarchy__c> reg, User UserCD)
    {
        list<Account> FOList = new list<Account>();
        list<PM_Hierarchy__c> Reg1 = [select id, name from PM_Hierarchy__c where id in: reg];
        Id FORecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.FIELD_OFFICE_RT_API_NAME);
        Account FO1 = new Account();
        FO1.Name = 'Ethiopia';
        FO1.Region__c = Reg1[0].id;
        FO1.Country_Director__c = UserCD.id;
        FO1.RecordTypeId = FORecTypeId;
        FOList.add(FO1);
        return FOList;
    }
    
    /**
    * Method name  : TerritoryTestData
    * Description  : This method creates Test Data for Territory
    * Return Type  : list<PM_Hierarchy__c>
    * Parameter    : list<Account>
    **/
    public static list<PM_Hierarchy__c> TerritoryTestData(list<Account> FO)
    {
        list<PM_Hierarchy__c> TerritoryList = new list<PM_Hierarchy__c>();
        Id PMHierarchyRecTypeId = Utility.getRecordTypeIdByDeveloperName(PM_Hierarchy__c.SObjectType, 'Territory');
        list<Account> FO1 = [select id, name from Account where id in: FO];
        PM_Hierarchy__c Ter = new PM_Hierarchy__c();
        Ter.Name = 'East Ethiopia';
        Ter.RecordTypeId = PMHierarchyRecTypeId;
        Ter.Field_Office__c = FO1[0].id;
        TerritoryList.add(Ter);
        return TerritoryList;
    }
    
    /**
    * Method name  : ClusterTestData
    * Description  : This method creates Test Data for Cluster
    * Return Type  : list<PM_Hierarchy__c>
    * Parameter    : list<PM_Hierarchy__c>, User
    **/
    public static list<PM_Hierarchy__c> ClusterTestData(list<PM_Hierarchy__c> Ter, User User1)
    {
        list<PM_Hierarchy__c> ClusterList = new list<PM_Hierarchy__c>();
        Id PMHierarchyRecTypeId = Utility.getRecordTypeIdByDeveloperName(PM_Hierarchy__c.SObjectType, 'Cluster');
        list<PM_Hierarchy__c> Territory = [select id, Name from PM_Hierarchy__c where id in: Ter];
        PM_Hierarchy__c Cl = new PM_Hierarchy__c();
        Cl.Name = 'East Ethiopia Cluster';
        Cl.RecordTypeId = PMHierarchyRecTypeId;
        Cl.Territory__c = Territory[0].id;
        Cl.Partnership_Facilitator__c = User1.id;
        ClusterList.add(Cl);
        return ClusterList;
    }
    
    /**
    * Method name  : CaseTestData
    * Description  : This method creates Test Data for Incident Case
    * Return Type  : list<Case>
    * Parameter    : list<Account>
    **/
    public static list<Case> CaseTestData(list<Account> FO1)
    {
        list<Case> CaseList = new list<Case>();
        Account FO = [select id, name from Account where name =: FO1[0].name];
        Id CaseRecTypeId = Utility.getRecordTypeIdByDeveloperName(Case.SObjectType, 'Incident');
        Case Case1 = new Case();
        Case1.Category__c = 'Beneficiary Lifecycle Mangement';
        Case1.Sub_Category__c = 'Beneficiary Transfer';
        Case1.Route_To__c = FO.id;
        Case1.Origin= 'Email';
        Case1.Impact__c = 'High';
        Case1.Severity__c = 'High';
        Case1.Priority = 'Medium';
        Case1.RecordTypeid = CaseRecTypeId;
        CaseList.add(Case1);
        return CaseList;
    }
    
    /**
    * Method name  : ConTestData
    * Description  : This method creates Test Data for Contacts for Lead
    * Return Type  : list<Contact>
    * Parameter    : list<Lead>
    **/
    public static list<Contact> ConTestData(list<Lead> LeadList)
    {
        list<Contact> ConList = new list<Contact>();
        list<Lead> LeadId = [select id, Name from Lead where id in: LeadList];
        Contact c = new Contact();
        c.FirstName = 'Ken';
        c.LastName = 'Adams';
        c.Lead__c = LeadId[0].id;
        ConList.add(c);
        Contact c1 = new Contact();
        c1.FirstName = 'Regina';
        c1.LastName = 'Filange';
        c1.Lead__c = LeadId[1].id;
        ConList.add(c1);
        return ConList;
    }
    
    /**
    * Method name  : ContentTestData
    * Description  : This method creates Test Data for Contents for Lead
    * Return Type  : list<Content__c>
    * Parameter    : list<Lead>
    **/
    public static list<Content__c> ContentTestData(list<Lead> LeadList)
    {
        list<Content__c> CtList = new list<Content__c>();
        list<Lead> LeadId = [select id, Name from Lead where id in: LeadList];
        Id RecTypeId = Utility.getRecordTypeIdByDeveloperName(Content__c.SObjectType,Constants.ICP_LEAD_RT_API_NAME);
        Content__c c = new Content__c();
        c.Content_Type__c = 'Lead Letter of Intent';
        c.Content_Download_Type__c = 'Image';
        c.ICP_Lead__c = LeadId[0].id;
        c.RecordTypeId = RecTypeId; 
        CtList.add(c);
        Content__c c1 = new Content__c();
        c1.Content_Type__c = 'Lead Letter of Intent';
        c1.ICP_Lead__c = LeadId[1].id;
        c1.RecordTypeId = RecTypeId; 
        CtList.add(c1);
        return CtList;
    }
    
    /**
    * Method name  : APTestData
    * Description  : This method creates Test Data for Activity Plan
    * Return Type  : list<Activity_Plan__c>
    * Parameter    : list<Account> , list<Contact>, User
    **/
    public static list<Activity_Plan__c> APTestData(list<Account> ICPList,  User User1)
    {
        list<Activity_Plan__c> apList = new list<Activity_Plan__c>();
        list<Account> icp = [select id, Name from Account where id in: ICPList];
        //list<Contact> con = [select id, Name from Contact where id in: ConList];
        Id OperationalPlanRecTypeId = Utility.getRecordTypeIdByDeveloperName(Activity_Plan__c.SObjectType, Constants.OPERATIONAL_PLAN_RT_API_NAME);
        Id SetUpPlanRecTypeId = Utility.getRecordTypeIdByDeveloperName(Activity_Plan__c.SObjectType, Constants.SETUP_PLAN_RT_API_NAME);
        Id facilitationWorkplanRecTypeId = Utility.getRecordTypeIdByDeveloperName(Activity_PLan__c.SObjectType,
            Constants.ACTIVITY_PLAN_FW_RT_API_NAME);
        /*Activity_Plan__c oOperationalPlan = new Activity_Plan__c();
        oOperationalPlan.Name = 'Operational Plan';
        oOperationalPlan.ICP__c = icp[0].id;
        oOperationalPlan.Operational_Plan_Start_Date__c = System.today();
        oOperationalPlan.RecordTypeId = OperationalPlanRecTypeId; 
        oOperationalPlan.ICP_Representative__c = con[0].id;
        oOperationalPlan.Partnership_Facilitator__c = User1.id;
        apList.add(oOperationalPlan);*/
        Activity_Plan__c oSetUpPlan = new Activity_Plan__c();
        oSetUpPlan.Name = 'Set Up Plan';
        oSetUpPlan.ICP__c = icp[0].id;
        oSetUpPlan.Set_Up_Plan_Target_Date__c = System.today();
        oSetUpPlan.Plan__c = 'Test Plan for Test Class';
        oSetUpPlan.RecordTypeId = SetUpPlanRecTypeId; 
        apList.add(oSetUpPlan);
        Activity_Plan__c oFacilitationWorkPlan = new Activity_Plan__c();
        oFacilitationWorkPlan.Name = 'Facilitation Plan';
        oFacilitationWorkPlan.ICP__c = icp[0].id;
        oFacilitationWorkPlan.Workplan_End_Date__c = System.today();
        oFacilitationWorkPlan.RecordTypeId = facilitationWorkplanRecTypeId ; 
        //oFacilitationWorkPlan.ICP_Representative__c = con[0].id;
        oFacilitationWorkPlan.Workplan_Start_Date__c = System.today();
        apList.add(oFacilitationWorkPlan);
        return apList;
    }
    
    /**
    * Method name  : ILETestData
    * Description  : This method creates Test Data for ICP Lifecycle Event 
    * Return Type  : list<ICP_Lifecycle_Events__c>
    * Parameter    : list<Account>
    **/
    public static list<ICP_Lifecycle_Events__c> ILETestData(list<Account> ICPList)
    {
        list<ICP_Lifecycle_Events__c> ILEList = new list<ICP_Lifecycle_Events__c>();
        list<Account> icp = [select id, Name from Account where id in: ICPList];
        Id icpLifecycleSuspensionRecTypeId = Utility.getRecordTypeIdByDeveloperName(ICP_Lifecycle_Events__c.SObjectType, Constants.SUSPENSION_RT_API_NAME);
        Id icpLifecycleTransitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(ICP_Lifecycle_Events__c.SObjectType,Constants.TRANSITION_ICP_LIFECYCLE_EVENTS_RT_API_NAME);
        Id icpLifecycleReactivationRecTypeId = Utility.getRecordTypeIdByDeveloperName(ICP_Lifecycle_Events__c.SObjectType,Constants.REACTIVATION_ICP_LIFECYCLE_EVENTS_RT_API_NAME);
        ICP_Lifecycle_Events__c suspension = new ICP_Lifecycle_Events__c();
        suspension.ICP__c = icp[0].id;
        suspension.Suspension_Start_Date__c = System.today();
        suspension.RecordTypeId = icpLifecycleSuspensionRecTypeId; 
        suspension.Suspension_Reasons__c = 'Disaster event';
        ILEList.add(suspension);
        ICP_Lifecycle_Events__c transition = new ICP_Lifecycle_Events__c();
        transition.ICP__c = icp[1].id;
        transition.Projected_Transition_Date__c = System.today();
        transition.RecordTypeId = icpLifecycleTransitionRecTypeId ; 
        transition.Reason_For_Transition__c = 'Disaster event';
        transition.Status__c = 'Pending Approval';
        ILEList.add(transition);
        ICP_Lifecycle_Events__c reactivation = new ICP_Lifecycle_Events__c();
        reactivation.ICP__c = icp[0].id;
        reactivation.Reactivation_Date__c = System.today();
        reactivation.RecordTypeId = icpLifecycleReactivationRecTypeId ; 
        reactivation.Describe_ICP_Improvement__c = 'Disaster event';
        ILEList.add(reactivation);
        ICP_Lifecycle_Events__c transition1 = new ICP_Lifecycle_Events__c();
        transition1.ICP__c = icp[0].id;
        transition1.Projected_Transition_Date__c = System.today();
        transition1.RecordTypeId = icpLifecycleTransitionRecTypeId ; 
        transition1.Reason_For_Transition__c = 'Disaster event';
        transition1.Status__c = 'Approved';
        ILEList.add(transition1);        
        return ILEList;
    }
    
    /**
    * Method name  : RankingAdministrationTestData
    * Description  : This method creates Test Data for Ranking Administration 
    * Return Type  : list<Ranking_Administration__c>
    * Parameter    : list<Account>
    **/
    public static list<Ranking_Administration__c> RankingAdministrationTestData(list<Account> FOList)
    {
        list<Ranking_Administration__c> RankingAdministrationList = new list<Ranking_Administration__c>();
        list<Account> FO = [select id, Name from Account where id in: FOList];
        Ranking_Administration__c RA = new Ranking_Administration__c();
        RA.Field_Office__c = FO[0].id;
        RA.Statement_Of_Faith_Compatibility__c = 60;
        RA.Commitment_To_Child_Ministry__c = 20;
        RA.Location__c = 20;
        RA.Legal_Registration__c = 20;
        RA.Physical_Environment__c = 10;
        RA.Child_Enrollment_Capacity__c = 20;
        RA.Commitment_To_Recruiting_Christians__c = 20;
        RA.Commitment_To_Use_Local_Resources__c = 20;
        RA.Denomination__c = 10;
        RankingAdministrationList.add(RA);
        return RankingAdministrationList;
    }
    
    /**
    * Method name  : HouseholdTestData
    * Description  : This method creates Test Data for Household
    * Return Type  : list<Household__c>
    * Parameter    : void
    **/
    public static list<Household__c> HouseholdTestData()
    {
        list<Household__c> lstHousehold = new list<Household__c>();
        Household__c household = new Household__c();
        household.Name = 'Household';
        household.Natural_Father_IsAlive__c = 'Yes';
        lstHousehold.add(household);
        return lstHousehold;
    }
    
    /**
    * Method name  : HouseholdMemberTestData
    * Description  : This method creates Test Data for Household Member
    * Return Type  : list<Household_Member__c>
    * Parameter    : list<Household__c>
    **/
    public static list<Household_Member__c> HouseholdMemberTestData(list<Household__c> lstHousehold)
    {
        list<Household_Member__c> lstHouseholdMember = new list<Household_Member__c>();
        list<Household__c> lstHouseholdM = [select id, Name from Household__c where id in: lstHousehold];
        Household_Member__c householdMember = new Household_Member__c();
        householdMember.Household__c = lstHousehold[0].id;
        householdMember.Role__c = 'Mother';
        householdMember.Is_Caregiver__c = true;
        householdMember.Is_Primary_Caregiver__c = true;
        lstHouseholdMember.add(householdMember);
        return lstHouseholdMember;
    }
    /* Added By Jeevan - To create Region PM Hiearchy */
    
    public static list<PM_Hierarchy__c> regionTestData(list<String> regionList)
    {
        List<PM_Hierarchy__c> regions = new List<PM_Hierarchy__c> () ; 
        for(String region : regionlist){
            regions.add( new PM_Hierarchy__c( Name = region , recordtypeID = Utility.getRecordTypeIdByDeveloperName(PM_Hierarchy__c.SObjectType, 'Region'))) ; 
        } 
        return regions;  
    }
    
    /* Added By Jeevan - To create territory PM Hiearchy */
    
    public static list<PM_Hierarchy__c> territoryTestData(list<String> territoryList)
    {
        List<PM_Hierarchy__c> territories = new List<PM_Hierarchy__c> () ; 
        for(String territory : territoryList){
            territories.add( new PM_Hierarchy__c( Name = territory , recordtypeID = Utility.getRecordTypeIdByDeveloperName(PM_Hierarchy__c.SObjectType,'Territory'))) ; 
        } 
        return territories;  
    } 
    
    /* Added By Jeevan - To create cluster PM Hiearchy */
    
    public static list<PM_Hierarchy__c> clusterTestData(list<String> clusterList)
    {
        List<PM_Hierarchy__c> clusters = new List<PM_Hierarchy__c> () ; 
        for(String cluster : clusterList){
            clusters.add( new PM_Hierarchy__c( Name = cluster , recordtypeID = Utility.getRecordTypeIdByDeveloperName(PM_Hierarchy__c.SObjectType, 'Cluster'))) ; 
        } 
        return clusters;  
    }
    
    /* Added By Jeevan - to create Field office */ 
    public static list<Account> FieldofficeTestData(list<String> FieldOfficeNames)
    {
        List<Account> accList = new List<Account> () ; 
        for(String NameFO : FieldOfficeNames){
            accList.add( new Account( Name = NameFO , recordtypeID = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.FIELD_OFFICE_RT_API_NAME))) ; 
        } 
        return accList;  
    }
    
    /* Added By Jeevan - to create FO Administrator for Beneficiary office */ 
    public static list<FO_Administration__c> FOAdministratorBOTestData(list<String> FieldOfficeAdminNames)
    {
        List<FO_Administration__c> FieldOfficeAdminList = new List<FO_Administration__c> () ; 
        for(String NameFO : FieldOfficeAdminNames){
            FieldOfficeAdminList.add( new FO_Administration__c(Needs_Association__c = 'ICP Association' , recordtypeID = Utility.getRecordTypeIdByDeveloperName(FO_Administration__c.SObjectType, Constants.FO_ADMINISTRATION_NEEDS_ADMIN_RT_API_NAME))) ; 
        } 
        return FieldOfficeAdminList;  
    }
    
     /* Added By Jeevan - to create ICP TESTDATA  */ 
    public static Account ICPTestData()
    {
       Account ICP = new Account (Name = 'Test ICP data' , ICP_Id__c = 'TD157', ICP_status__c='Active' ,RecordtypeID = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.ICP_RT_API_NAME) , BillingCountry = 'Ethiopia',
                                  BillingStreet = '12345 Main Street' , BillingCity = 'Guyaquil') ;
       return ICP ; 
    }
    
     /* Added By Jeevan - to create Beneficiary Assemrnts TEST DATA */ 
    public static Beneficiary_Assessment__c BenficiaryAssmntTestData()
    {
       Beneficiary_Assessment__c benAssmntTestData = new Beneficiary_Assessment__c(Name = 'TestBenAssmentData' , Assessment_Completion_Date__c = System.Today() , Height__c = 55 ,
                                                                                     Next_Assessment_Due_Date__c = System.today().AddDays(2) , Physical_Outcome_Score__c = 'Meets Expectations' ,
                                                                                     Cognitive_Outcome_Score__c = 'Meets Expectations' , Socio_emotional_Outcome_Score__c = 'Meets Expectations' , 
                                                                                     Spiritual_Outcome_Score__c = 'Meets Expectations' , recordtypeId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Assessment__c.SObjectType,Constants.CDPR_BA_RT_API_NAME)) ; 
       return benAssmntTestData ; 
    }
    
    // to create test data for globalData - Ranking ADministrator
     Public  static Global_Data__c globalDataRanking(String dName, String FieldName , String FieldValue ,Decimal FieldWeight ) { 
        Global_Data__c glData = new Global_Data__c(Name = dName , Field_Name__c = FieldName  , Field_Value__c = FieldValue  ,
                                                     RecordtypeID = Utility.getRecordTypeIdByDeveloperName(Global_Data__c.SObjectType, Constants.GLOBAL_DATA_RANKING_DATA_RT_API_NAME) , Field_Weight__c = FieldWeight) ; 
        return glData ; 
    }
    
    // to create global data - CDPR ..  
    Public  static Global_Data__c globalDataCDPR(String dName , String Indicator , String outComeArea , String Outcome) { 
        Global_Data__c glData = new Global_Data__c( Name = dName  , Indicator__c = Indicator , RecordtypeID = Utility.getRecordTypeIdByDeveloperName(Global_Data__c.SObjectType, Constants.GLOBAL_DATA_CDPR_INDICATORS_RT_API_NAME) , Outcome_Area__c = outComeArea , Outcome__c  = Outcome) ; 
        return glData ; 
    }
    
     /**
    * Method name  : globalDataNeeds
    * Description  : This method creates Test Data for globalData Need type 
    * Return Type  : Needs_Association__c 
    * Parameter    : ID , String , Boolean , String , Date , String 
    **/
    Public  static Global_Data__c globalDataNeeds(String dName , String NeedType, String needCategory) { 
        Global_Data__c glData = new Global_Data__c( Name = dName  , Need_Type__c= NeedType , RecordtypeID = Utility.getRecordTypeIdByDeveloperName(Global_Data__c.SObjectType, Constants.GLOBAL_DATA_NEEDS_DATA_RT_API_NAME) , Need_Category__c = needCategory) ; 
        return glData ; 
    }
    
    /**
    * Method name  : globalDataFrequency
    * Description  : This method creates Test Data for globalData Need type 
    * Return Type  : Needs_Association__c 
    * Parameter    : ID , String , Boolean , String , Date , String 
    **/
    Public  static Global_Data__c globalDataFrequency(String dName , Integer frequency) { 
        Global_Data__c glData = new Global_Data__c( Name = dName  , Beneficiary_Assessment_Frequency__c = frequency , RecordtypeID = Utility.getRecordTypeIdByDeveloperName(Global_Data__c.SObjectType, Constants.GLOBAL_DATA_GLOBAL_FREQUENCIES_RT_API_NAME)) ; 
        return glData ; 
    }
    
    // to create Response data 
    
    Public static Responses__c ResponsTestData(string comment , String points , String progressMeasure , String progMesDescp , String status) {
    
        Responses__c resTestData = new Responses__c(Comments__c = comment  , points__c = points  ,Progress_Measure__c = progressMeasure  , Progress_Measure_Description__c = progMesDescp  , Status__c = status) ; 
        return resTestData ;    
    }
    
    /**
    * Method name  : globalDataMalnutritionData
    * Description  : This method creates Test Data for globalData Malnutrition Data
    * Return Type  : Global_Data__c 
    * Parameter    : NA 
    **/
    Public  static Global_Data__c globalDataMalnutritionData() { 
        Global_Data__c glMlData = new Global_Data__c( Name = 'Malnutrition Data', Malnutrition_Data_Type__c = 'HFA', Age_In_Months__c = 228.00, Gender__c = 'Male', SD1neg__c = 169.245000, SD2neg__c = 161.947000, SD3neg__c = 154.648000, L__c = 1.000000, M__c = 176.543200, S__c = 0.041340, SD__c = 7.298300, SD0__c = 176.543000, SD1__c = 183.841000, SD2__c = 191.140000, SD3__c = 198.438000, RecordtypeID = Utility.getRecordTypeIdByDeveloperName(Global_Data__c.SObjectType, Constants.GLOBAL_DATA_GLOBAL_MALNUTRITION_DATA_RT_API_NAME)) ; 
        return glMlData ; 
    }    
     
     /**
    * Method name  : NeedsAssociationTestData 
    * Description  : This method creates Test Data for Needs Association  
    * Return Type  : Needs_Association__c 
    * Parameter    : ID , String , Boolean , String , Date , String 
    **/
    
    Public static Needs_Association__c  NeedsAssociationTestData(ID accID , string associateType , Boolean fulfilled  , String fulfilledBy , Date dte , String severity) 
    {
    

        Needs_Association__c needAsscoTestData = new Needs_Association__c(Account__c = accID , Association_Type__c = associateType  , Fulfilled__c = fulfilled , Fulfilled_By__c = fulfilledBy , Fulfillment_Date__c = dte , Severity__c = severity) ; 
        return needAsscoTestData ;      
    }
    /**
    * Method name  : Monthly Class Schedule DATA 
    * Description  : This method creates Test Data for Monthly Class Schedule  
    * Return Type  : Monthly_Class_Schedule__c 
    * Parameter    : Decimal ,String , String 
    **/
    Public static Monthly_Class_Schedule__c MonthlyClassScheduleTestData(Decimal year, string month , String ageGrp) 
    {
        //Monthly_Class_Schedule__c monClassScheduleTestData = new Monthly_Class_Schedule__c(Year__c  = year , Month__c = Month , Cognitive_Age_Group__c = ageGrp) ;     
        return null;//monClassScheduleTestData ;
    }
    
    /**
    * Method name  : ContactTestData 
    * Description  : This method creates Test Data for ContactTestData 
    * Return Type  : Contact 
    * Parameter    : String 
    **/
    Public static Contact ContactTestData (String LastName) 
    {
        Contact conTestData = new Contact(LastName = LastName) ; 
        return conTestData ;
    }
    /**
    * Method name  : ContactTestData 
    * Description  : This method creates Test Data for ContactTestData 
    * Return Type  : Beneficiary_Class_Attendance__c
    * Parameter    : String 
    **/
    Public static Beneficiary_Class_Attendance__c BeneficiaryClassAttendanceTestData (ID accountID , ID monthlyclassScheduleID) 
    {
        //Beneficiary_Class_Attendance__c  BenClassAttendanceTestData = new Beneficiary_Class_Attendance__c(Beneficiary__c = accountID  , Monthly_Class_Schedule__c = monthlyclassScheduleID) ; 
        return null;//BenClassAttendanceTestData  ;
    }
    
    /**
    * Method name  : ContactTestData 
    * Description  : This method creates Test Data for ContactTestData 
    * Return Type  : Beneficiary_Class_Attendance__c
    * Parameter    : String 
    **/
    Public static Beneficiary_Assessment__c BeneficiaryHealthAssessmentTestData(String sName , ID accountID , Integer iHeight , Integer iweight) 
    {
        Beneficiary_Assessment__c  oBeneficiaryHealthAssessmentData = new Beneficiary_Assessment__c(Name = sName , Beneficiary__c = accountID  , Assessment_Completion_Date__c = system.Today() , Height__c = iHeight , Weight__c = iweight) ; 
        return oBeneficiaryHealthAssessmentData  ;
    }
    
    /**
    * Method name  : ContentTestData
    * Description  : This method creates Test Data for Contents for Account
    * Return Type  : list<Content__c>
    * Parameter    : list<Account>
    **/
    public static list<Content__c> ContentTestData(list<Account> lstAcc)
    {
        list<Content__c> lstContent = new list<Content__c>();
        //list<Account> lstAccount = [select id, Name from Account where id in: lstAcc];
        Id recTypeId = Utility.getRecordTypeIdByDeveloperName(Content__c.SObjectType,Constants.BEN_API_NAME);
        Content__c oCont = new Content__c();
        oCont.Content_Type__c = 'Account Letter of Intent';
        oCont.Beneficiary__c = lstAcc[0].id;
        oCont.RecordTypeId = recTypeId; 
        lstContent.add(oCont);
        Content__c oContent = new Content__c();
        oContent.Content_Type__c = 'Account Letter of Intent';
        oContent.Beneficiary__c = lstAcc[1].id;
        oContent.RecordTypeId = recTypeId; 
        lstContent.add(oContent);
        return lstContent;
    }
    
    /**
    * Method name  : yearlyClassScheduleTestData
    * Description  : This method creates Test Data for Yearly Class Schedule of Beneficiary
    * Return Type  : Yearly_Class_Schedule__c
    * Parameter    : Account , Contact
    **/
    public static Yearly_Class_Schedule__c yearlyClassScheduleTestData(Account oICPAccount, Contact oContact) {
        Yearly_Class_Schedule__c oTestData = new Yearly_Class_Schedule__c (  BEN_Cognitive_Age_Group__c = '0-2' , Tutor__c = oContact.ID , 
                                            ICP_Name__c =  oICPAccount.ID , Class_Type__c = 'Center-Based Class' , Starting_Month__c = 'Dec' , 
                                            Year__c = '2015') ; 
        return oTestData;
    }
    
    /**
    * Method name  : monthlyClassScheduleTestData
    * Description  : This method creates Test Data for Monthly Class Schedule of Beneficiary
    * Return Type  : Monthly_Class_Schedule__c
    * Parameter    : Yearly_Class_Schedule__c
    **/
    public static Monthly_Class_Schedule__c monthlyClassScheduleTestData(Yearly_Class_Schedule__c oYearlyClass) {
        Monthly_Class_Schedule__c oMonthlyClassSchedule= new Monthly_Class_Schedule__c(BEN_Cognitive_Age_Group__c = '0-2',Yearly_Class__c=oYearlyClass.id);
        return oMonthlyClassSchedule;
    }
    
    /**
    * Method name  : beneficiaryClassAssociationTestData
    * Description  : This method creates Test Data for Monthly Class Schedule of Beneficiary
    * Return Type  : Beneficiary_Class_Association__c
    * Parameter    : Monthly_Class_Schedule__c
    **/
    public static Beneficiary_Class_Association__c beneficiaryClassAssociationTestData(Account oBenef, Monthly_Class_Schedule__c oMonthlySchedule) {
        Beneficiary_Class_Association__c oClassAssoc = new Beneficiary_Class_Association__c(BEN_Id__c = oBenef.id, Monthly_Class_Schedule__c = oMonthlySchedule.id);
        return oClassAssoc;
    }
    
    /**
    * Method name  : ContentTestDataSameAccount
    * Description  : This method creates Test Data for Contents for Same account
    * Return Type  : list<Content__c>
    * Parameter    : list<Account>
    **/
    public static list<Content__c> ContentTestDataSameAccount(Account acc)
    {
        list<Content__c> lstContent = new list<Content__c>();
        Id recTypeId = Utility.getRecordTypeIdByDeveloperName(Content__c.SObjectType,Constants.BEN_API_NAME);
        Content__c oCont = new Content__c();
        oCont.Content_Type__c = 'Photo - Beneficiary Full Body';
        oCont.Beneficiary__c = acc.id;
        oCont.RecordTypeId = recTypeId; 
        lstContent.add(oCont);
        Content__c oContent = new Content__c();
        oContent.Content_Type__c = 'Photo - Beneficiary Full Body';
        oContent.Beneficiary__c = acc.id;
        oContent.RecordTypeId = recTypeId; 
        lstContent.add(oContent);
        return lstContent;
    }
    
    /**
    * Method name  : addressTestData
    * Description  : This method creates Test Data for Address related to Lead
    * Return Type  : list<Content__c>
    * Parameter    : list<Account>
    **/
    public static Address__c addressTestData(Id leadId)
    {
        Id icpAddressRecTypeId = Utility.getRecordTypeIdByDeveloperName(Address__c.SObjectType,
        Constants.ICP_ADDRESS_RT_API_NAME);
        Address__c oAddress = new Address__c();
        oAddress.Lead__c = leadId;
        oAddress.City__c = 'NY';
        oAddress.Street__c = '123';
        oAddress.Country__c = 'USA';
        oAddress.State__c = 'NY';
        oAddress.Zip_Code__c = '11111';
        oAddress.Status__c = 'Active';
        oAddress.Address_Type__c = 'Mail Address';
        oAddress.RecordTypeId = icpAddressRecTypeId;
        return oAddress;
    }
      /**
    * Method name  : jsonProcessTestData
    * Description  : This method creates Test Data for JSON Process
    * Return Type  : JSON_Process__c
    * Parameter    : String,String,Boolean
    **/
    public static JSON_Process__c jsonProcessTestData(String sJsonProcessName,String sArrayTokenName,Boolean bIsInitialArray)
    {
        JSON_Process__c oJsonProcess = new JSON_Process__c();
        oJsonProcess.Name = sJsonProcessName;
        oJsonProcess.Array_Token_Name__c = sArrayTokenName;
        oJsonProcess.Is_initial_Array__c = bIsInitialArray;
        return oJsonProcess;
    }
     /**
    * Method name  : fieldGroupTestData
    * Description  : This method creates Test Data for Field Group
    * Return Type  : Field_Group__c
    * Parameter    : String,String
    **/
    public static Field_Group__c fieldGroupTestData(String sFieldGroupName,String sObjectAPIName)
    {
        Field_Group__c oFieldGroup = new Field_Group__c();
        oFieldGroup.Name = sFieldGroupName;
        oFieldGroup.Object_API_Name__c = sObjectAPIName;
        return oFieldGroup;
    }
       /**
    * Method name  : jsonStructureTestData
    * Description  : This method creates Test Data for Json Structure
    * Return Type  : JSON_Structure__c
    * Parameter    : String,String,Id,Boolean,Id
    **/
    public static JSON_Structure__c jsonStructureTestData(String sArrayTokenName,Id fieldGroupId,Boolean bIsArray,Id jsonProcessId)
    {
        JSON_Structure__c oJsonStructure = new JSON_Structure__c();
        oJsonStructure.Array_Token_Name__c = sArrayTokenName;
        oJsonStructure.Field_Group__c = fieldGroupId;
        oJsonStructure.is_Array__c = bIsArray;
        oJsonStructure.JSON_Process__c = jsonProcessId;
        return oJsonStructure;
    }
    /**
    * Method name  : contentfieldGroupElementTestData
    * Description  : This method creates Test Data for Content Field Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : String
    **/
    public static List<Field_Group_Element__c> contentfieldGroupElementTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c();
        oFGE1.Field_API_Name__c = 'Id';
        oFGE1.Field_Group__c = fieldGroupId;
        oFGE1.Field_Type__c = 'TEXT';
        oFGE1.JSON_Order__c = 1;
        oFGE1.Token_Name__c = 'ContentID';
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c();
        oFGE2.Field_API_Name__c = 'Beneficiary__c';
        oFGE2.Field_Group__c = fieldGroupId;
        oFGE2.Field_Type__c = 'TEXT';
        oFGE2.JSON_Order__c = 2;
        oFGE2.Token_Name__c = 'ParentID';
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c();
        oFGE3.Field_API_Name__c = 'AttachmentDT__c';
        oFGE3.Field_Group__c = fieldGroupId;
        oFGE3.Field_Type__c = 'DATE';
        oFGE3.JSON_Order__c = 3;
        oFGE3.Token_Name__c = 'CaptureDT';
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c();
        oFGE4.Field_API_Name__c = 'Content_Type__c';
        oFGE4.Field_Group__c = fieldGroupId;
        oFGE4.Field_Type__c = 'TEXT';
        oFGE4.JSON_Order__c = 4;
        oFGE4.Token_Name__c = 'DocumentType';
        lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c();
        oFGE5.Field_API_Name__c = 'Content_Link__c';
        oFGE5.Field_Group__c = fieldGroupId;
        oFGE5.Field_Type__c = 'TEXT';
        oFGE5.JSON_Order__c = 5;
        oFGE5.Token_Name__c = 'PerceptiveURI';
        lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c();
        oFGE6.Field_API_Name__c = 'AttachmentId__c';
        oFGE6.Field_Group__c = fieldGroupId;
        oFGE6.Field_Type__c = 'TEXT';
        oFGE6.JSON_Order__c = 6;
        oFGE6.Token_Name__c = 'AttachmentID';
        lstFGE.add(oFGE6);
        Field_Group_Element__c oFGE7 = new Field_Group_Element__c();
        oFGE7.Field_API_Name__c = 'Comments__c';
        oFGE7.Field_Group__c = fieldGroupId;
        oFGE7.Field_Type__c = 'TEXT';
        oFGE7.JSON_Order__c = 7;
        oFGE7.Token_Name__c = 'ChildKey';
        lstFGE.add(oFGE7);
        return lstFGE;
    }
     /**
    * Method name  : createBeneficiaryFieldGroupElementTestData
    * Description  : This method creates Test Data for Content Field Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : String
    **/
    public static List<Field_Group_Element__c> createBeneficiaryFieldGroupElementTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE = new Field_Group_Element__c();
        oFGE.Field_API_Name__c = 'Known_Complications__c';
        oFGE.Field_Group__c = fieldGroupId;
        oFGE.Field_Type__c = 'TEXT';
        oFGE.JSON_Order__c = NULL;
        oFGE.Token_Name__c = 'CaregiverName';
        lstFGE.add(oFGE);
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c();
        oFGE1.Field_API_Name__c = 'LastName';
        oFGE1.Field_Group__c = fieldGroupId;
        oFGE1.Field_Type__c = 'TEXT';
        oFGE1.JSON_Order__c = 1;
        oFGE1.Token_Name__c = 'AccountName';
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c();
        oFGE2.Field_API_Name__c = 'Educational_Description_Context_Needs__c';
        oFGE2.Field_Group__c = fieldGroupId;
        oFGE2.Field_Type__c = 'TEXT';
        oFGE2.JSON_Order__c = 2;
        oFGE2.Token_Name__c = 'AccountRecordType';
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c();
        oFGE3.Field_API_Name__c = 'Active_Program__c';
        oFGE3.Field_Group__c = fieldGroupId;
        oFGE3.Field_Type__c = 'TEXT';
        oFGE3.JSON_Order__c = 3;
        oFGE3.Token_Name__c = 'ActiveProgram';
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c();
        oFGE4.Field_API_Name__c = 'CDSP_Type__c';
        oFGE4.Field_Group__c = fieldGroupId;
        oFGE4.Field_Type__c = 'TEXT';
        oFGE4.JSON_Order__c = 4;
        oFGE4.Token_Name__c = 'CDSPType';
        lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c();
        oFGE5.Field_API_Name__c = 'Actual_First_Attendance_Date__c';
        oFGE5.Field_Group__c = fieldGroupId;
        oFGE5.Field_Type__c = 'DATE';
        oFGE5.JSON_Order__c = 5;
        oFGE5.Token_Name__c = 'ActualFirstAttendanceDate';
        lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c();
        oFGE6.Field_API_Name__c = 'Actual_Registration_Date__c';
        oFGE6.Field_Group__c = fieldGroupId;
        oFGE6.Field_Type__c = 'DATE';
        oFGE6.JSON_Order__c = 6;
        oFGE6.Token_Name__c = 'ActualRegistrationDate';
        lstFGE.add(oFGE6);
        Field_Group_Element__c oFGE7 = new Field_Group_Element__c(
        Field_API_Name__c = 'Agreement_Renewal_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 7,Token_Name__c ='AgreementRenewalDate');
        lstFGE.add(oFGE7);
        Field_Group_Element__c oFGE8 = new Field_Group_Element__c(
        Field_API_Name__c = 'Agreement_Signed_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 8,Token_Name__c ='AgreementSignedDate');
        lstFGE.add(oFGE8);
        Field_Group_Element__c oFGE9 = new Field_Group_Element__c(
        Field_API_Name__c = 'Alternate_Address_Expiry_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 9,Token_Name__c ='AlternateAddressExpiryDate');
        lstFGE.add(oFGE9);
        Field_Group_Element__c oFGE92 = new Field_Group_Element__c();
        oFGE92.Field_API_Name__c = 'Estimated_Birthdate__c';
        oFGE92.Field_Group__c = fieldGroupId;
        oFGE92.Field_Type__c = 'BOOLEAN';
        oFGE92.JSON_Order__c = 91;
        oFGE92.Token_Name__c = 'EstimatedBirthDate';
        lstFGE.add(oFGE92);     
        Field_Group_Element__c oFGE91 = new Field_Group_Element__c();
        oFGE91.Field_API_Name__c = 'Education_Level__c';
        oFGE91.Field_Group__c = fieldGroupId;
        oFGE91.Field_Type__c = 'TEXT';
        oFGE91.JSON_Order__c = 92;
        oFGE91.Token_Name__c = 'EducationLevel';
        lstFGE.add(oFGE91); 
        Field_Group_Element__c oFGE90 = new Field_Group_Element__c();
        oFGE90.Field_API_Name__c = 'Favorite_Subject_in_School__c';
        oFGE90.Field_Group__c = fieldGroupId;
        oFGE90.Field_Type__c = 'TEXT';
        oFGE90.JSON_Order__c = 90;
        oFGE90.Token_Name__c = 'FavoriteSubjectsInSchool';
        lstFGE.add(oFGE90); 
        Field_Group_Element__c oFGE89 = new Field_Group_Element__c();
        oFGE89.Field_API_Name__c = 'Times_Of_Hunger__c';
        oFGE89.Field_Group__c = fieldGroupId;
        oFGE89.Field_Type__c = 'TEXT';
        oFGE89.JSON_Order__c = 89;
        oFGE89.Token_Name__c = 'HungerMonths';
        lstFGE.add(oFGE89); 
        Field_Group_Element__c oFGE88 = new Field_Group_Element__c();
        oFGE88.Field_API_Name__c = 'Harvest_Seasons__c';
        oFGE88.Field_Group__c = fieldGroupId;
        oFGE88.Field_Type__c = 'TEXT';
        oFGE88.JSON_Order__c = 88;
        oFGE88.Token_Name__c = 'HarvestMonths';
        lstFGE.add(oFGE88); 
        Field_Group_Element__c oFGE87 = new Field_Group_Element__c();
        oFGE87.Field_API_Name__c = 'Not_Enrolled_In_Education_Reason__c';
        oFGE87.Field_Group__c = fieldGroupId;
        oFGE87.Field_Type__c = 'TEXT';
        oFGE87.JSON_Order__c = 87;
        oFGE87.Token_Name__c = 'ReasonNotAttendingSchool';
        lstFGE.add(oFGE87); 
        Field_Group_Element__c oFGE86 = new Field_Group_Element__c();
        oFGE86.Field_API_Name__c = 'BEN_Educational_Assessment__c';
        oFGE86.Field_Group__c = fieldGroupId;
        oFGE86.Field_Type__c = 'TEXT';
        oFGE86.JSON_Order__c = 86;
        oFGE86.Token_Name__c = 'AcademicPerformance';
        lstFGE.add(oFGE86);     
        Field_Group_Element__c oFGE85 = new Field_Group_Element__c();
        oFGE85.Field_API_Name__c = 'Country__c';
        oFGE85.Field_Group__c = fieldGroupId;
        oFGE85.Field_Type__c = 'TEXT';
        oFGE85.JSON_Order__c = 85;
        oFGE85.Token_Name__c = 'Country';
        lstFGE.add(oFGE85); 
        Field_Group_Element__c oFGE84 = new Field_Group_Element__c();
        oFGE84.Field_API_Name__c = 'Primary_Language__c';
        oFGE84.Field_Group__c = fieldGroupId;
        oFGE84.Field_Type__c = 'TEXT';
        oFGE84.JSON_Order__c = 84;
        oFGE84.Token_Name__c = 'NaturalMotherLivingWithChild';
        lstFGE.add(oFGE84); 
        Field_Group_Element__c oFGE83 = new Field_Group_Element__c();
        oFGE83.Field_API_Name__c = 'Travel_Time_To_Nearest_Medical_Facility__c';
        oFGE83.Field_Group__c = fieldGroupId;
        oFGE83.Field_Type__c = 'TEXT';
        oFGE83.JSON_Order__c = 83;
        oFGE83.Token_Name__c = 'NaturalFatherLivingWithChild';
        lstFGE.add(oFGE83);
        Field_Group_Element__c oFGE82 = new Field_Group_Element__c();
        oFGE82.Field_API_Name__c = 'Preferred_Name__pc';
        oFGE82.Field_Group__c = fieldGroupId;
        oFGE82.Field_Type__c = 'TEXT';
        oFGE82.JSON_Order__c = 82;
        oFGE82.Token_Name__c = 'PreferredName';
        lstFGE.add(oFGE82); 
        Field_Group_Element__c oFGE81 = new Field_Group_Element__c();
        oFGE81.Field_API_Name__c = 'Who_Attended_Birth__c';
        oFGE81.Field_Group__c = fieldGroupId;
        oFGE81.Field_Type__c = 'TEXT';
        oFGE81.JSON_Order__c = 81;
        oFGE81.Token_Name__c = 'ICPId';
        lstFGE.add(oFGE81); 
        Field_Group_Element__c oFGE80 = new Field_Group_Element__c();
        oFGE80.Field_API_Name__c = 'Local_Beneficiary_Number__c';
        oFGE80.Field_Group__c = fieldGroupId;
        oFGE80.Field_Type__c = 'TEXT';
        oFGE80.JSON_Order__c = 80;
        oFGE80.Token_Name__c = 'LocalBeneficiaryNumber';
        lstFGE.add(oFGE80);     
        Field_Group_Element__c oFGE79 = new Field_Group_Element__c(
        Field_API_Name__c = 'Locale__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 79,Token_Name__c ='TogetherNow');
        lstFGE.add(oFGE79);
        Field_Group_Element__c oFGE78 = new Field_Group_Element__c(
        Field_API_Name__c = 'Major_Or_Course_Of_Study__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 78,Token_Name__c ='MajorOrCourseOfStudy');
        lstFGE.add(oFGE78);
        Field_Group_Element__c oFGE77 = new Field_Group_Element__c(
        Field_API_Name__c = 'Type_Of_Vocational_Education__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 77,Token_Name__c ='TypeOfVocationalEducation');
        lstFGE.add(oFGE77);
        Field_Group_Element__c oFGE76 = new Field_Group_Element__c(
        Field_API_Name__c = 'Current_University_Year_Of_Study__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 76,Token_Name__c ='CurrentUniversityYearOfStudy');
        lstFGE.add(oFGE76);
        Field_Group_Element__c oFGE75 = new Field_Group_Element__c(
        Field_API_Name__c = 'Legal_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 75,Token_Name__c ='MaritalStatus');
        lstFGE.add(oFGE75);
        Field_Group_Element__c oFGE74 = new Field_Group_Element__c(
        Field_API_Name__c = 'Leadership_Style__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 74,Token_Name__c ='FemaleEmploymentStatus');
        lstFGE.add(oFGE74);
        Field_Group_Element__c oFGE73 = new Field_Group_Element__c(
        Field_API_Name__c = 'Building_Ownership__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 73,Token_Name__c ='MaleEmploymentStatus');
        lstFGE.add(oFGE73);
        Field_Group_Element__c oFGE72 = new Field_Group_Element__c(
        Field_API_Name__c = 'CDSP_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 72,Token_Name__c ='FemaleOccupation');
        lstFGE.add(oFGE72);
        Field_Group_Element__c oFGE71 = new Field_Group_Element__c(
        Field_API_Name__c = 'CGV_Pregnancy_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 71,Token_Name__c ='MaleOccupation');
        lstFGE.add(oFGE71);
        Field_Group_Element__c oFGE70 = new Field_Group_Element__c(
        Field_API_Name__c = 'Caregiver_HIV_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 70,Token_Name__c ='NaturalMotherIsAlive');
        lstFGE.add(oFGE70);
        Field_Group_Element__c oFGE69 = new Field_Group_Element__c(
        Field_API_Name__c = 'Breast_Feeding_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 69,Token_Name__c ='NaturalFatherIsAlive');
        lstFGE.add(oFGE69);
        Field_Group_Element__c oFGE66 = new Field_Group_Element__c(
        Field_API_Name__c = 'Local_Beneficiary_Id__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 66,Token_Name__c ='CompassChild');
        lstFGE.add(oFGE66);
        Field_Group_Element__c oFGE65 = new Field_Group_Element__c(
        Field_API_Name__c = 'Birth_Length_Cm__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DOUBLE',JSON_Order__c = 65,Token_Name__c ='BirthHeight');
        lstFGE.add(oFGE65);
        Field_Group_Element__c oFGE64 = new Field_Group_Element__c(
        Field_API_Name__c = 'Birth_Weight_Kg__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DOUBLE',JSON_Order__c = 64,Token_Name__c ='BirthWeight');
        lstFGE.add(oFGE64);
        Field_Group_Element__c oFGE63 = new Field_Group_Element__c(
        Field_API_Name__c = 'Weight_Kg__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DOUBLE',JSON_Order__c = 63,Token_Name__c ='WeightInKg');
        lstFGE.add(oFGE63);
        Field_Group_Element__c oFGE62 = new Field_Group_Element__c(
        Field_API_Name__c = 'External_Resources_Available__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 62,Token_Name__c ='TutorImplementerName');
        lstFGE.add(oFGE62);
        Field_Group_Element__c oFGE61 = new Field_Group_Element__c(
        Field_API_Name__c = 'Religious_Affiliation__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 61,Token_Name__c ='ReligiousAffiliation');
        lstFGE.add(oFGE61);
        Field_Group_Element__c oFGE60 = new Field_Group_Element__c(
        Field_API_Name__c = 'Program_Field_Manual_Exemption__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 60,Token_Name__c ='ProgramFieldManualExemption');
        lstFGE.add(oFGE60);     
        Field_Group_Element__c oFGE58 = new Field_Group_Element__c(
        Field_API_Name__c = 'Planned_Completion_Date_Change_Reason__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 58,Token_Name__c ='PlannedCompletionDateChangeReason');
        lstFGE.add(oFGE58);
        Field_Group_Element__c oFGE57 = new Field_Group_Element__c(
        Field_API_Name__c = 'Planned_Completion_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 57,Token_Name__c ='PlannedCompletionDate');
        lstFGE.add(oFGE57);
        Field_Group_Element__c oFGE56 = new Field_Group_Element__c(
        Field_API_Name__c = 'Phone',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 56,Token_Name__c ='Phone');
        lstFGE.add(oFGE56);     
        Field_Group_Element__c oFGE55 = new Field_Group_Element__c(
        Field_API_Name__c = 'Mental_Development_Conditions__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 55,Token_Name__c ='MentalDevelopmentConditions');
        lstFGE.add(oFGE55);
        Field_Group_Element__c oFGE54 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Last_Review_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 54,Token_Name__c ='LastReviewedDate');
        lstFGE.add(oFGE54);
        Field_Group_Element__c oFGE53 = new Field_Group_Element__c(
        Field_API_Name__c = 'Correspondence_Language__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 53,Token_Name__c ='Language');
        lstFGE.add(oFGE53);
        Field_Group_Element__c oFGE50 = new Field_Group_Element__c(
        Field_API_Name__c = 'Incident_Number__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 50,Token_Name__c ='IncidentNumber');
        lstFGE.add(oFGE50);
        Field_Group_Element__c oFGE49 = new Field_Group_Element__c(
        Field_API_Name__c = 'Incident_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 49,Token_Name__c ='IncidentDate');
        lstFGE.add(oFGE49);
        Field_Group_Element__c oFGE47 = new Field_Group_Element__c(
        Field_API_Name__c = 'Available_Courier_Services__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 47,Token_Name__c ='ICPName');
        lstFGE.add(oFGE47);     
        Field_Group_Element__c oFGE46 = new Field_Group_Element__c(
        Field_API_Name__c = 'CRCH_Project__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 46,Token_Name__c ='HouseholdName');
        lstFGE.add(oFGE46);
        Field_Group_Element__c oFGE44 = new Field_Group_Element__c(
        Field_API_Name__c = 'Height_Cm__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DOUBLE',JSON_Order__c = 44,Token_Name__c ='HeightInCm');
        lstFGE.add(oFGE44);     
        Field_Group_Element__c oFGE42 = new Field_Group_Element__c(
        Field_API_Name__c = 'Local_Grade_Level__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 42,Token_Name__c ='LocalGradeLevel');
        lstFGE.add(oFGE42);     
        Field_Group_Element__c oFGE41 = new Field_Group_Element__c(
        Field_API_Name__c = 'Gender__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 41,Token_Name__c ='Gender');
        lstFGE.add(oFGE41);
        Field_Group_Element__c oFGE40 = new Field_Group_Element__c(
        Field_API_Name__c = 'Formal_Education_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 40,Token_Name__c ='FormalEducationStatus');
        lstFGE.add(oFGE40);
        Field_Group_Element__c oFGE38 = new Field_Group_Element__c(
        Field_API_Name__c = 'Available_Banks__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 38,Token_Name__c ='ExistingBeneficiaryName');
        lstFGE.add(oFGE38);     
        Field_Group_Element__c oFGE37 = new Field_Group_Element__c(
        Field_API_Name__c = 'Physical_Disabilities__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 37,Token_Name__c ='Disabilities');
        lstFGE.add(oFGE37);     
        Field_Group_Element__c oFGE35 = new Field_Group_Element__c(
        Field_API_Name__c = 'Cognitive_Age_Group__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 35,Token_Name__c ='CognitiveAgeGroup');
        lstFGE.add(oFGE35);
        Field_Group_Element__c oFGE34 = new Field_Group_Element__c(
        Field_API_Name__c = 'Chronic_Illnesses__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 34,Token_Name__c ='ChronicIllness');
        lstFGE.add(oFGE34); 
        Field_Group_Element__c oFGE33 = new Field_Group_Element__c(
        Field_API_Name__c = 'Christian_Activities__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 33,Token_Name__c ='ChristianActivities');
        lstFGE.add(oFGE33);     
        Field_Group_Element__c oFGE31 = new Field_Group_Element__c(
        Field_API_Name__c = 'CSP_Tenure__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 31,Token_Name__c ='CSPTenure');
        lstFGE.add(oFGE31);     
        Field_Group_Element__c oFGE30 = new Field_Group_Element__c(
        Field_API_Name__c = 'CSP_Start_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 30,Token_Name__c ='CSPProgramStartDate');
        lstFGE.add(oFGE30);     
        Field_Group_Element__c oFGE29 = new Field_Group_Element__c(
        Field_API_Name__c = 'CSP_End_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 29,Token_Name__c ='CSPProgramEndDate');
        lstFGE.add(oFGE29);     
        Field_Group_Element__c oFGE28 = new Field_Group_Element__c(
        Field_API_Name__c = 'CDSP_Tenure__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 28,Token_Name__c ='CDSPTenure');
        lstFGE.add(oFGE28);     
        Field_Group_Element__c oFGE27 = new Field_Group_Element__c(
        Field_API_Name__c = 'CDSP_Start_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 27,Token_Name__c ='CDSPProgramStartDate');
        lstFGE.add(oFGE27);     
        Field_Group_Element__c oFGE26 = new Field_Group_Element__c(
        Field_API_Name__c = 'CDSP_End_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 26,Token_Name__c ='CDSPProgramEndDate');
        lstFGE.add(oFGE26);     
        Field_Group_Element__c oFGE22 = new Field_Group_Element__c(
        Field_API_Name__c = 'PersonBirthdate',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 22,Token_Name__c ='Birthdate');
        lstFGE.add(oFGE22);     
        Field_Group_Element__c oFGE21 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 21,Token_Name__c ='BeneficiaryStatus');
        lstFGE.add(oFGE21);     
        Field_Group_Element__c oFGE20 = new Field_Group_Element__c(
        Field_API_Name__c = 'Expected_Transition_Date_To_Sponsorship__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 20,Token_Name__c ='ExpectedTransitionDateToSponsorship');
        lstFGE.add(oFGE20);     
        Field_Group_Element__c oFGE19 = new Field_Group_Element__c(
        Field_API_Name__c = 'Expected_Transition_Date_To_Center__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 19,Token_Name__c ='ExpectedTransitionDateToCenter');
        lstFGE.add(oFGE19);     
        Field_Group_Element__c oFGE17 = new Field_Group_Element__c(
        Field_API_Name__c = 'Compass_Id__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 17,Token_Name__c ='COMPASSId');
        lstFGE.add(oFGE17); 
        Field_Group_Element__c oFGE15 = new Field_Group_Element__c(
        Field_API_Name__c = 'Fun_Things_To_Do__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 15,Token_Name__c ='BeneficiaryHobbyList');
        lstFGE.add(oFGE15);     
        Field_Group_Element__c oFGE14 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Confession_Of_Faith_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 14,Token_Name__c ='BeneficiaryConfessionofFaithDate');
        lstFGE.add(oFGE14);     
        Field_Group_Element__c oFGE13 = new Field_Group_Element__c(
        Field_API_Name__c = 'BEN_Chore_List__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 13,Token_Name__c ='BeneficiaryChoreList');
        lstFGE.add(oFGE13);     
        Field_Group_Element__c oFGE12 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Last_Bible_Distributed_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 12,Token_Name__c ='BeneficiaryLastBibleDistributedDate');
        lstFGE.add(oFGE12);     
        Field_Group_Element__c oFGE11 = new Field_Group_Element__c(
        Field_API_Name__c = 'Available_For_Marketing_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 11,Token_Name__c ='AvailableforMarketingDate');
        lstFGE.add(oFGE11);
        return lstFGE;
    }
    
    /**
    * Method name  : createSupporterProfileFieldGroupElementTestData
    * Description  : This method creates Test Data for Create Supporter Profile Field Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : String
    **/   
    public static List<Field_Group_Element__c> createSupporterProfileFieldGroupElementTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE = new Field_Group_Element__c();
        oFGE.Field_API_Name__c = 'FirstName';
        oFGE.Field_Group__c = fieldGroupId;
        oFGE.Field_Type__c = 'TEXT';
        oFGE.JSON_Order__c = NULL;
        oFGE.Token_Name__c = 'FirstName';
        lstFGE.add(oFGE);
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c();
        oFGE1.Field_API_Name__c = 'LastName';
        oFGE1.Field_Group__c = fieldGroupId;
        oFGE1.Field_Type__c = 'TEXT';
        oFGE1.JSON_Order__c = NULL;
        oFGE1.Token_Name__c = 'LastName';
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c();
        oFGE2.Field_API_Name__c = 'Correspondence_Language__c';
        oFGE2.Field_Group__c = fieldGroupId;
        oFGE2.Field_Type__c = 'DATE';
        oFGE2.JSON_Order__c = NULL;
        oFGE2.Token_Name__c = 'Language';
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c();
        oFGE3.Field_API_Name__c = 'Gender__c';
        oFGE3.Field_Group__c = fieldGroupId;
        oFGE3.Field_Type__c = 'TEXT';
        oFGE3.JSON_Order__c = NULL;
        oFGE3.Token_Name__c = 'Gender';
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c();
        oFGE4.Field_API_Name__c = 'Global_Partner__c';
        oFGE4.Field_Group__c = fieldGroupId;
        oFGE4.Field_Type__c = 'TEXT';
        oFGE4.JSON_Order__c = NULL;
        oFGE4.Token_Name__c = 'GlobalPartner';
        lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c();
        oFGE5.Field_API_Name__c = 'Global_Number__c';
        oFGE5.Field_Group__c = fieldGroupId;
        oFGE5.Field_Type__c = 'TEXT';
        oFGE5.JSON_Order__c = NULL;
        oFGE5.Token_Name__c = 'GlobalID';
        lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c();
        oFGE6.Field_API_Name__c = 'ID';
        oFGE6.Field_Group__c = fieldGroupId;
        oFGE6.Field_Type__c = 'TEXT';
        oFGE6.JSON_Order__c = NULL;
        oFGE6.Token_Name__c = 'GPID';
        lstFGE.add(oFGE6);  
        return lstFGE;
    }
  /**
    * Method name  : createHMElementsTestData
    * Description  : This method creates Test Data for HM Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> createHMElementsTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'Role__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 2,Token_Name__c ='Role');
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(
        Field_API_Name__c = 'Name',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 3,Token_Name__c ='HouseholdMemberName');
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c(
        Field_API_Name__c = 'Is_Caregiver_Text_from_Neuron__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 4,Token_Name__c ='IsCaregiver');
        lstFGE.add(oFGE4);
        return lstFGE;
    }    
     /**
    * Method name  : fetchBenefInfoRequestFGElementTestData
    * Description  : This method creates Test Data for HM Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> fetchBenefInfoRequestFGElementTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'Local_Beneficiary_ID__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c ='CompassChildKey');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'Compass_Id__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 2,Token_Name__c ='CompassId');
        lstFGE.add(oFGE2);
        return lstFGE;
    }    
    
     /**
    * Method name  : fetchBenefStatusRequestFGElementTestData
    * Description  : This method creates Test Data for HM Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> fetchBenefStatusRequestFGElementTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'Local_Beneficiary_ID__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c ='CompassChildKey');
        lstFGE.add(oFGE1);
        return lstFGE;
    }    
     /**
    * Method name  : fetchBenefStatusResponseFGElementTestData
    * Description  : This method creates Test Data for HM Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> fetchBenefStatusResponseFGElementTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'Local_Beneficiary_ID__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c ='CompassChildKey');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 2,Token_Name__c ='BeneficiaryStatus');
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(
        Field_API_Name__c = 'Review_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 3,Token_Name__c ='ReviewStatus');
        lstFGE.add(oFGE3);
        return lstFGE;
    }    
      /**
    * Method name  : hmWithBenefResponseFGElementsTestData
    * Description  : This method creates Test Data for HM Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> hmWithBenefResponseFGElementsTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'Existing_Beneficiary__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c ='CompassionBeneficiaryId');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'Role__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 2,Token_Name__c ='Role');
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(
        Field_API_Name__c = 'Name',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 3,Token_Name__c ='HouseholdMemberName');
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c(
        Field_API_Name__c = 'LastModifiedDate',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATETIME',JSON_Order__c = 4,Token_Name__c ='LastModifiedDate');
        lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c(
        Field_API_Name__c = 'Is_Caregiver__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'BOOLEAN',JSON_Order__c = 5,Token_Name__c ='IsCaregiver');
        lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c(
        Field_API_Name__c = 'CreatedDate',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATETIME',JSON_Order__c = 6,Token_Name__c ='CreatedDate');
        lstFGE.add(oFGE6);
        Field_Group_Element__c oFGE7 = new Field_Group_Element__c(
        Field_API_Name__c = 'Household__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 7,Token_Name__c ='Household');
        lstFGE.add(oFGE7);
        return lstFGE;
    }    
    
       /**
    * Method name  : updateBenefStatusFGElementsTestData
    * Description  : This method creates Test Data for HM Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> updateBenefStatusFGElementsTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'Available_Banks__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c ='ChildKey');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'Compass_Id__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 2,Token_Name__c ='CompassChildKey');
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(
        Field_API_Name__c = 'Sponsorship_Status__pc',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 3,Token_Name__c ='SponsorshipStatus');
        lstFGE.add(oFGE3);
        return lstFGE;
    }   
    
           /**
    * Method name  : updateExitBLEFGElementsTestData
    * Description  : This method creates Test Data for Exit BLE Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> updateExitBLEFGElementsTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',Token_Name__c ='Status');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'Reason_For_Delay_In_Processing__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',Token_Name__c ='COMPASSId');
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(
        Field_API_Name__c = 'Reason__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',Token_Name__c ='RecordTypeName');
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c(
        Field_API_Name__c = 'Name',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',Token_Name__c ='BeneficiaryLifecycleEventName');
        lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c(
        Field_API_Name__c = 'Comments__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',Token_Name__c ='BeneficiaryName');
        lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c(
        Field_API_Name__c = 'Reinstatement_Description__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',Token_Name__c ='BeneficiaryId');
        lstFGE.add(oFGE6);
        return lstFGE;
    }    
        /**
    * Method name  : bulkImageResponseFGElementsTestData
    * Description  : This method creates Test Data for HM Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> bulkImageResponseFGElementsTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'Comments__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c ='ChildKey');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'Content_Type__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 2,Token_Name__c ='DocumentType');
        lstFGE.add(oFGE2);
        return lstFGE;
    }   
     /**
    * Method name  : benefResponseFGElementsTestData
    * Description  : This method creates Test Data for HM Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> benefResponseFGElementsTestData(Id fieldGroupId)
    {   
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'Name',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c ='AccountName');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'Economic_Description_Context_Needs__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 2,Token_Name__c ='AccountOwner');
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(
        Field_API_Name__c = 'Educational_Description_Context_Needs__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 3,Token_Name__c ='AccountRecordType');
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c(
        Field_API_Name__c = 'Active_Program__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 4,Token_Name__c ='ActiveProgram');
        lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c(
        Field_API_Name__c = 'Actual_First_Attendance_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 5,Token_Name__c ='ActualFirstAttendanceDate');
        lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c(
        Field_API_Name__c = 'Actual_Registration_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 6,Token_Name__c ='ActualRegistrationDate');
        lstFGE.add(oFGE6);
        Field_Group_Element__c oFGE7 = new Field_Group_Element__c(
        Field_API_Name__c = 'Age__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 7,Token_Name__c ='Age');
        lstFGE.add(oFGE7);
        Field_Group_Element__c oFGE8 = new Field_Group_Element__c(
        Field_API_Name__c = 'Agreement_Renewal_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 8,Token_Name__c ='AgreementRenewalDate');
        lstFGE.add(oFGE8);
        Field_Group_Element__c oFGE9 = new Field_Group_Element__c(
        Field_API_Name__c = 'Agreement_Signed_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 9,Token_Name__c ='AgreementSignedDate');
        lstFGE.add(oFGE9);
        Field_Group_Element__c oFGE10 = new Field_Group_Element__c(
        Field_API_Name__c = 'Alternate_Address_Expiry_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 10,Token_Name__c ='AlternateAddressExpiryDate');
        lstFGE.add(oFGE10);
        Field_Group_Element__c oFGE11 = new Field_Group_Element__c(
        Field_API_Name__c = 'Approval_Stage__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 11,Token_Name__c ='ApprovalStage');
        lstFGE.add(oFGE11);
        Field_Group_Element__c oFGE12 = new Field_Group_Element__c(
        Field_API_Name__c = 'Available_For_Marketing_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 12,Token_Name__c ='AvailableforMarketingDate');
        lstFGE.add(oFGE12);
        Field_Group_Element__c oFGE13 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Last_Bible_Distributed_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 13,Token_Name__c ='BeneficiaryLastBibleDistributedDate');
        lstFGE.add(oFGE13);
        Field_Group_Element__c oFGE14 = new Field_Group_Element__c(
        Field_API_Name__c = 'BEN_Chore_List__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 14,Token_Name__c ='BeneficiaryChoreList');
        lstFGE.add(oFGE14);
        Field_Group_Element__c oFGE15 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Confession_Of_Faith_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 15,Token_Name__c ='BeneficiaryConfessionofFaithDate');
        lstFGE.add(oFGE15);
        Field_Group_Element__c oFGE16 = new Field_Group_Element__c(
        Field_API_Name__c = 'Fun_Things_To_Do__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 16,Token_Name__c ='BeneficiaryHobbyList');
        lstFGE.add(oFGE16);
        Field_Group_Element__c oFGE17 = new Field_Group_Element__c(
        Field_API_Name__c = 'Id',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 17,Token_Name__c ='BeneficiaryId');
        lstFGE.add(oFGE17);
        Field_Group_Element__c oFGE18 = new Field_Group_Element__c(
        Field_API_Name__c = 'Compass_Id__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 18,Token_Name__c ='COMPASSId');
        lstFGE.add(oFGE18);
        Field_Group_Element__c oFGE19 = new Field_Group_Element__c(
        Field_API_Name__c = 'LastModifiedDate',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATETIME',JSON_Order__c = 19,Token_Name__c ='LastModifiedDate');
        lstFGE.add(oFGE19);
        Field_Group_Element__c oFGE20 = new Field_Group_Element__c(
        Field_API_Name__c = 'Expected_Transition_Date_To_Center__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 20,Token_Name__c ='ExpectedTransitionDateToCenter');
        lstFGE.add(oFGE20);
        Field_Group_Element__c oFGE21 = new Field_Group_Element__c(
        Field_API_Name__c = 'Expected_Transition_Date_To_Sponsorship__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 21,Token_Name__c ='ExpectedTransitionDateToSponsorship');
        lstFGE.add(oFGE21);
        Field_Group_Element__c oFGE22 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 22,Token_Name__c ='BeneficiaryStatus');
        lstFGE.add(oFGE22);
        Field_Group_Element__c oFGE23 = new Field_Group_Element__c(
        Field_API_Name__c = 'PersonBirthdate',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 23,Token_Name__c ='Birthdate');
        lstFGE.add(oFGE23);
        Field_Group_Element__c oFGE24 = new Field_Group_Element__c(
        Field_API_Name__c = 'BMI_For_Age_WHO__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 24,Token_Name__c ='BMIforAgeWHO');
        lstFGE.add(oFGE24);
        Field_Group_Element__c oFGE25 = new Field_Group_Element__c(
        Field_API_Name__c = 'Known_Complications__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 25,Token_Name__c ='CaregiverName');
        lstFGE.add(oFGE25);
        Field_Group_Element__c oFGE26 = new Field_Group_Element__c(
        Field_API_Name__c = 'Primary_Caregiver__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 26,Token_Name__c ='CaregiverId');
        lstFGE.add(oFGE26);
        Field_Group_Element__c oFGE27 = new Field_Group_Element__c(
        Field_API_Name__c = 'CDSP_End_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 27,Token_Name__c ='CDSPProgramEndDate');
        lstFGE.add(oFGE27);
        Field_Group_Element__c oFGE28 = new Field_Group_Element__c(
        Field_API_Name__c = 'CDSP_Start_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 28,Token_Name__c ='CDSPProgramStartDate');
        lstFGE.add(oFGE28);
        Field_Group_Element__c oFGE29 = new Field_Group_Element__c(
        Field_API_Name__c = 'CDSP_Tenure__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 29,Token_Name__c ='CDSPTenure');
        lstFGE.add(oFGE29);
        Field_Group_Element__c oFGE30 = new Field_Group_Element__c(
        Field_API_Name__c = 'CSP_End_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 30,Token_Name__c ='CSPProgramEndDate');
        lstFGE.add(oFGE30);
        Field_Group_Element__c oFGE31 = new Field_Group_Element__c(
        Field_API_Name__c = 'CSP_Start_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 31,Token_Name__c ='CSPProgramStartDate');
        lstFGE.add(oFGE31);
        Field_Group_Element__c oFGE32 = new Field_Group_Element__c(
        Field_API_Name__c = 'CSP_Tenure__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 32,Token_Name__c ='CSPTenure');
        lstFGE.add(oFGE32);
        Field_Group_Element__c oFGE33 = new Field_Group_Element__c(
        Field_API_Name__c = 'CDSP_Type__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 33,Token_Name__c ='CDSPType');
        lstFGE.add(oFGE33);
        Field_Group_Element__c oFGE34 = new Field_Group_Element__c(
        Field_API_Name__c = 'Christian_Activities__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 34,Token_Name__c ='ChristianActivities');
        lstFGE.add(oFGE34);
        Field_Group_Element__c oFGE35 = new Field_Group_Element__c(
        Field_API_Name__c = 'Chronic_Illnesses__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 35,Token_Name__c ='ChronicIllness');
        lstFGE.add(oFGE35);
        Field_Group_Element__c oFGE36 = new Field_Group_Element__c(
        Field_API_Name__c = 'Cluster_Name__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 36,Token_Name__c ='ClusterName');
        lstFGE.add(oFGE36);
        Field_Group_Element__c oFGE37 = new Field_Group_Element__c(
        Field_API_Name__c = 'Cognitive_Age_Group__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 37,Token_Name__c ='CognitiveAgeGroup');
        lstFGE.add(oFGE37);
        Field_Group_Element__c oFGE38 = new Field_Group_Element__c(
        Field_API_Name__c = 'CreatedDate',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATETIME',JSON_Order__c = 38,Token_Name__c ='CreatedDate');
        lstFGE.add(oFGE38);
        Field_Group_Element__c oFGE39 = new Field_Group_Element__c(
        Field_API_Name__c = 'Physical_Disabilities__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 39,Token_Name__c ='Disabilities');
        lstFGE.add(oFGE39);
        Field_Group_Element__c oFGE40 = new Field_Group_Element__c(
        Field_API_Name__c = 'Existing_Beneficiary__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 40,Token_Name__c ='ExistingBeneficiaryId');
        lstFGE.add(oFGE40);
        Field_Group_Element__c oFGE41 = new Field_Group_Element__c(
        Field_API_Name__c = 'Available_Banks__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 41,Token_Name__c ='ExistingBeneficiaryName');
        lstFGE.add(oFGE41);
        Field_Group_Element__c oFGE42 = new Field_Group_Element__c(
        Field_API_Name__c = 'FO__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 42,Token_Name__c ='FO');
        lstFGE.add(oFGE42);
        Field_Group_Element__c oFGE43 = new Field_Group_Element__c(
        Field_API_Name__c = 'Formal_Education_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 43,Token_Name__c ='FormalEducationStatus');
        lstFGE.add(oFGE43);
        Field_Group_Element__c oFGE44 = new Field_Group_Element__c(
        Field_API_Name__c = 'Gender__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 44,Token_Name__c ='Gender');
        lstFGE.add(oFGE44);
        Field_Group_Element__c oFGE45 = new Field_Group_Element__c(
        Field_API_Name__c = 'Local_Grade_Level__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 45,Token_Name__c ='LocalGradeLevel');
        lstFGE.add(oFGE45);
        Field_Group_Element__c oFGE46 = new Field_Group_Element__c(
        Field_API_Name__c = 'US_Equivalent_Grade_Level__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 46,Token_Name__c ='USEquivalentGradeLevel');
        lstFGE.add(oFGE46);
        Field_Group_Element__c oFGE47 = new Field_Group_Element__c(
        Field_API_Name__c = 'Height_Cm__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DOUBLE',JSON_Order__c = 47,Token_Name__c ='HeightInCm');
        lstFGE.add(oFGE47);
        Field_Group_Element__c oFGE48 = new Field_Group_Element__c(
        Field_API_Name__c = 'Height_For_Age_WHO__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 48,Token_Name__c ='HeightforAgeWHO');
        lstFGE.add(oFGE48);
        Field_Group_Element__c oFGE49 = new Field_Group_Element__c(
        Field_API_Name__c = 'CRCH_Project__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 49,Token_Name__c ='HouseholdName');
        lstFGE.add(oFGE49);
        Field_Group_Element__c oFGE51 = new Field_Group_Element__c(
        Field_API_Name__c = 'ICP__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 51,Token_Name__c ='ICPId');
        lstFGE.add(oFGE51);
        Field_Group_Element__c oFGE52 = new Field_Group_Element__c(
        Field_API_Name__c = 'Available_Courier_Services__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 52,Token_Name__c ='ICPName');
        lstFGE.add(oFGE52);
        Field_Group_Element__c oFGE53 = new Field_Group_Element__c(
        Field_API_Name__c = 'Incident_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 53,Token_Name__c ='IncidentDate');
        lstFGE.add(oFGE53);
        Field_Group_Element__c oFGE54 = new Field_Group_Element__c(
        Field_API_Name__c = 'Incident_Number__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 54,Token_Name__c ='IncidentNumber');
        lstFGE.add(oFGE54);
        Field_Group_Element__c oFGE55 = new Field_Group_Element__c(
        Field_API_Name__c = 'Is_Alternate_Address_In_Use__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'BOOLEAN',JSON_Order__c = 55,Token_Name__c ='IsAlternateAddressinUse');
        lstFGE.add(oFGE55);
        Field_Group_Element__c oFGE56 = new Field_Group_Element__c(
        Field_API_Name__c = 'Is_Beneficiary_Attending_School__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'BOOLEAN',JSON_Order__c = 56,Token_Name__c ='IsBeneficiaryAttendingSchool');
        lstFGE.add(oFGE56);
        Field_Group_Element__c oFGE57 = new Field_Group_Element__c(
        Field_API_Name__c = 'Correspondence_Language__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 57,Token_Name__c ='Language');
        lstFGE.add(oFGE57);
        Field_Group_Element__c oFGE58 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Last_Review_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 58,Token_Name__c ='LastReviewedDate');
        lstFGE.add(oFGE58);
        Field_Group_Element__c oFGE59 = new Field_Group_Element__c(
        Field_API_Name__c = 'Mental_Development_Conditions__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 59,Token_Name__c ='MentalDevelopmentConditions');
        lstFGE.add(oFGE59);
        Field_Group_Element__c oFGE60 = new Field_Group_Element__c(
        Field_API_Name__c = 'Phone',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 60,Token_Name__c ='Phone');
        lstFGE.add(oFGE60);
        Field_Group_Element__c oFGE61 = new Field_Group_Element__c(
        Field_API_Name__c = 'Planned_Completion_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 61,Token_Name__c ='PlannedCompletionDate');
        lstFGE.add(oFGE61);
        Field_Group_Element__c oFGE62 = new Field_Group_Element__c(
        Field_API_Name__c = 'Planned_Completion_Date_Change_Reason__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 62,Token_Name__c ='PlannedCompletionDateChangeReason');
        lstFGE.add(oFGE62);
        Field_Group_Element__c oFGE63 = new Field_Group_Element__c(
        Field_API_Name__c = 'Preferred_Name__pc',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 63,Token_Name__c ='PreferredName');
        lstFGE.add(oFGE63);
        Field_Group_Element__c oFGE64 = new Field_Group_Element__c(
        Field_API_Name__c = 'Program_Field_Manual_Exemption__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 64,Token_Name__c ='ProgramFieldManualExemption');
        lstFGE.add(oFGE64);
        Field_Group_Element__c oFGE65 = new Field_Group_Element__c(
        Field_API_Name__c = 'Religious_Affiliation__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 65,Token_Name__c ='ReligiousAffiliation');
        lstFGE.add(oFGE65);
        Field_Group_Element__c oFGE66 = new Field_Group_Element__c(
        Field_API_Name__c = 'External_Resources_Available__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 66,Token_Name__c ='TutorImplementerName');
        lstFGE.add(oFGE66);
        Field_Group_Element__c oFGE67 = new Field_Group_Element__c(
        Field_API_Name__c = 'Weight_Kg__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DOUBLE',JSON_Order__c = 67,Token_Name__c ='WeightInKg');
        lstFGE.add(oFGE67);
        Field_Group_Element__c oFGE68 = new Field_Group_Element__c(
        Field_API_Name__c = 'Weight_For_Age_WHO__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 68,Token_Name__c ='WeightforAgeWHO');
        lstFGE.add(oFGE68);
        Field_Group_Element__c oFGE69 = new Field_Group_Element__c(
        Field_API_Name__c = 'Weight_For_Height_Length_WHO__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 69,Token_Name__c ='WeightforHeightLengthWHO');
        lstFGE.add(oFGE69);
        Field_Group_Element__c oFGE70 = new Field_Group_Element__c(
        Field_API_Name__c = 'Local_Beneficiary_Id__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 70,Token_Name__c ='CompassChild');
        lstFGE.add(oFGE70);
        Field_Group_Element__c oFGE71 = new Field_Group_Element__c(
        Field_API_Name__c = 'BEN_Educational_Assessment__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 71,Token_Name__c ='BeneficiaryEducationalAssessment');
        lstFGE.add(oFGE71);
        Field_Group_Element__c oFGE72 = new Field_Group_Element__c(
        Field_API_Name__c = 'Acceptance_Of_Agreement_Renewal__c',Field_Group__c = fieldGroupId,Field_Type__c = 'BOOLEAN',JSON_Order__c = 72,Token_Name__c ='NaturalFatherLivingWithChild');
        lstFGE.add(oFGE72);
        Field_Group_Element__c oFGE73 = new Field_Group_Element__c(
        Field_API_Name__c = 'Breast_Feeding_At_Registration__c',Field_Group__c = fieldGroupId,Field_Type__c = 'BOOLEAN',JSON_Order__c = 73,Token_Name__c ='NaturalMotherLivingWithChild');
        lstFGE.add(oFGE73);
        Field_Group_Element__c oFGE74 = new Field_Group_Element__c(
        Field_API_Name__c = 'Breast_Feeding_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 74,Token_Name__c ='NaturalFatherIsAlive');
        lstFGE.add(oFGE74);
        Field_Group_Element__c oFGE75 = new Field_Group_Element__c(
        Field_API_Name__c = 'Caregiver_HIV_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 75,Token_Name__c ='NaturalMotherIsAlive');
        lstFGE.add(oFGE75);
        Field_Group_Element__c oFGE76 = new Field_Group_Element__c(
        Field_API_Name__c = 'CGV_Pregnancy_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 76,Token_Name__c ='MaleOccupation');
        lstFGE.add(oFGE76);
        Field_Group_Element__c oFGE77 = new Field_Group_Element__c(
        Field_API_Name__c = 'CDSP_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 77,Token_Name__c ='FemaleOccupation');
        lstFGE.add(oFGE77);
        Field_Group_Element__c oFGE78 = new Field_Group_Element__c(
        Field_API_Name__c = 'Building_Ownership__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 78,Token_Name__c ='MaleEmploymentStatus');
        lstFGE.add(oFGE78);
        Field_Group_Element__c oFGE79 = new Field_Group_Element__c(
        Field_API_Name__c = 'Leadership_Style__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 79,Token_Name__c ='FemaleEmploymentStatus');
        lstFGE.add(oFGE79);
        Field_Group_Element__c oFGE80 = new Field_Group_Element__c(
        Field_API_Name__c = 'Legal_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 80,Token_Name__c ='MaritalStatus');
        lstFGE.add(oFGE80);
        Field_Group_Element__c oFGE81 = new Field_Group_Element__c(
        Field_API_Name__c = 'Current_University_Year_Of_Study__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 81,Token_Name__c ='CurrentUniversityYearOfStudy');
        lstFGE.add(oFGE81);
        Field_Group_Element__c oFGE82 = new Field_Group_Element__c(
        Field_API_Name__c = 'Type_Of_Vocational_Education__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 82,Token_Name__c ='TypeOfVocationalEducation');
        lstFGE.add(oFGE82);
        Field_Group_Element__c oFGE83 = new Field_Group_Element__c(
        Field_API_Name__c = 'Major_Or_Course_Of_Study__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 83,Token_Name__c ='MajorOrCourseOfStudy');
        lstFGE.add(oFGE83);
        Field_Group_Element__c oFGE84 = new Field_Group_Element__c(
        Field_API_Name__c = 'Locale__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 84,Token_Name__c ='TogetherNow');
        lstFGE.add(oFGE84);
        Field_Group_Element__c oFGE85 = new Field_Group_Element__c(
        Field_API_Name__c = 'Written_By_Laws__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'BOOLEAN',JSON_Order__c = 85,Token_Name__c ='Insert');
        lstFGE.add(oFGE85);
        Field_Group_Element__c oFGE86 = new Field_Group_Element__c(
        Field_API_Name__c = 'Not_Enrolled_In_Education_Reason__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 86,Token_Name__c ='NotEnrolledInEducationReason');
        lstFGE.add(oFGE86);
        Field_Group_Element__c oFGE87 = new Field_Group_Element__c(
        Field_API_Name__c = 'Harvest_Seasons__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 87,Token_Name__c ='HarvestMonths');
        lstFGE.add(oFGE87);
        Field_Group_Element__c oFGE88 = new Field_Group_Element__c(
        Field_API_Name__c = 'Times_Of_Hunger__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 88,Token_Name__c ='HungerMonths');
        lstFGE.add(oFGE88);
        Field_Group_Element__c oFGE89 = new Field_Group_Element__c(
        Field_API_Name__c = 'Favorite_Subject_in_School__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 89,Token_Name__c ='FavoriteSubjectsInSchool');
        lstFGE.add(oFGE89);
        Field_Group_Element__c oFGE90 = new Field_Group_Element__c(
        Field_API_Name__c = 'Education_Level__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 90,Token_Name__c ='EducationLevel');
        lstFGE.add(oFGE90);
        Field_Group_Element__c oFGE91 = new Field_Group_Element__c(
        Field_API_Name__c = 'Estimated_Birthdate__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'BOOLEAN',JSON_Order__c = 91,Token_Name__c = 'EstimatedBirthdate');
        lstFGE.add(oFGE91);
        Field_Group_Element__c oFGE92 = new Field_Group_Element__c(
        Field_API_Name__c = 'CDSP_Capacity__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 92,Token_Name__c = 'CurrentCDSPCapacity');
        lstFGE.add(oFGE92);
        return lstFGE;
    }
    
    /**
    * Method name  : disasterTestData
    * Description  : This method creates Test Data for Disaster
    * Return Type  : List<Disaster__c>
    * Parameter    : Account
    **/
    public static List<Disaster__c> disasterTestData(Account fieldOffice)
    {
        List<Disaster__c> lstDisaster = new List<Disaster__c>();
        Disaster__c oDisaster = new Disaster__c();
        oDisaster.Name = 'Earthquake in FO';
        oDisaster.Disaster_Date__c = System.today();
        oDisaster.Disaster_Type__c = 'Earthquake';
        oDisaster.Field_Office__c = fieldOffice.Id;
        oDisaster.Estimated_Loss_Of_Life__c = '1-10';
        oDisaster.Estimated_Serious_Injuries__c = '50-99';
        oDisaster.Estimated_Not_Attending_Project__c = '100-250';
        oDisaster.Estimated_Damage_Over_1_Million_USD__c = 'No';
        oDisaster.Estimated_Homes_Destroyed__c = '25-49';
        oDisaster.Estimated_Loss_Of_Livelihood__c = '25-49';
        oDisaster.Estimated_Basic_Supplies_Needed__c = '50-99';
        oDisaster.Disaster_Impact_Description__c = 'Sample Description';
        oDisaster.Disaster_Area_Description__c = 'Sample Area';
        oDisaster.Disaster_Response_Description__c = 'Sample Response';
        lstDisaster.add(oDisaster);
        Disaster__c oDisaster1 = new Disaster__c();
        oDisaster1.Name = 'Earthquake in FO';
        oDisaster1.Disaster_Date__c = System.today();
        oDisaster1.Disaster_Type__c = 'Earthquake';
        oDisaster1.Field_Office__c = fieldOffice.Id;
        oDisaster1.Estimated_Loss_Of_Life__c = '1-10';
        oDisaster1.Estimated_Serious_Injuries__c = '25-49';
        oDisaster1.Estimated_Not_Attending_Project__c = '25-49';
        oDisaster1.Estimated_Damage_Over_1_Million_USD__c = 'No';
        oDisaster1.Estimated_Homes_Destroyed__c = '25-49';
        oDisaster1.Estimated_Loss_Of_Livelihood__c = '25-49';
        oDisaster1.Estimated_Basic_Supplies_Needed__c = '50-99';
        oDisaster1.Disaster_Impact_Description__c = 'Sample Description';
        oDisaster1.Disaster_Area_Description__c = 'Sample Area';
        oDisaster1.Disaster_Response_Description__c = 'Sample Response';
        lstDisaster.add(oDisaster1);
        return lstDisaster;
    }
    
    /**
    * Method name  : beneficiaryImpactTestData
    * Description  : This method creates Test Data for Beneficiary Impact
    * Return Type  : List<Beneficiary_Impact__c>
    * Parameter    : Account, Disaster__c
    **/
    public static List<Beneficiary_Impact__c> beneficiaryImpactTestData(list<Account> lstBeneficiary,  Disaster__c oDisaster)
    {
        List<Beneficiary_Impact__c> lstBenImpact= new List<Beneficiary_Impact__c>();
        Beneficiary_Impact__c oBenImpact = new Beneficiary_Impact__c();
        oBenImpact.BEN_Name__c = lstBeneficiary[0].Id;
        oBenImpact.BEN_Location__c = 'Unknown';
        oBenImpact.Number_Caregivers_Died__c = 0;
        oBenImpact.Number_Siblings_Died__c = 1;
        oBenImpact.Number_Of_Caregivers_Seriously_Injured__c = 2;
        oBenImpact.Number_Of_Caregivers_Seriously_Injured__c = 3;
        oBenImpact.House_Condition__c = 'Damaged';
        oBenImpact.Lost_Personal_Effects__c = 'Lost School Supplies';
        oBenImpact.Disaster_Name__c = oDisaster.Id;
        lstBenImpact.add(oBenImpact);
        Beneficiary_Impact__c oBenImpact1 = new Beneficiary_Impact__c();
        oBenImpact1.BEN_Name__c = lstBeneficiary[1].Id;
        oBenImpact1.BEN_Location__c = 'Missing';
        oBenImpact1.Number_Caregivers_Died__c = 3;
        oBenImpact1.Number_Siblings_Died__c = 1;
        oBenImpact1.Number_Of_Caregivers_Seriously_Injured__c = 2;
        oBenImpact1.Number_Of_Caregivers_Seriously_Injured__c = 3;
        oBenImpact1.House_Condition__c = 'Destroyed';
        oBenImpact1.Lost_Personal_Effects__c = 'Lost School Supplies';
        oBenImpact1.Disaster_Name__c = oDisaster.Id;
        lstBenImpact.add(oBenImpact1);
        return lstBenImpact;
    }
    
    /**
    * Method name  : icpImpactTestData
    * Description  : This method creates Test Data for ICP Impact
    * Return Type  : List<ICP_Impact__c>
    * Parameter    : Account, Disaster__c
    **/
    public static List<ICP_Impact__c> icpImpactTestData(list<Account> lstICP,  Disaster__c oDisaster)
    {
        List<ICP_Impact__c> lstICPImpact= new List<ICP_Impact__c>();
        ICP_Impact__c oICPImpact = new ICP_Impact__c();
        oICPImpact.ICP_Name__c = lstICP[0].Id;
        oICPImpact.ICP_Disaster_Status__c = 'Affected';
        oICPImpact.Disaster_Impact_To_ICP_Infrastructure__c = 'Minor Damage';
        oICPImpact.Disaster_Impact_On_ICP_Program__c = 'Temporarily Closed';
        oICPImpact.ICP_Disaster_Impact_Description__c = 'Test Desc';
        oICPImpact.Disaster_Name__c = oDisaster.Id;
        lstICPImpact.add(oICPImpact);
        ICP_Impact__c oICPImpact1 = new ICP_Impact__c();
        oICPImpact1.ICP_Name__c = lstICP[1].Id;
        oICPImpact1.ICP_Disaster_Status__c = 'Affected';
        oICPImpact1.Disaster_Impact_To_ICP_Infrastructure__c = 'Significant Damage';
        oICPImpact1.Disaster_Impact_On_ICP_Program__c = 'Permanently Closed';
        oICPImpact1.ICP_Disaster_Impact_Description__c = 'Test Desc';
        oICPImpact1.Disaster_Name__c = oDisaster.Id;
        lstICPImpact.add(oICPImpact1);
        return lstICPImpact;
    }
    
    /**
    * Method name  : commitmentTestData
    * Description  : This method creates Test Data for Commitment records
    * Return Type  : Commitment__c
    * Parameter    : Account, Account
    **/
    public static Commitment__c commitmentTestData(Account oBeneficiary,  Account oSupporter)
    {
        Commitment__c oCommitment = new Commitment__c();
        oCommitment.BEN_Id__c = oBeneficiary.Id;
        oCommitment.SUP_Id__c = oSupporter.Id;
        oCommitment.Start_Date__c = System.today();
        return oCommitment;
    }
    
    /**
    * Method name  : supporterTestData
    * Description  : This method creates Test Data for Supporter records
    * Return Type  : Account
    * Parameter    : Account
    **/
    public static Account supporterTestData(Account oGlobalPartner)
    {
        Account oSupporter = new Account();
        Id supRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.SUPPORTER_PERSON_RT_API_NAME);
        oSupporter.LastName = 'Supporter';
        oSupporter.Global_Partner__c = oGlobalPartner.Id;
        oSupporter.RecordTypeId = supRecTypeId;
        return oSupporter;
    }
    
    /**
    * Method name  : globalPartnerTestData
    * Description  : This method creates Test Data for Supporter records
    * Return Type  : Account
    * Parameter    : String
    **/
    public static Account globalPartnerTestData(String sName)
    {
        Account oGlobalPartner = new Account();
        Id gpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.GLOBAL_PARTNER_RT_API_NAME);
        oGlobalPartner.Name = sName;
        oGlobalPartner.RecordTypeId = gpRecTypeId;
        return oGlobalPartner;
    }
    
    /**
    * Method name  : commUpdateTestData
    * Description  : This method creates Test Data for Supporter records
    * Return Type  : Communication_Update__c
    * Parameter    : Disaster__c
    **/
    public static Communication_Update__c commUpdateTestData(Disaster__c oDisaster)
    {
        Communication_Update__c oCommUpdate = new Communication_Update__c();
        oCommUpdate.Disaster_Name__c = oDisaster.Id;
        oCommUpdate.Disaster_Communication_Update_Status__c = 'Field Office Draft';
        oCommUpdate.Field_Office_Disaster_Response_Update__c = 'Demo';
        return oCommUpdate;
    }
    /**
    * Method name  : commKitTestData
    * Description  : This method creates Tes;t Data for Coomuncation Kit records
    * Return Type  : Communication_Kit__c
    * Parameter    : Account
    **/
    public static Communication_Kit__c commKitTestData( Account obenef, Account oSupporter,Account oICP){
        Id commKitRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_S2B_RT);
        Communication_Kit__c oCommKit= new Communication_Kit__c();
        oCommKit.RecordTypeId=commKitRecordTypeId ;
        oCommKit.SUP_ID__c=oSupporter.id;
        oCommKit.Status__c='Printed and sent to ICP';
        oCommKit.BEN_ID__c= obenef.id;
        oCommKit.SUP_ID__c=oSupporter.id;
        oCommKit.Print_Allowed_Date__c=System.Today()-2;
        oCommKit.Communication_Types__c='Large Gift Thank You Letter';
        oCommKit.Attachment_Not_Mailed__c=false;
        oCommKit.ICP_Lookup__c=oICP.id;
        oCommKit.Due_Back_At_Field_Office__c=System.Today()+14;
        
        
        return oCommKit;
        
    }
    
        
    /**
    * Method name  : sendICPInforToAMFGElementsTestData
    * Description  : This method creates Test Data for Field Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> sendICPInforToAMFGElementsTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'ICP_id__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c = 'Id');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'Name',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 2,Token_Name__c = 'ICP');
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(
        Field_API_Name__c = 'Denomination_Of_Church__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 3,Token_Name__c = 'Denomination');
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c(
        Field_API_Name__c = 'International_Mission_Affiliation__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 4,Token_Name__c = 'InternationalDenominationAffiliation');
        lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c(
        Field_API_Name__c = 'ICP_NBR_Priority__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 5,Token_Name__c = 'NewBeneficiaryRequestPriority');
        lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c(
        Field_API_Name__c = 'Partnership_Start_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 6,Token_Name__c = 'ProgramStartDate');
        lstFGE.add(oFGE6);
        Field_Group_Element__c oFGE7 = new Field_Group_Element__c(
        Field_API_Name__c = 'Partnership_Facilitator__r.Name',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 7,Token_Name__c = 'PartnershipFacilitator');
        lstFGE.add(oFGE7);
        Field_Group_Element__c oFGE8 = new Field_Group_Element__c(
        Field_API_Name__c = 'Phone',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 8,Token_Name__c = 'Phone');
        lstFGE.add(oFGE8);
        Field_Group_Element__c oFGE9 = new Field_Group_Element__c(
        Field_API_Name__c = 'Fax',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 9,Token_Name__c = 'Fax');
        lstFGE.add(oFGE9);
        Field_Group_Element__c oFGE10 = new Field_Group_Element__c(
        Field_API_Name__c = 'Field_Office__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 10,Token_Name__c = 'FieldOffice');
        lstFGE.add(oFGE10);
        Field_Group_Element__c oFGE11 = new Field_Group_Element__c(
        Field_API_Name__c = 'Cluster__r.Region1__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 11,Token_Name__c = 'Region');
        lstFGE.add(oFGE11);
        Field_Group_Element__c oFGE12 = new Field_Group_Element__c(
        Field_API_Name__c = 'Cluster__r.Name',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 12,Token_Name__c = 'Cluster');
        lstFGE.add(oFGE12);
        Field_Group_Element__c oFGE13 = new Field_Group_Element__c(
        Field_API_Name__c = 'BillingCountry',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 13,Token_Name__c = 'Country');
        lstFGE.add(oFGE13);
        Field_Group_Element__c oFGE14 = new Field_Group_Element__c(
        Field_API_Name__c = 'Territory__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 14,Token_Name__c = 'Territory');
        lstFGE.add(oFGE14);
        Field_Group_Element__c oFGE15 = new Field_Group_Element__c(
        Field_API_Name__c = 'Distance_To_Closest_Intl_Airport__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 15,Token_Name__c = 'AirportDistance');
        lstFGE.add(oFGE15);
        Field_Group_Element__c oFGE16 = new Field_Group_Element__c(
        Field_API_Name__c = 'Closest_Major_City__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 16,Token_Name__c = 'ClosestMajorCityEnglish');
        lstFGE.add(oFGE16);
        Field_Group_Element__c oFGE17 = new Field_Group_Element__c(
        Field_API_Name__c = 'Travel_Time_To_Intl_Airport_In_Hours__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 17,Token_Name__c = 'AirportTravelTime');
        lstFGE.add(oFGE17);
        Field_Group_Element__c oFGE18 = new Field_Group_Element__c(
        Field_API_Name__c = 'ICP_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 18,Token_Name__c = 'ICPStatus');
        lstFGE.add(oFGE18);
        Field_Group_Element__c oFGE19 = new Field_Group_Element__c(
        Field_API_Name__c = 'CDSP_Capacity__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 19,Token_Name__c = 'CurrentCDSPCapacity');
        lstFGE.add(oFGE19);
        Field_Group_Element__c oFGE20 = new Field_Group_Element__c(
        Field_API_Name__c = 'Minimum_Number_of_NBRs__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 20,Token_Name__c = 'MinimumNBRQuantity');
        lstFGE.add(oFGE20);
        Field_Group_Element__c oFGE21 = new Field_Group_Element__c(
        Field_API_Name__c = 'No_Of_CDSP_Beneficiaries__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 21,Token_Name__c = 'NumberOfCDSPBeneficiaries');
        lstFGE.add(oFGE21);
        Field_Group_Element__c oFGE22 = new Field_Group_Element__c(
        Field_API_Name__c = 'Population__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 22,Token_Name__c = 'RemainingCDSPCapacity');
        lstFGE.add(oFGE22);
        Field_Group_Element__c oFGE23 = new Field_Group_Element__c(
        Field_API_Name__c = 'BillingStreet',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 23,Token_Name__c = 'AddressStreet');
        lstFGE.add(oFGE23);
        Field_Group_Element__c oFGE24 = new Field_Group_Element__c(
        Field_API_Name__c = 'BillingCity',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 24,Token_Name__c = 'City');
        lstFGE.add(oFGE24);
        Field_Group_Element__c oFGE25 = new Field_Group_Element__c(
        Field_API_Name__c = 'BillingState',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 25,Token_Name__c = 'CountryDivision');
        lstFGE.add(oFGE25);
        Field_Group_Element__c oFGE26 = new Field_Group_Element__c(
        Field_API_Name__c = 'BillingPostalCode',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 25,Token_Name__c = 'PostalCode');
        lstFGE.add(oFGE26);
        return lstFGE;
    }
    
    /**
    * Method name  : sendBenefInforToAMFGElementsTestData
    * Description  : This method creates Test Data for Field Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> sendBenefInforToAMFGElementsTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'Thumbnail_URL__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c = 'Thumbnail');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'Child_Dev_Center_Name_English__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 2,Token_Name__c = 'BLERequestReason');
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(
        Field_API_Name__c = 'Correspondence_Language__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 3,Token_Name__c = 'CorrespondenceLanguage');
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c(
        Field_API_Name__c = 'CGV_Birth_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 4,Token_Name__c = 'ExitEffectiveDate');
        lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c(
        Field_API_Name__c = 'Church_Name_Local_Language__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 5,Token_Name__c = 'SFDCBeneficiaryLink');
        lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c(
        Field_API_Name__c = 'Available_For_Marketing_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 6,Token_Name__c = 'AvailableForMarketingDate');
        lstFGE.add(oFGE6);
        Field_Group_Element__c oFGE7 = new Field_Group_Element__c(
        Field_API_Name__c = 'PersonBirthdate',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 7,Token_Name__c = 'BirthDate');
        lstFGE.add(oFGE7);
        Field_Group_Element__c oFGE8 = new Field_Group_Element__c(
        Field_API_Name__c = 'FirstName',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 8,Token_Name__c = 'FirstName');
        lstFGE.add(oFGE8);
        Field_Group_Element__c oFGE9 = new Field_Group_Element__c(
        Field_API_Name__c = 'Gender__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 9,Token_Name__c = 'Gender');
        lstFGE.add(oFGE9);
        Field_Group_Element__c oFGE10 = new Field_Group_Element__c(
        Field_API_Name__c = 'Global_Number__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 10,Token_Name__c = 'BeneficiaryGlobalId');
        lstFGE.add(oFGE10);
        Field_Group_Element__c oFGE11 = new Field_Group_Element__c(
        Field_API_Name__c = 'Is_Orphan__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'BOOLEAN',JSON_Order__c = 11,Token_Name__c = 'IsOrphan');
        lstFGE.add(oFGE11);
        Field_Group_Element__c oFGE12 = new Field_Group_Element__c(
        Field_API_Name__c = 'LastName',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 12,Token_Name__c = 'LastName');
        lstFGE.add(oFGE12);
        Field_Group_Element__c oFGE13 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Last_Review_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 13,Token_Name__c = 'LastReviewDate');
        lstFGE.add(oFGE13);
        Field_Group_Element__c oFGE14 = new Field_Group_Element__c(
        Field_API_Name__c = 'Local_Beneficiary_ID__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 14,Token_Name__c = 'BeneficiaryLocalId');
        lstFGE.add(oFGE14);
        Field_Group_Element__c oFGE15 = new Field_Group_Element__c(
        Field_API_Name__c = 'Preferred_Name__pc',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 15,Token_Name__c = 'PreferredlName');
        lstFGE.add(oFGE15);
        Field_Group_Element__c oFGE16 = new Field_Group_Element__c(
        Field_API_Name__c = 'Religious_Affiliation__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 16,Token_Name__c = 'ReligiousAffiliation');
        lstFGE.add(oFGE16);
        Field_Group_Element__c oFGE17 = new Field_Group_Element__c(
        Field_API_Name__c = 'BEN_Last_Wrote__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 17,Token_Name__c = 'LetterLastWrittenDate');
        lstFGE.add(oFGE17);
        Field_Group_Element__c oFGE18 = new Field_Group_Element__c(
        Field_API_Name__c = 'Planned_Completion_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 18,Token_Name__c = 'PlannedCompletionDate');
        lstFGE.add(oFGE18);
        Field_Group_Element__c oFGE19 = new Field_Group_Element__c(
        Field_API_Name__c = 'Chronic_Illnesses__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 19,Token_Name__c = 'ChronicIllness');
        lstFGE.add(oFGE19);
        Field_Group_Element__c oFGE20 = new Field_Group_Element__c(
        Field_API_Name__c = 'Cluster_Name__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 20,Token_Name__c = 'Cluster');
        lstFGE.add(oFGE20);
        Field_Group_Element__c oFGE21 = new Field_Group_Element__c(
        Field_API_Name__c = 'Country_of_Citizenship__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 21,Token_Name__c = 'Country');
        lstFGE.add(oFGE21);
        Field_Group_Element__c oFGE22 = new Field_Group_Element__c(
        Field_API_Name__c = 'FO__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 22,Token_Name__c = 'FieldOffice_Name');
        lstFGE.add(oFGE22);
        Field_Group_Element__c oFGE23 = new Field_Group_Element__c(
        Field_API_Name__c = 'Household__r.Natural_Father_IsAlive__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 23,Token_Name__c = 'NaturalFatherAlive');
        lstFGE.add(oFGE23);
        Field_Group_Element__c oFGE24 = new Field_Group_Element__c(
        Field_API_Name__c = 'Household__r.Natural_Mother_IsAlive__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 24,Token_Name__c = 'NaturalMotherAlive');
        lstFGE.add(oFGE24);
        Field_Group_Element__c oFGE25 = new Field_Group_Element__c(
        Field_API_Name__c = 'Household__r.Total_Family_Males_18__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 25,Token_Name__c = 'NumberOfBrothersUnder18');
        lstFGE.add(oFGE25);
        Field_Group_Element__c oFGE26 = new Field_Group_Element__c(
        Field_API_Name__c = 'Household__r.Total_Family_Females__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 26,Token_Name__c = 'NumberOfSistersUnder18');
        lstFGE.add(oFGE26);
        Field_Group_Element__c oFGE27 = new Field_Group_Element__c(
        Field_API_Name__c = 'Household__r.Marital_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 27,Token_Name__c = 'ParentsMaritalStatus');
        lstFGE.add(oFGE27);
        Field_Group_Element__c oFGE28 = new Field_Group_Element__c(
        Field_API_Name__c = 'ICP__r.ICP_Id__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 28,Token_Name__c = 'ICP_Id');
        lstFGE.add(oFGE28);
        Field_Group_Element__c oFGE29 = new Field_Group_Element__c(
        Field_API_Name__c = 'Physical_Disabilities__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 29,Token_Name__c = 'PhysicalDisability');
        lstFGE.add(oFGE29);
        Field_Group_Element__c oFGE30 = new Field_Group_Element__c(
        Field_API_Name__c = 'ICP__r.Cluster__r.Territory__r.Name',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 30,Token_Name__c = 'Territory');
        lstFGE.add(oFGE30);
        Field_Group_Element__c oFGE31 = new Field_Group_Element__c(
        Field_API_Name__c = 'PO_Number__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 31,Token_Name__c = 'OrderNumber');
        lstFGE.add(oFGE31);
        Field_Group_Element__c oFGE32 = new Field_Group_Element__c(
        Field_API_Name__c = 'Actual_Registration_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 32,Token_Name__c = 'RegistrationEffectiveDate');
        lstFGE.add(oFGE32);
        Field_Group_Element__c oFGE33 = new Field_Group_Element__c(
        Field_API_Name__c = 'Alternate_Address_Expiry_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 33,Token_Name__c = 'ReinstatementEffectiveDate');
        lstFGE.add(oFGE33);
        Field_Group_Element__c oFGE34 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Id_For_Data_Load__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 34,Token_Name__c = 'TransferStatus');
        lstFGE.add(oFGE34);
        Field_Group_Element__c oFGE35 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Death_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 35,Token_Name__c = 'TransitionEffectiveDate');
        lstFGE.add(oFGE35);
        Field_Group_Element__c oFGE36 = new Field_Group_Element__c(
        Field_API_Name__c = 'Acceptance_Of_Agreement_Renewal__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'BOOLEAN',JSON_Order__c = 36,Token_Name__c = 'IsTransitioned');
        lstFGE.add(oFGE36);
        return lstFGE;
    }
    
    public static Account createGlobalPartnerData(String sName){
        Id globalPartnerId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, 'Global_Partner');
        Account oAcc = new Account();
        oAcc.Name = 'USA';
        oAcc.RecordTypeId = globalPartnerId;
        return oAcc;
    }
    
    /**
    * Method name  : TaskTestData
    * Description  : This method creates Test Data for Task
    * Return Type  : Task
    * Parameter    : User,Account
    **/
    public static Event EventTestData(User oUser, Account oAccount)
    {
         Datetime dTthirtyMinutesLater = DateTime.newInstance(System.Now().Year(), System.Now().Month(), System.Now().Day(), System.Now()
            .Hour(), System.Now().Minute()+30, System.Now().Second());
        Event oEvent = new Event();
        oEvent.Ownerid = oUser.id;
        oEvent.Subject = 'Test';
        oEvent.Whatid = oAccount.id;
        oEvent.Description = 'Test';
        oEvent.StartDateTime = System.Now();
        oEvent.EndDateTime = dTthirtyMinutesLater;
        return oEvent;
    }
    /* Method name : insertFieldGroupElementForSBC
    * Description  : This method creates Test Data for Field Group Elements 
    * Return Type  : list<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static list<Field_Group_Element__c> insertFieldGroupElementForSBC(Id fieldGroupId){
        list<Field_Group_Element__c> lstFGE = new list<Field_Group_Element__c>();
        Field_Group_Element__c oFG1_FGE1 = new Field_Group_Element__c(Field_API_Name__c =
            'Name', Token_Name__c = 'CompassionSBCId', Field_Type__c = 'TEXT',
            Date_Format__c = 'SFDC Standard', JSON_Order__c = 1, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE1);
        Field_Group_Element__c oFG1_FGE2 = new Field_Group_Element__c(Field_API_Name__c =
            'Local_GP_Kit_ID__c', Token_Name__c = 'GlobalPartnerSBCId', Field_Type__c =
            'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 2, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE2);
        Field_Group_Element__c oFG1_FGE3 = new Field_Group_Element__c(Field_API_Name__c =
            'INT_Source_System__c', Token_Name__c = 'SourceSystem', Field_Type__c =
            'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 3, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE3);
        Field_Group_Element__c oFG1_FGE4 = new Field_Group_Element__c(Field_API_Name__c =
            'RecordType.Name', Token_Name__c = 'Direction', Field_Type__c = 'TEXT',
            Date_Format__c = 'SFDC Standard', JSON_Order__c = 4, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE4);
        Field_Group_Element__c oFG1_FGE5 = new Field_Group_Element__c(Field_API_Name__c =
            'Print_Type_Selected__c', Token_Name__c = 'PrintType', Field_Type__c = 'TEXT',
            Date_Format__c = 'SFDC Standard', JSON_Order__c = 5, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE5);
        Field_Group_Element__c oFG1_FGE6 = new Field_Group_Element__c(Field_API_Name__c =
            'Status__c', Token_Name__c = 'SBCGlobalStatus', Field_Type__c = 'TEXT',
            Date_Format__c = 'SFDC Standard', JSON_Order__c = 6, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE6);
        Field_Group_Element__c oFG1_FGE7 = new Field_Group_Element__c(Field_API_Name__c =
            'Communication_Types__c', Token_Name__c = 'SBCTypes', Field_Type__c = 'TEXT',
            Date_Format__c = 'SFDC Standard', JSON_Order__c = 7, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE7);
        Field_Group_Element__c oFG1_FGE8 = new Field_Group_Element__c(Field_API_Name__c =
            'SUP_Id__r.Correspondence_Language__c', Token_Name__c = 'OriginalLanguage',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 8, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE8);
        Field_Group_Element__c oFG1_FGE9 = new Field_Group_Element__c(Field_API_Name__c =
            'BEN_Id__r.Correspondence_Language__c', Token_Name__c = 'TranslationLanguage',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 9, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE9);
        Field_Group_Element__c oFG1_FGE10 = new Field_Group_Element__c(
            Field_API_Name__c = 'INT_Final_Letter__c', Token_Name__c = 'IsFinalLetter',
            Field_Type__c = 'BOOLEAN', Date_Format__c = 'SFDC Standard', JSON_Order__c =
            10, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE10);
        Field_Group_Element__c oFG1_FGE11 = new Field_Group_Element__c(
            Field_API_Name__c = 'Final_Letter_Archived__c', Token_Name__c =
            'IsFinalLetterArchived', Field_Type__c = 'BOOLEAN', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 11, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE11);
        Field_Group_Element__c oFG1_FGE12 = new Field_Group_Element__c(
            Field_API_Name__c = 'Original_Letter_Archived__c', Token_Name__c =
            'IsOriginalLetterArchived', Field_Type__c = 'BOOLEAN', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 12, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE12);
        Field_Group_Element__c oFG1_FGE13 = new Field_Group_Element__c(
            Field_API_Name__c = 'Original_Mailed__c', Token_Name__c =
            'IsOriginalLetterMailed', Field_Type__c = 'BOOLEAN', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 13, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE13);
        Field_Group_Element__c oFG1_FGE14 = new Field_Group_Element__c(
            Field_API_Name__c = 'Relationship_Type__c', Token_Name__c =
            'RelationshipType', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard',
            JSON_Order__c = 14, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE14);
        Field_Group_Element__c oFG1_FGE15 = new Field_Group_Element__c(
            Field_API_Name__c = 'Attachment_mailed__c', Token_Name__c =
            'ItemNotScannedEligible', Field_Type__c = 'BOOLEAN', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 15, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE15);
        Field_Group_Element__c oFG1_FGE16 = new Field_Group_Element__c(
            Field_API_Name__c = 'Attachment_not_mailed__c', Token_Name__c =
            'ItemNotScannedNotEligible', Field_Type__c = 'BOOLEAN', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 16, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE16);
        Field_Group_Element__c oFG1_FGE17 = new Field_Group_Element__c(
            Field_API_Name__c = 'BEN_Global_ID__c', Token_Name__c =
            'Beneficiary_GlobalId', Field_Type__c = 'TEXT', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 17, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE17);
        Field_Group_Element__c oFG1_FGE18 = new Field_Group_Element__c(
            Field_API_Name__c = 'BEN_Id__r.Compass_Id__c', Token_Name__c =
            'Beneficiary_CompassId', Field_Type__c = 'TEXT', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 18, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE18);
        Field_Group_Element__c oFG1_FGE19 = new Field_Group_Element__c(
            Field_API_Name__c = 'BEN_Local_ID__c', Token_Name__c = 'Beneficiary_LocalId',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 19, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE19);
        Field_Group_Element__c oFG1_FGE20 = new Field_Group_Element__c(
            Field_API_Name__c = 'BEN_Id__r.Name', Token_Name__c = 'Beneficiary_Name',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 20, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE20);
        Field_Group_Element__c oFG1_FGE21 = new Field_Group_Element__c(
            Field_API_Name__c = 'BEN_Id__r.Gender__c', Token_Name__c =
            'Beneficiary_Gender', Field_Type__c = 'TEXT', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 21, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE21);
        Field_Group_Element__c oFG1_FGE22 = new Field_Group_Element__c(
            Field_API_Name__c = 'Ben_Id__r.Age__c', Token_Name__c = 'Beneficiary_Age',
            Field_Type__c = 'INTEGER', Date_Format__c = 'SFDC Standard', JSON_Order__c =
            22, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE22);
        Field_Group_Element__c oFG1_FGE23 = new Field_Group_Element__c(
            Field_API_Name__c = 'SUP_Global_ID__c', Token_Name__c = 'Supporter_GlobalId',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 23, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE23);
        Field_Group_Element__c oFG1_FGE24 = new Field_Group_Element__c(
            Field_API_Name__c = 'GP_Supporter_ID__c', Token_Name__c =
            'Supporter_CompassConstituentId', Field_Type__c = 'TEXT', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 24, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE24);
        Field_Group_Element__c oFG1_FGE25 = new Field_Group_Element__c(
            Field_API_Name__c = 'SUP_Id__r.Mandatory_Review_Flag__c', Token_Name__c =
            'Supporter_MandatoryReviewRequired', Field_Type__c = 'BOOLEAN',
            Date_Format__c = 'SFDC Standard', JSON_Order__c = 25, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE25);
        Field_Group_Element__c oFG1_FGE26 = new Field_Group_Element__c(
            Field_API_Name__c = 'BEN_Id__r.FO__c', Token_Name__c = 'FieldOffice_Name',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 26, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE26);
        Field_Group_Element__c oFG1_FGE27 = new Field_Group_Element__c(
            Field_API_Name__c = 'BEN_Id__r.ICP__r.ICP_Id__c', Token_Name__c = 'ICP_Id',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 27, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE27);
        Field_Group_Element__c oFG1_FGE28 = new Field_Group_Element__c(
            Field_API_Name__c = 'Global_Partner_Id__c', Token_Name__c =
            'GlobalPartner_Id', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard',
            JSON_Order__c = 28, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE28);
        Field_Group_Element__c oFG1_FGE29 = new Field_Group_Element__c(
            Field_API_Name__c = 'SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c',
            Token_Name__c = 'GlobalPartner_OptInForLanguageTranslation', Field_Type__c =
            'BOOLEAN', Date_Format__c = 'SFDC Standard', JSON_Order__c = 29, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE29);
        Field_Group_Element__c oFG1_FGE30 = new Field_Group_Element__c(
            Field_API_Name__c = 'Marked_For_Rework__c', Token_Name__c =
            'IsMarkedForRework', Field_Type__c = 'BOOLEAN', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 30, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE30);
        Field_Group_Element__c oFG1_FGE31 = new Field_Group_Element__c(
            Field_API_Name__c = 'Content_Issues_Found__c', Token_Name__c =
            'ReasonForRework', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard',
            JSON_Order__c = 31, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE31);
        Field_Group_Element__c oFG1_FGE32 = new Field_Group_Element__c(
            Field_API_Name__c = 'Comments__c', Token_Name__c = 'ReworkComments',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 32, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE32);
        Field_Group_Element__c oFG1_FGE33 = new Field_Group_Element__c(
            Field_API_Name__c = 'Translated_By__c', Token_Name__c = 'TranslatedBy',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 33, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE33);
        Field_Group_Element__c oFG1_FGE34 = new Field_Group_Element__c(
            Field_API_Name__c = 'Template_Id__c', Token_Name__c = 'Template',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 34, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE34);
        Field_Group_Element__c oFG1_FGE35 = new Field_Group_Element__c(
            Field_API_Name__c = 'Number_Of_Pages__c', Token_Name__c = 'NumberOfPages',
            Field_Type__c = 'INTEGER', Date_Format__c = 'SFDC Standard', JSON_Order__c =
            35, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE35);
        Field_Group_Element__c oFG1_FGE36 = new Field_Group_Element__c(
            Field_API_Name__c = 'Original_Letter_Link__c', Token_Name__c =
            'OriginalLetterURL', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard',
            JSON_Order__c = 36, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE36);
        Field_Group_Element__c oFG1_FGE37 = new Field_Group_Element__c(
            Field_API_Name__c = 'Final_Composed_Letter_Link__c', Token_Name__c =
            'FinalLetterURL', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard',
            JSON_Order__c = 37, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE37);
        Field_Group_Element__c oFG1_FGE38 = new Field_Group_Element__c(
            Field_API_Name__c = 'Original_Text__c', Token_Name__c = 'OriginalText',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 38, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE38);
        Field_Group_Element__c oFG1_FGE39 = new Field_Group_Element__c(
            Field_API_Name__c = 'Translated_Text_English__c', Token_Name__c =
            'EnglishTranslatedText', Field_Type__c = 'TEXT', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 39, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE39);
        Field_Group_Element__c oFG1_FGE40 = new Field_Group_Element__c(
            Field_API_Name__c = 'Final_Translated_Text__c', Token_Name__c =
            'TranslatedText', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard',
            JSON_Order__c = 40, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE40);
        Field_Group_Element__c oFG1_FGE41 = new Field_Group_Element__c(
            Field_API_Name__c = 'Transaction_Id__c', Token_Name__c =
            'Internal_Perceptive_TransactionId', Field_Type__c = 'TEXT', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 41, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE41);
        Field_Group_Element__c oFG1_FGE42 = new Field_Group_Element__c(
            Field_API_Name__c = 'SUP_Id__r.Preferred_Name__pc', Token_Name__c =
            'Supporter_PreferredName', Field_Type__c = 'TEXT', Date_Format__c =
            'SFDC Standard', JSON_Order__c = 42, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE42);
        Field_Group_Element__c oFG1_FGE43 = new Field_Group_Element__c(
            Field_API_Name__c = 'SUP_Id__r.Gender__c', Token_Name__c = 'Supporter_Gender',
            Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 43, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE43);
        Field_Group_Element__c oFG1_FGE44 = new Field_Group_Element__c(
            Field_API_Name__c = 'SUP_Id__r.Delivery_Preference__c', Token_Name__c =
            'Supporter_CommunicationDeliveryPreference', Field_Type__c = 'TEXT',
            Date_Format__c = 'SFDC Standard', JSON_Order__c = 44, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE44);
        
        return lstFGE;
    }
     /* Method name  : ILETestData
    * Description  : This method creates Test Data for ICP Lifecycle Event 
    * Return Type  : list<ICP_Lifecycle_Events__c>
    * Parameter    : list<Account>
    **/
    public static list<ICP_Lifecycle_Events__c> ILESuspensionTestData(list<Account> ICPList)
    {
        list<ICP_Lifecycle_Events__c> ILEList = new list<ICP_Lifecycle_Events__c>();
        list<Account> icp = [select id, Name from Account where id in: ICPList];
        Id icpLifecycleSuspensionRecTypeId = Utility.getRecordTypeIdByDeveloperName(ICP_Lifecycle_Events__c.SObjectType, Constants.SUSPENSION_RT_API_NAME);
        Id icpLifecycleTransitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(ICP_Lifecycle_Events__c.SObjectType,Constants.TRANSITION_ICP_LIFECYCLE_EVENTS_RT_API_NAME);
        Id icpLifecycleReactivationRecTypeId = Utility.getRecordTypeIdByDeveloperName(ICP_Lifecycle_Events__c.SObjectType,Constants.REACTIVATION_ICP_LIFECYCLE_EVENTS_RT_API_NAME);
        ICP_Lifecycle_Events__c suspension = new ICP_Lifecycle_Events__c();
        suspension.ICP__c = icp[0].id;
        suspension.Suspension_Start_Date__c = System.today();
        suspension.RecordTypeId = icpLifecycleSuspensionRecTypeId; 
        suspension.Suspension_Reasons__c = 'Disaster event';
        ILEList.add(suspension);
        return ILEList;
        }
        
        
    public static void insertRecTypeMappingCustSetting(){
        list<Record_Type_Mapping_For_SBC_Integration__c> lstRecTypeMapping = new list<Record_Type_Mapping_For_SBC_Integration__c>();
        lstRecTypeMapping.add(new Record_Type_Mapping_For_SBC_Integration__c(Name = 'B2S', RecordType_Name_For_Integration__c = 'Beneficiary To Supporter'));
        lstRecTypeMapping.add(new Record_Type_Mapping_For_SBC_Integration__c(Name = 'S2B', RecordType_Name_For_Integration__c = 'Supporter To Beneficiary'));
        insert lstRecTypeMapping;
    }
    
    public static list<Field_Group_Element__c> insertFieldGroupElementForSBC2(Id fieldGroupId){
        list<Field_Group_Element__c> lstFGE = new list<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(Field_API_Name__c = 'INT_Communication_Kit_Id__c', Token_Name__c = 'CompassionSBCId', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 1, Field_Group__c = fieldGroupId); lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(Field_API_Name__c = 'Local_GP_Kit_ID__c', Token_Name__c = 'GlobalPartnerSBCId', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 2, Field_Group__c = fieldGroupId); lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(Field_API_Name__c = 'INT_Source_System__c', Token_Name__c = 'SourceSystem', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 3, Field_Group__c = fieldGroupId); lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c(Field_API_Name__c = 'INT_RecordType_Name__c', Token_Name__c = 'Direction', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 4, Field_Group__c = fieldGroupId); lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c(Field_API_Name__c = 'Print_Type_Selected__c', Token_Name__c = 'PrintType', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 5, Field_Group__c = fieldGroupId); lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c(Field_API_Name__c = 'Status__c', Token_Name__c = 'SBCGlobalStatus', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 6, Field_Group__c = fieldGroupId); lstFGE.add(oFGE6);
        Field_Group_Element__c oFGE7 = new Field_Group_Element__c(Field_API_Name__c = 'Communication_Types__c', Token_Name__c = 'SBCTypes', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 7, Field_Group__c = fieldGroupId); lstFGE.add(oFGE7);
        Field_Group_Element__c oFGE8 = new Field_Group_Element__c(Field_API_Name__c = 'Final_Letter_Archived__c', Token_Name__c = 'IsFinalLetterArchived', Field_Type__c = 'BOOLEAN', Date_Format__c = 'SFDC Standard', JSON_Order__c = 8, Field_Group__c = fieldGroupId); lstFGE.add(oFGE8);
        Field_Group_Element__c oFGE9 = new Field_Group_Element__c(Field_API_Name__c = 'Original_Letter_Archived__c', Token_Name__c = 'IsOriginalLetterArchived', Field_Type__c = 'BOOLEAN', Date_Format__c = 'SFDC Standard', JSON_Order__c = 9, Field_Group__c = fieldGroupId); lstFGE.add(oFGE9);
        Field_Group_Element__c oFGE10 = new Field_Group_Element__c(Field_API_Name__c = 'Original_Mailed__c', Token_Name__c = 'IsOriginalLetterMailed', Field_Type__c = 'BOOLEAN', Date_Format__c = 'SFDC Standard', JSON_Order__c = 10, Field_Group__c = fieldGroupId); lstFGE.add(oFGE10);
        Field_Group_Element__c oFGE11 = new Field_Group_Element__c(Field_API_Name__c = 'Relationship_Type__c', Token_Name__c = 'RelationshipType', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 11, Field_Group__c = fieldGroupId); lstFGE.add(oFGE11);
        Field_Group_Element__c oFGE12 = new Field_Group_Element__c(Field_API_Name__c = 'Attachment_Mailed__c', Token_Name__c = 'ItemNotScannedEligible', Field_Type__c = 'BOOLEAN', Date_Format__c = 'SFDC Standard', JSON_Order__c = 12, Field_Group__c = fieldGroupId); lstFGE.add(oFGE12);
        Field_Group_Element__c oFGE13 = new Field_Group_Element__c(Field_API_Name__c = 'Attachment_Not_Mailed__c', Token_Name__c = 'ItemNotScannedNotEligible', Field_Type__c = 'BOOLEAN', Date_Format__c = 'SFDC Standard', JSON_Order__c = 13, Field_Group__c = fieldGroupId); lstFGE.add(oFGE13);
        Field_Group_Element__c oFGE14 = new Field_Group_Element__c(Field_API_Name__c = 'BEN_INT_Id__c', Token_Name__c = 'Beneficiary_GlobalId', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 14, Field_Group__c = fieldGroupId); lstFGE.add(oFGE14);
        Field_Group_Element__c oFGE15 = new Field_Group_Element__c(Field_API_Name__c = 'COMPASS_child_id__c', Token_Name__c = 'Beneficiary_CompassId', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 15, Field_Group__c = fieldGroupId); lstFGE.add(oFGE15);
        Field_Group_Element__c oFGE16 = new Field_Group_Element__c(Field_API_Name__c = 'BEN_INT_Local_Id__c', Token_Name__c = 'Beneficiary_LocalId', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 16, Field_Group__c = fieldGroupId); lstFGE.add(oFGE16);
        Field_Group_Element__c oFGE17 = new Field_Group_Element__c(Field_API_Name__c = 'SUP_INT_Id__c', Token_Name__c = 'Supporter_GlobalId', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 17, Field_Group__c = fieldGroupId); lstFGE.add(oFGE17);
        Field_Group_Element__c oFGE18 = new Field_Group_Element__c(Field_API_Name__c = 'COMPASS_con_pk__c', Token_Name__c = 'Supporter_CompassConstituentId', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 18, Field_Group__c = fieldGroupId); lstFGE.add(oFGE18);
        Field_Group_Element__c oFGE19 = new Field_Group_Element__c(Field_API_Name__c = 'Marked_For_Rework__c', Token_Name__c = 'IsMarkedForRework', Field_Type__c = 'BOOLEAN', Date_Format__c = 'SFDC Standard', JSON_Order__c = 19, Field_Group__c = fieldGroupId); lstFGE.add(oFGE19);
        Field_Group_Element__c oFGE20 = new Field_Group_Element__c(Field_API_Name__c = 'Content_Issues_Found__c', Token_Name__c = 'ReasonForRework', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 20, Field_Group__c = fieldGroupId); lstFGE.add(oFGE20);
        Field_Group_Element__c oFGE21 = new Field_Group_Element__c(Field_API_Name__c = 'Comments__c', Token_Name__c = 'ReworkComments', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 21, Field_Group__c = fieldGroupId); lstFGE.add(oFGE21);
        Field_Group_Element__c oFGE22 = new Field_Group_Element__c(Field_API_Name__c = 'Translated_By__c', Token_Name__c = 'TranslatedBy', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 22, Field_Group__c = fieldGroupId); lstFGE.add(oFGE22);
        Field_Group_Element__c oFGE23 = new Field_Group_Element__c(Field_API_Name__c = 'Template_Id__c', Token_Name__c = 'Template', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 23, Field_Group__c = fieldGroupId); lstFGE.add(oFGE23);
        Field_Group_Element__c oFGE24 = new Field_Group_Element__c(Field_API_Name__c = 'Number_Of_Pages__c', Token_Name__c = 'NumberOfPages', Field_Type__c = 'INTEGER', Date_Format__c = 'SFDC Standard', JSON_Order__c = 24, Field_Group__c = fieldGroupId); lstFGE.add(oFGE24);
        Field_Group_Element__c oFGE25 = new Field_Group_Element__c(Field_API_Name__c = 'Original_Letter_Link__c', Token_Name__c = 'OriginalLetterURL', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 25, Field_Group__c = fieldGroupId); lstFGE.add(oFGE25);
        Field_Group_Element__c oFGE26 = new Field_Group_Element__c(Field_API_Name__c = 'Final_Composed_Letter_Link__c', Token_Name__c = 'FinalLetterURL', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 26, Field_Group__c = fieldGroupId); lstFGE.add(oFGE26);
        Field_Group_Element__c oFGE27 = new Field_Group_Element__c(Field_API_Name__c = 'Original_Text__c', Token_Name__c = 'OriginalText', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 27, Field_Group__c = fieldGroupId); lstFGE.add(oFGE27);
        Field_Group_Element__c oFGE28 = new Field_Group_Element__c(Field_API_Name__c = 'Translated_Text_English__c', Token_Name__c = 'EnglishTranslatedText', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 28, Field_Group__c = fieldGroupId); lstFGE.add(oFGE28);
        Field_Group_Element__c oFGE29 = new Field_Group_Element__c(Field_API_Name__c = 'Final_Translated_Text__c', Token_Name__c = 'TranslatedText', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 29, Field_Group__c = fieldGroupId); lstFGE.add(oFGE29);
        Field_Group_Element__c oFGE30 = new Field_Group_Element__c(Field_API_Name__c = 'Transaction_Id__c', Token_Name__c = 'Internal_Perceptive_TransactionId', Field_Type__c = 'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 30, Field_Group__c = fieldGroupId); lstFGE.add(oFGE30);
        return lstFGE;
    }
    /**
    * Method name  : SolutionTestData
    * Description  : This method creates Test Data for Solution
    * Return Type  : Solution
    * Parameter    : NA
    **/
    public static Solution SolutionTestData()
    {
        Solution oSol= new Solution();
        oSol.SolutionName='testsolution';
        //oSol.CurrencyIsoCode='USD-U.S.Dollar';
        return oSol;
    }
    /**
    * Method name  : sendBLEfInforToAMFGElementsTestData
    * Description  : This method creates Test Data for Field Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> sendBLEfInforToAMFGElementsTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Thumbnail_URL__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c = 'Thumbnail');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'Last_Attended_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 2,Token_Name__c = 'ExitEffectiveDate');
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Available_For_Marketing_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 3,Token_Name__c = 'AvailableForMarketingDate');
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c(
        Field_API_Name__c = 'Associated_ICP_ID__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 4,Token_Name__c = 'SFDCBeneficiaryLink');
        lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.PersonBirthdate',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 5,Token_Name__c = 'Beneficiary__r.PersonBirthdate');
        lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.FirstName',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 6,Token_Name__c = 'FirstName');
        lstFGE.add(oFGE6);
        Field_Group_Element__c oFGE7 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Gender__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 7,Token_Name__c = 'Gender');
        lstFGE.add(oFGE7);
        Field_Group_Element__c oFGE8 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Global_Number__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 8,Token_Name__c = 'BeneficiaryGlobalId');
        lstFGE.add(oFGE8);
        Field_Group_Element__c oFGE9 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Is_Orphan__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'BOOLEAN',JSON_Order__c = 9,Token_Name__c = 'IsOrphan');
        lstFGE.add(oFGE9);
        Field_Group_Element__c oFGE10 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.LastName',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 10,Token_Name__c = 'LastName');
        lstFGE.add(oFGE10);
        Field_Group_Element__c oFGE11 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Beneficiary_Last_Review_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 11,Token_Name__c = 'LastReviewDate');
        lstFGE.add(oFGE11);
        Field_Group_Element__c oFGE12 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Local_Beneficiary_ID__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 12,Token_Name__c = 'Beneficiary__r.Local_Beneficiary_ID__c');
        lstFGE.add(oFGE12);
        Field_Group_Element__c oFGE13 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Preferred_Name__pc',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 13,Token_Name__c = 'PreferredlName');
        lstFGE.add(oFGE13);
        Field_Group_Element__c oFGE14 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Religious_Affiliation__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 14,Token_Name__c = 'ReligiousAffiliation');
        lstFGE.add(oFGE14);
        Field_Group_Element__c oFGE15 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.BEN_Last_Wrote__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 15,Token_Name__c = 'LetterLastWrittenDate');
        lstFGE.add(oFGE15);
        Field_Group_Element__c oFGE16 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Planned_Completion_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 16,Token_Name__c = 'PlannedCompletionDate');
        lstFGE.add(oFGE16);
        Field_Group_Element__c oFGE17 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Chronic_Illnesses__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 17,Token_Name__c = 'ChronicIllness');
        lstFGE.add(oFGE17);
        Field_Group_Element__c oFGE18 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Cluster_Name__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 18,Token_Name__c = 'Cluster');
        lstFGE.add(oFGE18);
        Field_Group_Element__c oFGE19 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Country_of_Citizenship__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 19,Token_Name__c = 'Country');
        lstFGE.add(oFGE19);
        Field_Group_Element__c oFGE20 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Household__r.Natural_Father_IsAlive__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 20,Token_Name__c = 'NaturalFatherAlive');
        lstFGE.add(oFGE20);
        Field_Group_Element__c oFGE21 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Household__r.Natural_Mother_IsAlive__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 21,Token_Name__c = 'NaturalMotherAlive');
        lstFGE.add(oFGE21);
        Field_Group_Element__c oFGE22 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Household__r.Total_Family_Males_18__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 22,Token_Name__c = 'NumberOfBrothersUnder18');
        lstFGE.add(oFGE22);
        Field_Group_Element__c oFGE23 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Household__r.Total_Family_Females__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'INTEGER',JSON_Order__c = 23,Token_Name__c = 'NumberOfSistersUnder18');
        lstFGE.add(oFGE23);
        Field_Group_Element__c oFGE24 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Household__r.Marital_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 24,Token_Name__c = 'ParentsMaritalStatus');
        lstFGE.add(oFGE24);
        Field_Group_Element__c oFGE25 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.ICP__r.ICP_Id__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 25,Token_Name__c = 'ICP_Id');
        lstFGE.add(oFGE25);
        Field_Group_Element__c oFGE26 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Physical_Disabilities__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 26,Token_Name__c = 'PhysicalDisability');
        lstFGE.add(oFGE26);
        Field_Group_Element__c oFGE27 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.ICP__r.Cluster__r.Territory__r.Name',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 27,Token_Name__c = 'Territory');
        lstFGE.add(oFGE27);
        Field_Group_Element__c oFGE28 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.PO_Number__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 28,Token_Name__c = 'OrderNumber');
        lstFGE.add(oFGE28);
        Field_Group_Element__c oFGE29 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Actual_Registration_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 29,Token_Name__c = 'RegistrationEffectiveDate');
        lstFGE.add(oFGE29);
        Field_Group_Element__c oFGE30 = new Field_Group_Element__c(
        Field_API_Name__c = 'Date_Of_Reinstatement__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 30,Token_Name__c = 'ReinstatementEffectiveDate');
        lstFGE.add(oFGE30);
        Field_Group_Element__c oFGE31 = new Field_Group_Element__c(
        Field_API_Name__c = 'Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 31,Token_Name__c = 'TransferStatus');
        lstFGE.add(oFGE31);
        Field_Group_Element__c oFGE32 = new Field_Group_Element__c(
        Field_API_Name__c = 'Date_Of_Action__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 32,Token_Name__c = 'TransitionEffectiveDate');
        lstFGE.add(oFGE32);
        Field_Group_Element__c oFGE33 = new Field_Group_Element__c(
        Field_API_Name__c = 'Has_Beneficiary__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'BOOLEAN',JSON_Order__c = 33,Token_Name__c = 'IsTransitioned');
        lstFGE.add(oFGE33);
        Field_Group_Element__c oFGE34 = new Field_Group_Element__c(
        Field_API_Name__c = 'Reason_For_Request__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 34,Token_Name__c = 'BLERequestReason');
        lstFGE.add(oFGE34);
        Field_Group_Element__c oFGE35 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.Correspondence_Language__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 35,Token_Name__c = 'CorrespondenceLanguage');
        lstFGE.add(oFGE35);
        Field_Group_Element__c oFGE36 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary__r.FO__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 36,Token_Name__c = 'FieldOffice_Name');
        lstFGE.add(oFGE36);
        return lstFGE;
    
    }
    /**
    * Method name  : sendBenefInfoToUSFGElementsTestData
    * Description  : This method creates Test Data for Field Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> sendBenefInfoToUSFGElementsTestData(Id fieldGroupId)
    {
    List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'FirstName',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c = 'FirstName');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'LastName',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 2,Token_Name__c = 'LastName');
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(
        Field_API_Name__c = 'Local_Beneficiary_ID__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 3,Token_Name__c = 'LocalBeneficiaryId');
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c(
        Field_API_Name__c = 'Global_Number__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 4,Token_Name__c = 'BeneficiaryGlobalID');
        lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c(
        Field_API_Name__c = 'Compass_Id__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 5,Token_Name__c = 'CompassID');
        lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c(
        Field_API_Name__c = 'Sponsorship_Status__pc',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 6,Token_Name__c = 'SponsorshipStatus');
        lstFGE.add(oFGE6);
        Field_Group_Element__c oFGE7 = new Field_Group_Element__c(
        Field_API_Name__c = 'PersonBirthdate',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 7,Token_Name__c = 'Birthdate');
        lstFGE.add(oFGE7);
        Field_Group_Element__c oFGE8 = new Field_Group_Element__c(
        Field_API_Name__c = 'BillingCountry',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 8,Token_Name__c = 'Country');
        lstFGE.add(oFGE8);
        Field_Group_Element__c oFGE9 = new Field_Group_Element__c(
        Field_API_Name__c = 'FO__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 9,Token_Name__c = 'FieldOffice');
        lstFGE.add(oFGE9);
        Field_Group_Element__c oFGE10 = new Field_Group_Element__c(
        Field_API_Name__c = 'Gender__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 10,Token_Name__c = 'Gender');
        lstFGE.add(oFGE10);
        Field_Group_Element__c oFGE11 = new Field_Group_Element__c(
        Field_API_Name__c = 'Correspondence_Language__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 11,Token_Name__c = 'CorrespondenceLanguage');
        lstFGE.add(oFGE11);
        Field_Group_Element__c oFGE12 = new Field_Group_Element__c(
        Field_API_Name__c = 'ICP__r.Name',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 12,Token_Name__c = 'ICP');
        lstFGE.add(oFGE12);
        Field_Group_Element__c oFGE13 = new Field_Group_Element__c(
        Field_API_Name__c = 'Beneficiary_Status__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 13,Token_Name__c = 'BeneficiaryStatus');
        lstFGE.add(oFGE13);
        Field_Group_Element__c oFGE14 = new Field_Group_Element__c(
        Field_API_Name__c = 'Church_Name_Local_Language__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 14,Token_Name__c = 'SupporterGlobalPartner');
        lstFGE.add(oFGE14);
        
        return lstFGE;
    }
/**
    * Method name  : resourceTestData
    * Description  : This method creates Test Data for staticResouce
    * Return Type  : list<StaticResource>
    **/
    public static list<StaticResource> resourceTestData()
    {
        list<StaticResource> lstTest = new list<StaticResource>();
        StaticResource testStaticRsc = new StaticResource();
        testStaticRsc.name ='test1';
        lstTest.add(testStaticRsc);
        return lstTest;
    }  
    /**
    * Method name  : CommitmentUpdatesFGElementsTestData
    * Description  : This method creates Test Data for Field Group Element
    * Return Type  : List<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static List<Field_Group_Element__c> CommitmentUpdatesFGElementsTestData(Id fieldGroupId)
    {
        List<Field_Group_Element__c> lstFGE = new List<Field_Group_Element__c>();
        Field_Group_Element__c oFGE1 = new Field_Group_Element__c(
        Field_API_Name__c = 'COMPASS_cm_pk__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 1,Token_Name__c = 'LegacyCommitmentId');
        lstFGE.add(oFGE1);
        Field_Group_Element__c oFGE2 = new Field_Group_Element__c(
        Field_API_Name__c = 'COMPASS_con_pk__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 2,Token_Name__c = 'LegacySupporterId');
        lstFGE.add(oFGE2);
        Field_Group_Element__c oFGE3 = new Field_Group_Element__c(
        Field_API_Name__c = 'COMPASS_child_id__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 3,Token_Name__c = 'LegacyBeneficiaryId');
        lstFGE.add(oFGE3);
        Field_Group_Element__c oFGE4 = new Field_Group_Element__c(
        Field_API_Name__c = 'BEN_INT_Global_ID__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 4,Token_Name__c = 'GlobalBeneficiaryId');
        lstFGE.add(oFGE4);
        Field_Group_Element__c oFGE5 = new Field_Group_Element__c(
        Field_API_Name__c = 'Relationship_Type__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 5,Token_Name__c = 'RelationshipType');
        lstFGE.add(oFGE5);
        Field_Group_Element__c oFGE6 = new Field_Group_Element__c(
        Field_API_Name__c = 'SUP_INT_Global_ID__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 6,Token_Name__c = 'GlobalSupporterId');
        lstFGE.add(oFGE6);
        Field_Group_Element__c oFGE7 = new Field_Group_Element__c(
        Field_API_Name__c = 'Start_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 7,Token_Name__c = 'StartDate');
        lstFGE.add(oFGE7);
        Field_Group_Element__c oFGE8 = new Field_Group_Element__c(
        Field_API_Name__c = 'End_Date__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'DATE',JSON_Order__c = 8,Token_Name__c = 'EndDate');
        lstFGE.add(oFGE8);
        Field_Group_Element__c oFGE9 = new Field_Group_Element__c(
        Field_API_Name__c = 'Supporter_Correspondence_Language__c',Field_Group__c = fieldGroupId,
        Field_Type__c = 'TEXT',JSON_Order__c = 9,Token_Name__c = 'CorrespondenceLanguage');
        lstFGE.add(oFGE9);
        return lstFGE;
    }
    /* Method name : CreateGiftResponsesFieldGroupElementForSBC
    * Description  : This method creates Test Data for Field Group Elements 
    * Return Type  : list<Field_Group_Element__c>
    * Parameter    : Id
    **/
    public static list<Field_Group_Element__c> CreateGiftResponsesFieldGroupElementForSBC(Id fieldGroupId){
        list<Field_Group_Element__c> lstFGE = new list<Field_Group_Element__c>();
        Field_Group_Element__c oFG1_FGE1 = new Field_Group_Element__c(Field_API_Name__c =
            'COMPASS_con_pk__c', Token_Name__c = 'LegacySupporterId', Field_Type__c = 'TEXT',
            Date_Format__c = 'SFDC Standard', JSON_Order__c = 1, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE1);
        Field_Group_Element__c oFG1_FGE2 = new Field_Group_Element__c(Field_API_Name__c =
            'INT_Communication_Kit_Id__c', Token_Name__c = 'LegacyBeneficiaryId', Field_Type__c =
            'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 2, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE2);
        Field_Group_Element__c oFG1_FGE3 = new Field_Group_Element__c(Field_API_Name__c =
            'INT_RecordType_Name__c', Token_Name__c = 'GiftAmount', Field_Type__c =
            'TEXT', Date_Format__c = 'SFDC Standard', JSON_Order__c = 3, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE3);
        Field_Group_Element__c oFG1_FGE4 = new Field_Group_Element__c(Field_API_Name__c =
            'SUP_INT_Id__c', Token_Name__c = 'GlobalSupporterId', Field_Type__c = 'TEXT',
            Date_Format__c = 'SFDC Standard', JSON_Order__c = 4, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE4);
        Field_Group_Element__c oFG1_FGE5 = new Field_Group_Element__c(Field_API_Name__c =
            'BEN_INT_Id__c', Token_Name__c = 'GlobalBeneficiaryId', Field_Type__c = 'TEXT',
            Date_Format__c = 'SFDC Standard', JSON_Order__c = 5, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE5);
         Field_Group_Element__c oFG1_FGE6 = new Field_Group_Element__c(Field_API_Name__c =
            'BEN_INT_Local_Id__c', Token_Name__c = 'LocalBeneficiaryId', Field_Type__c = 'TEXT',
            Date_Format__c = 'SFDC Standard', JSON_Order__c = 6, Field_Group__c = fieldGroupId);
        lstFGE.add(oFG1_FGE6);
        return lstFGE;
    }                 
}