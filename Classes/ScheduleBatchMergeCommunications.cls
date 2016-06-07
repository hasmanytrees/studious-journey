/******************************************************************************************************
Class Name         : ScheduleBatchMergeCommunications
Description        : This schedular class is used for run the BatchMergeCommunications class 
Created By         : Rahul Agarwal
Created On         : 12-Oct-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

global class ScheduleBatchMergeCommunications implements Schedulable {
	global void execute(SchedulableContext sc) {
		BatchMergeCommunications oBatch = new BatchMergeCommunications();
		database.executeBatch(oBatch);
	}
}