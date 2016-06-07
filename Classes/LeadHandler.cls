/******************************************************************************************************
Class Name         : LeadHandler
Description        : This is single Class for Lead which will cover all the Lead Functionality.
                     All Methods to cover Lead functionality will be defined in this class. These methods
                     will be called from LeadTrigger based on required trigger events.
Created By         : Shaik Manzoor 
Created On         : 08-Oct-2014 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class LeadHandler {

    /**
     * Method name  : onAfterUpdate
     * Description  : This method will be called after any Lead record is updated
     * Return Type  : void
     * Parameter    : map<Id, Lead> mapOldRecords, List<Lead> lstNewRecords
     **/
    public void onAfterUpdate(map<Id, Lead> mapOldRecords, List<Lead>
        lstNewRecords) {
        autoConvertLead(mapOldRecords, lstNewRecords);
    }

    /**
     * Method name  : onBeforeInsertOrUpdate
     * Description  : This method will be called before any Lead record is inserted or udpated
     * Return Type  : void
     * Parameter    : map<Id, Lead> , List<Lead> 
     **/
    public void onBeforeInsertOrUpdate(map<Id, Lead> mapOldRecords, List<Lead>
        lstNewRecords) {
        checkDuplicateICPID(lstNewRecords);
        calculateLeadScore(lstNewRecords);
    }

    /**
     * Method name  : onBeforeDelete
     * Description  : This method will be called before any Lead record is deleted
     * Return Type  : void
     * Parameter    : List<Lead> 
    public void onBeforeDelete(List<Lead> lstOldRecords) {
        preventDeleteLead(lstOldRecords);
    }
    **/

    /**
     * Method name  : autoConvertLead
     * Description  : This method set fields while Lead is converted to ICP Account record
     * Return Type  : void
     * Parameter    : map<Id, Lead> , List<Lead> 
     **/
    private void autoConvertLead(map<Id, Lead> mapoldRecords, List<Lead>
        lstNewRecords) {
        List<Lead> lstEligibleLeads = new List<lead>();
        for(Lead oLead: lstNewRecords) {
            if(oLead.status == Constants.QUALIFIED && mapOldRecords.get(oLead.id)
                .status != Constants.QUALIFIED) {
                lstEligibleLeads.add(oLead);
            }
        }

        List<Database.LeadConvert> lstLeadConvert = new List<Database.LeadConvert>
            ();
        for(Lead oLead: lstEligibleLeads) {
            Database.LeadConvert oLeadConvert = New Database.LeadConvert();
            oLeadConvert.setLeadId(oLead.id);
            oLeadConvert.setDoNotCreateOpportunity(True);
            oLeadConvert.setConvertedStatus(Constants.CONVERTED);
            lstLeadConvert.add(oLeadConvert);
        }
        List<Database.LeadConvertResult> lstLeadConvertResult = Database.convertLead(
            lstLeadConvert);
    }

    /**
    * Method name  : calculateLeadScore
    * Description  : Based upon the field weights configured in Global Data and in Ranking Administration corresponding to its concerned Field Office, Lead score calculates avaiable criterias. 
                     These same Criterias are also defined on Lead Detail page, and based on that Lead score calculations are done with the help of pre-configured data.
    * Return Type  : null
    * Parameter    : List<Lead> 
    **/
    private void calculateLeadScore(List<Lead> lstNewRecords) {

            Set<Id> setFOToQuery = new Set<Id>();
            for(Lead oConcernedLeadObject: lstNewRecords) {
                if(null != oConcernedLeadObject.Field_Office_Id__c) {
                    setFOToQuery.add(oConcernedLeadObject.Field_Office_Id__c);
                }
            }

            Map<Id, Account> mapIdToFieldOfficeObject = null;
            Map<Id, Ranking_Administration__c> mapIdToRankingAdminObject = null;
            try {
                mapIdToFieldOfficeObject = new Map<Id, Account> ([Select Id from account where Id in
                    : setFOToQuery
                ]);

                mapIdToRankingAdminObject = new Map<Id, Ranking_Administration__c> ([
                    Select Id, child_enrollment_capacity__c, commitment_to_child_ministry__c,
                    commitment_to_recruiting_christians__c,
                    commitment_to_use_local_resources__c, denomination__c, Field_Office__c,
                    legal_registration__c, location__c, physical_environment__c,
                    statement_of_faith_compatibility__c FROM Ranking_Administration__c where Field_Office__c in
                    : setFOToQuery
                ]);
            } catch(System.QueryException oQe) {
                ErrorLogUtility.logGeneralError(oQe, 'LeadHandler', 
                    'calculateLeadScore', 'SFDC CI');
                return;
            }


            Map<String, Schema.sObjectField> mapRankingAdminSchema = Schema.getGlobalDescribe()
                .get(Constants.RANKING_ADMINISTRATION_API_NAME)
                .getDescribe()
                .fields.getMap();
            List<String> lstConcernedFields = new List<String>();
            List<String> lstConcernedFieldsForStage1 = new List<String>();
            List<String> lstConcernedFieldsForStage2 = new List<String>();
            String sStage1FieldNames = System.label.Stage1_Field_Name_For_Lead_Score;
            String sFieldOfficeFieldName = System.label.Field_Office_Field_Name_For_Lead_Score;

            for(String sFieldName: mapRankingAdminSchema.keySet()) {
                if(sFieldName.contains('__c') && sFieldName <> sFieldOfficeFieldName) {
                    lstConcernedFields.add(sFieldName.toLowerCase());
                    if(sStage1FieldNames.contains(sFieldName)) {
                        lstConcernedFieldsForStage1.add(sFieldName);
                    } else {
                        lstConcernedFieldsForStage2.add(sFieldName);
                    }
                }
            }

            List<Global_Data__c> lstGlobalData = new List<Global_Data__c>();
            //Fetching global data object
            try {
                lstGlobalData = [SELECT Field_API_Name__c, Field_Description__c,
                    Field_Name__c, Field_Value__c, Field_Weight__c FROM Global_Data__c where Field_API_Name__c in
                    : lstConcernedFields
                ];
            } catch(System.QueryException oQe) {
                ErrorLogUtility.logGeneralError(oQe, 'LeadHandler', 
                    'calculateLeadScore', 'SFDC CI');
                return;
            }

            Map<String, List<Global_Data__c>> mapGlobalDataFieldApiNameToValue =
                new Map<String, List<Global_Data__c>>();
            for(Global_Data__c oGlobalData: lstGlobalData) {
                if(mapGlobalDataFieldApiNameToValue.containsKey(oGlobalData.Field_API_Name__c)) {
                    mapGlobalDataFieldApiNameToValue.get(oGlobalData.Field_API_Name__c)
                        .add(oGlobalData);
                } else {
                    mapGlobalDataFieldApiNameToValue.put(oGlobalData.Field_API_Name__c, new List <
                        Global_Data__c> {
                            oGlobalData
                        });
                }
            }

            Id icpLeadRecTypeId = Utility.getRecordTypeIdByDeveloperName(Lead.SObjectType,
                Constants.ICP_LEAD_RT_API_NAME);

            for(Lead oConcernedLeadObject: lstNewRecords) {
                if(icpLeadRecTypeId.equals(oConcernedLeadObject.RecordTypeId)) {
                    Map<String, String> mapLeadFieldNameToNewFieldValue = new Map<String,
                        String>();

                    for(String sFieldName: lstConcernedFields) {
                        mapLeadFieldNameToNewFieldValue.put(sFieldName, (String) oConcernedLeadObject
                            .get(sFieldName));
                    }

                    //If Lead isn't associated to any Cluster, then we aren't able to find Lead's Field Office and hence not able to calculate Lead Score
                    if(!mapIdToFieldOfficeObject.keySet()
                        .contains(oConcernedLeadObject.Field_Office_Id__c)) {
                        continue;
                    }

                    Ranking_Administration__c oRankingAdmin = getRankingAdminObject(
                        mapIdToRankingAdminObject, oConcernedLeadObject.Field_Office_Id__c);
                    //If data isn't configured against Ranking Administration then Lead score won't be calculated.
                    if(null == oRankingAdmin) {
                        continue;
                    }
                    oConcernedLeadObject.Lead_Score__c = calculateLeadScore(
                        lstConcernedFieldsForStage1, mapLeadFieldNameToNewFieldValue,
                        oRankingAdmin, mapGlobalDataFieldApiNameToValue);
                    oConcernedLeadObject.Lead_Score_Stage_2__c = calculateLeadScore(
                        lstConcernedFieldsForStage2, mapLeadFieldNameToNewFieldValue,
                        oRankingAdmin, mapGlobalDataFieldApiNameToValue);

                } //end of if
            } //end of for
        } //end of method 

    /**
     * Method name  : calculateLeadScore
     * Description  : This private method calculates Lead score for either Phase1 or Phase2 based  upon lstConcernedFields List
     * Return Type  : Decimal
     * Parameter    : List<String> ,Map<String,String> , Ranking_Administration__c , Map<String,List<Global_Data__c>> 
     **/
    private Decimal calculateLeadScore(List<String> lstConcernedFields, Map <
        String, String> mapLeadFieldNameToNewFieldValue, Ranking_Administration__c oRankingAdmin,
        Map<String, List<Global_Data__c>> mapGlobalDataFieldApiNameToValue) {

        Decimal dLeadScore = 0;
        for(String sFieldName: lstConcernedFields) {
            String sNewFieldValue = mapLeadFieldNameToNewFieldValue.get(sFieldName);
            Decimal dFieldWeightage = (Decimal) oRankingAdmin.get(sFieldName);
            Decimal dGlobalData = getGlobalDataForFieldValue(
                mapGlobalDataFieldApiNameToValue.get(sFieldName), sFieldName,
                sNewFieldValue);
            dLeadScore += dGlobalData * dFieldWeightage;
        }
        return dLeadScore;
    }

    /**
     * Method name  : getRankingAdminObject
     * Description  : This private method fetches Ranking Admin object from Map mapIdToRankingAdminObject based upon the Field office of concerned Lead Object
     * Return Type  : Ranking_Administration__c
     * Parameter    : Map<Id,Ranking_Administration__c> , Id 
     **/
    private Ranking_Administration__c getRankingAdminObject(Map<Id,
        Ranking_Administration__c> mapIdToRankingAdminObject, Id fieldOfficeId) {

        for(Id rankingId: mapIdToRankingAdminObject.keySet()) {
            if(mapIdToRankingAdminObject.get(rankingId)
                .Field_Office__c.equals(fieldOfficeId)) {
                return mapIdToRankingAdminObject.get(rankingId);
            }
        }
        return null;
    }

    /**
     * Method name  : getGlobalDataForFieldValue
     * Description  : This private  method fetches field weight from Global Data configured for corresponding Global Field Value
     * Return Type  : Decimal
     * Parameter    : List<Global_Data__c> , String , String 
     **/
    private Decimal getGlobalDataForFieldValue(List<Global_Data__c>
        lstGlobalData, String sFieldName, String sFieldValue) {

        if(lstGlobalData <> null) {
            for(Global_Data__c oGlobalData: lstGlobalData) {
                if(oGlobalData.Field_Value__c.equals(sFieldValue)) {
                    return oGlobalData.Field_Weight__c;
                }
            }
        }
        return 0;
    }

    /**
     * Method name  : icpFieldsOnLeadConvert
     * Description  : This method updated fields when Lead is converted to ICP account
     * Return Type  : void
     * Parameter    : list<Lead> 
     **/
    public static void icpFieldsOnLeadConvert(list<Lead> lstNewRecords) {
        List<Account> lstOfICPs = new list<Account>();
        Id rtId = null;
        Map<Id, Lead> mapIcpIdToLeadObj = new Map <
                Id, Lead>();
        try {
            rtId = [select Id from RecordType where SobjectType = : Constants.ACCOUNT_API_NAME AND DeveloperName = :
                Constants.ICP_RT_API_NAME
            ].Id;
        } catch(System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'LeadHandler', 
                'icpFieldsOnLeadConvert', 'SFDC CI');
            return;
            
        }
        for(Lead oLead: lstNewRecords) {
            if(oLead.ConvertedAccountId <> null) {
                if(oLead.ICP_ID__c == null) {
                    oLead.addError(System.Label.Error_Convert_Lead_Without_ICP_ID);
                }
                Account oAccount = new Account(RecordTypeId = rtId, Id = oLead.ConvertedAccountId,
                    ICP_Status__c = Constants.DRAFT, GPS_Location__latitude__s = oLead.GPS_Location__latitude__s,
                    GPS_Location__longitude__s = oLead.GPS_Location__longitude__s,Initial_Maturity_Level__c= Constants.ICP_Maturity_Developing);
                lstOfICPs.add(oAccount);
                if(oLead.ICP_ID__c != null && !mapIcpIdToLeadObj.containsKey(oLead.ConvertedAccountId)){
                    mapIcpIdToLeadObj.put(oLead.ConvertedAccountId,oLead);
                }
            }
        }
        if(!lstOfICPs.isEmpty()){
            List<Database.SaveResult> lstUpdateResults = 
                Database.update(lstOfICPs, false);
            Map<Id, List<String>> mapIdToErrorMsg = 
                ErrorLogUtility.logDMLError(lstUpdateResults, lstOfICPs, 'Account',
                    'LeadHandler', 'icpFieldsOnLeadConvert', 'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()){
                for(Id accountId: mapIdToErrorMsg.keySet()){
                    if(mapIcpIdToLeadObj.containsKey(accountId)){
                        Lead oLead = mapIcpIdToLeadObj.get(
                            accountId);
                        for(String sErrorMsg: mapIdToErrorMsg.get(accountId)){
                            oLead.addError(System.Label.Error_On_ICP+sErrorMsg);
                        }
                    }
                }
            }
        }
    }

    /**
     * Method name  : checkDuplicateICPID
     * Description  : This method will check ICP ID of Lead with ICP ID of Account for duplicate and error out duplicate ICP ID
     * Return Type  : void
     * Parameter    : List<Lead> 
     **/
    public void checkDuplicateICPID(List<Lead> lstNewRecords) {

        Map<String, Account> mapAccount = new Map<String, Account>();
        Set<String> setIcpIds = new Set<String>();
        List<Account> lstAccount = new List<Account>();
        for(Lead oLead: lstNewRecords) {
            if(oLead.isConverted == false) {
                setIcpIds.add(oLead.ICP_ID__c);
            }
        }
        try{
            lstAccount = [Select Id, ICP_ID__c From Account where 
                ICP_ID__c IN: setIcpIds AND ICP_ID__c != null
            ];
        }catch(System.QueryException oQe){
            ErrorLogUtility.logGeneralError(oQe, 'LeadHandler', 
                'checkDuplicateICPID', 'SFDC CI');
            return;
        }
        if(!lstAccount.isEmpty()) {
            for(Account acc: lstAccount) {
                if(!mapAccount.containsKey(acc.ICP_ID__c)) {
                    mapAccount.put(acc.ICP_ID__c, acc);
                }
            }
            for(Lead oLead: lstNewRecords) {
                if(mapAccount.containsKey(oLead.ICP_ID__c)) {
                    oLead.ICP_ID__c.addError(System.Label.Error_ICP_With_ICP_ID_Already_Exist);
                }
            }
        }
    }

    /**
     * Method name  : preventDeleteLead
     * Description  : This method will prevent user except System Admin from deleting Lead records.
     * Return Type  : void
     * Parameter    : List<Lead> 
    private void preventDeleteLead(List<Lead> lstOldRecords) {
        Profile systemAdminProfile = null;
        try{
            systemAdminProfile = [Select Id, Name from Profile where Name = :
                System.Label.System_Administrator limit 1
            ];
        }catch(System.QueryException oQe){
            ErrorLogUtility.logGeneralError(oQe, 'LeadHandler', 
                'preventDeleteLead', 'SFDC CI');
            return;
        }
        Id userProfileId = userinfo.getProfileId();
        for(Lead oLead: lstOldRecords) {
            if(userProfileId != systemAdminProfile.Id) {
                oLead.addError(System.Label.Error_Insufficient_Privileges);
            }
        }

    }
    **/
}