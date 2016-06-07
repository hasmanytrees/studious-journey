/******************************************************************************************************
Class Name         : ErrorLogUtility
Description        : This Utility class helps to log error in Error_Log__c object
Created By         : Himanshu Raichandani 
Created On         : 02-Feb-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class ErrorLogUtility {

    /**
     * Method name  : logIntegrationError
     * Description  : This method logs all integration related errors in Error_Log__c object
     * Return Type  : void
     * Parameter    : String, String, String, String, String, String, String, String, String, Boolean, String
     **/
    public static void logIntegrationInfo(String sStatus, String sType, String sClassName,
        String sMethodName, String sSourceSystem,
        Integer iStatusCode, String sErrorMessage, String sReqBody,
        String sRespBody, String sRespMsg,Exception oException) {
        if(sStatus == System.Label.Success && System.Label.Log_Integration_Success ==
            System.Label.True || sStatus == System.Label.Failure) {
            try {
                Id integErrorLogRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                    Error_Log__c.SObjectType,
                    Constants.ERRORLOG_INTEGRATION);
                Error_Log__c oErr = new Error_Log__c();
                oErr.Status__c = sStatus;
                oErr.Type__c = sType;
                oErr.Error_Occurred_in_Class__c = sClassName;
                oErr.Error_Occurred_in_Method__c = sMethodName;
                oErr.Logged_In_User__c = UserInfo.getUserName();
                oErr.Source_System__c = sSourceSystem;
                oErr.Status_Code__c = iStatusCode;
                oErr.Error_Body__c = sErrorMessage;
                oErr.Request_Body__c = sReqBody;
                oErr.Response_Body__c = sRespBody;
                oErr.Response_Message__c = sRespMsg;
                oErr.RecordTypeId = integErrorLogRecTypeId;
                if(oException != null){
                    if(String.isNotEmpty(oException.getStackTraceString())){
                        oErr.Stack_Trace__c = oException.getStackTraceString();
                    }
                    if(oException.getLineNumber() != null) {
                        oErr.Error_Occurred_at_Line_Number__c = String.ValueOf(oException.getLineNumber());
                    }
                }
                insert oErr;
            } catch(Exception oEx) {
                logGeneralError(oEx, 'ErrorLogUtility', 'logIntegrationInfo', 'SFDC CI');
            }
        }
    }
    
    /**
     * Method name  : logIntegrationInfoWithRecordId - Added to populate the Record Id in Error logging
     * Description  : This method logs all integration related errors in Error_Log__c object
     * Return Type  : void
     * Parameter    : String, String, String, String, String, Integer, String, String, String, String, String, String
     **/
    public static void logIntegrationInfoWithRecordId(String sStatus, String sType, String sClassName,
        String sMethodName, String sSourceSystem,
        Integer iStatusCode, String sErrorMessage, String sReqBody,
        String sRespBody, String sRespMsg,Exception oException,String sComKitID) {
        if(sStatus == System.Label.Success && System.Label.Log_Integration_Success ==
            System.Label.True || sStatus == System.Label.Failure) {
            try {
                Id integErrorLogRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                    Error_Log__c.SObjectType,
                    Constants.ERRORLOG_INTEGRATION);
                Error_Log__c oErr = new Error_Log__c();
                oErr.Status__c = sStatus;
                oErr.Type__c = sType;
                oErr.Error_Occurred_in_Class__c = sClassName;
                oErr.Error_Occurred_in_Method__c = sMethodName;
                oErr.Logged_In_User__c = UserInfo.getUserName();
                oErr.Source_System__c = sSourceSystem;
                oErr.Status_Code__c = iStatusCode;
                oErr.Error_Body__c = sErrorMessage;
                oErr.Request_Body__c = sReqBody;
                oErr.Response_Body__c = sRespBody;
                oErr.Response_Message__c = sRespMsg;
                oErr.RecordTypeId = integErrorLogRecTypeId;
                oErr.Record_Id__c = sComKitID;//SSHANKAR - 02-Jun-2016 - Added to capture Comm ID
                if(oException != null){
                    if(String.isNotEmpty(oException.getStackTraceString())){
                        oErr.Stack_Trace__c = oException.getStackTraceString();
                    }
                    if(oException.getLineNumber() != null) {
                        oErr.Error_Occurred_at_Line_Number__c = String.ValueOf(oException.getLineNumber());
                    }
                }
                insert oErr;
            } catch(Exception oEx) {
                logGeneralError(oEx, 'ErrorLogUtility', 'logIntegrationInfo', 'SFDC CI');
            }
        }
    }
    
   /**
     * Method name  : logIntegrationError
     * Description  : This method logs all integration related errors in Error_Log__c object
     * Return Type  : void
     * Parameter    : String, String, String, String, String, String, String, String, String, Boolean, String
     **/
    public static void logIntegrationInfoWithRetry(String sStatus, String sType, String sClassName,
        String sMethodName, String sSourceSystem,
        Integer iStatusCode, String sErrorMessage, String sReqBody,
        String sRespBody, String sRespMsg,Exception oException, String sESBURL, String sHTTPVerb) {
        if(sStatus == System.Label.Success && System.Label.Log_Integration_Success ==
            System.Label.True || sStatus == System.Label.Failure) {
            try {
                Id integErrorLogRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                    Error_Log__c.SObjectType,
                    Constants.ERRORLOG_INTEGRATION);
                Error_Log__c oErr = new Error_Log__c();
                oErr.Status__c = sStatus;
                oErr.Type__c = sType;
                oErr.Error_Occurred_in_Class__c = sClassName;
                oErr.Error_Occurred_in_Method__c = sMethodName;
                oErr.Logged_In_User__c = UserInfo.getUserName();
                oErr.Source_System__c = sSourceSystem;
                oErr.Status_Code__c = iStatusCode;
                oErr.Error_Body__c = sErrorMessage;
                oErr.Request_Body__c = sReqBody;
                oErr.Response_Body__c = sRespBody;
                oErr.Response_Message__c = sRespMsg;
                oErr.RecordTypeId = integErrorLogRecTypeId;
                oErr.ESB_URL__c = sESBURL;
                oErr.HTTP_Verb__c = sHTTPVerb;
                if(oException != null){
                    if(String.isNotEmpty(oException.getStackTraceString())){
                        oErr.Stack_Trace__c = oException.getStackTraceString();
                    }
                    if(oException.getLineNumber() != null) {
                        oErr.Error_Occurred_at_Line_Number__c = String.ValueOf(oException.getLineNumber());
                    }
                }
                insert oErr;
            } catch(Exception oEx) {
                logGeneralError(oEx, 'ErrorLogUtility', 'logIntegrationInfo', 'SFDC CI');
            }
        }
    }
    
     /**
     * Method name  : logIntegrationInfoWithRetryExt
     * Description  : This method logs all integration related errors in Error_Log__c object
     * Return Type  : void
     * Parameter    : String, String, String, String, String, Integer, String, String, String, String, 
                      Exception, String, String, String, String, 
     **/
     public static void logIntegrationInfoWithRetryExt(String sStatus, String sType, String sClassName,
        String sMethodName, String sSourceSystem,
        Integer iStatusCode, String sErrorMessage, String sReqBody,
        String sRespBody, String sRespMsg,Exception oException, String sESBURL, String sHTTPVerb, String sXcimToAddress, String sIntegrationName) {
        if(sStatus == System.Label.Success && System.Label.Log_Integration_Success ==
            System.Label.True || sStatus == System.Label.Failure) {
            try {
                Id integErrorLogRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                    Error_Log__c.SObjectType,
                    Constants.ERRORLOG_INTEGRATION);
                Error_Log__c oErr = new Error_Log__c();
                oErr.Status__c = sStatus;
                oErr.Type__c = sType;
                oErr.Error_Occurred_in_Class__c = sClassName;
                oErr.Error_Occurred_in_Method__c = sMethodName;
                oErr.Logged_In_User__c = UserInfo.getUserName();
                oErr.Source_System__c = sSourceSystem;
                oErr.Status_Code__c = iStatusCode;
                oErr.Error_Body__c = sErrorMessage.substring(0,31999);
                oErr.Request_Body__c = sReqBody.substring(0,32500);
                oErr.Response_Body__c = sRespBody;
                oErr.Response_Message__c = sRespMsg;
                oErr.RecordTypeId = integErrorLogRecTypeId;
                oErr.ESB_URL__c = sESBURL;
                oErr.HTTP_Verb__c = sHTTPVerb;
                oErr.Xcim_To_Address__c = sXcimToAddress;
                oErr.IsRepeatEnabled__c = true;
                oErr.Integration_Name__c = sIntegrationName;
                if(oException != null){
                    if(String.isNotEmpty(oException.getStackTraceString())){
                        oErr.Stack_Trace__c = oException.getStackTraceString();
                    }
                    if(oException.getLineNumber() != null) {
                        oErr.Error_Occurred_at_Line_Number__c = String.ValueOf(oException.getLineNumber());
                    }
                }
                insert oErr;
            } catch(Exception oEx) {
                logGeneralError(oEx, 'ErrorLogUtility', 'logIntegrationInfo', 'SFDC CI');
            }
        }
    }
    
    /**
     * Method name  : logDMLError
     * Description  : This method logs all DML related errors in Error_Log__c object
     * Return Type  : void
     * Parameter    : List<Database.SaveResult>, List<sObject>, String, String, String, String, String, Boolean
     **/
    public static Map<Id, List<String>> logDMLError(List<Database.SaveResult>
        lstSaveResult,
        List<sObject> lstSObject, String sObjectName, String sClassName, String sMethodName,
        String sSourceSystem, Boolean bAddError) {
        
        Map<Id, List<String>> mapIdToErrorMsg = logDMLError(lstSaveResult, lstSObject, sObjectName, sClassName, sMethodName,
            sSourceSystem, bAddError, false);
        return mapIdToErrorMsg;
    } 

    /**
     * Method name  : logDMLError
     * Description  : This method logs all DML related errors in Error_Log__c object
     * Return Type  : void
     * Parameter    : List<Database.SaveResult>, List<sObject>, String, String, String, String, String, Boolean, Boolean
     **/
    public static Map<Id, List<String>> logDMLError(List<Database.SaveResult>
        lstSaveResult,
        List<sObject> lstSObject, String sObjectName, String sClassName, String sMethodName,
        String sSourceSystem, Boolean bAddError, Boolean bSharingRecord) {
        Map<id, List<String>> mapIdToErrorMsg = new Map<id, List<String>>
            ();
        Id generalErrorLogRecTypeId;
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
                        if(bSharingRecord){
                            oErrorLog.User_Id__c = (String)lstSObject[i].get('UserOrGroupId');
                        }
                        lstErrorLog.add(oErrorLog);
                        if(!mapIdToErrorMsg.containsKey(lstSObject[i].Id)) {
                            mapIdToErrorMsg.put(lstSObject[i].Id, new List<string>());
                        }
                        mapIdToErrorMsg.get(lstSObject[i].Id)
                            .add(sErrorMsg);

                        if(bAddError) {
                            lstSObject[i].addError('Error : ' + sErrorMsg);
                        }
                        
                    }
                }
            }
            if(!lstErrorLog.isEmpty()) {
                List<Database.SaveResult> lstSaveResults = Database.insert(lstErrorLog,
                    false);
            }
        } catch(Exception oEx) {
            logGeneralError(oEx, 'ErrorLogUtility', 'logDMLError', 'SFDC CI');
        }
        return mapIdToErrorMsg;
    }

    /**
     * Method name  : logDMLError
     * Description  : This method logs all Upsert DML related errors in Error_Log__c object
     * Return Type  : void
     * Parameter    : List<Database.SaveResult>, List<sObject>, String, String, String, String, String, Boolean
     **/
    public static Map<Id, List<String>> logDMLError(List<Database.UpsertResult>
        lstUpsertResult,
        List<sObject> lstSObject, String sObjectName, String sClassName, String sMethodName,
        String sSourceSystem, Boolean bAddError) {
        Map<id, List<String>> mapIdToErrorMsg = new Map<id, List<String>>
            ();
        Id generalErrorLogRecTypeId;
        if(!lstUpsertResult.isEmpty()) {
            generalErrorLogRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                Error_Log__c.SObjectType,
                Constants.ERRORLOG_GENERAL);
        }
        try {
            List<Error_Log__c> lstErrorLog = new List<Error_Log__c>();
            for(Integer i = 0; i<lstUpsertResult.size(); i++) {
                if(!lstUpsertResult.get(i)
                    .isSuccess()) {
                    String sErrorMsg;
                    Database.UpsertResult oUpsertResult = lstUpsertResult[i];
                    for(Database.Error oError: oUpsertResult.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(oError.getStatusCode() + ': ' + oError.getMessage());
                        System.debug('Fields that affected by this error: ' + oError.getFields());
                        sErrorMsg = oError.getMessage();
                        Error_Log__c oErrorLog = new Error_Log__c(
                            RecordTypeId = generalErrorLogRecTypeId,
                            Record_Id__c = lstSObject[i].Id,
                            Object__c = sObjectName,
                            Error_Occurred_in_Class__c = sClassName,
                            Error_Occurred_in_Method__c = sMethodName,
                            Error_Body__c = sErrorMsg,
                            Logged_In_User__c = UserInfo.getUserName()
                        );
                        oErrorLog.Source_System__c = sSourceSystem;
                        lstErrorLog.add(oErrorLog);
                        if(!mapIdToErrorMsg.containsKey(lstSObject[i].Id)) {
                            mapIdToErrorMsg.put(lstSObject[i].Id, new List<string>());
                        }
                        mapIdToErrorMsg.get(lstSObject[i].Id)
                            .add(sErrorMsg);

                        if(bAddError) {
                            lstSObject[i].addError('Error : ' + sErrorMsg);
                        }
                    }
                }
            }
            if(!lstErrorLog.isEmpty()) {
                List<Database.SaveResult> lstSaveResults = Database.insert(lstErrorLog,
                    false);
            }
        } catch(Exception oEx) {
            System.debug('@@@@oex' + oex);
            logGeneralError(oEx, 'ErrorLogUtility', 'logDMLError', 'SFDC CI');
        }
        return mapIdToErrorMsg;
    }
    /**
     * Method name  : logDMLError
     * Description  : This method logs DML Delete related errors in Error_Log__c object
                      particularlly for sharing object
     * Return Type  : void
     * Parameter    : List<Database.DeleteResult>, List<sObject>, String, String, String, String, Boolean
     **/
    public static Map<Id, List<String>> logDMLError(List<Database.DeleteResult>
        lstDeleteResult,
        List<SObject> lstSObject, String sObjectName, String sClassName, String sMethodName,
        String sSourceSystem, Boolean bSharingRecord) {
        Map<id, List<String>> mapIdToErrorMsg = new Map<id, List<String>>
            ();
        try {
            List<Error_Log__c> lstErrorLog = new List<Error_Log__c>();
            for(Integer i = 0; i<lstDeleteResult.size(); i++) {
                if(!lstDeleteResult.get(i)
                    .isSuccess()) {
                    String sErrorMsg;
                    Database.DeleteResult oDeleteResult = lstDeleteResult[i];
                    for(Database.Error oError: oDeleteResult.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(oError.getStatusCode() + ': ' + oError.getMessage());
                        System.debug('Fields that affected by this error: ' + oError.getFields());
                        sErrorMsg = oError.getMessage();
                        Error_Log__c oErrorLog = new Error_Log__c(
                            Record_Id__c = lstSObject[i].Id,
                            Object__c = sObjectName,
                            Error_Occurred_in_Class__c = sClassName,
                            Error_Occurred_in_Method__c = sMethodName,
                            Error_Body__c = sErrorMsg,
                            Logged_In_User__c = UserInfo.getUserId()
                        );
                        oErrorLog.Source_System__c = sSourceSystem;
                        if(bSharingRecord){
                            oErrorLog.User_Id__c = (String)lstSObject[i].get('UserOrGroupId');
                        }
                        lstErrorLog.add(oErrorLog);
                        if(!mapIdToErrorMsg.containsKey(lstSObject[i].Id)) {
                            mapIdToErrorMsg.put(lstSObject[i].Id, new List<string>());
                        }
                        mapIdToErrorMsg.get(lstSObject[i].Id)
                            .add(sErrorMsg);
                    }
                }
            }
            if(!lstErrorLog.isEmpty()) {
                List<Database.SaveResult> lstSaveResults = Database.insert(lstErrorLog,
                    false);
            }
        } catch(Exception oEx) {
            logGeneralError(oEx, 'ErrorLogUtility', 'logDMLError', 'SFDC CI');
        }
        return mapIdToErrorMsg;
    }
    /**
     * Method name  : logDMLError
     * Description  : This method logs DML Delete related errors in Error_Log__c object
     * Return Type  : void
     * Parameter    : List<Database.DeleteResult>, List<sObject>, String, String, String, String
     **/
    public static Map<Id, List<String>> logDMLError(List<Database.DeleteResult>
        lstDeleteResult,
        List<Id> lstSObjectIds, String sObjectName, String sClassName, String sMethodName,
        String sSourceSystem) {
        Map<id, List<String>> mapIdToErrorMsg = new Map<id, List<String>>
            ();
        try {
            List<Error_Log__c> lstErrorLog = new List<Error_Log__c>();
            for(Integer i = 0; i<lstDeleteResult.size(); i++) {
                if(!lstDeleteResult.get(i)
                    .isSuccess()) {
                    String sErrorMsg;
                    Database.DeleteResult oDeleteResult = lstDeleteResult[i];
                    for(Database.Error oError: oDeleteResult.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(oError.getStatusCode() + ': ' + oError.getMessage());
                        System.debug('Fields that affected by this error: ' + oError.getFields());
                        sErrorMsg = oError.getMessage();
                        Error_Log__c oErrorLog = new Error_Log__c(
                            Record_Id__c = lstSObjectIds[i],
                            Object__c = sObjectName,
                            Error_Occurred_in_Class__c = sClassName,
                            Error_Occurred_in_Method__c = sMethodName,
                            Error_Body__c = sErrorMsg,
                            Logged_In_User__c = UserInfo.getUserId()
                        );
                        oErrorLog.Source_System__c = sSourceSystem;
                        lstErrorLog.add(oErrorLog);
                        if(!mapIdToErrorMsg.containsKey(lstSObjectIds[i])) {
                            mapIdToErrorMsg.put(lstSObjectIds[i], new List<string>());
                        }
                        mapIdToErrorMsg.get(lstSObjectIds[i])
                            .add(sErrorMsg);
                    }
                }
            }
            if(!lstErrorLog.isEmpty()) {
                List<Database.SaveResult> lstSaveResults = Database.insert(lstErrorLog,
                    false);
            }
        } catch(Exception oEx) {
            logGeneralError(oEx, 'ErrorLogUtility', 'logDMLError', 'SFDC CI');
        }
        return mapIdToErrorMsg;
    }

    /**
     * Method name  : logGeneralError
     * Description  : This method logs all general errors in Error_Log__c object
     * Return Type  : void
     * Parameter    : Exception , String, String, String
     **/
    public static void logGeneralError(Exception oException, String sClassName,
        String sMethodName, String sSourceSystem) {
        if(oException != null) {
            Id generalErrorLogRecTypeId = Utility.getRecordTypeIdByDeveloperName(
                Error_Log__c.SObjectType,
                Constants.ERRORLOG_GENERAL);
            List<Error_Log__c> lstErrorLog = new List<Error_Log__c>();
            Error_Log__c oErrorLog = new Error_Log__c();
            oErrorLog.RecordTypeId = generalErrorLogRecTypeId;
            if(oException.getMessage() != null && !String.isEmpty(oException.getMessage())) {
                oErrorLog.Error_Body__c = oException.getMessage();
            }
            if(oException.getStackTraceString() != null && !String.isEmpty(oException.getStackTraceString())){
                oErrorLog.Stack_Trace__c = oException.getStackTraceString();
            }
            oErrorLog.Error_Occurred_in_Class__c = sClassName;
            oErrorLog.Error_Occurred_in_Method__c = sMethodName;
            if(oException.getLineNumber() != null) {
                oErrorLog.Error_Occurred_at_Line_Number__c = String.ValueOf(oException.getLineNumber());
            }
            oErrorLog.Source_System__c = sSourceSystem;
            if(oException.getTypeName() != null && !String.isEmpty(oException.getTypeName())) {
                oErrorLog.Type__c = oException.getTypeName();
            }
            lstErrorLog.add(oErrorLog);

            if(!lstErrorLog.isEmpty()) {
                List<Database.SaveResult> lstSaveResults = Database.insert(lstErrorLog,
                    false);
            }
        }
    }

}