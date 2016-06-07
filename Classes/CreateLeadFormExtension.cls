/************************************************************************************************** 
Class Name   : CreateLeadFormExtension
Created By   : Danish Ahmed
Created Date : 08-Jun-2015
Description  : This controller is written for VF page CreateLeadForm.
               This class will capture leads created by Web.
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class CreateLeadFormExtension {
    
    List<Integer> lstNumbers;
    List<String> lstOperators;
    public String sInput {get; set;}
    public String sResult {get; set;}
    public Integer iNum1;
    public Integer iNum2;
    Integer iNumResult;
    String sOperator;
    Public Lead oLead {
        get;
        set;
    }
    public String sShowMessage {
        get;
        set;
    }
    public String sContactSalutation{
        get;
        set;
    }
    public String sLastName{
        get;
        set;
    }
    public String sPastorEmail{
        get;
        set;
    }
    public String sYourFirstName{
        get;
        set;
    }
    public String sYourLastName{
        get;
        set;
    }
    public String sYourEmail{
        get;
        set;
    }
    public String sYourPhone{
        get;
        set;
    }
    public String sYourRole{
        get;
        set;
    }
    public String sChurchMinistry{
        get;
        set;
    }
    public String sChurchInterest{
        get;
        set;
    }
    public String sChurchMinistryDemo{
        get;
        set;
    }
    public String sChurchAgreementToFaith{
        get;
        set;
    }
    public String sOtherBeliefs{
        get;
        set;
    }
    public String sLangCode{
        get;
        set;
    }
    public Boolean bCaptcha{
        get;
        set;
    }
    
    String sFieldOffice;
    public Boolean bError;
    Boolean bErrorForSave;
    List<Note__c> lstNote;
    List<String> lstErrorFields;
    
    /**
    * Method name  : CreateLeadFormExtension
    * Description  : This is a constructor used for Setting variables.
    * Return Type  : NA
    * Parameter    : ApexPages.StandardController
    **/
    public CreateLeadFormExtension(ApexPages.StandardController oController) {
        oLead = (Lead)oController.getRecord();
        lstNumbers = new List<Integer>{1, 2, 3, 4, 5, 6, 7, 8, 9};
        lstOperators = new List<String>{'+', '*'};
        lstNote = new List<Note__c>();
        try{
            String sLang = apexpages.currentpage().getparameters().get(Constants.Lang);       
            if(!String.isEmpty(sLang)){
                sLangCode = sLang;
            }
        }catch(Exception oEx){
            sLangCode = Constants.ENG_LANG_CODE;
        }
        try{
            sFieldOffice = apexpages.currentpage().getparameters().get(Constants.FO);
        }catch(Exception oEx){
            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,System.Label.Web_To_Lead_URL_Error);
            ApexPages.addMessage(oMsg);
        }
        oLead.Salutation = System.Label.Web_To_Lead_Pastor;
        sShowMessage = Constants.FALSE_LOWER_CASE;
        bError = false;
        bCaptcha = false;
        bErrorForSave = false;
        lstErrorFields = new List<String>();
    }
    
    /**
    * Method name  : generateRandomNumber
    * Description  : This methods simply returns a random number between 0 and 9.
    * Return Type  : Integer
    * Parameter    : NA
    **/
    public Integer generateRandomNumber(){
        Integer random = Math.Round(Math.Random() * lstNumbers.Size());
        if(random == lstNumbers.size()){
            random--;
        }
        return random;
    }
    
    /**
    * Method name  : generateRandomOperator
    * Description  : This methods simply returns a random Operator.
    * Return Type  : Integer
    * Parameter    : NA
    **/
    public Integer generateRandomOperator(){
        Integer sRandom = Math.Round(Math.Random() * lstOperators.Size());
        if(sRandom == lstOperators.size()){
            sRandom--;
        }
        return sRandom;
    }

    public Integer getINum1(){
        iNum1 = lstNumbers[generateRandomNumber()];
        return iNum1;
    }
    public Integer getINum2(){
        iNum2 = lstNumbers[generateRandomNumber()];
       return iNum2;
    }
    public String getSOperator(){
        sOperator = lstOperators[generateRandomOperator()];
        return sOperator;
    }
    
    /**
    * Method name  : validateCaptcha
    * Description  : This method is used to validate Captcha entered by user.
    * Return Type  : Boolean
    * Parameter    : NA
    **/   
    public Boolean validateCaptcha(){
        if(!String.isEmpty(sInput)){
            if(sOperator == '+'){
                iNumResult = iNum1 + iNum2;
            }
            else if(sOperator == '*'){
                iNumResult = iNum1 * iNum2;
            }
            if(sInput == String.valueOf(iNumResult)){
            }else{
                sResult = System.Label.Web_To_Lead_Captcha_Error; 
                bError = true;
                return bError;
            }
        }else{
            sResult = System.Label.Web_To_Lead_Captcha_Error; 
            bError = true;
            return bError;
        }
        return bError;
    }
    
    /**
    * Method name  : validateWebLead
    * Description  : This method is used to validate inputs entered by user.
    * Return Type  : PageReference
    * Parameter    : NA
    **/
    public PageReference validateWebLead(){
        sShowMessage = Constants.FALSE_LOWER_CASE;
        bError = false;
        bErrorForSave = false;
        bCaptcha = validateCaptcha();
        if(bCaptcha){
            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,System.Label.Web_To_Lead_Captcha_Error_2);
            ApexPages.addMessage(oMsg);
            return null;
        }
        if(oLead.StateCode == '__')
            oLead.StateCode = '';
        bError = validateFields();
        if(bError){
            sInput = Constants.EMPTY_STRING;
            return null;
        }
        oLead.LastName = sLastName;
        
        If(sChurchAgreementToFaith == System.Label.Web_To_Lead_Y){
            oLead.Statement_Of_Faith_Compatibility__c = System.Label.Web_To_Lead_Y;
        }else{
            oLead.Statement_Of_Faith_Compatibility__c = System.Label.Web_To_Lead_N;
        }
        String sName ='';
        sName = oLead.FirstName +' '+ oLead.LastName;
        oLead.Email = sPastorEmail;
        List<Lead> lstLead = new List<Lead>();
        try{
            lstLead = [Select Id, Church_Name_Local_Language__c from Lead
                Where (Church_Name_Local_Language__c =: oLead.Church_Name_Local_Language__c AND
                Name =: sName) OR Email =: oLead.Email Limit 1];
        }catch(Exception ex){
            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,System.Label.Web_To_Lead_Query_Error);
            ApexPages.addMessage(oMsg);
            return null;
        }
        if(lstLead.size() > 0){
            sShowMessage = Constants.TRUE_LOWER_CASE;
            return null;
        }
        saveWebLead();
        if(bErrorForSave == true){
            return null;
        }else{
            PageReference oPg = new PageReference(Constants.CREATE_LEAD_SUCCESS_URL);
            return oPg;
        }
        return null;
    }
    
    /**
    * Method name  : saveWebLead
    * Description  : This method is used to save inputs entered by user.
    * Return Type  : PageReference
    * Parameter    : NA
    **/
    public PageReference saveWebLead(){
        sFieldOffice = Constants.NO_CLUSTER + sFieldOffice;
        oLead.Commitment_To_Child_Ministry__c = sChurchMinistry;        
        List<PM_Hierarchy__c> lstCluster = new List<PM_Hierarchy__c>();
        try
        {
            lstCluster = [Select Id from PM_Hierarchy__c where RecordType.DeveloperName =: Constants.PM_HIERARCHY_CLUSTER_RT_API_NAME And Name =: sFieldOffice limit 1];
        }catch(Exception Ex){
            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,System.Label.Web_To_Lead_Query_Error_2);
            ApexPages.addMessage(oMsg);
            bErrorForSave = true;
            return null;
        }
        if(!lstCluster.isEmpty()){
            oLead.Cluster__c = lstCluster[0].Id;
        }
        
        Savepoint sp = Database.setSavepoint();
        try{            
            insert oLead;
        }
        catch(Exception ex){
            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(oMsg);
            bErrorForSave = true;
            return null;
        }
        if(oLead.Id != null){
        if(!String.isEmpty(sYourLastName) ){
            
            String sContactDetails = Constants.EMPTY_STRING;
            if(sContactSalutation  == null){
                sContactSalutation = Constants.EMPTY_STRING;
            }
            if(sYourRole == null){
                sYourRole =Constants.EMPTY_STRING;
            }
            sContactDetails = System.Label.Web_To_Lead_Title + ' ' + sContactSalutation + '\n' + System.Label.Web_To_Lead_First_Name + ' ' + sYourFirstName + '\n' + System.Label.Web_To_Lead_Last_Name + ' ' + sYourLastName + '\n' + System.Label.Web_To_Lead_Email + ' ' + sYourEmail + '\n' + System.Label.Web_To_Lead_Phone + ' ' + sYourPhone + '\n' + System.Label.Web_To_Lead_Role_At_Church + ' ' + sYourRole;
           
            lstNote.add(createNote(System.Label.Web_To_Lead_Contact_Information, sContactDetails));
        }
          lstNote.add(createNote(System.Label.Web_To_Lead_Reason_of_Church_Interest, sChurchInterest));
        
          lstNote.add(createNote(System.Label.Web_To_Lead_Church_Demonstration, sChurchMinistryDemo));
       
          lstNote.add(createNote(System.Label.Web_To_Lead_Any_Other_Beliefs, sOtherBeliefs));
        
        try{
            insert lstNote;
        }
        catch(Exception ex){
            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(oMsg);
            Database.rollback(sp);
            bErrorForSave = true;
            return null;
        }     
        sShowMessage = Constants.STRING_FALSE;
        }
        PageReference oPg = new PageReference(Constants.CREATE_LEAD_SUCCESS_URL);
        return oPg;
    }
    
    /**
    * Method name  : cancel
    * Description  : This method is used to cancel Web To Lead Page.
    * Return Type  : PageReference
    * Parameter    : NA
    **/
    public PageReference cancel(){
        if(!String.isEmpty(oLead.id)){
            PageReference oPageReference = new PageReference('/apex/LeadFormOutput?id='+oLead.Id);
            oPageReference.setRedirect(true);
            return oPageReference;
        }
        return null;
    }
    
    /**
    * Method name  : getSalutations
    * Description  : Getter method for salutations.
    * Return Type  : List<selectOption>
    * Parameter    : NA
    **/
    public List<selectOption> getSalutations() {
        List<selectOption> lstOptions = new List<selectOption>(); 
        lstOptions.add(new selectOption(Constants.EMPTY_STRING, System.Label.Web_To_Lead_None));
        Schema.DescribeFieldResult fieldResult =
            Lead.Salutation.getDescribe();
        List<Schema.PicklistEntry> oPLE = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry oPicklistEntry: oPLE)
            {
                lstOptions.add(new SelectOption(oPicklistEntry.getValue(),oPicklistEntry.getLabel()));
            } 
        return lstOptions; 
    }
    
    /**
    * Method name  : getSalutations
    * Description  : Getter method to get the Roles.
    * Return Type  : List<selectOption>
    * Parameter    : NA
    **/
    public List<selectOption> getYourRoles() {
        List<selectOption> lstOptions = new List<selectOption>(); 
        lstOptions.add(new selectOption(Constants.EMPTY_STRING, System.Label.Web_To_Lead_None));
        Schema.DescribeFieldResult fieldResult =
            Contact.Contact_Role_At_Church__c.getDescribe();
        List<Schema.PicklistEntry> oPLE = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry oPicklistEntry: oPLE)
            {
                lstOptions.add(new SelectOption(oPicklistEntry.getValue(),oPicklistEntry.getLabel()));
            } 
        return lstOptions; 
    }
    
    /**
    * Method name  : getOneGodOptions
    * Description  : Getter method for OneGodOptions.
    * Return Type  : List<selectOption>
    * Parameter    : NA
    **/
    public List<SelectOption> getOneGodOptions(){
        List<selectOption> lstOneGodOptions = new List<selectOption>();
        lstOneGodOptions.add(new selectOption(Constants.EMPTY_STRING , System.Label.Web_To_Lead_None));
        lstOneGodOptions.add(new selectOption(System.Label.Web_To_Lead_Y, System.Label.Web_To_Lead_Yes));
        lstOneGodOptions.add(new selectOption(System.Label.Web_To_Lead_N, System.Label.Web_To_Lead_No));
        return lstOneGodOptions;
    }
    
    /**
    * Method name  : validateFields
    * Description  : This method is called by validateWebLead. It is
                     used to validate the input entered by user.
    * Return Type  : Boolean
    * Parameter    : NA
    **/
    private Boolean validateFields(){
        if(String.isEmpty(oLead.Church_Name_Local_Language__c) || String.isEmpty(oLead.FirstName) || 
            String.isEmpty(sLastName) || String.isEmpty(sPastorEmail) || String.isEmpty(oLead.Primary_Contact_s_Phone_Number__c) || 
            String.isEmpty(oLead.LeadSource) || String.isEmpty(sChurchInterest) || 
            String.isEmpty(oLead.CountryCode) ||  String.isEmpty(oLead.Closest_Major_City_Local_Language__c) ||  
            String.isEmpty(oLead.Street) || String.isEmpty(oLead.City) ||   
            String.isEmpty(sChurchMinistry) ||  String.isEmpty(sChurchMinistryDemo) || String.isEmpty(sChurchAgreementToFaith) || 
            String.isEmpty(sOtherBeliefs) || String.isEmpty(oLead.Ministries__c) ||  
            String.isEmpty(oLead.International_Mission_Affiliation__c) ||  oLead.Number_Of_Active_Church_Members__c == null
        ){
            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,System.Label.Web_To_Lead_Error_Message);
            ApexPages.addMessage(oMsg);
            bError = true;
        }
        if(!String.isEmpty(oLead.LeadSource) && oLead.LeadSource == 'Other' && String.isEmpty(oLead.Other_Lead_Source__c)){
            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,System.Label.Web_To_Lead_Other_Reason_Error_Message);
            ApexPages.addMessage(oMsg);
            bError = true;
        }
        if((!String.isEmpty(sYourFirstName) || !String.isEmpty(sYourEmail) || 
            !String.isEmpty(sYourPhone) || !String.isEmpty(sYourRole)) && 
            String.isEmpty(sYourLastName)){
                ApexPages.Message oMsg = new ApexPages.Message(
                    Apexpages.Severity.ERROR,System.Label.Web_To_Lead_Please_Enter_Your_Last_Name
                );
            ApexPages.addMessage(oMsg);
            bError = true;
        }
        if(!String.isEmpty(sYourEmail) && !Pattern.matches(Constants.PATTERN_TO_MATCH, sYourEmail)){
            ApexPages.Message oMsg = new ApexPages.Message(
                    Apexpages.Severity.ERROR,System.Label.Web_To_Lead_Your_Email_Error
            );
            ApexPages.addMessage(oMsg);
            bError = true;
        }
        if(!String.isEmpty(sPastorEmail) && !Pattern.matches(Constants.PATTERN_TO_MATCH, sPastorEmail)){
            ApexPages.Message oMsg = new ApexPages.Message(
                Apexpages.Severity.ERROR,System.Label.Web_To_Lead_Pastor_Email_Error
            );
            ApexPages.addMessage(oMsg);
            bError = true;
        }
        return bError;
    }
    /**
    * Method name  : createNote
    * Description  : This is a generic method to create Notes.
    * Return Type  : Note
    * Parameter    : String, String
    **/
    private Note__c createNote(String sTitle, String sBody){
        Note__c oNote = new Note__c();
        oNote.Lead__c = oLead.Id;
        oNote.Name = sTitle;
        oNote.Body__c = sBody;
        oNote.Visibility__c='ICP and Field Office';
        oNote.Type__c ='Other';
        oNote.RecordTypeId =[Select Id,SobjectType,Name From RecordType where Name ='Lead' and SobjectType ='Note__c'  limit 1].Id;
        return oNote;
        
    }
    

}