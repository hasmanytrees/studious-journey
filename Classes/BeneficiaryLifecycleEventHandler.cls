/******************************************************************************************************
Class Name         : BeneficiaryLifecycleEventHandler
Description        : This is single Class for Beneficiary_Lifecycle_Event__c which will cover all it's trigger functionality.
                     These methods will be called from BeneficiaryLifecycleEventTrigger based on required trigger events.
Created By         : Himanshu Raichandani 
Created On         : 18-Nov-2014 
 ******************************************************************************************************/
public class BeneficiaryLifecycleEventHandler {

    /**
     * Method name  : onAfterUpdate
     * Description  : This method will be called after any BLE record is udpated
     * Return Type  : void
     * Parameter    : List<Beneficiary_Lifecycle_Event__c> , Map<Id,Beneficiary_Lifecycle_Event__c> 
     **/
    public void onAfterUpdate(List<Beneficiary_Lifecycle_Event__c>
        lstNewRecords, Map<Id, Beneficiary_Lifecycle_Event__c> mapOldRecords) {
        updateBeneficiaryDetailsForTransitionBLE(lstNewRecords, mapOldRecords);
        updateBeneficiaryDetailsForExitBLE(lstNewRecords, mapOldRecords);
    }

    /**
     * Method name  : onBeforeUpdate
     * Description  : This method will be called before any BLE record is udpated
     * Return Type  : void
     * Parameter    : List<Beneficiary_Lifecycle_Event__c> , Map<Id,Beneficiary_Lifecycle_Event__c> 
     **/
    public void onBeforeUpdate(List<Beneficiary_Lifecycle_Event__c>
        lstNewRecords, Map<Id, Beneficiary_Lifecycle_Event__c> mapOldRecords) {
        updateRvwStsOnBLEIfEmpty(lstNewRecords);
        mandatoryICPIDLocalBeneficiaryNumberForTransfer(lstNewRecords, mapOldRecords);
        duplicationCheckNewLocalBeneficiaryNumber(lstNewRecords, mapOldRecords);
        updateFieldOfficeForHousehold(lstNewRecords, mapOldRecords);
        updateBLEForTransferBLE(lstNewRecords, mapOldRecords);
        updateBLEForTransitionBLE(lstNewRecords, mapOldRecords);
        updateBeneficiaryDetailsForTransferBLE(lstNewRecords, mapOldRecords);
    }

    /**
     * Method name  : onBeforeInsert
     * Description  : This method will be called before any BLE record is inserted
     * Return Type  : void
     * Parameter    : List<Beneficiary_Lifecycle_Event__c> 
     **/
    public void onBeforeInsert(List<Beneficiary_Lifecycle_Event__c>
        lstNewRecords) {
        updateRvwStsOnBLEIfEmpty(lstNewRecords);
        mandatoryICPIDLocalBeneficiaryNumberForTransfer(lstNewRecords, null);
        duplicationCheckNewLocalBeneficiaryNumber(lstNewRecords, null);
      
        updateBeneficiaryForBLE(lstNewRecords);
        updateBLEForExitBLE(lstNewRecords);
        updateFieldOfficeForHousehold(lstNewRecords, null);
        updateBLEForTransferBLE(lstNewRecords, null);
        updateBeneficiaryDetailsForTransferBLE(lstNewRecords, null);
        restrictMultipleConsecutiveExits(lstNewRecords);
    }
    /**
     * Method name  : onAfterInsert
     * Description  : This method will be called after any BLE record is inserted
     * Return Type  : void
     * Parameter    : List<Beneficiary_Lifecycle_Event__c> 
     **/
    public void onAfterInsert(map<Id, Beneficiary_Lifecycle_Event__c>
        mapNewRecords) {
        //createUnplannedExitThankYouLetter(mapNewRecords);
    }

    /**
    * Method name  : updateBeneficiaryDetailsForTransitionBLE
    * Description  : This method updates field values of Beneficiary as soon as BLE with 'Transition' record type is created.As per the transition type, corresponding
                     Beneficiary is updated
    * Return Type  : void
    * Parameter    : List<Beneficiary_Lifecycle_Event__c> , Map<Id,Beneficiary_Lifecycle_Event__c>
    **/
    private void updateBeneficiaryDetailsForTransitionBLE(List <
        Beneficiary_Lifecycle_Event__c> lstNewRecords, Map<Id,
        Beneficiary_Lifecycle_Event__c> mapOldRecords) {
        Account_Prevent_Validation_on_Transition__c setting = Account_Prevent_Validation_on_Transition__c.getOrgDefaults();
        Boolean BypassValidation = False;
        List<Id> lstBenefIdsToQuery = new List<Id>();
        List<Beneficiary_Lifecycle_Event__c> lstBLEToLoop = new List <
            Beneficiary_Lifecycle_Event__c>();
        Id transitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSITION_RT_API_NAME
        );
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);

        for(Beneficiary_Lifecycle_Event__c oBleEvent: lstNewRecords) {
            if(transitionRecTypeId.equals(oBleEvent.RecordTypeId) && oBleEvent.Transition_Update_Date__c !=
                mapOldRecords.get(oBleEvent.Id)
                .Transition_Update_Date__c) {
                lstBenefIdsToQuery.add(oBleEvent.Beneficiary__c);
                lstBLEToLoop.add(oBleEvent);
            }
            if(transitionRecTypeId.equals(oBleEvent.RecordTypeId))      
            {       
            BypassValidation = True;        
            }       
        }
                         
        if(BypassValidation){       
            setting.Prevent_Validation_for_Transition__c = False; 
                  
            try{
                update setting;
            }
            catch(Exception oEx){
                  ErrorLogUtility.logGeneralError(oEx, 'BeneficiaryLifecycleEventHandler',
                            'updateBeneficiaryDetailsForTransitionBLE', 'SFDC CI');
            }       
        }
        if(!lstBenefIdsToQuery.isEmpty()) {
            Map<Id, Account> mapBenefIdToBenefObject = null;
            mapBenefIdToBenefObject = new Map<Id, Account> ([
                Select Id, LastName, HIV_Status__c, PersonBirthdate,
                Beneficiary_Confession_Of_Faith_Date__c, Active_Program__c,
                CDSP_Type__c, Review_Status__c,
                RecordTypeId, Beneficiary_Status__c, ICP__c, CSP_Start_Date__c,
                CSP_End_Date__c, CSP_Tenure__c, CDSP_End_Date__c, FirstName from Account where id in
                : lstBenefIdsToQuery
            ]);
            List<Account> lstBenefToUpdate = new List<Account>();
            String sCspToCdspHome = Constants.CSP_TO_CDSP_HOME;
            String sCdspHomeToCdspCenter = Constants.CDSP_HOME_TO_CDSP_CENTER;
            System.debug('lstBLEToLoop '+lstBLEToLoop);
            for(Beneficiary_Lifecycle_Event__c oConcernedBLE: lstBLEToLoop) {
                Account oConcernedBenef = mapBenefIdToBenefObject.get(oConcernedBLE.Beneficiary__c);
                System.debug('oConcernedBenef '+oConcernedBenef);
                if(oConcernedBenef.Active_Program__c.equals(Constants.CSP)) {
                    oConcernedBenef.Beneficiary_Status__c = Constants.DRAFT;
                    oConcernedBenef.Active_Program__c = Constants.CDSP;
                    oConcernedBenef.RecordTypeId = cdspRecTypeId;
                    oConcernedBenef.CSP_End_Date__c = System.today();
                    oConcernedBenef.CDSP_Type__c = (oConcernedBLE.Transition_Type__c.equals(
                        sCspToCdspHome)) ? Constants.HOME_BASED : Constants.CENTER_BASED;
                    if(oConcernedBenef.FirstName == null)
                        oConcernedBenef.FirstName = System.Label.Dummy_First_Name_For_Transition;
                    oConcernedBenef.Review_Status__c = (UserInfo.getUserType().equals(Label.PowerPartner)) ? 
                        Label.Review_Status_Not_Submitted : Label.Review_Status_Approved;
                    if(null != oConcernedBenef.CSP_Start_Date__c) {
                        oConcernedBenef.CSP_Tenure__c = oConcernedBenef.CSP_Start_Date__c.daysBetween(
                            System.today());
                    }

                } else if(oConcernedBenef.Active_Program__c.equals(Constants.CDSP)) {
                    if(oConcernedBLE.Transition_Type__c.equals(sCdspHomeToCdspCenter)) {
                        oConcernedBenef.CDSP_Type__c = Constants.CENTER_BASED;
                    }
                }
                lstBenefToUpdate.add(oConcernedBenef);
            }
            System.debug('lstBenefToUpdate '+lstBenefToUpdate);
            if(!lstBenefToUpdate.isEmpty()) {
                List<Database.SaveResult> lstUpdateResults =
                    Database.update(lstBenefToUpdate, false);
                ErrorLogUtility.logDMLError(lstUpdateResults, lstBenefToUpdate,
                    'Beneficiary_Lifecycle_Event__c',
                    'BeneficiaryLifecycleEventHandler',
                    'updateBeneficiaryDetailsForTransitionBLE', 'SFDC CI', false);
            }
        }
        if(BypassValidation){
            setting.Prevent_Validation_for_Transition__c= True;
            try{
                update setting;
            }
            catch(Exception oEx){
                  ErrorLogUtility.logGeneralError(oEx, 'BeneficiaryLifecycleEventHandler',
                            'updateBeneficiaryDetailsForTransitionBLE', 'SFDC CI');
            }    
        }
    }

    /**
     * Method name  : updateBeneficiaryDetailsForTransferBLE
     * Description  : This method updates field values of Beneficiary as soon as BLE with 'Transfer' record type is closed
     * Return Type  : void
     * Parameter    : List<Beneficiary_Lifecycle_Event__c> , Map<Id,Beneficiary_Lifecycle_Event__c>
     **/
    private void updateBeneficiaryDetailsForTransferBLE(List <
        Beneficiary_Lifecycle_Event__c> lstNewRecords, Map<Id,
        Beneficiary_Lifecycle_Event__c> mapOldRecords) {
        Prevent_Validation_Rule_For_Transfer__c setting = Prevent_Validation_Rule_For_Transfer__c.getOrgDefaults();             
        Boolean BypassValidation = false;
        List<Id> lstBenefIdsToQuery = new List<Id>();
        List<Beneficiary_Lifecycle_Event__c> lstBLEToLoop = new List <
            Beneficiary_Lifecycle_Event__c>();
        Set<Id> setBLEToSend = new Set<Id>();
        Id transferRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSFER_RT_API_NAME
        );

        for(Beneficiary_Lifecycle_Event__c oBleEvent: lstNewRecords) {
            if(transferRecTypeId.equals(oBleEvent.RecordTypeId) 
                && oBleEvent.Status__c == Constants.CLOSED 
                && oBleEvent.Review_Status__c == Label.Review_Status_Approved
                && (null == mapOldRecords || oBleEvent.Status__c <> mapOldRecords.get(oBleEvent.Id).Status__c 
                    || oBleEvent.Review_Status__c <> mapOldRecords.get(oBleEvent.Id).Review_Status__c)) {
                lstBenefIdsToQuery.add(oBleEvent.Beneficiary__c);
                lstBLEToLoop.add(oBleEvent);
                setBLEToSend.add(oBleEvent.Id);
            }
            if(transferRecTypeId.equals(oBleEvent.RecordTypeId))
            {
            BypassValidation  = True;
            }
        }
        if(BypassValidation)
        {
            setting.Prevent_Validation_for_Transfer__c = False;
            try{
                update setting;
            }
            catch(Exception oEx){
                  ErrorLogUtility.logGeneralError(oEx, 'BeneficiaryLifecycleEventHandler',
                            'updateBeneficiaryDetailsForTransitionBLE', 'SFDC CI');
            }    
        }
        if(!lstBenefIdsToQuery.isEmpty()) {
            Map<Id, Account> mapBenefIdToBenefObject = null;
            mapBenefIdToBenefObject = new Map<Id, Account> ([
                Select ICP__c from Account where id in : lstBenefIdsToQuery
            ]);
            List<Account> lstBenefToUpdate = new List<Account>();
            Map<Id, Beneficiary_Lifecycle_Event__c> mapBenefIdToBLEObj = new Map <
                Id, Beneficiary_Lifecycle_Event__c>();

            for(Beneficiary_Lifecycle_Event__c oConcernedBLE: lstBLEToLoop) {
                Account oConcernedBenef = mapBenefIdToBenefObject.get(oConcernedBLE.Beneficiary__c);
                oConcernedBenef.ICP__c = oConcernedBLE.New_Current_ICP__c;
                oConcernedBenef.Local_Beneficiary_Number__c = oConcernedBLE.New_Local_Beneficiary_Number__c;
                oConcernedBenef.Tutor_Implementer_Name__c = null;
                lstBenefToUpdate.add(oConcernedBenef);
                mapBenefIdToBLEObj.put(oConcernedBenef.Id, oConcernedBLE);
            }
            List<Database.SaveResult> lstUpdateResults;
            lstUpdateResults = Database.update(lstBenefToUpdate, false);
            Map<Id,List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(lstUpdateResults, lstBenefToUpdate,
                'Beneficiary_Lifecycle_Event__c',
                'BeneficiaryLifecycleEventHandler',
                'updateBeneficiaryDetailsForTransferBLE', 'SFDC CI', false);
            for(Integer i = 0; i<lstUpdateResults.size(); i++) {
                if(!lstUpdateResults.get(i)
                    .isSuccess()) {
                    Beneficiary_Lifecycle_Event__c ble = mapBenefIdToBLEObj.get(
                        lstBenefToUpdate.get(i)
                        .id);
                    Database.SaveResult sr = lstUpdateResults[i];
                    for(Database.Error error: sr.getErrors()) {
                        if(error.getMessage()
                            .contains(System.Label.Error_Local_Beneficiary_Id_For_Existing_Account)
                        ) {
                            ble.addError(System.Label.Error_New_Local_Beneficiary_Number_For_Existing_BLE);
                        } else if(error.getMessage()
                            .contains(System.Label.Error_Local_Beneficiary_Id_For_New_Account)) {
                            ble.addError(System.Label.Error_New_Local_Beneficiary_Number_For_New_BLE);
                        } else {
                            ble.addError(error.getMessage());
                        }
                    }
                }
            }
        }
       if(BypassValidation)
       {
        setting.Prevent_Validation_for_Transfer__c= True;
        update setting;
        }
    }

    /**
     * Method name  : updateBLEForTransferBLE
     * Description  : This method updates field value of Previous ICP on BLE as soon as BLE with 'Transfer' record type is closed
     * Return Type  : void
     * Parameter    : List<Beneficiary_Lifecycle_Event__c> , Map<Id,Beneficiary_Lifecycle_Event__c>
     **/
    private void updateBLEForTransferBLE(List<Beneficiary_Lifecycle_Event__c>
        lstNewRecords, Map<Id, Beneficiary_Lifecycle_Event__c> mapOldRecords) {

        List<Id> lstBenefIdsToQuery = new List<Id>();
        List<Beneficiary_Lifecycle_Event__c> lstBLEToLoop = new List <
            Beneficiary_Lifecycle_Event__c>();
        Id transferRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSFER_RT_API_NAME
        );

        for(Beneficiary_Lifecycle_Event__c oBleEvent: lstNewRecords) {
                if(oBleEvent.id!=null && transferRecTypeId.equals(oBleEvent.RecordTypeId) && 
                TriggerContextUtility.setBLETransferClosedFirstRun() && Constants.CLOSED.equals(mapOldRecords.get(oBleEvent.Id)
                        .Status__c) && !Utility.getSystemAdminProfileId().equals(UserInfo.getProfileId()) 
                        && Label.Review_Status_Approved.equals(mapOldRecords.get(oBleEvent.Id).Review_Status__c)) {
                    oBleEvent.addError(System.Label.You_cannot_edit_this_record);
                } 
            TriggerContextUtility.setBLETransferClosedFirstRunFalse();        
            if(transferRecTypeId.equals(oBleEvent.RecordTypeId) 
                && oBleEvent.Status__c == Constants.CLOSED 
                && oBleEvent.Review_Status__c == Label.Review_Status_Approved
                && (null == mapOldRecords || oBleEvent.Status__c <> mapOldRecords.get(oBleEvent.Id).Status__c 
                    || oBleEvent.Review_Status__c <> mapOldRecords.get(oBleEvent.Id).Review_Status__c)) {
                lstBenefIdsToQuery.add(oBleEvent.Beneficiary__c);
                lstBLEToLoop.add(oBleEvent);
            }
        }

        if(!lstBLEToLoop.isEmpty()) {
            Map<Id, Account> mapBenefIdToBenefObject = null;
            mapBenefIdToBenefObject = new Map<Id, Account> ([
                Select ICP__c from Account where id in : lstBenefIdsToQuery
            ]);
            for(Beneficiary_Lifecycle_Event__c oConcernedBLE: lstBLEToLoop) {
                Account oConcernedBenef = mapBenefIdToBenefObject.get(oConcernedBLE.Beneficiary__c);
                oConcernedBLE.Previous_ICP__c = oConcernedBenef.ICP__c;
                oConcernedBLE.Date_Of_Action__c = date.today();
            }
        }
    }

    /**
     * Method name  : updateBLEForTransitionBLE
     * Description  : This method updates status of BLE as Closed as soon as BLE with 'Transition' record type reaches Effective Date
     * Return Type  : void
     * Parameter    : List<Beneficiary_Lifecycle_Event__c> , Map<Id,Beneficiary_Lifecycle_Event__c>
     **/
    private void updateBLEForTransitionBLE(List<Beneficiary_Lifecycle_Event__c>
        lstNewRecords, Map<Id, Beneficiary_Lifecycle_Event__c> mapOldRecords) {
        Account_Prevent_Validation_on_Transition__c setting = Account_Prevent_Validation_on_Transition__c.getOrgDefaults();
        setting.Prevent_Validation_for_Transition__c = False;
        //update setting;
        List<Beneficiary_Lifecycle_Event__c> lstBLEToLoop = new List <
            Beneficiary_Lifecycle_Event__c>();
        Id transitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSITION_RT_API_NAME
        );

        for(Beneficiary_Lifecycle_Event__c oBleEvent: lstNewRecords) {
            if(transitionRecTypeId.equals(oBleEvent.RecordTypeId) && oBleEvent.Transition_Update_Date__c !=
                mapOldRecords.get(oBleEvent.Id).Transition_Update_Date__c) {
                lstBLEToLoop.add(oBleEvent);
            }
        }

        if(!lstBLEToLoop.isEmpty()) {
            for(Beneficiary_Lifecycle_Event__c oConcernedBLE: lstBLEToLoop) {
                oConcernedBLE.Status__c = Constants.CLOSED;
            }
        }
        setting.Prevent_Validation_for_Transition__c= True;
       // update setting;
    }
    
    /**
     * Method name  : mandatoryICPIDLocalBeneficiaryNumberForTransfer
     * Description  : This method will check for New ICP and New Local Beneficiary Number to be mandatory for a Transfer record
                      and also copied New ICP Mini Profile field value to New ICP field.
     * Return Type  : void
     * Parameter    : List<Beneficiary_Lifecycle_Event__c> , Map<ID,Beneficiary_Lifecycle_Event__c>
     **/
    private void mandatoryICPIDLocalBeneficiaryNumberForTransfer(List <
        Beneficiary_Lifecycle_Event__c> lstNewRecords, Map<Id, 
        Beneficiary_Lifecycle_Event__c> mapOldRecords) {
            Id transferRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSFER_RT_API_NAME
            );
            Set<Id> setICPMiniProfileId = new Set<Id>();
            Map<Id, ICP_Mini_Profile__c> mapIdToICPMiniProfile = new Map<Id, ICP_Mini_Profile__c>();
            for(Beneficiary_Lifecycle_Event__c oBleRecords: lstNewRecords){
                if((transferRecTypeId.equals(oBleRecords.RecordTypeId) && !String.isEmpty(oBleRecords.New_ICP_Mini_Profile__c)) && 
                (trigger.isInsert || (trigger.isUpdate && 
                oBleRecords.New_ICP_Mini_Profile__c != mapOldRecords.get(oBleRecords.Id).New_ICP_Mini_Profile__c))){
                    setICPMiniProfileId.add(oBleRecords.New_ICP_Mini_Profile__c);
                }
            }
            if(!setICPMiniProfileId.isEmpty()){
                mapIdToICPMiniProfile = new Map<Id, ICP_Mini_Profile__c>(
                    [Select Id, ICP__c from ICP_Mini_Profile__c where Id IN: setICPMiniProfileId]);
            }
            
            for(Beneficiary_Lifecycle_Event__c oBleRecords: lstNewRecords) {
                if(!String.isEmpty(oBleRecords.New_ICP_Mini_Profile__c) && !mapIdToICPMiniProfile.isEmpty() && 
                    mapIdToICPMiniProfile.containsKey(oBLERecords.New_ICP_Mini_Profile__c)){
                    oBleRecords.New_Current_ICP__c = mapIdToICPMiniProfile.get(oBleRecords.New_ICP_Mini_Profile__c).ICP__c;
                
                }
                if(transferRecTypeId.equals(oBleRecords.RecordTypeId) && oBleRecords.Status__c !=
                NULL && Constants.CLOSED.equals(oBleRecords.Status__c)) {
                        if(String.isEmpty(oBleRecords.New_Local_Beneficiary_Number__c) || String.isEmpty(oBleRecords.New_Current_ICP__c)) {
                        oBleRecords.addError(System.Label.New_ICP_ID_and_New_Local_Beneficiary_Number_are_mandatory);
                        }
                       
                    }
                
            }
    }
    


    /**
     * Method name  : duplicationCheckNewLocalBeneficiaryNumber
     * Description  : This method will check concatenate ICP ID and Local Beneficiary Number and check for Duplication 
     * Return Type  : void
     * Parameter    : List<Beneficiary_Lifecycle_Event__c> , Map<ID,Beneficiary_Lifecycle_Event__c>
     **/
    private void duplicationCheckNewLocalBeneficiaryNumber(List <
        Beneficiary_Lifecycle_Event__c> lstNewRecords, Map<ID,
        Beneficiary_Lifecycle_Event__c> mapOldRecords) {
        if(TriggerContextUtility.isBLEFirstRun()) {
            TriggerContextUtility.setBLEFirstRunFalse();
            Id transferRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSFER_RT_API_NAME
            );
            Id reinstatementRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_REINSTATEMENT_RETURN_RT_API_NAME
            );
            Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.CSP_BENEFICIARY_RT_API_NAME);
            Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.CDSP_BENEFICIARY_RT_API_NAME);
            Id icpRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.ICP_RT_API_NAME);
            Map<String, Beneficiary_Lifecycle_Event__c> mapStringToBle = new Map <
                String, Beneficiary_Lifecycle_Event__c>();
            Set<Id> setAccountId = new Set<Id>();
            Set<Id> setBeneficiaryIds = new Set<Id>();
            Map<String, String> mapLocalBeneficiary = new Map<String, String>();
            String sNewLocalBeneficiaryId = Constants.EMPTY_STRING;
            String sNewLocalBeneficiaryNo = Constants.EMPTY_STRING;
            Map<Id, Account> mapBeneficiaryIdToAccount = new Map<Id, Account>();
            Set<String> setIcpIds = new Set<String>();
            for(Beneficiary_Lifecycle_Event__c oBleRecords: lstNewRecords) {
                if(reinstatementRecTypeId.equals(oBleRecords.RecordTypeId) && (trigger.isInsert ||
                        (oBleRecords.New_Local_Beneficiary_Number__c != mapOldRecords.get(
                                oBleRecords.Id)
                            .New_Local_Beneficiary_Number__c))) {
                    setBeneficiaryIds.add(oBleRecords.Beneficiary__c);
                }
                 if(transferRecTypeId.equals(oBleRecords.RecordTypeId) && String.isEmpty(
                        oBleRecords.New_Local_Beneficiary_Number__c)&& oBleRecords.Status__c ==
                 Constants.CLOSED) {
                    oBleRecords.New_Local_Beneficiary_Number__c.addError(System.Label.New_Local_Beneficiary_Number_Is_Mandatory);
                }
            }
            if(!setBeneficiaryIds.isEmpty()) {
                mapBeneficiaryIdToAccount = new Map<Id, Account> ([Select Id, ICP__c,
                    Local_Beneficiary_Number__c, Beneficiary_Status__c From Account where(
                        RecordTypeId = : cdspRecTypeId OR RecordTypeId = : cspRecTypeId) AND Id IN:
                    setBeneficiaryIds
                ]);
            }
            for(Beneficiary_Lifecycle_Event__c oBleRecords: lstNewRecords) {
                if(trigger.isInsert || (oBleRecords.New_Local_Beneficiary_Number__c !=
                        mapOldRecords.get(oBleRecords.Id)
                        .New_Local_Beneficiary_Number__c) || (oBleRecords.New_Current_ICP__c !=
                        mapOldRecords.get(oBleRecords.Id)
                        .New_Current_ICP__c)) {
                    if(transferRecTypeId.equals(oBleRecords.RecordTypeId) && String.isNotEmpty(
                            oBleRecords.New_Local_Beneficiary_Number__c)) {
                        setAccountId.add(oBleRecords.New_Current_ICP__c);
                    }

                    if(!mapBeneficiaryIdToAccount.isEmpty() && reinstatementRecTypeId.equals(
                            oBleRecords.RecordTypeId)) {
                        setAccountId.add(mapBeneficiaryIdToAccount.get(oBleRecords.Beneficiary__c)
                            .ICP__c);
                    }
                }
            }
            if(!setAccountId.isEmpty()) {
                Map<Id, Account> mapIdToAccount = null;
                mapIdToAccount = new Map<Id, Account> ([Select Id,
                    ICP_ID__c From Account where RecordTypeId = : icpRecTypeId AND Id IN:
                    setAccountId
                ]);
                if(!mapIdToAccount.isEmpty()) {
                    for(Account oAccount: mapIdToAccount.values()) {
                        setIcpIds.add(oAccount.ICP_ID__c);
                    }
                    for(Beneficiary_Lifecycle_Event__c oBleRecords: lstNewRecords) {
                        if((oBleRecords.RecordTypeId == transferRecTypeId || oBleRecords.RecordTypeId ==
                                reinstatementRecTypeId)) {
                            if(String.isNotEmpty(oBleRecords.New_Local_Beneficiary_Number__c) &&
                                oBleRecords.RecordTypeId == transferRecTypeId) {
                                sNewLocalBeneficiaryNo = oBleRecords.New_Local_Beneficiary_Number__c;
                            } else if(oBleRecords.RecordTypeId == reinstatementRecTypeId && (
                                    String.isNotEmpty(oBleRecords.New_Local_Beneficiary_Number__c)) && (
                                    String.isNotEmpty(
                                        mapBeneficiaryIdToAccount.get(oBleRecords.Beneficiary__c)
                                        .Local_Beneficiary_Number__c)) && mapBeneficiaryIdToAccount.get(
                                    oBleRecords.Beneficiary__c)
                                .Beneficiary_Status__c == Constants.INACTIVE) {
                                oBleRecords.New_Local_Beneficiary_Number__c.addError(System.Label.Error_Local_beneficiary_Number);
                            } else if(oBleRecords.RecordTypeId == reinstatementRecTypeId && String.isEmpty(
                                    oBleRecords.New_Local_Beneficiary_Number__c) && String.isEmpty(
                                    mapBeneficiaryIdToAccount.get(oBleRecords.Beneficiary__c)
                                    .Local_Beneficiary_Number__c)) {
                                oBleRecords.New_Local_Beneficiary_Number__c.addError(System.Label.New_Local_Beneficiary_Number_Is_Mandatory);
                            } else if(oBleRecords.RecordTypeId == reinstatementRecTypeId && String.isNotEmpty(
                                    oBleRecords.New_Local_Beneficiary_Number__c) && String.isEmpty(
                                    mapBeneficiaryIdToAccount.get(oBleRecords.Beneficiary__c)
                                    .Local_Beneficiary_Number__c)) {
                                sNewLocalBeneficiaryNo = oBleRecords.New_Local_Beneficiary_Number__c;
                            }
                            if(sNewLocalBeneficiaryNo.length() == 1) {
                                sNewLocalBeneficiaryNo = Constants.OOO + sNewLocalBeneficiaryNo;
                            } else if(sNewLocalBeneficiaryNo.length() == 2) {
                                sNewLocalBeneficiaryNo = Constants.OO + sNewLocalBeneficiaryNo;
                            } else if(sNewLocalBeneficiaryNo.length() == 3) {
                                sNewLocalBeneficiaryNo = Constants.O + sNewLocalBeneficiaryNo;
                            }
                            if(transferRecTypeId.equals(oBleRecords.RecordTypeId) && String.isNotEmpty(
                                    mapIdToAccount.get(oBleRecords.New_Current_ICP__c)
                                    .ICP_ID__c)) {
                                sNewLocalBeneficiaryId = mapIdToAccount.get(oBleRecords.New_Current_ICP__c)
                                    .ICP_ID__c + sNewLocalBeneficiaryNo;
                            } else if((reinstatementRecTypeId.equals(oBleRecords.RecordTypeId) &&
                                    String.isNotEmpty(mapIdToAccount.get(mapBeneficiaryIdToAccount.get(
                                                oBleRecords.Beneficiary__c)
                                            .ICP__c)
                                        .ICP_ID__c) && sNewLocalBeneficiaryNo.length()> 0)) {
                                sNewLocalBeneficiaryId = mapIdToAccount.get(mapBeneficiaryIdToAccount.get(
                                            oBleRecords.Beneficiary__c)
                                        .ICP__c)
                                    .ICP_ID__c + sNewLocalBeneficiaryNo;
                            }
                            if(!mapLocalBeneficiary.containsKey(oBleRecords.New_Local_Beneficiary_Number__c) &&
                                String.isNotEmpty(oBleRecords.New_Local_Beneficiary_Number__c) &&
                                sNewLocalBeneficiaryId.length()> 0) {
                                mapLocalBeneficiary.put(oBleRecords.New_Local_Beneficiary_Number__c,
                                    sNewLocalBeneficiaryNo);
                            }
                            if((trigger.isInsert || (oBleRecords.New_Local_Beneficiary_Number__c !=
                                    mapOldRecords.get(oBleRecords.Id)
                                    .New_Local_Beneficiary_Number__c) || (oBleRecords.New_Current_ICP__c !=
                                    mapOldRecords.get(oBleRecords.Id)
                                    .New_Current_ICP__c)) && sNewLocalBeneficiaryId.length()> 0) {
                                if(mapStringToBle.containsKey(sNewLocalBeneficiaryId)) {
                                    oBleRecords.New_Local_Beneficiary_Number__c.addError(System.Label.Error_New_Local_Beneficiary_Number_For_New_BLE);
                                } else {
                                    mapStringToBle.put(sNewLocalBeneficiaryId, oBleRecords);
                                }
                            }

                        }
                    }
                }
            }
            if(!mapStringToBle.isEmpty()) {
                List<Account> lstAccountToLoop = new List<Account>();
                try {
                    lstAccountToLoop = [SELECT Id, Local_Beneficiary_ID__c,
                        Beneficiary_Status__c FROM Account WHERE(RecordTypeId = : cdspRecTypeId OR RecordTypeId = :
                            cspRecTypeId) AND ICP__r.ICP_ID__c IN: setIcpIds AND Local_Beneficiary_ID__c IN:
                        mapStringToBle.KeySet()
                    ];
                } catch(QueryException oQEx) {
                    ErrorLogUtility.logGeneralError(oQEx, 'BeneficiaryLifecycleEventHandler',
                        'duplicationCheckNewLocalBeneficiaryNumber', 'SFDC CI');
                    return;
                }
                for(Account oAccount: lstAccountToLoop) {
                    Beneficiary_Lifecycle_Event__c oNewBLE = mapStringToBle.get(oAccount.Local_Beneficiary_ID__c);
                    if(transferRecTypeId.equals(oNewBLE.RecordTypeID)) {
                        oNewBLE.addError(System.Label.Error_New_Local_Beneficiary_Number_For_Existing_BLE);
                    }
                    if(reinstatementRecTypeId.equals(oNewBLE.RecordTypeID) && oAccount.Id !=
                        oNewBLE.Beneficiary__c) {
                        oNewBLE.New_Local_Beneficiary_Number__c.addError(System.Label.Error_New_Local_Beneficiary_Number_For_Existing_BLE);
                    }
                }
            }
            if(!mapLocalBeneficiary.isEmpty()) {
                checkBLEForDuplicateBeneficiaryNumber(mapLocalBeneficiary, setAccountId,
                    transferRecTypeId, reinstatementRecTypeId, mapStringToBle);
            }
        }
    }

    /**
     * Method name  : checkBLEForDuplicateBeneficiaryNumber
     * Description  : This method will check BLE records of transfer and reinstatement for duplication of Local Beneficiary Number
     * Return Type  : void
     * Parameter    : Map<String,String>, Set<Id>, Id, Id, Map<String, Beneficiary_Lifecycle_Event__c>
     **/
    private void checkBLEForDuplicateBeneficiaryNumber(Map<String, String>
        mapLocalBeneficiary, Set<Id> setAccountId, Id transferRecTypeId, Id reinstatementRecTypeId,
        Map<String, Beneficiary_Lifecycle_Event__c> mapStringToBle) {

        List<Beneficiary_Lifecycle_Event__c> lstBLEToLoop = null;
        try {
            lstBLEToLoop = [select RecordTypeId,
                New_Local_Beneficiary_Number__c, Beneficiary__r.ICP__r.ICP_ID__c,
                New_Current_ICP__c, New_Current_ICP__r.ICP_ID__c From Beneficiary_Lifecycle_Event__c Where Status__c !=
                : Constants.CLOSED And(Beneficiary__r.ICP__c IN: setAccountId Or New_Current_ICP__c IN:
                    setAccountId) AND(RecordTypeId = : transferRecTypeId OR RecordTypeId = :
                    reinstatementRecTypeId) AND New_Local_Beneficiary_Number__c IN:
                mapLocalBeneficiary.KeySet()
            ];
        } catch(QueryException oQEx) {
            ErrorLogUtility.logGeneralError(oQEx, 'BeneficiaryLifecycleEventHandler',
                'checkBLEForDuplicateBeneficiaryNumber', 'SFDC CI');
            return;
        }
        for(Beneficiary_Lifecycle_Event__c oBleRecords: lstBLEToLoop) {
            if(String.isNotEmpty(oBleRecords.New_Local_Beneficiary_Number__c)) {
                String sBleLocalBeneficiaryId = Constants.EMPTY_STRING;
                if(oBleRecords.RecordTypeId == reinstatementRecTypeId &&
                    mapLocalBeneficiary.containsKey(String.valueOf(oBleRecords.New_Local_Beneficiary_Number__c))
                ) {
                    sBleLocalBeneficiaryId = oBleRecords.Beneficiary__r.ICP__r.ICP_ID__c +
                        mapLocalBeneficiary.get(oBleRecords.New_Local_Beneficiary_Number__c);
                }
                if(oBleRecords.RecordTypeId == transferRecTypeId && mapLocalBeneficiary.containsKey(
                        oBleRecords.New_Local_Beneficiary_Number__c)) {
                    sBleLocalBeneficiaryId = oBleRecords.New_Current_ICP__r.ICP_ID__c +
                        mapLocalBeneficiary.get(oBleRecords.New_Local_Beneficiary_Number__c);
                }
                if(mapStringToBle.containsKey(sBleLocalBeneficiaryId)) {
                    Beneficiary_Lifecycle_Event__c oNewBLE = mapStringToBle.get(
                        sBleLocalBeneficiaryId);
                    oNewBLE.New_Local_Beneficiary_Number__c.addError(System.Label.Error_New_Local_Beneficiary_Number_For_BLE);
                }
            }
        }
    }

    /**
    * Method name  : updateBeneficiaryDetailsForExitBLE
    * Description  : This method updates field values of Beneficiary as soon as BLE with 'Exit' record type is created, per the exit type, corresponding
                     Beneficiary is updated
    * Return Type  : void
    * Parameter    : List<Beneficiary_Lifecycle_Event__c> , Map<Id,Beneficiary_Lifecycle_Event__c>
    **/
    private void updateBeneficiaryDetailsForExitBLE(List <
        Beneficiary_Lifecycle_Event__c> lstNewRecords, Map<Id,
        Beneficiary_Lifecycle_Event__c> mapOldRecords) {

    System.debug(' lstNewRecords '+lstNewRecords);
        List<Id> lstBLEToSend = new List<Id>();
        Map<Id, Date> mapBenefIdToDeathDate = new Map<Id, Date>();
        Id planExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME);
        Id unplanExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_RT_API_NAME);

        for(Beneficiary_Lifecycle_Event__c oBleEvent: lstNewRecords) {
            if((planExitRecTypeId.equals(oBleEvent.RecordTypeId) || unplanExitRecTypeId
                    .equals(oBleEvent.RecordTypeId)) && oBleEvent.Exit_Update_Date__c !=
                mapOldRecords.get(oBleEvent.Id)
                .Exit_Update_Date__c) {
                mapBenefIdToDeathDate.put(oBleEvent.Beneficiary__c, (null == oBleEvent.Date_Of_Death__c) ?
                    null : oBleEvent.Date_Of_Death__c);
                lstBLEToSend.add(oBleEvent.Id);
            }
        }

        if(!mapBenefIdToDeathDate.keySet()
            .isEmpty()) {
            List<Account> lstBenefToUpdate = null;
            lstBenefToUpdate = new List<Account> ([Select Id,
                Beneficiary_Status__c, Beneficiary_Death_Date__c from Account where id in
                : mapBenefIdToDeathDate.keySet()
            ]);
            for(Account oConcernedBenef: lstBenefToUpdate) {
                oConcernedBenef.Beneficiary_Status__c = Constants.INACTIVE;
                oConcernedBenef.Beneficiary_Death_Date__c = (null <>
                    mapBenefIdToDeathDate.get(oConcernedBenef.Id)) ? mapBenefIdToDeathDate.get(
                    oConcernedBenef.Id) : null;
            }
      
            if(!lstBenefToUpdate.isEmpty()) {
                List<Database.SaveResult> lstUpdateResults =
                    Database.update(lstBenefToUpdate, false);
                ErrorLogUtility.logDMLError(lstUpdateResults, lstBenefToUpdate,
                    'Account','BeneficiaryLifecycleEventHandler', 'updateBeneficiaryDetailsForExitBLE',
                    'SFDC CI', false);
            }
        }
    
        System.debug(' lstBLEToSend '+lstBLEToSend);    
        if(!lstBLEToSend.isEmpty()) {
          updateExitBLE(lstBLEToSend);
            /*SendBLEInfoToNeuron.sendExitBLEInfo(lstBLEToSend);
            SendBLEExitInfoToNeuronBatch oSendBleBatch = new SendBLEExitInfoToNeuronBatch(lstBLEToSend,true);
            Database.executeBatch(oSendBleBatch,1);*/
        }
    }
    
    /**
    * Method name  : updateExitBLE
    * Description  : This method will change the record type of Planned and Unplanned exit to Read-Only and will 
             also udpate Compass_Update_Pending__c flag on Exit BLE.
    * Return Type  : void
    * Parameter    : List<Id>
    **/
    private void updateExitBLE(List<Id> lstBLEToSend){
        
        Id planExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME);
        Id unplanExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_RT_API_NAME );
    Id planExitReadOnlyRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_READONLY_RT_API_NAME);
        Id unplanExitReadOnlyRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_READONLY_RT_API_NAME);
     Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
    List<Beneficiary_Lifecycle_Event__c> lstBLEToUpdate = new List<Beneficiary_Lifecycle_Event__c>(
        [Select Compass_Update_Pending__c,RecordTypeId,Beneficiary__r.RecordTypeId   
        from Beneficiary_Lifecycle_Event__c where Id in :lstBLEToSend]);
    System.debug(' lstBLEToUpdate '+lstBLEToUpdate);
    if(!lstBLEToUpdate.isEmpty()) {
      for(Beneficiary_Lifecycle_Event__c oBleEvent : lstBLEToUpdate){
      // KN: Added check to ensure that the Compass_Update_Pending flag gets set only for Sponsorship beneficiaries
        if(!oBleEvent.Beneficiary__r.RecordTypeId.equals(cspRecTypeId)){ 
        oBleEvent.Compass_Update_Pending__c = true;
        }
        if(oBleEvent.RecordTypeId.equals(planExitRecTypeId)){
          oBleEvent.RecordTypeId = planExitReadOnlyRecTypeId;
        }else if(oBleEvent.RecordTypeId.equals(unplanExitRecTypeId)){
            oBleEvent.RecordTypeId = unplanExitReadOnlyRecTypeId;
        }
      }
            List<Database.SaveResult> lstUpdateResults =
                Database.update(lstBLEToUpdate, false);
            ErrorLogUtility.logDMLError(lstUpdateResults, lstBLEToUpdate,
                'Beneficiary_Lifecycle_Event__c',
                'BeneficiaryLifecycleEventHandler', 'updateExitRecordTypeToReadOnly',
                'SFDC CI', false);
      }               
    }
    
    /**
    * Method name  : restrictMultipleConsecutiveExits
    * Description  : This method restricts the creation of consecutive Exit BLEs unless they have a reinstatement BLE in between
    * Return Type  : void
    * Parameter    : List<Beneficiary_Lifecycle_Event__c>
    **/
    private void restrictMultipleConsecutiveExits(List <Beneficiary_Lifecycle_Event__c> lstNewRecords) {
        
        set<Id> setBeneficiaryId = new set<Id>();
        list<Beneficiary_Lifecycle_Event__c> lstOpenBLE = new list<Beneficiary_Lifecycle_Event__c>();
        Map<Id,Beneficiary_Lifecycle_Event__c> mapOpenBLE = new Map<Id,Beneficiary_Lifecycle_Event__c>();
        Id planExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME
        );
        Id unplanExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_RT_API_NAME
        );
        for(Beneficiary_Lifecycle_Event__c oBleEvent: lstNewRecords) {
            if(planExitRecTypeId.equals(oBleEvent.RecordTypeId) || unplanExitRecTypeId
               .equals(oBleEvent.RecordTypeId)){
                setBeneficiaryId.add(oBleEvent.Beneficiary__c);
               }
        }
        if(!setBeneficiaryId.isEmpty()) {
            lstOpenBLE = [SELECT id, Status__c, Beneficiary__c from Beneficiary_Lifecycle_Event__c WHERE
                                  Beneficiary__c in: setBeneficiaryId AND Status__c =: Constants.OPEN AND 
                                  (RecordTypeId =:  planExitRecTypeId OR RecordTypeId =: unplanExitRecTypeId)] ;
            
            if(!lstOpenBLE.isEmpty()) {
                for(Beneficiary_Lifecycle_Event__c oBle: lstOpenBLE){
                  if(!mapOpenBLE.containsKey(oBle.Beneficiary__c))  
                        mapOpenBLE.put(oBle.Beneficiary__c,oBle );
                }
                for(Beneficiary_Lifecycle_Event__c oBle: lstNewRecords) {
                    if(mapOpenBLE.containsKey(oBle.Beneficiary__c))
                        oBle.addError(System.Label.Error_Multiple_Exit);
                }
            }
        }
    }
    
    /**
    * Method name  : updateBLEForExitBLE
    * Description  : This method will copy the record type of Planned and Unplanned exit
    * Return Type  : void
    * Parameter    : List<Beneficiary_Lifecycle_Event__c>
    **/
    private void updateBLEForExitBLE(List <Beneficiary_Lifecycle_Event__c> lstNewRecords){
        
        Id planExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME);
        Id unplanExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_RT_API_NAME );

        for(Beneficiary_Lifecycle_Event__c oBleEvent: lstNewRecords) {
            if(planExitRecTypeId.equals(oBleEvent.RecordTypeId)) {
                oBleEvent.Original_Record_Type_ID__c = String.valueOf(oBleEvent.RecordTypeId);
                obleEvent.Record_Type__c = Constants.PLANNED_EXIT;  
            }else if(unplanExitRecTypeId.equals(oBleEvent.RecordTypeId)){
                oBleEvent.Original_Record_Type_ID__c = String.valueOf(oBleEvent.RecordTypeId);
                oBleEvent.Record_Type__c = Constants.UNPLANNED_EXIT;
            }
        }
    }
    
    /**
    * Method name  : updateBeneficiaryForBLE
    * Description  : This method will update the Beneficiary when Exits, Reinstatement and
             Transition BLE record is created. This will allow user to see if there 
             is any validation rule is failing for Beneficiary.
    * Return Type  : void
    * Parameter    : List<Beneficiary_Lifecycle_Event__c>
    **/    
    private void updateBeneficiaryForBLE(List <Beneficiary_Lifecycle_Event__c> lstNewRecords){
      Id planExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME);
        Id unplanExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_RT_API_NAME );
        Id transitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSITION_RT_API_NAME);
        Id reinstatementRecTypeId = Utility.getRecordTypeIdByDeveloperName(
          Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_REINSTATEMENT_RETURN_RT_API_NAME);
        Id transferRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSFER_RT_API_NAME);
        Set<Id> setBenefId = new Set<Id>();
        Set<Id> setHouseholdId = new Set<Id>();
        List<Account> lstBenefToUpdate = new List<Account>();
        List<Household_Member__c> lstHouseholdMember = new List<Household_Member__c>();
        Map<Id,Household_Member__c> mapHousehoIdIdTOHouseholdMember = 
          new Map<Id,Household_Member__c>();
        Map<Id, Beneficiary_Lifecycle_Event__c> mapBenefIdToBLEObj = new Map <
                Id, Beneficiary_Lifecycle_Event__c>();
        for(Beneficiary_Lifecycle_Event__c oBle: lstNewRecords){
          if(planExitRecTypeId.equals(oBle.RecordTypeId) || 
            unplanExitRecTypeId.equals(oBle.RecordTypeId) || 
            transitionRecTypeId.equals(oBle.RecordTypeId) || 
            reinstatementRecTypeId.equals(oBle.RecordTypeId) || 
            transferRecTypeId.equals(oBle.RecordTypeId)){
            setBenefId.add(oBle.Beneficiary__c);
            mapBenefIdToBLEObj.put(oBle.Beneficiary__c, oBle);           
          }
        }
        if(!setBenefId.isEmpty()){
          Map<Id,Account> mapIdToBeneficiary = new Map<Id,Account>
            ([Select Id,Household__c,Primary_Caregiver__c from Account 
            Where Id IN: setBenefId]);
          for(Beneficiary_Lifecycle_Event__c oBle: lstNewRecords){
            if(reinstatementRecTypeId.equals(oBle.RecordTypeId) && 
              mapIdToBeneficiary.containsKey(oBle.Beneficiary__c)){
              if(String.isEmpty(mapIdToBeneficiary.get(oBle.Beneficiary__c).Household__c)){
                oBle.addError(System.Label.Error_on_Benef + 
                        Constants.SPACE_STRING +System.Label.Household_And_Primary_Caregiver_Missing);
              }else{
                setHouseholdId.add(mapIdToBeneficiary.get(oBle.Beneficiary__c).Household__c);
              }
              
            }
          }
          if(!setHouseholdId.isEmpty()){
            lstHouseholdMember = [Select Id,Household__c from Household_Member__c where Household__c 
              IN: setHouseholdId and Is_Primary_Caregiver__c = true];
            for(Household_Member__c oHouseholdMember: lstHouseholdMember){
              if(!mapHousehoIdIdTOHouseholdMember.containsKey(oHouseholdMember.Household__c)){
                mapHousehoIdIdTOHouseholdMember.put(oHouseholdMember.Household__c,oHouseholdMember);
              }
            }
            for(Beneficiary_Lifecycle_Event__c oBLE: lstNewRecords){
              if(!mapHousehoIdIdTOHouseholdMember.containsKey(
                mapIdToBeneficiary.get(oBLE.Beneficiary__c).Household__c)){
                oBLE.addError(System.Label.Error_on_Benef + 
                      Constants.SPACE_STRING + System.Label.Primary_Caregiver_Missing);
              }
            }            
          }
          if(!mapIdToBeneficiary.isEmpty()){
            for(Account oBenef: mapIdToBeneficiary.values()){
              Account oBenefToUpdate = new Account();
              oBenefToUpdate.id = oBenef.id;
              lstBenefToUpdate.add(oBenefToUpdate);
            }
          }
          if(!lstBenefToUpdate.isEmpty()){        
            List<Database.SaveResult> lstUpdateResults =
                  Database.update(lstBenefToUpdate, false);
              ErrorLogUtility.logDMLError(lstUpdateResults, lstBenefToUpdate,
                  'Beneficiary_Lifecycle_Event__c',
                  'BeneficiaryLifecycleEventHandler',
                  'updateBeneficiaryForBLE', 'SFDC CI', false);
              for(Integer i = 0; i<lstUpdateResults.size(); i++) {
                  if(!lstUpdateResults.get(i)
                      .isSuccess()) {
                      Beneficiary_Lifecycle_Event__c oBle = mapBenefIdToBLEObj.get(
                          lstBenefToUpdate.get(i)
                          .id);
                      Database.SaveResult sr = lstUpdateResults[i];
                      for(Database.Error error: sr.getErrors()) {                        
                              oBle.addError(System.Label.Error_on_Benef + 
                                Constants.SPACE_STRING + error.getMessage());
                      }
                  }
              }  
          }
        }
    }
    
  /**
     * Method name  : updateFieldOfficeForHousehold
     * Description  : This method updates FO for Sharing Rule backend field of Household on creation of International Transfers of Beneficiaries.
     * Return Type  : void
     * Parameter    : List<Beneficiary_Lifecycle_Event__c>, Map<Id,Beneficiary_Lifecycle_Event__c> 
     **/
    private void updateFieldOfficeForHousehold(List <
        Beneficiary_Lifecycle_Event__c> lstNewRecords, Map<Id,
        Beneficiary_Lifecycle_Event__c> mapOldRecords) {
        Id transferRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSFER_RT_API_NAME
        );
        set<Id> setHouseholdIds = new set<Id>();
        map<Id, String> mapHouseholdFO = new map<Id, String>();
        list<Household__c> lstHouseholds = new list<Household__c>();
        list<String> lstFOForHousehold = new list<String>();
        map<Id, list<String>> mapHouseholdToListFO = new map<Id, list<String>>
            ();
        list<Account> lstBenefFO = new list<Account>();
        Map<Id, String> mapICPIdToFO = new Map<Id, String>();
        Map<Id, Account> mapBenefDetails = new Map<Id, Account>();
        Set<Id> setICPsToQuery = new Set<Id>();
        Set<Id> setBenefsToQuery = new Set<Id>();
        for(Beneficiary_Lifecycle_Event__c oBleEvent: lstNewRecords) {
            if(transferRecTypeId.equals(oBleEvent.RecordTypeId) && oBleEvent.Status__c !=
                NULL && oBleEvent.Status__c.equals(Constants.CLOSED)) {
                setICPsToQuery.add(oBleEvent.New_Current_ICP__c);
                setBenefsToQuery.add(oBleEvent.Beneficiary__c);
            }
        }
    
    
        if(!setICPsToQuery.isEmpty() && !setBenefsToQuery.isEmpty()) {
            List<Account> lstICPsBen = [SELECT id, Household__c, Household__r.Field_Office_For_Sharing_Rule__c,
                FO__c, Field_Office__c
                from Account where id in : setBenefsToQuery OR Id in : setICPsToQuery
            ];
            for(Account oAccount: lstICPsBen) {
                if(setICPsToQuery.contains(oAccount.id))
                    mapICPIdToFO.put(oAccount.Id, oAccount.Field_Office__c);
                else if(setBenefsToQuery.contains(oAccount.id) && oAccount.Household__c != NULL)
                    mapBenefDetails.put(oAccount.id, oAccount);
            }
        }
    
        if(!mapICPIdToFO.isEmpty() && !mapBenefDetails.isEmpty()) {
            for(Beneficiary_Lifecycle_Event__c oBleEvent: lstNewRecords) {
                if(transferRecTypeId.equals(oBleEvent.RecordTypeId) && oBleEvent.Status__c !=
                    NULL && (oBleEvent.Status__c.equals(Constants.CLOSED)) &&
                    (mapICPIdToFO.get(oBleEvent.New_Current_ICP__c) != mapBenefDetails.get(
                            oBleEvent.Beneficiary__c)
                        .FO__c) &&
                    (!mapBenefDetails.get(oBleEvent.Beneficiary__c)
                        .Household__r.Field_Office_For_Sharing_Rule__c.contains(mapICPIdToFO.get(
                            oBleEvent.New_Current_ICP__c)))) {
                    setHouseholdIds.add(mapBenefDetails.get(oBleEvent.Beneficiary__c)
                        .Household__c);
                    lstFOForHousehold.add(mapBenefDetails.get(oBleEvent.Beneficiary__c)
                        .Household__r.Field_Office_For_Sharing_Rule__c);
                    lstFOForHousehold.add(mapICPIdToFO.get(oBleEvent.New_Current_ICP__c));
                    mapHouseholdToListFO.put(mapBenefDetails.get(oBleEvent.Beneficiary__c)
                        .Household__c, lstFOForHousehold);
                }
            }
        }
        if(!setHouseholdIds.isEmpty()) {
            lstBenefFO = [SELECT id, Household__c, FO__c from Account where Household__c in
                : setHouseholdIds AND id NOT in : setBenefsToQuery
            ];
        }
        if(!lstBenefFO.isEmpty()) {
            for(Account oBenef: lstBenefFO) {
                mapHouseholdFO.put(oBenef.Household__c, oBenef.FO__c);
            }
        }
        if(!setHouseholdIds.isEmpty()) {
            lstHouseholds = [SELECT id, Field_Office_For_Sharing_Rule__c FROM Household__c WHERE id in
                : setHouseholdIds
            ];
            if(!mapHouseholdToListFO.isEmpty()) {
                for(Household__c oHousehold: lstHouseholds) {
                    list<String> lstFO = new list<String>();
                    lstFO = mapHouseholdToListFO.get(oHousehold.Id);
                    if(!lstFO.isEmpty() && !mapHouseholdFO.isEmpty() && lstFO.get(0)
                        .contains(mapHouseholdFO.get(oHousehold.Id))) {
                        oHousehold.Field_Office_For_Sharing_Rule__c = lstFO.get(0) + '; ' + lstFO
                            .get(1);
                    } else {
                        oHousehold.Field_Office_For_Sharing_Rule__c = lstFO.get(1);
                    }
                }
            }
        if(!lstHouseholds.isEmpty()) {
                List<Database.SaveResult> lstUpdateResults =
                    Database.update(lstHouseholds, false);
                ErrorLogUtility.logDMLError(lstUpdateResults, lstHouseholds,
                    'Beneficiary_Lifecycle_Event__c',
                    'BeneficiaryLifecycleEventHandler',
                    'updateFieldOfficeForHousehold', 'SFDC CI', false);
            }
        }
    }
    
    /**
    * Method name  : updateRvwStsOnBLEIfEmpty
    * Description  : This method will set default Review status based on logged in User
    * Return Type  : void
    * Parameter    : List<Beneficiary_Lifecycle_Event__c>
    **/
    private void updateRvwStsOnBLEIfEmpty(List<Beneficiary_Lifecycle_Event__c> lstNewRecords){
        Id planExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME);
        Id unplanExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_RT_API_NAME );
        Id transitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSITION_RT_API_NAME);
        Id reinstatementRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_REINSTATEMENT_RETURN_RT_API_NAME);
        Id transferRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_TRANSFER_RT_API_NAME);
        Id caregiverDeathRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_CRGVR_DEATH_RT_API_NAME);
        Boolean isPortalUser = (UserInfo.getUserType().equals(Label.PowerPartner)) ? true : false;
        for(Beneficiary_Lifecycle_Event__c oBle: lstNewRecords){
            if((planExitRecTypeId.equals(oBle.RecordTypeId) || 
                unplanExitRecTypeId.equals(oBle.RecordTypeId) || 
                transitionRecTypeId.equals(oBle.RecordTypeId) || 
                reinstatementRecTypeId.equals(oBle.RecordTypeId) || 
                transferRecTypeId.equals(oBle.RecordTypeId))
                && String.isEmpty(oBle.Review_Status__c)) {
                    if(Label.CSP.equals(oBle.Benef_Program_Stage__c)){
                        oBle.Review_Status__c = Label.Review_Status_Approved;
                    }else{
                        oBle.Review_Status__c = (isPortalUser)? Label.Review_Status_Submitted : Label.Review_Status_Approved;
                    }
            }
            else if(caregiverDeathRecTypeId.equals(oBle.RecordTypeId)
                        && String.isEmpty(oBle.Review_Status__c)){
                    if(Label.Program_Stage_Center_Based.equals(oBle.Benef_Program_Stage__c)){
                        oBle.Review_Status__c = Label.Review_Status_Approved;
                    }else{
                        oBle.Review_Status__c = (isPortalUser)? Label.Review_Status_Submitted : Label.Review_Status_Approved;
                    }           
            }
        }
    }
}