/******************************************************************************************************
Class Name         : PMATFormNewPrintExtension
Deascription       : An apex page controller for PMAT Form Print logic
Created By         : Akashdeep 
Created On         : 05/29/2015
******************************************************************************************************/
public class PMATFormNewPrintExtension 
{
    
    public PMAT_Assessment__c oCurrPMAT{get;set;}
    public PMAT__c oChildRecCI{get;set;}
    public PMAT__c oChildRecICP{get;set;}
    public Account oTempAcc{get;set;}
    public Profile ProfileName{get;set;}
    
    public String sStartDate{get;set;}
    public String sEndDate{get;set;}
   
    public boolean bRelationshipCapacityFlag{get;set;}
    public boolean bProgramCapacityFlag{get;set;}
    public boolean bProgramCapacityFlag2{get;set;}
    public boolean bDisablePMATType{get;set;}
    public boolean bShowCIChild{get;set;}
    public boolean bShowICPChild{get;set;}
    public boolean bNxtAssessDateFlag{get;set;}
    public boolean bCreateICPFormBtnFlag{get;set;}
    public List<PMAT_Cluster_Measure__c> lstOfMeasures{get;set;}
    public List<String> lstOfMeasureLabels{get;set;}
    public Set<String> setForValidation{get;set;}
    public List<SelectOption> lstLowHighValues{get;set;}
    public List<SelectOption> lstOneToSixValues{get;set;}
    
    
    /**
    * Method name  : PmatFormControllerNew
    * Description  : This is a standard constructor for the class PmatFormControllerNew that initialises all the variables
    * Return Type  : NA
    * Parameter    : ApexPages.StandardController 
    **/    
    public PMATFormNewPrintExtension(ApexPages.StandardController controller) 
    {
        oTempAcc = new Account();
        
        lstLowHighValues = new List<SelectOption>();
        lstOneToSixValues = new List<SelectOption>();
        
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
        
        sStartDate = '';
        sEndDate = '';
        
        bShowCIChild = false;
        bShowICPChild = false;
        bCreateICPFormBtnFlag = false;
        
        bNxtAssessDateFlag = false;
        bRelationshipCapacityFlag=true;
        bProgramCapacityFlag=false;
        bProgramCapacityFlag2 = false;
        bDisablePMATType = false;
        String Temp = UserInfo.getProfileId();
        ProfileName = [Select Name from Profile where id=: Temp ];
        setForValidation = new Set<String>{'1','2','3','4','5','6'};
        if(ApexPages.currentPage().getParameters().get('id') != null)
        {
            LoadPageInstance();
        }
        
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
    }
    
    /**
    * Method name  : LoadPageInstance
    * Description  : This is a method that loads the content to be displayed in the PMAT Form Page
    * Return Type  : void
    * Parameter    : void
    **/
    public void LoadPageInstance()
    {
        ID CurrPMAT = ApexPages.currentPage().getParameters().get('id');
        if(oCurrPMAT != null)
        {
            CurrPMAT = oCurrPMAT.id;
        }
        
        oCurrPMAT = [Select id, Name, Account_Name__c, Account_Name__r.Name, Account_Name__r.Cluster__c, Field_Office__c, Field_Office_ID__c, ICP_ID__c, Owner__c, Owner__r.Name, Partnership_Facilitator__c, Partnership_Facilitator_ID__c, Partnership_Facilitator_Supervisor__c, Partnership_Facilitator_Supervisor_ID__c, PMAT_Action_Item_List__c, PMAT_Assessment_End_Date__c, PMAT_Assessment_Start_Date__c, PMAT_Combined_Maturity_Level__c, PMAT_Combined_Maturity_Numeric_Average__c, PMAT_Completion_Date__c, PMAT_Discussion_Summary__c, PMAT_Next_Assessment_Date__c, FO_Created_ICP_Form__c, PMAT_ICP_Representative__c, PMAT_ICP_Representative__r.Name, CreatedById, LastModifiedById from PMAT_Assessment__c where id =: CurrPMAT];
        
        sStartDate  = oCurrPMAT.PMAT_Assessment_Start_Date__c.format();
        sEndDate  = oCurrPMAT.PMAT_Assessment_End_Date__c.format();
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
        catch (Exception ex)
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
                
            }
        }
        
        if( lstCheckChild.size() == 2 && lstCheckChild[0].PMAT_Status__c == Constants.PMAT_Discussion && lstCheckChild[1].PMAT_Status__c == Constants.PMAT_Discussion )
        {
            bShowCIChild = true;
            bShowICPChild = true;
        }
        else if(lstCheckChild.size() == 2 && lstCheckChild[0].PMAT_Status__c == Constants.PMAT_Complete && lstCheckChild[1].PMAT_Status__c == Constants.PMAT_Complete)
        {
            bShowCIChild = true;
            bShowICPChild = true;
            bNxtAssessDateFlag = true;
            
        }
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
}