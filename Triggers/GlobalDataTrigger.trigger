/******************************************************************************************************
Class Name         : GlobalDataTrigger
Deascription       : This is single trigger for Global Data which will cover all the trigger events.
                     All the functionality on Global Data should be called from this trigger. Methods 
                     to cover all global data functionality will be defined in class named GlobalDataHandler.
Created By         : Sowmya Chamakura
Created On         : 10-Dec-2014 
******************************************************************************************************/

trigger GlobalDataTrigger on Global_Data__c(after insert, after update) {
	if(Trigger.isAfter && Trigger.isInsert) {
		GlobalDataHandler.addGlobalIndicators(Trigger.new);
	}
}