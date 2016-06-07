/******************************************************************************************************
Class Name         : ICPLifecycleEventHandler
Description        : This is single Class for ICPLifecycleEvents which will cover all the ICPLifecycleEvents Functionality.
                     All Methods to cover ICPLifecycleEvents functionality will be defined in this class. These methods
                     will be called from ICPLifeCycleEventTrigger based on required trigger events.
Created By         : Danish Ahmed 
Created On         : 30-Jan-2015 
******************************************************************************************************/

public class ICPLifecycleEventHandler {

    /**
     * Method name  : onBeforeInsert
     * Description  : This method will be called before any ICP Lifecycle Event record is inserted
     * Return Type  : void
     * Parameter    : List<ICP_Lifecycle_Events__c> 
     **/
    public void onBeforeInsert(List<ICP_Lifecycle_Events__c> lstNewRecords) {
        updateCountryDirector(lstNewRecords);
    }

    /**
     * Method name  : onBeforeUpdate
     * Description  : This method will be called before any ICP Lifecycle Event record is udpated
     * Return Type  : void
     * Parameter    : List<ICP_Lifecycle_Events__c>, Map<Id,ICP_Lifecycle_Events__c> 
     **/
    public void onBeforeUpdate(List<ICP_Lifecycle_Events__c> lstNewRecords, Map <
        Id, ICP_Lifecycle_Events__c> mapOldRecords) {
        updateCountryDirector(lstNewRecords);
        updateICP(lstNewRecords, mapOldRecords);
    }
     /**
     * Method name  : onAfterUpdate
     * Description  : This method will be called after any ICP Lifecycle Event record is udpated
     * Return Type  : void
     * Parameter    : List<ICP_Lifecycle_Events__c>, Map<Id,ICP_Lifecycle_Events__c> 
     **/
    public void onAfterUpdate(List<ICP_Lifecycle_Events__c> lstNewRecords, Map <
        Id, ICP_Lifecycle_Events__c> mapOldRecords) {
        UpdateIsTransitionFieldOnAccount(lstNewRecords, mapOldRecords);
    }

    

    /**
     * Method name  : updateCountryDirector
     * Description  : This method will update the Country Director Field of Transition ICPLifecycleEvents.
     * Return Type  : void
     * Parameter    : List<ICP_Lifecycle_Events__c> 
     **/
    public void updateCountryDirector(List<ICP_Lifecycle_Events__c>
        lstNewRecords) {

        Id icpLifecycleTransitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            ICP_Lifecycle_Events__c.SObjectType, Constants.TRANSITION_ICP_LIFECYCLE_EVENTS_RT_API_NAME
        );
        Id icpRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);
        Set<Id> setICPId = new Set<Id>();
        for(ICP_Lifecycle_Events__c oICPLifecycleEventsObs: lstNewRecords) {
            if(oICPLifecycleEventsObs.RecordTypeId == icpLifecycleTransitionRecTypeId) {
                setICPId.add(oICPLifecycleEventsObs.ICP__c);
            }
        }
        if(!setICPId.isEmpty()) {
            Map<Id, Account> mapICPIdToAccount = null;
            mapICPIdToAccount = new Map<Id, Account> ([Select Id,
                Cluster__r.Territory__r.Field_Office__r.Country_Director__c from Account 
                where RecordTypeId = :icpRecordTypeId AND Id IN: setICPId
            ]);         
            if(!mapICPIdToAccount.isEmpty()) {
                for(ICP_Lifecycle_Events__c oICPLifecycleEventsObs: lstNewRecords) {
                    if(mapICPIdToAccount.containsKey(oICPLifecycleEventsObs.ICP__c)) {
                        oICPLifecycleEventsObs.Country_Director__c = mapICPIdToAccount.get(
                                oICPLifecycleEventsObs.ICP__c)
                            .Cluster__r.Territory__r.Field_Office__r.Country_Director__c;
                    }
                }
            }
        }
    }

    /**
     * Method name  : updateICP
     * Description  : This method will update Involvemnt of ICP related to ICP Lifecycle Event
     * Return Type  : void
     * Parameter    : List<ICP_Lifecycle_Events__c> , Map<Id,ICP_Lifecycle_Events__c> 
     **/
    public void updateICP(List<ICP_Lifecycle_Events__c> lstNewRecords, Map<Id,
        ICP_Lifecycle_Events__c> mapOldRecords) {

        Id icpLifecycleTransitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            ICP_Lifecycle_Events__c.SObjectType, Constants.TRANSITION_ICP_LIFECYCLE_EVENTS_RT_API_NAME
        );
        Id icpRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.ICP_RT_API_NAME);
        List<Account> lstAccountToUpdate = new List<Account>();
        Set<Id> setICPId = new Set<Id>();
        Map<Id, ICP_Lifecycle_Events__c> mapIcpIdToLEObj = new Map <
                Id, ICP_Lifecycle_Events__c>();
        for(ICP_Lifecycle_Events__c oICPLifecycleEventsObs: lstNewRecords) {
            if(oICPLifecycleEventsObs.RecordTypeId == icpLifecycleTransitionRecTypeId &&
                mapOldRecords.get(oICPLifecycleEventsObs.Id)
                .Status__c != oICPLifecycleEventsObs.Status__c && mapOldRecords.get(
                    oICPLifecycleEventsObs.Id)
                .Status__c == Constants.APPROVED && oICPLifecycleEventsObs.Status__c ==
                Constants.COMPLETED) {
                setICPId.add(oICPLifecycleEventsObs.ICP__c);
            }
        }
        if(!setICPId.isEmpty()) {
            Map<Id, Account> mapICPIdToAccount = null;
            mapICPIdToAccount = new Map<Id, Account> ([Select Id,
                Involvement__c from Account where RecordTypeId = : icpRecordTypeId 
                AND Id IN: setICPId
            ]);         
            if(!mapICPIdToAccount.isEmpty()) {
                for(ICP_Lifecycle_Events__c oICPLifecycleEventsObs: lstNewRecords) {
                    if(mapICPIdToAccount.containsKey(oICPLifecycleEventsObs.ICP__c)) {
                        Account oAccount = new Account();
                        oAccount.Id = oICPLifecycleEventsObs.ICP__c;
                        oAccount.Involvement__c = oICPLifecycleEventsObs.Involvement__c;
                        if(oAccount.Id != null && !mapIcpIdToLEObj.containsKey(oAccount.Id)){
                            mapIcpIdToLEObj.put(oAccount.Id,oICPLifecycleEventsObs);
                        }
                        lstAccountToUpdate.add(oAccount);
                    }
                }

            }
            if(!lstAccountToUpdate.isEmpty()) {
                List<Database.SaveResult> lstUpdateResults = 
                    Database.update(lstAccountToUpdate, false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstUpdateResults, lstAccountToUpdate, 'Account',
                    'ICPLifecycleEventHandler', 'updateICP', 'SFDC CI', false);
                if(!mapIdToErrorMsg.isEmpty()){
                    for(Id accountId: mapIdToErrorMsg.keySet()){
                        if(mapIcpIdToLEObj.containsKey(accountId)){
                            ICP_Lifecycle_Events__c oIcpLE = mapIcpIdToLEObj.get(
                                accountId);
                            for(String sErrorMsg: mapIdToErrorMsg.get(accountId)){
                                //oIcpLE.addError(System.Label.Error_On_ICP+sErrorMsg);
                            }
                            
                        }                       
                    }
                }
            }
        }
    }
     /**
    * Method name  : UpdateIsTransitionFieldOnAccount
    * Description  : This method will update the account field to True
                  if there is an approved Transition BLE.
    * Return Type  : void
    * Parameter    : List<ICP_Lifecycle_Events__c>, Map<Id,ICP_Lifecycle_Events__c>
    **/
    public void UpdateIsTransitionFieldOnAccount(List<ICP_Lifecycle_Events__c>
        lstNewRecords, Map<Id, ICP_Lifecycle_Events__c> mapOldRecords) {
        try {
            Id icpLifecycleTransitionRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                ICP_Lifecycle_Events__c.SObjectType, Constants.TRANSITION_ICP_LIFECYCLE_EVENTS_RT_API_NAME
            );
            Id icpRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
                Constants.ICP_RT_API_NAME);
            Set<Id> setICPIDsToQuery = new Set<Id>();
            list<ICP_Lifecycle_Events__c> lstICPLEs = null;
            List<Account> lstAccountToUpdate = new List<Account>();
            List<Account> lstFinalAccountToUpdate = new List<Account>();
            for(ICP_Lifecycle_Events__c oICPLifecycleEventsObs: lstNewRecords) {
                if(oICPLifecycleEventsObs.RecordTypeId ==
                    icpLifecycleTransitionRecTypeId &&
                    oICPLifecycleEventsObs.Status__c == Constants.APPROVED &&
                    mapOldRecords.get(oICPLifecycleEventsObs.id)
                    .Status__c !=
                    oICPLifecycleEventsObs.Status__c) {
                    setICPIDsToQuery.add(oICPLifecycleEventsObs.ICP__c);
                }
            }
            if(!setICPIDsToQuery.isEmpty()) {
                lstAccountToUpdate = [Select Id, Is_Transition_Approved__c
                    from Account where RecordTypeId = : icpRecordTypeId AND Id IN:
                    setICPIDsToQuery
                ];
                if(!lstAccountToUpdate.isEmpty()) {
                    for(Account oICPs: lstAccountToUpdate) {
                        oICPs.Is_Transition_Approved__c = True;
                        lstFinalAccountToUpdate.add(oICPs);
                    }
                }
                if(!lstFinalAccountToUpdate.isEmpty()) {
                    List<Database.SaveResult> lstUpdateResults =
                        Database.update(lstFinalAccountToUpdate, false);
                    ErrorLogUtility.logDMLError(lstUpdateResults, lstFinalAccountToUpdate,
                        'Account',
                        'ICPLifecycleEventHandler',
                        'UpdateIsTransitionFieldOnAccount', 'SFDC CI', false);
                }
            }
        } catch(Exception e) {
            ErrorLogUtility.logGeneralError(e, 'ICPLifecycleEventHandler',
                'UpdateIsTransitionFieldOnAccount', 'SFDC CI');
        }
       }
}