/******************************************************************************************************
Class Name         : RankingAdministrationTrigger
Deascription       : This is single trigger for Ranking_Administration__c which will cover all the trigger events.
                     All the functionality on Ranking_Administration__c should be called from this trigger. Methods 
                     to cover all Ranking_Administration__c functionality will be defined in class named
                     RankingAdministrationHandler.
Created By         : Himanshu Raichandani
Created On         : 12-Dec-2014 
******************************************************************************************************/
trigger RankingAdministrationTrigger on Ranking_Administration__c(before insert,
	before update) {

	RankingAdministrationHandler handler = new RankingAdministrationHandler();

	if(trigger.isInsert && trigger.isBefore) {
		handler.onBeforeInsert(Trigger.new);
	} else if(trigger.isUpdate && trigger.isBefore) {
		handler.onBeforeUpdate(Trigger.new);
	}
}