/************************************************************************
 *Class Name         : CSPBenefAttendanceTrackingExtension
 *Description        : This class allows Tutor to track attendance of CSP Beneficiaries in Monthly class 
 *Created By         : Himanshu Raichandani
 *Created On         : 13-July-2015 
 ********************************************************************************/
public with sharing class CSPBenefAttendanceTrackingExtension {

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
    private Map<String, Id> mapDisplayDateToId = new Map<String, Id>();

    /**
     * Method name  : CSPBenefAttendanceTrackingExtension
     * Description  : CSPBenefAttendanceTrackingExtension Constructor
     * Return Type  : NA
     * Parameter    : ApexPages.StandardController
     **/
    public CSPBenefAttendanceTrackingExtension(ApexPages.StandardController controllerParam) {

        bDisplayPopUp = false;
        bFirstTime = true;
        bShowComponents = true;
        Schema.DescribeSObjectResult oSObject = Schema.sObjectType.Yearly_Class_Schedule__c;
        if(!oSObject.isUpdateable()){
            bShowComponents = false;
        }
        lstForTable = new List<String> {''};
        lstDailyClassWrapper = new List<DailyClassWrapper>();
        lstBeneficiaryWrapper = new List<BeneficiaryDataWrapper>();
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

        lstBenefAssoc = [Select BEN_Id__c, BEN_Name__c, BEN_Local_Number__c,
            BEN_Local_Id__c, Monthly_Class_Schedule__c, Month_Name__c
            from Beneficiary_Class_Association__c where Monthly_Class_Schedule__c = :
            oMonthlySchedule.Id];
        System.debug('lstBenefAssoc ' + lstBenefAssoc);

        lstDailyClass = [Select Class_Date__c, Class_Hours__c, Day__c,
            Display_Date__c, Name, Monthly_Class_Schedule__c from Daily_Class_Schedule__c where Monthly_Class_Schedule__c = :
            oMonthlySchedule.Id];

        if(!lstDailyClass.isEmpty()) {
            bIsCreateFlow = false;
            for(Daily_Class_Schedule__c oDailyClass: lstDailyClass) {
                mapDisplayDateToId.put(oDailyClass.Display_Date__c, oDailyClass.Id);
                setBenefAttnForDaily.add(oDailyClass.Id);
            }

            lstBenefClassAttn = [Select Id, BEN_Attended__c, BEN_Hours_Attended__c,
                BEN_Id__c, Daily_Class_Schedule__c, Daily_Class_Day__c from Beneficiary_Class_Attendance__c where 
                Daily_Class_Schedule__c in :setBenefAttnForDaily ];

            Map<Decimal, BenefAttendance> mapMonthDayToBenefAttn = null;
            for(Beneficiary_Class_Attendance__c obenefClassAttn: lstBenefClassAttn) {
                if(mapBenefIdToMapDayToBenefAttn.keySet()
                    .contains(obenefClassAttn.BEN_Id__c)) {
                    mapBenefIdToMapDayToBenefAttn.get(obenefClassAttn.BEN_Id__c)
                        .put(obenefClassAttn.Daily_Class_Day__c, new BenefAttendance(
                            obenefClassAttn.Id, obenefClassAttn.BEN_Hours_Attended__c));
                } else {
                    mapMonthDayToBenefAttn = new Map<Decimal, BenefAttendance>();
                    mapMonthDayToBenefAttn.put(obenefClassAttn.Daily_Class_Day__c, new BenefAttendance(
                        obenefClassAttn.Id, obenefClassAttn.BEN_Hours_Attended__c));
                    mapBenefIdToMapDayToBenefAttn.put(obenefClassAttn.BEN_Id__c,
                        mapMonthDayToBenefAttn);
                }
            }
            System.debug('mapBenefIdToMapDayToBenefAttn ' +
                mapBenefIdToMapDayToBenefAttn);
        }

        instantiateDailyClassWrap();

        for(Beneficiary_Class_Association__c oBenefAssoc: lstBenefAssoc) {
            BeneficiaryDataWrapper oBenWapVar = new BeneficiaryDataWrapper();
            oBenWapVar.sBeneficiaryName = oBenefAssoc.BEN_Name__c;
            oBenWapVar.sBeneficiaryId = oBenefAssoc.BEN_Id__c;
            oBenWapVar.sLocalBeneficiaryId = oBenefAssoc.BEN_Local_Id__c;
            oBenWapVar.sLocalBeneficiaryNum = oBenefAssoc.BEN_Local_Number__c;
            oBenWapVar.lstBenefAttendance = populateBenefAttnHours(oBenWapVar);
            lstBeneficiaryWrapper.add(oBenWapVar);
        }
        calculateTotalHours();
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
    }

    /*
     * Method name  : populateBenefAttnCheckbox
     * Description  : This method populates attendance hours based on Beneficiary Attendance records.
     * Return Type  : List<BenefAttendance>
     * Parameter    : BeneficiaryDataWrapper
     */
    private List<BenefAttendance> populateBenefAttnHours(BeneficiaryDataWrapper oBenWapVar) {
        List<BenefAttendance> lstBenefAttn = new List<BenefAttendance>();
        BenefAttendance oBenefAttn = null;
        Map<Decimal, BenefAttendance> mapDayToAttnId = (true == bIsCreateFlow) ?
            null : mapBenefIdToMapDayToBenefAttn.get(oBenWapVar.sBeneficiaryId);
        Set<Decimal> setDays = (null == mapDayToAttnId) ? null : mapDayToAttnId.keySet();
        Decimal dDay;
        Decimal dHours;
        System.debug('setDays ' + setDays);
        for(Integer i = 0; i<lstDailyClassWrapper.size(); i++) {
            DailyClassWrapper oDailyWrap = lstDailyClassWrapper[i];
            oBenefAttn = new BenefAttendance();
            dDay = Decimal.valueOf(i + 1);
            if(null<> setDays && setDays.contains(dDay)) {
                oBenefAttn.benefAttnId = mapDayToAttnId.get(dDay).benefAttnId;
                dHours = mapDayToAttnId.get(dDay).dHours;
                oBenefAttn.dHours = (null<> dHours && dHours == 0) ? null : dHours;
            } else {
                oBenefAttn.dHours = null;
            }
            lstBenefAttn.add(oBenefAttn);
        }
        System.debug('lstBenefAttn ' + lstBenefAttn);
        return lstBenefAttn;
    }


    /*
     * Method name  : instantiateDailyClassWrap
     * Description  : Based upon month and year selected by Tutor, this method dynamically
                      generate names of column of the table corresponding to each day of that month  
     * Return Type  : void
     * Parameter    : void
     */
    private void instantiateDailyClassWrap() {

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

        DateTime dtCurrentDate = Datetime.newinstance(iYear, iMonth, 1);
        Boolean bIsPrintForm = ApexPages.currentPage()
            .getUrl().contains(Label.Class_Attn_Print_Page);

        for(Integer i = 0; i<iTotalDays; i++) {
            if(bIsPrintForm) {
                sNameToDisplayForPrint = String.valueOf(dtCurrentDate.day());
            }
            sNameToDisplay = dtCurrentDate.day() + ' (' + dtCurrentDate.format('EEEE')
                .substring(0, 3) + ')';
            sNameVfDisplay = dtCurrentDate.day() + ' (' +mapWeekEngToLocalLang.get(dtCurrentDate.format('EEEE')
                .substring(0, 3)) + ')';  
            if(mapDisplayDateToId.size()> 0) {
                lstDailyClassWrapper.add(new DailyClassWrapper((bIsPrintForm) ?
                    sNameToDisplayForPrint : sNameToDisplay, false, 0, dtCurrentDate.day(),
                    mapDisplayDateToId.get(sNameToDisplay),sNameVfDisplay ));
            } else {
                lstDailyClassWrapper.add(new DailyClassWrapper((bIsPrintForm) ?
                    sNameToDisplayForPrint : sNameToDisplay, false, 0, dtCurrentDate.day(),
                    null,sNameVfDisplay));
            }
            dtCurrentDate = dtCurrentDate.addDays(1);
        }

        System.debug('lstDailyClassWrapper: ' + lstDailyClassWrapper);
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
        List<Daily_Class_Schedule__c> lstDailyClassToInsert = new List <
            Daily_Class_Schedule__c>();
        Daily_Class_Schedule__c oDailyClass = null;

        if(mapDisplayDateToId.isEmpty()) {
            for(DailyClassWrapper oDCWrap: lstDailyClassWrapper) {
                oDailyClass = new Daily_Class_Schedule__c(
                    Class_Date__c = Date.newInstance(iYear, iMonth, oDCWrap.iDate),
                    Class_Hours__c = 0,
                    Display_Date__c = oDCWrap.sNameToDisplay,
                    Monthly_Class_Schedule__c = oMonthlySchedule.Id,
                    Name = oMonthlySchedule.Name + ' ' + iYear + '-' + iMonth + '-' +
                    oDCWrap.iDate);
                lstDailyClassToInsert.add(oDailyClass);
            }
            System.debug(' lstDailyClassToInsert' + lstDailyClassToInsert);
            if(!lstDailyClassToInsert.isEmpty()) {
                insert lstDailyClassToInsert;
            }
        }

        List<Daily_Class_Schedule__c> lstDailyClassToLoop = new List <
            Daily_Class_Schedule__c>();
        if(lstDailyClassToInsert.size()> 0) {
            lstDailyClassToLoop.addAll(lstDailyClassToInsert);
        } else {
            lstDailyClassToLoop.addAll(lstDailyClass);
        }

        Map<Integer, Id> mapDailyIndexSavedToId = new Map<Integer, Id>();
        Map<Integer, String> mapDailyIndexSavedToDailyName = new Map<Integer,
            String>();
        for(Integer i = 0; i<lstDailyClassToLoop.size(); i++) {
            oDailyClass = lstDailyClassToLoop[i];
            mapDailyIndexSavedToId.put(i, oDailyClass.Id);
            mapDailyIndexSavedToDailyName.put(i, oDailyClass.Name);
        }
        System.debug(' mapDailyIndexSavedToId ' + mapDailyIndexSavedToId);

        BenefAttendance oBenefAttnWrap = null;
        List<BenefAttendance> lstBenefAttendance = null;
        List<Id> lstBenefClassAttnToDelete = new List<Id>();
        List<Beneficiary_Class_Attendance__c> lstBenefClassAttendanceToUpsert =
            new List<Beneficiary_Class_Attendance__c>();
        Beneficiary_Class_Attendance__c oBenefClassAttn = null;

        for(BeneficiaryDataWrapper oBenWrap: lstBeneficiaryWrapper) {
            lstBenefAttendance = oBenWrap.lstBenefAttendance;
            for(Integer i = 0; i<lstBenefAttendance.size(); i++) {
                oBenefAttnWrap = lstBenefAttendance[i];
                if(oBenefAttnWrap.dHours<1 && null<> oBenefAttnWrap.benefAttnId) {
                    lstBenefClassAttnToDelete.add(oBenefAttnWrap.benefAttnId);
                } else if(oBenefAttnWrap.dHours> 0) {
                    oBenefClassAttn = new Beneficiary_Class_Attendance__c(
                        BEN_Hours_Attended__c = oBenefAttnWrap.dHours,
                        Id = (null == oBenefAttnWrap.benefAttnId) ? null : oBenefAttnWrap.benefAttnId,
                        BEN_Id__c = oBenWrap.sBeneficiaryId, BEN_Attended__c = true,
                        Daily_Class_Schedule__c = mapDailyIndexSavedToId.get(i),
                        Name = mapDailyIndexSavedToDailyName.get(i) + ' ' + oBenWrap.sLocalBeneficiaryNum);
                    lstBenefClassAttendanceToUpsert.add(oBenefClassAttn);
                }
            }
        }

        System.debug(' lstBenefClassAttendanceToUpsert.size() ' +
            lstBenefClassAttendanceToUpsert.size());
        if(!lstBenefClassAttendanceToUpsert.isEmpty()) {
            List<Database.UpsertResult> lstUpdateResults = Database.upsert(
                lstBenefClassAttendanceToUpsert, false);
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults,
                    lstBenefClassAttendanceToUpsert,
                    'Beneficiary_Class_Attendance__c', 'CSPBenefAttendanceTrackingExtension',
                    'saveAttendance', 'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_while_updating_Class_Attendance);
                Apexpages.addmessage(oMsg);
            }
        }

        System.debug(' lstBenefClassAttnToDelete.size() ' +
            lstBenefClassAttnToDelete.size());
        if(!lstBenefClassAttnToDelete.isEmpty()) {
            List<Database.DeleteResult> lstDeleteResults =
                Database.delete(lstBenefClassAttnToDelete, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstDeleteResults, lstBenefClassAttnToDelete,
                'Beneficiary_Class_Attendance__c', 'CSPBenefAttendanceTrackingExtension',
                'saveAttendance', 'SFDC CI');
            if(!mapIdToErrorMsg.isEmpty()) {
                Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                    Label.Error_while_updating_Class_Attendance);
                Apexpages.addmessage(oMsg);
                return null;
            }
        }
        PageReference oPageRef = new PageReference(
            '/apex/CSPBenefAttendanceTrackingPage?id=' + oMonthlySchedule.Id);
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
        public String sBeneficiaryName {
            get;
            set;
        }
        public Decimal dTotalHours {
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
        public Decimal dHours {
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
        public BenefAttendance(Id benefAttnIdArg, Decimal dHoursArg) {
                benefAttnId = benefAttnIdArg;
                dHours = (dHoursArg == 0) ? null : dHoursArg;
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
     * Method name  : calculateTotalHours
     * Description  : This method calculates attendance hours of all beneficiaries for that corresponding month.
     * Return Type  : void
     * Parameter    : void
     */
    private void calculateTotalHours() {

        List<BenefAttendance> lstBenefAttendance = null;
        Decimal dTotalHours = null;
        for(BeneficiaryDataWrapper oBenWrap: lstBeneficiaryWrapper) {
            lstBenefAttendance = oBenWrap.lstBenefAttendance;
            dTotalHours = 0;
            for(Integer i = 0; i<lstBenefAttendance.size(); i++) {
                if(lstBenefAttendance[i].dHours> 0) {
                    dTotalHours += lstBenefAttendance[i].dHours;
                }
            }
            oBenWrap.dTotalHours = (dTotalHours == 0) ? null : dTotalHours;
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