/******************************************************************************************************
Class Name         : CommunicationUpdatesHandler
Description        : This is single Class for Communication Updates which will cover all the Communication
                     Updates Functionality. All Methods to cover Communication Updates functionality will
                     be defined in this class. These methods will be called from CommunicationUpdatesTrigger
                     based on required trigger events.
Created By         : Sudipta Nayak
Created On         : 15-Jul-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class CommunicationUpdatesHandler {

	/**
	 * Method name  : onBeforeInsert
	 * Description  : This method will be called before any Communication Updates record is inserted
	 * Return Type  : void
	 * Parameter    : List<Communication_Update__c>
	 **/
	public void onBeforeInsert(List<Communication_Update__c> lstNewRecords) {
		populateCommunicationPeriod(lstNewRecords);
        populateCommunicationUpdateName(lstNewRecords);
	}

	/**
	 * Method name  : populateCommunicationPeriod
	 * Description  : This method will populate the Communication Update From field on the created record
	 * Return Type  : void
	 * Parameter    : List<Communication_Update__c>
	 **/
	private void populateCommunicationPeriod(List<Communication_Update__c>
		lstNewRecords) {

		Set<Id> setDisasterIDs = new Set<Id>();
		Map<Id, DateTime> mapDisasterToCreatedDate = new Map<Id, DateTime>();
		Map<Id, Communication_Update__c> mapDisasterToCommUpdate = new Map<Id,
			Communication_Update__c>();
		List<Communication_Update__c> lstCommuncationUpdate = new List<
			Communication_Update__c>();
		List<Disaster__c> lstDisasterRec = new List<Disaster__c>();

		for(Communication_Update__c oComUpdateRec: lstNewRecords) {
			setDisasterIDs.add(oComUpdateRec.Disaster_Name__c);
		}
		if(!setDisasterIDs.IsEmpty()) {
			lstCommuncationUpdate = [Select id, CreatedDate, Disaster_Name__r.CreatedDate from Communication_Update__c where Disaster_Name__c in
				: setDisasterIDs ORDER BY CreatedDate DESC
			];
			lstDisasterRec = [Select id, createdDate from Disaster__c where ID in :
				setDisasterIDs
			];
		}
		for(Disaster__c oDisasterRec: lstDisasterRec) {
			mapDisasterToCreatedDate.put(oDisasterRec.Id, oDisasterRec.createdDate);
		}
		for(Communication_Update__c oCommUpdate: lstCommuncationUpdate) {
			if(!mapDisasterToCommUpdate.containsKey(oCommUpdate.Disaster_Name__c)) {
				mapDisasterToCommUpdate.put(oCommUpdate.Disaster_Name__c, oCommUpdate);
			}
		}
		for(Communication_Update__c oComUpdateRec: lstNewRecords) {
			if(!mapDisasterToCommUpdate.containsKey(oComUpdateRec.Disaster_Name__c)) {
				oComUpdateRec.Communication_Updates_From__c = mapDisasterToCreatedDate.get(
					oComUpdateRec.Disaster_Name__c);
			} else {
				oComUpdateRec.Communication_Updates_From__c = mapDisasterToCommUpdate.get(
						oComUpdateRec.Disaster_Name__c)
					.CreatedDate;
			}
		}
	}
    
    /**
	 * Method name  : populateCommunicationUpdateName
	 * Description  : This method will populate the Communication Update Name with a sequence number
	 * Return Type  : void
	 * Parameter    : List<Communication_Update__c>
	 **/
	private void populateCommunicationUpdateName(List<Communication_Update__c>
		lstNewRecords) {
            Set<Id> setDisasterIDs = new Set<Id>();
            Map<Id, Integer> mapDisasterToNumber = new Map<Id, Integer>();
    		List<Communication_Update__c> lstCommuncationUpdate = new List<
			Communication_Update__c>();
            
            for(Communication_Update__c oComUpdateRec: lstNewRecords) {
                setDisasterIDs.add(oComUpdateRec.Disaster_Name__c);
            }
            if(!setDisasterIDs.IsEmpty()) {
                lstCommuncationUpdate = [Select id, Disaster_Name__c from Communication_Update__c where Disaster_Name__c in
                    : setDisasterIDs 
                ];
            }
            for(Communication_Update__c oCommUpdate: lstCommuncationUpdate) {
                if(mapDisasterToNumber.containsKey(oCommUpdate.Disaster_Name__c)) {
                    mapDisasterToNumber.put(oCommUpdate.Disaster_Name__c, 
                    	mapDisasterToNumber.get(oCommUpdate.Disaster_Name__c)+1);
                }
                else
                    mapDisasterToNumber.put(oCommUpdate.Disaster_Name__c, 2);
            }
            for(Communication_Update__c oComUpdateRec: lstNewRecords) {
                if(mapDisasterToNumber.get(oComUpdateRec.Disaster_Name__c) == NULL)
                    oComUpdateRec.Communication_Update_Name__c = Constants.COMM_UPDATE_1;
                else
                	oComUpdateRec.Communication_Update_Name__c = Constants.COMM_UPDATE + 
                    	mapDisasterToNumber.get(oComUpdateRec.Disaster_Name__c);
            }
        }
}