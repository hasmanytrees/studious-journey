/******************************************************************************************************
Class Name         : GlobalDataHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: GlobalDataHandler
                     and GlobalDataTrigger
Created By         : Jeevan D
Created On         : 16-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
private class GlobalDataHandler_Test 
{
    static testMethod void positiveTest() 
    {
        ID oUSerRecId = UserInfo.getUSerID () ; 
        User oUSerRec = new USer ( ID = oUSerRecId  ) ;  
        list<PM_Hierarchy__c> lstRegions = TestDataUtility.RegionTestData();
        insert lstRegions;
        list<Account> lstFeildOffice = TestDataUtility.FOTestData(lstRegions ,  oUSerRec) ;
        insert lstFeildOffice;
        
       Test.StartTest() ; 
           Global_Data__c oTestGlobalCDPR =  TestdataUtility.globalDataCDPR ( 'testGDDPR' , 'TEst outcome are ' , 'Physical' , 'test ') ;
           insert oTestGlobalCDPR ;
           System.Assert( oTestGlobalCDPR.ID != NULL ) ; 
       Test.StopTest() ; 
    }
}