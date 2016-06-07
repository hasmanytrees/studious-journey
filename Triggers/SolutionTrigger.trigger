/******************************************************************************************************
Class Name         : SolutionTrigger
Deascription       : This is single trigger for Solution which will cover all the trigger events.
                     All the functionality on Solution should be called from this trigger. Methods 
                     to cover all account functionality will be defined in SolutionHandler class named
                     SolutionHandler.
Created By         : Sfurti Pandey 
Created On         : 01-Oct-2015 
******************************************************************************************************/

trigger SolutionTrigger on Solution (before delete) {
    SolutionHandler oSolutionHandler= new SolutionHandler();
    if(Trigger.isDelete && Trigger.isBefore) {
        oSolutionHandler.onBeforedelete(Trigger.old);
    } 

}