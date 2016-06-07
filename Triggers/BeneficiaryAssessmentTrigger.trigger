/******************************************************************************************************
Class Name         : BeneficiaryAssessmentTrigger
Description       : This is single trigger for Beneficiary_Assessment__c which will cover all the trigger events.
                     All the functionality on Beneficiary_Assessment__c should be called from this trigger. Methods 
                     to cover all Beneficiary Lifecycle Event functionality will be defined in class named
                     BeneficiaryAssessmentHandler.
Created By         : Himanshu Raichandani 
Created On         : 15-Jan-2015 
******************************************************************************************************/
trigger BeneficiaryAssessmentTrigger on Beneficiary_Assessment__c(after insert,
	before insert, before update) {

	BeneficiaryAssessmentHandler handler = new BeneficiaryAssessmentHandler();
	if(Trigger.isAfter && Trigger.isInsert) {
		handler.onAfterInsert(Trigger.new);
	} else if(Trigger.isBefore && Trigger.isInsert) {
		handler.onBeforeInsert(Trigger.new);
	} else if(Trigger.isBefore && Trigger.isUpdate) {
		handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
	}
}