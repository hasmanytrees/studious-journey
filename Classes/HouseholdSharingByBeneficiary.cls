global class HouseholdSharingByBeneficiary implements Database.batchable < SObject > {
    public Database.Querylocator start(Database.BatchableContext bc) {
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
        Set<Id> setRecTypeIds = new Set<Id>{cdspRecTypeId,cspRecTypeId};
        String sQuery = 'Select Id, Household__c, FO__c from Account where Recordtypeid IN: setRecTypeIds';
        return Database.getQueryLocator(sQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        list<Account> lstAllAccounts = (list<Account>)scope;
        set<Id> HouseholdIds = new set<Id>();
        for(Account a: lstAllAccounts){
        	if(a.Household__c != null && a.FO__c != null){
	            HouseholdIds.add(a.Household__c);
        	}
        }
        map<Id, Household__c> mapHousehold = new map<Id, Household__c>([select Id, Field_Office_For_Sharing_Rule__c from Household__c where Id IN: HouseholdIds]);
        
        for(Account a: lstAllAccounts){
        	if(a.Household__c != null && a.FO__c != null){
	            if(mapHousehold.get(a.Household__c).Field_Office_For_Sharing_Rule__c == null){
	                mapHousehold.get(a.Household__c).Field_Office_For_Sharing_Rule__c = a.FO__c;
	            }
	            else if(mapHousehold.get(a.Household__c).Field_Office_For_Sharing_Rule__c <> null && !mapHousehold.get(a.Household__c).Field_Office_For_Sharing_Rule__c.contains(a.FO__c)){
	                String sSharingRule = mapHousehold.get(a.Household__c).Field_Office_For_Sharing_Rule__c + ';' + a.FO__c;
	                List<String> lstString = sSharingRule.split(';');
	                lstString.sort();
	                mapHousehold.get(a.Household__c).Field_Office_For_Sharing_Rule__c = String.join(lstString,';');
	            }
        	}
        }
        
        update mapHousehold.values();
    }

    
    public void finish(Database.BatchableContext BC) {

    }
}