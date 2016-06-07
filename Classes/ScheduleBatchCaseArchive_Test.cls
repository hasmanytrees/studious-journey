/******************************************************************************************************
Class Name         : ScheduleBatchCaseArchive_Test
Description        : This class contains unit tests for validating the behavior of Apex class: ScheduleBatchCaseArchive
Created By         : Jeevan D
Created On         : 16-Feb-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class ScheduleBatchCaseArchive_Test {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
	static testMethod void positiveTest() {
       Test.startTest();
       // Schedule the test job
       String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new ScheduleBatchCaseArchive());
       System.assert(jobId != NULL);
       Test.StopTest() ;                   
   }
}