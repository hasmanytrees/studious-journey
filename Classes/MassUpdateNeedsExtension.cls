/************************************************************************************************** 
Class Name   : MassUpdateNeedsController
Created By   : Vishal Katyare
Created Date : 10/30/2014
Description  : This controller is written for VF page MassUpdateNeeds,
         where particular Account is updated by adding multiple needs under it.
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public with sharing class MassUpdateNeedsExtension {

        public String sSuccessMessage {
                get;
                set;
        }
        public String sShowMessage {
                get;
                set;
        }
        public String sAccId {
                get;
                set;
        }
        public String sAccName {
                get;
                set;
        }
        public String sAccType {
                get;
                set;
        }
        public String sRecTypeId {
                get;
                set;
        }
        public List < NeedsWrapper > lstCiv {
                get;
                set;
        }
        public Set < String > selCIVNames {
                get;
                set;
        }
        public Boolean sHasSelected {
                get;
                set;
        }
        public Map < String, NeedsWrapper > mapNeedValue {
                get;
                set;
        }
        public Map < String, Needs_Association__c > mapCivAssociation {
                get;
                set;
        }
        public String sRecId {
                get;
                set;
        }
        public String sFieldOffice {
                get;
                set;
        }
        public String sUserType {
                get;
                set;
        }
        private String sFieldOfficeId;

        /**
         * Method name  : MassUpdateNeedsExtension
         * Description  : This is a constructor used for Setting variables from Url parameters.
         * Return Type  : NA
         * Parameter    : ApexPages.StandardController
         **/
        public MassUpdateNeedsExtension(ApexPages.StandardController oController) {
                sSuccessMessage = Label.Needs_updated_Successfully;
                sShowMessage = Constants.FALSE_LOWER_CASE;
                sUserType = UserInfo.getUserType();
                //Setting variables from Url parameters
                sAccId = ApexPages.currentPage()
                        .getParameters().get(Constants.ACC_ID);
                Account oAcc = null;
                try {
                        oAcc = [select Name, RecordTypeId, ICP__r.Cluster__r.Territory__r.Field_Office__r.Id
                                from account where Id = : sAccId
                        ];
                } catch(QueryException oQEx) {
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                                oQEx.getMessage());
                        ApexPages.addMessage(oMsg);
                        return;
                }
                sAccType = oAcc.RecordTypeId;
                sAccName = oAcc.Name;
                sFieldOfficeId = oAcc.ICP__r.Cluster__r.Territory__r.Field_Office__r.Id;
                mapNeedValue = new Map < String, NeedsWrapper > ();
                gatherRelatedData();
        }

        /**
        * Method name  : gatherRelatedData
        * Description  : This method will be invoked from controller to gather intial data list and interate them to define
                 a list of wrapper objects.
        * Return Type  : void
        * Parameter    : NA
        **/
        public void gatherRelatedData() {
                lstCiv = new List < NeedsWrapper > ();
                selCIVNames = new Set < String > ();
                mapCivAssociation = new Map < String, Needs_Association__c > ();
                String sNeedType = null;
                Id needDataRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                        Global_Data__c.SObjectType, Constants.GLOBAL_DATA_NEEDS_DATA_RT_API_NAME);
                Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                        Constants.ICP_RT_API_NAME);
                if(sAccType == icpRecTypeId)
                        sNeedType = Constants.ICP_NEED;
                else
                        sNeedType = Constants.BENEFICIARY_NEED;
                Integer iTemp = 0;
                //Fetching all Needs association present under beneficiary or ICP
                List < Needs_Association__c > lstNeedAssocToLoop = null;
                List < Global_Data__c > lstGlobalData = null;
                try {
                        lstNeedAssocToLoop = [SELECT Id, Name, Comments__c, Account__r.Id,
                                Account__c, Need__c, Severity__c, Need__r.Name
                                FROM Needs_Association__c where Account__c = : sAccId OR ICP__c = :
                                sAccId
                        ];

                        lstGlobalData = [SELECT Id, Name, Need_Type__c, Need_Category__c
                                FROM Global_Data__c
                                where recordTypeId = : needDataRecTypeId AND(Need_Type__c = : sNeedType OR Need_Type__c = :
                                        Constants.BOTH) order by Name
                        ];
                } catch(QueryException oQEx) {
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                                oQEx.getMessage());
                        ApexPages.addMessage(oMsg);
                        ErrorLogUtility.logGeneralError(oQEx, 'MassUpdateNeedsExtension',
                                'gatherRelatedData', 'SFDC CI');
                        return;
                }
                for(Needs_Association__c oNeedAssociation: lstNeedAssocToLoop) {
                        selCIVNames.add(oNeedAssociation.Need__r.Name);
                        mapCivAssociation.put(oNeedAssociation.Need__r.Name, oNeedAssociation);
                }

                /*Getting list of all needs, checking if association record aready exists or not
                  and accordingly creating wrapper class list*/
                for(Global_Data__c oGlobalData: lstGlobalData)

                {
                        NeedsWrapper oTempNeedsWrapper = new NeedsWrapper(oGlobalData);
                        if(selCIVNames.contains(oGlobalData.Name)) {
                                oTempNeedsWrapper.bIsSelected = true;
                                oTempNeedsWrapper.bAlreadyExists = true;
                                oTempNeedsWrapper.oNeedAssociation = mapCivAssociation.get(oGlobalData.Name);
                                oTempNeedsWrapper.sOldPriority = oTempNeedsWrapper.oNeedAssociation.Severity__c;
                                oTempNeedsWrapper.sOldComments = mapCivAssociation.get(oGlobalData.Name)
                                        .comments__c;
                        } else {
                                oTempNeedsWrapper.bIsSelected = false;
                                oTempNeedsWrapper.bAlreadyExists = false;
                        }
                        lstCiv.add(oTempNeedsWrapper);
                        mapNeedValue.put(String.valueOf(iTemp), oTempNeedsWrapper);
                        iTemp++;
                }
                if(lstCiv.size() < 1) {
                        ApexPages.Message oMsgNoRecords = new ApexPages.Message(ApexPages.severity.Info,
                                System.label.No_records_found_for_Needs);
                        ApexPages.addMessage(oMsgNoRecords);
                }
        }

        /**
        * Method name  : updateList
        * Description  : This method is to update Association list under beneficiaries.
                 It will be invoked on the click of a button named as Update List.
                 It will add CIV Needs Association for newly selected Needs as well as delete association for unchecked beneficiaries.
        * Return Type  : Page Reference
        * Parameter    : NA
        **/
        public void updateList() {
                List < Needs_Association__c > lstToBeAdded = new List < Needs_Association__c >
                        ();
                List < Id > lstToBeDeleted = new List < Id > ();

                Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                        Constants.CDSP_BENEFICIARY_RT_API_NAME);
                Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                        Constants.CSP_BENEFICIARY_RT_API_NAME);
                for(NeedsWrapper oCiv: lstCiv) {
                        //Civ Association to be inserted when previously unchecked need is checked
                        if(oCiv.bIsSelected == True && !oCiv.bAlreadyExists) {
                                Needs_Association__c oNewCIV = oCiv.oNeedAssociation;
                                oNewCIV.Severity__c = oCiv.oNeedAssociation.Severity__c;
                                if(sAccId != Constants.EMPTY_STRING && (sAccType.equals(cspRecTypeId) ||
                                                sAccType.equals(cdspRecTypeId))) {
                                        oNewCIV.Account__c = sAccId;
                                        oNewCIV.Association_Type__c = Constants.BENEFICIARY_ASSOCIATION;
                                } else {
                                        oNewCIV.Account__c = sAccId;
                                        oNewCIV.Association_Type__c = Constants.ICP_ASSOCIATION;
                                }
                                if(oCiv.sOldComments != oCiv.oNeedAssociation.comments__c) {
                                        oNewCIV.Comments__c = oCiv.oNeedAssociation.comments__c;
                                        oCiv.sOldComments = oCiv.oNeedAssociation.comments__c;
                                }
                                lstToBeAdded.add(oNewCIV);
                        }
                        //Civ Association to be deleted when previously selected need is unchecked
                        else
                        if(oCiv.bIsSelected == false && oCiv.bAlreadyExists) {
                                lstToBeDeleted.add(oCiv.oNeedAssociation.Id);
                        }
                        //Existing needs whoes priority is changed only.
                        else
                        if(oCiv.bIsSelected && oCiv.bAlreadyExists && oCiv.sOldPriority != oCiv.oNeedAssociation
                                .Severity__c) {
                                if(oCiv.sOldComments != oCiv.oNeedAssociation.comments__c) {
                                        oCiv.sOldComments = oCiv.oNeedAssociation.comments__c;
                                }
                                lstToBeAdded.add(oCiv.oNeedAssociation);
                        } else
                        if(oCiv.bIsSelected == True && oCiv.bAlreadyExists) {
                                if(oCiv.sOldComments != oCiv.oNeedAssociation.comments__c) {
                                        oCiv.sOldComments = oCiv.oNeedAssociation.comments__c;
                                        lstToBeAdded.add(oCiv.oNeedAssociation);
                                }
                        }
                }

                if(lstToBeAdded.size() > 0) {
                        List < Database.UpsertResult > lstUpdateResults = Database.upsert(
                                lstToBeAdded, false);
                        Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                                lstUpdateResults, lstToBeAdded,
                                'Needs_Association__c', 'MassUpdateNeedsExtension', 'updateList',
                                'SFDC CI', false);
                        if(!mapIdToErrorMsg.isEmpty()) {
                                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                                        Label.Error_in_saving_need);
                                Apexpages.addmessage(oMsg);
                                return;
                        }
                }
                if(lstToBeDeleted.size() > 0) {
                        List < Database.DeleteResult > lstUpdateResults = Database.delete(
                                lstToBeDeleted, false);
                        Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                                lstUpdateResults, lstToBeDeleted,
                                'Needs_Association__c', 'MassUpdateNeedsExtension', 'updateList',
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
         * Method name  : Cancel
         * Description  : This is a method for cancel button which redirects a webpage to the beneficiary record.
         * Return Type  : Page Reference
         * Parameter    : NA
         **/
        public pageReference cancel() {
                PageReference reference = new PageReference(Constants.BACKSLASH + sAccId);
                reference.setRedirect(true);
                return reference;
        }

        /**
         * Class name   : NeedsWrapper
         * Description  : This is an Inner wrapper class.
         **/
        public class NeedsWrapper {
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
                public string sNeedName {
                        get;
                        set;
                }
                public string sNeedCategory {
                        get;
                        set;
                }
                public NeedsWrapper(Global_Data__c oGlobalData) {
                        oNeedAssociation = new Needs_Association__c();
                        oNeedAssociation.Need__c = oGlobalData.Id;
                        sNeedCategory = oGlobalData.Need_Category__c;
                        bAlreadyExists = false;
                        sOldComments = Constants.EMPTY_STRING;
                        sNeedName = oGlobalData.Name;
                }
        }
}