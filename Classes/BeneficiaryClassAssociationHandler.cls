/******************************************************************************************************
Class Name         : BeneficiaryClassAssociationHandler
Description        : This is single Class for Beneficiary_Class_Association__c which will cover all it's
					 trigger functionality. These methods will be called from BeneficiaryClassAssociationTrigger
					 based on required trigger events.
Created By         : Sudipta Nayak
Created On         : 03-Sep-2015 
 ******************************************************************************************************/

public class BeneficiaryClassAssociationHandler {

    /**
     * Method name  : onAfterInsert
     * Description  : This method will be called after any Beneficiary Class Association record is inserted
     * Return Type  : void
     * Parameter    : List<Beneficiary_Class_Association__c>
     **/
    public void onAfterInsert(List<Beneficiary_Class_Association__c > lstNewRecords) {
        updateNumberOfClassesForBeneficiary(lstNewRecords);
    }
    
    /**
     * Method name  : onAfterDelete
     * Description  : This method will be called after any Beneficiary Class Association record is deleted
     * Return Type  : void
     * Parameter    : List<Beneficiary_Class_Association__c>
     **/
    public void onAfterDelete(List<Beneficiary_Class_Association__c > lstOldRecords) {
        updateNumberOfClassesForBeneficiary(lstOldRecords);
    }
    
    /**
     * Method name  : updateNumberOfClassesForBeneficiary
     * Description  : This method will calculate the number of Classes a Beneficiary is associated to.
     * Return Type  : void
     * Parameter    : List<Beneficiary_Class_Association__c>
     **/
    private void updateNumberOfClassesForBeneficiary(List<Beneficiary_Class_Association__c > lstNewRecords) {
        Set<Id> setBeneficiaryIds = new Set<Id>();
        Map<Id, Set<String>> mapBeneficiaryToClass = new Map<Id, Set<String>>();
        List<Account> lstBeneficiaries = new List<Account>();
        List<Beneficiary_Class_Association__c > lstBeneficiaryAssociations = new List<Beneficiary_Class_Association__c >();
        for(Beneficiary_Class_Association__c oClassAssociation : lstNewRecords) {
            setBeneficiaryIds.add(oClassAssociation.BEN_Id__c);
        }
        System.debug('setBeneficiaryIds:'+setBeneficiaryIds);
        if(!setBeneficiaryIds.isEmpty()) {
        	lstBeneficiaryAssociations = [SELECT Id, BEN_Id__c, Class_ID__c from Beneficiary_Class_Association__c where BEN_Id__c in: setBeneficiaryIds];
        }
        for(Beneficiary_Class_Association__c oClassAssociation : lstBeneficiaryAssociations) {
            if(!mapBeneficiaryToClass.containsKey(oClassAssociation.BEN_Id__c)) {
                Set<String> setClassIds = new Set<String>();
                setClassIds.add(oClassAssociation.Class_ID__c);
                mapBeneficiaryToClass.put(oClassAssociation.BEN_Id__c, setClassIds);
            }
            else {
                Set<String> setClassIds = new Set<String>();
                setClassIds = mapBeneficiaryToClass.get(oClassAssociation.BEN_Id__c);
                setClassIds.add(oClassAssociation.Class_ID__c);
                mapBeneficiaryToClass.put(oClassAssociation.BEN_Id__c, setClassIds);
            }
            System.debug('mapBeneficiaryToClass:' + mapBeneficiaryToClass);
        }
        if(!setBeneficiaryIds.isEmpty()) {
            lstBeneficiaries = [SELECT id, No_Of_Associated_Classes__c from Account where
                               id in: setBeneficiaryIds];
            for(Account oAccount : lstBeneficiaries) {
                if(mapBeneficiaryToClass.containsKey(oAccount.Id)) {
                    oAccount.No_Of_Associated_Classes__c = mapBeneficiaryToClass.get(oAccount.Id).size();
                    System.debug('No of Associated Classes:' + mapBeneficiaryToClass.get(oAccount.Id).size());
                }
                else
                    oAccount.No_Of_Associated_Classes__c = 0;
            }
        }
        if(!lstBeneficiaries.isEmpty()) {
			List < Database.SaveResult > lstInsertResults =
				Database.update(lstBeneficiaries, false);
			Map < Id, List < String >> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
				lstInsertResults, lstBeneficiaries, 'Account',
				'BeneficiaryClassAssociationHandler', 'updateNumberOfClassesForBeneficiary',
                'SFDC CI', false);
        }
    }
}