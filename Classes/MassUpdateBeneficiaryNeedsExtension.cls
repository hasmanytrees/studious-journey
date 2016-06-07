/******************************************************************************************************
Class Name         : MassUpdateBeneficiaryNeedsExtension
Description        : This is a controller class for MassUpdateBeneficiaryNeeds Page.
                     This will create Needs for Beneficiary.
Created By         : Sowmya Chamakura
Created On         : 27-Jan-2015 
 ******************************************************************************************************/

public with sharing class MassUpdateBeneficiaryNeedsExtension {
    public Id icpId {
        get;
        set;
    }
    public String sSuccessMessage {
        get;
        set;
    }
    public Account oIcpAccount {
        get;
        set;
    }
    public String sSelectedNeed {
        get;
        set;
    }
    public List<SelectOption> lstNeedsList {
        get;
        set;
    }
    public FilterListHandler oFilterListHandler {
        get;
        set;
    }
    public Custom_Search_Setting__c oSearchSetting;
    List<String> lstFieldAPINames = new List<String>();
    List<String> lstFieldLabels = new List<String>();
    public List<sObject> lstSObjectResult {
        get;
        set;
    }
    public set<String> setFieldsToDisplay {
        get;
        set;
    }
    public list<String> lstFieldsToDisplay {
        get;
        set;
    }
    public list<AccountWrapper> lstAccntWrapperLst {
        get;
        set;
    }
    public Boolean bIsSearchResult {
        get;
        set;
    }

    public String sShowMessage {
        get;
        set;
    }
    public String sPowerPartner {
        get;
        set;
    }
    public String sUserType {
        get;
        set;
    }

    /**
     * Method name  : MassUpdateBeneficiaryNeedsExtension
     * Description  : Constructor
     * Return Type  : NA
     * Parameter    : ApexPages. StandardController
     **/
    public MassUpdateBeneficiaryNeedsExtension(ApexPages.StandardController oController) {
        sSuccessMessage = Label.Needs_updated_Successfully;
        sShowMessage = Constants.FALSE_LOWER_CASE;
        bIsSearchResult = false;
        lstNeedsList = new List<SelectOption>();
        lstAccntWrapperLst = new List<AccountWrapper>();
        oSearchSetting = new Custom_Search_Setting__c();
        oFilterListHandler = new FilterListHandler();
        oFilterListHandler.mapValueType = new Map<String, STring>();
        setFieldsToDisplay = new set<String>();
        List<Global_Data__c> lstGlobalData = null;
        sPowerPartner = Constants.POWERPARTNER;
        sUserType = UserInfo.getUserType();
        icpId = ApexPages.currentPage()
            .getParameters()
            .get(Constants.ID);
        Account oIcpRecord = (Account) oController.getRecord();
        Id needRectypeId = Utility.getRecordTypeIdByDeveloperName(Global_Data__c.SObjectType,
            Constants.GLOBAL_DATA_NEEDS_DATA_RT_API_NAME);
        try {
            oIcpAccount = [Select Id, Name, Field_Office__c from Account where id = :
                oIcpRecord.Id
            ];
            lstGlobalData = [Select Id, Name, Need_Type__c from Global_Data__c where Recordtypeid = :
                needRectypeId and(Need_Type__c = : Constants.BENEFICIARY_NEED OR Need_Type__c = :
                    Constants.Both) Order By Name
            ];
        } catch(System.QueryException oQEx) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                oQEx.getMessage());
            ApexPages.addMessage(oMsg);
            return;
        }
        lstNeedsList.add(new SelectOption('', System.Label.select_need));
        for(Global_Data__c oNeedData: lstGlobalData) {
            lstNeedsList.add(new SelectOption(oNeedData.Id, oNeedData.Name));
        }
        setValueTypeMap();
    }

    /**
    * Method name  : setValueTypeMap
    * Description  : This method populates data structures which stores informationof all the fields which
                     are shown to User. This information consists of labels, API names & data type of fields displayed on UI.
    * Return Type  : void
    * Parameter    : void
    **/
    public void setValueTypeMap() {
        lstFieldsToDisplay = new list<String>();
        List<Custom_Search_Setting__c> lstSetting =
            new List<Custom_Search_Setting__c>();
        try {
            lstSetting = [select Name, Object__c,
                Fields_to_Filter__c, Numeric_Fields_to_Filter__c, Result_Column_Fields__c,
                Fields_to_Filter_Label__c, Result_Column_Fields_Label__c from Custom_Search_Setting__c where Name = :
                Constants.ACCOUNT_BENEFICIARY1
            ];
        } catch(System.QueryException oQe) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                oQe.getMessage());
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oQe, 'MassUpdateBeneficiaryNeedsExtension',
                'setValueTypeMap', 'SFDC CI');
            return;
        }
        if(!lstSetting.isEmpty())
            oSearchSetting = lstSetting[0];
        if(String.isNotBlank(oSearchSetting.Fields_to_Filter__c))
            lstFieldAPINames = oSearchSetting.Fields_to_Filter__c.split(Constants.COMMA);
        for(String field: lstFieldAPINames)
            oFilterListHandler.mapValueType.put(field, Constants.QUOTE_NEED);
        if(String.isNotBlank(oSearchSetting.Numeric_Fields_to_Filter__c))
            lstFieldAPINames.addAll(oSearchSetting.Numeric_Fields_to_Filter__c.split(
                Constants.COMMA));
        if(String.isNotBlank(oSearchSetting.Fields_to_Filter_Label__c)){
            //lstFieldLabels = oSearchSetting.Fields_to_Filter_Label__c.split(Constants.COMMA);
            lstFieldLabels = Label.Search_Setting_Beneficiary1_Fields_To_Filter_Label.split(Constants.COMMA);   
        }
        if(String.isNotBlank(oSearchSetting.Result_Column_Fields__c))
            oFilterListHandler.lstFields.add(new SelectOption(Constants.NONE, System.Label.Search_Ben_Controller_None));
        setFieldsToDisplay.addAll(oSearchSetting.Result_Column_Fields__c.split(
            Constants.COMMA));
        setFieldsToDisplay.addAll(lstFieldAPINames);
        lstFieldsToDisplay.addAll(setFieldsToDisplay);
        for(Integer i = 0; i<lstFieldAPINames.size(); i++) {
            oFilterListHandler.lstFields.add(new selectOption(lstFieldAPINames[i],
                lstFieldLabels[i]));
        }
    }

    /**
     * Method name  : bensearch
     * Description  : As per the filter provided from UI, this method queries all Beneficiaries satisfying the criteria provided.
     * Return Type  : void
     * Parameter    : void
     **/
    public PageReference bensearch() {
        lstSObjectResult = new List<sObject>();
        lstAccntWrapperLst = new List<AccountWrapper>();
        bIsSearchResult = true;
        String sQuery =
            'Select IsPersonAccount, Beneficiary_Confession_Of_Faith_Date__c,';
        for(String field: setFieldsToDisplay)
            sQuery = sQuery + field + ',';
        sQuery = sQuery +
            'Id From Account Where Beneficiary_Status__c= \'Active\'  and ICP__c =' +
            '\'' + oIcpAccount.Id + '\' AND';

        if(oFilterListHandler.oCompControllerRef != null) {
            oFilterListHandler.oCompControllerRef.formQuery();
            sQuery += oFilterListHandler.oCompControllerRef.sQuery;
        }

        sQuery += ' Id!=null AND RecordType.Name LIKE \'% Beneficiary%\' Limit 500';
        try {
            lstSObjectResult = Database.Query(sQuery);
        } catch(QueryException oQEx) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.Account_Search);
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oQEx, 'MassUpdateBeneficiaryNeedsExtension',
                'bensearch', 'SFDC CI');
            return null;
        }
        List<Account> lstAcc = new List<Account>();
        List<AccountWrapper> lstAccWrap = new List<AccountWrapper>();
        for(sObject oSObject: lstSObjectResult) {
            AccountWrapper oAw = new AccountWrapper();
            oAw.bIsChecked = false;
            oAw.oAccount = (Account) oSObject;
            lstAcc.add(oAw.oAccount);
            oAw.oNeedAssociation = new Needs_Association__c();
            lstAccWrap.add(oAw);
        }

        List<Needs_Association__c> lstNeedList = new List<Needs_Association__c>
            ();
        try {
            lstNeedList = [Select ID, Name, Account__c,
                Severity__c, Comments__c from Needs_Association__c where Need__c = :
                sSelectedNeed and Account__c IN: lstAcc
            ];
        } catch(QueryException oQEx) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.Account_Search);
            ApexPages.addMessage(oMsg);
            return null;
        }
        lstAccntWrapperLst = new List<AccountWrapper>();
        Boolean hasNeed = false;
        if(!lstNeedList.isEmpty()) {
            for(AccountWrapper awrap: lstAccWrap) {
                hasNeed = false;
                AccountWrapper oAw = new AccountWrapper();
                for(Needs_Association__c oNeedsAssociation: lstNeedList) {
                    oAw.oAccount = awrap.oAccount;
                    if(oNeedsAssociation.Account__c == awrap.oAccount.Id) {
                        hasNeed = true;
                        oAw.oNeedAssociation = oNeedsAssociation;
                        oAw.bIsChecked = true;
                        lstAccntWrapperLst.add(oAw);
                    }
                }
                if(!hasNeed)
                    lstAccntWrapperLst.add(oAw);
            }
        } else
            lstAccntWrapperLst.addAll(lstAccWrap);
        lstNeedList = new List<Needs_Association__c>();
        return null;
    }

    /**
     * Method name  : associateNeeds
     * Description  : This method will create/update Associated Needs.
     * Return Type  : void
     * Parameter    : void
     **/
    public PageReference associateNeeds() {
        List<Needs_Association__c> needInsertList = new List <
            Needs_Association__c>();
        Needs_Association__c needassctn;
        for(AccountWrapper oAwrp: lstAccntWrapperLst) {
            if(oAwrp.bIsChecked == true) {
                needassctn = new Needs_Association__c();
                if(null != oAwrp.oNeedAssociation && oAwrp.oNeedAssociation.Id != null) {
                    needassctn.id = oAwrp.oNeedAssociation.Id;
                }
                needassctn.Severity__c = oAwrp.oNeedAssociation.Severity__c;
                needassctn.Comments__c = oAwrp.oNeedAssociation.Comments__c;
                needassctn.Need__c = sSelectedNeed;
                needassctn.Association_Type__c = Constants.BENEFICIARY_ASSOCIATION;
                if(oAwrp.oAccount != null && (null == oAwrp.oNeedAssociation || oAwrp.oNeedAssociation
                        .Id == null)) {
                    needassctn.Account__c = oAwrp.oAccount.Id;
                }
                needInsertList.add(needassctn);
            }
        }

        if(!needInsertList.isEmpty()) {
            List<Database.UpsertResult> lstUpsertResults =
                Database.upsert(needInsertList, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpsertResults, needInsertList,
                'Needs_Association__c', 'MassUpdateAccountsExtension', 'updateList',
                'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                ApexPages.Message oMsgError = new ApexPages.Message(Apexpages.Severity.ERROR,
                    Label.Error_in_saving_need);
                ApexPages.addMessage(oMsgError);
                return null;
            }
        }
        sShowMessage = Constants.TRUE_LOWER_CASE;
        return null;
    }

    /**
     * Class name   : AccountWrapper
     * Description  : This is inner class used as a Data structure to hold & display information corresponding to Beneficiary and its associations.
     **/
    public class AccountWrapper {
        public boolean bIsChecked {
            get;
            set;
        }
        public Account oAccount {
            get;
            set;
        }
        public Needs_Association__c oNeedAssociation {
            get;
            set;
        }
    }

}