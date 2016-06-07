/******************************************************************************************************
Class Name         : PMATFormNewPrintExtension_Test
Description        : This class contains unit tests for validating the behavior of Apex class: PmatFormNewExtension
Created By         : Akashdeep 
Created On         : 7-Oct-2015 
*******************************************************************************************************/
@IsTest(SeeAllData=false) 
private class PMATFormNewPrintExtension_Test 
{
    static testMethod void verifyPmatFormNewPrintExtension() 
    {
        List<string> lstRegionNames = new List<String> (  ) ; 
        lstRegionNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstRegionTestData = TestDataUtility.regionTestData( lstRegionNames ) ;
        insert lstRegionTestData ;  
        List<string> lstFieldOfficeNames = new List<String> (  ) ; 
        lstFieldOfficeNames.add( 'testFieldOffice' ) ; 
        list<Account> lstFieldOfficeData = TestDataUtility.FieldofficeTestData( lstFieldOfficeNames ) ;
        lstFieldOfficeData[0].Region__c = lstRegionTestData[0].ID ;   
        insert lstFieldOfficeData ;      
        List<string> lstTerritoryNames = new List<String> (  ) ; 
        lstTerritoryNames.add( 'testRegion' ) ; 
        list<PM_Hierarchy__c> lstTerritoryTestData = TestDataUtility.TerritoryTestData( lstTerritoryNames ) ;
        lstTerritoryTestData[0].Field_Office__c = lstFieldOfficeData[0].ID ;
        List<string> lstClusterNames = new List<String> (  ) ; 
        lstClusterNames.add( 'testCluster' ) ; 
        list<PM_Hierarchy__c> lstClusterTestData = TestDataUtility.ClusterTestData( lstClusterNames ) ;
        lstClusterTestData[0].Territory__c = lstTerritoryTestData[0].ID ;
        insert lstClusterTestData ;
        Account oICPAccount = TestDataUtility.ICPTestData() ;
        oICPAccount.Cluster__c = lstClusterTestData[0].ID ;    
        insert oICPAccount ; 
       System.assertNotEquals(null,oICPAccount.id);
        
        Contact contactGP = new Contact(FirstName = 'Bob', LastName = 'Phillip', AccountId = oICPAccount.Id);
        insert contactGP;
         System.assertNotEquals(null,contactGP.id);       
        PMAT_Cluster_Measure__c PCM = new PMAT_Cluster_Measure__c();
        PCM.Outcome_Number__c =  '1: Demonstrate Effective Vision and Leadership';
        PCM.Indicator_Number__c = '1.1: ICP reflects strong partner church vision and values.';
        PCM.Measure_Number__c = 'Measure 1.1.1';
        PCM.Text_Position__c = 'Developing Partnership Stage Text';
        PCM.Measurement_Label__c = null;
        PCM.Field_Hierarchy__c = oICPAccount.Cluster__c;
        
        PMAT_Cluster_Measure__c PCM2 = new PMAT_Cluster_Measure__c();
        PCM2.Outcome_Number__c =  '1: Demonstrate Effective Vision and Leadership';
        PCM2.Indicator_Number__c = '1.1: ICP reflects strong partner church vision and values.';
        PCM2.Measure_Number__c = 'Measure 1.1.1';
        PCM2.Text_Position__c = 'Developing Partnership Stage Text';
        PCM2.Measurement_Label__c = 'Test';
        PCM2.Field_Hierarchy__c = oICPAccount.Cluster__c;
        
        List<PMAT_Cluster_Measure__c> lstPCM = new List<PMAT_Cluster_Measure__c>();
        lstPCM.add(PCM);
        lstPCM.add(PCM2);
        insert lstPCM;
        System.assertNotEquals(null,lstPCM);
        
        
        
        
        Test.StartTest() ; 
            ApexPages.StandardController stdConAcc = new ApexPages.StandardController(new PMAT_Assessment__c()) ;
            PMATFormNewPrintExtension testPMATPrintExtn = new PMATFormNewPrintExtension(stdConAcc) ; 
            testPMATPrintExtn.oCurrPMAT = new PMAT_Assessment__c();
            testPMATPrintExtn.oCurrPMAT.PMAT_Assessment_Start_Date__c = Date.newInstance( 2015, 10, 10 );
            testPMATPrintExtn.oCurrPMAT.PMAT_Assessment_End_Date__c = Date.newInstance( 2015, 10, 20 );
            testPMATPrintExtn.oCurrPMAT.PMAT_ICP_Representative__c = contactGP.id;
            
            testPMATPrintExtn.oCurrPMAT.Account_Name__c = oICPAccount.id;
            insert testPMATPrintExtn.oCurrPMAT;
            
            testPMATPrintExtn.oChildRecCI = new PMAT__c();
            testPMATPrintExtn.oChildRecCI.PMAT_Status__c = Constants.PMAT_Discussion;
            testPMATPrintExtn.oChildRecCI.PMAT_Type__c = Constants.Comp_Label;
            testPMATPrintExtn.oChildRecCI.PMAT_Assessment__c = testPMATPrintExtn.oCurrPMAT.id;
            insert testPMATPrintExtn.oChildRecCI;
            testPMATPrintExtn.ShowNextAssessDateField();
            testPMATPrintExtn.oCurrPMAT.FO_Created_ICP_Form__c = true;
            update testPMATPrintExtn.oCurrPMAT;
            testPMATPrintExtn.LoadPageInstance();
            
            testPMATPrintExtn.oChildRecICP = new PMAT__c();
            testPMATPrintExtn.oChildRecICP.PMAT_Type__c = Constants.ICP_Label;
            testPMATPrintExtn.oChildRecICP.PMAT_Assessment__c = testPMATPrintExtn.oCurrPMAT.id;
            testPMATPrintExtn.oChildRecICP.PMAT_Status__c = Constants.PMAT_Discussion;  
            insert testPMATPrintExtn.oChildRecICP;            
            testPMATPrintExtn.LoadPageInstance();          
            
            Pagereference pg1 = new PageReference( '/apex/PMATFormNewPrint?id='+testPMATPrintExtn.oCurrPMAT.id +'&retUrl') ;
            Test.setCurrentPage(pg1) ;    
            testPMATPrintExtn.oChildRecCI.PMAT_Status__c = Constants.PMAT_Complete;
            testPMATPrintExtn.oChildRecICP.PMAT_Status__c = Constants.PMAT_Complete;
            update testPMATPrintExtn.oChildRecCI;
            update testPMATPrintExtn.oChildRecICP;
            testPMATPrintExtn.LoadPageInstance();
            testPMATPrintExtn.ShowNextAssessDateField();                    
        Test.StopTest() ;       
    } 
    
    
    
    
    static testMethod void verifyPmatFormNewExtensionAsICP()
    {
        Account oICPAccount1 = TestDataUtility.ICPTestData() ;
        insert oICPAccount1 ; 
        System.assertNotEquals(null,oICPAccount1.id);
        Contact oConTestnew = new Contact (LastName = 'test contactnew', FirstName = 'test' , AccountID = oICPAccount1.ID ) ; 
        Insert oConTestnew ;
        System.assertNotEquals(null,oConTestnew.id);
        /*
        User oUser3 = TestDataUtility.UserTestData(Constants.ICP_FULL_ACCESS_PROFILE,'Community', NULL);
        oUser3.ContactId = oConTestnew.Id ; 
        
        insert oUser3; 
        */
        ApexPages.StandardController stdConAcc = new ApexPages.StandardController(new PMAT_Assessment__c()) ;
        
        PmatFormNewPrintExtension testPMATPrintExtn = new PmatFormNewPrintExtension(stdConAcc) ; 
        testPMATPrintExtn.oCurrPMAT = new PMAT_Assessment__c();
        testPMATPrintExtn.oCurrPMAT.PMAT_Assessment_Start_Date__c = Date.newInstance( 2015, 10, 10 );
        testPMATPrintExtn.oCurrPMAT.PMAT_Assessment_End_Date__c = Date.newInstance( 2015, 10, 20 );
        testPMATPrintExtn.oCurrPMAT.PMAT_ICP_Representative__c = oConTestnew.id;
        testPMATPrintExtn.oCurrPMAT.Account_Name__c = oICPAccount1.id;
        
        
        insert testPMATPrintExtn.oCurrPMAT;
        
        testPMATPrintExtn.oChildRecICP = new PMAT__c();
        testPMATPrintExtn.oChildRecICP.PMAT_Type__c = Constants.ICP_Label;
        testPMATPrintExtn.oChildRecICP.PMAT_Assessment__c = testPMATPrintExtn.oCurrPMAT.id;
        
        testPMATPrintExtn.oChildRecICP.PMAT_Status__c = Constants.PMAT_Discussion;            
        testPMATPrintExtn.oChildRecICP.Christ_Mutual_Identity_Church__c= '3'; testPMATPrintExtn.oChildRecICP.Christ_Mutual_Identity_Compassion__c= '1'; 
        testPMATPrintExtn.oChildRecICP.Mutual_Respect_Benefit_Compassion__c= '3'; testPMATPrintExtn.oChildRecICP.Mutual_Respect_Benefit_Church__c= '4'; 
        testPMATPrintExtn.oChildRecICP.Responsibilty_Commitment_Compassion__c= '5'; testPMATPrintExtn.oChildRecICP.Responsibilty_Commitment_Church__c= '1'; 
        testPMATPrintExtn.oChildRecICP.Transformation_Outcomes_Compassion__c= '4'; testPMATPrintExtn.oChildRecICP.Transformation_Outcomes_Church__c= '6'; 
        testPMATPrintExtn.oChildRecICP.Address_Outcomes_Standards_M1__c= '5'; testPMATPrintExtn.oChildRecICP.Address_Outcomes_Standards_M2__c= '4'; 
        testPMATPrintExtn.oChildRecICP.Address_Outcomes_Standards_M3__c= '3'; testPMATPrintExtn.oChildRecICP.Effective_Annual_Plans_M1__c= '2'; 
        testPMATPrintExtn.oChildRecICP.Effective_Annual_Plans_M2__c= '1'; testPMATPrintExtn.oChildRecICP.Effective_Annual_Plans_M3__c= '2'; 
        testPMATPrintExtn.oChildRecICP.Implements_Curriculum_Effectively_M1__c= '4'; testPMATPrintExtn.oChildRecICP.Implements_Curriculum_Effectively_M2__c= '5';
        testPMATPrintExtn.oChildRecICP.Implements_Curriculum_Effectively_M3__c= '6'; testPMATPrintExtn.oChildRecICP.Advocates_Children_Caregiver_M1__c= '1'; 
        testPMATPrintExtn.oChildRecICP.Advocates_Children_Caregiver_M2__c= '3'; testPMATPrintExtn.oChildRecICP.Advocates_Children_Caregiver_M3__c= '2'; 
        testPMATPrintExtn.oChildRecICP.Demonstrates_Learning_And_Improvement_M1__c= '4'; testPMATPrintExtn.oChildRecICP.Demonstrates_Learning_And_Improvement_M2__c= '2'; 
        testPMATPrintExtn.oChildRecICP.Demonstrates_Learning_And_Improvement_M3__c= '5'; testPMATPrintExtn.oChildRecICP.Mobilize_Technical_Financial_Assist_M1__c= '2'; 
        testPMATPrintExtn.oChildRecICP.Mobilize_Technical_Financial_Assist_M2__c= '5'; testPMATPrintExtn.oChildRecICP.Mobilize_Technical_Financial_Assist_M3__c= '6'; 
        testPMATPrintExtn.oChildRecICP.Quality_Training_ICP_Staff__c= '1'; testPMATPrintExtn.oChildRecICP.Encourage_ICP_Innovate_Personalize__c= '2'; 
        testPMATPrintExtn.oChildRecICP.Sufficient_Time_Project_Needs__c= '6'; testPMATPrintExtn.oChildRecICP.Unique_Challenges_Project__c= '5'; 
        testPMATPrintExtn.oChildRecICP.ICP_Autonomy_Decision_Making__c= '3'; testPMATPrintExtn.oChildRecICP.Natural_Extension_ICP_Ministry__c= '2'; 
        testPMATPrintExtn.oChildRecICP.Compassion_Demonstrated_Sensitivity__c= '4'; testPMATPrintExtn.oChildRecICP.Compassion_Requirement_Reasonable__c= '6'; 
        testPMATPrintExtn.oChildRecICP.Compassion_Requirement_Relevant__c= '1';            
        insert testPMATPrintExtn.oChildRecICP;        
        
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) 
        {
            String Temp = UserInfo.getProfileId();
            Profile ProfileName = [Select Name from Profile where id=: Temp ];
                
            Id iloggedInId = userinfo.getuserId();
            User u = [Select Name, username from User where id=:iloggedInId];
            
            Test.StartTest() ; 
                Pagereference pg1 = new PageReference( '/apex/PMATFormNewPrint?id='+testPMATPrintExtn.oCurrPMAT.id +'&retURL') ;
                Test.setCurrentPage(pg1) ;
                testPMATPrintExtn.LoadPageInstance();
                
            Test.StopTest() ; 
       } 
    }  
}