/************************************************************************
 *Class Name         : YearlyClassExtension
 *Description        : This class allows Tutor to add Beneficaries to its class for complete year 
 *Created By         : Himanshu Raichandani
 *Created On         : 23-June-2015 
 ********************************************************************************/
public with sharing class YearlyClassExtension {

    public Yearly_Class_Schedule__c oYearlySchedule {
        get;
        set;
    }
    public List<BeneficiaryDataWrapper> lstBeneficiaryWrapper {
        get;
        set;
    }
    public Map<String, Boolean> mapForFirstRow {
        get;
        set;
    }
    public Map<String, String> mapMonthEngToLocalLang {
        get;
        set;
    }
    public List<String> lstForTable {
        get;
        set;
    }
    public Boolean bDisplayPopUp {
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
    public List<String> lstForFirstRow {
        get;
        set;
    }
    public Boolean bShowComponents{
        get;
        set;
    }
    
    private List<Account> lstBeneficiaries = new List<Account>();
    private Set<Id> setExistingAssocIds = new Set<Id>();
    private Map<String, Integer> mapMonthNameToIndex = new Map<String,Integer>();
    private Map<Integer, String> mapIndexToMonthName = new Map<Integer,String>();
    private Map<Id, Id> mapBenefIdToAssocId = new Map<Id, Id>();
    private List<Monthly_Class_Schedule__c> lstMonthlyClass = new List <
        Monthly_Class_Schedule__c>();
    private Map<Id, Map<String,Id>> mapBenefIdToMapMonthToAssocId = new Map<Id,Map<String,Id>>();
    private Id existingRecId = null;


    /**
     * Method name  : YearlyClassExtension
     * Description  : YearlyClassExtension Constructor
     * Return Type  : NA
     * Parameter    : ApexPages.StandardController
     **/
    public YearlyClassExtension(ApexPages.StandardController controllerParam) {

        bDisplayPopUp = false;
        bShowComponents = true;
        lstForTable = new List<String> {
            Constants.EMPTY_STRING
        };
        Schema.DescribeSObjectResult oSObject = Schema.sObjectType.Yearly_Class_Schedule__c;
        if(!oSObject.isUpdateable()){
            bShowComponents = false;
        }
        existingRecId = controllerParam.getId();
        System.debug('existingRecId ' + existingRecId);

        if(null<> existingRecId) {
            oYearlySchedule = ([Select Id, BEN_Cognitive_Age_Group__c, Tutor__c,
                Year__c, Class_Type__c, Name, ICP_ID__c, Starting_Month__c,
                BEN_Program_Delivery__c, ICP_Name__c, Class_Description__c
                from Yearly_Class_Schedule__c where Id = : existingRecId
            ])[0];
            searchBeneficiary();
            bCreateFlow = false;
            bUpdateFlow = true;
        } else {
            oYearlySchedule = new Yearly_Class_Schedule__c();
            if(UserInfo.getUserType()
                .equals(Label.PowerPartner)) {
                oYearlySchedule.ICP_Name__c = [Select AccountId from User where Id = :
                    UserInfo.getUserId()
                ].AccountId;
            }
            bCreateFlow = true;
            bUpdateFlow = false;
        }
        instantiateMonthMap();
    }

    /*
     * Method name  : instantiateMonthMap
     * Description  : This method prepares a Map which keeps month name in English as key and Month name in 
     *                local language as value
     * Return Type  : void
     * Parameter    : void
     */
    private void instantiateMonthMap() {
        mapMonthEngToLocalLang = new Map<String,String>();
        List<String> lstHelperForFirstRow = new List<String> (Label.Yearly_Class_Month_Names
            .split(','));
        Integer i = 0;
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_Jan_Label);
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_Feb_Label);
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_Mar_Label);
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_Apr_Label);
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_May_Label);
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_Jun_Label);
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_Jul_Label);
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_Aug_Label);
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_Sep_Label);
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_Oct_Label);
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_Nov_Label);
        mapMonthEngToLocalLang.put(lstHelperForFirstRow[i++],Label.Class_Dec_Label);
    }

    /*
     * Method name  : searchBeneficiary
     * Description  : This method is called from the search button on VF page, this generates dyamic SOQL 
                      based on user provided filter criteria and populates result in pageblocktable. 
     * Return Type  : void
     * Parameter    : void
     */
    public void searchBeneficiary() {
        instantiateListForFirstRow();
        bDisplayPopup = true;
        String sYear = oYearlySchedule.Year__c;
        String sMonth = oYearlySchedule.Starting_Month__c;
        String sAgeGroup = oYearlySchedule.BEN_Cognitive_Age_Group__c;
        String sTutorId = oYearlySchedule.Tutor__c;
        String sName = oYearlySchedule.Name;
        String sProgramDelivery = oYearlySchedule.BEN_Program_Delivery__c;
        String sICPId = oYearlySchedule.ICP_Name__c;
        List<Yearly_Class_Schedule__c> lstYearlySchedule = null;


        lstYearlySchedule = [Select Id, BEN_Cognitive_Age_Group__c, Tutor__c,
            Year__c, Name, Class_Type__c, ICP_ID__c, Starting_Month__c,
            BEN_Program_Delivery__c, ICP_Name__c, Class_Description__c from Yearly_Class_Schedule__c where Year__c = :
            sYear and Tutor__c = : sTutorId and BEN_Cognitive_Age_Group__c = : sAgeGroup and Name = :sName
        ];

        if(lstYearlySchedule.size()> 0) {
            oYearlySchedule = lstYearlySchedule[0];
            Map<Id, Monthly_Class_Schedule__c> mapIdToMonthlyObj = new Map<Id,
                Monthly_Class_Schedule__c> ([Select Id,
                    Month__c, Yearly_Class__c from Monthly_Class_Schedule__c where Yearly_Class__c = :
                    oYearlySchedule.Id
                ]);

            lstMonthlyClass = mapIdToMonthlyObj.values();

            List<Beneficiary_Class_Association__c> lstBenefAssoc = [Select BEN_Id__c,
                Monthly_Class_Schedule__c, Month_Name__c from Beneficiary_Class_Association__c where
                Monthly_Class_Schedule__c in : mapIdToMonthlyObj.keySet()
            ];

            Map<String, Id> mapMonthNameToAssocId = null;
            for(Beneficiary_Class_Association__c oBenefAssoc: lstBenefAssoc) {

                if(mapBenefIdToMapMonthToAssocId.keySet()
                    .contains(oBenefAssoc.BEN_Id__c)) {
                    mapBenefIdToMapMonthToAssocId.get(oBenefAssoc.BEN_Id__c)
                        .put(oBenefAssoc.Month_Name__c, oBenefAssoc.Id);
                } else {
                    mapMonthNameToAssocId = new Map<String, Id>();
                    mapMonthNameToAssocId.put(oBenefAssoc.Month_Name__c, oBenefAssoc.Id);
                    mapBenefIdToMapMonthToAssocId.put(oBenefAssoc.BEN_Id__c,
                        mapMonthNameToAssocId);
                }
            }
            System.debug('mapBenefIdToMapMonthToAssocId ' +
                mapBenefIdToMapMonthToAssocId);
        }

        instantiateMonthlyClassList();

        String sQuery =
            'select RecordTypeId,Id,Name,FirstName,Local_Beneficiary_Number__c,LastName,Local_Beneficiary_ID__c from Account where';
        lstBeneficiaryWrapper = new list<BeneficiaryDataWrapper>();
        sQuery += ' Beneficiary_Status__c=\'' + label.Active + '\' AND ICP__c=\'' + sICPId +
            '\' AND Cognitive_Age_Group__c =\'' + sAgeGroup + '\'';
        if(sProgramDelivery.equals(Label.Center_Based_CDSP_Type)) {
            sQuery += ' AND Program_Stage__c = \'' + Label.Program_Stage_Center_Based +
                '\'';
        } else {
            sQuery += ' AND Program_Stage__c IN (\'' + Label.Program_Stage_Home_Based +
                '\',\'' + Label.CSP + '\')';
        }
        System.debug('sQuery ' + sQuery);

        try {
            lstBeneficiaries = Database.query(sQuery);
        } catch(QueryException oEx) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                oEx.getMessage());
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oEx, 'YearlyClassExtension',
                'searchBeneficiary', 'SFDC CI');
            return;
        }
        System.debug('lstBeneficiaries ' + lstBeneficiaries);
        for(Account oAcc: lstBeneficiaries) {
            BeneficiaryDataWrapper oBenWapVar = new BeneficiaryDataWrapper();
            oBenWapVar.sBeneficiaryName = oAcc.Name;
            oBenWapVar.sBeneficiaryId = oAcc.id;
            oBenWapVar.lstMonthWrapper = populateMonthCheckbox(oBenWapVar);
            oBenWapVar.sLocalBeneficiaryId = oAcc.Local_Beneficiary_ID__c;
       
            oBenWapVar.sLocalBeneficiaryNum = oAcc.Local_Beneficiary_Number__c;
            lstBeneficiaryWrapper.add(oBenWapVar);
        }
        lstBeneficiaryWrapper.sort();
        if(lstBeneficiaries.isEmpty()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info,
                Label.Yearly_Class_No_Benef_Error);
            ApexPages.addMessage(msg);
        }
    }

    /*
     * Method name  : populateMonthCheckbox
     * Description  : This method populates 12 checkboxes of Beneficairy Wrapper for every month.  
     * Return Type  : List<Boolean>
     * Parameter    : BeneficiaryDataWrapper
     */
    private List<MonthWrapper> populateMonthCheckbox(BeneficiaryDataWrapper oBenWapVar) {
        List<MonthWrapper> lstMonthWrapper = new List<MonthWrapper>();
        Id benefId = oBenWapVar.sBeneficiaryId;
        Set<String> setMonths = (null == existingRecId) ? null : (null ==
                mapBenefIdToMapMonthToAssocId.get(benefId)) ? null :
            mapBenefIdToMapMonthToAssocId.get(benefId)
            .keySet();
        MonthWrapper oMonthWrap = null;
        for(Integer i = 0; i<12; i++) {
            oMonthWrap = new MonthWrapper();
            if(null<> setMonths && setMonths.contains(mapIndexToMonthName.get(i))) {
                oMonthWrap.bSelectedMonth = true;
            } else {
                oMonthWrap.bSelectedMonth = false;
            }
            lstMonthWrapper.add(oMonthWrap);
        }
        return lstMonthWrapper;
    }

    /**
     * Class name   : BeneficiaryDataWrapper
     * Description  : Inner class to use as a data structure for holding Beneficiary information and its 
     *                association to Monthly Class Schedule
     **/
    public class BeneficiaryDataWrapper implements Comparable {
        public List<MonthWrapper> lstMonthWrapper {
            get;
            set;
        }
        public String sBeneficiaryId {
            get;
            set;
        }
        public String sLocalBeneficiaryId {
            get;
            set;
        }
        public String sLocalBeneficiaryNum {
            get;
            set;
        }
        public String sLocalBeneficiaryAge {
            get;
            set;
        }
        public String sBeneficiaryName {
            get;
            set;
        }
        public Boolean bCheckForAllMonths {
            get;
            set;
        }
        /*
         * Method name  : compareTo
         * Description  : This method is called whenever sort method is called on List containing objects of this 
                          wrapper class. 
         * Return Type  : Integer
         * Parameter    : Object
         */
        public Integer compareTo(Object oBenefWrap) {
            BeneficiaryDataWrapper oOrigBenefWrap = (BeneficiaryDataWrapper) oBenefWrap;
            if(sBeneficiaryName == oOrigBenefWrap.sBeneficiaryName) return 0;
            if(sBeneficiaryName> oOrigBenefWrap.sBeneficiaryName) return 1;
            return -1;
        }
    }

    /**
     * Class name   : MonthWrapper
     * Description  : Inner class to use as a data structure for holding Monthly Class Schedule
     **/
    public class MonthWrapper {
        public Boolean bSelectedMonth {
            get;
            set;
        }
        public Id associationId {
            get;
            set;
        }
    }

    /*
     * Method name  : instantiateMonthlyClassList
     * Description  : This method instantiates 12 checkboxes of Beneficairy Wrapper for every month.  
     * Return Type  : void
     * Parameter    : void
     */
    private void instantiateMonthlyClassList() {
        Integer iDecMonthIndex = mapMonthNameToIndex.get(Constants.DEC_ACRONYM);
        System.debug('iDecMonthIndex'+iDecMonthIndex);
        Decimal dYear = Decimal.valueOf(oYearlySchedule.Year__c);
        Set<String> setMonthNames = new Set<String>();
        if(!lstMonthlyClass.isEmpty()) {
            for(Monthly_Class_Schedule__c oMonthly: lstMonthlyClass) {
                setMonthNames.add(oMonthly.Month__c);
            }
        }
        for(String sMonthName: lstForFirstRow) {
            if(!setMonthNames.contains(sMonthName)) {
                Integer iCurrentMonthIndex = mapMonthNameToIndex.get(sMonthName);
                Monthly_Class_Schedule__c oMonthly = new Monthly_Class_Schedule__c(
                    Month__c = sMonthName, BEN_Cognitive_Age_Group__c = oYearlySchedule.BEN_Cognitive_Age_Group__c,
                    Name = oYearlySchedule.Name + '-' + sMonthName,
                    Year__c = (iCurrentMonthIndex <= iDecMonthIndex) ? String.valueOf(dYear) :
                    String.valueOf(dYear + 1));
                lstMonthlyClass.add(oMonthly);
            }
        }
    }

    /*
     * Method name  : instantiateListForFirstRow
     * Description  : This method instantiates List containing names of all months to be displayed in first 
                      row of table.  
     * Return Type  : void
     * Parameter    : void
     */
    private void instantiateListForFirstRow() {

        mapForFirstRow = new Map<String, Boolean>();
        lstForFirstRow = new List<String>();
        List<String> lstHelperForFirstRow = new List<String> (Label.Yearly_Class_Month_Names
            .split(','));
        String sStartingMonth = oYearlySchedule.Starting_Month__c;
        Integer iStartingIndex = 0;
        Integer iIndexForMap = 0;
        for(Integer i = 0; i<lstHelperForFirstRow.size(); i++) {
            if(sStartingMonth.equals(lstHelperForFirstRow[i])) {
                iStartingIndex = i;
                break;
            }
        }
        for(Integer i = iStartingIndex; i<12; i++) {
            mapMonthNameToIndex.put(lstHelperForFirstRow[i], iIndexForMap);
            mapIndexToMonthName.put(iIndexForMap++, lstHelperForFirstRow[i]);
            lstForFirstRow.add(lstHelperForFirstRow[i]);
            mapForFirstRow.put(lstHelperForFirstRow[i], false);
        }
        for(Integer i = 0; i<iStartingIndex; i++) {
            mapMonthNameToIndex.put(lstHelperForFirstRow[i], iIndexForMap);
            mapIndexToMonthName.put(iIndexForMap++, lstHelperForFirstRow[i]);
            lstForFirstRow.add(lstHelperForFirstRow[i]);
            mapForFirstRow.put(lstHelperForFirstRow[i], false);
        }
    }

    /*
     * Method name  : selectAllBenefForMonth
     * Description  : This method marks attendance of all beneficiary for that corresponding month.  
     * Return Type  : void
     * Parameter    : void
     */
    public void selectAllBenefForMonth() {

        String sMonthName = System.currentPagereference()
            .getParameters()
            .get(Constants.CLASS_MONTH_NAME_URL_PARAM);
        Integer iIndex = mapMonthNameToIndex.get(sMonthName);
        Boolean bValueToSet = mapForFirstRow.get(sMonthName);
        for(BeneficiaryDataWrapper oBenWrap: lstBeneficiaryWrapper) {
            (oBenWrap.lstMonthWrapper)[iIndex].bSelectedMonth = bValueToSet;
        }
    }

    /*
     * Method name  : selectAllMonthForBenef
     * Description  : This method marks attendance of all months for that corresponding beneficiary.  
     * Return Type  : void
     * Parameter    : void
     */
    public void selectAllMonthForBenef() {

        String sBenefId = System.currentPagereference()
            .getParameters()
            .get(Constants.CLASS_BENEF_ID_URL_PARAM);
        for(BeneficiaryDataWrapper oBenWrap: lstBeneficiaryWrapper) {
            if(oBenWrap.sBeneficiaryId.equals(sBenefId)) {
                Boolean bValueToSet = oBenWrap.bCheckForAllMonths;
                for(MonthWrapper oMonthWrap: oBenWrap.lstMonthWrapper) {
                    oMonthWrap.bSelectedMonth = bValueToSet;
                }
                break;
            }
        }
    }

    /*
     * Method name  : selectBeneficiaries
     * Description  : This method inserts/updates attendance into DB.  
     * Return Type  : PageReference
     * Parameter    : void
     */
    public PageReference selectBeneficiaries() {
        List<Beneficiary_Class_Association__c> lstAssocToAdd = new List <
            Beneficiary_Class_Association__c>();
        List<Id> lstAssocToDelete = new List<Id>();
        List<Id> lstMonthlytoDel = new List<Id>();
		
		if(!checkIfBenefIsSelected()){
			Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Class_No_Benef_Selected_Val_Error);
            Apexpages.addmessage(oMsg);
			return null;	
		}
        updateYearlyAndMonthly(lstMonthlytoDel);
        udpateBenefAssoc(lstAssocToAdd, lstAssocToDelete);

        System.debug('lstAssocToAdd ' + lstAssocToAdd);
        if(!lstAssocToAdd.isEmpty()) {
            List<Database.SaveResult> lstUpdateResults =
                Database.insert(lstAssocToAdd, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstAssocToAdd,
                'Beneficiary_Class_Association__c', 'YearlyClassExtension',
                'selectBeneficiaries', 'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_while_updating_Class_Attendance);
                Apexpages.addmessage(oMsg);
                return null;
            }
        }

        System.debug('lstAssocToDelete ' + lstAssocToDelete);
        if(!lstAssocToDelete.isEmpty()) {
            List<Database.DeleteResult> lstDeleteResults =
                Database.delete(lstAssocToDelete, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstDeleteResults, lstAssocToDelete,
                'Beneficiary_Class_Association__c', 'YearlyClassExtension',
                'selectBeneficiaries', 'SFDC CI');
            if(!mapIdToErrorMsg.isEmpty()) {
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_while_updating_Class_Attendance);
                Apexpages.addmessage(oMsg);
                return null;
            }
        }
        System.debug('lstMonthlytoDel ' + lstMonthlytoDel);
        if(!lstMonthlytoDel.isEmpty()) {
            List<Database.DeleteResult> lstDeleteResults =
                Database.delete(lstMonthlytoDel, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstDeleteResults, lstMonthlytoDel,
                'Monthly_Class_Schedule__c', 'YearlyClassExtension',
                'updateYearlyAndMonthly', 'SFDC CI');
            if(!mapIdToErrorMsg.isEmpty()) {
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_while_updating_Class_Attendance);
                Apexpages.addmessage(oMsg);
            }
        }
        return redirectToPreviousPage();
    }

    /*
     * Method name  : udpateBenefAssoc
     * Description  : This method inserts/updates Beneficiary association into DB.  
     * Return Type  : void
     * Parameter    : List<Beneficiary_Class_Association__c>,List<Id>
     */
    private void udpateBenefAssoc(List<Beneficiary_Class_Association__c>
        lstAssocToAdd, List<Id> lstAssocToDelete) {

        List<MonthWrapper> lstMonthWrapper = null;
        MonthWrapper oMonthWrap = null;
        Map<String, Id> mapMonthNameToMonthlyId = new Map<String, Id>();
        for(Monthly_Class_Schedule__c oMonthly: lstMonthlyClass) {
            mapMonthNameToMonthlyId.put(oMonthly.Month__c, oMonthly.Id);
        }

        System.debug('mapMonthNameToMonthlyId ' + mapMonthNameToMonthlyId);

        Set<String> setMonths = null;
        Map<String, Id> mapMonthNameToAssocId = null;
        String monthName = Constants.EMPTY_STRING;
        for(BeneficiaryDataWrapper oBenWrap: lstBeneficiaryWrapper) {
            lstMonthWrapper = oBenWrap.lstMonthWrapper;
            mapMonthNameToAssocId = (null == existingRecId) ? null :
                mapBenefIdToMapMonthToAssocId.get(oBenWrap.sBeneficiaryId);
            setMonths = (null == existingRecId || null == mapMonthNameToAssocId) ? null :
                mapMonthNameToAssocId.keySet();
            for(Integer i = 0; i<lstMonthWrapper.size(); i++) {
                oMonthWrap = lstMonthWrapper[i];
                monthName = mapIndexToMonthName.get(i);
                if(oMonthWrap.bSelectedMonth && (null == setMonths || !setMonths.contains(
                        monthName))) {
                    Beneficiary_Class_Association__c oBenefAssoc = new Beneficiary_Class_Association__c(
                        Monthly_Class_Schedule__c = (mapMonthNameToMonthlyId.get(
                            mapIndexToMonthName.get(i))),
                        BEN_Id__c = oBenWrap.sBeneficiaryId);
                    lstAssocToAdd.add(oBenefAssoc);
                } else if(!oMonthWrap.bSelectedMonth && null<> setMonths && setMonths.contains(
                        monthName)) {
                    lstAssocToDelete.add(mapMonthNameToAssocId.get(monthName));
                }
            }
        }
    }

    /*
     * Method name  : updateYearlyAndMonthly
     * Description  : This method inserts/updates Yearly and Monthly classes into DB.  
     * Return Type  : void
     * Parameter    : List<Id>
     */
    private void updateYearlyAndMonthly(List<Id> lstMonthlytoDel) {
        System.debug('oYearlySchedule ' + oYearlySchedule);
        try {
            if(null == existingRecId) {
                insert oYearlySchedule;
            } else {
                update oYearlySchedule;
            }
        } catch(Exception oEx) {
            ErrorLogUtility.logGeneralError(oEx, 'ActivityAttendanceExtension',
                'createActivityAttendance', 'SFDC CI');
            Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                oEx.getMessage());
            Apexpages.addmessage(oMsg);
        }

        Integer iBenListLength = lstBeneficiaryWrapper.size();
        Set<String> setMonthNames = new Set<String>();
        List<Monthly_Class_Schedule__c> lstMonthlyToUpsert = new List <
            Monthly_Class_Schedule__c>();
        for(Integer i = 0; i<12; i++) {
            for(Integer j = 0; j<iBenListLength; j++) {
                if(lstBeneficiaryWrapper[j].lstMonthWrapper[i].bSelectedMonth) {
                    setMonthNames.add(mapIndexToMonthName.get(i));
                    break;
                }
            }
        }
		
		Integer iDecMonthIndex = mapMonthNameToIndex.get(Constants.DEC_ACRONYM);
        System.debug('iDecMonthIndex'+iDecMonthIndex);
        Decimal dYear = Decimal.valueOf(oYearlySchedule.Year__c);
        for(Monthly_Class_Schedule__c oMonthly: lstMonthlyClass) {
            if(setMonthNames.contains(oMonthly.Month__c) && String.isEmpty(oMonthly.Yearly_Class__c)) {
                Integer iCurrentMonthIndex = mapMonthNameToIndex.get(oMonthly.Month__c);
                oMonthly.Yearly_Class__c = oYearlySchedule.Id;
                oMonthly.BEN_Cognitive_Age_Group__c = oYearlySchedule.BEN_Cognitive_Age_Group__c;
                oMonthly.Year__c = (iCurrentMonthIndex <= iDecMonthIndex) ? String.valueOf(dYear) 
                							:String.valueOf(dYear + 1);
                oMonthly.Name = oYearlySchedule.Name + '-' + oMonthly.Month__c;
                lstMonthlyToUpsert.add(oMonthly);
            } else if(!setMonthNames.contains(oMonthly.Month__c) && null<> oMonthly.Id) {
                lstMonthlytoDel.add(oMonthly.Id);
            }

        }

        System.debug('lstMonthlyToUpsert ' + lstMonthlyToUpsert);
        if(!lstMonthlyToUpsert.isEmpty()) {
            List<Database.UpsertResult> lstUpdateResults = Database.upsert(
                lstMonthlyToUpsert, false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults, lstMonthlyToUpsert,
                    'Monthly_Class_Schedule__c',
                    'YearlyClassExtension', 'updateYearlyAndMonthly', 'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_while_updating_Class_Attendance);
                Apexpages.addmessage(oMsg);
            }
        }
    }

    /*
     * Method name  : redirectToPreviousPage
     * Description  : This method redirects to Yearly Class tab.  
     * Return Type  : PageReference
     * Parameter    : void
     */
    public PageReference redirectToPreviousPage() {

        String sYearlyPrefix = Yearly_Class_Schedule__c.sObjectType.getDescribe()
            .getKeyPrefix();
        System.debug('');
        return new PageReference('/' + sYearlyPrefix);
    }

    /*
     * Method name  : resetAllDataStructures
     * Description  : This method reset all data structures of this form.  
     * Return Type  : void
     * Parameter    : void
     */
    public void resetAllDataStructures() {
        lstBeneficiaryWrapper.clear();
        lstMonthlyClass.clear();
        mapBenefIdToMapMonthToAssocId.clear();
        setExistingAssocIds.clear();
        lstBeneficiaries.clear();
        mapMonthNameToIndex.clear();
        mapIndexToMonthName.clear();
        mapBenefIdToAssocId.clear();
        searchBeneficiary();
    }
    
    /*
     * Method name  : checkIfBenefIsSelected
     * Description  : This method checks if at least one of the Beneficiary is enrolled for any class   
     * Return Type  : Boolean
     * Parameter    : void
     */
    private Boolean checkIfBenefIsSelected() {
    	
    	for(BeneficiaryDataWrapper oBenWrap: lstBeneficiaryWrapper){
    		List<MonthWrapper> lstMonthWrapper = oBenWrap.lstMonthWrapper;
    		for(MonthWrapper oMonthWrap : lstMonthWrapper){
    			if(oMonthWrap.bSelectedMonth){
    				return true;
    			}
    		}
    	}
    	return false;
    }
    
}