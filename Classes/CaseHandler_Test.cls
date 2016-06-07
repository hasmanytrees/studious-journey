/******************************************************************************************************
Class Name         : CaseHandler_Test
Description        : This class contains unit tests for validating the behavior of Apex class: CaseHandler
                     and CaseTrigger
Created By         : Rahul Agarwal
Created On         : 04-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@isTest
Private Class CaseHandler_Test{
    static TestMethod void cases(){
        list<RecordType> recordtypes = new list<RecordType>();
        recordtypes = [select Id, DeveloperName, SObjectType from RecordType where SObjectType = 'Account' OR SObjectType = 'PM_Hierarchy__c'];
        Id cdspRecTypeId;
        system.debug('****recordtypes'+recordtypes);
        Id supporterId;
        Id fieldOfficeId;
        Id TerritoryId;
        Id ClusterId;
        Id ICPId;
        Id GlobalPartnerId;
        test.startTest();
        for(RecordType r: recordtypes){
            if(r.SObjectType == 'Account'){
                if(r.Developername == 'Field_Office')
                    fieldOfficeId = r.id;
                else if(r.Developername == 'Supporter_Person')
                    supporterId = r.id;
                else if(r.Developername == 'CDSP_Beneficiary')
                    cdspRecTypeId = r.id;
                else if(r.Developername == 'ICP')
                    ICPId = r.id;
                else if(r.developername == 'Global_Partner')
                    GlobalPartnerId = r.id;
            }
            else if(r.SObjectType == 'PM_Hierarchy__c'){
                if(r.Developername == 'Territory')
                    TerritoryId = r.id;
                if(r.Developername == 'Cluster')
                    ClusterId = r.id;
            }
        }
        
        Account FieldOffice = new Account(Name = 'Ethiopia', RecordTypeId = fieldOfficeId);
        insert FieldOffice;
        PM_Hierarchy__c Territory = new PM_Hierarchy__c(Name = 'Territory', Field_Office__c = FieldOffice.Id, RecordTypeId = TerritoryId);
        insert Territory;
        PM_Hierarchy__c Cluster = new PM_Hierarchy__c(Name = 'Cluster', Territory__c = Territory.Id, RecordTypeId = ClusterId);
        insert Cluster;
        Account ICP = new Account(Name = 'ICP', Cluster__c = Cluster.id, RecordTypeId = ICPId, BillingCountry = 'India', BillingStreet = 'Street', BillingCity = 'Delhi',
                      Field_Office_For_Denominations__c = 'Ethiopia',Denomination_Church__c = 'Independent');
        insert ICP;
        Account GlobalPartner = new Account(Name = 'GP', RecordTypeId = GlobalPartnerId);
        insert GlobalPartner;
        list<Account> newAccounts = new list<Account>();
        Account Beneficiary = new Account(FirstName = 'Test', LastName = 'Name', RecordTypeId = cdspRecTypeId, ICP__c = ICP.Id,Review_Status__c='Approved',Local_Beneficiary_Number__c='3201');
        Account Supporter = new Account(FirstName = 'Test', LastName = 'Name', RecordTypeId = supporterId, Global_Partner__c = GlobalPartner.Id);
        
        newAccounts.add(Beneficiary);
        newAccounts.add(Supporter);
        insert newAccounts;
        system.debug('****Beneficiary'+Beneficiary);
        //insert Beneficiary;
        list<Case> newCases = new list<Case>();
        for(Integer i = 0; i < 20; i++){
            Case c = new Case( Supporter__c = Supporter.Id,ICP__c=ICP.id);
            newCases.add(c);
        }
        insert newCases;
        for(Case c: newCases){
            c.Subject = 'test case';
        }
        update newCases;
        
        List<Case> lstUpdatedCase = [ Select Global_Partner__c from Case where ID IN: newCases] ; 
        system.Assert( lstUpdatedCase[0].Global_Partner__c == GlobalPartner.Id ) ; 
        system.Assert( lstUpdatedCase[1].Global_Partner__c == GlobalPartner.Id ) ; 
        
        test.stopTest();
    }
}