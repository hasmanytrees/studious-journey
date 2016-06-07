/******************************************************************************************************
Class Name         : RankingAdministrationHandler
Deascription       : This is single Class for Ranking_Administration__c which will cover all the Ranking_Administration__c Functionality.
                     All Methods to cover Ranking_Administration__c functionality will be defined in this class. These methods
                     will be called from RankingAdministrationTrigger based on required trigger events.
Created By         : Himanshu Raichandani 
Created On         : 12-Dec-2014 
******************************************************************************************************/

public with sharing class RankingAdministrationHandler {

	/**
	 * Method name  : onBeforeInsert
	 * Description  : This method will be called before any Ranking Administration record is inserted
	 * Return Type  : void
	 * Parameter    : List<Ranking_Administration__c>
	 **/
	public void onBeforeInsert(List<Ranking_Administration__c> lstNewRecords) {
		checkForDuplicateRankingAdmin(lstNewRecords);
	}

	/**
	 * Method name  : onBeforeUpdate
	 * Description  : This method will be called before any Ranking Administration record is udpated
	 * Return Type  : void
	 * Parameter    : List<Ranking_Administration__c>
	 **/
	public void onBeforeUpdate(List<Ranking_Administration__c> lstNewRecords) {
		checkForDuplicateRankingAdmin(lstNewRecords);
	}

	/**
	 * Method name  : checkForDuplicateRankingAdmin
	 * Description  : This private method checks if Ranking Administtration object is already defined for same Field Office or not
	 * Return Type  : void
	 * Parameter    : List<Ranking_Administration__c>
	 **/
	private void checkForDuplicateRankingAdmin(List<Ranking_Administration__c>
		lstNewRecords) {
		List<Ranking_Administration__c> lstRankingAdminFromDB = 
			new List<Ranking_Administration__c>();
		lstRankingAdminFromDB = [Select Id,
			Field_Office__c from Ranking_Administration__c where Field_Office__c != 
			null
		];
		Map<Id, Id> mapFieldOfficeIdToRankingAdminId = new Map<Id, Id>();
		for(Ranking_Administration__c oRankingAdminFromDB: lstRankingAdminFromDB) {
			mapFieldOfficeIdToRankingAdminId.put(oRankingAdminFromDB.Field_Office__c,
				oRankingAdminFromDB.Id);
		}

		for(Ranking_Administration__c oConcernedRankingAdmin: lstNewRecords) {
			//Check if field office of concerned Ranking Admin record is equal to any of the existing Ranking Admin object in database
			if(mapFieldOfficeIdToRankingAdminId.keySet()
				.contains(oConcernedRankingAdmin.Field_Office__c)) {
				/*Check if record of mapFieldOfficeIdToRankingAdminId isn't similar to oConcernedRankingAdmin. 
				  This can happen when any existing Ranking Admin record is updated.
				  If it's same then just continue with the loop. If it's not then throw error.*/
				if(!mapFieldOfficeIdToRankingAdminId.get(oConcernedRankingAdmin.Field_Office__c)
					.equals(oConcernedRankingAdmin.Id)) {
					oConcernedRankingAdmin.addError(System.label.Error_For_Duplicate_FO_For_Ranking_Admin_Object);
				}
			}
		}
	}
}