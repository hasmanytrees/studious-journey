/************************************************************************
*Class Name         :AccountSearchController
*Deascriotion       : This is VF controller for the Page AccountSearchPage, which helps user to Search
                      through system for existing beneficiary records based on various input parameters.  
*Created By         : Vishal Katyare 
*Created On         : 12/27/2013 

********************************************************************************/

public with sharing class AccountSearchController {
    String icpPortalProfile;

    public FilterListHandler oFilterListHandler {
        get;
        set;
    }
    public List<Account> lstAccount {
        get;
        set;
    }
    List<Account> lstAccountVar {
        get;
        set;
    }
    public String sObjectType {
        get;
        set;
    }
    public String sObjectName {
        get;
        set;
    }
    public List<sObject> lstSObjectResult {
        get;
        set;
    }
    public Custom_Search_Setting__c oSearchSetting {
        get;
        set;
    }
    public boolean bRenderObjectType {
        get;
        set;
    }
    public String sColumnName {
        get;
        set;
    }

    List<String> lstFieldAPINames = new List<String>();
    List<String> lstFieldLabels = new List<String>();
    public set<String> setFieldsToDisplay {
        get;
        set;
    }
    public list<String> lstFieldsToDisplay {
        get;
        set;
    }
    public Schema.sObjectType sObj {
        get;
        set;
    }
    public map<String, String> mapLabel {
        get;
        set;
    }
    public List<String> lstResultAPINames = new List<String>();
    Id cdspRecTypeId = null;
    Id cspRecTypeId = null;
    Id icpRecTypeId = null;
    Id icpLeadRecTypeId = null;
    String sRecordType ='';

    /**
     * Method name  : AccountSearchController
     * Description  : This is a constructor class of AccountSearchController class.
     * Return Type  : NA
     * Parameter    : void
     **/
    public AccountSearchController() {
        lstSObjectResult = new List<sObject>();
        mapLabel = new Map<String, String>();
        bRenderObjectType = false;
        setFieldsToDisplay = new set<String>();
        lstFieldsToDisplay = new list<String>();
        oFilterListHandler = new FilterListHandler();
        oSearchSetting = new Custom_Search_Setting__c();
        if(sObjectName == null)
            sObjectName = Constants.ACCOUNT_API_NAME;
        if(sObjectType == null)
            sObjectType = Constants.BEN_API_NAME;
        oFilterListHandler.sObjectName = sObjectName;
        oFilterListHandler.sObjectType = sObjectType;
        oFilterListHandler.mapValueType = new Map<String, STring>();
        lstAccountVar = new List<Account>();
        lstAccount = new List<Account>();
        setvalueTypeMap();
        sColumnName = Constants.EMPTY_STRING;
        
        cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);
        icpLeadRecTypeId = Utility.getRecordTypeIdByDeveloperName(Lead.SObjectType,
            Constants.ICP_LEAD_RT_API_NAME);
    }

    /**
    * Method name  : setvalueTypeMap
    * Description  : This method sets map in the VF component used for filter criteria. This sets parameters
                     which take input as a string literals and need quote to be insterted in dynamic query.
    * Return Type  : void
    * Parameter    : void
    **/
    public void setvalueTypeMap() {
            
        lstSObjectResult = new List<sObject>();
        String sObjTypeParam = System.currentPagereference()
            .getParameters().get('sObjectType');
        System.debug('sObjTypeParam: '+sObjTypeParam);
        if(null<>sObjTypeParam){
            sObjectType = String.escapeSingleQuotes(sObjTypeParam);
        }else if(Constants.LEAD_API_NAME.equals(sObjectName)){
            sObjectType = Constants.ICP_RT_API_NAME;
        }
                
        if(UserInfo.getUserType() ==Constants.POWERPARTNER && sObjectType == Constants.ICP_RT_API_NAME){
            sObjectName = Constants.ICP_MINI_PROFILE_OBJ_NAME;
            sRecordType = '';
        }
        System.debug('sObjectName: '+sObjectName+' sObjectType: '+sObjectType+' sRecordType: '+sRecordType);
        
        oFilterListHandler.resetSelectedValue();
        
        oFilterListHandler.sObjectName = sObjectName;
        oFilterListHandler.sObjectType = sObjectType;
        oFilterListHandler.lstFields = new List<SelectOption>();
        setFieldsToDisplay = new set<String>();
        lstFieldsToDisplay = new list<String>();
        lstFieldAPINames = new List<String>();
        oFilterListHandler.mapValueType = new Map<String, STring>();
        lstFieldLabels = new List<String>();
        setFieldsToDisplay = new set<String>();
        List<Custom_Search_Setting__c> lstSetting = new List <
            Custom_Search_Setting__c>();
        try {
            if(UserInfo.getUserType()!=Constants.POWERPARTNER){
                lstSetting = [select Name, Object__c, Record_Type__c, Fields_to_Filter__c,
                    Numeric_Fields_to_Filter__c,
                    Result_Column_Fields__c, Fields_to_Filter_Label__c,
                    Result_Column_Fields_Label__c
                    from Custom_Search_Setting__c
                    where Object__c = : sObjectName and Record_Type__c = : sObjectType order by Name];
                    system.debug('************lstSetting'+lstSetting);
                
            }
            else{
                if(sObjectType == Constants.BEN_API_NAME){
                    lstSetting = [select Name, Object__c, Record_Type__c, Fields_to_Filter__c,
                    Numeric_Fields_to_Filter__c,
                    Result_Column_Fields__c, Fields_to_Filter_Label__c,
                    Result_Column_Fields_Label__c
                    from Custom_Search_Setting__c                   
                    where Object__c = : sObjectName and Record_Type__c = : sObjectType and Name =:'Portal-Account-Beneficiary'];
                }
                 else{
                lstSetting = [select Name, Object__c, Record_Type__c, Fields_to_Filter__c,
                    Numeric_Fields_to_Filter__c,
                    Result_Column_Fields__c, Fields_to_Filter_Label__c,
                    Result_Column_Fields_Label__c
                    from Custom_Search_Setting__c
                    where Name =:'Portal-Account-ICP'];
                }
            }
        } catch(QueryException oQEx) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.Account_Search);
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oQEx, 'AccountSearchController',
                'setvalueTypeMap', 'SFDC CI');
            return;
        }
        if(!lstSetting.isEmpty())
            oSearchSetting = lstSetting[0];
        if(String.isNotBlank(oSearchSetting.Fields_to_Filter__c))
            lstFieldAPINames = oSearchSetting.Fields_to_Filter__c.split(Constants.COMMA);

        for(String sField: lstFieldAPINames)
            oFilterListHandler.mapValueType.put(sField, Constants.QUOTE_NEED);


        if(String.isNotBlank(oSearchSetting.Numeric_Fields_to_Filter__c))
            lstFieldAPINames.addAll(oSearchSetting.Numeric_Fields_to_Filter__c.split(
                Constants.COMMA));
        if(String.isNotBlank(oSearchSetting.Fields_to_Filter_Label__c)){
            if(!String.isEmpty(oSearchSetting.Record_Type__c)){
                if(oSearchSetting.Record_Type__c.equals(Constants.BEN_API_NAME)){
                    if(UserInfo.getUserType()!=Constants.POWERPARTNER){
                        lstFieldLabels = Label.Search_Setting_Beneficiary_Fields_To_Filter_Label.split(Constants.COMMA);
                    }
                    else{
                        lstFieldLabels = Label.Search_Setting_Beneficiary_Portal_Fields_To_Filter_Label.split(Constants.COMMA);
                    }
                }else if(oSearchSetting.Object__c.equals(Constants.ACCOUNT_API_NAME)){
                    if(UserInfo.getUserType()!=Constants.POWERPARTNER){
                        lstFieldLabels = Label.Search_Setting_ICP_Fields_To_Filter_Label.split(Constants.COMMA);
                    }
                    else{
                        lstFieldLabels = Label.Search_Setting_ICP_Portal_Fields_To_Filter_Label.split(Constants.COMMA);
                    }
                        
                }else if(oSearchSetting.Object__c.equals(Constants.ICP_MINI_PROFILE_OBJ_NAME)){
                    lstFieldLabels = Label.Search_Setting_ICP_Portal_Fields_To_Filter_Label.split(Constants.COMMA);
                }else if(oSearchSetting.Record_Type__c.equals(Constants.ICP_RT_API_NAME)){
                    lstFieldLabels = Label.Search_Setting_Lead_Fields_To_Filter_Label.split(Constants.COMMA);
                }
            }else
            lstFieldLabels = Label.Search_Setting_ICP_Portal_Fields_To_Filter_Label.split(Constants.COMMA);
            
        }
        Map<String, String> mapLabelsToAPINames = new Map<String, String>();
        for(Integer i = 0; i < lstFieldLabels.size(); i++){
            mapLabelsToAPINames.put(lstFieldLabels[i],lstFieldAPINames[i]);
        }
        lstFieldLabels.sort();
        if(String.isNotBlank(oSearchSetting.Result_Column_Fields__c)) {
            lstResultAPINames.addAll(oSearchSetting.Result_Column_Fields__c.split(
                Constants.COMMA));
            setFieldsToDisplay.addAll(oSearchSetting.Result_Column_Fields__c.split(
                Constants.COMMA));
        }
        
        oFilterListHandler.lstFields.add(new SelectOption(Constants.NONE, 
        System.Label.Search_Ben_Controller_None));
        lstFieldsToDisplay.addAll(setFieldsToDisplay);
        setFieldsToDisplay.addAll(lstFieldAPINames);
        for(Integer i = 0; i<lstFieldAPINames.size(); i++) {
            oFilterListHandler.lstFields.add(new selectOption(mapLabelsToAPINames.get(lstFieldLabels[i]),
                lstFieldLabels[i]));
        }
        oFilterListHandler.oCompControllerRef = null;
    }

    /**
     * Method name  : search
     * Description  : This method is called from the search button on VF page, this generates dyamic SOQL based on user provided filter criteria
                      and populates result in pageblocktable.  
     * Return Type  : PageReference
     * Parameter    : void
     **/
    public PageReference search() {
        
        if(UserInfo.getUserType() ==Constants.POWERPARTNER && sObjectType == Constants.ICP_RT_API_NAME){
            sObjectName = Constants.ICP_MINI_PROFILE_OBJ_NAME;
            sRecordType = '';
        }
        if(sObjectType == Constants.BEN_API_NAME){
            sRecordType = cdspRecTypeId + '\' Or RecordTypeId = \'' + cspRecTypeId;
        }
        if(sObjectName == Constants.ACCOUNT_API_NAME && sObjectType == Constants.ICP_RT_API_NAME){
            sRecordType = icpRecTypeId;
            
        }
        if(sObjectName == Constants.LEAD_API_NAME && sObjectType == Constants.ICP_RT_API_NAME){
            sRecordType = icpLeadRecTypeId;
            
        }
        String sQuery = 'Select ';
        for(String sField: setFieldsToDisplay)
            sQuery = sQuery + sField + ',';
        sQuery = sQuery + 'Id From ' + sObjectName + ' where';
        if(oFilterListHandler.oCompControllerRef != null) {
            for(Integer i = 0; i<oFilterListHandler.lstSelectedField.size(); i++) {
                oFilterListHandler.lstSelectedTextValue[i] = String.escapeSingleQuotes(oFilterListHandler.lstSelectedTextValue[i]);
                if(oFilterListHandler.lstSelectedField[i] == Constants.AGE_API_Name) {
                    oFilterListHandler.lstSelectedField[i] = Constants.AGE_IN_MONTHS_API_NAME;
                    if(String.isNotEmpty(oFilterListHandler.lstSelectedOperator[i]) &&
                        String.isNotEmpty(oFilterListHandler.lstSelectedTextValue[i])) {
                        Integer iAgeVar = 0;
                        try {
                            iAgeVar = Integer.ValueOf(oFilterListHandler.lstSelectedTextValue[i]) *
                                12;
                        } catch(Exception oEx) {
                            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                                System.Label.Please_provide_valid_Age_argument);
                            ApexPages.addMessage(oMsg);
                            return null;
                        }
                        oFilterListHandler.lstSelectedTextValue[i] = String.valueOf(iAgeVar);
                    }
                }
            }
            oFilterListHandler.oCompControllerRef.formQuery();
            sQuery += oFilterListHandler.oCompControllerRef.sQuery;
        }
        sQuery += ' Id!=null ';
        if(!String.isEmpty(sRecordType)){
        sQuery += 'AND (RecordTypeId = \'' + sRecordType + '\') ';
        }
        sQuery += 'Order By CreatedDate desc, Id Limit 100';
        System.debug('sQuery: '+sQuery);
        try {
            lstSObjectResult = Database.query(sQuery);
            
        } catch(QueryException oQEx) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.Account_Search);
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oQEx, 'AccountSearchController', 'search',
                'SFDC CI');
            return null;
        }
        sObj = Schema.getGlobalDescribe()
            .get(sObjectName)
            .getDescribe()
            .getSObjectType();
        sColumnName = System.Label.AS_Beneficiary_Name;
        return null;

    }

    /**
     * Method name  : close
     * Description  : This method is called from VF page onclick of close Button and redirects to Salesfoce home page.
     * Return Type  : PageReference
     * Parameter    : void
     **/
    public pageReference close() {
        return new pageReference(Constants.CLOSE_BUTTON_REDIRECT);
    }

    /**
     * Method name  : getMyOptions
     * Description  : This method decides the Record Types for all the Object Names
     * Return Type  : List<SelectOption>
     * Parameter    : void
     **/
    public List<SelectOption> getMyOptions() {
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption(Constants.BEN_API_NAME, System.Label.AS_Beneficiary));
        lstOptions.add(new SelectOption(Constants.ICP_RT_API_NAME, System.Label.Search_Ben_Controller_ICP));
        lstOptions.add(new SelectOption(Constants.FIELD_OFFICE, System.Label.AS_Field_Office));
        lstOptions.add(new SelectOption(Constants.ICP_LEAD, System.Label.AS_ICP_Lead));
        return lstOptions;
    }

    /**
     * Method name  : getRecordTypeListAccount
     * Description  : This method decides the lstOptions displayed for Object Type when Object Name is selected as Account
     * Return Type  : List<SelectOption>
     * Parameter    : void
     **/
    public List<SelectOption> getRecordTypeListAccount() {
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption(Constants.BEN_API_NAME, System.Label.AS_Beneficiary));
        lstOptions.add(new SelectOption(Constants.ICP_RT_API_NAME, System.Label.Search_Ben_Controller_ICP));
        return lstOptions;
    }

    /**
     * Method name  : getRecordTypeListLead
     * Description  : This method decides the lstOptions displayed for Object Type when Object Name is selected as Lead
     * Return Type  : List<SelectOption>
     * Parameter    : void
     **/
    public List<SelectOption> getRecordTypeListLead() {
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption(Constants.ICP_RT_API_NAME, System.Label.Search_Ben_Controller_ICP));
        return lstOptions;
    }

    /**
     * Method name  : getRecordTypeList
     * Description  : This method decides the record types for all the Object Names
     * Return Type  : List<SelectOption>
     * Parameter    : void
     **/
    public List<SelectOption> getRecordTypeList() {
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption(Constants.BEN_API_NAME, System.Label.AS_Beneficiary));
        lstOptions.add(new SelectOption(Constants.ICP_RT_API_NAME, System.Label.Search_Ben_Controller_ICP));
        lstOptions.add(new SelectOption(Constants.FIELD_OFFICE, System.Label.AS_Field_Office));
        lstOptions.add(new SelectOption(Constants.ICP_LEAD, System.Label.AS_ICP_Lead));
        return lstOptions;
    }

    /**
     * Method name  : getObjectList
     * Description  : This method decides the lstOptions displayed in the Object Type picklist sField
     * Return Type  : List<SelectOption>
     * Parameter    : void
     **/
    public List<SelectOption> getObjectList() {
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption(Constants.ACCOUNT_API_NAME, System.Label.Account));
        if(UserInfo.getUserType() != Constants.POWERPARTNER){
          lstOptions.add(new SelectOption(Constants.LEAD_API_NAME, System.Label.Lead));
        }
        return lstOptions;
    }
    
}