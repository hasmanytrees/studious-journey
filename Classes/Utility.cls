/******************************************************************************************************
Class Name         : Utility
Deascription       : This is single Class which contains all generic methods that are required across all
                     other development. Use this class to define methods like getting RecordtypeId, Reading 
                     Picklist values and any other generic processing that might be reusable in other development in future.
Created By         : Vishal Katyare 
Created On         : 14-Oct-2014 
******************************************************************************************************/

global class Utility {
    private static Id sysAdminProfileId = null; 
    // Build a local cache so that we don't request this multiple times
    private static Map<Schema.SObjectType, Map<String, Id>> mapRecTypeCache;
    static {
        mapRecTypeCache = new Map<Schema.SObjectType, Map<String, Id>>();
    }

    public static Boolean bIsRecordInsert = false;

    /**
     * Method name  : getFieldGroupElements
     * Description  : This method is for returning fields in Field Group Elements to be used in Query
     * Return Type  : String
     * Parameter    : String
     **/
    public static string getFieldGroupElements(String sFieldGroupName) {
        List<Field_Group_Element__c> lstFieldGroupElements = new List<Field_Group_Element__c>();
        try{
             lstFieldGroupElements = [Select Id,
                Field_Group__r.Name, Field_API_Name__c from Field_Group_Element__c where 
                Field_Group__r.Name = : sFieldGroupName
            ];
        }catch(System.QueryException oQe) {
                ErrorLogUtility.logGeneralError(oQe, 'Utility', 
                    'getFieldGroupElements', 'SFDC CI');
        }
        String sQueryString = Constants.EMPTY_STRING;
        if(!lstFieldGroupElements.isEmpty()) {
            for(Field_Group_Element__c oListElement: lstFieldGroupElements) {
                sQueryString += oListElement.Field_API_Name__c + Constants.COMMA;
            }
        }

        return sQueryString;
    }

    /**
    * Method name  : getRecordTypeIdByDeveloperName
    * Description  : Returns a map of active, user-available RecordType IDs for a given SoConcernedDescribeectType, 
                     keyed by each RecordType's unique, unchanging DeveloperName
    * Return Type  : Id
    * Parameter    : Schema.SoConcernedDescribeectType, String
    **/
    public static Id getRecordTypeIdByDeveloperName(Schema.SObjectType oToken,
        String sRecTypeDevName) {

        Map<String, Id> mapRecordTypes = mapRecTypeCache.get(oToken);

        if(mapRecordTypes == null) {
            mapRecordTypes = new Map<String, Id>();
            mapRecTypeCache.put(oToken, mapRecordTypes);
        } else {
            return mapRecordTypes.keySet()
                .contains(sRecTypeDevName) ? mapRecordTypes.get(sRecTypeDevName) : null;
        }

        Schema.DescribeSObjectResult oConcernedDescribe = oToken.getDescribe();

        String sSoqlString =
            'SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = \'' +
            String.escapeSingleQuotes(oConcernedDescribe.getName()) +
            '\' AND IsActive = TRUE';
        List<SObject> lstResults;
        try {
            lstResults = Database.query(sSoqlString);
        } catch(System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'Utility', 
                    'getRecordTypeIdByDeveloperName', 'SFDC CI');
            lstResults = new List<SObject>();
        }

        for(SObject oRecType: lstResults) {
            mapRecordTypes.put(String.valueOf(oRecType.get(Constants.DEVELOPER_NAME)),
                oRecType.Id);
        }

        return mapRecordTypes.keySet()
            .contains(sRecTypeDevName) ? mapRecordTypes.get(sRecTypeDevName) : null;
    }
            
    /**
    * Method name  : getSystemAdminProfileId
    * Description  : This method returns System Admin Profile Id
    * Return Type  : Id
    **/
    
    public static Id getSystemAdminProfileId(){
        if(null==sysAdminProfileId){
            sysAdminProfileId = [select Id 
                from Profile where name=:Label.System_Administrator LIMIT 1].Id;
        }
        return sysAdminProfileId;
    }
    
    /**
    * Method name  : createShareRecord
    * Description  : This method creates share record for Standard And Custom objects
    * Return Type  : Id
    * Parameter    : Id, Id, String, String
    **/
    public Static SObject createShareRecord(Id RecordId, Id UsrOrGroupId, String sShareObjectType, String sAccessLevel){
        Sobject oShareRecord;
        if(sShareObjectType.endsWith(Constants.PREFIX_CUSTOM_OBJ_API_NAME)) {
            String sObjectShare = sShareObjectType.substring(0,sShareObjectType.length()-1)+Constants.SHARE;
            Schema.SObjectType oSObjectType = Schema.getGlobalDescribe().get(sObjectShare);
            oShareRecord = oSObjectType.newSObject();
            oShareRecord.put(Constants.PARENTID,RecordId);
            oShareRecord.put(Constants.USERORGROUPID,UsrOrGroupId);
            oShareRecord.put(Constants.ACCESSLEVEL,sAccessLevel);
            oShareRecord.put(Constants.ROWCAUSE,COnstants.APEX_BASED_SHARING); 
        }       
        else{
            String sObjectShareId = sShareObjectType+Constants.STRING_ID;
            String sObjectShare = sShareObjectType+Constants.SHARE;
            Schema.SObjectType oSObjectType = Schema.getGlobalDescribe().get(sObjectShare);
            oShareRecord = oSObjectType.newSObject();
            oShareRecord.put(sShareObjectType+Constants.STRING_ID,RecordId);
            oShareRecord.put(Constants.USERORGROUPID,UsrOrGroupId);
            oShareRecord.put(sShareObjectType+Constants.ACCESSLEVEL,sAccessLevel);
            if(sShareObjectType.equals(Constants.ACCOUNT_OBJ_API_NAME)){
                oShareRecord.put(Constants.OPPORTUNITYACCESSLEVEL,Constants.NONE_VALUE);
            }
        }
        return oShareRecord;
    }
    
    /**
    * Method name  : insertShareRecords
    * Description  : This method insert share record for Standard And Custom objects
    * Return Type  : Id
    * Parameter    : User, List<sObject>, String 
    **/
    public Static Boolean insertShareRecord(User oUser, List<sObject> lstToInsert, String sShareObjectName){
        Boolean bError = false;
        try{
            insert lstToInsert;
        }catch(Exception oEx){
            bError = true;
            String sMessage = oEx.getMessage();
            oEx.setMessage(Constants.ERROR_LOG_INSERT_MESSAGE1 +sShareObjectName+Constants.ERROR_LOG_INSERT_MESSAGE2+oUser.Id+Constants.ERROR_LOG_INSERT_MESSAGE3+sMessage);
            ErrorLogUtility.logGeneralError(oEx,'Utility','insertShareRecord','SFDC CI');
        }
        return bError;
    }
    
    /**
    * Method name  : deleteShareRecord
    * Description  : This method delete share record for Standard And Custom objects
    * Return Type  : Id
    * Parameter    : User, List<sObject>, String 
    **/
    public Static Boolean deleteShareRecord(User oUser, List<sObject> lstToDelete, String sShareObjectName){
        Boolean bError = false;
        try{
            delete lstToDelete;
        }catch(Exception oEx){
            bError = true;
            String sMessage = oEx.getMessage();
            oEx.setMessage(Constants.ERROR_LOG_INSERT_MESSAGE1+sShareObjectName+Constants.ERROR_LOG_DELETE_MESSAGE1+oUser.Id+Constants.ERROR_LOG_INSERT_MESSAGE3+sMessage);
            ErrorLogUtility.logGeneralError(oEx,'Utility','deleteShareRecord','SFDC CI');
        }
        return bError;
    }
}