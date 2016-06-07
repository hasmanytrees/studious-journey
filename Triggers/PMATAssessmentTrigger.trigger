/******************************************************************************************************
Class Name         : PMATAssessmentTrigger
Deascription       : This is single trigger for PMAT Assessment which will cover all the trigger events.
                     All the functionality on PMAT Assessment should be called from this trigger. Methods 
                     to cover all account functionality will be defined in PMAT Assessment Handler class
                     named PMATAssessmentHandler.
Created By         : Sudipta Nayak
Created On         : 14-Jul-2015
******************************************************************************************************/

trigger PMATAssessmentTrigger on PMAT_Assessment__c (after insert, after update) {
    
    PMATAssessmentHandler pmatAssessmentHandler = new PMATAssessmentHandler();
    if(trigger.isUpdate && trigger.isAfter) {
        pmatAssessmentHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    else if(trigger.isInsert && trigger.isAfter) {
        pmatAssessmentHandler.onAfterInsert(Trigger.new);
    }
}