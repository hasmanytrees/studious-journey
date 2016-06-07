/******************************************************************************************************
Class Name         : SolutionHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: EventHandler
                     and SolutionTrigger
Created By         : Sfurti Pandey
Created On         : 05-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
public class SolutionHandler_Test{
    static testMethod void verifySolutionhandler() 
    
    {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            Test.StartTest(); 
            Solution oSolution=TestDataUtility.SolutionTestData( );
            insert oSolution;
            try{
                delete oSolution;
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.You_Do_Not_Have_Access_to_Delete_Solution) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            Test.StopTest(); 
        }
       
    }
    
}