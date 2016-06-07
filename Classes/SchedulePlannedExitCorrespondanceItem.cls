/******************************************************************************************************
Class Name         : SchedulePlannedExitCorrespondanceItem
Description        : A scheduler for PlannedExitCorrespondanceItem Batch
Created By         : Rahul Agarwal 
Created On         : 10/14/2015
******************************************************************************************************/
global class SchedulePlannedExitCorrespondanceItem implements Schedulable{
    /**
    * Method name  : execute
    * Description  : This method executes the call for batch operation
    * Return Type  : void
    * Parameter    : SchedulableContext
    **/
    global void execute(SchedulableContext SC){
        BatchPlannedExitCorrespondanceItem lwb = new BatchPlannedExitCorrespondanceItem();
        database.executebatch(lwb);
    }
}