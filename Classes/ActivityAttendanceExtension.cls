/************************************************************************
*Class Name         : ActivityAttendanceExtension
*Description        : This is VisualForce extension class for the Page ActivityAttendancePage, 
                      which helps user to specify activities and their attendance.
*Created By         : Himanshu Raichandani 
*Created On         : 03/07/2015
********************************************************************************/
public with sharing class ActivityAttendanceExtension {

    public String sICPId {
        get;
        set;
    }
    public List<BeneficiaryWrapper> lstBenefWrapForPopup {
        get;
        set;
    }
    public Map<Id, BeneficiaryWrapper> mapBenefIdToBenefWrapper {
        get;
        set;
    }
    public Boolean bDisplayPopup {
        get;
        set;
    }
    public Boolean bCheckAllForPopup {
        get;
        set;
    }
    public FilterListHandler oFilterListHandler {
        get;
        set;
    }
    public Activity_Attendance__c oActivityAttendance {
        get;
        set;
    }
    public Boolean bShowBottom {
        get;
        set;
    }
    public Boolean bCreateFlow {
        get;
        set;
    }
    public Boolean bUpdateFlow {
        get;
        set;
    }
    public Boolean bCheckAllAttendance {
        get;
        set;
    }
    public Integer iTotalScheduledHours {
        get;
        set;
    }
    public Integer iTotalAttendedHours {
        get;
        set;
    }
    public List<String> lstForTable {
        get;
        set;
    }
    public String sEmptyString {
        get;
        set;
    }
    public String bLoginFromPartnerPortal {
        get;
        set;
    }

    private List<Account> lstQueriedBeneficiaries {
        get;
        set;
    }
    public Boolean bHideComponents {
        get;
        set;
    }
    private Id existingRecId = null;
    private List<Beneficiary_Activity_Association__c> lstQueriedBenefAssoc =
        new List<Beneficiary_Activity_Association__c>();
    private Map<Id, Id> mapQueriedBenefIdToAssocId = new Map<Id, Id>();

    /**
     * Method name  : ActivityAttendanceExtension
     * Description  : ActivityAttendanceExtension Constructor
     * Return Type  : NA
     * Parameter    : ApexPages.StandardController
     **/
    public ActivityAttendanceExtension(ApexPages.StandardController controllerParam) {
        oFilterListHandler = new FilterListHandler();
        bHideComponents= true;
        bCheckAllAttendance = false;
        mapBenefIdToBenefWrapper = new Map<Id, BeneficiaryWrapper>();
        oFilterListHandler.sObjectName = Constants.ACCOUNT_API_NAME;
        sEmptyString = '';
        oFilterListHandler.mapValueType = new Map<String, String>();
        bDisplayPopup = false;
        existingRecId = controllerParam.getId();
        lstForTable = new List<String> {
            ''
        };
        Schema.DescribeSObjectResult oSObject = Schema.sObjectType.Activity_Attendance__c;
        if(!oSObject.isUpdateable()){
            bHideComponents = false;
        }
        bLoginFromPartnerPortal = (UserInfo.getUserType()
            .equals(Label.PowerPartner)) ? Constants.TRUE_LOWER_CASE : Constants.FALSE_LOWER_CASE;
        if(null<> existingRecId) {
            instantiateAttendances();
            bCreateFlow = false;
            bUpdateFlow = true;
            bShowBottom = true;
        } else {
            oActivityAttendance = new Activity_Attendance__c();
            if(Boolean.valueOf(bLoginFromPartnerPortal)) {
                oActivityAttendance.ICP__c = [Select AccountId from User where Id = :
                    UserInfo.getUserId()].AccountId;
            }
            bCreateFlow = true;
            bUpdateFlow = false;
            bShowBottom = false;
        }
        setSearchParameters();
    }

    /**
     * Method name  : instantiateAttendances
     * Description  : This method fetches all existing attendance saved.
     * Return Type  : void
     * Parameter    : void
     **/
    private void instantiateAttendances() {
        mapBenefIdToBenefWrapper.clear();
        mapQueriedBenefIdToAssocId.clear();
        oActivityAttendance = [Select Name, Activity_Date__c, BEN_Program_Type__c,
            Activity_Type__c, Activity_Description__c, ICP__c, ICP__r.ICP_Id__c,
            Tutor__c from Activity_Attendance__c where Id = : existingRecId
        ][0];

        lstQueriedBenefAssoc = [Select Activity__c, BEN_Attended__c,
            Primary_Caregiver__c, BEN_Id__c, BEN_Name__c, BEN_Local_Id__c from Beneficiary_Activity_Association__c 
            where Activity__c = :oActivityAttendance.Id
        ];

        for(Beneficiary_Activity_Association__c oBenefAssoc: lstQueriedBenefAssoc) {
            mapBenefIdToBenefWrapper.put(oBenefAssoc.BEN_Id__c, new BeneficiaryWrapper(
                oBenefAssoc.BEN_Id__c, oBenefAssoc.BEN_Local_Id__c, oBenefAssoc.BEN_Name__c,
                true, oBenefAssoc.BEN_Attended__c, oBenefAssoc.Primary_Caregiver__c));
            mapQueriedBenefIdToAssocId.put(oBenefAssoc.BEN_Id__c, oBenefAssoc.Id);
        }
        calculateHours();
    }

    /**
     * Method name  : selectBeneficiaries
     * Description  : This method adds Beneficiaries to the main table from popup.
     * Return Type  : void
     * Parameter    : void
     **/
    public void selectBeneficiaries() {

        if(null<> lstBenefWrapForPopup) {
            for(BeneficiaryWrapper oBenWrap: lstBenefWrapForPopup) {
                if(oBenWrap.bSelected) {
                    if(!mapBenefIdToBenefWrapper.keySet()
                        .contains(oBenWrap.sBeneficiaryId)) {
                        mapBenefIdToBenefWrapper.put(oBenWrap.sBeneficiaryId, oBenWrap);
                    }
                } else {
                    if(mapBenefIdToBenefWrapper.keySet()
                        .contains(oBenWrap.sBeneficiaryId)) {
                        mapBenefIdToBenefWrapper.remove(oBenWrap.sBeneficiaryId);
                    }
                }
            }
        }
        bDisplayPopup = false;
        bCheckAllForPopup = false;
    }

    /**
     * Method name  : saveBeneficiaryAttendance
     * Description  : This method saves Beneficiary activity attendance.
     * Return Type  : void
     * Parameter    : void
     **/
    public void saveBeneficiaryAttendance() {

        List<Beneficiary_Activity_Association__c> lstAssocToUpsert = new List <
            Beneficiary_Activity_Association__c>();
        List<Id> lstAssocToDelete = new List<Id>();
        Beneficiary_Activity_Association__c oBenefAssoc = null;
        for(BeneficiaryWrapper oBenWrap: mapBenefIdToBenefWrapper.values()) {
            if(mapQueriedBenefIdToAssocId.keySet()
                .contains(oBenWrap.sBeneficiaryId)) {
                oBenefAssoc = new Beneficiary_Activity_Association__c(Id =
                    mapQueriedBenefIdToAssocId.get(oBenWrap.sBeneficiaryId),
                    BEN_Attended__c = oBenWrap.bAttended);
            } else {
                oBenefAssoc = new Beneficiary_Activity_Association__c(Activity__c =
                    oActivityAttendance.Id,
                    BEN_Attended__c = oBenWrap.bAttended, BEN_Id__c = oBenWrap.sBeneficiaryId
                );
            }
            lstAssocToUpsert.add(oBenefAssoc);
        }

        for(Id benefId: mapQueriedBenefIdToAssocId.keySet()) {
            if(!mapBenefIdToBenefWrapper.keySet()
                .contains(benefId)) {
                lstAssocToDelete.add(mapQueriedBenefIdToAssocId.get(benefId));
            }
        }

        System.debug(' lstAssocToUpsert ' + lstAssocToUpsert);
        if(!lstAssocToUpsert.isEmpty()) {
            List<Database.UpsertResult> lstUpdateResults = Database.upsert(
                lstAssocToUpsert, false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults, lstAssocToUpsert,
                    'Beneficiary_Activity_Association__c',
                    'ActivityAttendanceExtension', 'saveBeneficiaryAttendance', 'SFDC CI',
                    false);
            if(!mapIdToErrorMsg.isEmpty()) {
                System.debug('Exception message 1: '+mapIdToErrorMsg.values());
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_Activity_Attn_Update);
                Apexpages.addmessage(oMsg);
                return;
            }
        }

        System.debug(' lstAssocToDelete ' + lstAssocToDelete);
        if(!lstAssocToDelete.isEmpty()) {
            List<Database.DeleteResult> lstDeleteResults = Database.delete(
                lstAssocToDelete, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstDeleteResults, lstAssocToDelete,
                'Beneficiary_Activity_Association__c', 'ActivityAttendanceExtension',
                'saveBeneficiaryAttendance', 'SFDC CI');
            if(!mapIdToErrorMsg.isEmpty()) {
                System.debug('Exception message 2: '+mapIdToErrorMsg.values());
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_Activity_Attn_Update);
                Apexpages.addmessage(oMsg);
                return;
            }
        }

        try {
            update oActivityAttendance;
        } catch(Exception oEx) {
            System.debug('Exception message 3: '+oEx.getMessage());
            ErrorLogUtility.logGeneralError(oEx, 'ActivityAttendanceExtension',
                'saveBeneficiaryAttendance', 'SFDC CI');
            Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_Activity_Attn_Update);
            Apexpages.addmessage(oMsg);
        }
        instantiateAttendances();
    }

    /**
     * Method name  : showPopup
     * Description  : This method reset variables which makes popup page visible to Tutor.
     * Return Type  : void
     * Parameter    : void
     **/
    public void showPopup() {
        bDisplayPopup = true;
        search();
    }

    /**
     * Method name  : createActivityAttendance
     * Description  : This method is called when Activity is cerated for the first time.
     * Return Type  : PageReference
     * Parameter    : void
     **/
    public PageReference createActivityAttendance() {
        PageReference oPageRef = null;
        if(null == existingRecId) {
            try {
                insert oActivityAttendance;
            } catch(Exception oEx) {
                ErrorLogUtility.logGeneralError(oEx, 'ActivityAttendanceExtension',
                    'createActivityAttendance', 'SFDC CI');
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_Activity_Attn_Update);
                Apexpages.addmessage(oMsg);
                return null;
            }
            oPageRef = new PageReference(Constants.ACTIVITY_ATTN_PAGE_URL +
                oActivityAttendance.Id);
            oPageRef.setRedirect(true);
        }
        return oPageRef;
    }

    /**
     * Method name  : redirectToPrintPage
     * Description  : This method redirects User to Acrtivity Attendance Print form.
     * Return Type  : PageReference
     * Parameter    : void
     **/
    public PageReference redirectToPrintPage() {
        PageReference oPageRef = new PageReference(Constants.ACTIVITY_ATTN_PRINT_PAGE_URL +
            oActivityAttendance.Id);
        oPageRef.setRedirect(true);
        return oPageRef;
    }

    /*
     * Method name  : setSearchParameters
     * Description  : This method sets Picklist in the VF component used for filter criteria.
                      This lists out all the field used for filter criteria
     * Return Type  : void
     * Parameter    : void
     */
    private void setSearchParameters() {

        List<Custom_Search_Setting__c> lstSetting = [select Name, Object__c,
            Fields_to_Filter__c, Result_Column_Fields__c from Custom_Search_Setting__c where Name = :
            Constants.SEARCH_ACTIVITY
        ];

        Custom_Search_Setting__c oSearchSetting;
        List<String> lstFieldAPINames = new List<String>();
        List<String> lstFieldLabels = new List<String>();
        if(!lstSetting.isEmpty())
            oSearchSetting = lstSetting[0];

        if(String.isNotBlank(oSearchSetting.Fields_to_Filter__c))
            lstFieldAPINames = oSearchSetting.Fields_to_Filter__c.split(Constants.COMMA);

        for(String sField: lstFieldAPINames)
            oFilterListHandler.mapValueType.put(sField, Constants.QUOTE_NEED);

        if(String.isNotBlank(label.Search_Activity_Fields_To_Filter_Labels))
            lstFieldLabels = label.Search_Activity_Fields_To_Filter_Labels.split(
                Constants.COMMA);

        if(String.isNotBlank(oSearchSetting.Result_Column_Fields__c))
            oFilterListHandler.lstFields.add(new SelectOption(Constants.NONE,
                Label.Search_Ben_Controller_None));

        for(Integer i = 0; i<lstFieldAPINames.size(); i++) {
            oFilterListHandler.lstFields.add(new selectOption(lstFieldAPINames[i],
                lstFieldLabels[i]));
        }
    }

    /*
     * Method name  : search
     * Description  : this method is called from the search button on VF page, this generates dyamic SOQL
                      based on user provided filter criteria and populates result in pageblocktable. 
     * Return Type  : None
     * Parameter    : NA
     */
    public void search() {

        String sQuery = 'select RecordTypeId,Id,Primary_Caregiver__r.Name,Name,ICP__c,Tutor_Implementer_Name__r.Name,CDSP_Type__c,';
        sQuery+='Local_Beneficiary_Id__c,Cognitive_Age_Group__c,Active_Program__c,Gender__c,ICP__r.Name,FirstName,LastName from Account where';
        lstBenefWrapForPopup = new List<BeneficiaryWrapper>();

        if(oFilterListHandler.oCompControllerRef != null) {
            oFilterListHandler.oCompControllerRef.formQuery();
            sQuery += oFilterListHandler.oCompControllerRef.sQuery;
        }

        sQuery += ' Beneficiary_Status__c=\'' + label.Active + '\' AND ICP__c=\'' +
            oActivityAttendance.ICP__c + '\'';
        if(oActivityAttendance.BEN_Program_Type__c.equals(Label.Activity_Attn_Center_Based_Lbl)) {
            sQuery += ' AND Program_Stage__c = \'' + Label.Program_Stage_Center_Based + '\'';
        } else {
            sQuery += ' AND Program_Stage__c IN (\'' + Label.Program_Stage_Home_Based +
                '\',\'' + Label.CSP + '\')';
        }

        system.debug('=======sQuery=======' + sQuery);
        try {
            lstQueriedBeneficiaries = Database.query(sQuery);
        } catch(QueryException oQEx) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.Account_Search);
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oQEx, 'ActivityAttendanceExtension',
                'search',
                'SFDC CI');
            return;
        }

        Set<Id> setSelectedIds = mapBenefIdToBenefWrapper.keySet();
        for(Account oBenef: lstQueriedBeneficiaries) {
            BeneficiaryWrapper oBenWrap = new BeneficiaryWrapper();

            oBenWrap.sCognitiveAgeGroup = oBenef.Cognitive_Age_Group__c;
            oBenWrap.sBeneficiaryName = oBenef.Name;
            oBenWrap.sGender = oBenef.Gender__c;
            oBenWrap.sActiveProgram = oBenef.Active_Program__c;
            oBenWrap.bSelected = (setSelectedIds.contains(oBenef.Id)) ? true : false;
            oBenWrap.sBeneficiaryId = oBenef.Id;
            oBenWrap.sLocalBeneficiaryId = oBenef.Local_Beneficiary_Id__c;
            oBenWrap.sTutorImplementerName = oBenef.Tutor_Implementer_Name__r.Name;
            oBenWrap.sPrimaryCaregiverName = oBenef.Primary_Caregiver__r.Name;
            oBenWrap.sProgramType = oBenef.CDSP_Type__c;
            lstBenefWrapForPopup.add(oBenWrap);
        }

        System.debug(lstBenefWrapForPopup);
        lstBenefWrapForPopup.sort();
    }

    /**
     * Class name   : BeneficiaryWrapper
     * Description  : Inner class to use as a data structure for holding Beneficiary Information
     **/
    public class BeneficiaryWrapper implements Comparable {
        public String sBeneficiaryId {
            get;
            set;
        }
        public String sLocalBeneficiaryId {
            get;
            set;
        }
        public String sBeneficiaryName {
            get;
            set;
        }
        public String sCognitiveAgeGroup {
            get;
            set;
        }
        public String sGender {
            get;
            set;
        }
        public String sActiveProgram {
            get;
            set;
        }
        public Boolean bSelected {
            get;
            set;
        }
        public Boolean bAttended {
            get;
            set;
        }
        public String sTutorImplementerName {
            get;
            set;
        }
        public String sPrimaryCaregiverName {
            get;
            set;
        }
        public String sProgramType {
            get;
            set;
        }

        /**
         * Method name  : BeneficiaryWrapper Constructor with arguments
         * Return Type  : NA
         * Parameter    : String,String,String,Boolean,Boolean,String
         **/
        public BeneficiaryWrapper(String sBeneficiaryIdArg, String sLocalBeneficiaryIdArg,
            String sBeneficiaryNameArg,
            Boolean bSelectedArg, Boolean bAttendedArg, String sPrimaryCaregiverNameArg
        ) {
            sBeneficiaryId = sBeneficiaryIdArg;
            sLocalBeneficiaryId = sLocalBeneficiaryIdArg;
            sBeneficiaryName = sBeneficiaryNameArg;
            bSelected = bSelectedArg;
            bAttended = bAttendedArg;
            sPrimaryCaregiverName = sPrimaryCaregiverNameArg;
        }

        /*
         * Method name  : compareTo
         * Description  : This method is called whenever sort method is called on List containing objects 
                          of this wrapper class. 
         * Return Type  : Integer
         * Parameter    : Object
         */
        public Integer compareTo(Object oBenefWrap) {
                BeneficiaryWrapper oOrigBenefWrap = (BeneficiaryWrapper) oBenefWrap;
                if(sBeneficiaryName == oOrigBenefWrap.sBeneficiaryName) return 0;
                if(sBeneficiaryName> oOrigBenefWrap.sBeneficiaryName) return 1;
                return -1;
            }
            /**
             * Method name  : BeneficiaryWrapper no-arg Constructor
             * Return Type  : NA
             * Parameter    : void
             **/
        public BeneficiaryWrapper() {}
    }

    /*
     * Method name  : closePopupPage
     * Description  : This method resets variable so that popup is made invisible.
     * Return Type  : void
     * Parameter    : void
     */
    public void closePopupPage() {
        bDisplayPopup = false;
        bCheckAllForPopup = false;
    }

    /*
     * Method name  : checkAllAttendance
     * Description  : This method marks attendance of all Beneficiaries selected for this activity.
     * Return Type  : void
     * Parameter    : void
     */
    public void checkAllAttendance() {
        System.debug('bCheckAllAttendance ' + bCheckAllAttendance);
        for(BeneficiaryWrapper oBenWrap: mapBenefIdToBenefWrapper.values()) {
            oBenWrap.bAttended = bCheckAllAttendance;
        }
    }

    /*
     * Method name  : calculateHours
     * Description  : This method calculates number of present and absent Beneficiaries in this Activity.
     * Return Type  : void
     * Parameter    : void
     */
    public void calculateHours() {
        iTotalScheduledHours = mapBenefIdToBenefWrapper.values()
            .size();
        iTotalAttendedHours = 0;
        for(BeneficiaryWrapper oBenWrap: mapBenefIdToBenefWrapper.values()) {
            if(oBenWrap.bAttended) {
                iTotalAttendedHours++;
            }
        }
    }

    /*
     * Method name  : backToListPage
     * Description  : This method redirects Tutor to Activity Tab.
     * Return Type  : PageReference
     * Parameter    : void
     */
    public PageReference backToListPage() {
        String sActivityPrefix = Activity_Attendance__c.sObjectType.getDescribe()
            .getKeyPrefix();
        return new PageReference('/' + sActivityPrefix);
    }
}