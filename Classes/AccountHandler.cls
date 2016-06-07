/******************************************************************************************************
Class Name         : AccountHandler
Description        : This is single Class for Account which will cover all the Account Functionality.
                     All Methods to cover oAccount functionality will be defined in this class. These methods
                     will be called from AccountTrigger based on required trigger events.
Created By         : Vishal Katyare 
Created On         : 14-Oct-2014 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class AccountHandler {
    /**
     * Method name  : onAfterInsert
     * Description  : This method will be called after any Account record is inserted
     * Return Type  : void
     * Parameter    : List<Account>
     **/
    public void onAfterInsert(List < Account > lstNewRecords) {
        Utility.bIsRecordInsert = true;
        createRegistrationBLEvent();
        createSetupPlan();
        calculateBeneficiaryCountOnICP(lstNewRecords, null);
        getContactsFromLeadToConvertedAccount(lstNewRecords);
        updateAssocAddressOnLeadConversion(lstNewRecords);
        updateFieldOfficeForHouseholdOnBenefInsert(lstNewRecords);
        shareBeneficiaryWithICPUser(lstNewRecords,null);
        copyICPDetailsToICPMiniProfile(lstNewRecords,null);
        updateRegEffDateForCSP(lstNewRecords,null);
    }


    /**
     * Method name  : onAfterUpdate
     * Description  : This method will be called after any Account record is updated
     * Return Type  : void
     * Parameter    : Map<Id,Account>, Map<Id,Account>, List<Account>
     **/
    public void onAfterUpdate(Map < Id, Account > mapOldRecords, Map < Id, Account >
        mapNewRecords, List < Account > lstNewRecords) {
        calculateBeneficiaryCountOnICP(lstNewRecords, mapOldRecords);
        updateFieldOfficeForHouseholdOnBenefUpdate(lstNewRecords, mapOldRecords);
        updateConfessFlag(lstNewRecords, mapOldRecords);
        //deleteSharingBeneficiaryTransfer(lstNewRecords,mapOldRecords);
        deleteCommunicationKit(mapNewRecords, mapOldRecords);
        commKitOnICPTransition(mapNewRecords, mapOldRecords);
        shareBeneficiaryWithICPUser(lstNewRecords,mapOldRecords);
        updateRegEffDateForCSP(lstNewRecords,mapOldRecords);
        if (!Label.Disable_For_Data_Load.equals('true')) {
            sendBenefUpdateToUS(mapNewRecords, mapOldRecords);
        }
        copyICPDetailsToICPMiniProfile(lstNewRecords,mapOldRecords);
    }

    /**
     * Method name  : onBeforeUpdate
     * Description  : This method will be called before any Account record is udpated
     * Return Type  : void
     * Parameter    : Map<Id,Account>, Map<Id,Account>, List<Account>
     **/
    public void onBeforeUpdate(Map < Id, Account > mapOldRecords, Map < Id,
        Account > mapNewRecords, List < Account > lstNewRecords) {
        if (!Utility.getSystemAdminProfileId().equals(UserInfo.getProfileId())) {
            checkFirstNameOnCDSP(lstNewRecords);
        }
        updateRvwStsOnBenefIfEmpty(lstNewRecords);
        preventLocalBeneficiaryNumberDelete(lstNewRecords);
        updateICPOnExistingBenefSelection(mapOldRecords, mapNewRecords);
        updateICPMaximumBeneficiaryCapacity(lstNewRecords);
        updateUSEquivalentGradeLevel(lstNewRecords, mapOldRecords);
        updateLifecycleEvent(lstNewRecords, mapOldRecords, mapNewRecords);
        updateCognitiveAgeGroup(lstNewRecords, mapOldRecords);
         updateIsOrphanOnAccount(lstNewRecords);
         updateIsPartnerFlag(lstNewRecords);
        if (!Label.Disable_For_Data_Load.equals('true')) {
            updateMalnutritionData(lstNewRecords, mapOldRecords);
            concatenateICPIDLocalBeneficiaryNumber(lstNewRecords, mapOldRecords);
            updatePrimaryCaregiver(lstNewRecords, mapOldRecords);
          //  checkRegistrationDateLimit(lstNewRecords);
        }
    }

    /**
     * Method name  : onBeforeInsert
     * Description  : This method will be called before any Account record is inserted
     * Return Type  : void
     * Parameter    : List<Account>
     **/
    public void onBeforeInsert(List < Account > lstNewRecords) {

        if (!Utility.getSystemAdminProfileId().equals(UserInfo.getProfileId())) {
            if (!Label.Disable_For_Data_Load.equals('true')) {
                //checkRegistrationDateLimit(lstNewRecords);
            }
            checkFirstNameOnCDSP(lstNewRecords);
        }
        updateRvwStsOnBenefIfEmpty(lstNewRecords);
        updateLeadSourceOnAccount(lstNewRecords);
        validateICPBeneficiaryForPortal(lstNewRecords);
        updateICPMaximumBeneficiaryCapacity(lstNewRecords);
        updateUSEquivalentGradeLevel(lstNewRecords, null);
        updateCognitiveAgeGroup(lstNewRecords, null);
        updateIsOrphanOnAccount(lstNewRecords);
        if (!Label.Disable_For_Data_Load.equals('true')) {
            updateMalnutritionData(lstNewRecords, null);
            concatenateICPIDLocalBeneficiaryNumber(lstNewRecords, null);
            updatePrimaryCaregiver(lstNewRecords, null);
        }
        updateDeliveryPreferenceOnSupporter(lstNewRecords);
    }

    /**
    * Method name  : getContactsFromLeadToConvertedAccount
    * Description  : This method will check if the Account is a converted oAccount and convert the
                     Lead Contacts and Contents to the Converted ICP contacts and contents.
    * Return Type  : void
    * Parameter    : List<Account>
    **/
    public void getContactsFromLeadToConvertedAccount(List < Account >
        lstNewRecords) {
        map < String, Id > mapSourceLeadId = new map < String, Id > ();
        set < String > setSourceLeadId = new set < String > ();
        List < Content__c > lstContentToUpdate = new List < Content__c > ();
        Set < Id > setLeadIds = new Set < Id > ();
        Id contentICPRecTypeId = Utility.getRecordTypeIdByDeveloperName(Content__c.SObjectType,
            Constants.ICP_RT_API_NAME);
        for (Account oAcc: lstNewRecords) {
            if (oAcc.Source_Lead_Id__c != NULL) {
                mapSourceLeadId.put(oAcc.Source_Lead_Id__c, oAcc.Id);
                setSourceLeadId.add(oAcc.Source_Lead_Id__c);
            }
        }
        if (!setSourceLeadId.isEmpty()) {
            List < Lead > lstLeadId = [Select Id from Lead where Lead_Id__c IN:
                setSourceLeadId
            ];
            for (Lead oLead: lstLeadId) {
                setLeadIds.add(oLead.Id);
            }
        }
        List < Contact > lstContactsRelatedToConvertedAccount = new List < Contact >
            ();
        if (!setLeadIds.isEmpty()) {
            lstContactsRelatedToConvertedAccount = [select Lead__r.Lead_Id__c,
                AccountId from Contact where Lead__c IN: setLeadIds
            ];
            for (Contact oLeadID: lstContactsRelatedToConvertedAccount) {
                if (mapSourceLeadId.containsKey(oLeadID.Lead__r.Lead_Id__c)) {
                    oLeadID.AccountId = mapSourceLeadId.get(oLeadID.Lead__r.Lead_Id__c);
                }
            }
            if (!setSourceLeadId.isEmpty()) {
                lstContentToUpdate = [Select Id, RecordTypeId, ICP_Lead__r.Lead_Id__c,
                    ICP__c from Content__c where ICP_Lead__c IN: setLeadIds
                ];
                if (!lstContentToUpdate.isEmpty()) {
                    for (Content__c oContent: lstContentToUpdate) {
                        if (mapSourceLeadId.containsKey(oContent.ICP_Lead__r.Lead_Id__c)) {
                            oContent.ICP__c = mapSourceLeadId.get(oContent.ICP_Lead__r.Lead_Id__c);
                            oContent.RecordTypeId = contentICPRecTypeId;
                        }
                    }
                }
            }
        }
        if (!lstContentToUpdate.isEmpty()) {
            List < Database.SaveResult > lstUpdateResults =
                Database.update(lstContentToUpdate, false);
            Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstContentToUpdate, 'Content__c',
                'AccountHandler', 'getContactsFromLeadToConvertedAccount', 'SFDC CI',
                false);
        }
        if (!lstContactsRelatedToConvertedAccount.isEmpty()) {
            List < Database.SaveResult > lstUpdateResults =
                Database.update(lstContactsRelatedToConvertedAccount, false);
            Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstContactsRelatedToConvertedAccount, 'Contact',
                'AccountHandler', 'getContactsFromLeadToConvertedAccount', 'SFDC CI',
                false);
        }
    }

    /**
    * Method name  : updateLeadSourceOnAccount
    * Description  : This method will populate Lead source and oGlobalDataUtilKey Lead source from Lead to ICP, i.e oAccount, as Standard Lead conversion process maps 
                     it to the Contact field
    * Return Type  : void
    * Parameter    : List<Account>
    **/
    public void updateLeadSourceOnAccount(List < Account > lstNewRecords) {
        Map < Id, String > mapSourceLeadId = new Map < Id, String > ();
        List < Account > lstConvertedAccs = new List < Account > ();
        for (Account oAcc: lstNewRecords) {
            if (oAcc.Source_Lead_Id__c != NULL) {
                mapSourceLeadId.put(oAcc.Id, oAcc.Source_Lead_Id__c);
                lstConvertedAccs.add(oAcc);
            }
        }
        List < Lead > lstSourceLeads =
            new List < Lead > ();
        try {
            lstSourceLeads = [select Id, Lead_Id__c, LeadSource,
                Other_Lead_Source__c from Lead where Lead_Id__c IN: mapSourceLeadId.values()
            ];
        } catch (System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'AccountHandler',
                'updateLeadSourceOnAccount', 'SFDC CI');
            return;
        }
        Map < String, Lead > mapLeadSource = new Map < String, Lead > ();
        for (Lead oLead: lstSourceLeads) {
            mapLeadSource.put(oLead.Lead_Id__c, oLead);
        }
        for (Account oAcc: lstConvertedAccs) {
            oAcc.Lead_Source__c = mapLeadSource.get(mapSourceLeadId.get(oAcc.Id))
                .LeadSource;
            oAcc.Other_Lead_Source__c = mapLeadSource.get(mapSourceLeadId.get(oAcc.Id))
                .Other_Lead_Source__c;
        }
    }

    /**
     * Method name  : createRegistrationBLEvent
     * Description  : This method will create default program for the newly created beneficiary reading selected record type.
     * Return Type  : void
     * Parameter    : void
     **/
    public void createRegistrationBLEvent() {
        Id registrationRecId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_REGISTRATION_RT_API_NAME
        );
        List < Beneficiary_Lifecycle_Event__c > lstBLEvent = new List <
            Beneficiary_Lifecycle_Event__c > ();
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        for (Account oAcc: (List < Account > ) trigger.new) {
            if (oAcc.RecordTypeId.equals(cdspRecTypeId) || oAcc.RecordTypeId.equals(
                    cspRecTypeId)) {
                Beneficiary_Lifecycle_Event__c oBLEvent = new Beneficiary_Lifecycle_Event__c();
                oBLEvent.Beneficiary__c = oAcc.Id;
                oBLEvent.RecordTypeId = registrationRecId;
                oBLEvent.New_Current_ICP__c = oAcc.ICP__c;
                /*if (oAcc.Actual_Registration_Date__c != null)
                    oBLEvent.Date_of_Action__c = Date.valueOf(oAcc.Actual_Registration_Date__c);
                else
                    oBLEvent.Date_of_Action__c = Date.valueOf(oAcc.CreatedDate);*/
                oBLEvent.Reason_for_Request__c = Constants.REGISTRATION_WITH_COMPASSION;

                lstBLEvent.add(oBLEvent);
            }
        }
        if (!lstBLEvent.isEmpty()) {
            List < Database.SaveResult > lstInsertResults =
                Database.insert(lstBLEvent, false);
            Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstInsertResults, lstBLEvent, 'Beneficiary_Lifecycle_Event__c',
                'AccountHandler', 'createRegistrationBLEvent', 'SFDC CI', false);
        }
    }
    /**
     * Method name  : createSetupPlan
     * Description  : This method will create a Set Up Plan for the newly created ICP.
     * Return Type  : void
     * Parameter    : void
     * Created By   : MV 
     **/
    public void createSetupPlan() {
        Id setupPlanRecId = Utility.getRecordTypeIdByDeveloperName(
            Activity_Plan__c.SObjectType, Constants.SETUP_PLAN_RT_API_NAME
        );        
        Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);   
        List < Activity_Plan__c > lstSetupPlan = new List <
            Activity_Plan__c > ();   
       for (Account oAcc: (List < Account > ) trigger.new) {
          if (oAcc.RecordTypeId.equals(icpRecTypeId)||(oAcc.Source_Lead_Id__c != null&& 
               oAcc.ICP_Id__c !=null)) {
                Activity_Plan__c oActPlan = new Activity_Plan__c();
                oActPlan.ICP__c = oAcc.Id;
                oActPlan.RecordTypeId = setupPlanRecId ;
                oActPlan.Name = 'Set Up Plan for'+' '+String.valueof(oAcc.ICP_Id__c);                          
                lstSetupPlan.add(oActPlan);
            }
        }
        if (!lstSetupPlan.isEmpty()) {
            List < Database.SaveResult > lstInsertResults =
                Database.insert(lstSetupPlan , false);
            Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstInsertResults, lstSetupPlan, 'Activity_Plan__c',
                'AccountHandler', 'createSetupPlan', 'SFDC CI', false);
        }
    }

    /**
     * Method name  : calculateBeneficiaryCountOnICP
     * Description  : Method is created to update beneficiary count on ICP
     * Return Type  : void
     * Parameter    : List<Account> ,Map<Id,Account> 
     **/
    private void calculateBeneficiaryCountOnICP(List < Account > lstNewRecords,
        Map < Id, Account > mapOldRecords) {
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        List < Id > lstICPIds = new List < Id > ();

        for (Account oAcc: lstNewRecords) {
            if (oAcc.ICP__c != null && (oAcc.RecordTypeId == cspRecTypeId || oAcc.RecordTypeId ==
                    cdspRecTypeId) &&
                (null == mapOldRecords || (mapOldRecords.get(oAcc.Id) != null && !oAcc.Beneficiary_Status__c
                    .equals(mapOldRecords.get(oAcc.Id).Beneficiary_Status__c)) || (
                    mapOldRecords.get(oAcc.Id) != null && !oAcc.ICP__c.equals(mapOldRecords
                        .get(oAcc.Id).ICP__c)) || (mapOldRecords.get(oAcc.Id) != null && null <> oAcc.CDSP_Type__c && 
                        !oAcc.CDSP_Type__c.equals(mapOldRecords.get(oAcc.Id).CDSP_Type__c)))) {
                if (null != mapOldRecords && oAcc.ICP__c != null && mapOldRecords.get(
                        oAcc.Id) != null && !oAcc.ICP__c.equals(mapOldRecords.get(oAcc.Id).ICP__c)) {
                    lstICPIds.add(oAcc.ICP__c);
                    lstICPIds.add(mapOldRecords.get(oAcc.Id).ICP__c);
                } else {
                    lstICPIds.add(oAcc.ICP__c);
                }
            }
        }

        if (!lstICPIds.isEmpty()) {
            List < Account > lstICPs =
                new List < Account > ();
            lstICPs = [Select Id, Name, No_Of_CSP_Beneficiaries__c,
                No_Of_CDSP_Beneficiaries__c,Home_Based_Sponsorship_Beneficiaries__c from Account where Id IN: lstICPIds
            ];

            Map < Id, Map < String, Integer >> mapIdToMapTokenToBenefNumber =
                prepareBenefNumberMap(lstICPs);

            if (null == mapIdToMapTokenToBenefNumber) {
                return;
            }
            for (Account icp: lstICPs) {
                if (mapIdToMapTokenToBenefNumber.keySet().contains(icp.Id)) {
                    icp.No_Of_CSP_Beneficiaries__c = mapIdToMapTokenToBenefNumber.get(icp.Id)
                        .get(Constants.CSP_TOKEN);
                    icp.No_Of_CDSP_Beneficiaries__c = mapIdToMapTokenToBenefNumber.get(icp.Id)
                        .get(Constants.CDSP_TOKEN);
                    icp.Home_Based_Sponsorship_Beneficiaries__c = mapIdToMapTokenToBenefNumber.get(icp.Id)
                        .get(Constants.CDSP_HOME_BASED_TOKEN);
                }
            }

            if (!lstICPs.isEmpty()) {
                List < Database.SaveResult > lstUpdateResults =
                    Database.update(lstICPs, false);
                Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, lstICPs, 'Account',
                    'AccountHandler', 'calculateBeneficiaryCountOnICP', 'SFDC CI', false);
            }
        }
    }

    /**
    * Method name  : prepareBenefNumberMap
    * Description  : This method prepares map whose Id is CSP/CDSP token and in value another map whose oKey is ICP Id and value consists no of beneficiaries
                     under that ICP
    * Return Type  : Map<Id,Map<String,Integer>>
    * Parameter    : List<Account> 
    **/
    private Map < Id, Map < String, Integer >> prepareBenefNumberMap(List <
        Account > lstICPs) {
        Map < Id, Map < String, Integer >> mapIdToMapTokenToBenefNumber = new Map <
            Id, Map < String, Integer >> ();
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        List < Account > lstAllAssocBenef =
            new List < Account > ();
        lstAllAssocBenef = [Select Id, RecordTypeId, ICP__c,
            Program_Stage__c, Beneficiary_Status__c from Account where(RecordTypeId = :
                cspRecTypeId OR RecordTypeId = : cdspRecTypeId) AND Beneficiary_Status__c = :
            Constants.ACTIVE AND ICP__c in : lstICPs
        ];
        Map < String, Integer > mapTokenToBenefNumberDefault = null;
        for (Account oICP: lstICPs) {
            mapTokenToBenefNumberDefault = new Map < String, Integer > ();
            mapTokenToBenefNumberDefault.put(Constants.CSP_TOKEN, 0);
            mapTokenToBenefNumberDefault.put(Constants.CDSP_TOKEN, 0);
            mapTokenToBenefNumberDefault.put(Constants.CDSP_HOME_BASED_TOKEN, 0);
            mapIdToMapTokenToBenefNumber.put(oICP.Id, mapTokenToBenefNumberDefault);
        }
        for (Account oAcc: lstAllAssocBenef) {
            if (mapIdToMapTokenToBenefNumber.keySet().contains(oAcc.ICP__c)) {
                Map < String, Integer > mapTokenToBenefNumber =
                    mapIdToMapTokenToBenefNumber.get(oAcc.ICP__c);
                if (Label.CSP.equals(oAcc.Program_Stage__c)) {
                    mapTokenToBenefNumber.put(Constants.CSP_TOKEN, mapTokenToBenefNumber.get(
                        Constants.CSP_TOKEN) + 1);
                } else if (Label.Program_Stage_Center_Based.equals(oAcc.Program_Stage__c)) {
                    mapTokenToBenefNumber.put(Constants.CDSP_TOKEN, mapTokenToBenefNumber.get(
                        Constants.CDSP_TOKEN) + 1);
                } else if (Label.Program_Stage_Home_Based.equals(oAcc.Program_Stage__c)) {
                    mapTokenToBenefNumber.put(Constants.CDSP_HOME_BASED_TOKEN, mapTokenToBenefNumber.get(
                        Constants.CDSP_HOME_BASED_TOKEN) + 1);
                }
            } else {
                Map < String, Integer > mapTokenToBenefNumber = new Map < String, Integer >
                    ();
                if (Label.CSP.equals(oAcc.Program_Stage__c)) {
                    mapTokenToBenefNumber.put(Constants.CSP_TOKEN, mapTokenToBenefNumber.get(
                        Constants.CSP_TOKEN) + 1);
                } else if (Label.Program_Stage_Center_Based.equals(oAcc.Program_Stage__c)) {
                    mapTokenToBenefNumber.put(Constants.CDSP_TOKEN, mapTokenToBenefNumber.get(
                        Constants.CDSP_TOKEN) + 1);
                } else if (Label.Program_Stage_Home_Based.equals(oAcc.Program_Stage__c)) {
                    mapTokenToBenefNumber.put(Constants.CDSP_HOME_BASED_TOKEN, mapTokenToBenefNumber.get(
                        Constants.CDSP_TOKEN) + 1);
                }
                mapIdToMapTokenToBenefNumber.put(oAcc.ICP__c, mapTokenToBenefNumber);
            }
        }
        return mapIdToMapTokenToBenefNumber;
    }
    
    /**
    * Method name  : updateAssocAddressOnLeadConversion
    * Description  : Checks if there is any ICP created via Lead conversion. if there is any, then it queries all associated address to that Lead. Updates record type of that
                     Address and associate it to the converted ICP oAccount
    * Return Type  : void
    * Parameter    : List<Account>
    **/
    private void updateAssocAddressOnLeadConversion(List < Account > lstNewRecords) {
        List < String > lstConcernedLeadIds = new List < String > ();
        Map < String, Id > mapLeadIdFieldToAccountId = new Map < String, Id > ();
        //Checks if there is any ICP created via Lead Conversion
        for (Account oAccount: lstNewRecords) {
            if (null != oAccount.Source_Lead_Id__c) {
                lstConcernedLeadIds.add(oAccount.Source_Lead_Id__c);
                mapLeadIdFieldToAccountId.put(oAccount.Source_Lead_Id__c, oAccount.Id);
            }
        }
        if (!lstConcernedLeadIds.isEmpty()) {
            Map < Id, Lead > mapLeadQueried = null;
            mapLeadQueried = new Map < Id, Lead > ([Select Id,
                Lead_Id__c from Lead where Lead_Id__c in : lstConcernedLeadIds
            ]);
            Id icpAddressRecTypeId = Utility.getRecordTypeIdByDeveloperName(Address__c.SObjectType,
                Constants.ICP_ADDRESS_RT_API_NAME);
            List < Address__c > lstAddressToUpdate =
                new List < Address__c > ();
            try {
                lstAddressToUpdate = [Select Lead__c, Account__c,
                    RecordTypeId, Lead__r.Lead_Id__c from Address__c where Lead__c in :
                    mapLeadQueried.keySet()
                ];
            } catch (System.QueryException oQe) {
                ErrorLogUtility.logGeneralError(oQe, 'AccountHandler',
                    'updateAssocAddressOnLeadConversion', 'SFDC CI');
                return;
            }
            for (Address__c addressToUpdate: lstAddressToUpdate) {
                addressToUpdate.RecordTypeId = icpAddressRecTypeId;
                addressToUpdate.Account__c = mapLeadIdFieldToAccountId.get(addressToUpdate
                    .Lead__r.Lead_Id__c);
            }
            if (!lstAddressToUpdate.isEmpty()) {
                List < Database.SaveResult > lstUpdateResults =
                    Database.update(lstAddressToUpdate, false);
                Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, lstAddressToUpdate, 'Address__c',
                    'AccountHandler', 'updateAssocAddressOnLeadConversion', 'SFDC CI', false
                );
            }
        }
    }

    /**
     * Method name  : updateICPOnExistingBenefSelection
     * Description  : This method is used to fetch ICP value from Existing CDSP Beneficiary & populate it on CSP level Beneficiary.
     * Return Type  : void
     * Parameter    : Map<Id,Account>, Map<Id,Account>
     **/
    private void updateICPOnExistingBenefSelection(Map < Id, Account >
        mapOldRecords, Map < Id, Account > mapNewRecords) {
        List < Id > lstExistingBenefToQuery = new List < Id > ();
        List < Id > lstBenefToUpdate = new List < Id > ();
        Id cspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        for (Id accountId: mapNewRecords.keySet()) {
            Account oAccount = mapNewRecords.get(accountId);
            if (cspBenefRecTypeId.equals(oAccount.RecordTypeId) && null != oAccount.Existing_Beneficiary__c &&
                mapOldRecords.get(oAccount.Id)
                .Existing_Beneficiary__c != oAccount.Existing_Beneficiary__c) {
                lstExistingBenefToQuery.add(oAccount.Existing_Beneficiary__c);
                lstBenefToUpdate.add(oAccount.Id);
            }
        }
        Map < Id, Account > mapExistingBenef = null;
        mapExistingBenef = new Map < Id, Account > ([Select ICP__c from Account where Id in
            : lstExistingBenefToQuery
        ]);
        for (Id benefToUpdateId: lstBenefToUpdate) {
            Account oBenefToUpdate = mapNewRecords.get(benefToUpdateId);
            oBenefToUpdate.ICP__c = mapExistingBenef.get(oBenefToUpdate.Existing_Beneficiary__c)
                .ICP__c;
        }
    }

    /**
    * Method name  : updateMalnutritionData
    * Description  : This method populates Malnutrition related WHO picklist data based upon the weight and height of beneficiary. For all 4 WHO fields, data has 
                     to be populated in Malnutrition_Data__c custom setting
    * Return Type  : void
    * Parameter    : List<Account>, Map<Id,Account>
    **/
    private void updateMalnutritionData(List < Account > lstNewRecords, Map < Id,
        Account > mapOldRecords) {
        Set < Decimal > setAgeInMonths = new Set < Decimal > ();
        Set < Decimal > setLength = new Set < Decimal > ();
        Id cspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Id cdspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        List < Account > lstAccountToUpdate = new List < Account > ();
        for (Account oAcc: lstNewRecords) {
            if ((cspBenefRecTypeId.equals(oAcc.RecordTypeId) || cdspBenefRecTypeId.equals(
                    oAcc.RecordTypeId)) && oAcc.PersonBirthdate != null && oAcc.Weight_Kg__c !=
                null && oAcc.Height_Cm__c != null && (null == mapOldRecords || oAcc.Gender__c !=
                    mapOldRecords.get(oAcc.Id)
                    .Gender__c || oAcc.Weight_Kg__c != mapOldRecords.get(oAcc.Id)
                    .Weight_Kg__c || oAcc.Height_Cm__c != mapOldRecords.get(oAcc.Id)
                    .Height_Cm__c || oAcc.PersonBirthdate != mapOldRecords.get(oAcc.Id)
                    .PersonBirthdate)) {
                lstAccountToUpdate.add(oAcc);
                setAgeInMonths.add(oAcc.Age_In_Months__c);
                setLength.add(oAcc.Height_Cm__c);
            }
        }

        if (!lstAccountToUpdate.isEmpty()) {
            List < Global_Data__c > lstGlobalData = new List < Global_Data__c > ();
            try {
                lstGlobalData = [Select Age_In_Months__c, Length__c,
                    SD1__c, SD2__c, SD3neg__c, SD2neg__c, Gender__c,
                    Malnutrition_Data_Type__c from Global_Data__c where Age_In_Months__c in
                    :
                    setAgeInMonths or Length__c in : setLength
                ];
            } catch (System.QueryException oQe) {
                ErrorLogUtility.logGeneralError(oQe, 'AccountHandler',
                    'updateMalnutritionData', 'SFDC CI');
                return;
            }
            Map < GlobalDataUtilKey, Global_Data__c > mapGlobalDataUtil =
                prepareGlobalDataUtilMap(lstGlobalData);
            Global_Data__c oGlobalDataForWFA = null;
            Global_Data__c oGlobalDataForHFA = null;
            Global_Data__c oGlobalDataForWFH = null;
            Global_Data__c oGlobalDataForBMI = null;
            for (Account oAcc: lstAccountToUpdate) {
                if (null != oAcc.Age_In_Months__c && null != oAcc.Height_Cm__c && null !=
                    oAcc.Gender__c) {
                    oGlobalDataForWFA = mapGlobalDataUtil.get(new GlobalDataUtilKey((Integer) oAcc
                        .Age_In_Months__c, 0, oAcc.Gender__c, Constants.WFA_TOKEN));
                    oAcc.Weight_For_Age_WHO__c = updateAccountField(oGlobalDataForWFA, oAcc,
                        Constants.WFA_TOKEN);

                    oGlobalDataForHFA = mapGlobalDataUtil.get(new GlobalDataUtilKey((Integer) oAcc
                        .Age_In_Months__c, 0, oAcc.Gender__c, Constants.HFA_TOKEN));
                    oAcc.Height_For_Age_WHO__c = updateAccountField(oGlobalDataForHFA, oAcc,
                        Constants.HFA_TOKEN);

                    oGlobalDataForWFH = mapGlobalDataUtil.get(new GlobalDataUtilKey(0, (
                        Integer) oAcc.Height_Cm__c, oAcc.Gender__c, Constants.WFH_TOKEN));
                    oAcc.Weight_For_Height_Length_WHO__c = updateAccountField(
                        oGlobalDataForWFH, oAcc, Constants.WFH_TOKEN);

                    oGlobalDataForBMI = mapGlobalDataUtil.get(new GlobalDataUtilKey((Integer) oAcc
                        .Age_In_Months__c, 0, oAcc.Gender__c, Constants.BMI_TOKEN));
                    oAcc.BMI_For_Age_WHO__c = updateAccountField(oGlobalDataForBMI, oAcc,
                        Constants.BMI_TOKEN);
                }
            }
        }
    }

    /**
     * Method name  : updateAccountField
     * Description  : Common method used to update all 4 WHO related picklist.
     * Return Type  : String
     * Parameter    : Global_Data__c , Account , String 
     **/
    private String updateAccountField(Global_Data__c oGlobalData, Account oAcc,
        String sMalType) {
        String sFieldToUpdate = null;
        Malnutrition_Data__c oMalData = Malnutrition_Data__c.getValues(sMalType);
        Decimal dHelperField = (Decimal) oAcc.get(oMalData.Field_Name__c);
        if (oAcc.Age_In_Months__c > oMalData.No_Of_Months_For_Condition_1__c) {
            sFieldToUpdate = oMalData.Value1_For_Age__c;
        } else if (sMalType.equals(Constants.BMI_TOKEN) && oAcc.Age_In_Months__c <
            oMalData.No_Of_Months_For_Condition_2__c) {
            sFieldToUpdate = oMalData.Value2_For_Age__c;
        } else if (sMalType.equals(Constants.WFH_TOKEN) && oAcc.Height_Cm__c >
            oMalData.Height__c) {
            sFieldToUpdate = oMalData.Value_For_Height__c;
        } else if (null == oGlobalData) {
            //Ideally shouldn't happen ever unless data problem. This means global data isn't having correspondent data and field would be updated by sFieldToUpdate default null value.
            //Kept above some conditions in order to avoid NullPointerException in those scenarios.
        } else if (dHelperField < oGlobalData.SD3neg__c) {
            sFieldToUpdate = oMalData.Value_1__c;
        } else if (dHelperField < oGlobalData.SD2neg__c && dHelperField >=
            oGlobalData.SD3neg__c) {
            sFieldToUpdate = oMalData.Value_2__c;
        } else if (dHelperField >= oGlobalData.SD2neg__c && !sMalType.equals(
                Constants.BMI_TOKEN)) {
            sFieldToUpdate = oMalData.Value_3__c;
        } else if (sMalType.equals(Constants.BMI_TOKEN) && dHelperField >
            oGlobalData
            .SD2__c) {
            sFieldToUpdate = oMalData.Value_3__c;
        } else if (sMalType.equals(Constants.BMI_TOKEN) && dHelperField >
            oGlobalData
            .SD1__c && dHelperField <= oGlobalData.SD2__c) {
            sFieldToUpdate = oMalData.Value_4__c;
        } else if (sMalType.equals(Constants.BMI_TOKEN) && dHelperField <=
            oGlobalData.SD1__c && dHelperField >= oGlobalData.SD2neg__c) {
            sFieldToUpdate = oMalData.Value_5__c;
        }
        return sFieldToUpdate;
    }

    /**
    * Class name   : GlobalDataUtilKey
    * Description  : Inner class which is used as a Key for mapGlobalDataUtil. This oKey uniquely identifies Global Data Malnutrition object on the basis of
                     Age or Height, Gender & Malnutrition Type
    **/
    private class GlobalDataUtilKey {
        public Integer iAgeInMonthsKey;
        public String sGenderKey;
        public Integer iHeightKey;
        public String sMalnutritionTypeKey;

        public GlobalDataUtilKey(Integer iAgeInMonthsArg, Integer iHeightKeyArg,
            String sGenderArg, String sMalnutritionTypeArg) {
            sGenderKey = (null == sGenderArg) ? Constants.NA : sGenderArg;
            sMalnutritionTypeKey = (null == sMalnutritionTypeArg) ? Constants.NA :
                sMalnutritionTypeArg;
            iAgeInMonthsKey = (null == iAgeInMonthsArg) ? 0 : iAgeInMonthsArg;
            iHeightKey = (null == iHeightKeyArg) ? 0 : iHeightKeyArg;
        }

        /**
         * Method name  : hashCode
         * Description  : Overriding hashCode method so that this inner class can be effectively used as oKey of Map
         * Return Type  : Integer
         * Parameter    : void
         **/
        public Integer hashCode() {
            return iAgeInMonthsKey + iHeightKey + sGenderKey.hashCode() +
                sMalnutritionTypeKey.hashCode();
        }

        /**
         * Method name  : equals
         * Description  : Overriding equals method so that this inner class can be effectively used as oKey of Map
         * Return Type  : Boolean
         * Parameter    : Object
         **/
        public Boolean equals(Object obj) {
            GlobalDataUtilKey oGlobalDataUtilKey = (GlobalDataUtilKey) obj;
            if (oGlobalDataUtilKey.iAgeInMonthsKey == iAgeInMonthsKey &&
                oGlobalDataUtilKey.sGenderKey.equals(sGenderKey) && oGlobalDataUtilKey.sMalnutritionTypeKey
                .equals(sMalnutritionTypeKey) && oGlobalDataUtilKey.iHeightKey ==
                iHeightKey)
                return true;
            else
                return false;
        }
    }

    /**
     * Method name  : prepareGlobalDataUtilMap
     * Description  : This method prepares GlobalDAtaUtil map whose oKey is inner class GlobalDataUtilKey & value is correspondent Global_Data__c object
     * Return Type  : Map<GlobalDataUtilKey,Global_Data__c>
     * Parameter    : List<Global_Data__c>
     **/
    private Map < GlobalDataUtilKey, Global_Data__c > prepareGlobalDataUtilMap(
        List < Global_Data__c > lstGlobalData) {
        Map < GlobalDataUtilKey, Global_Data__c > mapGlobalDataUtil = new Map <
            GlobalDataUtilKey, Global_Data__c > ();
        for (Global_Data__c oGlobalData: lstGlobalData) {
            GlobalDataUtilKey oKey = new GlobalDataUtilKey((Integer) oGlobalData.Age_In_Months__c,
                Integer.valueOf(oGlobalData.Length__c), oGlobalData.Gender__c,
                oGlobalData.Malnutrition_Data_Type__c);
            mapGlobalDataUtil.put(oKey, oGlobalData);
        }
        return mapGlobalDataUtil;
    }

    /**
     * Method name  : updateICPMaximumBeneficiaryCapacity
     * Description  : This private method updates maximum Beneficiary Capacity fields present on ICP
     * Return Type  : void
     * Parameter    : List<Account> 
     **/
    private void updateICPMaximumBeneficiaryCapacity(List < Account >
        lstNewRecords) {
        for (Account oAcc: lstNewRecords) {
            if (oAcc.CDSP_Capacity__c != null && oAcc.CSP_Capacity__c != null) {
                oAcc.ICP_Maximum_Beneficiary_Capacity__c = oAcc.CDSP_Capacity__c + oAcc.CSP_Capacity__c;
            } else if (oAcc.CDSP_Capacity__c != null) {
                oAcc.ICP_Maximum_Beneficiary_Capacity__c = oAcc.CDSP_Capacity__c;
            } else if (oAcc.CSP_Capacity__c != null) {
                oAcc.ICP_Maximum_Beneficiary_Capacity__c = oAcc.CSP_Capacity__c;
            } else if (oAcc.CDSP_Capacity__c == null && oAcc.CSP_Capacity__c == null) {
                oAcc.ICP_Maximum_Beneficiary_Capacity__c = 0;
            }
        }
    }

    /**
    * Method name  : updateUSEquivalentGradeLevel
    * Description  : This method will populate US Equivalent Grade level based upon Country & Local grade level of Beneficiary. This mapping is fetched
                     from Global Data object with Education data record type.
    * Return Type  : void
    * Parameter    : List<Account> , Map<Id,Account>
    **/
    private void updateUSEquivalentGradeLevel(List < Account > lstNewRecords,
            Map < Id, Account > mapOldRecords) {
            List < Account > lstBenefToLoop = new List < Account > ();
            Id cdspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.CDSP_BENEFICIARY_RT_API_NAME);
            Set < String > setCountry = new Set < String > ();
            Set < String > setlocalGradeLevel = new Set < String > ();

            for (Account oAccount: lstNewRecords) {
                if (cdspBenefRecTypeId.equals(oAccount.RecordTypeId) && null != oAccount.Country__c &&
                    null != oAccount.Local_Grade_Level__c && (Trigger.isInsert || (Trigger.isUpdate &&
                        !oAccount.Local_Grade_Level__c.equals(mapOldRecords.get(oAccount.Id)
                            .Local_Grade_Level__c)))) {
                    lstBenefToLoop.add(oAccount);
                    setCountry.add(oAccount.Country__c);
                    setlocalGradeLevel.add(oAccount.Local_Grade_Level__c);
                } else if (cdspBenefRecTypeId.equals(oAccount.RecordTypeId) && null ==
                    oAccount.Local_Grade_Level__c) {
                    oAccount.US_Equivalent_Grade_Level__c = null;
                }
            }

            if (!lstBenefToLoop.isEmpty()) {
                List < Global_Data__c > lstGlobalData =
                    new List < Global_Data__c > ();
                try {
                    lstGlobalData = [Select US_Equivalent_Grade_Level__c,
                        Local_Grade_Level__c, Country__c from Global_Data__c where
                        Local_Grade_Level__c in : setlocalGradeLevel AND
                        Country__c in : setCountry
                    ];
                } catch (System.QueryException oQe) {
                    ErrorLogUtility.logGeneralError(oQe, 'AccountHandler',
                        'updateUSEquivalentGradeLevel', 'SFDC CI');
                    return;
                }
                Map < EducationDataUtilKey, Global_Data__c > mapEducationDataUtil =
                    mapPrepareEducationDataUtil(lstGlobalData);
                Global_Data__c oGlobalData = null;
                for (Account oBenef: lstBenefToLoop) {
                    oGlobalData = mapEducationDataUtil.get(new EducationDataUtilKey(oBenef.Country__c,
                        oBenef.Local_Grade_Level__c));
                    oBenef.US_Equivalent_Grade_Level__c = (null == oGlobalData || (null !=
                        oGlobalData && String.IsEmpty(oGlobalData.US_Equivalent_Grade_Level__c)
                    )) ? null : oGlobalData.US_Equivalent_Grade_Level__c;
                }
            }

        }
        /**
        * Class name   : EducationDataUtilKey
        * Description  : Inner class which is used as a Key for mapEducationDataUtil. This oKey uniquely identifies Global Data Education object on the basis of
                         Country & Local Grade Level
        **/
    private class EducationDataUtilKey {
        public String sCountryKey;
        public String sLocalGradeLevelKey;

        public EducationDataUtilKey(String sCountryArg, String sLocalGradeLevelArg) {
            sCountryKey = (null == sCountryArg) ? Constants.NA : sCountryArg;
            sLocalGradeLevelKey = (null == sLocalGradeLevelArg) ? Constants.NA :
                sLocalGradeLevelArg;
        }

        /**
         * Method name  : hashCode
         * Description  : Overriding hashCode method so that this inner class can be effectively used as oKey of Map
         * Return Type  : Integer
         * Parameter    : void
         **/
        public Integer hashCode() {
            return sCountryKey.hashCode() + sLocalGradeLevelKey.hashCode();
        }

        /**
         * Method name  : equals
         * Description  : Overriding equals method so that this inner class can be effectively used as oKey of Map
         * Return Type  : Boolean
         * Parameter    : Object
         **/
        public Boolean equals(Object obj) {
            EducationDataUtilKey oGlobalDataUtilKey = (EducationDataUtilKey) obj;
            if (oGlobalDataUtilKey.sCountryKey.equals(sCountryKey) &&
                oGlobalDataUtilKey
                .sLocalGradeLevelKey.equals(sLocalGradeLevelKey))
                return true;
            else
                return false;
        }
    }

    /**
     * Method name  : mapPrepareEducationDataUtil
     * Description  : This method prepares educationDataUtil map whose oKey is inner class EducationDataUtilKey & value is correspondent Global_Data__c object
     * Return Type  : Map<EducationDataUtilKey,Global_Data__c>
     * Parameter    : List<Global_Data__c>
     **/
    private Map < EducationDataUtilKey, Global_Data__c >
        mapPrepareEducationDataUtil(List < Global_Data__c > lstGlobalData) {
            Map < EducationDataUtilKey, Global_Data__c > mapEducationDataUtil = new Map <
                EducationDataUtilKey, Global_Data__c > ();
            for (Global_Data__c oGlobalData: lstGlobalData) {
                EducationDataUtilKey oKey = new EducationDataUtilKey(oGlobalData.Country__c,
                    oGlobalData.Local_Grade_Level__c);
                mapEducationDataUtil.put(oKey, oGlobalData);
            }
            return mapEducationDataUtil;
        }

    /**
     * Method name  : updateLifecycleEvent
     * Description  : This method will update Suspension ICP lifecycle events Actual Suspension End Date with current date of ICP transion date
     * Return Type  : void
     * Parameter    : List<Account> , Map<ID,Account>
     **/
    private void updateLifecycleEvent(List < Account > lstNewRecords, Map < ID,
        Account > mapOldRecords, Map < ID, Account > mapNewRecords) {
        List < Account > lstICPConcerned = new List < Account > ();
        Set < Id > setICPId = new Set < Id > ();
        List < ICP_Lifecycle_Events__c > lstICPLifecycleEventsToUpdate = new List <
            ICP_Lifecycle_Events__c > ();
        Id icpRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);
        Id lifecycleSuspensionRecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            ICP_Lifecycle_Events__c.SObjectType, Constants.SUSPENSION_RT_API_NAME);
        Map < Id, Account > mapLEIdIdToIcpbj = new Map <
            Id, Account > ();
        for (Account oAcc: lstNewRecords) {
            if (oAcc.RecordTypeId == icpRecordTypeId && oAcc.ICP_Status__c !=
                mapOldRecords.get(oAcc.Id)
                .ICP_Status__c &&
                mapOldRecords.get(oAcc.Id)
                .ICP_Status__c == Constants.SUSPENDED) {

                setICPId.add(oAcc.id);
            }
        }
        if (!setICPId.isEmpty()) {
            lstICPConcerned = [Select Id, ICP_Status__c, (Select Id,
                    Actual_Suspension_End_Date__c from ICP_Lifecycle_Events__r where RecordTypeId = :
                    lifecycleSuspensionRecordTypeId ORDER BY CreatedDate DESC LIMIT 1) From Account where Id IN:
                setICPId
            ];
            for (Account oAcc: lstICPConcerned) {
                if (!oAcc.ICP_Lifecycle_Events__r.isEmpty()) {
                    ICP_Lifecycle_Events__c oICPLifecycleEvent = new ICP_Lifecycle_Events__c();
                    oICPLifecycleEvent.id = oAcc.ICP_Lifecycle_Events__r[0].Id;
                    oICPLifecycleEvent.Actual_Suspension_End_Date__c = System.Today();
                    oICPLifecycleEvent.Status__c = Constants.COMPLETED;
                    lstICPLifecycleEventsToUpdate.add(oICPLifecycleEvent);
                    if (oICPLifecycleEvent.Id != null && !mapLEIdIdToIcpbj.containsKey(
                            oICPLifecycleEvent.Id)) {
                        mapLEIdIdToIcpbj.put(oICPLifecycleEvent.Id, oAcc);
                    }
                }
            }
            if (!lstICPLifecycleEventsToUpdate.isEmpty()) {
                List < Database.SaveResult > lstUpdateResults =
                    Database.update(lstICPLifecycleEventsToUpdate, false);
                Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, lstICPLifecycleEventsToUpdate,
                    'ICP_Lifecycle_Events__c',
                    'AccountHandler', 'updateLifecycleEvent', 'SFDC CI', false
                );
                for (Id icpLEId: mapIdToErrorMsg.keySet()) {
                    if (mapLEIdIdToIcpbj.containsKey(icpLEId)) {
                        Id accountId = mapLEIdIdToIcpbj.get(
                            icpLEId).Id;
                        Account oAccount = mapNewRecords.get(accountId);
                        for (String sErrorMsg: mapIdToErrorMsg.get(icpLEId)) {
                            oAccount.addError(System.Label.Error_On_ICP_Lifecycle_Event + sErrorMsg);
                        }
                    }
                }
            }
        }


    }

    /**
     * Method name  : concatenateICPIDLocalBeneficiaryNumber
     * Description  : This method will check concatenate ICP ID and Local Beneficiary Number to create Local Beneficiary ID and check for Duplication
     * Return Type  : void
     * Parameter    : List<Account> , Map<ID,Account>
     **/
    private void concatenateICPIDLocalBeneficiaryNumber(List < Account >
        lstNewRecords, Map < ID, Account > mapOldRecords) {
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);
        Id reinstatementRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_REINSTATEMENT_RETURN_RT_API_NAME
        );
        Id transferRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSFER_RT_API_NAME
        );
        Map < String, Account > mapAccount = new Map < String, Account > ();
        Set < Id > setAccountId = new Set < Id > ();
        Map < String, String > mapLocalBeneficiary = new Map < String, String > ();
        Set < String > setICPId = new Set < String > ();
        for (Account oAccount: lstNewRecords) {
            if (String.isEmpty(oAccount.Local_Beneficiary_Number__c) && (oAccount.RecordTypeId ==
                    cdspRecTypeId || oAccount.RecordTypeId == cspRecTypeId) && oAccount.Beneficiary_Status__c ==
                Constants.ACTIVE) {
                oAccount.Local_Beneficiary_Number__c.addError(System.Label.Error_Local_Beneficiary_Number_Is_Mandatory);
            } else if (String.isEmpty(oAccount.Local_Beneficiary_Number__c) && (
                    oAccount.RecordTypeId == cdspRecTypeId || oAccount.RecordTypeId ==
                    cspRecTypeId) && oAccount.Beneficiary_Status__c != Constants.ACTIVE) {

                oAccount.Local_Beneficiary_Id__c = Constants.EMPTY_STRING;
            } else if ((trigger.isInsert && (oAccount.RecordTypeId == cdspRecTypeId ||
                    oAccount.RecordTypeId == cspRecTypeId)) ||
                (String.isNotEmpty(oAccount.Local_Beneficiary_Number__c) &&
                    (oAccount.RecordTypeId == cdspRecTypeId || oAccount.RecordTypeId ==
                        cspRecTypeId) && (oAccount.ICP__c != mapOldRecords.get(oAccount.Id)
                        .ICP__c || oAccount.Local_Beneficiary_Number__c != mapOldRecords.get(
                            oAccount.Id)
                        .Local_Beneficiary_Number__c))) {
                setAccountId.add(oAccount.ICP__c);
            }
        }
        if (!setAccountId.isEmpty()) {
            Map < Id, Account > mapIdToAccount = null;
            mapIdToAccount = new Map < Id, Account > ([Select Id,
                ICP_ID__c From Account where RecordTypeId = : icpRecTypeId AND Id IN:
                setAccountId
            ]);
            if (!mapIdToAccount.isEmpty()) {
                for (Account oAccount: mapIdToAccount.values()) {
                    setICPId.add(oAccount.ICP_ID__c);
                }
                for (Account oAccount: lstNewRecords) {
                    if (setAccountId.contains(oAccount.ICP__c)) {
                        String sLocalBeneficiaryNo = oAccount.Local_Beneficiary_Number__c;
                        if (sLocalBeneficiaryNo.length() == 1) {
                            sLocalBeneficiaryNo = Constants.OOO + sLocalBeneficiaryNo;
                        } else if (sLocalBeneficiaryNo.length() == 2) {
                            sLocalBeneficiaryNo = Constants.OO + sLocalBeneficiaryNo;
                        } else if (sLocalBeneficiaryNo.length() == 3) {
                            sLocalBeneficiaryNo = Constants.O + sLocalBeneficiaryNo;
                        }
                        if (!mapLocalBeneficiary.containsKey(oAccount.Local_Beneficiary_Number__c)) {
                            mapLocalBeneficiary.put(oAccount.Local_Beneficiary_Number__c,
                                sLocalBeneficiaryNo);
                        }
                        if (mapIdToAccount.get(oAccount.ICP__c)
                            .ICP_ID__c != null) {
                            oAccount.Local_Beneficiary_ID__c = mapIdToAccount.get(oAccount.ICP__c)
                                .ICP_ID__c + sLocalBeneficiaryNo;
                            if ((trigger.isInsert || (oAccount.Local_Beneficiary_ID__c !=
                                    mapOldRecords.get(oAccount.Id)
                                    .Local_Beneficiary_ID__c)) && TriggerContextUtility.isFirstRun()) {
                                TriggerContextUtility.setFirstRunFalse();
                                if (mapAccount.containsKey(oAccount.Local_Beneficiary_ID__c)) {
                                    oAccount.Local_Beneficiary_Number__c.addError(System.Label.Error_Local_Beneficiary_Id_For_New_Account);
                                } else {
                                    mapAccount.put(oAccount.Local_Beneficiary_ID__c, oAccount);
                                }
                            }
                        }
                    }
                }
            }
            if (TriggerContextUtility.isTransferBLEFirstRun()) {
                TriggerContextUtility.setTransferBLEFirstRunFalse();
                if (!mapAccount.isEmpty()) {
                    List < Account > lstAccount =
                        new List < Account > ();
                    lstAccount = [SELECT Local_Beneficiary_ID__c FROM Account WHERE(
                            RecordTypeId = : cdspRecTypeId OR RecordTypeId = :
                            cspRecTypeId) AND ICP__r.ICP_ID__c IN: setICPId AND
                        Local_Beneficiary_ID__c IN: mapAccount.KeySet() Limit 5000
                    ];
                    for (Account oAccount: lstAccount) {
                        Account oNewAccount = mapAccount.get(oAccount.Local_Beneficiary_ID__c);
                        oNewAccount.Local_Beneficiary_Number__c.addError(System.Label.Error_Local_Beneficiary_Id_For_Existing_Account);
                    }
                }
                if (!mapLocalBeneficiary.isEmpty()) {
                    checkBLEForDuplication(mapLocalBeneficiary, setAccountId,
                        reinstatementRecTypeId, transferRecTypeId, mapAccount);
                }
            }
        }
    }

    /**
     * Method name  : checkBLEForDuplication
     * Description  : This method will check Beneficiary Lifecycle Event records of transfer and reinstatement for duplication of Local Beneficiary Number
     * Return Type  : void
     * Parameter    : Map<String,String> ,Set<Id> , Id , Id , Map<String, Account> 
     **/
    private void checkBLEForDuplication(Map < String, String > mapLocalBeneficiary,
        Set < Id > setAccountId, Id reinstatementRecTypeId, Id transferRecTypeId,
        Map < String, Account > mapAccount) {
        List < Beneficiary_Lifecycle_Event__c > lstBLE =
            new List < Beneficiary_Lifecycle_Event__c > ();
        List < Beneficiary_Lifecycle_Event__c > lstBLE1 =
            new List < Beneficiary_Lifecycle_Event__c > ();
        try {
            lstBLE = [select RecordTypeId,
                New_Local_Beneficiary_Number__c, Beneficiary__r.ICP__r.ICP_ID__c,
                New_Current_ICP__r.ICP_ID__c From Beneficiary_Lifecycle_Event__c Where Status__c !=
                : Constants.CLOSED And(Beneficiary__r.ICP__c IN: setAccountId Or New_Current_ICP__c IN:
                    setAccountId) AND(RecordTypeId = : reinstatementRecTypeId OR RecordTypeId = :
                    transferRecTypeId) AND New_Local_Beneficiary_Number__c IN:
                mapLocalBeneficiary.KeySet()
            ];
        } catch (System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'AccountHandler',
                'checkBLEForDuplication', 'SFDC CI');
            return;
        }
        for (Beneficiary_Lifecycle_Event__c oBleRecords: lstBLE) {
            if (String.isNotEmpty(oBleRecords.New_Local_Beneficiary_Number__c)) {
                String sBleLocalBeneficiaryId = '';
                if (oBleRecords.RecordTypeId == reinstatementRecTypeId &&
                    mapLocalBeneficiary.containsKey(oBleRecords.New_Local_Beneficiary_Number__c)
                ) {
                    sBleLocalBeneficiaryId = oBleRecords.Beneficiary__r.ICP__r.ICP_ID__c +
                        mapLocalBeneficiary.get(oBleRecords.New_Local_Beneficiary_Number__c);
                }
                if (oBleRecords.RecordTypeId == transferRecTypeId && mapLocalBeneficiary.containsKey(
                        oBleRecords.New_Local_Beneficiary_Number__c)) {
                    sBleLocalBeneficiaryId = oBleRecords.New_Current_ICP__r.ICP_ID__c +
                        mapLocalBeneficiary.get(oBleRecords.New_Local_Beneficiary_Number__c);
                    if (mapAccount.containsKey(sBleLocalBeneficiaryId) && oBleRecords.Beneficiary__c ==
                        mapAccount.get(sBleLocalBeneficiaryId)
                        .Id) {
                        sBleLocalBeneficiaryId = '';
                    }
                }
                if (mapAccount.containsKey(sBleLocalBeneficiaryId)) {
                    Account oNewAccount = mapAccount.get(sBleLocalBeneficiaryId);
                    oNewAccount.Local_Beneficiary_Number__c.addError(System.Label.Error_New_Local_Beneficiary_Number_For_BLE);
                }
            }
        }
    }

    /**
     * Method name  : checkRegistrationDateLimit
     * Description  : This method will check if Registration Date is not more than 4 months from today's date for CSP and CDSP Beneficiary.
     * Return Type  : void
     * Parameter    : List<Account>
     **/
    private void checkRegistrationDateLimit(List < Account > lstNewRecords) {
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        for (Account oBenef: lstNewRecords)
            if ((oBenef.RecordTypeId.equals(cdspRecTypeId)) && (null != oBenef.Actual_Registration_Date__c &&
                    oBenef.Actual_Registration_Date__c.addDays(120) < System.today()))
                oBenef.addError(System.label.Registration_Date_Limit);
    }

    /**
     * Method name  : checkFirstNameOnCDSP
     * Description  : This method is to make CDSP Beneficiary's FirstName mandatory when the Beneficiary record is inserted or updated.
     * Return Type  : void
     * Parameter    : List<Account>
     **/
    private void checkFirstNameOnCDSP(List < Account > lstNewRecords) {
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        for (Account oBenef: lstNewRecords)
            if (oBenef.RecordTypeId.equals(cdspRecTypeId) && String.isEmpty(oBenef.FirstName))
                oBenef.addError(System.label.CDSP_First_Name_Mandatory);
    }

    /**
    * Method name  : preventLocalBeneficiaryNumberDelete
    * Description  : This method will prevent user from removing local beneficiary number if there exists
                     a reinstatement record with blank local beneficiary number for this beneficiary
    * Return Type  : void
    * Parameter    : List<Account>
    **/
    private void preventLocalBeneficiaryNumberDelete(List < Account >
        lstNewRecords) {
        Id reinstatementRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_REINSTATEMENT_RETURN_RT_API_NAME
        );
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Set < Id > setBeneficiaryId = new Set < Id > ();
        for (Account oAccount: lstNewRecords) {
            if (String.isEmpty(oAccount.Local_Beneficiary_Number__c) && (oAccount.RecordTypeId ==
                    cdspRecTypeId || oAccount.RecordTypeId == cspRecTypeId) && oAccount.Beneficiary_Status__c ==
                Constants.INACTIVE) {

                setBeneficiaryId.add(oAccount.Id);
            }
        }
        if (!setBeneficiaryId.isEmpty()) {
            Map < Id, Account > mapBeneficiary = null;
            mapBeneficiary = new Map < Id, Account > ([select Id, (
                    select Id from Beneficiary_Lifecycle_Events__r Where Status__c != :
                    Constants.CLOSED AND recordTypeId = : reinstatementRecTypeId AND New_Local_Beneficiary_Number__c =
                    null ORDER BY CreatedDate DESC LIMIT 1) From Account where Id IN:
                setBeneficiaryId
            ]);
            for (Account oAccount: lstNewRecords) {
                if (mapBeneficiary.containsKey(oAccount.Id) &&
                    !mapBeneficiary.get(oAccount.Id)
                    .Beneficiary_Lifecycle_Events__r.isEmpty()) {

                    oAccount.addError(System.Label.Error_Reinstatement_Exists);
                }
            }
        }
    }

    /**
     * Method name  : updatePrimaryCaregiver
     * Description  : This method is to update Primary Caregiver for a Beneficiary based on the Household associated.
     * Return Type  : void
     * Parameter    : List<Account>, Map<Id, Account>
     **/
    private void updatePrimaryCaregiver(List < Account > lstNewRecords, Map <
        Id, Account > mapOldRecords) {
        if (TriggerContextUtility.bPrimaryCaregiverFirstRun) {
            TriggerContextUtility.setPrimaryCaregiverFirstRunFalse();
            Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.CDSP_BENEFICIARY_RT_API_NAME);
            Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.CSP_BENEFICIARY_RT_API_NAME);
            set < Id > setHouseholdIds = new set < Id > ();
            list < Household_Member__c > lstHouseholdMember = new list <
                Household_Member__c > ();
            map < Id, Household_Member__c > mapHouseholdMember = new map < Id,
                Household_Member__c > ();
            for (Account oBenef: lstNewRecords) {
                if ((oBenef.RecordTypeId.equals(cdspRecTypeId) || oBenef.RecordTypeId.equals(
                        cspRecTypeId)) && String.isNotEmpty(oBenef.Household__c) && (trigger.IsInsert ||
                        ((oBenef.Beneficiary_Status__c != mapOldRecords.get(oBenef.Id)
                            .Beneficiary_Status__c) || (oBenef.Household__c != mapOldRecords.get(
                                oBenef.Id)
                            .Household__c) || (oBenef.Primary_Caregiver__c != mapOldRecords.get(
                                oBenef.Id)
                            .Primary_Caregiver__c)) &&
                        !(oBenef.Beneficiary_Status__c.equals(Constants.INACTIVE) &&
                            mapOldRecords.get(oBenef.Id)
                            .Beneficiary_Status__c.equals(Constants.ACTIVE)))) {
                    setHouseholdIds.add(oBenef.Household__c);
                }
            }
            if (!setHouseholdIds.isEmpty()) {
                lstHouseholdMember = [SELECT id, Name, Is_Primary_Caregiver__c,
                    Household__c from Household_Member__c WHERE
                    Household__c in : setHouseholdIds AND Is_Primary_Caregiver__c = true
                ];
            }
            if (!lstHouseholdMember.isEmpty()) {
                for (Household_Member__c oHM: lstHouseholdMember) {
                    if (!mapHouseholdMember.containsKey(oHM.Household__c))
                        mapHouseholdMember.put(oHM.Household__c, oHM);
                }
            }
            if (!mapHouseholdMember.isEmpty()) {
                for (Account oBenef: lstNewRecords) {
                    if (mapHouseholdMember.containsKey(oBenef.Household__c)) {
                        oBenef.Primary_Caregiver__c = (mapHouseholdMember.get(oBenef.Household__c))
                            .Id;
                    }
                }
            }
            for (Account oBenef: lstNewRecords) {
                if (trigger.isUpdate && (oBenef.RecordTypeId.equals(cdspRecTypeId) ||
                        oBenef.RecordTypeId.equals(cspRecTypeId)) &&
                    (oBenef.Household__c == NULL || mapHouseholdMember.get(oBenef.Household__c) ==
                        NULL) &&
                    !(oBenef.Beneficiary_Status__c.equals(Constants.INACTIVE) &&
                        mapOldRecords.get(oBenef.Id)
                        .Beneficiary_Status__c.equals(Constants.ACTIVE)) &&
                    (oBenef.Household__c != mapOldRecords.get(oBenef.Id)
                        .Household__c)) {
                    oBenef.Primary_Caregiver__c = NULL;
                }
            }
        }
    }

    /**
     * Method name  : updateFieldOfficeForHouseholdOnBenefUpdate
     * Description  : This method updates FO for Sharing Rule backend field of Household whenever the Household field on a Beneficiary is updated
     * Return Type  : void
     * Parameter    : List<Household_Member__c>
     **/
    private void updateFieldOfficeForHouseholdOnBenefUpdate(List < Account >
        lstNewRecords, Map <
        Id, Account > mapOldRecords) {
        set < Id > setHouseholdsToQuery = new set < Id > ();
        map < Id, set < String >> mapHouseholdToFO = new map < Id, set < String >> ();
        Map < Id, Account > mapIdToOldBenef = new Map < Id, Account > ();
        list < Household__c > lstHouseholdWithFO = new list < Household__c > ();
        list < Household__c > lstHouseholdToUpdate = new list < Household__c > ();
        String sFO;
        list < String > lstAllFOs;
        for (Account oBenef: lstNewRecords) {
            if (mapOldRecords.get(oBenef.id)
                .Household__c != oBenef.Household__c) {
                if (mapOldRecords.get(oBenef.id).Household__c != NULL) {
                    setHouseholdsToQuery.add(mapOldRecords.get(oBenef.id)
                        .Household__c);
                }
                setHouseholdsToQuery.add(oBenef.Household__c);
            }
        }
        if (!setHouseholdsToQuery.isEmpty()) {
            mapIdToOldBenef = new Map < Id, Account > ([SELECT id, FO__c, Household__c,
                Household__r.Field_Office_For_Sharing_Rule__c from Account
                where Household__c in : setHouseholdsToQuery and Household__c != null
            ]);

        }
        for (Account oBenef: mapIdToOldBenef.values()) {
            if (mapHouseholdToFO.get(oBenef.Household__c) == NULL) {
                set < String > setFO = new set < String > ();
                setFO.add(oBenef.FO__c);
                mapHouseholdToFO.put(oBenef.Household__c, setFO);
            } else {
                set < String > setFO = mapHouseholdToFO.get(oBenef.Household__c);
                setFO.add(oBenef.FO__c);
                mapHouseholdToFO.put(oBenef.Household__c, setFO);
            }
        }
        if (!mapHouseholdToFO.isEmpty()) {
            lstHouseholdWithFO = [SELECT id, Field_Office_For_Sharing_Rule__c from Household__c where id in
                : mapHouseholdToFO.keyset()
            ];
        }
        if (!lstHouseholdWithFO.isEmpty()) {
            for (Household__c oHousehold: lstHouseholdWithFO) {
                lstAllFOs = new list < String > (mapHouseholdToFO.get(oHousehold.Id));
                lstAllFOs.sort();
                sFO = String.join(lstAllFOs, ';');
                if (oHousehold.Field_Office_For_Sharing_Rule__c != NULL && !oHousehold.Field_Office_For_Sharing_Rule__c
                    .equals(sFO)) {
                    oHousehold.Field_Office_For_Sharing_Rule__c = sFO;
                    lstHouseholdToUpdate.add(oHousehold);
                } else if (oHousehold.Field_Office_For_Sharing_Rule__c == NULL) {
                    oHousehold.Field_Office_For_Sharing_Rule__c = sFO;
                    lstHouseholdToUpdate.add(oHousehold);
                } else if (sFO == NULL) {
                    oHousehold.Field_Office_For_Sharing_Rule__c = NULL;
                    lstHouseholdToUpdate.add(oHousehold);
                }
            }
        }

        if (!lstHouseholdToUpdate.isEmpty()) {
            List < Database.SaveResult > lstUpdateResults =
                Database.update(lstHouseholdToUpdate, false);
            ErrorLogUtility.logDMLError(lstUpdateResults, lstHouseholdToUpdate,
                'Account',
                'AccountHandler',
                'updateFieldOfficeForHouseholdOnBenefUpdate', 'SFDC CI', false);
            System.debug('After Update');
        }
    }

    /**
    * Method name  : updateFieldOfficeForHouseholdOnBenefInsert
    * Description  : This method updates FO for Sharing Rule backend field of Household whenever Beneficiary is inserted
                     and associated to a Household which was not created by a FO User
    * Return Type  : void
    * Parameter    : List<Household_Member__c>
    **/
    private void updateFieldOfficeForHouseholdOnBenefInsert(List < Account >
            lstNewRecords) {

            set < Id > setHouseholdToQuery = new set < Id > ();
            map < Id, String > mapHouseholdToFO = new map < Id, String > ();
            list < Household__c > lstHouseholdToUpdate = new list < Household__c > ();
            for (Account oBenef: lstNewRecords) {
                setHouseholdToQuery.add(oBenef.Household__c);
                mapHouseholdToFO.put(oBenef.Household__c, oBenef.FO__c);
            }

            lstHouseholdToUpdate = [SELECT id, Field_Office_For_Sharing_Rule__c from Household__c where id in
                : setHouseholdToQuery AND Field_Office_For_Sharing_Rule__c = : NULL
            ];

            for (Household__c oHousehold: lstHouseholdToUpdate) {
                oHousehold.Field_Office_For_Sharing_Rule__c = mapHouseholdToFO.get(
                    oHousehold.Id);
            }

            if (!lstHouseholdToUpdate.isEmpty()) {
                List < Database.SaveResult > lstUpdateResults =
                    Database.update(lstHouseholdToUpdate, false);
                ErrorLogUtility.logDMLError(lstUpdateResults, lstHouseholdToUpdate,
                    'Account',
                    'AccountHandler',
                    'updateFieldOfficeForHouseholdOnBenefInsert', 'SFDC CI', false);
                System.debug('After Update');
            }
        }
   
    /**
    * Method name  :  validateICPBeneficiaryForPortal
    * Description  : This method validated that portal user should not be allowed to create beneficiary for
                     any ICP and can create beneficiary for his/her own ICP.
    * Return Type  : void
    * Parameter    : List<Account>
    
    **/
    private void validateICPBeneficiaryForPortal(List < Account >
        lstNewRecords) {
        if (UserInfo.getUSerType() == Constants.POWERPARTNER) {
            User oCurrentuser = [Select Accountid from User where id = : UserInfo.getUserId()];
            for (Account oAcc: lstNewRecords) {            
                if (oCurrentuser.Accountid != oAcc.ICP__c) {
                    oAcc.adderror(System.Label.AccountHandler_Create_Beneficiary_Error_For_ICP);
                }
            }
        }
    }
    
    /**
    * Method name  : shareBeneficiaryWithICPUser
    * Description  : This method share the Beneficiary with ICP Portal Users 
                     on Insert and during transfer. For transfer it will also 
                     delete the record from sharing Object.
    * Return Type  : void
    * Parameter    : List<Account>, Map <Id, Account>
    **/
    private void shareBeneficiaryWithICPUser(List < Account > lstNewRecords, Map <        
        Id, Account > mapOldRecords) {
        Boolean bInsert = false;
        if(trigger.isInsert)
            bInsert = true;
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,Constants.CSP_BENEFICIARY_RT_API_NAME);
        Set<Id> setICPId = new Set<Id>();
        Set<Id> setBenefIdForDelete = new Set<Id>();
        Map<Id, Id> mapHouseholdIdToICPId = new Map<Id, Id>();
        Set<Id> setHouseholdIdToDelete = new Set<Id>();
        Set<Id> setPreviousICP = new Set<Id>();
        
        for (Account oAccount: lstNewRecords){
            if(cdspRecTypeId.equals(oAccount.RecordTypeId) || cspRecTypeId.equals(oAccount.RecordTypeId)){
                if(trigger.isInsert){
                    setICPId.add(oAccount.ICP__c);
                }
                else if(trigger.isUpdate && oAccount.ICP__c == mapoldRecords.get(oAccount.Id).ICP__c && oAccount.Household__c != mapoldRecords.get(oAccount.Id).Household__c){
                    setICPId.add(oAccount.ICP__c);
                    if(!String.isEmpty(mapoldRecords.get(oAccount.Id).Household__c)){
                        setHouseholdIdToDelete.add(mapoldRecords.get(oAccount.Id).Household__c);
                        mapHouseholdIdToICPId.put(mapoldRecords.get(oAccount.Id).Household__c, mapoldRecords.get(oAccount.Id).ICP__c);
                        setPreviousICP.add(oAccount.ICP__c);
                    }
                }
                else if(trigger.isUpdate && oAccount.ICP__c != mapoldRecords.get(oAccount.Id).ICP__c){
                    setICPId.add(oAccount.ICP__c);
                    setBenefIdForDelete.add(oAccount.Id);
                    if (!String.isEmpty(mapoldRecords.get(oAccount.Id).Household__c)){
                        setHouseholdIdToDelete.add(mapoldRecords.get(oAccount.Id).Household__c);
                        mapHouseholdIdToICPId.put(mapoldRecords.get(oAccount.Id).Household__c, mapoldRecords.get(oAccount.Id).ICP__c);
                        setPreviousICP.add(mapoldRecords.get(oAccount.Id).ICP__c);
                    }
                }
            }
        }
        if(!setICPId.isEmpty() && !Test.isRunningTest()){
            System.enqueueJob(new QueueDeleteRecordsBeforeBenefShare(lstNewRecords, mapOldRecords, bInsert, setICPId, setHouseholdIdToDelete, mapHouseholdIdToICPId, setPreviousICP, setBenefIdForDelete));
        }
    }

    /**
     * Method name  : deleteCommunicationKit
     * Description  : 
     * Return Type  : void
     * Parameter    : Map<Id,Account> , Map<Id,Account>
     **/
    private static void deleteCommunicationKit(map < Id, Account > mapTriggerNew,
            map < Id, Account > mapTriggerOld) {
            set < Id > setBenIdsForCommKitDelete = new set < Id > ();
            set < Id > setBenIdsForCommKitUpdateOrDelete = new set < Id > ();
            for (Account oAcc: mapTriggerNew.Values()) {
                if (oAcc.Beneficiary_Status__c == Constants.INACTIVE && oAcc.Beneficiary_Status__c !=
                    mapTriggerOld.get(oAcc.Id).Beneficiary_Status__c)
                    {
                    setBenIdsForCommKitDelete.add(oAcc.Id);
                    }
                 Else if(oAcc.Sponsorship_Status__pc == Constants.BENEFICIARY_UNSPONSORED &&
                      oAcc.Sponsorship_Status__pc !=mapTriggerOld.get(oAcc.Id).Sponsorship_Status__pc)
                    {
                    setBenIdsForCommKitDelete.add(oAcc.Id);  
                    }       
                  
            }
            system.debug('<><><>setBenIdsForCommKitDelete ' + setBenIdsForCommKitDelete);
            list < Communication_Kit__c > lstCommKit = new list < Communication_Kit__c >
                ();
            try {
                lstCommKit = [select Id, Communication_Types__c, BEN_Id__c from Communication_Kit__c where
                        BEN_Id__c IN: setBenIdsForCommKitDelete AND (Status__c = :
                        Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED OR Status__c = :
                        Constants.COMMUNICATION_KIT_STATUS_LETTER_MARKED_FOR_REWORK) AND RecordTypeId = :
                    CommunicationKitHandler.sRecordTypeB2S
                ];
            } catch (System.QueryException oQe) {
                ErrorLogUtility.logGeneralError(oQe, 'AccountHandler',
                    'deleteCommunicationKit', 'SFDC CI');
            }
            list < Communication_Kit__c > lstCommKitToDel = new list <
                Communication_Kit__c > ();
      /* MV : Modified the logic to delete all B2S 'Ready to be Printed' and 'Marked for rework' letters */     
            for (Communication_Kit__c oCommKit: lstCommKit) {
                if (setBenIdsForCommKitDelete.contains(oCommKit.BEN_Id__c))
                    lstCommKitToDel.add(oCommKit);               
            }
            if (lstCommKitToDel.size() > 0)
            try{
                delete lstCommKitToDel;
                }catch(Exception oEx){
                 ErrorLogUtility.logGeneralError(oEx,'AccountHandler','deleteCommunicationKit','SFDC CI');                
                }          
        }
        /**
         * Method name  : commKitOnICPTransition
         * Description  : This method will delete any pending scheduled letters when ICP is transitioned
         * Return Type  : void
         * Parameter    : Map<Id,Account> , Map<Id,Account>
         **/
    private static void commKitOnICPTransition(map < Id, Account > mapTriggerNew,
        map < Id, Account > mapTriggerOld) {
        set < Id > setICPIdsForCommKit = new set < Id > ();
        for (Account oAcc: mapTriggerNew.Values()) {
            if (oAcc.ICP_Status__c == Constants.ICP_STATUS_TRANSITIONED && oAcc.ICP_Status__c !=
                mapTriggerOld.get(oAcc.Id).ICP_Status__c)
                setICPIdsForCommKit.add(oAcc.Id);
        }
        list < Communication_Kit__c > lstCommKit = new list < Communication_Kit__c >
            ();
        try {
            lstCommKit = [select Id, Communication_Types__c from Communication_Kit__c where BEN_ID__r.ICP__c IN: setICPIdsForCommKit AND(Status__c = :
                    Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED OR Status__c = :
                    Constants.COMMUNICATION_KIT_STATUS_LETTER_MARKED_FOR_REWORK)
            ];
        } catch (System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'AccountHandler',
                'commKitOnICPTransition', 'SFDC CI');
        }
        for (Communication_Kit__c oCommKit: lstCommKit) {
            if (oCommKit.Communication_Types__c != null && oCommKit.Communication_Types__c
                .contains(Constants.CORRESPONDENCE_ITEM_TYPE_SCHEDULED_LETTER)) {
                oCommKit.Communication_Types__c = oCommKit.Communication_Types__c.remove(
                    Constants.CORRESPONDENCE_ITEM_TYPE_SCHEDULED_LETTER);
            }
        }
        if (!lstCommKit.isEmpty()) {
            List < Database.SaveResult > lstUpdateResults =
                Database.update(lstCommKit, false);
            Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstCommKit, 'Communication_Kit__c',
                'AccountHandler', 'commKitOnICPTransition', 'SFDC CI', false);
        }
    
    }
    /**
     * Method name  : updateCognitiveAgeGroup
     * Description  : This method will populate Cognitive Age Group based on Age in months if user not selects Cognitive Age Group.
     * Return Type  : void
     * Parameter    : List<Account> , Map<Id,Account>
     **/
    private void updateCognitiveAgeGroup(List < Account > lstNewRecords,
        Map < Id, Account > mapOldRecords) {
        try {
            Id cdspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.CDSP_BENEFICIARY_RT_API_NAME);
            Id cspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.CSP_BENEFICIARY_RT_API_NAME);
            List < Cognitive_Age_Group_Values__c > lstCognitiveAgeGroup =
                Cognitive_Age_Group_Values__c.getall()
                .values();

            Map < Integer, String > mapAgeCognitiveGrp = new Map < Integer, String >
                ();

            FOR(Cognitive_Age_Group_Values__c oCognitiveAgeGroup:
                lstCognitiveAgeGroup) {
                mapAgeCognitiveGrp.put((integer) oCognitiveAgeGroup.Age__c,
                    oCognitiveAgeGroup.Cognitive_Age_Group__c);

            }

            for (Account oAccount: lstNewRecords) {

                if ((cdspBenefRecTypeId.equals(oAccount.RecordTypeId) ||
                        cspBenefRecTypeId
                        .equals(oAccount.RecordTypeId)) &&
                    null != oAccount.Age__c && ((Trigger.isInsert && oAccount.Cognitive_Age_Group__c ==
                            null) || (Trigger.isUpdate) &&
                        (oAccount.Age__c != (mapOldRecords.get(oAccount.Id)
                            .Age__c) && oAccount.Cognitive_Age_Group__c == (mapOldRecords.get(
                                oAccount.Id)
                            .Cognitive_Age_Group__c)) || (oAccount.Cognitive_Age_Group__c ==
                            null))
                ) {
                    if (oAccount.Age__c >= 19) {
                        oAccount.Cognitive_Age_Group__c = Label.Cognitive_Age_Group_Picklist_Value;
                    } else {

                        oAccount.Cognitive_Age_Group__c = mapAgeCognitiveGrp.get((integer) oAccount
                            .Age__c);

                    }
                }
            }

        } catch (Exception e) {
            ErrorLogUtility.logGeneralError(e, 'AccountHandler',
                'updateCognitiveAgeGroup', 'SFDC CI');
        }
    }
     /**
    * Method name  : updateIsOrphanOnAccount
    * Description  : This method will set Is Orphan checkbox to True if Parents of the beneficiary are not alive.
    * Return Type  : void
    * Parameter    : List<Account>
    **/
    private void updateIsOrphanOnAccount(List <Account> lstNewRecords){
        Set <Id> setHouseHoldIds = new Set <Id>();
        Map <Id,HouseHold__c> mapIDHousehold;
        try{
            for(Account oAccount : lstNewRecords){
                setHouseHoldIds.add(oAccount.Household__c);
            }
            mapIDHousehold = new Map < Id,Household__c > ([Select Id,Natural_Father_IsAlive__c,
                    Natural_Mother_IsAlive__c From Household__c Where Id IN:setHouseHoldIds]);    
            for(Account oAccount: lstNewRecords){
                if(mapIDHousehold.containsKey(oAccount.Household__c) && 
                    mapIDHousehold.get(oAccount.Household__c).Natural_Father_IsAlive__c == Constants.NO &&
                    mapIDHousehold.get(oAccount.Household__c).Natural_Mother_IsAlive__c == Constants.NO){
                        oAccount.Is_Orphan__c = True;
                } else {
                    oAccount.Is_Orphan__c = False;
                }
            }
        }catch (Exception e) {
            ErrorLogUtility.logGeneralError(e, 'AccountHandler',
                'updateIsOrphanOnAccount', 'SFDC CI');
        }
    }

        
     /**
     * Method name  : sendBenefUpdateToUS
     * Description  : This method will send update to US if specified condition is satisfied
     * Return Type  : void
     * Parameter    : Map<Id,Account> , Map<Id,Account>
     **/
        private void sendBenefUpdateToUS(Map<Id,Account> mapNewTrigger, Map<Id,Account> mapOldTrigger){

            Set<Id> setBenefIDToUpdate = new Set<Id>();
            List<Account> lstFlagUpdate = new List<Account>();
            Account oNewBenef = null;
            Account oOldBenef = null;
            Id cdspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                    Constants.CDSP_BENEFICIARY_RT_API_NAME);
            Id cspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                    Constants.CSP_BENEFICIARY_RT_API_NAME);
            Boolean bICPUser = UserInfo.getUserType().equals(Label.PowerPartner);
            Set<Id> setBenefIdsSentToUS = TriggerContextUtility.setBenefIdsSentToUS;
            for(Id benefID : mapNewTrigger.keySet()){
                oNewBenef = mapNewTrigger.get(benefID);
                oOldBenef = mapOldTrigger.get(benefID);
                if((oNewBenef.RecordTypeId.equals(cdspBenefRecTypeId) || oNewBenef.RecordTypeId.equals(cspBenefRecTypeId)) 
                    && oNewBenef.No_Of_Active_Commitments__c > 0
                    && !setBenefIdsSentToUS.contains(benefID)
                    && Label.Active.equals(oNewBenef.Beneficiary_Status__c)
                    && (oNewBenef.Local_Beneficiary_Number__c!=oOldBenef.Local_Beneficiary_Number__c 
                        || oNewBenef.Compass_Id__c!=oOldBenef.Compass_Id__c
                        || oNewBenef.BillingCountry!=oOldBenef.BillingCountry
                        || oNewBenef.Correspondence_Language__c!=oOldBenef.Correspondence_Language__c
                        || (Label.Review_Status_Approved.equals(oNewBenef.Review_Status__c) && Label.Review_Status_Submitted.equals(oOldBenef.Review_Status__c))
                        || Label.Draft_Status.equals(oOldBenef.Beneficiary_Status__c)
                        || (!bICPUser && (oNewBenef.FirstName != oOldBenef.FirstName 
                            || oNewBenef.PersonBirthdate != oOldBenef.PersonBirthdate 
                            || oNewBenef.LastName != oOldBenef.LastName 
                            || oNewBenef.Local_Beneficiary_ID__c != oOldBenef.Local_Beneficiary_ID__c 
                            || oNewBenef.ICP__c != oOldBenef.ICP__c 
                            || oNewBenef.Gender__c != oOldBenef.Gender__c)))){
                                setBenefIDToUpdate.add(benefID);
                                setBenefIdsSentToUS.add(benefID);                                                              
                }
            } 
          
            System.debug('setBenefIDToUpdate '+setBenefIDToUpdate);
               if(!setBenefIDToUpdate.isEmpty()){
                Integer iStartIndexToCopy = 0;
                List<Id> lstBenefIDToSend = new List<Id>(setBenefIDToUpdate);
                Integer iRemBenefToSend = lstBenefIDToSend.size();
                List<Id> lstBenefToSend = null;
                while(iRemBenefToSend > 0){
                    lstBenefToSend = new List<Id>();
                    Integer iEndIndexToCopy = (iRemBenefToSend < = 50)?iStartIndexToCopy+iRemBenefToSend:iStartIndexToCopy+50;
                    for(Integer i = iStartIndexToCopy; i < iEndIndexToCopy; i++){
                        lstBenefToSend.add(lstBenefIDToSend.get(i));
                    }
                    iRemBenefToSend -= 50;
                    iStartIndexToCopy += 50;
                    iRemBenefToSend = (iRemBenefToSend<50)?Math.mod(iRemBenefToSend,50):iRemBenefToSend;
                    System.debug('Calling SendBenefInfoToUS from AccountHandler with following lstBenefToSend:'+lstBenefToSend);
                    System.enqueueJob(new SendBenefInfoToUS(new Set<Id>(lstBenefToSend)));
                }     
            }
    }

    /**
    * Method name  : updateRvwStsOnBenefIfEmpty
    * Description  : This method will set default Review status based on logged in User
    * Return Type  : void
    * Parameter    : List<Account>
    **/
    private void updateRvwStsOnBenefIfEmpty(List<Account> lstNewRecords){
        Id cdspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                    Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id cspBenefRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                    Constants.CSP_BENEFICIARY_RT_API_NAME);
        for(Account oBenef : lstNewRecords){
            if(String.isEmpty(oBenef.Review_Status__c)){
                if(cdspBenefRecTypeId.equals(oBenef.RecordTypeId)){
                    oBenef.Review_Status__c = (UserInfo.getUserType().equals(Label.PowerPartner))?
                                            Label.Review_Status_Not_Submitted : Label.Review_Status_Approved;
                }
            }
        }
    }
    
    /**
    * Method name  : copyICPDetailsToICPMiniProfile
    * Description  : This method will Copy ICP details to ICP Mini Profile object.
    * Return Type  : void
    * Parameter    : List<Account> , Map<Id,Account>
    **/ 
    private void copyICPDetailsToICPMiniProfile(List<Account> lstnewRecords, Map<Id, Account> mapOldRecords){
        Id icpRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);
        List<ICP_Mini_Profile__c> lstICPMiniProfileToUpsert = new List<ICP_Mini_Profile__c>();
        for(Account oAccount: lstNewRecords){
            if(icpRecordTypeId.equals(oAccount.RecordTypeId) && (trigger.isInsert || 
                (trigger.isUpdate && (oAccount.Name != mapOldRecords.get(oAccount.Id).Name || 
                oAccount.ICP_Status__c != mapOldRecords.get(oAccount.Id).ICP_Status__c || 
                oAccount.RecordTypeId != mapOldRecords.get(oAccount.Id).RecordTypeId ||
                oAccount.Field_Office__c != mapOldRecords.get(oAccount.Id).Field_Office__c || 
                oAccount.ICP_Id__c != mapOldRecords.get(oAccount.Id).ICP_Id__c)))){
                ICP_Mini_Profile__c oICPMiniProfile = new ICP_Mini_Profile__c();
                oICPMiniProfile.ICP__c = oAccount.Id;
                oICPMiniProfile.Name = oAccount.Name;
                oICPMiniProfile.ICP_Status__c = oAccount.ICP_Status__c;
                oICPMiniProfile.Field_Office__c = oAccount.Field_Office__c;
                oICPMiniProfile.ICP_Id__c = oAccount.ICP_Id__c;
                lstICPMiniProfileToUpsert.add(oICPMiniProfile);         
            }
        }
        If(!lstICPMiniProfileToUpsert.isEmpty()){
            List<Database.UpsertResult> lstUpsertResults = 
                Database.upsert(lstICPMiniProfileToUpsert,ICP_Mini_Profile__c.ICP_ID__c.getDescribe().getSObjectField() ,false);
            
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpsertResults, lstICPMiniProfileToUpsert, 'ICP_Mini_Profile__c',
                'AccountHandler', 'copyICPDetailsToICPMiniProfile',
                'SFDC CI', false);
        }
    }
     /**
     * Method name  : updateConfessFlag
     * Description  : This method will update the value of 'Beneficiary Confessed Jesus As Savior' checkbox on the latest Exit BLE with the value of the checkbox in the CDSP account.
     * Return Type  : void
     * Parameter    : List<Account> , Map<Id, Account>
     **/
    private void updateConfessFlag(List<Account> lstNewRecords, Map<Id,
        Account> mapOldRecords) {
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id, Beneficiary_Lifecycle_Event__c> mapIDBLE;
        
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);

        Id planExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME
        );
        Id unplanExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_RT_API_NAME
        );
        Id planExitReadOnlyRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_READONLY_RT_API_NAME
        );
        Id unplanExitReadOnlyRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_READONLY_RT_API_NAME
        );
        List<Id> lstRecTypeIds = new List<Id> {
            planExitRecTypeId, unplanExitRecTypeId, planExitReadOnlyRecTypeId,
            unplanExitReadOnlyRecTypeId
        };

        try {

            for(Account oAccount: lstNewRecords) {
             if(oAccount.RecordTypeId.equals(cdspRecTypeId)){
             
                setAccountIds.add(oAccount.Id);
            }
            }

            List<Beneficiary_Lifecycle_Event__c> lstBLE = new List <
                Beneficiary_Lifecycle_Event__c>();

            lstBLE = [Select Beneficiary__c,
                Beneficiary_Confesses_Jesus_as_Savior__c From Beneficiary_Lifecycle_Event__c
                where RecordTypeId in : lstRecTypeIds and Beneficiary__c in :
                setAccountIds order by CreatedDate desc
            ];
            if(!lstBLE.isEmpty()) {
                for(Account oAccount: lstNewRecords) {
                  if(oAccount.RecordTypeId.equals(cdspRecTypeId)){
                    if(!oAccount.Beneficiary_Confesses_Jesus_as_Savior__c ==
                        mapOldRecords.get(oAccount.Id)
                        .Beneficiary_Confesses_Jesus_as_Savior__c
                    ) {

                        for(Beneficiary_Lifecycle_Event__c oBLE: lstBLE) {
                          if((oAccount.Id == oBLE.Beneficiary__c) && (oAccount.Beneficiary_Confesses_Jesus_as_Savior__c !=
                              oBLE.Beneficiary_Confesses_Jesus_as_Savior__c)) {

                                oBLE.Beneficiary_Confesses_Jesus_as_Savior__c = oAccount.Beneficiary_Confesses_Jesus_as_Savior__c;
                                break;
                            }
                        }
                    }
                    }
                }
                update lstBLE;
            }
        } catch(Exception e) {
            ErrorLogUtility.logGeneralError(e, 'AccountHandler',
                'updateConfessFlag', 'SFDC CI');
                 
        }

    }
     /**
     * Method name  : updateRegEffDateForCSP
     * Description  : This method will update 'Effective Date' of a Survival Registation BLE when 
                      beneficiary becomes 'Active'.     
     * Return Type  : void
     * Parameter    : List<Account> , Map<Id, Account>
       Created By   : MV 
     **/
    private void updateRegEffDateForCSP(List<Account> lstNewRecords, Map<Id,
        Account> mapOldRecords) {
        
        Set<ID> setAccountIds =  new Set<ID>(); 
        List<Beneficiary_Lifecycle_Event__c>  lstRegBLE = new List<Beneficiary_Lifecycle_Event__c>();
        List<Beneficiary_Lifecycle_Event__c>  lstBLEToUpdate = new List<Beneficiary_Lifecycle_Event__c>();
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Id bleRegistRecId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType,
            Constants.BLE_REGISTRATION_RT_API_NAME);          
         try{      
            for(Account oAccount :lstNewRecords)
            {
              If(oAccount.recordtypeid == cspRecTypeId  && oAccount.Beneficiary_Status__c == Constants.ACTIVE &&
                 ((null==mapOldRecords)||(null<>mapOldRecords&&(mapOldRecords.get(oAccount.id).Beneficiary_Status__c == Constants.Draft))))
                     {
                     setAccountIds.add(oAccount.id); 
                     }
            }
            if(!setAccountIds.isEmpty())
            {
             lstRegBLE = [select id ,Date_of_Action__c from Beneficiary_Lifecycle_Event__c where 
               Beneficiary__r.id in:setAccountIds and RecordTypeid =:bleRegistRecId and Date_of_Action__c = Null] ;
             if(!lstRegBLE .isEmpty())
             {
               for (Beneficiary_Lifecycle_Event__c oBLE : lstRegBLE)
               {
                   oBLE.Date_of_Action__c = date.today(); 
                   lstBLEToUpdate.add(oBLE); 
               } 
               Update lstBLEToUpdate ;                         
            }
        }
        } catch(Exception e) {
            ErrorLogUtility.logGeneralError(e, 'AccountHandler',
                'updateRegEffDateForCSP', 'SFDC CI');
                 
        }
       }
    /**
     * Method name  : updateIsPartnerFlag
     * Description  : This method will Enable ICP as Portal for Active/Draft ICP's
     * Return Type  : void
     * Parameter    : List<Account> 
     **/
     private void updateIsPartnerFlag(List<Account> lstNewRecords)
    {
      Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME) ; 
     List <Account> lstICPs = new List <Account> ();
     List <Account> lstICPToUpdate = new List <Account> ();
      for(Account oAccount : lstNewRecords)
      {
        if((oAccount.RecordTypeId == icpRecTypeId) && ((oAccount.ICP_Status__c == Constants.ACTIVE)||
            (oAccount.ICP_Status__c == Constants.DRAFT)) &&(oAccount.IsPartner == false))
            {
              oAccount.IsPartner = true ;                         
            }      
      }     
     }
     
    /**
     * Method name  : updateDeliveryPreferenceOnSupporter
     * Description  : This will default the Supporter's Delivery 
                      Preference to the related Global Partner's Delivery 
                      Preference upon creation of the Supporter.
     * Return Type  : void
     * Parameter    : List<Account> 
     **/
    private void updateDeliveryPreferenceOnSupporter(List<Account> lstNewRecords)
    {
      Id iSuppRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.SUPPORTER_PERSON_RT_API_NAME);
      boolean bHasSuppRecord = false;
      for(Account oAccount : lstNewRecords)
      {
        if(oAccount.RecordTypeId == iSuppRecTypeId && String.isEmpty(oAccount.Delivery_Preference__c))
        {
            bHasSuppRecord = true;
        }
      }
      if(bHasSuppRecord == true)
      {
          Id iGlobalPartnerRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.GLOBAL_PARTNER_RT_API_NAME);       
          Map<id,Account> mapOfGlobalPartners = new Map<id,Account>([Select id, Delivery_Preference__c from Account where RecordTypeId =: iGlobalPartnerRecTypeId]);
          for(Account oAccount : lstNewRecords)
          {
            if(oAccount.RecordTypeId == iSuppRecTypeId && String.isEmpty(oAccount.Delivery_Preference__c) 
            && !String.isEmpty(oAccount.Global_Partner__c) && !String.isEmpty(mapOfGlobalPartners.get(oAccount.Global_Partner__c).Delivery_Preference__c))
            {
                oAccount.Delivery_Preference__c =  mapOfGlobalPartners.get(oAccount.Global_Partner__c).Delivery_Preference__c;
            }      
          }
      }     
    } 
}