/******************************************************************************************************
Class Name         : CommunicationUpdatesHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     CommunicationUpdatesHandler and CommunicationUpdatesTrigger
Created By         : Sudipta Nayak
Created On         : 15-Sep-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class CommunicationUpdatesHandler_Test {
    static testMethod void communicationUpdatesTest()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        User UserLM = TestDataUtility.UserTestData('Leadership Management','LM', 'GMC');
        insert UserLM;
        System.runAs(UserLM) {
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            Test.startTest();
            insert lstDisaster;
            Communication_Update__c oCommUpdateFirst = TestDataUtility.commUpdateTestData(lstDisaster[0]);
            insert oCommUpdateFirst;
            Communication_Update__c oCommUpdateSecond = TestDataUtility.commUpdateTestData(lstDisaster[0]);
            insert oCommUpdateSecond;
            System.assertNotEquals(null,oCommUpdateSecond);
            System.debug('oCommUpdateSecond Name'+oCommUpdateSecond.Communication_Updates_From__c);
            System.debug('oCommUpdateSecond Name'+oCommUpdateSecond.Communication_Updates_To__c);
            System.debug('oCommUpdateSecond Name'+oCommUpdateSecond.Communication_Update_Name__c);
            Test.stopTest();
        }
    }
}