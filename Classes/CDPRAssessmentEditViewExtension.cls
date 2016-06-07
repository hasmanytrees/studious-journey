/************************************************************************
*Name               : CDPRAssessmentEditViewExtension
*Description        : This is oFOA controller class for CDPRAssessmentEditViewPage used for the Edit/View assessment 
                      of the Beneficiary which in turn leads to creation of oFOA Beneficiary Assessment record.   
*Created By         : Himanshu Raichandani
*Created On         : 1/19/2015

********************************************************************************/
public with sharing class CDPRAssessmentEditViewExtension {
    public String sBenefId{
        get;
        set;
    }
    public String sSuccessMessage{
        get;
        set;
    }
    public String sShowMessage {
        get;
        set;
    }
    public Beneficiary_Assessment__c oBeneficiaryAssessment {
        get;
        set;
    }
    public List<Responses__c> lstExistingResponse {
        get;
        set;
    }
    public ID cdprRtId;
    public Account oAccnt {
        get;
        set;
    }
    public List<FO_Administration__c> lstFOAdmin {
        get;
        set;
    }
    public List<String> lstOutcomeArea {
        get;
        set;
    }
    public set<String> setIndicator;
    public String sViewEditButton;
    public Map<String, List<String>> mapIndicator {
        get;
        set;
    }
    public Map<String, List<Responses__c>> mapResponse {
        get;
        set;
    }
    public Map<String, List<Responses__c>> mapOutArea {
        get;
        set;
    }
    public String sUserType {
        get;
        set;
    }
    public String sPowerPartner {
        get;
        set;
    }
    public Boolean bShowComponents{
        get;
        set;
    }
    set<String> setOutcomeArea = new set<String>();
    List<Responses__c> lstResponse = new List<Responses__c>();

    /**
     * Method Name  : CDPRAssessmentEditViewExtension
     * Description  : Constructor
     * Return Type  : NA
     * Parameter    : ApexPages.StandardController
     **/
    public CDPRAssessmentEditViewExtension(ApexPages.StandardController controller) {
        
        bShowComponents = true;
        Schema.DescribeSObjectResult oSObject = Schema.sObjectType.Beneficiary_Assessment__c;
        if(!oSObject.isUpdateable()){
            bShowComponents = false;
        }
        sSuccessMessage = Label.FO_CDPR_Report_Alert_Msg;
        sShowMessage = Constants.FALSE_LOWER_CASE;
        sUserType = UserInfo.getUserType();
        sPowerPartner = Constants.POWERPARTNER;     
        mapOutArea = new Map<String, List<Responses__c>>();
        Map<String, String> mapParameters = ApexPages.currentPage()
            .getparameters();
        if(mapParameters.containskey(Constants.RETURL)) {
            sViewEditButton = System.Label.Edit;
        } else {
            sViewEditButton = System.Label.View;
        }
        cdprRtId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Assessment__c.SObjectType,
            Constants.CDPR_BA_RT_API_NAME);
        oBeneficiaryAssessment = (Beneficiary_Assessment__c) controller.getRecord();
        lstExistingResponse = new List<Responses__c>();
        if(oBeneficiaryAssessment.RecordTypeId == cdprRtId) {
            fetchResponses();
        }
    }

    /**
    * Method Name  : fetchResponses
    * Description  : This method is used to fetch existing responses for the Beneficiary Assessment record to be edited
             along with FO Administration information such as Outcome Areas, Indicators, Measures related to oFOA beneficiary'sOutArea Field Office.
    * Return type  : void         
    * Parameter    : void
    **/

    public void fetchResponses() {
        try{
            lstExistingResponse = [Select CDPR_ID__c, Indicator__c, Points__c,
                Progress_Measure__c, Progress_Measure_Description__c, Comments__c,
                Outcome_Area__c from Responses__c where CDPR_ID__c = :
                oBeneficiaryAssessment.Id
            ];
            oAccnt = [Select Id, Name, ICP__r.Name, ICP__r.Cluster__r.Territory__r.Field_Office__c,
                Age_In_Months_And_Years__c, Cognitive_Age_Group__c from Account where id = :
                oBeneficiaryAssessment.Beneficiary__c
            ];
            lstFOAdmin = [SELECT Id, Name, RecordTypeId, Field_Office__c, Global_Data__c,
                Progress_Measure__c, Progress_Measure_Description__c, Age_Group__c,
                Outcome_Area__c, Indicator__c FROM FO_Administration__c where Field_Office__c = :
                oAccnt.ICP__r.Cluster__r.Territory__r.Field_Office__c and Age_Group__c = :
                oAccnt.Cognitive_Age_Group__c order by Outcome_Area__c,Indicator_Order__c, Indicator__c,
                Progress_Measure__c
            ];
        }catch(System.QueryException oQe) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                oQe.getMessage());
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oQe, 'CDPRAssessmentEditViewExtension', 
                    'fetchResponses', 'SFDC CI');
            return;
        }
        lstOutcomeArea = new List<String>();
        setIndicator = new set<String>();
        mapIndicator = new Map<String, List<String>>();
        mapResponse = new Map<String, List<Responses__c>>();
        List<String> lstMatchedOutcomeArea;
        List<Responses__c> lstNewResponses = new List<Responses__c>();

        Responses__c oResponse;
        for(FO_Administration__c oFOAdmin: lstFOAdmin) {
            oResponse = new Responses__c();
            oResponse.Outcome_Area__c = oFOAdmin.Outcome_Area__c;
            oResponse.Indicator__c = oFOAdmin.Indicator__c;
            oResponse.Progress_Measure__c = oFOAdmin.Progress_Measure__c;
            oResponse.Progress_Measure_Description__c = oFOAdmin.Progress_Measure_Description__c;
            lstNewResponses.add(oResponse);
            setOutcomeArea.add(oFOAdmin.Outcome_Area__c);
            setIndicator.add(oFOAdmin.Indicator__c);
        }
        lstOutcomeArea.addAll(setOutcomeArea);

        for(String sOutArea: setOutcomeArea) {
            for(FO_Administration__c oFOA: lstFOAdmin) {
                set<String> setMatchedOutArea = new set<String>();
                lstMatchedOutcomeArea = new List<String>();
                if(sOutArea == oFOA.Outcome_Area__c) {
                    if(mapIndicator.containsKey(sOutArea)) {
                        lstMatchedOutcomeArea = mapIndicator.get(sOutArea);
                    }
                    lstMatchedOutcomeArea.add(oFOA.Indicator__c);
                    setMatchedOutArea.addAll(lstMatchedOutcomeArea);
                    lstMatchedOutcomeArea = new List<String>();
                    lstMatchedOutcomeArea.addAll(setMatchedOutArea);
                    mapIndicator.put(sOutArea, lstMatchedOutcomeArea);
                }
            }
        }

        for(String sIndicator: setIndicator) {
            for(Responses__c oResp: lstNewResponses) {
                if(sIndicator == oResp.Indicator__c) {
                    List<Responses__c> lstRespRecords = new List<Responses__c>();
                    if(mapResponse.containsKey(sIndicator)) {
                        lstRespRecords = mapResponse.get(sIndicator);
                    }
                    lstRespRecords.add(oResp);
                    mapResponse.put(sIndicator, lstRespRecords);
                }
            }

            for(Responses__c oResp: lstExistingResponse) {
                if(sIndicator == oResp.Indicator__c) {
                    List<Responses__c> lstRespRecords = new List<Responses__c>();
                    if(mapResponse.containsKey(sIndicator)) {
                        lstRespRecords = mapResponse.get(sIndicator);
                    }
                    Integer iIndex = -1;
                    for(Integer i = 0; i<lstRespRecords.size(); i++) {
                        if(lstRespRecords[i].Progress_Measure__c == oResp.Progress_Measure__c) {
                            iIndex = i;
                            break;
                        }
                    }
                    if(iIndex != -1) {
                        lstRespRecords[iIndex] = oResp;
                        mapResponse.put(sIndicator, lstRespRecords);
                    }
                }
            }
        }
    }

    /**
    * Method Name  : saveForm
    * Description  : This method is used to Save the user input to update the Beneficairy Assessment Record
             along with updating Response records for each Measure which has Points. 
    * Return type  : void        
    * Parameter    : void
    **/
    public void saveForm() {
        List<Responses__c> lstResponseData = new List<Responses__c>();
        List<Responses__c> lstResponseInsert = new List<Responses__c>();
        Map<String, Integer> mapResponseTotals = new Map<String, Integer>();
        Map<String, Integer> mapCountPoints = new Map<String, Integer>();
        Map<String, Decimal> mapTotals = new Map<String, Decimal>();
        Integer i = 0;
        Integer j = 0;
        for(String sOutArea: setIndicator) {
            i = 0;
            for(Responses__c oResp: mapResponse.get(sOutArea)) {
                j = 0;
                if(oResp.Points__c != null && oResp.Points__c != '') {
                    j = Integer.valueOf(oResp.Points__c);
                }
                i += j;
                lstResponseData.add(oResp);
            }
            mapResponseTotals.put(sOutArea, i);
        }

        for(String sOutArea: setOutcomeArea) {
            for(Responses__c oResp: lstResponseData) {
                lstResponse = new List<Responses__c>();
                if(sOutArea == oResp.Outcome_Area__c) {
                    if(mapOutArea.containsKey(sOutArea)) {
                        lstResponse = mapOutArea.get(sOutArea);
                    }
                    lstResponse.add(oResp);
                    mapOutArea.put(sOutArea, lstResponse);
                }
            }
        }


        for(String sOutcomeArea: mapOutArea.keyset()) {
            Decimal dTotal = 0.0;
            Integer iCountOfPoints = 0;

        for(Responses__c oResponse: mapOutArea.get(sOutcomeArea)) {

            if(String.isNotBlank(oResponse.Points__c)) {
                dTotal += Decimal.valueOf(oResponse.Points__c);
                iCountOfPoints++;
            }
        }
        mapCountPoints.put(sOutcomeArea, iCountOfPoints);
        if(mapCountPoints.get(sOutcomeArea) != NULL && mapCountPoints.get(
                sOutcomeArea) != 0) {
            dTotal = Math.ceil(dTotal / mapCountPoints.get(sOutcomeArea));
        }
        mapTotals.put(sOutcomeArea, dTotal);
    }

        if(mapTotals.containsKey(Constants.PHYSICAL_OUTCOME_AREA) && mapTotals.get(
                Constants.PHYSICAL_OUTCOME_AREA) != NULL) {
            PointsStatusList__c oPointStatus = PointsStatusList__c.getValues(String.valueOf(
                mapTotals.get(Constants.PHYSICAL_OUTCOME_AREA)));
            if(oPointStatus != NULL) {
                oBeneficiaryAssessment.Physical_Outcome_Score__c = oPointStatus.Status__c;
            }
        }
        if(mapTotals.containsKey(Constants.SPIRITUAL_OUTCOME_AREA) && mapTotals.get(
                Constants.SPIRITUAL_OUTCOME_AREA) != NULL) {
            PointsStatusList__c oPointStatus = PointsStatusList__c.getValues(String.valueOf(
                mapTotals.get(Constants.SPIRITUAL_OUTCOME_AREA)));
            if(oPointStatus != NULL) {
                oBeneficiaryAssessment.Spiritual_Outcome_Score__c = oPointStatus.Status__c;
            }
        }
        if(mapTotals.containsKey(Constants.COGNITIVE_OUTCOME_AREA) && mapTotals.get(
                Constants.COGNITIVE_OUTCOME_AREA) != NULL) {
            PointsStatusList__c oPointStatus = PointsStatusList__c.getValues(String.valueOf(
                mapTotals.get(Constants.COGNITIVE_OUTCOME_AREA)));
            if(oPointStatus != NULL) {
                oBeneficiaryAssessment.Cognitive_Outcome_Score__c = oPointStatus.Status__c;
            }
        }
        if(mapTotals.containsKey(Constants.SOCIO_EMOTIONAL_OUTCOME_AREA) &&
            mapTotals.get(Constants.SOCIO_EMOTIONAL_OUTCOME_AREA) != NULL) {
            PointsStatusList__c oPointStatus = PointsStatusList__c.getValues(String.valueOf(
                mapTotals.get(Constants.SOCIO_EMOTIONAL_OUTCOME_AREA)));
            if(oPointStatus != NULL) {
                oBeneficiaryAssessment.Socio_emotional_Outcome_Score__c = oPointStatus.Status__c;
            }
        }
        try{
            update oBeneficiaryAssessment;
        }catch(DMLException oExp){
            ErrorLogUtility.logGeneralError(oExp, 'CDPRAssessmentEditViewExtension', 
            'saveForm', 'SFDC CI');
            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR, oExp.getdmlMessage(0));
            ApexPages.addMessage(oMsg);
            return;
        }
        for(Responses__c oResp: lstResponseData) {
            Responses__c oResponse = new Responses__c();
            if(oResp.Points__c != null && oResp.Points__c != '') {
                PointsStatusList__c oPointStatus = PointsStatusList__c.getValues(String.valueOf(
                    oResp.Points__c));
                oResponse.CDPR_ID__c = oBeneficiaryAssessment.Id;
                oResponse.Indicator__c = oResp.Indicator__c;
                oResponse.Outcome_Area__c = oResp.Outcome_Area__c;
                oResponse.Points__c = oResp.Points__c;
                oResponse.Status__c = oPointStatus.Status__c;
                oResponse.Progress_Measure__c = oResp.Progress_Measure__c;
                oResponse.Progress_Measure_Description__c = oResp.Progress_Measure_Description__c;
                oResponse.Comments__c = oResp.Comments__c;
                lstResponseInsert.add(oResponse);
            }
        }

        
        List<Database.UpsertResult> lstUpsertResults = Database.upsert(lstResponseInsert,false);
        Map<Id, List<String>> mapIdToErrorMsg = 
        ErrorLogUtility.logDMLError(lstUpsertResults, lstResponseInsert, 'Response__c',
            'CDPRAssessmentEditViewExtension', 'saveForm', 'SFDC CI', false);
        if(!mapIdToErrorMsg.isEmpty()){ 
            for(Id respId: mapIdToErrorMsg.keySet()){
                for(String sErrorMsg: mapIdToErrorMsg.get(respId)){
                    Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,sErrorMsg);
                    Apexpages.addmessage(oMsg);
                }
            }
            return;
        }
        sShowMessage = Constants.TRUE_LOWER_CASE;
        sBenefId = oBeneficiaryAssessment.beneficiary__c;
    }

    /**
    * Method Name  : redirect
    * Description  : This method is called on page load to redirect Edit or View Beneficiary Assessment
             button click based on the recordtype. If CDPR is the recordtype, Edit/View VF page is opened else
             the standard Beneficiary assessment pages for respective layouts are opened. 
    * Return type  : pageReference        
    * Parameter    : void
    **/
    public pagereference redirect() {
        if(oBeneficiaryAssessment.RecordTypeId != cdprRtId) {
            if(sViewEditButton == System.Label.Edit) {

            /**    return new PageReference(Constants.BACKSLASH + oBeneficiaryAssessment.Id  +
                    Constants.CDPR_URL_TOKEN_3 + Constants.AMPERSAND + Constants.RETURL + 
                    Constants.IS_EQUAL_TO +Constants.BACKSLASH+
                    Constants.ICPPORTAL+Constants.BACKSLASH+oBeneficiaryAssessment.Id+
                    Constants.CDPR_URL_TOKEN_3); **/
                    
                return new PageReference(Constants.BACKSLASH +oBeneficiaryAssessment.Id   +
                    Constants.CDPR_URL_TOKEN_3 + Constants.AMPERSAND + Constants.RETURL + 
                    Constants.IS_EQUAL_TO + Constants.BACKSLASH+oBeneficiaryAssessment.beneficiary__c);

            } else {
                return new PageReference(Constants.BACKSLASH + oBeneficiaryAssessment.Id +
                    Constants.NO_OVERRIDE_1);
            }
        }

        return null;
    }

    /**
     * Method Name  : cancel
     * Description  : This method is called on click of Cancel button on the VisualForce page to redirect back to the Beneficiary Assessment Record.
     * Return type  : pageReference        
     * Parameter    : void
     **/
    public pageReference cancel() {
        return new pagereference(Constants.BACKSLASH + oBeneficiaryAssessment.beneficiary__c);
    }

}