/******************************************************************************************************
Class Name         : YearlyClassScheduleHandler
Description        : This is single Class for Yearly Class Schedule which will cover all the 
                     Yearly Class Schedule Functionality.
                     All Methods to cover Yearly Class Schedule functionality will be defined in this 
                     class. These methods will be called from Yearly Class ScheduleTrigger based on 
                     required trigger events.
Created By         : Danish Ahmed
Created On         : 08-Sep-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class YearlyClassScheduleHandler{

    /**
    * Method name  : onAfterInsert
    * Description  : This method will be called after any Yearly Class Schedule record is Inserted
    * Return Type  : void
    * Parameter    : List<Yearly_Class_Schedule__c> , Map<ID , Yearly_Class_Schedule__c>
    **/
    Public void onAfterInsert(List<Yearly_Class_Schedule__c> lstNewRecords , Map<Id,Yearly_Class_Schedule__c> mapOldRecords) {
        shareYearlyClassSchedule(lstNewRecords,mapOldRecords);  
    }
    
    /**
    * Method name  : onAfterUpdate
    * Description  : This method will be called after any Yearly Class Schedule record is Updated
    * Return Type  : void
    * Parameter    : List<Yearly_Class_Schedule__c> , Map<ID , Yearly_Class_Schedule__c>
    **/
    Public void onAfterUpdate(List<Yearly_Class_Schedule__c> lstNewRecords , Map<Id,Yearly_Class_Schedule__c> mapOldRecords) {
        shareYearlyClassSchedule(lstNewRecords,mapOldRecords);  
    }
    
    /**
    * Method name  : shareYearlyClassSchedule
    * Description  : This method will share Yearly Class Schedule Records with Partner users.
    * Return Type  : void
    * Parameter    : List<Yearly_Class_Schedule__c>, Map<Id,Yearly_Class_Schedule__c> 
    **/
    public void  shareYearlyClassSchedule(List<Yearly_Class_Schedule__c> lstNewRecords, Map<Id,Yearly_Class_Schedule__c> mapOldRecords) {
        
        Set<Id> setICPId = new Set<Id>();
        Set<Id> setYearlyClassIdToDelete = new Set<Id>();
        List<Yearly_Class_Schedule__Share> lstYearlyClassShare = new List<Yearly_Class_Schedule__Share>();
        List<Yearly_Class_Schedule__Share> lstYearlyClassShareToDelete = new List<Yearly_Class_Schedule__Share>();
        List<Yearly_Class_Schedule__c> lstYearlyClassToShare = new List<Yearly_Class_Schedule__c>();
        map<Id,List<Id>> mapICPIdToUsersLstId = new map<Id,List<Id>>();
        
        for(Yearly_Class_Schedule__c oYearlyClass: lstNewRecords){
            if(!String.isEmpty(oYearlyClass.ICP_Name__c) && (trigger.isInsert || (trigger.isUpdate && oYearlyClass.ICP_Name__c != mapOldRecords.get(oYearlyClass.Id).ICP_Name__c))){
                setICPId.add(oYearlyClass.ICP_Name__c);
                lstYearlyClassToShare.add(oYearlyClass);
                if(trigger.isUpdate){
                    setYearlyClassIdToDelete.add(oYearlyClass.Id);
                }
            }
        }
        if(!setYearlyClassIdToDelete.isEmpty()){
            lstYearlyClassShareToDelete = [Select Id from Yearly_Class_Schedule__Share where ParentId IN: setYearlyClassIdToDelete and RowCause='Apex_Based_Sharing__c'];
            if(!lstYearlyClassShareToDelete.isEmpty()){
            List<Database.DeleteResult> lstDeleteResults = 
                Database.delete(lstYearlyClassShareToDelete,false);
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                      lstDeleteResults, lstYearlyClassShareToDelete, 
                      'Yearly_Class_Schedule__Share','YearlyClassScheduleHandler', 'shareYearlyClassSchedule','SFDC CI',true);
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
            for(Yearly_Class_Schedule__c oYearlyClass: lstYearlyClassToShare){
                if(mapICPIdToUsersLstId.containsKey(oYearlyClass.ICP_Name__c)){
                    for(Id userId: mapICPIdToUsersLstId.get(oYearlyClass.ICP_Name__c)){
                        if(oYearlyClass.OwnerId != userId)
                            lstYearlyClassShare.add((Yearly_Class_Schedule__Share)Utility.createShareRecord(oYearlyClass.Id,userId,'Yearly_Class_Schedule__c','Edit'));
                    }
                            
                }
            }
            If(!lstYearlyClassShare.ISEmpty()){
                List<Database.SaveResult> lstInsertResults =
                    Database.Insert(lstYearlyClassShare, false);
                Map<Id,List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                    lstInsertResults, lstYearlyClassShare,
                    'Yearly_Class_Schedule__Share',
                    'YearlyClassScheduleHandler', 'shareYearlyClassSchedule', 'SFDC CI', false
                );
            }
        }
    }
}