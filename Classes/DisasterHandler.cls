/******************************************************************************************************
Class Name         : DisasterHandler
Description        : This is single Class for Disaster which will cover all the Disaster Functionality.
                     All Methods to cover oDisaster functionality will be defined in this class. These methods
                     will be called from DisasterTrigger based on required trigger events.
Created By         : Sudipta Nayak
Created On         : 24-Jun-2014 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

Public class DisasterHandler {

	/**
	 * Method name  : onBeforeInsert
	 * Description  : This method will be called before any Disaster record is inserted
	 * Return Type  : void
	 * Parameter    : List<Disaster__c> 
	 **/
	public void onBeforeInsert(List<Disaster__c> lstNewRecords) {
		updateDisasterCommunicationsContact(lstNewRecords);
		calculateSeverityLevel(lstNewRecords, null);
	}

	/**
	 * Method name  : onBeforeUpdate
	 * Description  : This method will be called before any Disaster record is updated
	 * Return Type  : void
	 * Parameter    : List<Disaster__c> 
	 **/
	public void onBeforeUpdate(List<Disaster__c> lstNewRecords, Map<Id,
		Disaster__c> mapOldRecords) {
		calculateSeverityLevel(lstNewRecords, mapOldRecords);
	}

	/**
	 * Method name  : calculateSeverityLevel
	 * Description  : This method calculates the severity level of a Disaster
	 * Return Type  : void
	 * Parameter    : List<Disaster__c> , Map<Id, Disaster__c>  
	 **/
	Private void calculateSeverityLevel(List<Disaster__c> lstNewRecords, Map <
		Id, Disaster__c> mapOldRecords) {
		for(Disaster__c oDisaster: lstNewRecords) {
			if(mapOldRecords == NULL || (!mapOldRecords.isEmpty() && (mapOldRecords.get(
						oDisaster.Id)
					.Estimated_Loss_Of_Life__c != oDisaster.Estimated_Loss_Of_Life__c ||
					mapOldRecords.get(oDisaster.Id)
					.Impact_To_Field_Office_Operations__c != oDisaster.Impact_To_Field_Office_Operations__c ||
					mapOldRecords.get(oDisaster.Id)
					.Estimated_Damage_Over_1_Million_USD__c != oDisaster.Estimated_Damage_Over_1_Million_USD__c ||
					mapOldRecords.get(oDisaster.Id)
					.Estimated_Serious_Injuries__c != oDisaster.Estimated_Serious_Injuries__c ||
					mapOldRecords.get(oDisaster.Id)
					.Estimated_Homes_Destroyed__c != oDisaster.Estimated_Homes_Destroyed__c ||
					mapOldRecords.get(oDisaster.Id)
					.Estimated_Not_Attending_Project__c != oDisaster.Estimated_Not_Attending_Project__c ||
					mapOldRecords.get(oDisaster.Id)
					.Estimated_Loss_Of_Livelihood__c != oDisaster.Estimated_Loss_Of_Livelihood__c ||
					mapOldRecords.get(oDisaster.Id)
					.Estimated_Basic_Supplies_Needed__c != oDisaster.Estimated_Basic_Supplies_Needed__c
				))) {
				if(oDisaster.Estimated_Loss_Of_Life__c == Constants.DISASTER_100_250 ||
					oDisaster.Estimated_Loss_Of_Life__c == Constants.DISASTER_250 ||
					oDisaster.Impact_To_Field_Office_Operations__c == Constants.NON_OPERATIONAL_DESTROYED ||
					oDisaster.Estimated_Damage_Over_1_Million_USD__c == Constants.YES)
						oDisaster.Disaster_Severity_Level__c = Constants.DISASTER_RED;
                    
				else if(oDisaster.Estimated_Loss_Of_Life__c == Constants.DISASTER_25_49 ||
					oDisaster.Estimated_Loss_Of_Life__c == Constants.DISASTER_50_99 ||
					oDisaster.Estimated_Serious_Injuries__c == Constants.DISASTER_50_99 ||
					oDisaster.Estimated_Serious_Injuries__c == Constants.DISASTER_100_250 ||
					oDisaster.Estimated_Serious_Injuries__c == Constants.DISASTER_250 ||
					oDisaster.Estimated_Homes_Destroyed__c == Constants.DISASTER_250)
						oDisaster.Disaster_Severity_Level__c = Constants.DISASTER_ORANGE;
                    
				else if(oDisaster.Estimated_Loss_Of_Life__c == Constants.DISASTER_1_10 ||
					oDisaster.Estimated_Loss_Of_Life__c == Constants.DISASTER_11_24 ||
					oDisaster.Estimated_Serious_Injuries__c == Constants.DISASTER_25_49 ||
					oDisaster.Estimated_Homes_Destroyed__c == Constants.DISASTER_50_99 ||
					oDisaster.Estimated_Homes_Destroyed__c == Constants.DISASTER_100_250 ||
					oDisaster.Estimated_Not_Attending_Project__c == Constants.DISASTER_100_250 ||
					oDisaster.Estimated_Not_Attending_Project__c == Constants.DISASTER_250 ||
					oDisaster.Estimated_Loss_Of_Livelihood__c == Constants.DISASTER_100_250 ||
					oDisaster.Estimated_Loss_Of_Livelihood__c == Constants.DISASTER_250 ||
					oDisaster.Estimated_Basic_Supplies_Needed__c == Constants.DISASTER_250)
						oDisaster.Disaster_Severity_Level__c = Constants.DISASTER_YELLOW;
                    
				else if((oDisaster.Estimated_Serious_Injuries__c == Constants.DISASTER_1_10 ||
                    oDisaster.Estimated_Serious_Injuries__c == Constants.DISASTER_11_24) ||
					(oDisaster.Estimated_Homes_Destroyed__c == Constants.DISASTER_1_10 ||
					oDisaster.Estimated_Homes_Destroyed__c == Constants.DISASTER_11_24 ||
					oDisaster.Estimated_Homes_Destroyed__c == Constants.DISASTER_25_49) ||
                    (oDisaster.Estimated_Not_Attending_Project__c == Constants.DISASTER_1_10 ||
					oDisaster.Estimated_Not_Attending_Project__c == Constants.DISASTER_11_24 ||
					oDisaster.Estimated_Not_Attending_Project__c == Constants.DISASTER_25_49 ||
					oDisaster.Estimated_Not_Attending_Project__c == Constants.DISASTER_50_99) ||
					(oDisaster.Estimated_Loss_Of_Livelihood__c == Constants.DISASTER_1_10 ||
					oDisaster.Estimated_Loss_Of_Livelihood__c == Constants.DISASTER_11_24 ||
					oDisaster.Estimated_Loss_Of_Livelihood__c == Constants.DISASTER_25_49 ||
					oDisaster.Estimated_Loss_Of_Livelihood__c == Constants.DISASTER_50_99) ||
                    (oDisaster.Estimated_Basic_Supplies_Needed__c == Constants.DISASTER_100_250 ||
					oDisaster.Estimated_Basic_Supplies_Needed__c == Constants.DISASTER_1_10 ||
					oDisaster.Estimated_Basic_Supplies_Needed__c == Constants.DISASTER_11_24 ||
					oDisaster.Estimated_Basic_Supplies_Needed__c == Constants.DISASTER_25_49 ||
					oDisaster.Estimated_Basic_Supplies_Needed__c == Constants.DISASTER_50_99) ||
					(oDisaster.Impact_To_Field_Office_Operations__c == Constants.MINOR ||
                    oDisaster.Impact_To_Field_Office_Operations__c == Constants.SIGNIFICANT))
						oDisaster.Disaster_Severity_Level__c = Constants.DISASTER_BLUE;
				else
					oDisaster.Disaster_Severity_Level__c = Constants.DISASTER_GREEN;
			}
		}
	}

	/**
	* Method name  : updateDisasterCommunicationsContact
	* Description  : This method defaults the Disaster Communications Contact with the name of the User who has
					 created the Master Disaster record.
	* Return Type  : void
	* Parameter    : List<Disaster__c> 
	**/
	Private void updateDisasterCommunicationsContact(List<Disaster__c>
		lstNewRecords) {
		for(Disaster__c oDisaster: lstNewRecords) {
			oDisaster.Disaster_Communications_Contact__c = UserInfo.getUserId();
		}
	}
}