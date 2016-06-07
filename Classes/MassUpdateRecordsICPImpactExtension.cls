/******************************************************************************************************
Class Name         : MassUpdateRecordsICPImpactExtension
Description        : This is VisualForce controller for the Page MassUpdateRecordsICPImpact, which helps
                     in mass creation of ICP Impacts for an associated Master Disaster record.
Created By         : Sudipta Nayak
Created On         : 24-Jul-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public with sharing class MassUpdateRecordsICPImpactExtension {

    Public List<AccountWrapper> lstICPWrapper {
        get;
        set;
    }
    Public List<AccountWrapper> lstBeneficiaryWrapper {
        get;
        set;
    }
    Public ICP_Impact__c oFilter{
        get;
        set;
    }
    Public Boolean bDisplayICPImpact {
        get;
        set;
    }
    Public List<SelectOption> lstFilterVal {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(Constants.FIELD_OFFICE, System.Label.AS_Field_Office));
            options.add(new SelectOption(Constants.CLUSTER, System.Label.Disaster_Cluster));
            options.add(new SelectOption(Constants.TERRITORY, System.Label.Disaster_Territory));
            return options;
        }
        set;
    }
    Public ICP_Impact__c oIcpImpactRecValues {
        get;
        set;
    }
    Public String sFilters {
        get;
        set;
    }
    Public Boolean bIsErrorFlag {
    	get;
        set;
    }
    id recID;
    Set<String> setErrorICPs;
    Set<String> setSuccessICPs;

     /**
     * Method name  : MassUpdateRecordsICPImpactExtension
     * Description  : This is the constructor method of MassUpdateRecordsICPImpactExtension class.
     * Return Type  : NA
     * Parameter    : void
     **/
    public MassUpdateRecordsICPImpactExtension(ApexPages.StandardController controller) {

        recID = ApexPages.currentPage()
            .getParameters()
            .get(Constants.DISASTER);
        Disaster__c oDisaster = [SELECT Id, Field_Office__c from Disaster__c where Id = : recID];
        bDisplayICPImpact = false;
        oFilter = new ICP_Impact__c(Field_Office__c = oDisaster.Field_Office__c);
        sFilters = Constants.FIELD_OFFICE;
        setErrorICPs = new Set<String>();
        setSuccessICPs = new Set<String>();
        renderFilter();
    }

    /**
     * Method name  : search
     * Description  : This method returns the list of ICPs based on the filter criteria selected by the User
     * Return Type  : pagereference
     * Parameter    : void
     **/
    Public pagereference search() {
        bDisplayICPImpact = true;
        List<Account> lstICPAccount = new List<Account>();
        List<ICP_Impact__c> lstICPImpactToLoop = new List<ICP_Impact__c>();
        lstICPAccount = [Select Id, Name, Cluster__c, ICP_ID__c, ICP_Status__c from Account 
                         where( Cluster__c = : oFilter.Cluster__c OR Cluster__r.Territory__c =: oFilter.Territory__c 
                               OR Cluster__r.Territory__r.Field_Office__c =: oFilter.Field_Office__c) 
                         AND (Recordtype.DeveloperName =: Constants.ICP_RT_API_NAME) AND (ICP_Status__c =: Constants.ACTIVE
                                                                                          OR ICP_Status__c =: Constants.SUSPENDED OR ICP_Status__c =: Constants.ICP_STATUS_PHASED_OUT) LIMIT 500
                        ];
        if(!lstICPAccount.isEmpty()) {
            lstICPImpactToLoop = [Select Id, ICP_Name__c, Disaster_Name__c from ICP_Impact__c where ICP_Name__c in
                : lstICPAccount AND Disaster_Name__c =: recID
            ];
        }
        Set<Id> setICPIDs = new Set<Id>();
        if(!lstICPImpactToLoop.isEmpty()) {
            for(ICP_Impact__c oICPImpact: lstICPImpactToLoop) {
                setICPIDs.add(oICPImpact.ICP_Name__c);
            }
        }
        if(lstICPAccount != NULL && lstICPAccount.size()> 0) {
            lstICPWrapper = new List<AccountWrapper>();
            for(Account oAccount: lstICPAccount) {
                if(!setICPIDs.isEmpty() && setICPIDs.contains(oAccount.Id))
                    lstICPWrapper.add(new AccountWrapper(oAccount, true));
                else
                    lstICPWrapper.add(new AccountWrapper(oAccount, false));
            }
        }
        return null;
    }

    /**
     * Method name  : renderFilter
     * Description  : This method renders the fields to set Filter Criteria based on User's selection
     * Return Type  : void
     * Parameter    : void
     **/
    public void renderFilter() {
        if(sFilters == Constants.TERRITORY) {
            oFilter.Cluster__c = oFilter.Field_Office__c = NULL;
        }
        if(sFilters == Constants.CLUSTER) {
            oFilter.Territory__c = oFilter.Field_Office__c = NULL;
        }
        if(sFilters == Constants.FIELD_OFFICE) {
            oFilter.Territory__c = oFilter.Cluster__c = NULL;
        }

    }
    
    /**
     * Method name  : validateRecordsToInsert
     * Description  : This method is used to validate the input data before inserting in database
     * Return Type  : Boolean
     * Parameter    : AccountWrapper
     **/
    public void validateRecordsToInsert(AccountWrapper oAcntWrap) {
        bIsErrorFlag = false;
        if(oAcntWrap.oIcpImpactRecValues.Disaster_Impact_To_ICP_Infrastructure__c == NULL || 
			oAcntWrap.oIcpImpactRecValues.Disaster_Impact_On_ICP_Program__c == NULL || 
            oAcntWrap.oIcpImpactRecValues.ICP_Disaster_Impact_Description__c == NULL) {
                setErrorICPs.add(oAcntWrap.oAccount.Name);
                oAcntWrap.bIsSelected = false;
                bIsErrorFlag = true;
            }
        else {
            setSuccessICPs.add(oAcntWrap.oAccount.Name);
            oAcntWrap.bAlreadyExists = true;
        }
    }
    
    /**
     * Method name  : save
     * Description  : This method creates new ICP Impact records for selected Beneficiaries
     * Return Type  : pagereference
     * Parameter    : void
     **/
    public pagereference save() {

        List<ICP_Impact__c> lstICPImpact = new List<ICP_Impact__c>();
        for(AccountWrapper icpWrap: lstICPWrapper) {
            if(icpWrap.bIsSelected && !icpWrap.bAlreadyExists) {
                validateRecordsToInsert(icpWrap);
                if(!bIsErrorFlag) {
                    lstICPImpact.add(new ICP_Impact__c(ICP_Name__c = icpWrap.oAccount.ID,
                        Disaster_Name__c = recID,
                        Disaster_Impact_To_ICP_Infrastructure__c = icpWrap.oIcpImpactRecValues.Disaster_Impact_To_ICP_Infrastructure__c,
                        Disaster_Impact_On_ICP_Program__c = icpWrap.oIcpImpactRecValues.Disaster_Impact_On_ICP_Program__c,
                        ICP_Disaster_Impact_Description__c = icpWrap.oIcpImpactRecValues.ICP_Disaster_Impact_Description__c
                    ));
                    icpWrap.bIsSelected = true;
                }
            }
        }

        if(lstICPImpact != NULL && lstICPImpact.size()> 0) {
			List < Database.SaveResult > lstInsertResults =
				Database.insert(lstICPImpact, false);
			Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
				lstInsertResults, lstICPImpact, 'ICP_Impact__c',
				'MassUpdateRecordsICPImpactExtension', 'save', 'SFDC CI', false);
        }
        if(!setSuccessICPs.isEmpty() && !setErrorICPs.isEmpty()) {
            ApexPages.Message oMsgSuccess = new ApexPages.Message(ApexPages.Severity.info,
            	System.Label.Disaster_ICP_Impact_Success_Message + setSuccessICPs);
            ApexPages.addMessage(oMsgSuccess);
            setSuccessICPs.clear();
            ApexPages.Message oMsgError = new ApexPages.Message(ApexPages.Severity.Error,
            	System.Label.Disaster_ICP_Impact_Error_Message + setErrorICPs);
            ApexPages.addMessage(oMsgError);
            setErrorICPs.clear();
            return null;
        }
        else if(!setErrorICPs.isEmpty()) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
            	System.Label.Disaster_ICP_Impact_Error_Message + setErrorICPs);
            ApexPages.addMessage(oMsg);
            setErrorICPs.clear();
            return null;
        }
        else {
            if(!setSuccessICPs.isEmpty()) {
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.info,
                    System.Label.Disaster_ICP_Impact_Success_Message + setSuccessICPs);
                ApexPages.addMessage(oMsg);
            }
        	PageReference pg = new PageReference(Constants.BACKSLASH + recID);
            return pg;
        }
    }

    /**
     * Method name  : cancel
     * Description  : This method redirects the user to the Master Disaster Record.
     * Return Type  : pagereference
     * Parameter    : void
     **/
    public PageReference cancel() {
        PageReference pg = new PageReference(Constants.BACKSLASH + recID);
        return pg;
    }

     /**
     * Class name   : AccountWrapper
     * Description  : This is an inner class used as a Data structure to hold & display information corresponding to Beneficiary and its associations.
     **/
    Public class AccountWrapper {
        Public Boolean bIsSelected {
            get;
            set;
        }
        Public Account oAccount {
            get;
            set;
        }
        public Boolean bAlreadyExists {
            get;
            set;
        }
        Public ICP_Impact__c oIcpImpactRecValues {
            get;
            set;
        }
        Public AccountWrapper(Account oAccount, Boolean bAlreadyExists) {
            if(bAlreadyExists)
                this.bIsSelected = true;
            else
                this.bIsSelected = false;
            this.oAccount = oAccount;
            this.bAlreadyExists = bAlreadyExists;
        	oIcpImpactRecValues = new ICP_Impact__c();
        }
    }
}