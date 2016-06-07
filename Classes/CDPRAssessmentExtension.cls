/************************************************************************
*Name               : CDPRAssessmentExtension
*Description        : This is a controller class for CDPRAssessment page used for assessment 
                      of the Beneficiary which in turn leads to creation of a Beneficiary Assessment record.   
*Created By         : Sowmya Chamakura
*Created On         : 1/09/2015

********************************************************************************/
public with sharing class CDPRAssessmentExtension {
    
    
    public String sSuccessMessage{
        get;
        set;
    }
    public String sShowMessage {
        get;
        set;
    }
    public String sBeneficiaryName {
        get;
        set;
    }
    public String sIcpName {
        get;
        set;
    }
    public Beneficiary_Assessment__c oBeneficiaryAssessment {
        get;
        set;
    }
    public Id recordtypeId;
    public Id beneficiaryId{
        get;
        set;
    }
    public String sAge {
        get;
        set;
    }
    public Id fieldOfficeId;
    public String sAgeGroup {
        get;
        set;
    }
    public List<String> lstOutComeArea {
        get;
        set;
    }
    public set<String> setIndicators;
    public Account oAccount {
        get;
        set;
    }
    public List<FO_Administration__c> lstFoAdministration {
        get;
        set;
    }
    public Map<String, List<String>> mapIndicator {
        get;
        set;
    }
    public Map<String, List<Responses__c>> mapResponses {
        get;
        set;
    }
    Org_Level_Settings__c oOrgDefaults;
    public Map<String, List<Responses__c>> mapOutArea {
        get;
        set;
    }
    public String sUserType {
        get;
        set;
     }

    /*****************************************
    Method Name: CDPRAssessmentExtension
    Description: Constructor
    *******************************************/
    public CDPRAssessmentExtension(ApexPages.StandardController controller) {
        sSuccessMessage = Label.FO_CDPR_Report_Alert_Msg;
        sShowMessage = Constants.FALSE_LOWER_CASE;
        sUserType = UserInfo.getUserType();
        mapOutArea = new Map<String, List<Responses__c>>();
        oOrgDefaults = Org_Level_Settings__c.getOrgDefaults();
        beneficiaryId = ApexPages.currentPage()
            .getParameters()
            .get(Constants.CF_STRING + oOrgDefaults.Account_BenAssessment_Id__c +
                Constants.LOOKUP_ID_STRING);
        sBeneficiaryName = ApexPages.currentPage()
            .getParameters()
            .get(Constants.CF_STRING + oOrgDefaults.Account_BenAssessment_Id__c);
        recordtypeId = ApexPages.currentPage()
            .getParameters()
            .get(Constants.RECORD_TYPE);
        fetchFOAdminInfo();
        
    }

    /************************
    Method Name: fetchFOAdminInfo
    Description:  This method is used to fetch FO Administration information such as Outcome Areas, Indicators, Measures related to a beneficiary's Field Office.
    Return type: void              
    ************************************/   
    public void fetchFOAdminInfo() {
        try {
            if(beneficiaryId != NULL) {
                oAccount = [Select Id, Name, ICP__r.Name, ICP__r.Cluster__r.Territory__r.Field_Office__c,
                    Age_In_Months_And_Years__c, Cognitive_Age_Group__c from Account where id = :
                    beneficiaryId
                ];
                sIcpName = oAccount.ICP__r.Name;
                oBeneficiaryAssessment = new Beneficiary_Assessment__c();
                sAge = oAccount.Age_In_Months_And_Years__c;
                fieldOfficeId = oAccount.ICP__r.Cluster__r.Territory__r.Field_Office__c;
                sAgeGroup = oAccount.Cognitive_Age_Group__c;
            }
            if(fieldOfficeId != NULL || sAgeGroup != Constants.EMPTY_STRING) {
                lstFoAdministration = [SELECT Id, Name, RecordTypeId, Field_Office__c,
                    Global_Data__c, Progress_Measure__c, Progress_Measure_Description__c,
                    Age_Group__c, Outcome_Area__c, Indicator__c FROM FO_Administration__c where Field_Office__c = :
                    fieldOfficeId and Age_Group__c = : sAgeGroup order by Outcome_Area__c,Indicator_Order__c,
                    Indicator__c, Progress_Measure__c
                ];
            }
        } catch(System.QueryException oQe) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                oQe.getMessage());
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oQe, 'CDPRAssessmentExtension',
                'fetchFOAdminInfo', 'SFDC CI');
            return;
        }
        List<Responses__c> lstTempResponses = new List<Responses__c>();
        lstOutComeArea = new List<String>();
        set<String> setTempValues = new set<String>();
        setIndicators = new set<String>();
        mapIndicator = new Map<String, List<String>>();
        mapResponses = new Map<String, List<Responses__c>>();
        List<String> lstTempString;
        List<Responses__c> lstResponse = new List<Responses__c>();

        Responses__c oResponse;
        if(!lstFoAdministration.isEmpty()) {
            for(FO_Administration__c foadmin: lstFoAdministration) {
                oResponse = new Responses__c();
                oResponse.Outcome_Area__c = foadmin.Outcome_Area__c;
                oResponse.Indicator__c = foadmin.Indicator__c;
                oResponse.Progress_Measure__c = foadmin.Progress_Measure__c;
                oResponse.Progress_Measure_Description__c = foadmin.Progress_Measure_Description__c;

                lstResponse.add(oResponse);
                setTempValues.add(foadmin.Outcome_Area__c);
                setIndicators.add(foadmin.Indicator__c);
            }
            lstOutComeArea.addAll(setTempValues);

            for(String sTempValues: setTempValues) {
                for(FO_Administration__c oFoAdmin: lstFoAdministration) {
                    set<String> setTempString = new set<String>();
                    lstTempString = new List<String>();
                    if(sTempValues == oFoAdmin.Outcome_Area__c) {
                        if(mapIndicator.containsKey(sTempValues)) {
                            lstTempString = mapIndicator.get(sTempValues);
                        }
                        lstTempString.add(oFoAdmin.Indicator__c);
                        setTempString.addAll(lstTempString);
                        lstTempString = new List<String>();
                        lstTempString.addAll(setTempString);
                        mapIndicator.put(sTempValues, lstTempString);
                    }
                }
            }
        }
        if(!lstResponse.isEmpty()) {
            for(String sTemp: setTempValues) {
                for(Responses__c oResponseVal: lstResponse) {
                    lstTempResponses = new List<Responses__c>();
                    if(sTemp == oResponseVal.Outcome_Area__c) {
                        if(mapOutArea.containsKey(sTemp)) {
                            lstTempResponses = mapOutArea.get(sTemp);
                        }
                        lstTempResponses.add(oResponseVal);
                        mapOutArea.put(sTemp, lstTempResponses);
                    }
                }
            }
            for(String sIndicator: setIndicators) {
                for(Responses__c oResponseVal: lstResponse) {
                    if(sIndicator == oResponseVal.Indicator__c) {
                        List<Responses__c> lstTempResponse = new List<Responses__c>();
                        if(mapResponses.containsKey(sIndicator)) {
                            lstTempResponse = mapResponses.get(sIndicator);
                        }
                        lstTempResponse.add(oResponseVal);
                        mapResponses.put(sIndicator, lstTempResponse);
                    }
                }
            }
        }
    }

    /************************
    Method Name: Redirect
    Description:  This method is called on page load to redirect New Beneficiary Assessment button click based on the recordtype. If CDPR is the recordtype, VF page is opened else the standard Beneficiary assessment pages for respective layouts are opened. 
    Return type: pagereference               
    ************************************/

    public pagereference redirect() {
        String sUrl;
        ID BenficiaryRecordTypeID = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Assessment__c.SObjectType, Constants.CDPR_BA_RT_API_NAME);
        Schema.DescribeSObjectResult describeResult = Beneficiary_Assessment__c.sObjectType
            .getDescribe();
        string sObjType = describeResult.getkeyprefix();
        if(recordtypeId != BenficiaryRecordTypeID) {
            String shostname = ApexPages.currentPage()
                .getHeaders()
                .get(Constants.HOST);
                if(UserInfo.getUserType()!='PowerPartner'){
                     sUrl = Constants.HTTPS + shostname + Constants.BACKSLASH + sObjType +
                        Constants.CDPR_URL_TOKEN_1 + recordtypeId + Constants.CDPR_URL_TOKEN_2 +
                        oOrgDefaults.Account_BenAssessment_Id__c + Constants.LOOKUP_ID_STRING +
                        Constants.IS_EQUAL_TO + beneficiaryId + Constants.AMPERSAND + Constants.CF_STRING +
                        oOrgDefaults.Account_BenAssessment_Id__c + Constants.IS_EQUAL_TO +
                        sBeneficiaryName + Constants.AMPERSAND + Constants.RETURL + Constants.IS_EQUAL_TO + beneficiaryId;
                }
                else{
                     sUrl = Constants.HTTPS + shostname + Constants.BACKSLASH + Constants.ICPPORTAL + Constants.BACKSLASH +sObjType +
                        Constants.CDPR_URL_TOKEN_1 + recordtypeId + Constants.CDPR_URL_TOKEN_2 +
                        oOrgDefaults.Account_BenAssessment_Id__c + Constants.LOOKUP_ID_STRING +
                        Constants.IS_EQUAL_TO + beneficiaryId + Constants.AMPERSAND + Constants.CF_STRING +
                        oOrgDefaults.Account_BenAssessment_Id__c + Constants.IS_EQUAL_TO +
                        sBeneficiaryName + Constants.AMPERSAND + Constants.RETURL + Constants.IS_EQUAL_TO + Constants.ICPPORTALREtURL+ beneficiaryId;
                }
                
            pagereference pageref = new pagereference(sUrl);
            pageref.setredirect(true);
            return pageref;
        } else
            return null;
    }

    /************************
    Method Name: saveForm
    Description:  This method is used to Save the user input to create a New Beneficairy Assessment Record along with Response records created for each Measure which has Points. 
    Return type: pagereference               
    ************************************/
    public void saveForm() {
        if(fieldOfficeId == NULL) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                System.Label.No_Field_Office_associated_to_Beneficiary));
            return;
        }
        if(sAgeGroup == NULL || sAgeGroup == Constants.EMPTY_STRING) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                System.Label.No_Cognitive_Age_Group_associated_to_Beneficiary));
            return;
        }
        List<Responses__c> lstResponseData = new List<Responses__c>();
        List<Responses__c> lstResponseInsert = new List<Responses__c>();
        Decimal months;
        Map<String, Integer> mapResponseTotals = new Map<String, Integer>();
        Map<String, Integer> mapCountPoints = new Map<String, Integer>();
        Map<String, Decimal> mapTotals = new Map<String, Decimal>();
        Integer i = 0;
        Integer j = 0;
        for(String sIndicator: setIndicators) {
            i = 0;
            for(Responses__c oResponses: mapResponses.get(sIndicator)) {
                j = 0;
                if(oResponses.Points__c != null && oResponses.Points__c != '') {
                    j = Integer.valueOf(oResponses.Points__c);
                }
                i += j;
                lstResponseData.add(oResponses);
            }
            mapResponseTotals.put(sIndicator, i);

        }


        for(String sOutArea: mapOutArea.keyset()) {
            Decimal dTotal = 0.0;
            Integer iCountOfPoints = 0;

            for(Responses__c oResponseData: mapOutArea.get(sOutArea)) {

                if(String.isNotBlank(oResponseData.Points__c)) {
                    dTotal += Decimal.valueOf(oResponseData.Points__c);
                    iCountOfPoints++;
                }
            }
            mapCountPoints.put(sOutArea, iCountOfPoints);
            if(mapCountPoints.get(sOutArea) != NULL && mapCountPoints.get(sOutArea) !=
                0) {
                dTotal = Math.ceil(dTotal / mapCountPoints.get(sOutArea));
            }
            mapTotals.put(sOutArea, dTotal);
        }

        Beneficiary_Assessment__c oNewBeneficiaryAssessment = new Beneficiary_Assessment__c();
        oNewBeneficiaryAssessment.Name = Constants.CDPR_BEN_ASSESS_NAME_PREFIX +
            system.today()
            .format();
        oNewBeneficiaryAssessment.Beneficiary__c = oAccount.Id;
        oNewBeneficiaryAssessment.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Assessment__c.SObjectType, Constants.CDPR_BA_RT_API_NAME);
        oNewBeneficiaryAssessment.Assessment_Completion_Date__c =
            oBeneficiaryAssessment.Assessment_Completion_Date__c;

        if(mapTotals.containsKey(Constants.PHYSICAL_OUTCOME_AREA) && mapTotals.get(
                Constants.PHYSICAL_OUTCOME_AREA) != NULL) {
            PointsStatusList__c ps = PointsStatusList__c.getValues(String.valueOf(
                mapTotals.get(Constants.PHYSICAL_OUTCOME_AREA)));
            if(ps != NULL) {
                oNewBeneficiaryAssessment.Physical_Outcome_Score__c = ps.Status__c;
            }
        }
        if(mapTotals.containsKey(Constants.SPIRITUAL_OUTCOME_AREA) && mapTotals.get(
                Constants.SPIRITUAL_OUTCOME_AREA) != NULL) {
            PointsStatusList__c ps = PointsStatusList__c.getValues(String.valueOf(
                mapTotals.get(Constants.SPIRITUAL_OUTCOME_AREA)));
            if(ps != NULL) {
                oNewBeneficiaryAssessment.Spiritual_Outcome_Score__c = ps.Status__c;
            }
        }
        if(mapTotals.containsKey(Constants.COGNITIVE_OUTCOME_AREA) && mapTotals.get(
                Constants.COGNITIVE_OUTCOME_AREA) != NULL) {
            PointsStatusList__c ps = PointsStatusList__c.getValues(String.valueOf(
                mapTotals.get(Constants.COGNITIVE_OUTCOME_AREA)));
            if(ps != NULL) {
                oNewBeneficiaryAssessment.Cognitive_Outcome_Score__c = ps.Status__c;
            }
        }
        if(mapTotals.containsKey(Constants.SOCIO_EMOTIONAL_OUTCOME_AREA) &&
            mapTotals.get(Constants.SOCIO_EMOTIONAL_OUTCOME_AREA) != NULL) {
            PointsStatusList__c ps = PointsStatusList__c.getValues(String.valueOf(
                mapTotals.get(Constants.SOCIO_EMOTIONAL_OUTCOME_AREA)));
            if(ps != NULL) {
                oNewBeneficiaryAssessment.Socio_emotional_Outcome_Score__c = ps.Status__c;
            }
        }
        try {
            insert oNewBeneficiaryAssessment;
        } catch(DMLException oExp) {
            ErrorLogUtility.logGeneralError(oExp, 'CDPRAssessmentExtension',
                'saveForm', 'SFDC CI');
            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,
                oExp.getdmlMessage(0));
            ApexPages.addMessage(oMsg);
            return;
        }
        for(Responses__c oResponseData: lstResponseData) {
            Responses__c oResponse = new Responses__c();
            if(oResponseData.Points__c != null && oResponseData.Points__c != '') {
                PointsStatusList__c ps = PointsStatusList__c.getValues(String.valueOf(
                    oResponseData.Points__c));
                oResponse.CDPR_ID__c = oNewBeneficiaryAssessment.Id;
                oResponse.Indicator__c = oResponseData.Indicator__c;
                oResponse.Outcome_Area__c = oResponseData.Outcome_Area__c;
                oResponse.Points__c = oResponseData.Points__c;
                oResponse.Status__c = ps.Status__c;
                oResponse.Progress_Measure__c = oResponseData.Progress_Measure__c;
                oResponse.Progress_Measure_Description__c = oResponseData.Progress_Measure_Description__c;
                oResponse.Comments__c = oResponseData.Comments__c;
                lstResponseInsert.add(oResponse);
            }
        }

        List<Database.SaveResult> lstInsertResults = Database.insert(
            lstResponseInsert, false);
        Map<Id, List<String>> mapIdToErrorMsg =
            ErrorLogUtility.logDMLError(lstInsertResults, lstResponseInsert,
                'Response__c',
                'CDPRAssessmentExtension', 'saveForm', 'SFDC CI', false);
        if(!mapIdToErrorMsg.isEmpty()) {
            for(Id respId: mapIdToErrorMsg.keySet()) {
                for(String sErrorMsg: mapIdToErrorMsg.get(respId)) {
                    Apexpages.Message oMsg = new Apexpages.Message(ApexPages.Severity.ERROR,
                        sErrorMsg);
                    Apexpages.addmessage(oMsg);
                }
            }
            return;
        }
        
        sShowMessage = Constants.TRUE_LOWER_CASE;
    }

    /************************
    Method Name: cancel
    Description:  This method is called on click of Cancel button on the VF page to redirect back to the Beneficiary Assessment Record.
    Return type: pagereference               
    ************************************/
    public pageReference cancel() {
        if(UserInfo.getUserType()!='PowerPartner'){
        return new pagereference(Constants.BACKSLASH + beneficiaryId);
        }
        else{
            return new pagereference(Constants.BACKSLASH +  Constants.ICPPORTAL+ Constants.BACKSLASH + beneficiaryId);
        }
    }
}