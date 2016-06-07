/******************************************************************************************************
Class Name         : CaseHandler
Description       :  This is single Class for Case which will cover all it's trigger functionality.
                     These methods will be called from Case_Trigger based on required trigger events.
Created By         : Rahul Agarwal 
Created On         : 16-Dec-2014 
 ******************************************************************************************************/

public class CaseHandler {

    /**********************************
    Method Name : shareCaseToCreator
    Description : This method shares Case to its Creator such that Creator of Case can always edit Case which he/she created.
    Return type : void
    Parameter   : List<Case> listNewCaseResults
    ************************************/
    public static void shareCaseToCreator(List<Case> lstNewCaseResults) {
        List<CaseShare> lstCaseShare = new List<CaseShare>();
        for(Case oConcernedCase: lstNewCaseResults) {
            CaseShare oCaseShare = new CaseShare();
            oCaseShare.CaseId = oConcernedCase.Id;
            oCaseShare.CaseAccessLevel = Constants.EDIT_ACCESS_LEVEL;
            oCaseShare.UserOrGroupId = oConcernedCase.CreatedById;
            lstCaseShare.add(oCaseShare);
        }
        if(!lstCaseShare.isEmpty()) {
            List<Database.SaveResult> lstSaveResult = Database.insert(lstCaseShare,
                false);
            for(Database.SaveResult sr: lstSaveResult) {
                if(!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    /*Check if the error is related to trival access level.
                      Access levels equal or more permissive than the object's default access level are not allowed. 
                      These sharing records are not required and thus an insert exception is acceptable.*/
                    if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&
                        err.getMessage()
                        .contains(Constants.ACCESS_LEVEL)) {
                        /*Indicates success.*/
                    } else {
                        ErrorLogUtility.logDMLError(lstSaveResult, lstCaseShare,
                            'CaseShare', 'CaseHandler', 'shareCaseToCreator', 'SFDC CI', false);
                    }
                }
            }
        }
    }

	/******************************************************************************************************
	Method Name : updateCase
	Description : This method populates Case's Global Partner & Field Office values for queried ICPs & Supporters
	Return type : void
	Parameter   : List<Case> 
	********************************************************************************************************/
	public static void updateCase(List<Case> lstNewResults) {
		Set<Id> setICPIds = new Set<Id>();
		Set<Id> setSupporterIds = new Set<Id>();
		Map<Id, Account> mapIdToICP = new Map<Id, Account>();
		Map<Id, Account> mapIdToSupporter = new Map<Id, Account>();
		for(Case oConcernedCase: lstNewResults) {
			if(oConcernedCase.ICP__c <> null)
				setICPIds.add(oConcernedCase.ICP__c);
			if(oConcernedCase.Supporter__c <> null)
				setSupporterIds.add(oConcernedCase.Supporter__c);
		}
		try {
			mapIdToICP = new Map<Id, Account> ([Select Id,
				Cluster__r.Territory__r.Field_Office__r.Id from Account where Id IN:
				setICPIds
			]);

			mapIdToSupporter = new Map<Id, Account> ([Select Id, Global_Partner__c from Account where Id IN:
				setSupporterIds
			]);
		} catch(QueryException oQEx) {
			ErrorLogUtility.logGeneralError(oQEx, 'CaseHandler', 'updateCase',
				'SFDC CI');
			return;
		}

		for(Case oConcernedCase: lstNewResults) {

			if(mapIdToICP.containskey(oConcernedCase.ICP__c) &&
				mapIdToICP.get(oConcernedCase.ICP__c)
				.Cluster__r.Territory__r.Field_Office__r.Id <> null)
				oConcernedCase.Field_Office__c = mapIdToICP.get(oConcernedCase.ICP__c)
				.Cluster__r.Territory__r.Field_Office__r.Id;

			if(mapIdToSupporter.containskey(oConcernedCase.Supporter__c) &&
				mapIdToSupporter.get(oConcernedCase.Supporter__c)
				.Global_Partner__c <> null)
				oConcernedCase.Global_Partner__c = mapIdToSupporter.get(oConcernedCase.Supporter__c)
				.Global_Partner__c;
		}
	}
}