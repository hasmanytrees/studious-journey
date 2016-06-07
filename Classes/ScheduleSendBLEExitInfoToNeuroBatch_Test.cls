/******************************************************************************************************
Class Name         : ScheduleSendBLEExitInfoToNeuroBatch_Test
Description        : This class contains unit tests for validating the behavior of Apex class: ScheduleSendBLEExitInfoToNeuroBatch
Created By         : Himanshu R
Created On         : 08-June-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class ScheduleSendBLEExitInfoToNeuroBatch_Test {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
	static testMethod void positiveTest() {
       Test.startTest();
       // Schedule the test job
       String jobId = System.schedule('ScheduleApexClassTestForNeuron',
                        CRON_EXP,
                        new ScheduleSendBLEExitInfoToNeuronBatch());
       System.assert(jobId != NULL);
       Test.StopTest();                 
   }
}