/******************************************************************************************************
Class Name         : ScheduleBatchRetryMechanism_Test
Description        : This class contains unit tests for validating the behavior of Apex class: ScheduleBatchRetryMechanism
Created By         : Sfurti Pandey
Created On         : 03-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
private class ScheduleBatchRetryMechanism_Test {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
  static testMethod void positiveTest() {
       Test.startTest();
       // Schedule the test job
       String jobId = System.schedule('ScheduleApexClassTestbatchretry',
                        CRON_EXP, 
                        new ScheduleBatchRetryMechanism());
       System.assert(jobId != NULL);
       Test.StopTest() ;                   
   }
}