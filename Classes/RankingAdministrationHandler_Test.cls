/******************************************************************************************************
Class Name         : RankingAdministrationHandler_Test
Deascription       : This class contains unit tests for validating the behavior of Apex class: RankingAdministrationHandler
                     and RankingAdministrationTrigger
Created By         : Shaik Manzoor
Created On         : 05-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest(SeeAllData=false)
Private Class RankingAdministrationHandler_Test {
    static TestMethod void RankingAdministrationHandlerTestMethod() {
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(new User(Id = UserInfo.getUserId())) {
          Test.startTest();
          list<PM_Hierarchy__c> lstReg = TestDataUtility.RegionTestData();
          insert lstReg;
          list<Account> lstFO = TestDataUtility.FOTestData(lstReg, UserCD);
          insert lstFO;
          list<Ranking_Administration__c> lstRA = TestDataUtility.RankingAdministrationTestData(lstFO);
          insert lstRA;
          list<Ranking_Administration__c> lstRA1 = new list<Ranking_Administration__c>();
          for(Ranking_Administration__c RA : [Select id,Location__c from Ranking_Administration__c where id in:lstRA]) {
            RA.Location__c = 20;
            lstRA1.add(RA);
          }
          update lstRA1;
          try {
          list<Ranking_Administration__c> lstRA2 = TestDataUtility.RankingAdministrationTestData(lstFO);
          insert lstRA2;
          }
          catch (Exception e){
            System.assert(e.getMessage().contains(System.label.Error_For_Duplicate_FO_For_Ranking_Admin_Object), 'message=' + e.getMessage());
          }
          Test.stopTest();
        }
    }
}