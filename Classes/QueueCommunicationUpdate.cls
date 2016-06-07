/******************************************************************************************************
Class Name         : QueueCommunicationUpdate
Deascription       : This class is used to update the Communication records
Created By         : Akashdeep Vinnakota
Created On         : 24-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class QueueCommunicationUpdate implements Queueable {
    public Set<ID> setUpdateCommKit {
        get;
        set;
    }
    public String sPrintOutput {
        get;
        set;
    }
    public List<Template_Sequencing_Data__c> lstCurrTempSeq {
        get;
        set;
    }
    public Map<String, Map<Integer, List<Template_Sequencing_Data__c>>>
        mapOfFoKeys {
            get;
            set;
        }
    public List<Communication_Kit__c> lstUpdateCommKit {
        get;
        set;
    }

    /**
     * Method name  : QueueCommunicationUpdate
     * Description  : This is a construtor of this class.
     * Return Type  : 
     * Parameter    : User, List<Communication_Kit__c>
     **/
    public QueueCommunicationUpdate(String sPrintOutput, List<Communication_Kit__c>
        lstUpdateCommKit, Map<String, 
        Map<Integer, List<Template_Sequencing_Data__c>>>
        mapOfFoKeys, List<Template_Sequencing_Data__c> lstCurrTempSeq) {

        this.sPrintOutput = sPrintOutput;
        this.lstUpdateCommKit = lstUpdateCommKit;
        this.mapOfFoKeys = mapOfFoKeys;
        this.lstCurrTempSeq = lstCurrTempSeq;
        
        /*
        DateTime d = datetime.now();
        //Noting the current month's name
        String sMonthName = d.format(Constants.PrintPortal_CurrMonth);    
        String sSearchMonth = '%'+sMonthName+'%';

        lstCurrTempSeq = new List<Template_Sequencing_Data__c>();
        lstCurrTempSeq = [Select id, Age_Min__c, Age_Max__c, FO_Id__c, Priority__c,
            Template_Id__c, Template_Last_Used_Date__c, Template_Months__c,
            Template_Order__c, Type_of_Letter__c from Template_Sequencing_Data__c
            where Template_Months__c LIKE : sSearchMonth ORDER BY Priority__c, 
            Template_Order__c ASC
        ];


        mapOfFoKeys = new Map<String, Map<Integer, List <
            Template_Sequencing_Data__c>>>();
        for(Template_Sequencing_Data__c CurrTS: lstCurrTempSeq) {
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
                 String sQuery =
            'Select id, Status__c, BEN_ID__c, BEN_ID__r.BEN_Last_Wrote__c, BEN_Id__r.ICP__r.Letters_Due_at_FO__c, BEN_Id__r.ICP__r.Gift_Letters_Due_at_FO__c,BEN_Id__r.Age_In_Months__c, BEN_Id__r.ICP__r.Cluster__r.Territory__r.Field_Office__r.Field_Office_Id__c, RecordType.Name, Communication_Types__c from Communication_Kit__c where id IN: setUpdateCommKit';
        this.lstUpdateCommKit = Database.query(sQuery);
        */

    }

    /**
     * Method name  : execute
     * Description  : This method is used to update Communication records.
     * Return Type  : void
     * Parameter    : QueueableContext
     **/
    public void execute(QueueableContext context) {
        DateTime d = datetime.now();
        String sMonthName = d.format(Constants.PrintPortal_CurrMonth);

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
            CurrRec.Printed_Not_Sent_To_FO__c = true;
            if(String.ValueOf(sPrintOutput) != Constants.VAR_Select) {
                CurrRec.Print_Type_Selected__c = String.ValueOf(sPrintOutput);
            }
            if((String.ValueOf(CurrRec.Communication_Types__c) != Null) && (String.ValueOf(
                        CurrRec.Communication_Types__c)
                    .contains(Constants.Small_Gift_Thank_You_Letter) ||
                    String.ValueOf(CurrRec.Communication_Types__c)
                    .contains(Constants.Large_Gift_Thank_You_Letter) ||
                    String.ValueOf(CurrRec.Communication_Types__c)
                    .contains(Constants.CORRESPONDENCE_ITEM_TYPE_SCHEDULED_LETTER))// KN(COR addition)- Adding scheduled Letters into the 28-day working time bucket
               && CurrRec.BEN_Id__r.ICP__r.Gift_Letters_Due_at_FO__c !=
                Null && CurrRec.Marked_For_Rework__c != true) {
                CurrRec.Due_Back_At_Field_Office__c = System.Today()
                    .addDays(Integer.ValueOf(CurrRec.BEN_Id__r.ICP__r.Gift_Letters_Due_at_FO__c));
            } else {
                if(CurrRec.BEN_Id__r.ICP__r.Letters_Due_at_FO__c != Null && CurrRec.Marked_For_Rework__c != true)
                    CurrRec.Due_Back_At_Field_Office__c = System.Today()
                    .addDays(Integer.ValueOf(CurrRec.BEN_Id__r.ICP__r.Letters_Due_at_FO__c));
            }

            list<String> lstOfCommTypes = new list<String>();

            Decimal RealAge = (CurrRec.BEN_Id__r.Age_In_Months__c) / 12;
            if(CurrRec.Communication_Types__c != null) {
                lstOfCommTypes = CurrRec.Communication_Types__c.split(';');
            } else {
                lstOfCommTypes = new list<String> {
                    ''
                };
            }

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
                for(Template_Sequencing_Data__c CurrTS: mapOfFoKeys.get(FoKey)
                    .get(iCurrPriority)) {
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

        for(Template_Sequencing_Data__c CurrTS: lstCurrTempSeq) {
            if(setOfTemplateIds.contains(CurrTS.id))
                CurrTS.Template_Last_Used_Date__c = System.Today();
        }
        
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

        List<Database.SaveResult> lstUpdateResults = new List<Database.SaveResult>
            ();
        try {
            lstUpdateResults = Database.update(lstCurrTempSeq, false);
        } catch(DmlException ex) {
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstCurrTempSeq, 'Template_Sequencing_Data__c',
                'CommunicationKitSearchPageController', 'getID', 'SFDC CI', false);
        }
        System.Debug('bUpdateFromPrintPortal before Print: ' +
            CommunicationKitHandler.bUpdateFromPrintPortal);
        if(lstUpdateCommKit.size()> 0) {
            try {
                TriggerContextUtility.switchOffCommunicationTrigger();
                //CommunicationKitHandler.bUpdateFromPrintPortal = true;
                lstUpdateResults = Database.update(lstUpdateCommKit, false);
                //CommunicationKitHandler.bUpdateFromPrintPortal = false;
            } catch(DmlException ex) {
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, lstCurrTempSeq, 'Communication_Kit__c',
                    'CommunicationKitSearchPageController', 'getID', 'SFDC CI', false);
            }
        }
        
        if(lstOfBen.size() > 0)
        {
            try 
            {
                TriggerContextUtility.switchOffAccountTrigger();
                lstUpdateResults = Database.update(lstOfBen, false);
            }catch(DmlException ex) {
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstOfBen, 'Account',
                'CommunicationKitSearchPageController', 'getID', 'SFDC CI', false);
            }
        }
    }
}