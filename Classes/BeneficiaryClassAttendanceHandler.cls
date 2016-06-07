/******************************************************************************************************
Class Name         : BeneficiaryClassAttendanceHandler
Description        : This is single Class for Beneficiary Class Attendance which will cover all it's
					 trigger functionality. These methods will be called from BeneficiaryClassAttendance
					 Trigger based on required trigger events.
Created By         : Sudipta Nayak
Created On         : 16-Sep-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class BeneficiaryClassAttendanceHandler {
	/**
	 * Method name  : onAfterInsert
	 * Description  : This method will be called after any Beneficiary Class Attendance record is inserted
	 * Return Type  : void
	 * Parameter    : List<Beneficiary_Class_Attendance__c>
	 **/
	public void onAfterInsert(List<Beneficiary_Class_Attendance__c> lstNewRecords) {
		updateLastAttendedDateOnInsert(lstNewRecords);
	}
    
    /**
	 * Method name  : onAfterUpdate
	 * Description  : This method will be called after any Beneficiary Class Attendance record is inserted
	 * Return Type  : void
	 * Parameter    : List<Beneficiary_Class_Attendance__c>
	 **/
	public void onAfterUpdate(List<Beneficiary_Class_Attendance__c> lstNewRecords, Map <Id, Beneficiary_Class_Attendance__c> mapOldRecords) {
		updateLastAttendedDateOnUpdate(lstNewRecords, mapOldRecords);
	}
    
    /**
	 * Method name  : updateLastAttendedDateOnInsert
	 * Description  : This method will update the last attended date for a Beneficiary
	 * Return Type  : void
	 * Parameter    : List<Beneficiary_Class_Attendance__c>
	 **/
	private void updateLastAttendedDateOnInsert(List<Beneficiary_Class_Attendance__c> lstNewRecords) {
        Set<Id> setBeneficiaryIds = new Set<Id>();
        Map <Id, Account> mapBeneficiaryToDate = new Map <Id, Account>();
        List<Account> lstBeneficiaryToUpdate = new List<Account>();
        for(Beneficiary_Class_Attendance__c oAttendance: lstNewRecords) {
            if((oAttendance.Class_Type__c == Constants.CENTER_BASED_CLASS || oAttendance.Class_Type__c == Constants.GROUP_ACTIVITIES) && oAttendance.BEN_Attended__c) {
                	setBeneficiaryIds.add(oAttendance.BEN_Id__c);
            }
        }
        System.debug('setBeneficiaryIds'+setBeneficiaryIds);
        if(!setBeneficiaryIds.isEmpty()) {
        	mapBeneficiaryToDate = new Map <Id, Account>([SELECT Id, Last_Class_Attended_Date__c, 
                                   Last_Activity_Attended_Date__c from Account where Id in: setBeneficiaryIds]);
        }
        System.debug('mapBeneficiaryToDate'+mapBeneficiaryToDate);
        for(Beneficiary_Class_Attendance__c oAttendance: lstNewRecords) {
            if(setBeneficiaryIds.contains(oAttendance.BEN_Id__c) && mapBeneficiaryToDate.containsKey(oAttendance.BEN_Id__c) && 
              (mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c == NULL && 
                   oAttendance.Class_Type__c == Constants.CENTER_BASED_CLASS || 
               mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c == NULL && 
                        oAttendance.Class_Type__c == Constants.GROUP_ACTIVITIES)) {
                if(mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c == NULL && 
                   oAttendance.Class_Type__c == Constants.CENTER_BASED_CLASS && oAttendance.BEN_Attended__c == true) {
                    System.debug('mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c'+
                                 mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c);
                    System.debug('oAttendance.Class_Date__c'+oAttendance.Class_Date__c);
                    mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c = oAttendance.Class_Date__c;
                    mapBeneficiaryToDate.put(oAttendance.BEN_Id__c, mapBeneficiaryToDate.get(oAttendance.BEN_Id__c));
                   }
                else if(mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c == NULL && 
                        oAttendance.Class_Type__c == Constants.GROUP_ACTIVITIES && oAttendance.BEN_Attended__c == true) {
                        System.debug('mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c'+
                                 mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c);
                        System.debug('oAttendance.Class_Date__c'+oAttendance.Class_Date__c);
                        mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c = oAttendance.Class_Date__c;
                        mapBeneficiaryToDate.put(oAttendance.BEN_Id__c, mapBeneficiaryToDate.get(oAttendance.BEN_Id__c));
                        }
            }
            else if(setBeneficiaryIds.contains(oAttendance.BEN_Id__c) && mapBeneficiaryToDate.containsKey(oAttendance.BEN_Id__c)) {
                if(mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c < oAttendance.Class_Date__c && 
                   oAttendance.Class_Type__c == Constants.CENTER_BASED_CLASS && oAttendance.BEN_Attended__c == true) {
                    System.debug('mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c'+
                                 mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c);
                    System.debug('oAttendance.Class_Date__c'+oAttendance.Class_Date__c);
                    mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c = oAttendance.Class_Date__c;
                    mapBeneficiaryToDate.put(oAttendance.BEN_Id__c, mapBeneficiaryToDate.get(oAttendance.BEN_Id__c));
            	}
                else if(mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c < oAttendance.Class_Date__c && 
                        oAttendance.Class_Type__c == Constants.GROUP_ACTIVITIES && oAttendance.BEN_Attended__c == true) {
                        System.debug('mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c'+
                                 mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c);
                    	System.debug('oAttendance.Class_Date__c'+oAttendance.Class_Date__c);
                    	mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c = oAttendance.Class_Date__c;
                    	mapBeneficiaryToDate.put(oAttendance.BEN_Id__c, mapBeneficiaryToDate.get(oAttendance.BEN_Id__c));
            	}
        	}
        }
        System.debug('mapBeneficiaryToDate'+mapBeneficiaryToDate);
        if(!mapBeneficiaryToDate.isEmpty()) {
            for(Account oAccount: mapBeneficiaryToDate.values()) {
                lstBeneficiaryToUpdate.add(oAccount);
            }
        }
        System.debug('lstBeneficiaryToUpdate'+lstBeneficiaryToUpdate);
        if(!lstBeneficiaryToUpdate.isEmpty()) {
            List < Database.SaveResult > lstUpdateResults =
                Database.update(lstBeneficiaryToUpdate, false);
            ErrorLogUtility.logDMLError(lstUpdateResults, lstBeneficiaryToUpdate,
                'Account','BeneficiaryClassAttendanceHandler',
                'updateLastAttendedDate', 'SFDC CI', false);
        }
	}
    
    /**
	 * Method name  : updateLastAttendedDateOnUpdate
	 * Description  : This method will update the last attended date for a Beneficiary
	 * Return Type  : void
	 * Parameter    : List<Beneficiary_Class_Attendance__c>, Map <Id, Beneficiary_Class_Attendance__c>
	 **/
	private void updateLastAttendedDateOnUpdate( List<Beneficiary_Class_Attendance__c> lstNewRecords, Map <Id, Beneficiary_Class_Attendance__c> mapOldRecords) {
        Set<Id> setBeneficiaryIds = new Set<Id>();
        Map<Id, Account> mapBeneficiaryToDate = new Map<Id, Account>();
        List<Account> lstBeneficiaryToUpdate = new List<Account>();
        Map<Id, Beneficiary_Class_Attendance__c> mapBeneficiaryAttendance = new Map<Id, Beneficiary_Class_Attendance__c>();
        Date dtLast60Days = System.today() - 61;
        for(Beneficiary_Class_Attendance__c oAttendance: lstNewRecords) {
            if((oAttendance.Class_Type__c == Constants.CENTER_BASED_CLASS || oAttendance.Class_Type__c == Constants.GROUP_ACTIVITIES) && mapOldRecords.get(oAttendance.Id).BEN_Attended__c != oAttendance.BEN_Attended__c) {
                	setBeneficiaryIds.add(oAttendance.BEN_Id__c);
            }
        }
        System.debug('setBeneficiaryIds'+ setBeneficiaryIds);
        if(!setBeneficiaryIds.isEmpty()) {
        	mapBeneficiaryToDate = new Map <Id, Account>([SELECT Id, Last_Class_Attended_Date__c, 
                                   Last_Activity_Attended_Date__c from Account where Id in: setBeneficiaryIds]);
        }
        if(!setBeneficiaryIds.isEmpty()) {
        	mapBeneficiaryAttendance = new Map<Id, Beneficiary_Class_Attendance__c>([SELECT Id, BEN_Attended__c, BEN_Id__c, Class_Date__c,
                                   Class_Type__c from Beneficiary_Class_Attendance__c where BEN_Id__c in: setBeneficiaryIds AND 
                                   BEN_Attended__c =: True AND Class_Date__c >: dtLast60Days]);
        }
        System.debug('mapBeneficiaryAttendance'+ mapBeneficiaryAttendance);
        for(Beneficiary_Class_Attendance__c oAttendance: lstNewRecords) {
            if(setBeneficiaryIds.contains(oAttendance.BEN_Id__c)) {
                if(oAttendance.Class_Type__c == Constants.CENTER_BASED_CLASS)
                	mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c = dtLast60Days;
                else if(oAttendance.Class_Type__c == Constants.GROUP_ACTIVITIES)
                    mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c = dtLast60Days;
                mapBeneficiaryToDate.put(oAttendance.BEN_Id__c, mapBeneficiaryToDate.get(oAttendance.BEN_Id__c));
            }
        }
        for(Beneficiary_Class_Attendance__c oAttendance: mapBeneficiaryAttendance.values()) {
            if(mapBeneficiaryToDate.containsKey(oAttendance.BEN_Id__c) && oAttendance.Class_Type__c == Constants.CENTER_BASED_CLASS
               && mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c < oAttendance.Class_Date__c ) {
            	System.debug('mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c'+
                             mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c);
                System.debug('oAttendance.Class_Date__c'+oAttendance.Class_Date__c);
                mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c = oAttendance.Class_Date__c;
                mapBeneficiaryToDate.put(oAttendance.BEN_Id__c, mapBeneficiaryToDate.get(oAttendance.BEN_Id__c));
            }
            else if(mapBeneficiaryToDate.containsKey(oAttendance.BEN_Id__c) && oAttendance.Class_Type__c == Constants.GROUP_ACTIVITIES
                    && mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c < oAttendance.Class_Date__c ) {
            	System.debug('mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c'+
                             mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Activity_Attended_Date__c);
                System.debug('oAttendance.Class_Date__c'+oAttendance.Class_Date__c);
                mapBeneficiaryToDate.get(oAttendance.BEN_Id__c).Last_Class_Attended_Date__c = oAttendance.Class_Date__c;
                mapBeneficiaryToDate.put(oAttendance.BEN_Id__c, mapBeneficiaryToDate.get(oAttendance.BEN_Id__c));
            }
        }
        System.debug('mapBeneficiaryToDate'+mapBeneficiaryToDate);
        
        if(!mapBeneficiaryToDate.isEmpty()) {
            for(Account oAccount: mapBeneficiaryToDate.values()) {
                lstBeneficiaryToUpdate.add(oAccount);
            }
        }
        System.debug('lstBeneficiaryToUpdate'+lstBeneficiaryToUpdate);
        if(!lstBeneficiaryToUpdate.isEmpty()) {
            List < Database.SaveResult > lstUpdateResults =
                Database.update(lstBeneficiaryToUpdate, false);
            ErrorLogUtility.logDMLError(lstUpdateResults, lstBeneficiaryToUpdate,
                'Account','BeneficiaryClassAttendanceHandler',
                'updateLastAttendedDate', 'SFDC CI', false);
        }
	}
}