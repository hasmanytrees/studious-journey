/******************************************************************************************************
Class Name         :SchedulePlannedExitCorrespondanceItem_Test
Description        : This class contains unit tests for validating the behavior of Apex class: SchedulePlannedExitCorrespondanceItem
Created By         : Sfurti Pandey
Created On         : 18-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
private class SchedulePlannedExitCorresItem_Test {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
  static testMethod void positiveTest() {
       Test.startTest();
       // Schedule the test job
       String jobId = System.schedule('SchedulePlannedExitCorrespondanceItem',
                        CRON_EXP, 
                        new SchedulePlannedExitCorrespondanceItem());
       System.assert(jobId != NULL);
       Test.StopTest() ;                   
   }
}