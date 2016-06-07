/******************************************************************************************************
Class Name         : ContentTrigger
Deascription       : This is single trigger for Yearly Class Schedule which will cover all the trigger events.
                     All the functionality on Yearly Class Schedule should be called from this trigger. Methods 
                     to cover all Yearly Class Schedule functionality will be defined in YearlyClassScheduleHandler class.
Created By         : Danish Ahmed
Created On         : 08-Sep-2015 
******************************************************************************************************/
trigger YearlyClassScheduleTrigger on Yearly_Class_Schedule__c (after insert, after update) {
    
    YearlyClassScheduleHandler oYearlyClassHandler = new YearlyClassScheduleHandler();
    if(Trigger.isInsert && Trigger.isAfter) {
        oYearlyClassHandler.onAfterInsert(Trigger.new, Trigger.oldMap);
    }else If(Trigger.isUpdate && Trigger.isAfter){
        oYearlyClassHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}