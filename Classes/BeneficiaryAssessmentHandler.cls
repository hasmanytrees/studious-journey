/******************************************************************************************************
Class Name         : BeneficiaryAssessmentHandler
Description        : This is single Class for Beneficiary_Assessment__c which will cover all it's trigger functionality.
					 These methods will be called from BeneficiaryAssessmentTrigger based on required trigger events.
Created By         : Himanshu Raichandani 
Created On         : 15-Jan-2015
******************************************************************************************************/
public class BeneficiaryAssessmentHandler {

	/**********************************
	Method Name	: onAfterInsert
	Description	: This method is used to execute codes for After Insert operation on Beneficiary Assessment.
	Return type	: void
	Parameter	: List<Beneficiary_Assessment__c>
	************************************/
	public void onAfterInsert(List<Beneficiary_Assessment__c> lstNewRecords) {
		updateAccountDetails(lstNewRecords);
	}

	/*********************************
	Method Name	: onBeforeInsert
	Description	: This method is used to execute codes for Before Insert operation on Beneficiary Assessment.
	Return type	: void
	Parameter	: List<Beneficiary_Assessment__c>
	************************************/
	public void onBeforeInsert(List<Beneficiary_Assessment__c> lstNewRecords) {
		updateNextAssessDueDate(lstNewRecords, null);
	}

	/**********************************
	Method Name	: onBeforeInsert
	Description	: This method is used to execute codes for Before Update operation on Beneficiary Assessment.
	Return type	: void
	Parameter	: List<Beneficiary_Assessment__c>, Map<Id,Beneficiary_Assessment__c>
	************************************/
	public void onBeforeUpdate(List<Beneficiary_Assessment__c> lstNewRecords,
		Map<Id, Beneficiary_Assessment__c> mapOldRecords) {
		updateNextAssessDueDate(lstNewRecords, mapOldRecords);
	}

	/**********************************
    Method Name	: updateNextAssessDueDate
    Description	: This method is used to udpate Next Assessment Due date of Beneficiary Assessment. THis method queries frequency from Global Data object
	  			  and based upon queried data and current completion date it populates next assessment date
    Return type	: void
    Parameter	: List<Beneficiary_Assessment__c>, Map<Id, Beneficiary_Assessment__c>
    ************************************/
	private void updateNextAssessDueDate(List<Beneficiary_Assessment__c>
		lstNewRecords, Map<Id, Beneficiary_Assessment__c> mapOldRecords) {
		List<Id> lstBenefToQuery = new List<Id>();
		List<Beneficiary_Assessment__c> lstBenefAssessToUpdate = new List <
			Beneficiary_Assessment__c>();
		Id haRecTypeId = Utility.getRecordTypeIdByDeveloperName(
			Beneficiary_Assessment__c.SObjectType, Constants.BA_Health_Assessment_RT_API_NAME
		);
		Id dpRecTypeId = Utility.getRecordTypeIdByDeveloperName(
			Beneficiary_Assessment__c.SObjectType, Constants.BA_Development_Plan_RT_API_NAME
		);
		Id cdprRecTypeId = Utility.getRecordTypeIdByDeveloperName(
			Beneficiary_Assessment__c.SObjectType, Constants.BA_CDPR_RT_API_NAME);
		Id gmRecTypeId = Utility.getRecordTypeIdByDeveloperName(
			Beneficiary_Assessment__c.SObjectType, Constants.BA_Growth_Monitoring_RT_API_NAME
		);

		for(Beneficiary_Assessment__c oBenefAssess: lstNewRecords) {
			if(null != oBenefAssess.Assessment_Completion_Date__c && (null ==
					mapOldRecords || (mapOldRecords.get(oBenefAssess.Id)
						.Assessment_Completion_Date__c != oBenefAssess.Assessment_Completion_Date__c
					))) {
				lstBenefAssessToUpdate.add(oBenefAssess);
				if(haRecTypeId.equals(oBenefAssess.RecordTypeId) || gmRecTypeId.equals(
						oBenefAssess.RecordTypeId)) {
					lstBenefToQuery.add(oBenefAssess.Beneficiary__c);
				}
			}
		}

		if(!lstBenefAssessToUpdate.isEmpty()) {
			Map<Id, Account> mapIdToBenef = null;
			List<Global_Data__c> lstGlobalData = null;
			mapIdToBenef = new Map<Id, Account> ([Select Id,
				Age_In_Months__c, Active_Program__c from Account where id in :
				lstBenefToQuery
			]);
			lstGlobalData = [Select Name,
				Beneficiary_Assessment_Frequency__c from Global_Data__c where RecordTypeId = :
				Utility.getRecordTypeIdByDeveloperName(Global_Data__c.SObjectType,
					Constants.GLOBAL_DATA_GLOBAL_FREQUENCIES_RT_API_NAME)
			];
			String sCdprToken = Global_Constants__c.getValues(Constants.CDPR_FREQUENCY_NAME)
				.Value__c;
			String sDpToken = Global_Constants__c.getValues(Constants.DEVELOPMENT_PLAN_FREQUENCY_NAME)
				.Value__c;
			String sGmToken = Global_Constants__c.getValues(Constants.GROWTH_MONITORING_FREQUENCY_NAME)
				.Value__c;
			String sHaToken = Global_Constants__c.getValues(Constants.HEALTH_ASSESSMENT_FREQUENCY_NAME)
				.Value__c;
			String sHatToken = Global_Constants__c.getValues(Constants.HEALTH_ASSESSMENT_FREQUENCY_TWO_YEARS)
				.Value__c;
			Map<String, Decimal> mapGDTokenToFrequency = prepareFrequencyMap(
				lstGlobalData, sCdprToken, sDpToken, sGmToken, sHaToken, sHatToken);

			for(Beneficiary_Assessment__c oBenefAssess: lstBenefAssessToUpdate) {
				Decimal oFrequency = null;
				if(haRecTypeId.equals(oBenefAssess.RecordTypeId) && null != mapIdToBenef.get(
						oBenefAssess.Beneficiary__c)
					.Age_In_Months__c) {
					oFrequency = (mapIdToBenef.get(oBenefAssess.Beneficiary__c)
							.Age_In_Months__c<24) ? mapGDTokenToFrequency.get(sHatToken) :
						mapGDTokenToFrequency.get(sHaToken);
				} else if(dpRecTypeId.equals(oBenefAssess.RecordTypeId)) {
					oFrequency = mapGDTokenToFrequency.get(sDpToken);
				} else if(cdprRecTypeId.equals(oBenefAssess.RecordTypeId)) {
					oFrequency = mapGDTokenToFrequency.get(sCdprToken);
				} else if(gmRecTypeId.equals(oBenefAssess.RecordTypeId) && null !=
					mapIdToBenef.get(oBenefAssess.Beneficiary__c)
					.Active_Program__c) {
					oFrequency = (Constants.CSP_TOKEN.equals(mapIdToBenef.get(oBenefAssess.Beneficiary__c)
						.Active_Program__c)) ? mapGDTokenToFrequency.get(sGmToken) : null;
				}

				if(null <> oFrequency) {
					Decimal dMonths = Math.ceil(oFrequency * 12);
					oBenefAssess.Next_Assessment_Due_Date__c = oBenefAssess.Assessment_Completion_Date__c
						.addMonths(Integer.valueOf(dMonths));
				}
			}
		}
	}

	/**********************************
	Method Name	: prepareFrequencyMap
	Description	: This method is used to prepare map which contains type of assessment as key and corresponding frequency from Global data as value
	Return type	: Map<String,Decimal>
	Parameter	: List<Global_Data__c>, String, String, String, String, String
	************************************/
	private Map<String, Decimal> prepareFrequencyMap(List<Global_Data__c>
		lstGlobalData, String sCdprToken, String sDpToken, String sGmToken, String sHaToken,
		String sHatToken) {

		Map<String, Decimal> mapGDTokenToFrequency = new Map<String, Decimal>
			();
		for(Global_Data__c oGlobalData: lstGlobalData) {
			if(sCdprToken.equals(oGlobalData.name)) {
				mapGDTokenToFrequency.put(sCdprToken, oGlobalData.Beneficiary_Assessment_Frequency__c);
			} else if(sDpToken.equals(oGlobalData.name)) {
				mapGDTokenToFrequency.put(sDpToken, oGlobalData.Beneficiary_Assessment_Frequency__c);
			} else if(sGmToken.equals(oGlobalData.name)) {
				mapGDTokenToFrequency.put(sGmToken, oGlobalData.Beneficiary_Assessment_Frequency__c);
			} else if(sHaToken.equals(oGlobalData.name)) {
				mapGDTokenToFrequency.put(sHaToken, oGlobalData.Beneficiary_Assessment_Frequency__c);
			} else if(sHatToken.equals(oGlobalData.name)) {
				mapGDTokenToFrequency.put(sHatToken, oGlobalData.Beneficiary_Assessment_Frequency__c);
			}
		}
		return mapGDTokenToFrequency;
	}

	/*********************************
	Method Name	: updateAccountDetails
	Description	: Once Growth monitoring Beneficiary Assessment is created, weight & height mentioned on assessment record is copied to its 
	  		      corresponding Beneficiary record.
	Return type	: void
	Parameter	: List<Beneficiary_Assessment__c>
	************************************/
	private void updateAccountDetails(List<Beneficiary_Assessment__c>
		lstNewRecords) {
		List<Id> lstBenefIdToQuery = new List<Id>();
		List<Beneficiary_Assessment__c> lstBenefAssessToLoop = new List <
			Beneficiary_Assessment__c>();
		List<Account> lstBenefToUpdate = new List<Account>();
		Map<Id, Beneficiary_Assessment__c> mapBenefIdToBAObj = new Map<Id,
			Beneficiary_Assessment__c>();
		Id grwthMonitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
			Beneficiary_Assessment__c.SObjectType, Constants.BA_Growth_Monitoring_RT_API_NAME
		);
		Id healthAssessRecTypeId = Utility.getRecordTypeIdByDeveloperName(
			Beneficiary_Assessment__c.SObjectType, Constants.BA_Health_Assessment_RT_API_NAME
		);

		for(Beneficiary_Assessment__c oBenefAssess: lstNewRecords) {
			if(grwthMonitRecTypeId.equals(oBenefAssess.RecordTypeId) ||
				healthAssessRecTypeId.equals(oBenefAssess.RecordTypeId)) {
				lstBenefIdToQuery.add(oBenefAssess.Beneficiary__c);
				lstBenefAssessToLoop.add(oBenefAssess);
				mapBenefIdToBAObj.put(oBenefAssess.Beneficiary__c, oBenefAssess);
			}
		}
		if(!lstBenefIdToQuery.isEmpty()) {
			Map<Id, Account> mapIdToBenef = null;
			mapIdToBenef = new Map<Id, Account> ([Select Weight_Kg__c,
				Height_Cm__c from Account where id in : lstBenefIdToQuery
			]);
		
			for(Beneficiary_Assessment__c oBenefAssess: lstBenefAssessToLoop) {
				Account oBenef = mapIdToBenef.get(oBenefAssess.Beneficiary__c);
				oBenef.Weight_Kg__c = oBenefAssess.Weight__c;
				oBenef.Height_Cm__c = oBenefAssess.Height__c;
				lstBenefToUpdate.add(oBenef);
			}

			if(!lstBenefToUpdate.isEmpty()) {
				List<Database.SaveResult> lstUpdateResults =
					Database.update(lstBenefToUpdate, false);
				Map<Id, List<String>> mapIdToErrorMsg =
					ErrorLogUtility.logDMLError(lstUpdateResults, lstBenefToUpdate, 'Account',
						'BeneficiaryAssessmentHandler', 'updateAccountDetails', 'SFDC CI', false
					);
				if(!mapIdToErrorMsg.isEmpty()) {
					for(Id accountId: mapIdToErrorMsg.keySet()) {
						if(mapBenefIdToBAObj.containsKey(accountId)) {
							Beneficiary_Assessment__c oBenefAsses = mapBenefIdToBAObj.get(
								accountId);
							for(String sErrorMsg: mapIdToErrorMsg.get(accountId)) {
								oBenefAsses.addError(System.Label.Error_on_Beneficiary + sErrorMsg);
								System.debug('Error while updating Beneficiary: ' + sErrorMsg +
									' For Beneficiary Assesment: ' + oBenefAsses.Name);
							}
						}
					}
				}
			}
		}
	}
}