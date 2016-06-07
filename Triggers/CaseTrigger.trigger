/******************************************************************************************************
Class Name         : CaseTrigger
Deascription       : This is single trigger for Case which will cover all the trigger events.
                     All the functionality on Case should be called from this trigger. Methods 
                     to cover all account functionality will be defined in Handler class named
                     CaseHandler.
Created By         : Rahul Agarwal 
Created On         : 26-Nov-2014 
******************************************************************************************************/

trigger CaseTrigger on Case(before insert, before update, after update) {

	if(trigger.isUpdate && trigger.isAfter) {
		CaseHandler.shareCaseToCreator(trigger.new);
	}

	if((trigger.isInsert || trigger.isUpdate) && trigger.isBefore) {
		CaseHandler.updateCase(trigger.new);
	}
}