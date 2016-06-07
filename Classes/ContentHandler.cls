/******************************************************************************************************
Class Name         : ContentHandler
Description        : This is single Class for Content which will cover all the Content Functionality.
                     All Methods to cover Content functionality will be defined in this class. These methods
                     will be called from ContentTrigger based on required trigger events.
Created By         : Danish Ahmed
Created On         : 03-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class ContentHandler {
    
    /**
    * Method name  : onAfterInsert
    * Description  : This method will be called after any Content record is Inserted
    * Return Type  : void
    * Parameter    : List<Content__c> , Map<ID , Content__c>
    **/
    Public void onAfterInsert(List<Content__c> lstNewRecords , Map<Id,Content__c> mapOldRecords) {
        shareContent(lstNewRecords,mapOldRecords);  
    }
    
    /**
    * Method name  : onAfterUpdate
    * Description  : This method will be called after any Content record is Updated
    * Return Type  : void
    * Parameter    : List<Content__c> , Map<ID , Content__c>
    **/
    Public void onAfterUpdate(List<Content__c> lstNewRecords , Map<Id,Content__c> mapOldRecords) {
        shareContent(lstNewRecords,mapOldRecords);  
    }
    
    /**
    * Method name  : shareContent
    * Description  : This method will share Content Records with Partner users.
    * Return Type  : void
    * Parameter    : List<Content__c>, Map<Id,Content__c> 
    **/
    private void  shareContent(List<Content__c> lstNewRecords, Map<Id,Content__c> mapOldRecords) {
        
        Id icpContentRecTypeId = Utility.getRecordTypeIdByDeveloperName(Content__c.SObjectType,
            Constants.CONTENT_ICP_RT_API_NAME);
        Id benefContentRecTypeId = Utility.getRecordTypeIdByDeveloperName(Content__c.SObjectType,
            Constants.CONTENT_BENEFICIARY_RT_API_NAME);
        Id benefAssesContentRecTypeId = Utility.getRecordTypeIdByDeveloperName(Content__c.SObjectType,
            Constants.CONTENT_BENEF_ASSESMNT_RT_API_NAME);
        Id bleContentRecTypeId = Utility.getRecordTypeIdByDeveloperName(Content__c.SObjectType,
            Constants.CONTENT_BLE_RT_API_NAME);
        Set<Id> setICPId = new Set<Id>();
        Set<Id> setContentId = new Set<Id>();
        Set<Id> setContenShareToDelete = new Set<Id>();
        Set<Id> setICPIdToDelete = new Set<Id>();
        List<Content__Share> lstContentShare = new List<Content__Share>();
        List<Content__Share> lstContentShareToDelete = new List<Content__Share>();
        map<Id,List<Id>> mapICPIdToUsersLstId = new map<Id,List<Id>>();
        for(Content__c oContent: lstNewRecords){
            if(((icpContentRecTypeId.equals(oContent.RecordTypeId) || benefContentRecTypeId.equals(oContent.RecordTypeId) || 
                benefAssesContentRecTypeId.equals(oContent.RecordTypeId) || bleContentRecTypeId.equals(oContent.RecordTypeId)) 
                && (!String.isEmpty(oContent.ICP__c) || !String.isEmpty(oContent.Beneficiary__c) || 
                !String.isEmpty(oContent.Beneficiary_Assessment__c) || !String.isEmpty(oContent.Beneficiary_Lifecycle_Event__c))) 
                && (trigger.isInsert || (trigger.isUpdate && (oContent.ICP__c != mapOldRecords.get(oContent.Id).ICP__c || 
                oContent.Beneficiary__c != mapOldRecords.get(oContent.Id).Beneficiary__c || 
                oContent.Beneficiary_Assessment__c != mapOldRecords.get(oContent.Id).Beneficiary_Assessment__c || 
                oContent.Beneficiary_Lifecycle_Event__c != mapOldRecords.get(oContent.Id).Beneficiary_Lifecycle_Event__c)))){
                setContentId.add(oContent.Id);          
            }
        }
        if(!setContentId.isEmpty()){
        List<Content__c> lstContentsToShare = [Select Id,OwnerId,ICP__c,Beneficiary__r.ICP__c,Beneficiary_Assessment__r.Beneficiary__r.ICP__c,
            Beneficiary_Lifecycle_Event__r.Beneficiary__r.ICP__c from Content__c where Id IN: setContentId];
            if(!lstContentsToShare.isEmpty()){
                for(Content__c oContent: lstContentsToShare){
                    if(trigger.isInsert || (trigger.isUpdate && ((oContent.ICP__c != mapOldRecords.get(oContent.Id).ICP__c || 
                        oContent.Beneficiary__r.ICP__c != mapOldRecords.get(oContent.Id).Beneficiary__r.ICP__c || 
                        oContent.Beneficiary_Assessment__r.Beneficiary__r.ICP__c != mapOldRecords.get(oContent.Id).Beneficiary_Assessment__r.Beneficiary__r.ICP__c || 
                        oContent.Beneficiary_Lifecycle_Event__r.Beneficiary__r.ICP__c != mapOldRecords.get(oContent.Id).Beneficiary_Lifecycle_Event__r.Beneficiary__r.ICP__c)))){
                        if(!String.isEmpty(oContent.ICP__c)){
                            setICPId.add(oContent.ICP__c);
                        }
                        else if(!String.isEmpty(oContent.Beneficiary__r.ICP__c)){
                            setICPId.add(oContent.Beneficiary__r.ICP__c);
                        }
                        else if(!String.isEmpty(oContent.Beneficiary_Assessment__r.Beneficiary__r.ICP__c)){
                            setICPId.add(oContent.Beneficiary_Assessment__r.Beneficiary__r.ICP__c);
                        }
                        else if(!String.isEmpty(oContent.Beneficiary_Lifecycle_Event__r.Beneficiary__r.ICP__c)){
                            setICPId.add(oContent.Beneficiary_Lifecycle_Event__r.Beneficiary__r.ICP__c);
                        }
                        if(trigger.isUpdate){
                            setICPIdToDelete.add(oContent.Id);
                        }
                    }
                }
                if(!setICPIdToDelete.isEmpty()){
                    lstContentShareToDelete = [Select Id from Content__Share where ParentId IN: setICPIdToDelete and RowCause=: Constants.APEX_BASED_SHARING];
                    if(!lstContentShareToDelete.isEmpty()){
                        List<Database.DeleteResult> lstDeleteResults = 
                            Database.delete(lstContentShareToDelete,false);
                        Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                            lstDeleteResults, lstContentShareToDelete, 
                            'Content__Share','ContentHandler', 'shareContent','SFDC CI',true);
                    }
                }
                if(!setICPId.isEmpty()){
                    for(User oUser: [Select id,AccountId  from user where AccountId IN: setICPId and IsActive = true]){
                        if(mapICPIdToUsersLstId.containsKey(oUser.AccountId)){
                            mapICPIdToUsersLstId.get(oUser.AccountId).add(oUser.Id);
                        }   
                        else
                            mapICPIdToUsersLstId.put(oUser.AccountId,new List<Id> {oUser.Id});
                    }
                    for(Content__c oContent: lstContentsToShare){
                        if(mapICPIdToUsersLstId.containsKey(oContent.ICP__c)){
                            for(Id userId: mapICPIdToUsersLstId.get(oContent.ICP__c)){
                                if(oContent.OwnerId != userId)
                                    lstContentShare.add((Content__Share)Utility.createShareRecord(oContent.Id,userId,Constants.CONTENT_OBJ_API_NAME,Constants.EDIT_ACCESS));
                            }
                            
                        }
                        else if(mapICPIdToUsersLstId.containsKey(oContent.Beneficiary__r.ICP__c)){
                            for(Id userId: mapICPIdToUsersLstId.get(oContent.Beneficiary__r.ICP__c)){
                                if(oContent.OwnerId != userId)
                                    lstContentShare.add((Content__Share)Utility.createShareRecord(oContent.Id,userId,Constants.CONTENT_OBJ_API_NAME,Constants.EDIT_ACCESS));
                            }
                            
                        }
                        else if(mapICPIdToUsersLstId.containsKey(oContent.Beneficiary_Assessment__r.Beneficiary__r.ICP__c)){
                            for(Id userId: mapICPIdToUsersLstId.get(oContent.Beneficiary_Assessment__r.Beneficiary__r.ICP__c)){
                                if(oContent.OwnerId != userId)
                                    lstContentShare.add((Content__Share)Utility.createShareRecord(oContent.Id,userId,Constants.CONTENT_OBJ_API_NAME,Constants.EDIT_ACCESS));
                            }
                            
                        }
                        else if(mapICPIdToUsersLstId.containsKey(oContent.Beneficiary_Lifecycle_Event__r.Beneficiary__r.ICP__c)){
                            for(Id userId: mapICPIdToUsersLstId.get(oContent.Beneficiary_Lifecycle_Event__r.Beneficiary__r.ICP__c)){
                                if(oContent.OwnerId != userId)
                                    lstContentShare.add((Content__Share)Utility.createShareRecord(oContent.Id,userId,Constants.CONTENT_OBJ_API_NAME,Constants.EDIT_ACCESS));
                            }
                            
                        }
                    }
                    If(!lstContentShare.ISEmpty()){
                        List<Database.SaveResult> lstInsertResults =
                            Database.Insert(lstContentShare, false);
                        Map<Id,List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                            lstInsertResults, lstContentShare,
                            'Content__Share',
                            'ContentHandler', 'contentShare', 'SFDC CI', false, true
                        );
                    }
                }
            }
        }
     }
}