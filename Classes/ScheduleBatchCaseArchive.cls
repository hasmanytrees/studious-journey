/******************************************************************************************************
Class Name         : ScheduleBatchCaseArchive
Description        : This schedular class is used for run the Batch_CaseArchive class on regular intervals
                     specified in the corresponding Scheduler job
Created By         : Rahul Agarwal
Created On         : 04-Dec-2014 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

global class ScheduleBatchCaseArchive implements Schedulable {
	global void execute(SchedulableContext sc) {
		BatchCaseArchive oBatch = new BatchCaseArchive();
		database.executeBatch(oBatch);
		system.abortJob(sc.getTriggerId());
	}
}