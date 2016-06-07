/******************************************************************************************************
Class Name         : BatchBeneficiaryCount
Description        : This class is used for evaluating No_Of_CSP_Beneficiaries__c, No_Of_CDSP_Beneficiaries__c 
                     and Home_Based_Sponsorship_Beneficiaries__c fields on ICP.
Created By         : Rahul Agarwal
Created On         : 20-May-2015 
******************************************************************************************************/
global class BatchBeneficiaryCount implements Database.batchable<SObject> {

    /**
     * Method name  : start
     * Description  : This method queries all ICPs
     * Return Type  : Database.Querylocator
     * Parameter    : Database.BatchableContext
     **/
    public Database.Querylocator start(Database.BatchableContext oBC) {
        Id icpId = [Select Id from RecordType where SObjectType =
            'Account'
            AND DeveloperName = 'ICP'
        ].Id;
        String sQuery =
            'Select Id, No_Of_CSP_Beneficiaries__c, No_Of_CDSP_Beneficiaries__c, Home_Based_Sponsorship_Beneficiaries__c from Account where RecordTypeId =: icpId';
        return Database.getQueryLocator(sQuery);
    }

    /**
     * Method name  : execute
     * Description  : This method updates Number of Beneficiaries for ICP queried in start method
     * Return Type  : void
     * Parameter    : Database.BatchableContext
     **/
    public void execute(Database.BatchableContext oBC, List<sObject>
        lstScope) {
        list<Account> lstAllICPs = new list<Account>();
        lstAllICPs = (list<Account> ) lstScope;

        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(
            Account.SObjectType, Constants.CSP_BENEFICIARY_RT_API_NAME);

        list<Account> lstCSPBeneficiaries = new list<Account>();
        lstCSPBeneficiaries = [select id, ICP__c from Account where Beneficiary_Status__c =
            'Active'
            AND RecordTypeId = : cspRecTypeId AND ICP__c IN:
            lstAllICPs
        ];

        map<Id, Account> mapCSPICPupdate = new map<Id, Account>();
        for(Account oAcc: lstAllICPs){
            Account oICP = new Account(No_Of_CSP_Beneficiaries__c=0,Id=oAcc.Id);
            mapCSPICPupdate.put(oAcc.Id, oICP);
        }
        for (Account oAcc: lstCSPBeneficiaries) {
            if (mapCSPICPupdate.containsKey(oAcc.ICP__c)) {
                mapCSPICPupdate.get(oAcc.ICP__c).No_Of_CSP_Beneficiaries__c =
                    mapCSPICPupdate.get(oAcc.ICP__c).No_Of_CSP_Beneficiaries__c +1;
            }
        }
        if(mapCSPICPupdate.size() > 0)
            update mapCSPICPupdate.values();

        list<Account> lstCDSPCenterBeneficiaries = new list<Account>();
        lstCDSPCenterBeneficiaries = [select id, ICP__c from Account where Beneficiary_Status__c =
            'Active'
            AND RecordTypeId = : cdspRecTypeId AND ICP__c IN:
            lstAllICPs AND Program_Stage__c = 'Center Based Sponsorship'];

        map<Id, Account> mapCDSPCenterICPupdate = new map<Id, Account>
           ();
        for(Account oAcc: lstAllICPs){
             Account oICP = new Account(No_Of_CDSP_Beneficiaries__c=0,Id=oAcc.Id);
             mapCDSPCenterICPupdate.put(oAcc.Id, oICP);
        }

        for (Account oAcc: lstCDSPCenterBeneficiaries) {
            if (mapCDSPCenterICPupdate.containsKey(oAcc.ICP__c)) {
                mapCDSPCenterICPupdate.get(oAcc.ICP__c).No_Of_CDSP_Beneficiaries__c =
                    mapCDSPCenterICPupdate.get(oAcc.ICP__c).No_Of_CDSP_Beneficiaries__c +1;
            }
        }
        if(mapCDSPCenterICPupdate.size() > 0)
            update mapCDSPCenterICPupdate.values();
        
        list<Account> mapCDSPHomeBeneficiaries = new list<Account>();
        mapCDSPHomeBeneficiaries = [select id, ICP__c from Account where Beneficiary_Status__c =
            'Active'
            AND RecordTypeId = : cdspRecTypeId AND ICP__c IN:
            lstAllICPs AND Program_Stage__c = 'Home Based Sponsorship'];

        map<Id, Account> mapCDSPHomeICPupdate = new map<Id, Account>();
        for(Account oAcc: lstAllICPs){
             Account oICP = new Account(Home_Based_Sponsorship_Beneficiaries__c=0,Id=oAcc.Id);
             mapCDSPHomeICPupdate.put(oAcc.Id, oICP);
        }

        for (Account oAcc: mapCDSPHomeBeneficiaries) {
            if (mapCDSPHomeICPupdate.containsKey(oAcc.ICP__c)) {
                mapCDSPHomeICPupdate.get(oAcc.ICP__c).Home_Based_Sponsorship_Beneficiaries__c =
                    mapCDSPHomeICPupdate.get(oAcc.ICP__c).Home_Based_Sponsorship_Beneficiaries__c +1;
            }
        }
        if(mapCDSPHomeICPupdate.size() > 0)
            update mapCDSPHomeICPupdate.values();

    }

    /**
     * Method name  : finish
     * Description  : This method performs tasks that needs to be done afterjob is finished.
     * Return Type  : void
     * Parameter    : Database.BatchableContext
     **/
    public void finish(Database.BatchableContext BC) {}

}