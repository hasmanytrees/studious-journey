/******************************************************************************************************
Class Name         : MassUpdateAccountsExtension
Description        : This controller is written for VF page MassUpdateAccounts,
                     where particular CIV need is updated on Multiple Accounts at once. 
Created By         : Himanshu Raichandani
Created On         : 30-Oct-2014
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public with sharing class MassUpdateAccountsExtension {

    public String sSuccessMessage {
        get;
        set;
    }
    public String sShowMessage {
        get;
        set;
    }
    public String sCivId {
        get;
        set;
    }
    public String sAccType {
        get;
        set;
    }
    public String sCivName {
        get;
        set;
    }
    public Needs_Association__c oTempAssociation {
        get;
        set;
    }
    public List < AccountWrapper > lstAccount {
        get;
        set;
    }
    public Set < String > setSelAccIds {
        get;
        set;
    }
    public Map < String, AccountWrapper > mapNeedValue {
        get;
        set;
    }
    public String sRecId {
        get;
        set;
    }
    public Map < String, Needs_Association__c > mapAccCIVAssociation {
        get;
        set;
    }
    public String sAccountMessage {
        get;
        set;
    }

    /**
     * Method name  : MassUpdateAccountsExtension
     * Description  : This is a constructor for the class MassUpdateAccountsController that initialises all the variables
     * Return Type  : N/A
     * Parameter    : ApexPages.StandardController 
     **/
    public MassUpdateAccountsExtension(ApexPages.StandardController oController) {
        sSuccessMessage = Label.Needs_updated_Successfully;
        sShowMessage = Constants.FALSE_LOWER_CASE;
        //Reading url parameter values to set variables
        sCivId = ApexPages.currentPage()
            .getParameters()
            .get(Constants.CIV_ID);
        sAccType = ApexPages.currentPage()
            .getParameters()
            .get(Constants.ACC_TYPE);
        sCivName = ApexPages.currentPage()
            .getParameters()
            .get(Constants.CIV_NAME);
        sAccountMessage = System.Label.Mass_Update_Account_Msg + sCivName + 
            System.Label.Mass_Update_Account_Msg2;
        oTempAssociation = (Needs_Association__c) oController.getRecord();
        lstAccount = new List < AccountWrapper > ();
        mapNeedValue = new Map < String, AccountWrapper > ();
        gatherRelatedData();
    }

    /**
    * Method name  : updateList
    * Description  : Method for updating Association list under beneficiaries.This method will be invoked on button click named Update List.
                     This will add CIV Needs Association for newly selected beneficiaries as well as delete association for unchecked beneficiaries.
    * Return Type  : pageReference
    * Parameter    : void
    **/
    public void updateList() {
        List < Needs_Association__c > lstToBeAdded = new List < Needs_Association__c >
            ();
        List < Id > lstToBeDeleted = new List < Id > ();
        for(AccountWrapper oAccount: lstAccount) {
            //for newly selected beneficiaries
            if(oAccount.bIsSelected && !(oAccount.bAlreadyExists)) {
                
                Needs_Association__c oNewCIV = oAccount.oNeedAssociation;

                oNewCIV.Need__c = sCivId;
                oNewCIV.recordTypeId = Utility.getRecordTypeIdByDeveloperName(
                    Needs_Association__c.SObjectType, Constants.BENEFICIARY_ASSOCIATION_RT_API_NAME
                );
                oNewCIV.Severity__c = oAccount.oNeedAssociation.Severity__c;
                oNewCIV.Comments__c = oAccount.oNeedAssociation.comments__c;
                lstToBeAdded.add(oNewCIV);
            }
            //existing beneficiaries which are unchecked
            else
            if(!(oAccount.bIsSelected) && oAccount.bAlreadyExists) {
                lstToBeDeleted.add(oAccount.oNeedAssociation.Id);
            }
            //Existing beneficiaries whoes priority is changed only.
            else
            if(oAccount.bIsSelected && oAccount.bAlreadyExists && oAccount.sOldPriority !=
                oAccount.oNeedAssociation.Severity__c)
                lstToBeAdded.add(oAccount.oNeedAssociation);

            else
            if(oAccount.sOldComments != oAccount.oNeedAssociation.comments__c) {
                lstToBeAdded.add(oAccount.oNeedAssociation);
                oAccount.sOldComments = oAccount.oNeedAssociation.comments__c;
            }
        }

        if(lstToBeAdded.size() > 0) {
            List < Database.UpsertResult > lstUpdateResults =
                Database.upsert(lstToBeAdded, false);
            Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstToBeAdded,
                'Needs_Association__c', 'MassUpdateAccountsExtension', 'updateList',
                'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_in_saving_need);
                Apexpages.addmessage(oMsg);
                return;
            }
        }
        if(lstToBeDeleted.size() > 0) {
            List < Database.DeleteResult > lstUpdateResults =
                Database.delete(lstToBeDeleted, false);
            Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstToBeDeleted,
                'Needs_Association__c', 'MassUpdateAccountsExtension', 'updateList',
                'SFDC CI');
            if(!mapIdToErrorMsg.isEmpty()) {
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_in_saving_need);
                Apexpages.addmessage(oMsg);
                return;
            }
        }
        sShowMessage = Constants.TRUE_LOWER_CASE;
    }

    /**
     * Method name  : gatherRelatedData
     * Description  : This method will be invoked from controller to gather intiial data list and interate them to define list of wrapper object.
     * Return Type  : void
     * Parameter    : void
     **/
    public void gatherRelatedData() {

        Set < Id > setAccRecTypeIds = new Set < Id > ();
        //Depending on related list, account record types are considered (Beneficiary or ICP)
        if(sAccType == Constants.BEN_TOKEN) {
            setAccRecTypeIds.add(Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.CSP_BENEFICIARY_RT_API_NAME));
            setAccRecTypeIds.add(Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.CDSP_BENEFICIARY_RT_API_NAME));
        } else if(sAccType == Constants.ICP_TOKEN) {
            setAccRecTypeIds.add(Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.ICP_RT_API_NAME));
        }
        lstAccount = new List < AccountWrapper > ();
        setSelAccIds = new Set < String > ();
        mapAccCIVAssociation = new Map < String, Needs_Association__c > ();
        List < Needs_Association__c > lstNeedAssoc = null;
        try {
            lstNeedAssoc = [SELECT Id, Name, Need__r.Name,
                Comments__c, Account__r.Id, ICP__r.Id, Severity__c
                FROM Needs_Association__c where Need__c = : sCivId
            ];
        } catch(QueryException oEx) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                oEx.getMessage());
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oEx, 'MassUpdateAccountsExtension',
                'gatherRelatedData', 'SFDC CI');
            return;
        }
        for(Needs_Association__c oNeedAssoc: lstNeedAssoc) {
            if(sAccType == Constants.BEN_TOKEN) {
                setSelAccIds.add(oNeedAssoc.Account__r.Id);
                mapAccCIVAssociation.put(oNeedAssoc.Account__r.Id, oNeedAssoc);
            }
        }
        //Populating all accounts with checkbox based on required record type
        List < Account > lstAllAccount = new List < Account > ();
        try {
            if(oTempAssociation.ICP__c != null) {
                lstAllAccount = [SELECT Id, Name, Type, recordTypeId, isPersonAccount
                    FROM Account where RecordTypeId IN: setAccRecTypeIds AND ICP__c = :
                    oTempAssociation.ICP__c order by name limit 1000
                ];
            } else {
                lstAllAccount = [SELECT Id, Name, Type, recordTypeId, isPersonAccount
                    FROM Account where RecordTypeId IN: setAccRecTypeIds order by name limit 1000
                ];
            }
        } catch(QueryException oEx) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                oEx.getMessage());
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oEx, 'MassUpdateAccountsExtension',
                'gatherRelatedData', 'SFDC CI');
            return;
        }
        Integer iCount = 0;
        for(Account oAccount: lstAllAccount) {
            AccountWrapper oTempAccWrapper = new AccountWrapper(oAccount);
            if(setSelAccIds.contains(oAccount.Id)) {
                oTempAccWrapper.bIsSelected = true;
                oTempAccWrapper.bAlreadyExists = true;
                oTempAccWrapper.oNeedAssociation = mapAccCIVAssociation.get(oAccount.Id);
                oTempAccWrapper.sOldPriority = oTempAccWrapper.oNeedAssociation.Severity__c;
            } else {
                oTempAccWrapper.bIsSelected = false;
                oTempAccWrapper.bAlreadyExists = false;
            }
            lstAccount.add(oTempAccWrapper);
            mapNeedValue.put(String.valueOf(iCount), oTempAccWrapper);
            iCount++;

        }
        if(lstAccount.size() < 1) {
            ApexPages.Message oMyMsg = new ApexPages.Message(ApexPages.severity.Info,
                System.Label.No_Beneficiary_Found_Message);
            ApexPages.addMessage(oMyMsg);
        }
    }

    /**
     * Method name  : Cancel
     * Description  : This method is invoked from cancel button on VF Page which simply redirects to the Need record.   
     * Return Type  : pageReference
     * Parameter    : void
     **/
    public pageReference Cancel() {
        PageReference oReference = new PageReference(Constants.BACKSLASH + sCivId);
        oReference.setRedirect(true);
        return oReference;
    }

    /**
     * Class name   : AccountWrapper
     * Description  : Inner wrapper class whose list is used for displaying pageblocktables along with checkboxes. 
     **/
    public class AccountWrapper {
        public Boolean bIsSelected {
            get;
            set;
        }
        public Needs_Association__c oNeedAssociation {
            get;
            set;
        }
        public Boolean bAlreadyExists {
            get;
            set;
        }
        public String sOldPriority {
            get;
            set;
        }
        public string sOldComments {
            get;
            set;
        }

        public AccountWrapper(Account oAccount) {
            oNeedAssociation = new Needs_Association__c();
            oNeedAssociation.Account__c = oAccount.Id;
            bAlreadyExists = false;
            sOldComments = Constants.EMPTY_STRING;
        }
    }
}