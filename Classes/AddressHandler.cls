/******************************************************************************************************
Class Name         : AddressHandler
Description        : This is single Class for Address which will cover all theAddress Functionality.
                     All Methods to cover oAddress functionality will be defined in this class. These methods
                     will be called from AddressTrigger based on required trigger events.
Created By         :Sfurti Pandey
Created On         : 24-June-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class AddressHandler {
    
    /**
    * Method name  : onAfterInsert
    * Description  : This method will be called after any Address record is Inserted
    * Return Type  : void
    * Parameter    : List<Address__c> , Map<ID , Address__c>
    **/
    Public void onAfterInsert(List<Address__c> lstNewRecords , Map<Id,Address__c> mapOldRecords) {
        shareAddress(lstNewRecords,mapOldRecords);  
    }
    
    /**
    * Method name  : onAfterUpdate
    * Description  : This method will be called after any Address record is Updated
    * Return Type  : void
    * Parameter    : List<Address__c> , Map<ID , Address__c>
    **/
    Public void onAfterUpdate(List<Address__c> lstNewRecords , Map<Id,Address__c> mapOldRecords) {
        shareAddress(lstNewRecords,mapOldRecords);  
    }
    
    /**
    * Method name  : shareAddress
    * Description  : This method will share Address Records with Partner users.
    * Return Type  : void
    * Parameter    : List<Address__c>
    **/
    public void  shareAddress(List<Address__c> lstNewRecords, Map<Id,Address__c> mapOldRecords) {
        
        Id icpAddRecTypeId = Utility.getRecordTypeIdByDeveloperName(Address__c.SObjectType,
            Constants.ICP_ADDRESS_RT_API_NAME);
        Set<Id> setICPId = new Set<Id>();
        Set<Id> setICPIdToDelete = new Set<Id>();
        List<Address__Share> lstAddressShare = new List<Address__Share>();
        List<Address__Share> lstAddressShareToDelete = new List<Address__Share>();
        map<Id,List<Id>> mapICPIdToUsersLstId = new map<Id,List<Id>>();
        for(Address__c oAddress: lstNewRecords){
            if((icpAddRecTypeId.equals(oAddress.RecordTypeId) && !String.isEmpty(oAddress.Account__c)) && (trigger.isInsert || (trigger.isUpdate && oAddress.Account__c != mapOldRecords.get(OAddress.Id).Account__c))){
                setICPId.add(oAddress.Account__c);
                if(trigger.isUpdate){
                    setICPIdToDelete.add(oAddress.Id);
                }
            }
        }
        if(!setICPIdToDelete.isEmpty()){
            lstAddressShareToDelete = [Select Id from Address__Share where ParentId IN: setICPIdToDelete and RowCause=: Constants.APEX_BASED_SHARING];
            if(!lstAddressShareToDelete.isEmpty()){
                List<Database.DeleteResult> lstDeleteResults = 
                    Database.delete(lstAddressShareToDelete,false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstDeleteResults, lstAddressShareToDelete, 
                    'Address__Share','AddressHandler', 'shareAddress','SFDC CI',true);
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
            for(Address__c oAddress: lstNewRecords){
                if(mapICPIdToUsersLstId.containsKey(oAddress.Account__c)){
                    for(Id userId: mapICPIdToUsersLstId.get(oAddress.Account__c)){
                        lstAddressShare.add((Address__Share)Utility.createShareRecord(oAddress.Id,userId,Constants.ADDRESS_OBJ_API_NAME,Constants.READ_ACCESS));
                    }
                    
                }
            }
            If(!lstAddressShare.ISEmpty()){
                List<Database.SaveResult> lstInsertResults =
                    Database.Insert(lstAddressShare, false);
                Map<Id,List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstInsertResults, lstAddressShare,
                    'Address__Share',
                    'AddressHandler', 'addressShare', 'SFDC CI', false, true
                );
            }
        }
            
     }
}