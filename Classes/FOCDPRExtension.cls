/************************************************************************
*Name               : FOCDPRExtension
*Description        : This page is used for adding Progress Measures
                      corresponding to specific Field Office.   
*Created By         : Sowmya Chamakura
*Created On         : 1/10/2015

********************************************************************************/
public with sharing class FOCDPRExtension {

    public String sSuccessMessage{
        get;
        set;
    }
    public String sShowMessage {
        get;
        set;
    }
    public String sSelectOutcome {
        get;
        set;
    }
    public Boolean bShowResults {
        get;
        set;
    }
    public String sAcctId {
        get;
        set;
    }
    public Account oAcc {
        get;
        set;
    }

    public FO_Administration__c oCreateFOA {
        get;
        set;
    }
    public Map<String, List<FO_Administration__c>> mapInd {
        get;
        set;
    }
    public List<FO_Administration__c> oResults {
        get;
        set;
    }
    public List<FO_Administration__c> lstFOA {
        get;
        set;
    }
    public List<String> lstIndicator {
        get;
        set;
    }
    
    private ApexPages.StandardController controller;

    /**
    * Method Name: FOCDPRExtension
    * Description: Constructor
    **/
    public FOCDPRExtension(ApexPages.StandardController controllerParam) {
        
        sSuccessMessage = Label.FO_CDPR_Report_Alert_Msg;
        sShowMessage = Constants.FALSE_LOWER_CASE;
        controller = controllerParam;
        bShowResults = false;
        oCreateFOA = new FO_Administration__c();
        oResults = new List<FO_Administration__c> ();
        sAcctId = ApexPages.currentPage()
            .getParameters()
            .get(Constants.ID);
    }
    
    /**
    * Method Name: getOutcome
    * Description: This method queries outcome area corresponding to Field Office
    * Return type: List<SelectOption>
    * Parameter  : void
    **/
    public List<SelectOption> getOutcome() {
        List<SelectOption> lstOptions = new List<SelectOption> ();
        Schema.DescribeFieldResult oFieldResult = Global_Data__c.Outcome_Area__c.getDescribe();
        List<Schema.PicklistEntry> lstPLE = oFieldResult.getPicklistValues();
        lstOptions.add(new SelectOption(Constants.NONE, System.Label.Search_Ben_Controller_None));
        for(Schema.PicklistEntry oPE: lstPLE) {
            lstOptions.add(new SelectOption(oPE.getValue(),oPE.getLabel()));
        }
        return lstOptions;
    }

    /**
     * Method name  : doSearch
     * Description  : This method queries FO_Adminstration object coresponding to 
                      selected Outcome area.
     * Return Type  : void
     * Parameter    : void
     **/
    public void doSearch() {
        lstIndicator = new List<String> ();
        Set<String> setIndicator = new set<String> ();
        mapInd = new Map<String, List<FO_Administration__c>> ();
        List<FO_Administration__c> lstFOAdmin = new List<FO_Administration__c>
            ();
        List<FO_Administration__c> lstUniqueValues = new List <
            FO_Administration__c> ();
        try {
            lstUniqueValues = [SELECT Id, Indicator__c, Progress_Measure__c,
                Progress_Measure_Description__c FROM FO_Administration__c WHERE Outcome_Area__c = :
                sSelectOutcome AND Age_Group__c = : oCreateFOA.Age_Group__c AND Field_Office__c = :
                sAcctId ORDER BY Indicator__c, Progress_Measure__c
            ];
        } catch(System.QueryException oQe) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                oQe.getMessage());
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oQe, 'FOCDPRExtension',
                'doSearch', 'SFDC CI');
            return;
        }
        for(FO_Administration__c oAcc: lstUniqueValues) {
            setIndicator.add(oAcc.Indicator__c);
        }
        for(String sIndicator: setIndicator) {
            lstIndicator.add(sIndicator);
            for(FO_Administration__c oAcc: lstUniqueValues) {
                lstFOAdmin = new List<FO_Administration__c> ();
                if(sIndicator == oAcc.Indicator__c) {
                    if(mapInd.containsKey(sIndicator))
                        lstFOAdmin = mapInd.get(sIndicator);
                    lstFOAdmin.add(oAcc);
                    mapInd.put(sIndicator, lstFOAdmin);
                }
            }
        }
        bShowResults = true;
    }

    /**
     * Method name  : save
     * Description  : This method saves Progress Measures in FO_Adminstration object coresponding to 
                      selected Outcome area.
     * Return Type  : void
     * Parameter    : void
     **/
    public void save() {
        List<FO_Administration__c> lstFO = new List<FO_Administration__c> ();

        for(String sIndicator: mapInd.Keyset()) {
            lstFO.addAll(mapInd.get(sIndicator));
        }

        List<Database.SaveResult> lstUpdateResults = Database.update(lstFO, false);
        Map<Id, List<String>> mapIdToErrorMsg =
            ErrorLogUtility.logDMLError(lstUpdateResults, lstFO, 'FO_Administration__c',
                'FOCDPRExtension', 'save', 'SFDC CI', false);
        if(!mapIdToErrorMsg.isEmpty()) {
            for(Id foId: mapIdToErrorMsg.keySet()) {
                for(String sErrorMsg: mapIdToErrorMsg.get(foId)) {
                    Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                        sErrorMsg);
                    Apexpages.addmessage(oMsg);
                    return;
                }
            }
        }
        sShowMessage = Constants.TRUE_LOWER_CASE;
    }

}