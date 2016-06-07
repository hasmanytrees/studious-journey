/******************************************************************************************************
Class Name         : BeneficiaryClassAttendanceTrigger
Deascription       : This is single trigger for Beneficiary Class Attendance which will cover all the trigger
					 events. All the functionality on Beneficiary Class Attendance should be called from this
					 trigger. Methods to cover all Beneficiary Class Attendance functionality will be defined
					 in Beneficiary Class Attendance Handler class named BeneficiaryClassAttendanceHandler.
Created By         : Sudipta Nayak 
Created On         : 16-Sep-2015 
******************************************************************************************************/

trigger BeneficiaryClassAttendanceTrigger on Beneficiary_Class_Attendance__c (after insert, after update) {
	BeneficiaryClassAttendanceHandler beneficiaryClassAttendanceHandler = new BeneficiaryClassAttendanceHandler();
    if( Trigger.IsAfter && Trigger.IsInsert ) {
        beneficiaryClassAttendanceHandler.onAfterInsert(trigger.new);
    }
    if( Trigger.IsAfter && Trigger.IsUpdate ) {
        beneficiaryClassAttendanceHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    }
}