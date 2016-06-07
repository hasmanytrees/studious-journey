/******************************************************************************************************
Class Name         : BeneficiaryImpactTrigger
Description        : This is single trigger for Beneficiary_Impact__c which will cover all the trigger events.
                     All the functionality on Beneficiary_Impact__c should be called from this trigger. Methods 
                     to cover all Beneficiary Impact functionality will be defined in class named BeneficiaryImpactHandler.
Created By         : Sudipta Nayak
Created On         : 24-Jul-2015
******************************************************************************************************/
trigger BeneficiaryImpactTrigger on Beneficiary_Impact__c (before insert) {
	BeneficiaryImpactHandler oHandler = new BeneficiaryImpactHandler();
    if(Trigger.isBefore && Trigger.isInsert) {
        oHandler.onBeforeInsert(Trigger.new);
    }
}