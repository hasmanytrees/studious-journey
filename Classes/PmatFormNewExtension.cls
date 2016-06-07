/******************************************************************************************************
Class Name         : PmatFormNewExtension
Deascription       : An apex page controller for PMAT Form logic
Created By         : Akashdeep 
Created On         : 05/29/2015
******************************************************************************************************/
public class PmatFormNewExtension 
{
    public String sPageMode{get;set;}
    
    public PMAT_Assessment__c oCurrPMAT{get;set;}
    public PMAT__c oChildRecCI{get;set;}
    public PMAT__c oChildRecICP{get;set;}
    public Account oTempAcc{get;set;}
    public Profile ProfileName{get;set;}

    public boolean bRelationshipCapacityFlag{get;set;}
    public boolean bProgramCapacityFlag{get;set;}
    public boolean bProgramCapacityFlag2{get;set;}
    public boolean bShowCIChild{get;set;}
    public boolean bShowICPChild{get;set;}
    public boolean bNxtAssessDateFlag{get;set;}
    public boolean bCreateICPFormBtnFlag{get;set;}
    public boolean bFOCanEditICPForm{get;set;}
    public boolean bDisablePrint{get;set;}
    public boolean bEnableEdit{get;set;}
    public boolean bEnableCreate{get;set;}
    
    public List<PMAT_Cluster_Measure__c> lstOfMeasures{get;set;}
    public List<String> lstOfMeasureLabels{get;set;}
    public Set<String> setForValidation{get;set;}
    public List<SelectOption> lstLowHighValues{get;set;}
    public List<SelectOption> lstOneToSixValues{get;set;}
    public List<SelectOption> lstFOFormStatusValues{get;set;}
    public List<SelectOption> lstICPFormStatusValues{get;set;}
    
    public boolean bIsNewIsNotICPAdmin{get;set;}
    public boolean bIsEditIsNotICPAdmin{get;set;}
    public boolean bIsNotViewIsNotICPAdmin{get;set;}
    public boolean bIsViewIsICPAdmin{get;set;}
    public boolean bIsNotViewIsNotICPAdminIsFOCreateICPForm{get;set;}    
    public boolean bIsViewIsICPAdminIsNxtAssessDateFlag{get;set;}
    public boolean bIsNotViewIsNotICPAdminIsNxtAssessDateFlag{get;set;}    
    public boolean bIsNotViewIsICPAdminIsFoEditICPForm{get;set;}
    public boolean bIsViewIsNotICPAdminIsNotFoEditICPForm{get;set;}    
    public boolean bIsNotView{get;set;}
    public boolean bIsViewIsEnableEdit{get;set;}
    Public Boolean bcheckForInsert{get;set;}
    /**
    * Method name  : PmatFormNewExtension
    * Description  : This is a standard constructor for the class PmatFormNewExtension that initialises all the variables
    * Return Type  : NA
    * Parameter    : ApexPages.StandardController 
    **/    
    public PmatFormNewExtension(ApexPages.StandardController controller) 
    {
        oTempAcc = new Account();
        
        lstLowHighValues = new List<SelectOption>();
        lstOneToSixValues = new List<SelectOption>();
        lstFOFormStatusValues = new List<SelectOption>();
        lstICPFormStatusValues = new List<SelectOption>();
        
        lstFOFormStatusValues.add(new SelectOption(Constants.PMAT_Initiated,System.Label.PMAT_Status_Initiated));
        lstFOFormStatusValues.add(new SelectOption(Constants.PMAT_Discussion,System.Label.PMAT_Status_Ready_for_Discussion));
        lstFOFormStatusValues.add(new SelectOption(Constants.PMAT_Complete,System.Label.PMAT_Status_Complete, true));
        
        lstICPFormStatusValues.add(new SelectOption(Constants.PMAT_Initiated,System.Label.PMAT_Status_Initiated));
        lstICPFormStatusValues.add(new SelectOption(Constants.PMAT_Discussion,System.Label.PMAT_Status_Ready_for_Discussion));
        
        lstLowHighValues.add(new SelectOption('1',System.Label.PMAT_Low));
        lstLowHighValues.add(new SelectOption('2',System.Label.PMAT_High));
        lstLowHighValues.add(new SelectOption('3',System.Label.PMAT_Low));
        lstLowHighValues.add(new SelectOption('4',System.Label.PMAT_High));
        lstLowHighValues.add(new SelectOption('5',System.Label.PMAT_Low));
        lstLowHighValues.add(new SelectOption('6',System.Label.PMAT_High));
        
        lstOneToSixValues.add(new SelectOption('1','1'));
        lstOneToSixValues.add(new SelectOption('2','2'));
        lstOneToSixValues.add(new SelectOption('3','3'));
        lstOneToSixValues.add(new SelectOption('4','4'));
        lstOneToSixValues.add(new SelectOption('5','5'));
        lstOneToSixValues.add(new SelectOption('6','6'));
        
        bNxtAssessDateFlag = false;
        bRelationshipCapacityFlag=true;
        bProgramCapacityFlag=false;
        bProgramCapacityFlag2 = false;
        bEnableEdit = true;
        bEnableCreate = true;
        bFOCanEditICPForm = false;
        bCreateICPFormBtnFlag = false;
        
        bIsNewIsNotICPAdmin = false;
        bIsEditIsNotICPAdmin = false;
        bIsNotViewIsNotICPAdmin = false;
        bIsViewIsICPAdmin = false;
        bIsNotViewIsNotICPAdminIsFOCreateICPForm = false;    
        bIsViewIsICPAdminIsNxtAssessDateFlag = false;
        bIsNotViewIsNotICPAdminIsNxtAssessDateFlag = false;    
        bIsNotViewIsICPAdminIsFoEditICPForm = false;
        bIsViewIsNotICPAdminIsNotFoEditICPForm = false;    
        bIsNotView = false;
        bIsViewIsEnableEdit = false;
        bcheckForInsert = false;
        String Temp = UserInfo.getProfileId();
        ProfileName = [Select Name from Profile where id=: Temp ];
        setForValidation = new Set<String>{'1','2','3','4','5','6'};
        
        if(ApexPages.currentPage().getParameters().get('id') == null)
        {
            bDisablePrint = true;
            sPageMode = Constants.PMAT_New;
            oCurrPMAT = new PMAT_Assessment__c();
            oCurrPMAT.Owner__c = userinfo.getuserid();
            
            Schema.DescribeSObjectResult oSObject = Schema.sObjectType.PMAT_Assessment__c;
            if(!oSObject.isCreateable())
            {
                bEnableCreate = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.PMAT_Create_Access_Error);
                ApexPages.addMessage(myMsg);
                return;
            }
            
            if( ApexPages.currentPage().getParameters().get('AccId') != null && ApexPages.currentPage().getParameters().get('AccId') != '')
            {
                oCurrPMAT.Account_Name__c = ApexPages.currentPage().getParameters().get('AccId');
                fillChurch();
            }
            
            if (ProfileName.Name != Constants.ICP_Admin)
            {
                bShowCIChild = true;
                bShowICPChild = false;
                oChildRecCI = new PMAT__c();
                oChildRecCI.PMAT_Type__c = Constants.Comp_Label;
                bIsNewIsNotICPAdmin = true;
                
            }
            if( sPageMode != Constants.PMAT_View && ProfileName.Name != Constants.ICP_Admin)
            {
                bIsNotViewIsNotICPAdmin = true;
            }
            
            
        }
        else if(ApexPages.currentPage().getParameters().get('retUrl') != null)
        {
            sPageMode = Constants.PMAT_Edit;
            LoadPageInstance();
        }
        else
        {
            sPageMode = Constants.PMAT_View;
            Schema.DescribeSObjectResult oSObject = Schema.sObjectType.PMAT_Assessment__c;
            if(!oSObject.isUpdateable())
            {
                bEnableEdit = false;
            }
            LoadPageInstance();
        }
    }
    
    /**
    * Method name  : fillChurch
    * Description  : This is a method that pre-fills Account detials on the PMAT form
    * Return Type  : void
    * Parameter    : void
    **/
    public void fillChurch()
    {
        oTempAcc = [Select ICP_Id__c, Field_Office__c, Cluster__r.Territory__r.Field_Office__r.id, Partnership_Facilitator__r.id, Partnership_Facilitator__r.Name, Partnership_Facilitator_Supervisor__r.id, Partnership_Facilitator_Supervisor__r.Name from Account where id =: oCurrPMAT.Account_Name__c limit 1];
        getLabelValues(oTempAcc.Cluster__c);
    }
    
    /**
    * Method name  : formTwo
    * Description  : This is a method that toggles the visibility of Relationship Capacity Section
    * Return Type  : void
    * Parameter    : void
    **/
    public pagereference formTwo()
    {
        bRelationshipCapacityFlag = true;  
        bProgramCapacityFlag=false;
        bProgramCapacityFlag2 = false;
        return null;
    }
    
    /**
    * Method name  : programCapacity
    * Description  : This is a method that toggles the visibility of Program Capacity Part 1 Section
    * Return Type  : void
    * Parameter    : void
    **/
    public pagereference programCapacity()
    {
        bProgramCapacityFlag=true;
        bRelationshipCapacityFlag = false; 
        bProgramCapacityFlag2 = false; 
        return null;
    }
    
    /**
    * Method name  : programCapacity2
    * Description  : This is a method that toggles the visibility of Program Capacity Part 2 Section
    * Return Type  : void
    * Parameter    : void
    **/
    public pagereference programCapacity2()
    {
        bProgramCapacityFlag=false;
        bRelationshipCapacityFlag = false; 
        bProgramCapacityFlag2 = true; 
        return null;
    }
    
    /**
    * Method name  : ShowNextAssessDateField
    * Description  : This is a method that toggles the visibility of Next Assessment Date Field
    * Return Type  : void
    * Parameter    : void
    **/
    public void ShowNextAssessDateField()
    {
        if( oChildRecCI.PMAT_Status__c == Constants.PMAT_Complete)
        {
            bNxtAssessDateFlag = true;
        }
        else
        {
            bNxtAssessDateFlag = false;
        }
        
        if( sPageMode != Constants.PMAT_View && ProfileName.Name != Constants.ICP_Admin && bNxtAssessDateFlag){
            bIsNotViewIsNotICPAdminIsNxtAssessDateFlag = true;
        }
    }
    
    /**
    * Method name  : LoadPageInstance
    * Description  : This is a method that loads the content to be displayed in the PMAT Form Page
    * Return Type  : void
    * Parameter    : void
    **/
    public void LoadPageInstance()
    {
        bFOCanEditICPForm = false;
        bIsNewIsNotICPAdmin = false;
        bIsEditIsNotICPAdmin = false;
        bIsNotViewIsNotICPAdmin = false;
        bIsViewIsICPAdmin = false;
        bIsNotViewIsNotICPAdminIsFOCreateICPForm = false;    
        bIsViewIsICPAdminIsNxtAssessDateFlag = false;
        bIsNotViewIsNotICPAdminIsNxtAssessDateFlag = false;    
        bIsNotViewIsICPAdminIsFoEditICPForm = false;
        bIsViewIsNotICPAdminIsNotFoEditICPForm = false;    
        bIsNotView = false;
        bIsViewIsEnableEdit = false;
        
        ID CurrPMAT = ApexPages.currentPage().getParameters().get('id');
        if(oCurrPMAT != null)
        {
            CurrPMAT = oCurrPMAT.id;
            bDisablePrint = false;
        }
        
        oCurrPMAT = [Select id, Name, Account_Name__c, Account_Name__r.Cluster__c, Field_Office__c, Field_Office_ID__c, ICP_ID__c, Owner__c, Partnership_Facilitator__c, Partnership_Facilitator_ID__c, 
                     Partnership_Facilitator_Supervisor__c, Partnership_Facilitator_Supervisor_ID__c, PMAT_Action_Item_List__c, PMAT_Assessment_End_Date__c, PMAT_Assessment_Start_Date__c, PMAT_Combined_Maturity_Level__c, PMAT_Combined_Maturity_Numeric_Average__c, 
                     PMAT_Completion_Date__c, PMAT_Discussion_Summary__c, PMAT_Next_Assessment_Date__c, FO_Created_ICP_Form__c, PMAT_ICP_Representative__c, CreatedById, LastModifiedById from PMAT_Assessment__c where id =: CurrPMAT];
        
        getLabelValues(oCurrPMAT.Account_Name__r.Cluster__c);
        
        List<PMAT__c> lstCheckChild = new List<PMAT__c>();
        
        String Query = 'Select ';
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PMAT__c.fields.getMap();
        for (String fieldName: schemaFieldMap.keySet()) {
             Query+= fieldName + ', ';
        }
        Query = Query.removeEnd(', ');
        Query+= ' from PMAT__c where PMAT_Assessment__c = \''+ oCurrPMAT.id + '\' ORDER BY PMAT_Type__c DESC ';
        
        try
        {
            lstCheckChild = Database.query(Query);
        }
        catch(Exception ex)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.PMAT_Error_in_PMAT_Query);
            ApexPages.addMessage(myMsg);
            return;
        }
        
       if( lstCheckChild.size() == 1 )
        {
            if( lstCheckChild[0].PMAT_Type__c == Constants.Comp_Label )
            {
              oChildRecCI = lstCheckChild[0];
              bCreateICPFormBtnFlag = true;
            }
            if (ProfileName.Name == Constants.ICP_Admin)
            {
                oChildRecICP = new PMAT__c();
                oChildRecICP.PMAT_Type__c = Constants.ICP_Label;
            }
        }
        else if ( lstCheckChild.size() == 2 )
        {
            bCreateICPFormBtnFlag = false;
            oChildRecCI = lstCheckChild[0];
            oChildRecICP = lstCheckChild[1];             
        }
        
        if (ProfileName.Name == Constants.ICP_Admin)
        {
            bShowCIChild = false;
            bShowICPChild = true;
        }
        else if (ProfileName.Name != Constants.ICP_Admin)
        {
            bShowCIChild = true;
            bShowICPChild = false;
            if( oCurrPMAT.FO_Created_ICP_Form__c == true )
            {
                bShowICPChild = true;
                bFOCanEditICPForm = true;
            }
        }
        
        if( lstCheckChild.size() == 2 && lstCheckChild[0].PMAT_Status__c == Constants.PMAT_Discussion && lstCheckChild[1].PMAT_Status__c == Constants.PMAT_Discussion )
        {
            bShowCIChild = true;
            bShowICPChild = true;
            lstFOFormStatusValues[2].setDisabled(false);
        }
        else if(lstCheckChild.size() == 2 && lstCheckChild[0].PMAT_Status__c == Constants.PMAT_Complete && lstCheckChild[1].PMAT_Status__c == Constants.PMAT_Complete)
        {
            bShowCIChild = true;
            bShowICPChild = true;
            sPageMode = 'VIEW';
            bNxtAssessDateFlag = true;
            bFOCanEditICPForm = false;
        }
        
        
        // The following evaluations were moved from the VF Page to Apex Class
        if( sPageMode == Constants.PMAT_Edit && ProfileName.Name != Constants.ICP_Admin){
            bIsEditIsNotICPAdmin = true;
        }
        if( sPageMode != Constants.PMAT_View && ProfileName.Name != Constants.ICP_Admin){
            bIsNotViewIsNotICPAdmin = true;
        }
        if( sPageMode == Constants.PMAT_View || ProfileName.Name == Constants.ICP_Admin){
            bIsViewIsICPAdmin = true;
        }
        if( sPageMode != Constants.PMAT_View && ProfileName.Name != Constants.ICP_Admin && bCreateICPFormBtnFlag){
            bIsNotViewIsNotICPAdminIsFOCreateICPForm = true;
        }
        if( sPageMode != Constants.PMAT_View && ProfileName.Name != Constants.ICP_Admin && bNxtAssessDateFlag){
            bIsNotViewIsNotICPAdminIsNxtAssessDateFlag = true;
        }
        if( (sPageMode == Constants.PMAT_View || ProfileName.Name == Constants.ICP_Admin) && bNxtAssessDateFlag){
            bIsViewIsICPAdminIsNxtAssessDateFlag = true;
        } 
             
        if(sPageMode != Constants.PMAT_View && (ProfileName.Name == Constants.ICP_Admin || bFOCanEditICPForm)){
            bIsNotViewIsICPAdminIsFoEditICPForm = true;
        }
        if(sPageMode == Constants.PMAT_View || (ProfileName.Name != Constants.ICP_Admin && !bFOCanEditICPForm)) {
            bIsViewIsNotICPAdminIsNotFoEditICPForm = true;
        }
        if(sPageMode == Constants.PMAT_View && bEnableEdit){
            bIsViewIsEnableEdit = true;
        }
        
    }
    
    /**
    * Method name  : recordSave
    * Description  : This is a method that updates or inserts te PMAT master & child Object records
    * Return Type  : void
    * Parameter    : void
    **/
    
    public PageReference recordSave()
    {
          
        List<PMAT_Assessment__c> lstExistingPMATCheck = [Select id from PMAT_Assessment__c where Account_Name__c =:  oCurrPMAT.Account_Name__c AND PMAT_Completion_Date__c = Null AND id !=: oCurrPMAT.id ];
        
        if(lstExistingPMATCheck.size() > 0 )
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.PMAT_Incomplete_Form_Exists );
            ApexPages.addMessage(myMsg);
            return null ;
        }
        
        List<PMAT_Assessment__c> lstDateOverlapCheck = [Select id from PMAT_Assessment__c where Account_Name__c =:  oCurrPMAT.Account_Name__c
        AND ((PMAT_Assessment_Start_Date__c <=: oCurrPMAT.PMAT_Assessment_Start_Date__c AND PMAT_Assessment_End_Date__c >=: oCurrPMAT.PMAT_Assessment_End_Date__c)
        OR (PMAT_Assessment_Start_Date__c >=: oCurrPMAT.PMAT_Assessment_Start_Date__c AND PMAT_Assessment_End_Date__c <=: oCurrPMAT.PMAT_Assessment_End_Date__c)
        OR (PMAT_Assessment_Start_Date__c <=: oCurrPMAT.PMAT_Assessment_Start_Date__c AND PMAT_Assessment_End_Date__c <=: oCurrPMAT.PMAT_Assessment_End_Date__c AND PMAT_Assessment_End_Date__c >=: oCurrPMAT.PMAT_Assessment_Start_Date__c)
        OR (PMAT_Assessment_Start_Date__c >=: oCurrPMAT.PMAT_Assessment_Start_Date__c AND PMAT_Assessment_End_Date__c >=: oCurrPMAT.PMAT_Assessment_End_Date__c AND PMAT_Assessment_Start_Date__c <=: oCurrPMAT.PMAT_Assessment_End_Date__c))];
        
        if(lstDateOverlapCheck.size() > 0 && lstDateOverlapCheck[0].id != oCurrPMAT.id)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.PMAT_Overlaps_Existing_Assessment);
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        if(oChildRecCI != Null && oChildRecCI.PMAT_Status__c == Constants.PMAT_Discussion && (!(setForValidation.contains(oChildRecCI.Christ_Mutual_Identity_Church__c)) ||
            !(setForValidation.contains(oChildRecCI.Address_Outcomes_Standards_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.Address_Outcomes_Standards_M2__c)) ||
            !(setForValidation.contains(oChildRecCI.Address_Outcomes_Standards_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.Advocates_Children_Caregiver_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.Advocates_Children_Caregiver_M2__c)) ||
            !(setForValidation.contains(oChildRecCI.Advocates_Children_Caregiver_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.Christ_Mutual_Identity_Compassion__c)) ||
            !(setForValidation.contains(oChildRecCI.Compassion_Demonstrated_Sensitivity__c)) ||
            !(setForValidation.contains(oChildRecCI.Compassion_Requirement_Reasonable__c)) ||
            !(setForValidation.contains(oChildRecCI.Compassion_Requirement_Relevant__c)) ||
            !(setForValidation.contains(oChildRecCI.Contribute_Facility_Financial_Support_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.Contribute_Facility_Financial_Support_M2__c)) ||
            !(setForValidation.contains(oChildRecCI.Contribute_Facility_Financial_Support_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.CRCH_Influence_Oversee_Program_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.CRCH_Influence_Oversee_Program_M2__c)) ||
            !(setForValidation.contains(oChildRecCI.CRCH_Influence_Oversee_Program_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.CRCH_Leader_Engage_Children_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.CRCH_Leader_Engage_Children_M2__c))||
            !(setForValidation.contains(oChildRecCI.CRCH_Leader_Engage_Children_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.Demonstrates_Learning_And_Improvement_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.Demonstrates_Learning_And_Improvement_M2__c)) ||
            !(setForValidation.contains(oChildRecCI.Demonstrates_Learning_And_Improvement_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.Effective_Annual_Plans_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.Effective_Annual_Plans_M2__c)) ||
            !(setForValidation.contains(oChildRecCI.Effective_Annual_Plans_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.Encourage_ICP_Innovate_Personalize__c)) ||
            !(setForValidation.contains(oChildRecCI.ICP_Autonomy_Decision_Making__c)) ||
            !(setForValidation.contains(oChildRecCI.ICP_Reflects_Vision_Values_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.ICP_Reflects_Vision_Values_M2__c)) ||
            !(setForValidation.contains(oChildRecCI.ICP_Reflects_Vision_Values_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.Implements_Curriculum_Effectively_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.Implements_Curriculum_Effectively_M2__c)) ||
            !(setForValidation.contains(oChildRecCI.Implements_Curriculum_Effectively_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.Mobilize_Technical_Financial_Assist_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.Mobilize_Technical_Financial_Assist_M2__c)) ||
            !(setForValidation.contains(oChildRecCI.Mobilize_Technical_Financial_Assist_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.Mobilizing_Community_Resource_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.Mobilizing_Community_Resource_M2__c)) ||
            !(setForValidation.contains(oChildRecCI.Mobilizing_Community_Resource_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.Mutual_Respect_Benefit_Church__c)) ||
            !(setForValidation.contains(oChildRecCI.Mutual_Respect_Benefit_Compassion__c)) ||
            !(setForValidation.contains(oChildRecCI.Natural_Extension_ICP_Ministry__c)) ||
            !(setForValidation.contains(oChildRecCI.Quality_Quantity_Staff_Volunteers_M1__c)) ||
            !(setForValidation.contains(oChildRecCI.Quality_Quantity_Staff_Volunteers_M2__c)) ||
            !(setForValidation.contains(oChildRecCI.Quality_Quantity_Staff_Volunteers_M3__c)) ||
            !(setForValidation.contains(oChildRecCI.Quality_Training_ICP_Staff__c)) ||
            !(setForValidation.contains(oChildRecCI.Responsibilty_Commitment_Church__c)) ||
            !(setForValidation.contains(oChildRecCI.Responsibilty_Commitment_Compassion__c)) ||
            !(setForValidation.contains(oChildRecCI.Sufficient_Time_Project_Needs__c)) ||
            !(setForValidation.contains(oChildRecCI.Transformation_Outcomes_Church__c)) ||
            !(setForValidation.contains(oChildRecCI.Transformation_Outcomes_Compassion__c)) || 
            !(setForValidation.contains(oChildRecCI.Unique_Challenges_Project__c)) ) )
        {
            oChildRecCI.PMAT_Status__c = Constants.PMAT_Status_Init;
            try
            {
                UPDATE oChildRecCI;
            }
            catch(DmlException ex)
            {
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                ApexPages.addMessage(oMsg);
                ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.PMAT_FO_Complete_All_Questions);
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        else if( oChildRecICP != Null && oChildRecICP.PMAT_Status__c == Constants.PMAT_Discussion && (!(setForValidation.contains(oChildRecICP.Christ_Mutual_Identity_Church__c)) ||
            !(setForValidation.contains(oChildRecICP.Address_Outcomes_Standards_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.Address_Outcomes_Standards_M2__c)) ||
            !(setForValidation.contains(oChildRecICP.Address_Outcomes_Standards_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.Advocates_Children_Caregiver_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.Advocates_Children_Caregiver_M2__c)) ||
            !(setForValidation.contains(oChildRecICP.Advocates_Children_Caregiver_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.Christ_Mutual_Identity_Compassion__c)) ||
            !(setForValidation.contains(oChildRecICP.Compassion_Demonstrated_Sensitivity__c)) ||
            !(setForValidation.contains(oChildRecICP.Compassion_Requirement_Reasonable__c)) ||
            !(setForValidation.contains(oChildRecICP.Compassion_Requirement_Relevant__c)) ||
            !(setForValidation.contains(oChildRecICP.Contribute_Facility_Financial_Support_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.Contribute_Facility_Financial_Support_M2__c)) ||
            !(setForValidation.contains(oChildRecICP.Contribute_Facility_Financial_Support_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.CRCH_Influence_Oversee_Program_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.CRCH_Influence_Oversee_Program_M2__c)) ||
            !(setForValidation.contains(oChildRecICP.CRCH_Influence_Oversee_Program_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.CRCH_Leader_Engage_Children_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.CRCH_Leader_Engage_Children_M2__c))||
            !(setForValidation.contains(oChildRecICP.CRCH_Leader_Engage_Children_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.Demonstrates_Learning_And_Improvement_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.Demonstrates_Learning_And_Improvement_M2__c)) ||
            !(setForValidation.contains(oChildRecICP.Demonstrates_Learning_And_Improvement_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.Effective_Annual_Plans_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.Effective_Annual_Plans_M2__c)) ||
            !(setForValidation.contains(oChildRecICP.Effective_Annual_Plans_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.Encourage_ICP_Innovate_Personalize__c)) ||
            !(setForValidation.contains(oChildRecICP.ICP_Autonomy_Decision_Making__c)) ||
            !(setForValidation.contains(oChildRecICP.ICP_Reflects_Vision_Values_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.ICP_Reflects_Vision_Values_M2__c)) ||
            !(setForValidation.contains(oChildRecICP.ICP_Reflects_Vision_Values_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.Implements_Curriculum_Effectively_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.Implements_Curriculum_Effectively_M2__c)) ||
            !(setForValidation.contains(oChildRecICP.Implements_Curriculum_Effectively_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.Mobilize_Technical_Financial_Assist_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.Mobilize_Technical_Financial_Assist_M2__c)) ||
            !(setForValidation.contains(oChildRecICP.Mobilize_Technical_Financial_Assist_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.Mobilizing_Community_Resource_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.Mobilizing_Community_Resource_M2__c)) ||
            !(setForValidation.contains(oChildRecICP.Mobilizing_Community_Resource_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.Mutual_Respect_Benefit_Church__c)) ||
            !(setForValidation.contains(oChildRecICP.Mutual_Respect_Benefit_Compassion__c)) ||
            !(setForValidation.contains(oChildRecICP.Natural_Extension_ICP_Ministry__c)) ||
            !(setForValidation.contains(oChildRecICP.Quality_Quantity_Staff_Volunteers_M1__c)) ||
            !(setForValidation.contains(oChildRecICP.Quality_Quantity_Staff_Volunteers_M2__c)) ||
            !(setForValidation.contains(oChildRecICP.Quality_Quantity_Staff_Volunteers_M3__c)) ||
            !(setForValidation.contains(oChildRecICP.Quality_Training_ICP_Staff__c)) ||
            !(setForValidation.contains(oChildRecICP.Responsibilty_Commitment_Church__c)) ||
            !(setForValidation.contains(oChildRecICP.Responsibilty_Commitment_Compassion__c)) ||
            !(setForValidation.contains(oChildRecICP.Sufficient_Time_Project_Needs__c)) ||
            !(setForValidation.contains(oChildRecICP.Transformation_Outcomes_Church__c)) ||
            !(setForValidation.contains(oChildRecICP.Transformation_Outcomes_Compassion__c)) || 
            !(setForValidation.contains(oChildRecICP.Unique_Challenges_Project__c)) ) )
        {
            oChildRecICP.PMAT_Status__c = Constants.PMAT_Status_Init;
            try
            {
                UPDATE oChildRecICP;
            }
            catch(DmlException ex)
            {
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                ApexPages.addMessage(oMsg);
                ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.PMAT_ICP_Complete_All_Questions);
            ApexPages.addMessage(myMsg);
            return null;
        }
        /*MV-Start: validation to fire when ICP users try to save the form once the form is 'Completed' by FO*/   
        if(ProfileName.Name == Constants.ICP_Admin){ 
        ID idpmat = ApexPages.currentPage().getParameters().get('id');
        List<PMAT__c> lstPmat= [select id , PMAT_Status__c from PMAT__c where PMAT_Assessment__r.id =:idpmat order by PMAT_Type__c DESC] ;         
        if(!lstPmat.isempty()){        
        String sCIStatus = lstPmat[0].PMAT_Status__c;       
        if(sCIStatus == Constants.PMAT_Complete){
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.PMAT_Assessment_Completed);
            ApexPages.addMessage(myMsg);
            return null;
          } 
         }
        }
        /*MV-END */
        if( oCurrPMAT.Name == Null )
        {
            System.Debug('oTempAcc.ICP_Id__c: '+ oTempAcc.ICP_Id__c);
            System.Debug('oCurrPMAT.PMAT_Assessment_Start_Date__c: '+ oCurrPMAT.PMAT_Assessment_Start_Date__c.format());
            System.Debug('oCurrPMAT.PMAT_Assessment_End_Date__c: '+ oCurrPMAT.PMAT_Assessment_End_Date__c.format());
            oCurrPMAT.Name = oTempAcc.ICP_Id__c + '-PMAT From '+ oCurrPMAT.PMAT_Assessment_Start_Date__c.format() + ' to ' + oCurrPMAT.PMAT_Assessment_End_Date__c.format();
        }
        else
        {
            oCurrPMAT.Name = oCurrPMAT.ICP_ID__c + '-PMAT From '+ oCurrPMAT.PMAT_Assessment_Start_Date__c.format() + ' to ' + oCurrPMAT.PMAT_Assessment_End_Date__c.format();
        }
        
        
        try
       
        {
         If(oCurrPMAT.id!=null)
            {   
                update oCurrPMAT;
                                 
            }
            else
                {
                insert oCurrPMAT;
                bcheckForInsert=true;
                System.debug('@@@'+bcheckForInsert);
                }
        }
        catch(DmlException ex)
        {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
            ApexPages.addMessage(oMsg);

            ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
        }
        
        List<PMAT__c> lstCheckChild = [Select id, PMAT_Type__c from PMAT__c where PMAT_Assessment__c =: oCurrPMAT.id];
        System.Debug('ProfileName: ' + ProfileName.Name);
        
        if( lstCheckChild.size() == 0 )
        {
            if (ProfileName.Name != Constants.ICP_Admin)
            {
                oChildRecCI.Name = oCurrPMAT.Name + '-' + Constants.Child_CI;
                oChildRecCI.PMAT_Assessment__c = oCurrPMAT.id;
                oChildRecCI.PMAT_Status__c = Constants.PMAT_Status_Init;
                try
                {
                    INSERT oChildRecCI;
                }
                catch(DmlException ex)
                {
                    ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                    ApexPages.addMessage(oMsg);

                    ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
                }
            }
            else if(ProfileName.Name == Constants.ICP_Admin)
            {
                oChildRecICP.Name = oCurrPMAT.Name + '-' + Constants.Child_ICP;
                oChildRecICP.PMAT_Assessment__c = oCurrPMAT.id;
                oChildRecICP.PMAT_Status__c = Constants.PMAT_Status_Init;
                try
                {
                    INSERT oChildRecICP;
                }
                catch(DmlException ex)
                {
                    ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                    ApexPages.addMessage(oMsg);
                    ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
                }
            }
        }
        else if( lstCheckChild.size() == 1 )
        {
            if (ProfileName.Name != Constants.ICP_Admin)
            {
                if(  lstCheckChild[0].PMAT_Type__c == Constants.Comp_Label )
                {
                    try
                    {
                        UPDATE oChildRecCI;
                    }
                    catch(DmlException ex)
                    {
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                        ApexPages.addMessage(oMsg);
                        ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
                    }
                }
                else
                {
                    oChildRecCI.Name = oCurrPMAT.Name + '-' + Constants.Child_CI;
                    oChildRecCI.PMAT_Assessment__c = oCurrPMAT.id;
                    oChildRecCI.PMAT_Status__c = Constants.PMAT_Status_Init;
                    try
                    {
                        INSERT oChildRecCI;
                    }
                    catch(DmlException ex)
                    {
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                        ApexPages.addMessage(oMsg);
                        ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
                    }
                }
            }
            else if(ProfileName.Name == Constants.ICP_Admin)
            {
                if(  lstCheckChild[0].PMAT_Type__c == Constants.ICP_Label )
                {
                    try
                    {
                        UPDATE oChildRecICP;
                    }
                    catch(DmlException ex)
                    {
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                        ApexPages.addMessage(oMsg);
                        ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
                    }
                }
                else
                {
                    oChildRecICP.Name = oCurrPMAT.Name + '-' + Constants.Child_ICP;
                    oChildRecICP.PMAT_Assessment__c = oCurrPMAT.id;
                    oChildRecICP.PMAT_Status__c = Constants.PMAT_Status_Init;
                    try
                    {
                        INSERT oChildRecICP;
                    }
                    catch(DmlException ex)
                    {
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                        ApexPages.addMessage(oMsg);
                        ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
                    }
                }
            }
        }
        else
        {
            if (ProfileName.Name != Constants.ICP_Admin)
            {
                try
                {
                    UPDATE oChildRecCI;
                }
                catch(DmlException ex)
                {
                    ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                    ApexPages.addMessage(oMsg);
                    ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
                }
                if(oChildRecCI.PMAT_Status__c == Constants.PMAT_Complete)
                {
                    oChildRecICP.PMAT_Status__c = Constants.PMAT_Complete;
                    try
                    {
                        UPDATE oChildRecICP;
                    }
                    catch(DmlException ex)
                    {
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                        ApexPages.addMessage(oMsg);
                        ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
                    }
                }
                if( oCurrPMAT.FO_Created_ICP_Form__c == true)
                {
                    try
                    {
                        UPDATE oChildRecICP;
                    }
                    catch(DmlException ex)
                    {
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                        ApexPages.addMessage(oMsg);
                        ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
                    }
                }                       
            }
            
            if(ProfileName.Name == Constants.ICP_Admin)
            {
                try
                {
                    UPDATE oChildRecICP;
                }
                catch(DmlException ex)
                {
                    ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
                    ApexPages.addMessage(oMsg);
                    ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','recordSave', 'SFDC CI');
                }            
            }

        }
            
        if (bcheckForInsert == true)
        {
         return RedirectUrl();
         }
        else 
        {
        sPageMode = Constants.PMAT_View;
        LoadPageInstance();
        return null;
        }       
    }
    
    /**
    * Method name  : createICPForm
    * Description  : This method creates a new ICP Form, when the FO user decides to fill the ICP Form as well 
    * Return Type  : void
    * Parameter    : void
    **/
    public void createICPForm()
    {
        oChildRecICP = new PMAT__c();
        oChildRecICP.PMAT_Type__c = Constants.ICP_Label;
        oChildRecICP.Name = oCurrPMAT.Name + '-' + Constants.Child_ICP;
        oChildRecICP.PMAT_Assessment__c = oCurrPMAT.id;
        oChildRecICP.PMAT_Status__c = Constants.PMAT_Status_Init;
        try
        {
            INSERT oChildRecICP;
        }
        catch(DmlException ex)
        {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','createICPForm', 'SFDC CI');
            return;
        }
        

        
        oCurrPMAT.FO_Created_ICP_Form__c = true;
        try
        {
            UPDATE oCurrPMAT;
        }
        catch(DmlException ex)
        {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,  ex.getMessage());
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(ex, 'PmatFormNewExtension','createICPForm', 'SFDC CI');
            return;
        }
        
        bCreateICPFormBtnFlag = false;
        bFOCanEditICPForm = true;
        
        LoadPageInstance();
    }
    
    /**
    * Method name  : ClickSave
    * Description  : This is a method that gets called when Save button is clicked
    * Return Type  : void
    * Parameter    : void
    **/
    public PageReference clickSave()
    {
       return recordSave();
        
    }
    
    /**
    * Method name  : getLabelValues
    * Description  : This method fetaches the cluster level measures for given cluster id
    * Return Type  : void
    * Parameter    : Cluster id
    **/
    public void getLabelValues(ID iClusterDataId)
    {
        lstOfMeasures = [Select Outcome_Number__c, Indicator_Number__c, Measure_Number__c, Text_Position__c, Measurement_Label__c from PMAT_Cluster_Measure__c where Field_Hierarchy__c =: iClusterDataId ORDER BY Sorting_Number__c ASC];
        lstOfMeasureLabels = new List<String>();
        
        if(lstOfMeasures.size() < Integer.ValueOf(System.Label.PMAT_Cluster_Measure_Number))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, System.Label.PMAT_Cluster_Measure_Warning);
            ApexPages.addMessage(myMsg);
        }
        
        for(PMAT_Cluster_Measure__c oCurrRec : lstOfMeasures)
        {
            if(oCurrRec.Measurement_Label__c == null)
            {
                lstOfMeasureLabels.add(System.Label.PMAT_Missing_Measure_Label);
            }
            else
            {
                lstOfMeasureLabels.add(oCurrRec.Measurement_Label__c);
            }
        }
        
        for(integer i = 0; i < Integer.ValueOf(System.Label.PMAT_Cluster_Measure_Number) - lstOfMeasures.size() ; i++)
        {
            lstOfMeasureLabels.add('');
        }
    }
    
    /**
    * Method name  : clickEdit
    * Description  : This is a method that gets called when Edit button is clicked & opens the form in EDIT mode
    * Return Type  : void
    * Parameter    : void
    **/
    public void clickEdit()
    {
        sPageMode = Constants.PMAT_Edit;
        LoadPageInstance();
    }
    
    /**
    * Method name  : clickCancel
    * Description  : This is a method that gets called when Cancel button is clicked
    * Return Type  : void
    * Parameter    : void
    **/
    public PageReference clickCancel()
    {
        if( oCurrPMAT.id == null )
        {
            PageReference PageRef = new PageReference('/'+ApexPages.currentPage().getParameters().get('AccId'));
            return PageRef;
        }
        else
        {
            sPageMode = Constants.PMAT_View;
            LoadPageInstance();
            return null;
        }
    }
    
    /**
    * Method name  : ClickPrint
    * Description  : This method gets called when Print button is clicked and takes user to the Print PMAT page
    * Return Type  : void
    * Parameter    : void
    **/
    public PageReference ClickPrint()
    {
        PageReference PageRef = new PageReference(Constants.PMAT_PRINT_PAGE+oCurrPMAT.id);
        return PageRef;
    } 
    /**
    * Method name  : RedirectUrl
    * Description  : This method will redirct to record if new record is inseted 
    * Return Type  : PageReference
    * Parameter    : void
    **/
    public PageReference RedirectUrl()
    {
        PageReference PageRef = new PageReference('/apex/PMATFormNew?id='+oCurrPMAT.id);
        PageRef.setRedirect(true);

        return PageRef;
    } 
    
}