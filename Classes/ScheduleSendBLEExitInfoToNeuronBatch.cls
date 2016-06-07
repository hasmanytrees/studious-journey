/******************************************************************************************************
Class Name         : ScheduleSendBLEExitInfoToNeuronBatch
Description        : This schedular class is used for run the SendBLEExitInfoToNeuronBatch class
Created By         : Himanshu Raichandani
Created On         : 08-Jun-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class ScheduleSendBLEExitInfoToNeuronBatch implements Schedulable {
	public void execute(SchedulableContext sc) {
		SendBLEExitInfoToNeuronBatch oBatch = new SendBLEExitInfoToNeuronBatch();
		database.executeBatch(oBatch,1);
	}
}