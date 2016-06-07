/******************************************************************************************************
Class Name         : CommunicationDeletion_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     CommunicationDeletion
Created By         : Sudipta Nayak
Created On         : 05-Nov-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false)
private class CommunicationDeletion_Test {
    static testMethod void verifyCommunicationDeletion()  {
        Test.StartTest();
        list<Id> AccountId = new List<Id>();
        list<Account> lstAccountICP =  new List<Account>();
        list<Account> lstAccountICPUpdate = new list<Account>();
        FeedItem oFeedItem = new FeedItem(); 
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        System.assertNotEquals(null,UserPF);
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.assertNotEquals(null,UserCD);
        Test.StopTest();
        System.runAs(UserPF) {
            List<sObject> lstESBURLData = Test.loadData(ESB_URL__c.sObjectType, 'ESBURLData');
            
        }
    }
}