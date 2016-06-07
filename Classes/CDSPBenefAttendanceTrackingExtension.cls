/************************************************************************
 *Class Name         : CDSPBenefAttendanceTrackingExtension
 *Description        : This class allows Tutor to track attendance of CDSP Beneficiaries in Monthly class 
 *Created By         : Himanshu Raichandani
 *Created On         : 29-June-2015 
 ********************************************************************************/
public with sharing class CDSPBenefAttendanceTrackingExtension {

    public Monthly_Class_Schedule__c oMonthlySchedule {
        get;
        set;
    }
    public Boolean bDisplayPopUp {
        get;
        set;
    }
    public Id existingRecId {
        get;
        set;
    }
    public List<String> lstForTable {
        get;
        set;
    }
    public List<BeneficiaryDataWrapper> lstBeneficiaryWrapper {
        get;
        set;
    }
    public List<DailyClassWrapper> lstDailyClassWrapper {
        get;
        set;
    }
    public Integer[] arrNoOfPresentBenef {
        get;
        set;
    }
    public Integer[] arrNoOfAbsentBenef {
        get;
        set;
    }
    public String sLoginFromPartnerPortal {
        get;
        set;
    }
    public Integer iFirstElement {
        get;
        set;
    }
    public Integer iRowsToShow {
        get;
        set;
    }
    public Boolean bDisabledNextBtn {
        get;
        set;
    }
    public Boolean bDisabledPrevBtn {
        get;
        set;
    }
    public Boolean bDisabledFirstBtn {
        get;
        set;
    }
    public Boolean bDisabledLastBtn {
        get;
        set;
    }
    public Boolean bShowComponents {
        get;
        set;
    }

    private String sMonthlyName;
    private List<Daily_Class_Schedule__c> lstDailyClass = new List <
        Daily_Class_Schedule__c>();
    private Map<Id, Map<Decimal, BenefAttendance>>
        mapBenefIdToMapDayToBenefAttn = new Map<Id, Map<Decimal, BenefAttendance>>();
    private Boolean bIsCreateFlow = true;
    private Set<Id> setBenefAttnForDaily = new Set<Id>();
    private Integer iTotalDays;
    private Boolean bFirstTime;

    /**
     * Method name  : CDSPBenefAttendanceTrackingExtension
     * Description  : CDSPBenefAttendanceTrackingExtension Constructor
     * Return Type  : NA
     * Parameter    : ApexPages.StandardController
     **/
    public CDSPBenefAttendanceTrackingExtension(ApexPages.StandardController controllerParam) {

        bDisplayPopUp = false;
        bFirstTime = true;
        bShowComponents = true;
        lstForTable = new List<String> {
            ''
        };
        Schema.DescribeSObjectResult oSObject = Schema.sObjectType.Monthly_Class_Schedule__c;
        if(!oSObject.isUpdateable()){
            bShowComponents = false;
        }
        lstDailyClassWrapper = new List<DailyClassWrapper>();
        lstBeneficiaryWrapper = new List<BeneficiaryDataWrapper>();
        arrNoOfPresentBenef = new Integer[31];
        arrNoOfAbsentBenef = new Integer[31];
        resetAttendanceCountList();
        existingRecId = controllerParam.getId();
        sLoginFromPartnerPortal = (UserInfo.getUserType()
            .equals(Label.PowerPartner)) ? Constants.TRUE_LOWER_CASE : Constants.FALSE_LOWER_CASE;
        if(null<> existingRecId) {
            oMonthlySchedule = ([Select Id, ICP_Name__c, Yearly_Class__r.ICP_Name__r.ICP_Id__c,
                Yearly_Class__r.BEN_Program_Delivery__c, Yearly_Class__r.Class_Type__c,
                Yearly_Class__r.Class_Description__c, BEN_Cognitive_Age_Group__c,
                Tutor__c, Year__c, Name, Month__c, Yearly_Class__c
                from Monthly_Class_Schedule__c where Id = : existingRecId])[0];
            searchBeneficiary();
        } else {
            oMonthlySchedule = new Monthly_Class_Schedule__c();
        }
    }

    /*
     * Method name  : searchBeneficiary
     * Description  : This method is called as soon as page is launched. This generates dynamic SOQL based on Yearly Class data fectehd through DB. 
     * Return Type  : void
     * Parameter    : void
     */
    public void searchBeneficiary() {
        clearAllDataStructures();
        System.debug('oMonthlySchedule ' + oMonthlySchedule);
        List<Beneficiary_Class_Association__c> lstBenefAssoc = null;
        List<Beneficiary_Class_Attendance__c> lstBenefClassAttn = null;

        lstBenefAssoc = [Select BEN_Id__c, BEN_Local_Number__c, BEN_Name__c,
            BEN_Local_Id__c, Monthly_Class_Schedule__c, Month_Name__c
            from Beneficiary_Class_Association__c where Monthly_Class_Schedule__c = :
            oMonthlySchedule.Id];
        System.debug('lstBenefAssoc ' + lstBenefAssoc);

        lstDailyClass = [Select Class_Date__c, Class_Hours__c, Day__c,
            Display_Date__c, Monthly_Class_Schedule__c from Daily_Class_Schedule__c where Monthly_Class_Schedule__c = :
            oMonthlySchedule.Id];
        System.debug('lstDailyClass: '+lstDailyClass);
        if(!lstDailyClass.isEmpty()) {
            bIsCreateFlow = false;
            for(Daily_Class_Schedule__c oDailyClass: lstDailyClass) {
                if(oDailyClass.Class_Hours__c> 0) {
                    setBenefAttnForDaily.add(oDailyClass.Id);
                }
            }

            lstBenefClassAttn = [Select Id, BEN_Attended__c, BEN_Id__c,
                Daily_Class_Schedule__c, Daily_Class_Day__c from Beneficiary_Class_Attendance__c where Daily_Class_Schedule__c in
                : setBenefAttnForDaily];

            Map<Decimal, BenefAttendance> mapMonthDayToBenefAttn = null;
            for(Beneficiary_Class_Attendance__c obenefClassAttn: lstBenefClassAttn) {
                if(mapBenefIdToMapDayToBenefAttn.keySet()
                    .contains(obenefClassAttn.BEN_Id__c)) {
                    mapBenefIdToMapDayToBenefAttn.get(obenefClassAttn.BEN_Id__c)
                        .put(obenefClassAttn.Daily_Class_Day__c, new BenefAttendance(
                            obenefClassAttn.Id, obenefClassAttn.BEN_Attended__c));
                } else {
                    mapMonthDayToBenefAttn = new Map<Decimal, BenefAttendance>();
                    mapMonthDayToBenefAttn.put(obenefClassAttn.Daily_Class_Day__c, new BenefAttendance(
                        obenefClassAttn.Id, obenefClassAttn.BEN_Attended__c));
                    mapBenefIdToMapDayToBenefAttn.put(obenefClassAttn.BEN_Id__c,
                        mapMonthDayToBenefAttn);
                }
            }
            System.debug('mapBenefIdToMapDayToBenefAttn ' +
                mapBenefIdToMapDayToBenefAttn);

            Map<String, Decimal> mapDisplayDateToHours = new Map<String, Decimal>();
            Map<String, Id> mapDisplayDateToId = new Map<String, Id>();
            for(Daily_Class_Schedule__c oDailyClass: lstDailyClass) {
                mapDisplayDateToHours.put(oDailyClass.Display_Date__c, oDailyClass.Class_Hours__c);
                mapDisplayDateToId.put(oDailyClass.Display_Date__c, oDailyClass.Id);
            }
            calculateColumns(mapDisplayDateToHours, mapDisplayDateToId);

        } else {
            calculateColumns(null, null);
        }
        Map<String, BeneficiaryDataWrapper> mapBenNameToBenWrap = new Map <
            String, BeneficiaryDataWrapper>();
        for(Beneficiary_Class_Association__c oBenefAssoc: lstBenefAssoc) {
            BeneficiaryDataWrapper oBenWapVar = new BeneficiaryDataWrapper();
            oBenWapVar.sBeneficiaryName = oBenefAssoc.BEN_Name__c;
            oBenWapVar.sBeneficiaryId = oBenefAssoc.BEN_Id__c;
            oBenWapVar.sLocalBeneficiaryId = oBenefAssoc.BEN_Local_Id__c;
            oBenWapVar.lstBenefAttendance = populateBenefAttnCheckbox(oBenWapVar);
            oBenWapVar.sLocalBeneficiaryNum = oBenefAssoc.BEN_Local_Number__c;
            lstBeneficiaryWrapper.add(oBenWapVar);
            mapBenNameToBenWrap.put(oBenefAssoc.BEN_Name__c, oBenWapVar);
        }
        lstBeneficiaryWrapper.sort();
        bFirstTime = false;
        System.debug('lstBeneficiaryWrapper ' + lstBeneficiaryWrapper);
        if(lstBeneficiaryWrapper.isEmpty()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info,
                Label.Class_Attn_No_Benef_Error);
            ApexPages.addMessage(msg);
        }
        bDisplayPopUp = true;
        iFirstElement = 0;
        iRowsToShow = 7;
        bDisabledNextBtn = false;
        bDisabledPrevBtn = true;
        bDisabledFirstBtn = true;
        bDisabledLastBtn = false;
        calculateNoOfAttendance();
    }

    /*
     * Method name  : populateBenefAttnCheckbox
     * Description  : This method populates attendance checkbox based on Beneficiary Attendance records.
     * Return Type  : List<BenefAttendance>
     * Parameter    : BeneficiaryDataWrapper
     */
    private List<BenefAttendance> populateBenefAttnCheckbox(
        BeneficiaryDataWrapper oBenWapVar) {
        List<BenefAttendance> lstBenefAttn = new List<BenefAttendance>();
        BenefAttendance oBenefAttn = null;
        Map<Decimal, BenefAttendance> mapDayToAttnId = (true == bIsCreateFlow) ?
            null : mapBenefIdToMapDayToBenefAttn.get(oBenWapVar.sBeneficiaryId);
        Set<Decimal> setDays = (null == mapDayToAttnId) ? null : mapDayToAttnId.keySet();
        for(Integer i = 0; i<lstDailyClassWrapper.size(); i++) {
            DailyClassWrapper oDailyWrap = lstDailyClassWrapper[i];
            oBenefAttn = new BenefAttendance();
            Decimal dDay = Decimal.valueOf(i + 1);
            if(null<> setDays && setDays.contains(dDay)) {
                oBenefAttn.benefAttnId = mapDayToAttnId.get(dDay)
                    .benefAttnId;
                oBenefAttn.bSelected = mapDayToAttnId.get(dDay)
                    .bSelected;
            } else {
                oBenefAttn.bSelected = false;
            }
            lstBenefAttn.add(oBenefAttn);
        }
        return lstBenefAttn;
    }


    /*
     * Method name  : calculateColumns
     * Description  : Based upon month and year selected by Tutor, this method dynamically
                      generate names of column of the table corresponding to each day of that month  
     * Return Type  : void
     * Parameter    : void
     */
    private void calculateColumns(Map<String, Decimal> mapDisplayDateToHours,
        Map<String, Id> mapDisplayDateToId) {

        Integer iMonth = convertMonthTextToNumber(oMonthlySchedule.Month__c);
        String sAgeGroup = oMonthlySchedule.BEN_Cognitive_Age_Group__c;
        Integer iYear = Integer.valueOf(oMonthlySchedule.Year__c);
        iTotalDays = Date.daysInMonth(iYear, iMonth);
        String sNameToDisplay = '';
        String sNameVfDisplay = '';
        String sNameToDisplayForPrint = '';
        
        Map<String,String> mapWeekEngToLocalLang = new Map<String,String>();      
        List<String> lstHelperForFirstRow = new List<String> (Label.Class_Attendance_Week_Names
            .split(','));
        Integer j = 0;
        mapWeekEngToLocalLang.put(lstHelperForFirstRow[j++],Label.Class_Mon_Label);
        mapWeekEngToLocalLang.put(lstHelperForFirstRow[j++],Label.Class_Tue_Label);
        mapWeekEngToLocalLang.put(lstHelperForFirstRow[j++],Label.Class_Wed_Label);
        mapWeekEngToLocalLang.put(lstHelperForFirstRow[j++],Label.Class_Thu_Label);
        mapWeekEngToLocalLang.put(lstHelperForFirstRow[j++],Label.Class_Fri_Label);
        mapWeekEngToLocalLang.put(lstHelperForFirstRow[j++],Label.Class_Sat_Label);        
        mapWeekEngToLocalLang.put(lstHelperForFirstRow[j++],Label.Class_Sun_Label);

        Boolean bIsPrintForm = ApexPages.currentPage()
            .getUrl().contains(Label.Class_Attn_Print_Page);
        for(Integer i = 0; i<iTotalDays; i++) {
            DateTime dtCurrentDate = Datetime.newinstance(iYear, iMonth, i+1);
            if(bIsPrintForm) {
                sNameToDisplayForPrint = String.valueOf(dtCurrentDate.day());
            }
            sNameToDisplay = dtCurrentDate.day() + ' (' + dtCurrentDate.format('EEEE')
                .substring(0, 3) + ')';
            sNameVfDisplay = dtCurrentDate.day() + ' (' +mapWeekEngToLocalLang.get(dtCurrentDate.format('EEEE')
                .substring(0, 3)) + ')';  
            if(null<> mapDisplayDateToHours) {
                lstDailyClassWrapper.add(new DailyClassWrapper((bIsPrintForm) ?
                    sNameToDisplayForPrint : sNameToDisplay, false, mapDisplayDateToHours.get(
                        sNameToDisplay), dtCurrentDate.day(), mapDisplayDateToId.get(
                        sNameToDisplay),sNameVfDisplay));
            } else {
                lstDailyClassWrapper.add(new DailyClassWrapper((bIsPrintForm) ?
                    sNameToDisplayForPrint : sNameToDisplay, false, 0, dtCurrentDate.day(),
                    null,sNameVfDisplay));
            }
            sNameToDisplay = Constants.EMPTY_STRING;
            sNameToDisplayForPrint = Constants.EMPTY_STRING;
        }
    }

    /*
     * Method name  : saveAttendance
     * Description  : This method saves attendance recorded by Tutor.
     * Return Type  : PageReference
     * Parameter    : void
     */
    public PageReference saveAttendance() {

        Integer iYear = Integer.valueOf(oMonthlySchedule.Year__c);
        Integer iMonth = convertMonthTextToNumber(oMonthlySchedule.Month__c);
        List<Daily_Class_Schedule__c> lstDailyClassToUpsert = new List <
            Daily_Class_Schedule__c>();
        Daily_Class_Schedule__c oDailyClass = null;

        for(DailyClassWrapper oDCWrap: lstDailyClassWrapper) {
            oDailyClass = new Daily_Class_Schedule__c(
                Class_Date__c = Date.newInstance(iYear, iMonth, oDCWrap.iDate),
                Class_Hours__c = oDCWrap.dHours,
                Id = (null == oDCWrap.dailyClassId) ? null : oDCWrap.dailyClassId,
                Display_Date__c = oDCWrap.sNameToDisplay,
                Monthly_Class_Schedule__c = oMonthlySchedule.Id,
                Name = oMonthlySchedule.Name + ' ' + iYear + '-' + iMonth + '-' + oDCWrap
                .iDate);
            lstDailyClassToUpsert.add(oDailyClass);
        }
        
        System.debug(' lstDailyClassToUpsert' + lstDailyClassToUpsert);
        if(!lstDailyClassToUpsert.isEmpty()) {
            List<Database.UpsertResult> lstUpdateResults = Database.upsert(
                lstDailyClassToUpsert, false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults, lstDailyClassToUpsert,
                    'Daily_Class_Schedule__c','CDSPBenefAttendanceTrackingExtension',
                    'saveAttendance', 'SFDC CI',false);
            if(!mapIdToErrorMsg.isEmpty()) {
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_while_updating_Class_Attendance);
                Apexpages.addmessage(oMsg);
            }
        }

        Map<Integer, Id> mapDailyIndexSavedToId = new Map<Integer, Id>();
        Map<Integer, String> mapDailyIndexSavedToDailyName = new Map<Integer,
            String>();
        for(Integer i = 0; i<lstDailyClassToUpsert.size(); i++) {
            oDailyClass = lstDailyClassToUpsert[i];
            if(oDailyClass.Class_Hours__c> 0) {
                mapDailyIndexSavedToId.put(i, oDailyClass.Id);
                mapDailyIndexSavedToDailyName.put(i, oDailyClass.Name);
            }
        }
        System.debug(' mapDailyIndexSavedToId ' + mapDailyIndexSavedToId);

        BenefAttendance oBenefAttnWrap = null;
        List<BenefAttendance> lstBenefAttendance = null;
        Set<Integer> setMonthlyIndexToSave = mapDailyIndexSavedToId.keySet();
        List<Id> lstBenefClassAttnToDelete = new List<Id>();
        List<Beneficiary_Class_Attendance__c> lstBenefClassAttendance = new List <
            Beneficiary_Class_Attendance__c>();
        Beneficiary_Class_Attendance__c oBenefClassAttn = null;

        if(null<> setMonthlyIndexToSave && setMonthlyIndexToSave.size()> 0) {
            Set<Id> setMonthlyIdToSave = new Set<Id> (mapDailyIndexSavedToId.values());
            for(Id attnId: setBenefAttnForDaily) {
                if(!setMonthlyIdToSave.contains(attnId)) {
                    lstBenefClassAttnToDelete.add(attnId);
                }
            }
        }

        for(BeneficiaryDataWrapper oBenWrap: lstBeneficiaryWrapper) {
            lstBenefAttendance = oBenWrap.lstBenefAttendance;
            for(Integer i = 0; i<lstBenefAttendance.size(); i++) {
                if(setMonthlyIndexToSave.contains(i)) {
                    oBenefAttnWrap = lstBenefAttendance[i];
                    oBenefClassAttn = new Beneficiary_Class_Attendance__c(
                        BEN_Attended__c = oBenefAttnWrap.bSelected,
                        Id = (null == oBenefAttnWrap.benefAttnId) ? null : oBenefAttnWrap.benefAttnId,
                        BEN_Id__c = oBenWrap.sBeneficiaryId,
                        Daily_Class_Schedule__c = mapDailyIndexSavedToId.get(i),
                        Name = mapDailyIndexSavedToDailyName.get(i) + ' ' + oBenWrap.sLocalBeneficiaryNum);
                    lstBenefClassAttendance.add(oBenefClassAttn);
                }
            }
        }

        System.debug(' lstBenefClassAttendance ' + lstBenefClassAttendance);
        if(!lstBenefClassAttendance.isEmpty()) {
            List<Database.UpsertResult> lstUpdateResults = Database.upsert(
                lstBenefClassAttendance, false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults, lstBenefClassAttendance,
                    'Beneficiary_Class_Attendance__c',
                    'CDSPBenefAttendanceTrackingExtension', 'saveAttendance', 'SFDC CI',
                    false);
            if(!mapIdToErrorMsg.isEmpty()) {
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_while_updating_Class_Attendance);
                Apexpages.addmessage(oMsg);
            }
        }

        System.debug(' lstBenefClassAttnToDelete ' + lstBenefClassAttnToDelete);
        if(!lstBenefClassAttnToDelete.isEmpty()) {
            List<Database.DeleteResult> lstDeleteResults =
                Database.delete(lstBenefClassAttnToDelete, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstDeleteResults, lstBenefClassAttnToDelete,
                'Beneficiary_Class_Attendance__c', 'CDSPBenefAttendanceTrackingExtension',
                'saveAttendance', 'SFDC CI');
            if(!mapIdToErrorMsg.isEmpty()) {
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_while_updating_Class_Attendance);
                Apexpages.addmessage(oMsg);
                return null;
            }
        }
        PageReference oPageRef = new PageReference(
            '/apex/CDSPBenefAttendanceTrackingPage?id=' + oMonthlySchedule.Id);
        oPageRef.setRedirect(true);
        return oPageRef;
    }

    /**
     * Class name   : BeneficiaryDataWrapper
     * Description  : Inner class to use as a data structure for holding Beneficiary information and its association to Monthly Class Schedule
     **/
    public class BeneficiaryDataWrapper implements Comparable {
        public List<BenefAttendance> lstBenefAttendance {
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
        public string sBeneficiaryName {
            get;
            set;
        }
        /*
         * Method name  : compareTo
         * Description  : This method is called whenever sort method is called on List containing objects of this wrapper class. 
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
     * Class name   : BenefAttendance
     * Description  : Inner class to use as a data structure for holding Beneficiary Attendance information.
     **/
    public class BenefAttendance {
        public Boolean bSelected {
            get;
            set;
        }
        public Id benefAttnId {
            get;
            set;
        }
        /**
         * Method name  : BenefAttendance Constructor with arguments
         * Return Type  : NA
         * Parameter    : Id, Boolean
         **/
        public BenefAttendance(Id benefAttnIdArg, Boolean bSelectedArg) {
                benefAttnId = benefAttnIdArg;
                bSelected = bSelectedArg;
            }
            /**
             * Method name  : BenefAttendance no-arg Constructor
             * Return Type  : NA
             * Parameter    : void
             **/
        public BenefAttendance() {}
    }

    /**
     * Class name   : DailyClassWrapper
     * Description  : Inner class to use as a data structure for holding Daily Class Attendance records.
     **/
    public class DailyClassWrapper {
        public String sNameToDisplay {
            get;
            set;
        }
        public Boolean bCheckAll {
            get;
            set;
        }
        public Decimal dHours {
            get;
            set;
        }
        public Integer iDate {
            get;
            set;
        }
        public Id dailyClassId {
            get;
            set;
        }
        public String sNameVfDisplay {
            get;
            set;
        }
        /**
         * Method name  : DailyClassWrapper Constructor with arguments
         * Return Type  : NA
         * Parameter    : String,Boolean,Decimal,Integer,Id
         **/
        public DailyClassWrapper(String sNameArg, Boolean bCheckAllArg, Decimal dHoursArg,
            Integer iDateArg, Id dailyClassIdArg,String sDisplayArg) {
            sNameToDisplay = sNameArg;
            bCheckAll = bCheckAllArg;
            dHours = (dHoursArg == 0) ? null : dHoursArg;
            iDate = iDateArg;
            dailyClassId = dailyClassIdArg;
            sNameVfDisplay = sDisplayArg;
        }
    }

    /*
     * Method name  : clearAllDataStructures
     * Description  : This method resets all data structures which ultimately resets all attendance marked by Tutor.
     * Return Type  : void
     * Parameter    : void
     */
    private void clearAllDataStructures() {
        if(null<> lstBeneficiaryWrapper) {
            lstBeneficiaryWrapper.clear();
        }
        if(null<> lstDailyClassWrapper) {
            lstDailyClassWrapper.clear();
        }
        if(null<> lstDailyClass) {
            lstDailyClass.clear();
        }
        if(null<> mapBenefIdToMapDayToBenefAttn) {
            mapBenefIdToMapDayToBenefAttn.clear();
        }
        if(null<> setBenefAttnForDaily) {
            setBenefAttnForDaily.clear();
        }
    }

    /*
     * Method name  : convertMonthTextToNumber
     * Description  : This method creates a map between month name and its corresponding number as salesforce doesn't provide this API OOB  
     * Return Type  : String month
     * Parameter    : Integer
     */
    private Integer convertMonthTextToNumber(String sMonth) {
        Map<String, Integer> mapMonthTextToNumber = new Map<String, Integer>();
        String[] monthArr = Label.Yearly_Class_Month_Names.split(',');
        mapMonthTextToNumber.put(monthArr[0], 1);
        mapMonthTextToNumber.put(monthArr[1], 2);
        mapMonthTextToNumber.put(monthArr[2], 3);
        mapMonthTextToNumber.put(monthArr[3], 4);
        mapMonthTextToNumber.put(monthArr[4], 5);
        mapMonthTextToNumber.put(monthArr[5], 6);
        mapMonthTextToNumber.put(monthArr[6], 7);
        mapMonthTextToNumber.put(monthArr[7], 8);
        mapMonthTextToNumber.put(monthArr[8], 9);
        mapMonthTextToNumber.put(monthArr[9], 10);
        mapMonthTextToNumber.put(monthArr[10], 11);
        mapMonthTextToNumber.put(monthArr[11], 12);
        return mapMonthTextToNumber.get(sMonth);
    }

    /*
     * Method name  : selectAllBenefForDaily
     * Description  : This method marks attendance of all beneficiary for that corresponding date.  
     * Return Type  : void
     * Parameter    : void
     */
    public void selectAllBenefForDaily() {

        Integer iIndex = Integer.valueOf(System.currentPagereference()
            .getParameters()
            .get('iDay')) - 1;
        Boolean bValueToUpdate = lstDailyClassWrapper[iIndex].bCheckAll;
        for(BeneficiaryDataWrapper oBenWrap: lstBeneficiaryWrapper) {
            (oBenWrap.lstBenefAttendance)[iIndex].bSelected = bValueToUpdate;
        }
    }

    /*
     * Method name  : calculateNoOfAttendance
     * Description  : This method calculates attendance of all beneficiaries for that corresponding month.  
     * Return Type  : void
     * Parameter    : void
     */
    private void calculateNoOfAttendance() {
        resetAttendanceCountList();
        List<BenefAttendance> lstBenefAttn = null;
        for(BeneficiaryDataWrapper oBenWrap: lstBeneficiaryWrapper) {
            lstBenefAttn = oBenWrap.lstBenefAttendance;
            for(Integer i = 0; i<lstBenefAttn.size(); i++) {
                if(lstDailyClassWrapper[i].dHours> 0) {
                    if(lstBenefAttn[i].bSelected == true) {
                        arrNoOfPresentBenef[i]++;
                    } else {
                        arrNoOfAbsentBenef[i]++;
                    }
                }
            }
        }
    }

    /*
     * Method name  : resetAttendanceCountList
     * Description  : This method resets attendance count of all beneficiaries for that corresponding month.  
     * Return Type  : void
     * Parameter    : void
     */
    private void resetAttendanceCountList() {
        for(Integer i = 0; i<iTotalDays; i++) {
            arrNoOfPresentBenef[i] = 0;
            arrNoOfAbsentBenef[i] = 0;
        }
    }

    /*
     * Method name  : redirectToListPage
     * Description  : This method redirects to Monthly Class tab.  
     * Return Type  : PageReference
     * Parameter    : void
     */
    public Pagereference redirectToListPage() {
        String sMonthlyPrefix = Monthly_Class_Schedule__c.sObjectType.getDescribe()
            .getKeyPrefix();
        return new PageReference('/' + sMonthlyPrefix);
    }

    /*
     * Method name  : nextPage
     * Description  : This method resets variable so that next set of elements are visible in table.  
     * Return Type  : PageReference
     * Parameter    : void
     */
    public void nextPage() {
        if(iFirstElement + 8 <= iTotalDays) {
            iFirstElement += 7;
        }
        bDisabledNextBtn = (iFirstElement + 8 <= iTotalDays) ? false : true;
        bDisabledPrevBtn = false;
        bDisabledFirstBtn = false;
        bDisabledLastBtn = bDisabledNextBtn;
    }

    /*
     * Method name  : previousPage
     * Description  : This method resets variable so that previous set of elements are visible in table.  
     * Return Type  : PageReference
     * Parameter    : void
     */
    public void previousPage() {
        if(iFirstElement - 7>= 0) {
            iFirstElement -= 7;
        }
        bDisabledPrevBtn = (iFirstElement - 6>= 0) ? false : true;
        bDisabledNextBtn = false;
        bDisabledFirstBtn = bDisabledPrevBtn;
        bDisabledLastBtn = false;
    }

    /*
     * Method name  : firstPage
     * Description  : This method resets variable so that first set of elements are visible in table.
     * Return Type  : PageReference
     * Parameter    : void
     */
    public void firstPage() {
        iFirstElement = 0;
        bDisabledNextBtn = false;
        bDisabledPrevBtn = true;
        bDisabledFirstBtn = true;
        bDisabledLastBtn = false;
    }

    /*
     * Method name  : lastPage
     * Description  : This method resets variable so that last set of elements are visible in table.
     * Return Type  : PageReference
     * Parameter    : void
     */
    public void lastPage() {
        Integer iReminder = Math.mod(iTotalDays, 7);
        iFirstElement = (iReminder==0) ? 21 : iTotalDays - iReminder;
        bDisabledNextBtn = true;
        bDisabledPrevBtn = false;
        bDisabledFirstBtn = false;
        bDisabledLastBtn = true;
    }    
}