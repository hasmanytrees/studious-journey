/******************************************************************************************************
Class Name         : MassUpdateRecordsBenImpactExtension
Description        : This is VisualForce controller for the Page MassUpdateRecordsBenImpact, which helps
                     in mass creation of Beneficiary Impacts for an associated Master Disaster record.
Created By         : Sudipta Nayak
Created On         : 24-Jul-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public with sharing class MassUpdateRecordsBenImpactExtension {
    Public List<AccountWrapper> lstBeneficiaryWrapper {
        get;
        set;
    }
    Public Beneficiary_Impact__c oFilter {
        get;
        set;
    }
    Public Boolean bDisplayBenList {
        get;
        set;
    }
    Public List<SelectOption> lstFilterVal {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(Constants.ICP_TOKEN, System.Label.Search_Ben_Controller_ICP));
            return options;
        }
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
    Set<String> setErrorBeneficiaries;
    Set<String> setSuccessBeneficiaries;

    /**
     * Method name  : MassUpdateRecordsBenImpactExtension
     * Description  : This is the constructor method of MassUpdateRecordsBenImpactExtension class.
     * Return Type  : NA
     * Parameter    : void
     **/
    public MassUpdateRecordsBenImpactExtension(ApexPages.StandardController controller) {

        recID = ApexPages.currentPage()
            .getParameters()
            .get(Constants.DISASTER);
        bDisplayBenList = false;
        oFilter = new Beneficiary_Impact__c();
        setErrorBeneficiaries = new Set<String>();
        setSuccessBeneficiaries = new Set<String>();
    }

    /**
     * Method name  : search
     * Description  : This method returns the list of Beneficiaries based on the filter criteria selected by the User
     * Return Type  : pagereference
     * Parameter    : void
     **/
    Public pagereference search() {
        bDisplayBenList = true;
        Id CDSPBeneficiaryRecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id CSPBeneficiaryRecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        List<Account> lstBeneficiary = new List<Account>();
        List<Beneficiary_Impact__c> lstBenImpactToLoop = new List<Beneficiary_Impact__c>();
        lstBeneficiary = [Select Id, Name, Local_Beneficiary_ID__c,
                          RecordTypeId, Beneficiary_Status__c from Account where ICP__c = : oFilter.ICP__c
                          AND(RecordTypeId = : CDSPBeneficiaryRecordTypeId OR RecordTypeId = :
                              CSPBeneficiaryRecordTypeId) AND Beneficiary_Status__c = : Constants.ACTIVE LIMIT 500
                         ];
        if(!lstBeneficiary.isEmpty()) {
            lstBenImpactToLoop = [Select Id, BEN_Name__c,
                Disaster_Name__c from Beneficiary_Impact__c where
                BEN_Name__c in : lstBeneficiary AND Disaster_Name__c = : recID
            ];
        }
        Set<Id> setBeneficiaryIDs = new Set<Id>();
        if(!lstBenImpactToLoop.isEmpty()) {
            for(Beneficiary_Impact__c oBenImpact: lstBenImpactToLoop) {
                setBeneficiaryIDs.add(oBenImpact.BEN_Name__c);
            }
        }
        System.debug('setBeneficiaryIDs with Ben Impact records'+setBeneficiaryIDs);
        if(lstBeneficiary != NULL && lstBeneficiary.size()> 0) {
            lstBeneficiaryWrapper = new List<AccountWrapper>();
            for(Account oAccount: lstBeneficiary) {
                if(!setBeneficiaryIDs.isEmpty() && setBeneficiaryIDs.contains(oAccount.Id))
                    lstBeneficiaryWrapper.add(new AccountWrapper(oAccount, true));
                else
                    lstBeneficiaryWrapper.add(new AccountWrapper(oAccount, false));
            }
        }
        return null;
    }

    /**
     * Method name  : validateRecordsToInsert
     * Description  : This method is used to validate the input data before inserting in database
     * Return Type  : Boolean
     * Parameter    : AccountWrapper
     **/
    public void validateRecordsToInsert(AccountWrapper oAcntWrap) {
        bIsErrorFlag = false;
        if(oAcntWrap.oBenImpactRecValues.BEN_Location__c == NULL ||
            oAcntWrap.oBenImpactRecValues.BEN_Physical_Condition__c == NULL ||
            (!(oAcntWrap.oBenImpactRecValues.BEN_Location__c == Constants.UNKNOWN ||
            oAcntWrap.oBenImpactRecValues.BEN_Location__c == Constants.MISSING ||
            oAcntWrap.oBenImpactRecValues.BEN_Physical_Condition__c == Constants.BENEFICIARY_HEALTHY) &&
             oAcntWrap.oBenImpactRecValues.BEN_Phy_Condition_Description__c == NULL) ||
            oAcntWrap.oBenImpactRecValues.Number_Caregivers_Died__c == NULL ||
            oAcntWrap.oBenImpactRecValues.Number_Of_Caregivers_Seriously_Injured__c ==
            NULL ||
            oAcntWrap.oBenImpactRecValues.Number_Siblings_Died__c == NULL ||
            oAcntWrap.oBenImpactRecValues.Number_Of_Siblings_Seriously_Injured__c ==
            NULL ||
            oAcntWrap.oBenImpactRecValues.House_Condition__c == NULL ||
            oAcntWrap.oBenImpactRecValues.Lost_Personal_Effects__c == NULL) {
            setErrorBeneficiaries.add(oAcntWrap.oAccount.Name);
            oAcntWrap.bIsSelected = false;
            bIsErrorFlag = true;
        } else {
            setSuccessBeneficiaries.add(oAcntWrap.oAccount.Name);
            oAcntWrap.bAlreadyExists = true;
        }
    }

    /**
     * Method name  : save
     * Description  : This method creates new Beneficiary Impact records for selected Beneficiaries
     * Return Type  : pagereference
     * Parameter    : void
     **/
    public pagereference save() {
        List<Beneficiary_Impact__c> lstBenImpact = new List <
            Beneficiary_Impact__c>();
        for(AccountWrapper benWrap: lstBeneficiaryWrapper) {
            if(benWrap.bIsSelected && !benWrap.bAlreadyExists) {
                if(benWrap.oBenImpactRecValues.BEN_Location__c == Constants.UNKNOWN || 
                   benWrap.oBenImpactRecValues.BEN_Location__c == Constants.MISSING) 
                    benWrap.oBenImpactRecValues.BEN_Physical_Condition__c = Constants.UNKNOWN;
                System.debug('benWrap'+ benWrap);
                validateRecordsToInsert(benWrap);
                if(!bIsErrorFlag) {
                    lstBenImpact.add(new Beneficiary_Impact__c(BEN_Name__c = benWrap.oAccount
                        .ID,
                        Disaster_Name__c = recID, BEN_Location__c = benWrap.oBenImpactRecValues
                        .BEN_Location__c,
                        BEN_Physical_Condition__c = benWrap.oBenImpactRecValues.BEN_Physical_Condition__c,
                        BEN_Phy_Condition_Description__c = benWrap.oBenImpactRecValues.BEN_Phy_Condition_Description__c,
                        Number_Caregivers_Died__c = benWrap.oBenImpactRecValues.Number_Caregivers_Died__c,
                        Number_Of_Caregivers_Seriously_Injured__c = benWrap.oBenImpactRecValues
                        .Number_Of_Caregivers_Seriously_Injured__c,
                        Number_Siblings_Died__c = benWrap.oBenImpactRecValues.Number_Siblings_Died__c,
                        Number_Of_Siblings_Seriously_Injured__c = benWrap.oBenImpactRecValues.Number_Of_Siblings_Seriously_Injured__c,
                        House_Condition__c = benWrap.oBenImpactRecValues.House_Condition__c,
                        Lost_Personal_Effects__c = benWrap.oBenImpactRecValues.Lost_Personal_Effects__c,
                        Loss_Of_Livelihood__c = benWrap.oBenImpactRecValues.Loss_Of_Livelihood__c
                    ));
                    benWrap.bIsSelected = true;
                }
            }
        }
        if(lstBenImpact != NULL && lstBenImpact.size()> 0) {
            List<Database.SaveResult> lstInsertResults =
                Database.insert(lstBenImpact, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstInsertResults, lstBenImpact, 'Beneficiary_Impact__c',
                'MassUpdateRecordsBenImpactExtension', 'save', 'SFDC CI', false);
        }
        if(!setSuccessBeneficiaries.isEmpty() && !setErrorBeneficiaries.isEmpty()) {
            ApexPages.Message oMsgSuccess = new ApexPages.Message(ApexPages.Severity.info,
                System.Label.Disaster_Ben_Impact_Success_Message +
                setSuccessBeneficiaries);
            ApexPages.addMessage(oMsgSuccess);
            setSuccessBeneficiaries.clear();
            ApexPages.Message oMsgError = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.Disaster_Ben_Impact_Error_Message + setErrorBeneficiaries);
            ApexPages.addMessage(oMsgError);
            setErrorBeneficiaries.clear();
            return null;
        } else if(!setErrorBeneficiaries.isEmpty()) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.Disaster_Ben_Impact_Error_Message + setErrorBeneficiaries);
            ApexPages.addMessage(oMsg);
            setErrorBeneficiaries.clear();
            return null;
        } else {
            if(!setSuccessBeneficiaries.isEmpty()) {
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.info,
                    System.Label.Disaster_Ben_Impact_Success_Message +
                    setSuccessBeneficiaries);
                ApexPages.addMessage(oMsg);
            }
            PageReference pg = new PageReference(Constants.BACKSLASH + recID);
            return pg;
        }
    }

    /**
     * Method name  : defaultFields
     * Description  : This method defaults fields on Benefciary Impact record.
     * Return Type  : void
     * Parameter    : void
     **/

    public void defaultFields() {
        for(AccountWrapper benWrap: lstBeneficiaryWrapper) {
            benWrap.setValue();
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
        public Boolean bReadOnly {
            get;
            set;
        }
        Public Beneficiary_Impact__c oBenImpactRecValues {
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
            this.bReadOnly = false;
            oBenImpactRecValues = new Beneficiary_Impact__c();
            oBenImpactRecValues.Number_Caregivers_Died__c = 0;
            oBenImpactRecValues.Number_Of_Caregivers_Seriously_Injured__c = 0;
            oBenImpactRecValues.Number_Siblings_Died__c = 0;
            oBenImpactRecValues.Number_Of_Siblings_Seriously_Injured__c = 0;
        }
        Public void setValue() {
            if(this.oBenImpactRecValues.BEN_Location__c == Constants.UNKNOWN ||
               this.oBenImpactRecValues.BEN_Location__c == Constants.MISSING) {
                this.oBenImpactRecValues.BEN_Physical_Condition__c = Constants.UNKNOWN;
                this.bReadOnly = true;
            }
            else {
                this.oBenImpactRecValues.BEN_Physical_Condition__c = NULL;
                this.bReadOnly = false;
            }
        }
    }
}