/******************************************************************************************************
Class Name         : CommunicationKitSearchPageController
Description        : This is the controller class for the Print Portal page
Created By         : Akashdeep Vinnakota 
Created On         : 17-July-2015 
******************************************************************************************************/
public with sharing class CommunicationKitSearchPageController {
    public String sCorrType {
        get;
        set;
    }
    public String sPrintOutput {
        get;
        set;
    }

    public String sUserInputICPs {
        get;
        set;
    }

    public String sRecordType {
        get;
        set;
    }

    public boolean bChecked {
        get;
        set;
    }

    public boolean bSentSuccess {
        get;
        set;
    }

    public boolean bShowResTbl {
        get;
        set;
    }
    public boolean bIsError {
        get;
        set;
    }
    public boolean bDisablePrintOption {
        get;
        set;
    }

    public boolean bDisableCommType {
        get;
        set;
    }
    public boolean bDependentPicklist {
        get;
        set;
    }

    public Communication_Kit__c oUtilityObj {
        get;
        set;
    }

    public List<SelectOption> lstAgeGroupValues {
        get;
        set;
    }
    public List<SelectOption> lstCommKitStatusValues {
        get;
        set;
    }
    public List<SelectOption> lstCommKitRecordTypeNames {
        get;
        set;
    }
    public List<SelectOption> lstPrintOptions {
        get;
        set;
    }
    public List<SelectOption> lstCommunicationTypes {
        get;
        set;
    }
    public List<WrapperObj> lstResultList {
        get;
        set;
    }
    public List<String> lstAgeGroup {
        get;
        set;
    }

    public Map<String, ID> mapOfRecordTypes;
    public Map<String, Integer> mapOfMonthNames {
        get;
        set;
    }

    private ApexPages.StandardSetController setCon {
        get;
        set;
    }

    private List<Communication_Kit__c> SearchList {
        get;
        set;
    }
    public Integer size {
        get;
        set;
    }

    public Integer noOfRecords {
        get;
        set;
    }

    public ID sSelectedId {
        get;
        set;
    }

    public Set<ID> setOfChosenIds {
        get;
        set;
    }

    public String sSortField {
        get;
        set;
    }

    public String sSortDir {
        get;
        set;
    }
    private Set<Id> setOfAllIds;

    /**
     * Method name  : CommunicationKitSearchPageController
     * Description  : This is constructor of the class responsible for initializing all the variables required
     * Return Type  : N/A
     * Parameter    : void
     **/

    public CommunicationKitSearchPageController() {
        mapOfMonthNames = new Map<String, Integer>();
        mapOfMonthNames.put(Constants.Jan, 1);
        mapOfMonthNames.put(Constants.Feb, 2);
        mapOfMonthNames.put(Constants.Mar, 3);
        mapOfMonthNames.put(Constants.Apr, 4);
        mapOfMonthNames.put(Constants.May, 5);
        mapOfMonthNames.put(Constants.Jun, 6);
        mapOfMonthNames.put(Constants.Jul, 7);
        mapOfMonthNames.put(Constants.Aug, 8);
        mapOfMonthNames.put(Constants.Sep, 9);
        mapOfMonthNames.put(Constants.Oct, 10);
        mapOfMonthNames.put(Constants.Nov, 11);
        mapOfMonthNames.put(Constants.Dec, 12);

        setOfChosenIds = new Set<ID>();
        sSortField = '';
        sSortDir = '';
        setOfAllIds = new Set<ID>();
        
        bDisablePrintOption = false;
        lstPrintOptions = new List<SelectOption>();
        lstCommunicationTypes = new List<SelectOption>();
        lstAgeGroupValues = new List<SelectOption>();
        lstCommKitRecordTypeNames = new List<SelectOption>();
        lstCommKitStatusValues = new List<SelectOption>();
        oUtilityObj = new Communication_Kit__c();
        lstAgeGroup = new List<String> {
            Constants.All_CONSTANT
        };
        bShowResTbl = false;
        bIsError = false;
        sRecordType = '';
        sUserInputICPs = '';
        bDisableCommType = false;
        bDependentPicklist = false;
        bChecked = false;
        bSentSuccess = false;
        size = 50;


        lstPrintOptions.add(new SelectOption(Constants.All_CONSTANT, 
            System.Label.Print_Portal_Comm_Type_All));
        lstPrintOptions.add(new SelectOption(Constants.Print_Option_Header,
            System.Label.Print_Option_Header));
        lstPrintOptions.add(new SelectOption(Constants.Print_Option_Template,
            System.Label.Print_Option_Template));

        lstCommunicationTypes.add(new SelectOption(Constants.All_CONSTANT, 
            System.Label.Print_Portal_Comm_Type_All));
        lstCommunicationTypes.add(new SelectOption(Constants.NEW_SPONSOR_LETTER,
            System.Label.Print_Portal_Comm_Type_New_Sponsor));
        lstCommunicationTypes.add(new SelectOption(Constants.RELATIONSHIP_LETTER,
            System.Label.Print_Portal_Comm_Type_Relationship_Letter));
        lstCommunicationTypes.add(new SelectOption(Constants.FINAL_LETTER, 
            System.Label.Print_Portal_Comm_Type_Final_Letter));

        Schema.DescribeFieldResult ageGroupFieldDescription = Account.Cognitive_Age_Group__c
            .getDescribe();

        lstAgeGroupValues.add(new SelectOption(Constants.All_CONSTANT, System.Label.Print_Portal_Comm_Type_All));
        lstAgeGroupValues.add(new SelectOption(Constants.AgeGroupOption1_Value,
            Constants.AgeGroupOption1_Label));
        lstAgeGroupValues.add(new SelectOption(Constants.AgeGroupOption2_Value,
            Constants.AgeGroupOption2_Label));
        lstAgeGroupValues.add(new SelectOption(Constants.AgeGroupOption3_Value,
            Constants.AgeGroupOption3_Label));
        
        Map<String, Schema.RecordTypeInfo> mapOfRecordTypeNames =
            Schema.SObjectType.Communication_Kit__c.getRecordTypeInfosByName();
        Map<ID, Schema.RecordTypeInfo> mapOfRecordTypeIds =
            Schema.SObjectType.Communication_Kit__c.getRecordTypeInfosById();
        lstCommKitRecordTypeNames.add(new SelectOption(Constants.Both_CONSTANT,
           System.Label.Print_Portal_Record_Type_Both));
        mapOfRecordTypes = new Map<String, ID>();
        for(ID RecTypeId: mapOfRecordTypeIds.keyset()) {
            for(String RecTypeName: mapOfRecordTypeNames.keyset()) {
                if(mapOfRecordTypeIds.get(RecTypeId) == mapOfRecordTypeNames.get(
                        RecTypeName)) {
                    mapOfRecordTypes.put(RecTypeName, RecTypeId);
                }
            }
        }
        for(String picklistEntry: mapOfRecordTypeNames.keyset()) 
        {
            if(mapOfRecordTypeNames.get(picklistEntry).isMaster() == false){
                lstCommKitRecordTypeNames.add(new SelectOption(mapOfRecordTypes.get(picklistEntry),
                   picklistEntry));                
            }        
        }
    
        Schema.DescribeFieldResult statusFieldDescription = Communication_Kit__c.Status__c
            .getDescribe();
        lstCommKitStatusValues.add(new SelectOption(Constants.All_CONSTANT, System.Label.Print_Portal_Comm_Type_All));
        for(Schema.Picklistentry picklistEntry: statusFieldDescription.getPicklistValues()) {
            lstCommKitStatusValues.add(new SelectOption(pickListEntry.getValue(),
                pickListEntry.getLabel()));
        }
        oUtilityObj.Status__c = lstCommKitStatusValues[1].getValue();
        sRecordType = lstCommKitRecordTypeNames[1].getValue();
        sPrintOutput = lstPrintOptions[1].getValue();
    }

    /**
    * Method name  : reRenderDependentPanel
    * Description  : This method is responsible for re-rendering the Communication Types picklist 
                     on the page based on the selection of Record Type
    * Return Type  : void
    * Parameter    : N/A
    **/

    public void reRenderDependentPanel() {
        if(sRecordType == lstCommKitRecordTypeNames[1].getValue()) {
            bDisableCommType = false;
            //bDependentPicklist = true;
            sPrintOutput = lstPrintOptions[1].getValue();
            bDisablePrintOption = false;
            oUtilityObj.RecordTypeid = mapOfRecordTypes.get(String.escapeSingleQuotes(
                sRecordType));
        } else if(sRecordType == lstCommKitRecordTypeNames[2].getValue()) {
            sCorrType = Constants.All_CONSTANT;
            bDisableCommType = true;
            //bDependentPicklist = true;
            sPrintOutput = lstPrintOptions[2].getValue();
            bDisablePrintOption = true;
            oUtilityObj.RecordTypeid = mapOfRecordTypes.get(String.escapeSingleQuotes(
                sRecordType));
        } else {
            bDisableCommType = false;
            bDependentPicklist = false;
            sPrintOutput = lstPrintOptions[2].getValue();
            bDisablePrintOption = true;
        }
    }

    /**
     * Method name  : checkSelectAll
     * Description  : This method selects all the records displayed on the page
     * Return Type  : void
     * Parameter    : N/A
     **/
    public void checkSelectAll() {
        if(bChecked) {
            setOfChosenIds.addall(setOfAllIds);
        } else {
            setOfChosenIds = new Set<Id>();
        }
        refreshList();
        System.Debug('setOfChosenIds in Select All: ' + setOfChosenIds);
    }

    /**
     * Method name  : setSorting
     * Description  : This method sets the sorting direction of the records
     * Return Type  : void
     * Parameter    : N/A
     **/
    public void setSorting() {
        sSortDir = (sSortDir == Constants.PrintPortal_ASC) ? Constants.PrintPortal_DESC :
            Constants.PrintPortal_ASC;
        System.Debug('sSortField: ' + sSortField);
        search();
    }

    /**
     * Method name  : setSorting
     * Description  : This method selects/deselects individual records based on the action on the page
     * Return Type  : void
     * Parameter    : N/A
     **/
    public void addSetUpdateCommKit() {
        if(setOfChosenIds.contains(sSelectedId)) {
            setOfChosenIds.remove(sSelectedId);
        } else {
            setOfChosenIds.add(sSelectedId);
        }
    }

    /**
     * Method name  : getID
     * Description  : This is contains actions that are carried out after a print request is given
     * Return Type  : void
     * Parameter    : N/A
     **/
    public void getID() {
            bSentSuccess = false;
            if(sPrintOutput == Constants.All_CONSTANT && String.Valueof(sRecordType) !=
                lstCommKitRecordTypeNames[2].getValue()) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                    System.Label.Print_Portal_Choose_Print_Option_Error);
                ApexPages.addMessage(myMsg);
                bShowResTbl = false;
                search();
                return;
            }


            Set<ID> setUpdateCommKit = new Set<ID>();
            setUpdateCommKit.addall(setOfChosenIds);


            if(setUpdateCommKit.size() == 0) {
                bIsError = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,
                    System.Label.Print_Portal_Choose_Letter_To_Print);
                ApexPages.addMessage(myMsg);
                return;
            } else {

                List<Communication_Kit__c> lstUpdateCommKit = new List <
                    Communication_Kit__c>();
                lstUpdateCommKit = [Select id, Status__c, BEN_ID__c, BEN_ID__r.BEN_Last_Wrote__c,
                    BEN_Id__r.Age_In_Months__c,
                    BEN_Id__r.ICP__r.Cluster__r.Territory__r.Field_Office__r.Field_Office_Id__c,
                    RecordType.Name, RecordType.id,
                    BEN_Id__r.ICP__r.Letters_Due_at_FO__c, BEN_Id__r.ICP__r.Gift_Letters_Due_at_FO__c,
                    Communication_Types__c, Marked_For_Rework__c from Communication_Kit__c where id IN:
                    setUpdateCommKit
                ];


                List<Communication_Kit__c> lstUpdateCommKitS2B = new List <Communication_Kit__c>();
                List<Communication_Kit__c> lstUpdateCommKitB2S = new List <Communication_Kit__c>();

                Integer iSuppRecCount = 0;
                Integer iIndex = 0;
                // Put S2B record in separate list
                System.Debug('>>>> Before setUpdateCommKit.size(): ' + setUpdateCommKit.size());
                System.Debug('>>>> Before setUpdateCommKit: ' + setUpdateCommKit);
                
                System.Debug('>>>> Before lstUpdateCommKit.size(): ' + lstUpdateCommKit.size());
                System.Debug('>>>> Before lstUpdateCommKit: ' + lstUpdateCommKit);
                
                System.Debug('>>>> Before lstUpdateCommKitS2B.size(): ' + lstUpdateCommKitS2B.size());
                System.Debug('>>>> Before lstUpdateCommKitS2B: ' + lstUpdateCommKitS2B);
                for(Communication_Kit__c CurrRec: lstUpdateCommKit)
                {
                    if(CurrRec.RecordType.id == CommunicationKitHandler.sRecordTypeS2B) {
                        iSuppRecCount += 1;
                        lstUpdateCommKitS2B.add(CurrRec);
                        setUpdateCommKit.remove(CurrRec.id);
                    }
                    else
                    {
                        lstUpdateCommKitB2S.add(CurrRec);
                    }
                    
                    if(iSuppRecCount> 45) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,
                            System.Label.Print_Portal_SuppRecs_Error_Msg);
                        ApexPages.addMessage(myMsg);
                        return;
                    }
                }
                
                System.Debug('>>>> After setUpdateCommKit.size(): ' + setUpdateCommKit.size());
                System.Debug('>>>> After setUpdateCommKit: ' + setUpdateCommKit);
                
                System.Debug('>>>> After lstUpdateCommKit.size(): ' + lstUpdateCommKit.size());
                System.Debug('>>>> After lstUpdateCommKit: ' + lstUpdateCommKit);

                System.Debug('>>>> After lstUpdateCommKitS2B.size(): ' + lstUpdateCommKitS2B.size());
                System.Debug('>>>> After lstUpdateCommKitS2B: ' + lstUpdateCommKitS2B);
                
                List<Template_Sequencing_Data__c> CurrTempSeq = new List <
                Template_Sequencing_Data__c>();
                DateTime d = datetime.now();
                //Noting the current month's name
                String sMonthName = d.format(Constants.PrintPortal_CurrMonth);    
                String sSearchMonth = '%'+sMonthName+'%';    
                CurrTempSeq = [Select id, Age_Min__c, Age_Max__c, FO_Id__c, Priority__c,
                    Template_Id__c, Template_Last_Used_Date__c, Template_Months__c,
                    Template_Order__c, Type_of_Letter__c from Template_Sequencing_Data__c 
                    where Template_Months__c LIKE : sSearchMonth ORDER BY Priority__c,
                    Template_Order__c ASC
                ];
        
                //Map of Template Sequencing Logic Indexed By FO id & Priority
                Map<String, Map<Integer, List<Template_Sequencing_Data__c>>>
                    mapOfFoKeys = new Map<String, Map<Integer, List <
                    Template_Sequencing_Data__c>>>();
                for(Template_Sequencing_Data__c CurrTS: CurrTempSeq) {
                    if(!mapOfFoKeys.containsKey(CurrTS.FO_Id__c)) {
                        List<Template_Sequencing_Data__c> lstTemp = new List <
                            Template_Sequencing_Data__c>();
                        lstTemp.add(CurrTS);
                        Map<Integer, List<Template_Sequencing_Data__c>> InnerMap = new Map <
                            Integer, List<Template_Sequencing_Data__c>>();
                        InnerMap.put(Integer.ValueOf(CurrTS.Priority__c), lstTemp);
                        mapOfFoKeys.put(CurrTS.FO_Id__c, InnerMap);
                    } else {
                        Map<Integer, List<Template_Sequencing_Data__c>> InnerMap =
                            mapOfFoKeys.get(CurrTS.FO_Id__c);
                        if(InnerMap.containsKey(Integer.ValueOf(CurrTS.Priority__c))) {
                            List<Template_Sequencing_Data__c> lstTemp = InnerMap.get(Integer.ValueOf(
                                CurrTS.Priority__c));
                            lstTemp.add(CurrTS);
                            InnerMap.put(Integer.ValueOf(CurrTS.Priority__c), lstTemp);
                            mapOfFoKeys.put(CurrTS.FO_Id__c, InnerMap);
                        } else {
                            List<Template_Sequencing_Data__c> lstTemp = new List <
                                Template_Sequencing_Data__c>();
                            lstTemp.add(CurrTS);
                            InnerMap.put(Integer.ValueOf(CurrTS.Priority__c), lstTemp);
                            mapOfFoKeys.put(CurrTS.FO_Id__c, InnerMap);
                        }
                    }
                }

                System.Debug('>>>> lstUpdateCommKitB2S: ' + lstUpdateCommKitB2S.size());
                if(lstUpdateCommKitB2S.size() > 0) {
                    List<Communication_Kit__c> lstToSend = new List<Communication_Kit__c>();
                    for(Communication_Kit__c oCurrRec: lstUpdateCommKitB2S) {
                        lstToSend.add(oCurrRec);
                        if(lstToSend.size() == 100) {
                            System.enqueueJob(new QueueCommunicationUpdate(String.escapeSingleQuotes(
                                sPrintOutput), lstToSend, mapOfFoKeys, CurrTempSeq));
                            lstToSend = new List<Communication_Kit__c>();
                        }
                    }
                    if(lstToSend.size()> 0)
                        System.enqueueJob(new QueueCommunicationUpdate(String.escapeSingleQuotes(
                            sPrintOutput), lstToSend, mapOfFoKeys, CurrTempSeq));
                    CommunicationKitHandler.bUpdateFromPrintPortal = false;
                
                }
                System.Debug('>>>> lstUpdateCommKitS2B: ' + lstUpdateCommKitS2B.size());
                if(lstUpdateCommKitS2B.size() > 0) {
                    processCommRecs(lstUpdateCommKitS2B,mapOfFoKeys,CurrTempSeq);
                }
                

            }
            
            bSentSuccess = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm, System.Label.Print_Portal_Print_Message);
            ApexPages.addMessage(myMsg);
            
        }
        /**
         * Method name  : processCommRecs
         * Description  : This method updates Template id, Print Date, Print Option, 
                          Status & Due back at Field Office. It also updates the Template
                          Sequencing Logic Data 
         * Return Type  : void
         * Parameter    : List<Communication_Kit__c>
         **/
    public void processCommRecs(List<Communication_Kit__c> lstUpdateCommKit, Map<String, 
        Map<Integer, List<Template_Sequencing_Data__c>>>
        mapOfFoKeys, List<Template_Sequencing_Data__c> CurrTempSeq) {
        
        DateTime d = datetime.now();
        String sMonthName = d.format(Constants.PrintPortal_CurrMonth);
        System.Debug('>>>> mapOfFoKeys: ' + mapOfFoKeys);

        Set<id> setOfTemplateIds = new Set<id>();
        Set<id> setofBenIds = new Set<id>();

        for(Communication_Kit__c CurrRec: lstUpdateCommKit) {
            if(CurrRec.RecordType.id == CommunicationKitHandler.sRecordTypeB2S)
            {
                setofBenIds.add(CurrRec.BEN_ID__c);
            }
            if(CurrRec.Marked_For_Rework__c != true)
            {
                CurrRec.Print_Date__c = System.Today();
            }
            CurrRec.Status__c = Constants.Comm_Status;
            if(String.ValueOf(sPrintOutput) != lstPrintOptions[0].getValue()) {
                CurrRec.Print_Type_Selected__c = String.escapeSingleQuotes(String.ValueOf(
                    sPrintOutput));
            }
            if((String.ValueOf(CurrRec.Communication_Types__c) != Null) && (String.ValueOf(
                        CurrRec.Communication_Types__c)
                    .contains(Constants.Small_Gift_Thank_You_Letter) ||
                    String.ValueOf(CurrRec.Communication_Types__c)
                    .contains(
                        Constants.Large_Gift_Thank_You_Letter)) && CurrRec.BEN_Id__r.ICP__r.Gift_Letters_Due_at_FO__c !=
                Null && CurrRec.Marked_For_Rework__c != true) {
                CurrRec.Due_Back_At_Field_Office__c = System.Today()
                    .addDays(Integer.ValueOf(CurrRec.BEN_Id__r.ICP__r.Gift_Letters_Due_at_FO__c));
            } else {
                if(CurrRec.BEN_Id__r.ICP__r.Letters_Due_at_FO__c != Null && CurrRec.Marked_For_Rework__c != true)
                    CurrRec.Due_Back_At_Field_Office__c = System.Today()
                    .addDays(Integer.ValueOf(CurrRec.BEN_Id__r.ICP__r.Letters_Due_at_FO__c));
            }

            list<String> lstOfCommTypes = new list<String>();

            //Determining real age of the beneficiary
            Decimal RealAge = (CurrRec.BEN_Id__r.Age_In_Months__c) / 12;
             
            
            if(CurrRec.Communication_Types__c != null) {
                lstOfCommTypes = CurrRec.Communication_Types__c.split(';');
            } else {
                lstOfCommTypes = new list<String> {
                    ''
                };
            }

            //Setting Priority of current Communication record based on Communication Types
            Integer iCurrPriority;
            Set<String> TempSet = new Set<String> (lstOfCommTypes);
            if(TempSet.contains(Constants.NEW_SPONSOR_LETTER)) {
                iCurrPriority = 1;
            } else if(TempSet.contains(Constants.FINAL_LETTER)) {
                iCurrPriority = 2;
            } else if(TempSet.contains(Constants.CORRESPONDENCE_ITEM_TYPE_SCHEDULED_LETTER) ||
                TempSet.contains(Constants.CORRESPONDENCE_ITEM_TYPE_RECIPROCAL_LETTER) ||
                TempSet.contains(Constants.Small_Gift_Thank_You_Letter) || TempSet.contains(
                    Constants.Large_Gift_Thank_You_Letter)) {
                iCurrPriority = 3;
            } else if(TempSet.contains(Constants.COMMUNICATION_TYPE_BENEFICIARY_INITIATED)) {
                iCurrPriority = 4;
            }

            Map<id, Map<id, Template_Sequencing_Data__c>> mapOfTemplate = new Map <
                id, Map<id, Template_Sequencing_Data__c>>();
            String FoKey = '';
            if( CurrRec.BEN_Id__c !=null && CurrRec.BEN_Id__r.ICP__c != null && CurrRec.BEN_Id__r.ICP__r.Cluster__c !=null && 
                CurrRec.BEN_Id__r.ICP__r.Cluster__r.Territory__c != null &&  CurrRec.BEN_Id__r.ICP__r.Cluster__r.Territory__r.Field_Office__c != null 
                && CurrRec.BEN_Id__r.ICP__r.Cluster__r.Territory__r.Field_Office__r.Field_Office_Id__c != null)
            {
                FoKey = CurrRec.BEN_Id__r.ICP__r.Cluster__r.Territory__r.Field_Office__r.Field_Office_Id__c;
            }
            else
            {
                FoKey = '';
            }
            if(mapOfFoKeys.get(FoKey) != null && mapOfFoKeys.get(FoKey)
                .get(iCurrPriority) != null) {
                Integer iCurrOrder;
                Date LastUsedDate;
                //Fetching TSD records for the current records FO id & Priority
                for(Template_Sequencing_Data__c CurrTS: mapOfFoKeys.get(FoKey)
                    .get(iCurrPriority)) {
                    //Checking if the Age & Month match the current communication record
                    if(CurrTS.Age_Min__c <= RealAge && RealAge<CurrTS.Age_Max__c && CurrTS.Template_Months__c
                        .contains(sMonthName)) {
                        if(mapOfTemplate.containsKey(CurrRec.id)) {
                            if(CurrTS.Template_Last_Used_Date__c == null && mapOfTemplate.get(
                                    CurrRec.id)
                                .values()
                                .Template_Last_Used_Date__c != null) {
                                if(mapOfTemplate.get(CurrRec.id)
                                    .values()
                                    .Template_Last_Used_Date__c.daysBetween(System.Today())> 60) 
                                    {
                                        CurrRec.Template_Id__c = CurrTS.Template_Id__c;
                                        Map<ID, Template_Sequencing_Data__c> InnerMap = new Map<ID,
                                            Template_Sequencing_Data__c>();
                                        InnerMap.put(CurrTS.id, CurrTS);
                                        mapOfTemplate.put(CurrRec.id, InnerMap);
                                } 
                                
                            }
                            else if(CurrTS.Template_Last_Used_Date__c != null && mapOfTemplate.get(
                                    CurrRec.id)
                                .values()
                                .Template_Last_Used_Date__c != null) {
                                if(CurrTS.Template_Last_Used_Date__c.daysBetween(System.Today())<60 &&
                                    mapOfTemplate.get(CurrRec.id)
                                    .values()
                                    .Template_Last_Used_Date__c.daysBetween(System.Today())> 60) {
                                    CurrRec.Template_Id__c = CurrTS.Template_Id__c;
                                    Map<ID, Template_Sequencing_Data__c> InnerMap = new Map<ID,
                                        Template_Sequencing_Data__c>();
                                    InnerMap.put(CurrTS.id, CurrTS);
                                    mapOfTemplate.put(CurrRec.id, InnerMap);
                                } else if(CurrTS.Template_Last_Used_Date__c.daysBetween(System.Today())>
                                    60 && mapOfTemplate.get(CurrRec.id)
                                    .values()
                                    .Template_Last_Used_Date__c.daysBetween(System.Today())> 60) {
                                    if(CurrTS.Template_Last_Used_Date__c<mapOfTemplate.get(CurrRec.id)
                                        .values()
                                        .Template_Last_Used_Date__c) {
                                        CurrRec.Template_Id__c = CurrTS.Template_Id__c;
                                        Map<ID, Template_Sequencing_Data__c> InnerMap = new Map<ID,
                                            Template_Sequencing_Data__c>();
                                        InnerMap.put(CurrTS.id, CurrTS);
                                        mapOfTemplate.put(CurrRec.id, InnerMap);
                                    }
                                }
                            }
                        } else {
                            CurrRec.Template_Id__c = CurrTS.Template_Id__c;
                            Map<ID, Template_Sequencing_Data__c> InnerMap = new Map<ID,
                                Template_Sequencing_Data__c>();
                            InnerMap.put(CurrTS.id, CurrTS);
                            mapOfTemplate.put(CurrRec.id, InnerMap);
                        }
                    }


                }
            }
            if(mapOfTemplate.get(CurrRec.id) != null)
                setOfTemplateIds.add(mapOfTemplate.get(CurrRec.id)
                    .values()
                    .id);
        }

        System.Debug('>>>> setOfTemplateIds: ' + setOfTemplateIds);

        //Updating last used date of Template Sequencing Data
        for(Template_Sequencing_Data__c CurrTS: CurrTempSeq) {
            if(setOfTemplateIds.contains(CurrTS.id))
                CurrTS.Template_Last_Used_Date__c = System.Today();
        }
        
        System.Debug('>>>> setofBenIds: ' + setofBenIds);
        List<Account> lstOfBen = new List<Account>();
        if(setofBenIds.size() > 0)
        {
            for(ID iCurrRec : setofBenIds)
            {
                Account oBenRec = new Account();
                oBenRec.id = iCurrRec;
                oBenRec.BEN_Last_Wrote__c = System.Today();
                lstOfBen.add(oBenRec);
            }
        }
        System.Debug('>>>> lstOfBen: ' + lstOfBen);
        //Update Template Sequecing Data records
        List<Database.SaveResult> lstUpdateResults = new List<Database.SaveResult>
            ();
        try {
            lstUpdateResults = Database.update(CurrTempSeq, false);
        } catch(DmlException ex) {
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, CurrTempSeq, 'Template_Sequencing_Data__c',
                'CommunicationKitSearchPageController', 'getID', 'SFDC CI', false);
        }
        //Update Communication records
        if(lstUpdateCommKit.size()> 0) {
            try {

                CommunicationKitHandler.bUpdateFromPrintPortal = true;
                lstUpdateResults = Database.update(lstUpdateCommKit, false);
                CommunicationKitHandler.bUpdateFromPrintPortal = false;
            } catch(DmlException ex) {
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, lstUpdateCommKit, 'Communication_Kit__c',
                    'CommunicationKitSearchPageController', 'getID', 'SFDC CI', false);
            }
        }
        
        //Update Beneficiary Records
        if(lstOfBen.size() > 0)
        {
            try 
            {
                lstUpdateResults = Database.update(lstOfBen, false);
            }catch(DmlException ex) {
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstOfBen, 'Account',
                'CommunicationKitSearchPageController', 'getID', 'SFDC CI', false);
            }
        }

        
    }

    /**
     * Method name  : search
     * Description  : This is contains the actions when a search is called from the Print Portal
     * Return Type  : void
     * Parameter    : N/A
     **/

    public void search() {
        bSentSuccess = false;
        bChecked = false;
        setOfAllIds = new Set<ID>();
        setOfChosenIds = new Set<ID>();


        List<String> lstOfChosenAgeGroup = new List<String>();
        for(String oSO: lstAgeGroup) {
            List<String> lstTemp = oSO.split(',', 5);
            lstOfChosenAgeGroup.addall(lstTemp);
        }
        Set<String> setOfChosenAgeGroup = new Set<String>();
        setOfChosenAgeGroup.addall(lstOfChosenAgeGroup);


        String DbQuery =
            'Select id, Name, Status__c, Print_Date__c, BEN_Local_ID__c, BEN_Id__c, BEN_Id__r.Name, ' +
            'BEN_Id__r.ICP__r.ICP_Id__c, BEN_Id__r.ICP__r.Name, BEN_Id__r.Cognitive_Age_Group__c, ' +
            'Communication_Types__c, RecordType.Name from Communication_Kit__c ';
        
        if(sCorrType != null && sCorrType != Constants.All_CONSTANT) {
            if(sCorrType == Constants.RELATIONSHIP_LETTER) {
                DbQuery = DbQuery +
                    ' Where Communication_Types__c INCLUDES (\'Scheduled Letter\', \'Reciprocal Letter\', \'Small Gift Thank You Letter\', ' +
                    ' \'Large Gift Thank You Letter\')';
            } else {
                DbQuery = DbQuery + ' Where Communication_Types__c INCLUDES (\'' + String.escapeSingleQuotes(
                        sCorrType) +
                    '\') ';
            }
        }
        else
        {
            DbQuery = DbQuery +
                    ' Where Communication_Types__c INCLUDES (\'Scheduled Letter\', \'Reciprocal Letter\', \'Small Gift Thank You Letter\', ' +
                    ' \'Large Gift Thank You Letter\', \'Final Letter\', \'New Sponsor Letter\',\'\')';
        }
        
        if(sPrintOutput == Constants.Print_Option_Header && String.Valueof(
                sRecordType) ==
            lstCommKitRecordTypeNames[1].getValue() && (lstAgeGroup.size() == 0 ||
                sCorrType == Constants.VAR_Select)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.Print_Portal_CAG_AND_CT_Filled);
            ApexPages.addMessage(myMsg);
            bShowResTbl = false;
            return;
        }

        if((oUtilityObj.BEN_Id__c == null || String.ValueOf(oUtilityObj.BEN_Id__c) ==
                '') && (oUtilityObj.Print_Date__c == null || String.ValueOf(oUtilityObj.Print_Date__c) ==
                '') && (String.Valueof(oUtilityObj.ICP_Lookup__c) == null || String.Valueof(
                oUtilityObj.ICP_Lookup__c) == '') && (oUtilityObj.Status__c == null ||
                oUtilityObj.Status__c == Constants.VAR_Select) && (lstAgeGroup.size() == 0) &&
            (
                sCorrType == null || sCorrType == Constants.VAR_Select) && (sRecordType ==
                null ||
                sRecordType == Constants.VAR_Select) && (sPrintOutput == null ||
                sPrintOutput ==
                Constants.All_CONSTANT)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,
                System.Label.Print_Portal_Fill_One_Criteria);
            ApexPages.addMessage(myMsg);
            bShowResTbl = false;
            return;
        }
        Date CurrDate = System.Today();

        if(oUtilityObj.BEN_Id__c != null && String.ValueOf(oUtilityObj.BEN_Id__c) !=
            '') {
            DbQuery = DbQuery + ' AND BEN_Id__c = \'' + string.escapeSingleQuotes(
                oUtilityObj.BEN_Id__c) + '\' ';
        }
        if(oUtilityObj.Print_Date__c != null && String.ValueOf(oUtilityObj.Print_Date__c) !=
            '') {
            DateTime dPrint = Datetime.newinstance(oUtilityObj.Print_Date__c.year(),
                oUtilityObj.Print_Date__c.month(), oUtilityObj.Print_Date__c.day());
            DbQuery = DbQuery + ' AND Print_Date__c = ' + dPrint.format('yyyy-MM-dd');
        }
        if(String.Valueof(sUserInputICPs) != null && String.Valueof(sUserInputICPs) !=
            '') {
            sUserInputICPs = String.Valueof(sUserInputICPs)
                .replace(' ', '');
            List<String> lstTemp = String.Valueof(sUserInputICPs)
                .split(',');
            List<Account> lstOfICPs = [Select id, ICP_Id__c from Account where ICP_Id__c in
                : lstTemp
            ];
            Map<String, Id> MapOfAccs = new Map<String, Id>();
            Set<String> setIncorrectICP = new Set<String>();
            for(Account Acc: lstOfICPs) {
                MapOfAccs.put(Acc.ICP_Id__c, Acc.id);
            }
            for(String ICPId: lstTemp) {
                if(!MapOfAccs.containsKey(ICPId)) {
                    setIncorrectICP.add(ICPId);
                }

            }
            if(setIncorrectICP.size()> 0) {
                String ErrorMsg = String.ValueOf(System.Label.Print_Portal_ICP_Error_Message +
                    setIncorrectICP + System.Label.Print_Portal_ICP_Error_Message_2);
                ErrorMsg = ErrorMsg.replace('{', '')
                    .replace('}', '');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                    ErrorMsg);
                ApexPages.addMessage(myMsg);
                return;
            }
            setIncorrectICP = new Set<String>();
            setIncorrectICP.addall(lstTemp);
            DbQuery = DbQuery + ' AND BEN_Id__r.ICP__r.ICP_Id__c IN ' + inClausify(
                setIncorrectICP);
        }
        if(String.Valueof(sRecordType) != null && String.Valueof(sRecordType) !=
            'Select') {
            if(String.Valueof(sRecordType) != Constants.Both_CONSTANT) {
                DbQuery = DbQuery + ' AND RecordTypeId = \'' + string.escapeSingleQuotes(
                    String.Valueof(
                        sRecordType)) + '\' ';
            }
        }
        if(String.Valueof(oUtilityObj.Status__c) != null && String.Valueof(
                oUtilityObj.Status__c) != Constants.All_CONSTANT) {
            DbQuery = DbQuery + ' AND Status__c = \'' + string.escapeSingleQuotes(
                String.Valueof(oUtilityObj.Status__c)) + '\' ';
        }
        if(lstOfChosenAgeGroup.size()> 0 && !setOfChosenAgeGroup.contains(
                Constants.All_CONSTANT)) {
            DbQuery = DbQuery +
                ' AND BEN_Id__r.Cognitive_Age_Group__c IN: lstOfChosenAgeGroup ';
        }
        
        
        //Set<String> TemplateGroup = new Set<String>{'%-H-%', '%-G-%'};
        //COMMENTED BY RAHUL AGARWAL
        //Set<String> TemplateGroup = new Set<String>{'%-A-%', '%-B-%','%-C-%', '%-D-%','%-E-%', '%-F-%'};
        //DbQuery = DbQuery + ' AND (Template_ID__c LIKE: TemplateGroup) ';
        // ADDED BY RAHUL AGARWAL
       Set<String> TemplateGroup = new Set<String>{'%-H-%', '%-G-%'};
        DbQuery = DbQuery + ' AND (NOT Template_ID__c LIKE: TemplateGroup) ';
        
        
        
        DbQuery = DbQuery + ' AND Print_Allowed_Date__c <= ' + System.Now()
            .format(
                'yyyy-MM-dd');
        if(sSortField != '' && sSortDir != '') {
            DbQuery = DbQuery + ' ORDER BY ' + String.escapeSingleQuotes(sSortField) +
                ' ' + String.escapeSingleQuotes(sSortDir);
            DbQuery = DbQuery + ' NULLS LAST ';
        } else {
            DbQuery = DbQuery + ' ORDER BY CreatedDate DESC ';
        }
        DbQuery = DbQuery + ' LIMIT 2000';
        system.debug(' DbQuery>>> ' + DbQuery);


        try {
            SearchList = Database.Query(DbQuery);
            // Push all the records into a standard set controller
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                DbQuery));
        } catch(Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.Print_Portal_Dynamic_Query_Error);
            ApexPages.addMessage(myMsg);
            return;
        }

        if(SearchList.size()> 0) {
            for(Communication_Kit__c oCKRec: SearchList) {
                setOfAllIds.add(oCKRec.id);
            }
        }
        //Clearing SearchList to avoid View State Error
        SearchList = new List<Communication_Kit__c>();

        if(setCon.getResultSize()> 0) {
            bShowResTbl = true;
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
        } else {
            bShowResTbl = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,
                System.Label.Print_Portal_No_Records_Found);
            ApexPages.addMessage(myMsg);
            return;
        }

        refreshList();



    }

    /******************************************************************************************************
     Wrapper Class Name : WrapperObj
     Description        : This is the wrapper class for displaying the result set on the Print Portal page
     Created By         : Akashdeep Vinnakota 
     Created On         : 17-July-2015 
     ******************************************************************************************************/

    @TestVisible public class WrapperObj {
        public boolean bIsSelected {
            get;
            set;
        }
        public Communication_Kit__c oCKRec {
            get;
            set;
        }

        public WrapperObj(boolean bIsSelected, Communication_Kit__c oCKRec) {
            this.bIsSelected = bIsSelected;
            this.oCKRec = oCKRec;
        }

    }

    /**
     * Method name  : refresh
     * Description  : This method resets the standard set controller to 1st page
     * Return Type  : void
     * Parameter    : N/A
     **/
    public pageReference refresh() {
        setCon = null;
        search();
        setCon.setPageNumber(1);
        return null;
    }

    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }

    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }

    /**
     * Method name  : first
     * Description  : This method displays first set of records in the Standard Set Controller
     * Return Type  : void
     * Parameter    : N/A
     **/
    public void first() {
        setCon.first();
        refreshList();
    }

    /**
     * Method name  : last
     * Description  : This method displays last set of records in the Standard Set Controller
     * Return Type  : void
     * Parameter    : N/A
     **/
    public void last() {
        setCon.last();
        refreshList();
    }

    /**
     * Method name  : previous
     * Description  : This method displays previous set of records in the Standard Set Controller
     * Return Type  : void
     * Parameter    : N/A
     **/
    public void previous() {
        setCon.previous();
        refreshList();
    }

    /**
     * Method name  : next
     * Description  : This method displays next set of records in the Standard Set Controller
     * Return Type  : void
     * Parameter    : N/A
     **/
    public void next() {
        setCon.next();
        refreshList();

    }

    /**
     * Method name  : refreshList
     * Description  : This method refreshes the search results on the Print Portal VF page
     * Return Type  : void
     * Parameter    : N/A
     **/
    public void refreshList() {
        lstResultList = new List<WrapperObj>();
        for(Communication_Kit__c CkRec: (List<Communication_Kit__c> ) setCon.getRecords()) {
            if(setOfChosenIds.contains(CkRec.id) || bChecked) {
                lstResultList.add(new WrapperObj(true, CkRec));
            } else {
                lstResultList.add(new WrapperObj(false, CkRec));
            }
        }
        System.Debug('lstResultList: ' + lstResultList.size());
    }

    /**
     * Method name  : inClausify
     * Description  : This method returns a String converted values of Set elements
     * Return Type  : void
     * Parameter    : N/A
     **/
    public String inClausify(Set<String> ids) {
        String inClause = String.format(Constants.PrintPortal_inClausifyString1, new List <
            String> {
                String.join(new List<String> (ids), Constants.PrintPortal_inClausifyString2)
            });
        return inClause;
    }
}