/******************************************************************************************************
Class Name         : DisasterHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: DisasterHandler
                     and DisasterTrigger
Created By         : Sudipta Nayak
Created On         : 10-Sep-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false) 
private class DisasterHandler_Test {
    static testMethod void disasterTest()  {
        User UserPF = TestDataUtility.UserTestData('Partnership Facilitator','PF', 'Ethiopia Partnership Facilitator');
        insert UserPF;
        User UserCD = TestDataUtility.UserTestData('TCPT Read Only','CD', 'Ethiopia Country Director');
        insert UserCD;
        System.runAs(UserPF) {
            list<PM_Hierarchy__c> lstPMHierarchyReg = TestDataUtility.RegionTestData();
            insert  lstPMHierarchyReg;
            list<Account> lstAccountFO = TestDataUtility.FOTestData(lstPMHierarchyReg, UserCD);
            insert lstAccountFO;
            list<Disaster__c> lstDisaster = TestDataUtility.disasterTestData(lstAccountFO[0]);
            Test.startTest();
            insert lstDisaster;
            Disaster__c oDisaster = [Select Id, Disaster_Severity_Level__c, Disaster_Communications_Contact__r.LastName from Disaster__c where Id =: lstDisaster[0].Id];
            System.assertEquals('Orange', oDisaster.Disaster_Severity_Level__c);
            System.assertEquals('TestingPartnership Facilitator', oDisaster.Disaster_Communications_Contact__r.LastName);
            lstDisaster[0].Estimated_Not_Attending_Project__c = '50-99';
            lstDisaster[1].Estimated_Damage_Over_1_Million_USD__c = 'Yes';
            update lstDisaster;
            lstDisaster[0].Estimated_Basic_Supplies_Needed__c = '250+';
            lstDisaster[1].Estimated_Damage_Over_1_Million_USD__c = 'No';
            lstDisaster[1].Estimated_Loss_Of_Life__c = '0';
            lstDisaster[1].Estimated_Serious_Injuries__c = '0';
            lstDisaster[1].Estimated_Homes_Destroyed__c = '0';
            update lstDisaster;
            Test.stopTest();
        }        
    }

}