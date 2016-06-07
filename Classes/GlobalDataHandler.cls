/******************************************************************************************************
Class Name         : GlobalDataHandler
Description        : This is single Class for GLobal Data which will cover all it's trigger functionality.
					 These methods will be called from GlobalDataTrigger based on required trigger events.
Created By         : Sowmya Chamakura
Created On         : 10-Dec-2014 
******************************************************************************************************/
public class GlobalDataHandler {
	/**
	 * Method name  : addGlobalIndicators
	 * Description  : This method adds global indicators for all field offices for every oIndicator added in GLobal Data for CDPR record type
	 * Return Type  : void
	 * Parameter    : List<Global_Data__c> 
	 **/
	public static void addGlobalIndicators(List<Global_Data__c> lstIndicator) {
		List<FO_Administration__c> lstFOAdmin = new List<FO_Administration__c>
			();
		FO_Administration__c oFOAdmin;
		Id fieldOfficeRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
			Constants.FIELD_OFFICE_RT_API_NAME);
		List<Account> lstFO = null;
		lstFO = [Select Id, Name from Account where RecordtypeId = :
			fieldOfficeRecordTypeId
		];
		Schema.DescribeFieldResult oAgeGroup = Account.Cognitive_Age_Group__c.getDescribe();
		List<Schema.PicklistEntry> lstAgeGroupValues = oAgeGroup.getPicklistValues();
		Id foAdminRecordTypeId = Utility.getRecordTypeIdByDeveloperName(
			FO_Administration__c.SObjectType, Constants.CDPR_FO_ADMIN_RT_API_NAME);
		Id CDPRRecordTypeId = Utility.getRecordTypeIdByDeveloperName(Global_Data__c.SObjectType,
			Constants.CDPR_INDICATORS_GLOBAL_DATA_RT_API_NAME);

		for(Global_Data__c oIndicator: lstIndicator) {

			if(oIndicator.RecordtypeId == CDPRRecordTypeId) {
				for(Account oAccnt: lstFO) {
					for(Schema.PicklistEntry oAge: lstAgeGroupValues) {
						for(Integer i = 1; i<4; i++) {
							oFOAdmin = new FO_Administration__c();
							oFOAdmin.Field_Office__c = oAccnt.Id;
							oFOAdmin.Age_Group__c = oAge.getLabel();
							oFOAdmin.Global_Data__c = oIndicator.Id;
							oFOAdmin.Progress_Measure__c = Constants.MEASURE + i;
							oFOAdmin.RecordtypeId = foAdminRecordTypeId;

							lstFOAdmin.add(oFOAdmin);
						}
					}
				}
			}
		}
		List<Database.SaveResult> lstUpdateResults = Database.insert(lstFOAdmin,
			false);
		ErrorLogUtility.logDMLError(lstUpdateResults, lstFOAdmin, 'Global_Data__c',
			'GlobalDataHandler', 'addGlobalIndicators', 'SFDC CI', false);
	}
}