/******************************************************************************************************
Class Name         : MassUpdateController
Description        : This is a controller class which implements the Bulk Update functionality
                     for a couple of objects.
Created By         : Sunayana Tekalkote
Created On         : 07-Jan-2015 
 ******************************************************************************************************/


public with sharing class MassUpdateController {

    public FilterListHandler oFilterListHandler {
        get;
        set;
    }
    public Account oIcpAccount {
        get;
        set;
    }
    public boolean bIsSuccess {
        get;
        set;
    }
    public Custom_Search_Setting__c oSearchSetting;
    List<String> lstFieldAPINames = new List<String>();
    List<String> lstFieldLabels = new List<String>();
    public list<AccountWrapper> lstAccntWrapper {
        get;
        set;
    }
    public Beneficiary_Lifecycle_Event__c oBledisplay {
        get;
        set;
    }
    public Medical_Incidents__c oMedIncident {
        get;
        set;
    }
    public Immunization__c oImmunization {
        get;
        set;
    }
    public Beneficiary_Assessment__c oBenefAssessment {
        get;
        set;
    }
    public List<sObject> lstSObjectResult {
        get;
        set;
    }
    public set<String> setFieldsToDisplay {
        get;
        set;
    }
    public list<String> lstFieldsToDisplay {
        get;
        set;
    }
    public String sObjectType {
        get;
        set;
    }
    public List<SelectOption> lstObjectType {
        get;
        set;
    }
    public Boolean bIsUpdateList {
        get;
        set;
    }
    public Boolean bIsSearchPage {
        get;
        set;
    }
    public Boolean bIsSearchResult {
        get;
        set;
    }
    public Boolean bIsErrorFlag {
        get;
        set;
    }
    public String sObjName {
        get;
        set;
    }
    public List<String> lstField {
        get;
        set;
    }
    public SObject oObjectName {
        get;
        set;
    }
    public SObject oNewObjectName;
    public Map<String, String> mapLabel {
        get;
        set;
    }
    public Map<String, Schema.SObjectField> mapFields = new Map<String,
        Schema.SObjectField>();
    public Map<Schema.SObjectField, String> mapFieldToAPIName = new Map <
        Schema.SObjectField, String>();
    public Map<String, Mass_Update__c> mapMassUpdate = Mass_Update__c.getAll();
    public Schema.sObjectType oSObj {
        get;
        set;
    }
    public Map<String, String> mapIdToBeneficiaryName;
    public String sShowMessage {
        get;
        set;
    }
    public String sSuccessMsg {
        get;
        set;
    }
    public String sUserType {
        get;
        set;
    }
    Set<String> setBenefId = new Set<String>();
    private Boolean bSuccessScen = true;
    public String sPowerPartner {
        get;
        set;
    }

    /**
     * Method name  : MassUpdateController
     * Description  : This is a constructor for the class MassUpdateController that initialises all the variables
     * Return Type  : NA
     * Parameter    : void
     **/
    public MassUpdateController() {
        oIcpAccount = new Account();
        oBledisplay = new Beneficiary_Lifecycle_Event__c();
        oMedIncident = new Medical_Incidents__c();
        oImmunization = new Immunization__c();
        oBenefAssessment = new Beneficiary_Assessment__c();
        lstAccntWrapper = new List<AccountWrapper>();
        lstObjectType = new List<SelectOption>();
        bIsSuccess = false;
        bIsErrorFlag = false;
        sShowMessage = Constants.FALSE_LOWER_CASE;
        sSuccessMsg = System.Label.Mass_Update_Success_Message;
        oSearchSetting = new Custom_Search_Setting__c();
        bIsUpdateList = false;
        bIsSearchPage = false;
        bIsSearchResult = false;
        sUserType = UserInfo.getUserType();
        setFieldsToDisplay = new set<String>();
        sPowerPartner = Constants.POWERPARTNER;

        mapIdToBeneficiaryName = new Map<String, String>();

        oFilterListHandler = new FilterListHandler();
        oFilterListHandler.mapValueType = new Map<String, STring>();

        setvalueTypeMap();

        lstObjectType.add(new SelectOption(Constants.EMPTY_STRING, System.Label.Search_Ben_Controller_None));
        List<String> lstObjectTypeValue = new List<String>();
        List<String> lstObjectTypeLabel = new List<String>();
        if(sUserType == Constants.POWERPARTNER) {
            User oUser = [Select Id, AccountId from user where id = : UserInfo.getUserId()];
            oIcpAccount.ICP__c = oUser.AccountId;
            lstObjectTypeValue = System.label.Mass_Update_Records_Mass_Update_Values_For_Partners
                .split(Constants.COMMA);
            lstObjectTypeLabel = System.label.Mass_Update_Records_Mass_Update_For_Partners
                .split(Constants.COMMA);
        } else {
            lstObjectTypeValue = System.label.Mass_Update_Records_Mass_Update_Values.split(
                Constants.COMMA);
            lstObjectTypeLabel = System.label.Mass_Update_Records_Mass_Update.split(
                Constants.COMMA);
        }

        for(Integer i = 0; i<lstObjectTypeLabel.size(); i++) {
            lstObjectType.add(new SelectOption(lstObjectTypeValue.get(i),
                lstObjectTypeLabel.get(i)));
        }
    }

    /**
    * Method name  : fetchUpdateFields
    * Description  : Method for updating Association list under beneficiaries.This method will be invoked on button click named Update List.
                     This will add CIV Needs Association for newly selected beneficiaries as well as delete association for unchecked beneficiaries.
    * Return Type  : void
    * Parameter    : void
    **/
    public void fetchUpdateFields() {
        bIsSearchResult = false;
        sObjName = mapMassUpdate.get(sObjectType)
            .Object__c;

        if(sObjName == Constants.Beneficiary_Lifecycle_Event_API_Name)
            oBledisplay.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
                Beneficiary_Lifecycle_Event__c.SObjectType, sObjectType);
        mapLabel = new Map<String, String>();
        bIsSearchPage = true;

        lstField = new List<String>();
        List<String> lstTemp = mapMassUpdate.get(sObjectType)
            .Fields__c.split(';');
        lstField.addAll(lstTemp);

        if(lstField.size()> 0)
            bIsUpdateList = true;

        Schema.SObjectType oTargetType = Schema.getGlobalDescribe()
            .get(sObjName);
        oObjectName = oTargetType.newSObject();

        SObjectType oObjType = Schema.getGlobalDescribe()
            .get(sObjName);
        mapFields = oObjType.getDescribe()
            .fields.getMap();

        for(String sField: lstField) {
            mapLabel.put(sField, mapFields.get(sField)
                .getDescribe()
                .getLabel());
        }
    }

    /**
    * Method name  : setvalueTypeMap
    * Description  : This method populates data structures which stores informationof all the fields which
                     are shown to User. This information consistes of labels, API names & data type of fields displayed on UI.
    * Return Type  : void
    * Parameter    : void
    **/
    public void setvalueTypeMap() {
        lstFieldsToDisplay = new list<String>();
        bIsSearchResult = false;

        List<Custom_Search_Setting__c> lstSetting = [select Name, Object__c,
            Fields_to_Filter__c, Numeric_Fields_to_Filter__c, Result_Column_Fields__c,
            Fields_to_Filter_Label__c, Result_Column_Fields_Label__c from Custom_Search_Setting__c where Name = :
            Constants.ACCOUNT_BENEFICIARY1
        ];

        if(!lstSetting.isEmpty())
            oSearchSetting = lstSetting[0];

        if(String.isNotBlank(oSearchSetting.Fields_to_Filter__c))
            lstFieldAPINames = oSearchSetting.Fields_to_Filter__c.split(Constants.COMMA);

        for(String sField: lstFieldAPINames)
            oFilterListHandler.mapValueType.put(sField, Constants.QUOTE_NEED);

        if(String.isNotBlank(oSearchSetting.Numeric_Fields_to_Filter__c))
            lstFieldAPINames.addAll(oSearchSetting.Numeric_Fields_to_Filter__c.split(
                Constants.COMMA));

        if(String.isNotBlank(oSearchSetting.Fields_to_Filter_Label__c))
        //lstFieldLabels = oSearchSetting.Fields_to_Filter_Label__c.split(Constants.COMMA);
            lstFieldLabels = System.label.Mass_Update_Records_Fields_To_Filter_Label.split(
            Constants.COMMA);

        if(String.isNotBlank(oSearchSetting.Result_Column_Fields__c))
            oFilterListHandler.lstFields.add(new SelectOption(Constants.NONE,
                System.Label.Search_Ben_Controller_None));

        setFieldsToDisplay.addAll(oSearchSetting.Result_Column_Fields__c.split(
            Constants.COMMA));
        setFieldsToDisplay.addAll(lstFieldAPINames);
        lstFieldsToDisplay.addAll(setFieldsToDisplay);

        for(Integer i = 0; i<lstFieldAPINames.size(); i++) {
            oFilterListHandler.lstFields.add(new selectOption(lstFieldAPINames[i],
                lstFieldLabels[i]));
        }
    }

    Public List<AccountWrapper> getAccWrapSets() {
        return lstAccntWrapper;
    }

    /**
     * Method name  : bensearch
     * Description  : As per the filter provided from UI, this method queries all Beneficiaries satisfying the criteria provided.
     * Return Type  : void
     * Parameter    : void
     **/

    public PageReference bensearch() {
        lstSObjectResult = new List<sObject>();
        lstAccntWrapper = new List<AccountWrapper>();
        bIsSearchResult = true;
        String sQuery =
            'Select IsPersonAccount, Beneficiary_Confession_Of_Faith_Date__c, Weight_Kg__c, Height_Cm__c,';

        for(String sField: setFieldsToDisplay)
            sQuery = sQuery + String.escapeSingleQuotes(sField) + Constants.COMMA;


        sQuery = sQuery +
            'Id From Account Where Beneficiary_Status__c= \'Active\'  and ICP__c =' +
            '\'' + oIcpAccount.ICP__c + '\' AND';

        if(oFilterListHandler.oCompControllerRef != null) {
            oFilterListHandler.oCompControllerRef.formQuery();
            sQuery += oFilterListHandler.oCompControllerRef.sQuery;
        }

        sQuery +=
            ' Id!=null AND RecordType.Name LIKE \'% Beneficiary%\' Order By Local_Beneficiary_ID__c Limit 500';


        //   sQuery = sQuery + 'ID from Account LIMIT 1000' ;
        try {
            lstSObjectResult = Database.query(sQuery);
        } catch(QueryException oQEx) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.Account_Search);
            ApexPages.addMessage(oMsg);
            ErrorLogUtility.logGeneralError(oQEx, 'MassUpdateController', 'bensearch',
                'SFDC CI');
            return null;
        }

        oSObj = Schema.getGlobalDescribe()
            .get(Constants.ACCOUNT_API_NAME)
            .getDescribe()
            .getSObjectType();

        Integer iPage = 0;
        Integer iOffsetNum = 500;

        for(sObject oSObject: lstSObjectResult) {
            AccountWrapper oAcntWrap = new AccountWrapper();
            oAcntWrap.bIsChecked = false;
            oAcntWrap.oAccount = (Account) oSObject;
            lstAccntWrapper.add(oAcntWrap);
        }

        return null;
    }

    /**
    * Method name  : createUpdateRecords
    * Description  : Based upon the object type & record type of record displayed on UI, data is created or updated.
                     This method also populates error in case there is some erroneous data populated by User on UI.
    * Return Type  : PageReference
    * Parameter    : void
    **/
    public PageReference createUpdateRecords() {
        Database.SaveResult[] oSRList;
        String sOperation = mapMassUpdate.get(sObjectType)
            .Operations__c;
        List<Beneficiary_Lifecycle_Event__c> lstBLE = new List <
            Beneficiary_Lifecycle_Event__c>();
        List<Account> lstAcnt = new List<Account>();
        List<Immunization__c> lstImmu = new List<Immunization__c>();
        List<Medical_Incidents__c> lstMed = new List<Medical_Incidents__c>();
        List<Beneficiary_Assessment__c> lstBenefAssess = new List <
            Beneficiary_Assessment__c>();
        Boolean bCheckSelect = false;

        for(AccountWrapper oAcntWrap: lstAccntWrapper) {
            if(oAcntWrap.bIsChecked == true) {
                bCheckSelect = true;
                if(!mapIdToBeneficiaryName.containsKey(oAcntWrap.oAccount.Id)) {
                    mapIdToBeneficiaryName.put(oAcntWrap.oAccount.Id, oAcntWrap.oAccount.Name);
                }
            }
        }

        if(bCheckSelect == false) {
            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,
                System.Label.Error_Beneficiary_Selection);
            ApexPages.addMessage(oMsg);
            return null;
        }


        if(sObjectType == Constants.BLE_PLANNED_EXIT_RT_API_NAME || sObjectType ==
            Constants.BLE_TRANSFER_RT_API_NAME || sObjectType == Constants.BLE_TRANSITION_RT_API_NAME ||
            sObjectType == Constants.BLE_UNPLANNED_EXIT_RT_API_NAME) {
            if(sObjectType == Constants.BLE_TRANSITION_RT_API_NAME && String.isEmpty(
                    oBledisplay.Transition_Type__c)) {
                ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,
                    System.Label.Mass_Update_Error_For_Transition);
                ApexPages.addMessage(oMsg);
                return null;
            }
            if(sObjectType == Constants.BLE_UNPLANNED_EXIT_RT_API_NAME && (String.isEmpty(
                        oBledisplay.Reason_For_Request__c) || oBledisplay.Last_Attended_Date__c ==
                    null)) {
                ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,
                    System.Label.Mass_Update_Error_For_Unplanned);
                ApexPages.addMessage(oMsg);
                return null;
            }
            if(sObjectType == Constants.BLE_TRANSFER_RT_API_NAME) {
                bIsErrorFlag = validateTransferRecordForInsert(lstAccntWrapper,
                    oBledisplay);
                if(bIsErrorFlag == true) {
                    return null;
                }
            }
            for(AccountWrapper oAcntWrap: lstAccntWrapper) {
                if(oAcntWrap.bIsChecked == true) {
                    Schema.SObjectType oTargetType = Schema.getGlobalDescribe()
                        .get(sObjName);
                    oNewObjectName = oTargetType.newSObject();
                    Beneficiary_Lifecycle_Event__c oBLE = new Beneficiary_Lifecycle_Event__c();
                    oBLE.Beneficiary__c = oAcntWrap.oAccount.Id;
                    if(sObjectType == Constants.BLE_TRANSFER_RT_API_NAME) {
                        oBLE.New_Local_Beneficiary_Number__c = oAcntWrap.sNewLocalBeneficiaryNumber;
                    }
                    oBLE.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
                        Beneficiary_Lifecycle_Event__c.SObjectType, sObjectType);
                    oBLE.Reason_For_Request__c = oBledisplay.Reason_For_Request__c;
                    oBLE.Other_Reasons_For_Request__c = oBledisplay.Other_Reasons_For_Request__c;
                    oBLE.Comments__c = oBledisplay.Comments__c;
                    oBLE.Last_Attended_Date__c = oBledisplay.Last_Attended_Date__c;
                    oBLE.Death_Category__c = oBledisplay.Death_Category__c;
                    oBLE.Death_Sub_Category__c = oBledisplay.Death_Sub_Category__c;
                    oBLE.Date_Of_Death__c = oBledisplay.Date_Of_Death__c;
                    oBLE.New_Current_ICP__c = oBledisplay.New_Current_ICP__c;
                    oBLE.Transition_Type__c = oBledisplay.Transition_Type__c;
                    oBLE.Review_Status__c   = oBledisplay.Review_Status__c;
                    oBLE.Status__c = oBledisplay.Status__c;
                    lstBLE.add(oBLE);
                }
            }
        }
        if(sObjectType == Constants.MEDICALINCIDENTS_IMMUNIZATION_RT_API_NAME) {
            for(AccountWrapper oAcntWrap: lstAccntWrapper) {
                if(oAcntWrap.bIsChecked == true) {
                    Immunization__c oImmunizationObj = new Immunization__c();
                    oImmunizationObj.Beneficiary__c = oAcntWrap.oAccount.Id;
                    oImmunizationObj.Immunization_Type__c = oImmunization.Immunization_Type__c;
                    oImmunizationObj.Dosage__c = oImmunization.Dosage__c;
                    oImmunizationObj.Immunization_Date__c = oImmunization.Immunization_Date__c;
                    lstImmu.add(oImmunizationObj);
                }
            }
        }

        if(sObjectType == Constants.MEDICALINCIDENTS_ILLNESS_RT_API_NAME ||
            sObjectType == Constants.MEDICALINCIDENTS_INJURY_RT_API_NAME) {
            if(sObjectType == Constants.MEDICALINCIDENTS_ILLNESS_RT_API_NAME && (
                    String.isEmpty(oMedIncident.Illness_Category__c) || String.isEmpty(
                        oMedIncident
                        .Illness_Sub_Category__c))) {
                ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,
                    System.Label.Mass_Update_Error_For_Illness);
                ApexPages.addMessage(oMsg);
                return null;
            }
            if(sObjectType == Constants.MEDICALINCIDENTS_INJURY_RT_API_NAME && String.isEmpty(
                    oMedIncident.Injury__c)) {
                ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,
                    System.Label.Mass_Update_Error_For_Injury);
                ApexPages.addMessage(oMsg);
                return null;
            }
            for(AccountWrapper oAcntWrap: lstAccntWrapper) {
                if(oAcntWrap.bIsChecked == true) {
                    Medical_Incidents__c oMedicalIncident = new Medical_Incidents__c();
                    oMedicalIncident.Beneficiary__c = oAcntWrap.oAccount.Id;
                    oMedicalIncident.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
                        Medical_Incidents__c.SobjectType, sObjectType);
                    oMedicalIncident.Illness_Category__c = oMedIncident.Illness_Category__c;
                    oMedicalIncident.Illness_Sub_Category__c = oMedIncident.Illness_Sub_Category__c;
                    //oMedicalIncident.Status__c=oMedIncident.Status__c;
                    oMedicalIncident.Optional_Comment__c = oMedIncident.Optional_Comment__c;
                    oMedicalIncident.Injury__c = oMedIncident.Injury__c;
                    oMedicalIncident.Incident_Date__c = oMedIncident.Incident_Date__c;
                    lstMed.add(oMedicalIncident);
                }
            }
        }

        if(sObjectType == Constants.BEN_API_NAME || sObjectType == Constants.AGE_TRANSITION_API_NAME) {
            if(sObjectType == Constants.BEN_API_NAME && oIcpAccount.Beneficiary_Confession_Of_Faith_Date__c ==
                null) {
                ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,
                    System.Label.Mass_Update_Error_For_Beneficiary_Confession);
                ApexPages.addMessage(oMsg);
                return null;
            }
            if(sObjectType == Constants.AGE_TRANSITION_API_NAME && String.isEmpty(
                    oIcpAccount.Cognitive_Age_Group__c)) {
                ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,
                    System.Label.Mass_Update_Error_For_Beneficiary_Cognitive_Age);
                ApexPages.addMessage(oMsg);
                return null;
            }
            for(AccountWrapper oAcntWrap: lstAccntWrapper) {
                if(oAcntWrap.bIsChecked == true) {
                    Account oAccount = new Account(id = oAcntWrap.oAccount.Id);
                    if(oIcpAccount.Beneficiary_Confession_Of_Faith_Date__c != null)
                        oAccount.Beneficiary_Confession_Of_Faith_Date__c = oIcpAccount.Beneficiary_Confession_Of_Faith_Date__c;
                    if(oIcpAccount.Cognitive_Age_Group__c != null)
                        oAccount.Cognitive_Age_Group__c = oIcpAccount.Cognitive_Age_Group__c;
                    if(oIcpAccount.Beneficiary_Last_Bible_Distributed_Date__c != null)
                        oAccount.Beneficiary_Last_Bible_Distributed_Date__c = oIcpAccount.Beneficiary_Last_Bible_Distributed_Date__c;
                    if(oIcpAccount.Program_Field_Manual_Exemption__c != null)
                        oAccount.Program_Field_Manual_Exemption__c = oIcpAccount.Program_Field_Manual_Exemption__c;
                    lstAcnt.add(oAccount);
                }
            }
        }

        if(sObjectType == Constants.BA_Growth_Monitoring_RT_API_NAME) {
            bIsErrorFlag = validateHealthAssessRecordForInsert(lstAccntWrapper);
            if(bIsErrorFlag == true) {
                return null;
            }
            Id gmRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                Beneficiary_Assessment__c.SObjectType, Constants.BA_Growth_Monitoring_RT_API_NAME
            );
            for(AccountWrapper oAcntWrap: lstAccntWrapper) {
                if(oAcntWrap.bIsChecked == true) {
                    Beneficiary_Assessment__c oBenefAsses = new Beneficiary_Assessment__c();
                    oBenefAsses.Beneficiary__c = oAcntWrap.oAccount.Id;
                    oBenefAsses.Assessment_Completion_Date__c = oBenefAssessment.Assessment_Completion_Date__c;
                    oBenefAsses.Height__c = oAcntWrap.dHeight;
                    oBenefAsses.Weight__c = oAcntWrap.dWeight;
                    oBenefAsses.Name = oBenefAssessment.Name;
                    oBenefAsses.RecordTypeId = gmRecTypeId;
                    lstBenefAssess.add(oBenefAsses);
                }
            }
        }

        if(sObjectType == Constants.BA_Health_Assessment_RT_API_NAME) {
            bIsErrorFlag = validateHealthAssessRecordForInsert(lstAccntWrapper);
            if(bIsErrorFlag == true) {
                return null;
            }
            Id haRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                Beneficiary_Assessment__c.SObjectType, Constants.BA_Health_Assessment_RT_API_NAME
            );
            for(AccountWrapper oAcntWrap: lstAccntWrapper) {
                if(oAcntWrap.bIsChecked == true) {
                    Beneficiary_Assessment__c oBenefAsses = new Beneficiary_Assessment__c();
                    oBenefAsses.Beneficiary__c = oAcntWrap.oAccount.Id;
                    oBenefAsses.Assessment_Completion_Date__c = oBenefAssessment.Assessment_Completion_Date__c;
                    oBenefAsses.Height__c = oAcntWrap.dHeight;
                    oBenefAsses.Weight__c = oAcntWrap.dWeight;
                    oBenefAsses.Name = oBenefAssessment.Name;
                    oBenefAsses.RecordTypeId = haRecTypeId;
                    lstBenefAssess.add(oBenefAsses);
                }
            }
        }

        if(lstMed.size()> 0) {
            oSRList = Database.insert(lstMed, false);
            logError(oSRList, lstMed, 'Medical_Incidents__c', 'MassUpdateController',
                'createUpdateRecords', 'SFDC CI');
        }
        if(lstImmu.size()> 0) {
            oSRList = Database.insert(lstImmu, false);
            logError(oSRList, lstImmu, 'Immunization__c', 'MassUpdateController',
                'createUpdateRecords', 'SFDC CI');
        }
        if(lstBLE.size()> 0 && sObjectType == Constants.BLE_TRANSFER_RT_API_NAME) {
            oSRList = Database.insert(lstBLE, false);
            logError(oSRList, lstBLE, 'Beneficiary_Lifecycle_Event__c',
                'MassUpdateController', 'createUpdateRecords', 'SFDC CI');
        }

        if(lstBLE.size()> 0 && sObjectType != Constants.BLE_TRANSFER_RT_API_NAME) {
            oSRList = Database.insert(lstBLE, false);
            logError(oSRList, lstBLE, 'Beneficiary_Lifecycle_Event__c',
                'MassUpdateController', 'createUpdateRecords', 'SFDC CI');
        }

        if(lstAcnt.size()> 0) {
            oSRList = Database.update(lstAcnt, false);
            logError(oSRList, lstAcnt, 'Account', 'MassUpdateController',
                'createUpdateRecords', 'SFDC CI');
        }

        if(lstBenefAssess.size()> 0) {
            oSRList = Database.insert(lstBenefAssess, false);
            logError(oSRList, lstBenefAssess, 'Beneficiary_Assessment__c',
                'MassUpdateController',
                'createUpdateRecords', 'SFDC CI');
        }
        return null;

    }

    /**
     * Method name  : validateTransferRecordForInsert
     * Description  : This method is used to validate the input data before inserting in database
     * Return Type  : Boolean
     * Parameter    : list<AccountWrapper>, Beneficiary_Lifecycle_Event__c
     **/
    public Boolean validateTransferRecordForInsert(list<AccountWrapper>
        lstAccntWrapper, Beneficiary_Lifecycle_Event__c oBledisplay) {
                bIsErrorFlag = false;
                if(sObjectType == Constants.BLE_TRANSFER_RT_API_NAME && oBledisplay.Reason_For_Request__c ==
                                null) {
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                                System.Label.Please_Enter_Reason_For_Request);
                        ApexPages.addMessage(oMsg);
                        bIsErrorFlag = true;
                }
                if(sObjectType == Constants.BLE_TRANSFER_RT_API_NAME && (oBledisplay.New_Current_ICP__c ==
                                null && oBledisplay.Status__c == Constants.CLOSED)) {
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                                System.Label.Please_Enter_New_ICP_ID_and_New_Local_Beneficiary_Number);
                        ApexPages.addMessage(oMsg);
                        bIsErrorFlag = true;
                }
                for(AccountWrapper oAcntWrap: lstAccntWrapper) {
                        if(sObjectType == Constants.BLE_TRANSFER_RT_API_NAME) {
                                if(oAcntWrap.bIsChecked == true) {
                                        if(String.isEmpty(oAcntWrap.sNewLocalBeneficiaryNumber) && oBledisplay.Status__c == Constants.CLOSED) {
                                                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                                                        System.Label.Local_Ben_Number);
                                                ApexPages.addMessage(oMsg);
                                                bIsErrorFlag = true;
                                        }
                                }
                        }
                }
                return bIsErrorFlag;
    }

    /**
     * Method name  : validateHealthAssessRecordForInsert
     * Description  : This method is used to validate the input data before inserting in database
     * Return Type  : Boolean
     * Parameter    : list<AccountWrapper>
     **/
    public Boolean validateHealthAssessRecordForInsert(list<AccountWrapper>
        lstAccntWrapper) {
        bIsErrorFlag = false;
        for(AccountWrapper oAcntWrap: lstAccntWrapper) {
            if(oAcntWrap.bIsChecked == true) {
                if(null == oAcntWrap.dWeight || oAcntWrap.dWeight<1 || null == oAcntWrap
                    .dHeight || oAcntWrap.dHeight<1) {
                    ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                        Label.Mass_Update_Ben_Asses_Error);
                    ApexPages.addMessage(oMsg);
                    bIsErrorFlag = true;
                    break;
                }
            }
        }
        return bIsErrorFlag;
    }

    /**
     * Method name  : logError
     * Description  : This method logs all Insert/Update DML related errors in Error_Log__c object
     * Return Type  : void
     * Parameter    : List<Database.SaveResult>, List<sObject>, String, String, String, String,
     **/
    private Void logError(List<Database.SaveResult>
        lstSaveResult,
        List<sObject> lstSObject, String sObjectName, String sClassName, String sMethodName,
        String sSourceSystem) {
        bSuccessScen = true;
        Id generalErrorLogRecTypeId;
        String sBeneficiaryNames = Constants.EMPTY_STRING;
        if(!lstSaveResult.isEmpty()) {
            generalErrorLogRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                Error_Log__c.SObjectType,
                Constants.ERRORLOG_GENERAL);
        }
        try {
            List<Error_Log__c> lstErrorLog = new List<Error_Log__c>();
            for(Integer i = 0; i<lstSaveResult.size(); i++) {
                if(!lstSaveResult.get(i)
                    .isSuccess()) {
                    String sErrorMsg;
                    Database.SaveResult oSaveResult = lstSaveResult[i];
                    for(Database.Error oError: oSaveResult.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(oError.getStatusCode() + ': ' + oError.getMessage());
                        System.debug('Fields that affected by this error: ' + oError.getFields());
                        sErrorMsg = oError.getMessage();
                        Error_Log__c oErrorLog = new Error_Log__c();
                        oErrorLog.RecordTypeId = generalErrorLogRecTypeId;
                        if(lstSObject[i].Id != null) {
                            oErrorLog.Record_Id__c = lstSObject[i].Id;
                        }
                        oErrorLog.Object__c = sObjectName;
                        oErrorLog.Error_Occurred_in_Class__c = sClassName;
                        oErrorLog.Error_Occurred_in_Method__c = sMethodName;
                        oErrorLog.Error_Body__c = sErrorMsg;
                        oErrorLog.Logged_In_User__c = UserInfo.getUserName();
                        oErrorLog.Source_System__c = sSourceSystem;
                        lstErrorLog.add(oErrorLog);
                        if((sObjectType == Constants.BEN_API_NAME || sObjectType == Constants.AGE_TRANSITION_API_NAME) &&
                            (!mapIdToBeneficiaryName.isEmpty() && mapIdToBeneficiaryName.containsKey(
                                lstSObject.get(i)
                                .Id))) {
                            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,
                                mapIdToBeneficiaryName.get(lstSObject.get(i)
                                    .Id) + Constants.COLON_STRING + oError.getMessage());
                            ApexPages.addMessage(oMsg);
                        }
                        if((sObjectType != Constants.BEN_API_NAME && sObjectType != Constants.AGE_TRANSITION_API_NAME) &&
                            !mapIdToBeneficiaryName.isEmpty() && mapIdToBeneficiaryName.containsKey(
                                (String)(lstSObject.get(i)
                                    .get('Beneficiary__c')))) {
                            ApexPages.Message oMsg = new ApexPages.Message(Apexpages.Severity.ERROR,
                                mapIdToBeneficiaryName.get((String)(lstSObject.get(i)
                                    .get('Beneficiary__c'))) + Constants.COLON_STRING + oError.getMessage()
                            );
                            ApexPages.addMessage(oMsg);
                        }
                        bSuccessScen = false;

                    }
                }
                if(lstSaveResult.get(i)
                    .isSuccess()) {
                    if((sObjectType == Constants.BEN_API_NAME || sObjectType == Constants.AGE_TRANSITION_API_NAME) &&
                        (!mapIdToBeneficiaryName.isEmpty() && mapIdToBeneficiaryName.containsKey(
                            lstSObject.get(i)
                            .Id))) {
                        sBeneficiaryNames = sBeneficiaryNames + ', ' + mapIdToBeneficiaryName.get(
                            lstSObject.get(i)
                            .Id);
                        setBenefId.add(lstSObject.get(i)
                            .Id);
                    }
                    if((sObjectType != Constants.BEN_API_NAME && sObjectType != Constants.AGE_TRANSITION_API_NAME) &&
                        !mapIdToBeneficiaryName.isEmpty() && mapIdToBeneficiaryName.containsKey(
                            (String)(lstSObject.get(i)
                                .get('Beneficiary__c')))) {
                        sBeneficiaryNames = sBeneficiaryNames + ', ' + mapIdToBeneficiaryName.get(
                            (String)(lstSObject.get(i)
                                .get('Beneficiary__c')));
                        setBenefId.add((String)(lstSObject.get(i)
                            .get('Beneficiary__c')));
                    }
                }
            }
            for(AccountWrapper oAcntWrap: lstAccntWrapper) {
                if(oAcntWrap.bIsChecked == true && !setBenefId.isEmpty() && setBenefId.contains(
                        oAcntWrap.oAccount.Id)) {
                    oAcntWrap.bIsChecked = false;
                }
            }
            if(!lstErrorLog.isEmpty()) {
                List<Database.SaveResult> lstSaveResults = Database.insert(lstErrorLog,
                    false);
            }
        } catch(DMLException oEx) {
            ErrorLogUtility.logGeneralError(oEx, 'MassUpdateController', 'logError',
                'SFDC CI');
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Info,
                oEx.getMessage());
            ApexPages.addMessage(oMsg); 
        }
        if(!String.isEmpty(sBeneficiaryNames)) {
            String sSuccessMessage = System.Label.BLM_msg_part_1 + Constants.SPACE_STRING +
                sBeneficiaryNames.substring(2) + Constants.SPACE_STRING + System.Label.BLM_msg_part_2;
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Info,
                sSuccessMessage);
            ApexPages.addMessage(oMsg);
        }
        sShowMessage = (bSuccessScen) ? 'true' : 'false';
    }


    /**5
     * Class name   : AccountWrapper
     * Description  : This is inner class used as a Data structure to hold & display information corresponding to Beneficiary and its associations.
     **/
    public class AccountWrapper {
        public boolean bIsChecked {
            get;
            set;
        }
        public string sNewLocalBeneficiaryNumber {
            get;
            set;
        }
        public Decimal dWeight {
            get;
            set;
        }
        public Decimal dHeight {
            get;
            set;
        }
        public Account oAccount {
            get;
            set;
        }
    }
}