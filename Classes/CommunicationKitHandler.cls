/******************************************************************************************************
Class Name         : CommunicationKitHandler
Description        : This is single Class for Communication Kit Object which will cover all it's trigger functionality.
These methods will be called from CommunicationKitTrigger based on required trigger events.
Created By         : Rahul Agarwal
Created On         : 03-Jul-2015
******************************************************************************************************/
public class CommunicationKitHandler
{
	public static boolean bUpdateFromPrintPortal = false;
	public static boolean bUpdateError = false;
	public static string strGlobalPartnerSBCId;
	public static string strBenID;


	/**
	* Method name  : onBeforeInsert
	* Description  : This method will be called before any Communication Kit record is inserted
	* Return Type  : void
	* Parameter    : List<Communication_Kit__c>
	**/
	public void onBeforeInsert(list<Communication_Kit__c> lstTriggerNew)
	{
		if(System.Label.Disable_for_Data_Load_R3 != 'true')
		{
			updateLastCommunicationDate(lstTriggerNew, null);
		}

		updateRelationType(lstTriggerNew, null);

		if(System.Label.Disable_for_Data_Load_R3 != 'true')
		{
			checkPrintAllowedDate(lstTriggerNew);
			updateSupporterCorrespondenceLang(lstTriggerNew);
			settingB2SKitStatus(lstTriggerNew);
			updateS2BKitStatus(lstTriggerNew);
			updateNumberOfPages(lstTriggerNew);
		}
	}


	/**
	* Method name  : onAfterInsert
	* Description  : This method will be called after any Communication Kit record is inserted
	* Return Type  : void
	* Parameter    : Map<Id, Communication_Kit__c>
	**/
	public void onAfterInsert(map<Id, Communication_Kit__c> mapTriggerNew)
	{
		if(System.Label.Disable_for_Data_Load_R3 != 'true')
		{
			createReciprocalKitOnIncomingS2B(mapTriggerNew.Values(), null);
			sendCommKitToGpOrSDL(null, mapTriggerNew);
			updateStatus(mapTriggerNew.values());
			updateBenLastWroteDate(mapTriggerNew.values(), null);
		}
	}


	/**
	* Method name  : onBeforeUpdate
	* Description  : This method will be called before any Communication Kit record is updated
	* Return Type  : void
	* Parameter    : List<Communication_Kit__c>, Map<Id, Communication_Kit__c>
	**/
	public void onBeforeUpdate(list<Communication_Kit__c> lstTriggerNew, map<Id, Communication_Kit__c> mapTriggerOld)
	{
		if(bUpdateFromPrintPortal == false)
		{
			if(System.Label.Disable_for_Data_Load_R3 != 'true')
			{
				updateLastCommunicationDate(lstTriggerNew, mapTriggerOld);
			}

			updateRelationType(lstTriggerNew, mapTriggerOld);

			if(System.Label.Disable_for_Data_Load_R3 != 'true')
			{
				checkPrintAllowedDate(lstTriggerNew);
				settingB2SKitStatus(lstTriggerNew);
				updateS2BKitStatus(lstTriggerNew);
				preventINTSupporterUpdate(lstTriggerNew, mapTriggerOld);
				updateErrorDescription(lstTriggerNew);
			}
		}
	}


	/**
	* Method name  : onAfterUpdate
	* Description  : This method will be called after any Communication Kit record is updated
	* Return Type  : void
	* Parameter    : Map<Id, Communication_Kit__c>, Map<Id, Communication_Kit__c>
	**/
	public void onAfterUpdate(map<Id, Communication_Kit__c> mapTriggerOld, map<Id, Communication_Kit__c> mapTriggerNew)
	{
		if(System.Label.Disable_for_Data_Load_R3 != 'true')
		{
			sendCommKitToGpOrSDL(mapTriggerOld, mapTriggerNew);

			if(bUpdateFromPrintPortal == false)
			{
				createReciprocalKitOnIncomingS2B(mapTriggerNew.Values(), mapTriggerOld);

				//sendCommKitToCompass(mapTriggerNew.Values(), mapTriggerOld);
				// UpdateStatus has to be the last method to be called

				updateStatus(mapTriggerNew.values());
				updateBenLastWroteDate(mapTriggerNew.values(), mapTriggerOld);
				updateLetterStatus(mapTriggerNew, mapTriggerOld);
			}
		}
	}


	/**
	* Method name  : onAfterDelete
	* Description  : This method will be called after any Communication Kit record is deleted
	* Return Type  : void
	* Parameter    : Map<Id, Communication_Kit__c>
	**/
	public void onAfterDelete(map<Id, Communication_Kit__c> mapTriggerOld)
	{
		if(System.Label.Disable_for_Data_Load_R3 != 'true')
		{
			CommunicationDeletion.sendCommunicationDeletion(mapTriggerOld.Values());
		}
	}


	public static final string sRecordTypeS2B = Utility.getRecordTypeIdByDeveloperName(Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_S2B_RT);
	public static final string sRecordTypeB2S = Utility.getRecordTypeIdByDeveloperName(Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_B2S_RT);
	public static boolean bSendJSONResponse = false;
	

	/**
	* Method name  : findOrCreateCommKitRecord
	* Description  : This method will create the communication kits for the passed beneficiary
	* Return Type  : void
	* Parameter    : map<String, String>, map<Id, Account>
	**/
	public static void findOrCreateCommKitRecord(map<string, string> mapBenIdCommKitType, map<string, string> mapLocalBenIdSuppQuestions)
	{
		System.debug('>>>> mapBenIdCommKitType : ' + mapBenIdCommKitType);
		System.debug('>>>> mapLocalBenIdSuppQuestions : ' + mapLocalBenIdSuppQuestions);
		
		map<Id, Account> mapBenPassed = new  map<Id, Account>();
		mapBenPassed = new  map<Id, Account>([SELECT
			Id, 
			Local_Beneficiary_Id__c, 
			BEN_Last_Wrote__c, 
			BEN_Next_Allowed_Writing_Date__c
		FROM
			Account
		WHERE
			Local_Beneficiary_Id__c in: mapBenIdCommKitType.KeySet() AND RecordTypeId = : Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME)]);
		map<string, string> mapBenIdCommKitTypeForCDSPOnly = new  map<string, string>();
		
		for(Account oAcc: mapBenPassed.Values())
		{
			mapBenIdCommKitTypeForCDSPOnly.put(oAcc.Local_Beneficiary_Id__c, mapBenIdCommKitType.get(oAcc.Local_Beneficiary_Id__c));
		}
		
		map<string, Account> mapLocalBenIdBen = new  map<string, Account>();
		
		for(Account oAcc: mapBenPassed.Values())
		{
			mapLocalBenIdBen.put(oAcc.Local_Beneficiary_Id__c, oAcc);
		}

		list<Communication_Kit__c> lstCommKits = new  list<Communication_Kit__c>();
		map<string, Id> mapLocalBenIdCommKitId = new  map<string, Id>();
		list<Communication_Kit__c> lstUpdateCommKit = new  list<Communication_Kit__c>();
		lstCommKits = [SELECT
			Id, 
			BEN_Local_ID__c, 
			Communication_Types__c, 
			Supporter_Questions__c
		FROM
			Communication_Kit__c
		WHERE
			BEN_Local_ID__c in: mapBenIdCommKitTypeForCDSPOnly.KeySet() AND Status__c = : Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED AND RecordTypeId = : sRecordTypeB2S
		ORDER BY
			CreatedDate];

		for(Communication_Kit__c oComKit: lstCommKits)
		{
			System.debug('>>>> mapLocalBenIdSuppQuestions : ' + mapLocalBenIdSuppQuestions);
			System.debug('>>>> oComKit.BEN_Local_ID__c : ' + oComKit.BEN_Local_ID__c);
			Boolean bUpdate = false;

			if(mapLocalBenIdSuppQuestions != null && mapLocalBenIdSuppQuestions.containsKey(oComKit.BEN_Local_ID__c))
			{
				System.debug('>>>> mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c) ' + mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c));
				bUpdate = true;

				if(string.isEmpty(oComKit.Supporter_Questions__c))
				{
					oComKit.Supporter_Questions__c = ((mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c) == null) ? '' : mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c));
				}
				else if(!string.isEmpty(oComKit.Supporter_Questions__c))
				{
					if(!string.isEmpty(mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c)) && !mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c).equalsIgnoreCase(Constants.SBC_No_Questions) && !oComKit.Supporter_Questions__c.containsIgnoreCase(mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c)))
					{
						oComKit.Supporter_Questions__c += '; ' + mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c);
						if(oComKit.Supporter_Questions__c.containsIgnoreCase(Constants.SBC_No_Questions + '; '))
						{
							oComKit.Supporter_Questions__c = oComKit.Supporter_Questions__c.remove(Constants.SBC_No_Questions + '; ');
						}
					}
				}
			}

			if(!mapLocalBenIdCommKitId.containsKey(oComKit.BEN_Local_Id__c))
			{
				System.debug('>>>> ocomKit.Communication_Types__c ' + ocomKit.Communication_Types__c);
				mapLocalBenIdCommKitId.put(oComKit.BEN_Local_ID__c, oComKit.Id);

				if(ocomKit.Communication_Types__c != null && !ocomKit.Communication_Types__c.contains(mapBenIdCommKitTypeForCDSPOnly.get(oComKit.BEN_Local_Id__c)))
				{
					ocomKit.Communication_Types__c += ';' + mapBenIdCommKitTypeForCDSPOnly.get(oComKit.BEN_Local_Id__c);
					lstUpdateCommKit.add(ocomKit);
					bUpdate = false;
				}
				else if(ocomKit.Communication_Types__c == null)
				{
					ocomKit.Communication_Types__c = mapBenIdCommKitTypeForCDSPOnly.get(oComKit.BEN_Local_Id__c);
					lstUpdateCommKit.add(ocomKit);
					bUpdate = false;
				}

				if(bUpdate == true)
				{
					lstUpdateCommKit.add(ocomKit);
				}

				if(mapBenIdCommKitTypeForCDSPOnly.get(oComKit.BEN_Local_Id__c) != null && mapBenIdCommKitTypeForCDSPOnly.get(oComKit.BEN_Local_Id__c).contains(Constants.CORRESPONDENCE_ITEM_TYPE))
				{
					oComKit.Print_Allowed_Date__c = system.today();
				}

				mapBenIdCommKitTypeForCDSPOnly.KeySet().remove(oComKit.BEN_Local_Id__c);
			}
		}

		if(!lstUpdateCommKit.isEmpty())
		{
			removeDUplicateCommunicationTypes(lstUpdateCommKit);
			List<Database.SaveResult> lstUpdateResults = Database.update(lstUpdateCommKit, false);
			Map<Id, List<string>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(lstUpdateResults, lstUpdateCommKit, Constants.COMMUNICATION_KIT_API_NAME, Constants.CLASS_COMMUNICATION_KIT_HANDLER, 'findOrCreateCommKitRecord', Constants.SOURCE_SYSTEM_SFDC_CI, false);
		}

		// create new Communication Kit
		list<Commitment__c> lstCommitments = new  list<Commitment__c>();

		system.debug('<><><> ' + mapBenIdCommKitTypeForCDSPOnly.KeySet());

		lstCommitments = [SELECT
			Id, 
			BEN_Id__c, 
			BEN_Id__r.Local_Beneficiary_Id__c, 
			Status__c, 
			SUP_Id__c, 
			Relationship_Type__c
		FROM
			Commitment__c
		WHERE
			BEN_Id__r.Local_Beneficiary_Id__c in: mapBenIdCommKitTypeForCDSPOnly.KeySet() AND Status__c = : Constants.COMMITMENT_STATUS_ACTIVE
		ORDER BY
			CreatedDate];
		
		System.debug('>>>> lstCommitments : ' + lstCommitments.size());
		
		list<Communication_Kit__c> lstNewCommKit = new  list<Communication_Kit__c>();
		map<string, Commitment__c> mapLocalBenidCommitmentCorrespondent = new  map<string, Commitment__c>();
		
		for(Commitment__c oCommitment: lstCommitments)
		{
			if(oCommitment.Relationship_Type__c == Constants.COMMITMENT_TYPE_CORRESPONDENT && !mapLocalBenidCommitmentCorrespondent.containsKey(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c))
			{
				mapLocalBenidCommitmentCorrespondent.put(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c, oCommitment);
				lstNewCommKit.add(createCommKitRecord(oCommitment, mapLocalBenIdBen, mapBenIdCommKitTypeForCDSPOnly.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c)));
			}
		}

		map<string, Commitment__c> mapLocalBenidSponsorship = new  map<string, Commitment__c>();
		
		for(Commitment__c oCommitment: lstCommitments)
		{
			if(oCommitment.Relationship_Type__c == Constants.COMMITMENT_TYPE_SPONSORSHIP && !mapLocalBenidCommitmentCorrespondent.containsKey(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c) && !mapLocalBenidSponsorship.containsKey(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c))
			{
				mapLocalBenidSponsorship.put(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c, oCommitment);
				lstNewCommKit.add(createCommKitRecord(oCommitment, mapLocalBenIdBen, mapBenIdCommKitTypeForCDSPOnly.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c)));
			}
		}

		System.debug('>>>> lstNewCommKit : ' + lstNewCommKit.size());
		System.debug('>>>> lstNewCommKit : ' + lstNewCommKit.size());

		if(lstNewCommKit.size() > 0)
		{
			for(Communication_Kit__c oCommRec: lstNewCommKit)
			{
				System.debug('>>>> mapLocalBenIdSuppQuestions : ' + mapLocalBenIdSuppQuestions);
				System.debug('>>>> oCommRec.BEN_ID__r.Local_Beneficiary_ID__c : ' + oCommRec.BEN_ID__r.Local_Beneficiary_ID__c);
				
				if(mapLocalBenIdSuppQuestions != null && mapLocalBenIdSuppQuestions.containsKey(mapBenPassed.get(oCommRec.BEN_ID__c).Local_Beneficiary_ID__c))
				{
					oCommRec.Supporter_Questions__c = mapLocalBenIdSuppQuestions.get(mapBenPassed.get(oCommRec.BEN_ID__c).Local_Beneficiary_ID__c);
				}
			}

			removeDUplicateCommunicationTypes(lstNewCommKit);
			Insert lstNewCommKit;
		}

		for(Communication_Kit__c oCommKit: lstNewCommKit)
		{
			mapLocalBenIdCommKitId.put(mapBenPassed.get(oCommKit.BEN_Id__c).Local_Beneficiary_Id__c, oCommKit.Id);
		}

		//return mapLocalBenIdCommKitId;
		if(CommunicationKitHandler.bSendJSONResponse)
		{
			list<Communication_Kit__c> lstToSendResponse = new  list<Communication_Kit__c>();
			set<Id> setCommKitIds = new  set<Id>();
			setCommKitIds.addAll(mapLocalBenIdCommKitId.Values());
			string sQuery = 'Select ' + Utility.getFieldGroupElements(Constants.COMMUNICATION_RESPONSES_FG) + 'Name from Communication_Kit__c where Id IN: setCommKitIds';
			lstToSendResponse = database.query(sQuery);

			for(Communication_Kit__c oCommKit: lstToSendResponse)
			{
				oCOmmKit.INT_Communication_Kit_Id__c = oCommKit.Name;
			}

			Map<string, List<sObject>> mapOutputVar = new  Map<string, List<sObject>>();
			mapOutputVar.put(Constants.COMMUNICATION_RESPONSES_FG, lstToSendResponse);
			string sJsonResponse = JSONHandlerMethods.serialize(mapOutputVar, Constants.COMMUNICATION_RESPONSES_PN);

			system.debug('<><><> ' + sJsonResponse);

			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = blob.valueOf(sJsonResponse);
		}
	}


	private static void updateErrorDescription(List<Communication_Kit__c> lstNewComm)
	{
		for(Communication_Kit__c oComm: lstNewComm)
		{
			if(oComm.Status__c != 'System Error')
			{
				oComm.Error_Description__c = '';
			}
		}
	}


	/**
	* Method name  : findOrCreateCommKitRecordExt
	* Description  : This method will create the communication kits for the passed beneficiary
	* Return Type  : void
	* Parameter    : map<String, String>
	**/
	public static void findOrCreateCommKitRecordExt(map<string, string> mapBenIdCommKitType, map<string, string> mapLocalBenIdSuppQuestions)
	{
		System.debug('>>>> mapLocalBenIdSuppQuestions: ' + mapLocalBenIdSuppQuestions);
		
		map<Id, Account> mapBenPassed = new  map<Id, Account>();
		
		mapBenPassed = new  map<Id, Account>([SELECT
			Id, 
			Local_Beneficiary_Id__c, 
			BEN_Last_Wrote__c, 
			BEN_Next_Allowed_Writing_Date__c
		FROM
			Account
		WHERE
			Local_Beneficiary_Id__c in: mapBenIdCommKitType.KeySet() AND RecordTypeId = : Utility.getRecordTypeIdByDeveloperName(Account.SObjectType, Constants.CDSP_BENEFICIARY_RT_API_NAME)]);
		map<string, Account> mapLocalBenIdBen = new  map<string, Account>();
		
		//Map of LocalBenid & Ben Account Record
		for(Account oAcc: mapBenPassed.Values())
		{
			mapLocalBenIdBen.put(oAcc.Local_Beneficiary_Id__c, oAcc);
		}
		
		map<string, string> mapBenIdCommKitTypeForCDSPOnly = new  map<string, string>();
		
		//Map of LocalBenid & Gift Name
		for(Account oAcc: mapBenPassed.Values())
		{
			mapBenIdCommKitTypeForCDSPOnly.put(oAcc.Local_Beneficiary_Id__c, mapBenIdCommKitType.get(oAcc.Local_Beneficiary_Id__c));
		}

		list<Commitment__c> lstCommitments = new  list<Commitment__c>();
		lstCommitments = [SELECT
			Id, 
			BEN_Id__c, 
			BEN_Id__r.Local_Beneficiary_Id__c, 
			Status__c, 
			SUP_Id__c, 
			Relationship_Type__c
		FROM
			Commitment__c
		WHERE
			BEN_Id__r.Local_Beneficiary_Id__c in: mapBenIdCommKitTypeForCDSPOnly.KeySet() AND Status__c = : Constants.COMMITMENT_STATUS_ACTIVE
		ORDER BY
			CreatedDate];

		map<string, Commitment__c> mapLocalBenidCommitmentCorrespondent = new  map<string, Commitment__c>();

		for(Commitment__c oCommitment: lstCommitments)
		{
			if(oCommitment.Relationship_Type__c == Constants.COMMITMENT_TYPE_CORRESPONDENT && !mapLocalBenidCommitmentCorrespondent.containsKey(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c))
			{
				mapLocalBenidCommitmentCorrespondent.put(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c, oCommitment);
			}
		}

		map<string, Commitment__c> mapLocalBenidSponsorship = new  map<string, Commitment__c>();

		for(Commitment__c oCommitment: lstCommitments)
		{
			if(oCommitment.Relationship_Type__c == Constants.COMMITMENT_TYPE_SPONSORSHIP && !mapLocalBenidCommitmentCorrespondent.containsKey(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c) && !mapLocalBenidSponsorship.containsKey(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c))
			{
				mapLocalBenidSponsorship.put(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c, oCommitment);
			}
		}

		list<Communication_Kit__c> lstCommKits = new  list<Communication_Kit__c>();
		map<string, Id> mapLocalBenIdCommKitId = new  map<string, Id>();
		list<Communication_Kit__c> lstUpdateCommKit = new  list<Communication_Kit__c>();
		lstCommKits = [SELECT
			Id, 
			Name, 
			BEN_Local_ID__c, 
			Communication_Types__c, 
			Supporter_Questions__c, 
			Relationship_Type__c, 
			BEN_Id__c
		FROM
			Communication_Kit__c
		WHERE
			(BEN_Local_ID__c in: mapLocalBenidCommitmentCorrespondent.KeySet() OR BEN_Local_ID__c in: mapLocalBenidSponsorship.KeySet()) AND Status__c = : Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED AND RecordTypeId = : sRecordTypeB2S
		ORDER BY
			CreatedDate];

		for(Communication_Kit__c oComKit: lstCommKits)
		{
			Boolean bUpdate = false;
			System.debug('>>>> oComKit.Name: ' + oComKit.Name);
			if(oComKit.Relationship_Type__c == Constants.COMMITMENT_TYPE_CORRESPONDENT)
			{
				if(mapLocalBenIdSuppQuestions != null && mapLocalBenIdSuppQuestions.containsKey(oComKit.BEN_Local_ID__c))
				{
					if(string.isEmpty(oComKit.Supporter_Questions__c))
					{
						bUpdate = true;
						oComKit.Supporter_Questions__c = ((mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c) == null) ? '' : mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c));
					}
					else if(!string.isEmpty(oComKit.Supporter_Questions__c))
					{
						if(!string.isEmpty(mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c)) && !mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c).equalsIgnoreCase(Constants.SBC_No_Questions) && !oComKit.Supporter_Questions__c.containsIgnoreCase(mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c)))
						{
							bUpdate = true;
							oComKit.Supporter_Questions__c += '; ' + mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c);
							if(oComKit.Supporter_Questions__c.containsIgnoreCase(Constants.SBC_No_Questions + '; '))
							{
								oComKit.Supporter_Questions__c = oComKit.Supporter_Questions__c.remove(Constants.SBC_No_Questions + '; ');
							}
						}
					}
				}

				if(oComKit.Communication_Types__c != null && !oComKit.Communication_Types__c.contains(mapBenIdCommKitTypeForCDSPOnly.get(oComKit.BEN_Local_Id__c)))
				{
					oComKit.Communication_Types__c += ';' + mapBenIdCommKitTypeForCDSPOnly.get(oComKit.BEN_Local_Id__c);
					lstUpdateCommKit.add(oComKit);
					bUpdate = false;
				}
				else if(oComKit.Communication_Types__c == null)
				{
					oComKit.Communication_Types__c = mapBenIdCommKitTypeForCDSPOnly.get(oComKit.BEN_Local_Id__c);
					lstUpdateCommKit.add(oComKit);
					bUpdate = false;
				}

				System.debug('>>>> oComKit.Supporter_Questions__c : ' + oComKit.Supporter_Questions__c);

				mapLocalBenIdCommKitId.put(mapBenPassed.get(oComKit.BEN_Id__c).Local_Beneficiary_Id__c, oComKit.Id);
				mapLocalBenidCommitmentCorrespondent.KeySet().remove(oComKit.BEN_Local_Id__c);

				if(bUpdate == true)
				{
					lstUpdateCommKit.add(ocomKit);
				}
			}
			else if(oComKit.Relationship_Type__c == Constants.COMMITMENT_TYPE_SPONSORSHIP)
			{
				if(mapLocalBenIdSuppQuestions != null && mapLocalBenIdSuppQuestions.containsKey(oComKit.BEN_Local_ID__c) && !mapLocalBenIdCommKitId.containsKey(mapBenPassed.get(oComKit.BEN_Id__c).Local_Beneficiary_Id__c))
				{
					if(string.isEmpty(oComKit.Supporter_Questions__c))
					{
						bUpdate = true;
						oComKit.Supporter_Questions__c = ((mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c) == null) ? '' : mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c));
					}
					else if(!string.isEmpty(oComKit.Supporter_Questions__c))
					{
						if(!string.isEmpty(mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c)) && !mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c).equalsIgnoreCase(Constants.SBC_No_Questions) && !oComKit.Supporter_Questions__c.containsIgnoreCase(mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c)))
						{
							bUpdate = true;
							oComKit.Supporter_Questions__c += '; ' + mapLocalBenIdSuppQuestions.get(oComKit.BEN_Local_ID__c);
							if(oComKit.Supporter_Questions__c.containsIgnoreCase(Constants.SBC_No_Questions + '; '))
							{
								oComKit.Supporter_Questions__c = oComKit.Supporter_Questions__c.remove(Constants.SBC_No_Questions + '; ');
							}
						}
					}
				}

				if(oComKit.Communication_Types__c != null && !oComKit.Communication_Types__c.contains(mapBenIdCommKitTypeForCDSPOnly.get(oComKit.BEN_Local_Id__c)))
				{
					oComKit.Communication_Types__c += ';' + mapBenIdCommKitTypeForCDSPOnly.get(oComKit.BEN_Local_Id__c);
					lstUpdateCommKit.add(oComKit);
					bUpdate = false;
					mapLocalBenIdCommKitId.put(mapBenPassed.get(oComKit.BEN_Id__c).Local_Beneficiary_Id__c, oComKit.Id);
				}
				else if(oComKit.Communication_Types__c == null)
				{
					oComKit.Communication_Types__c = mapBenIdCommKitTypeForCDSPOnly.get(oComKit.BEN_Local_Id__c);
					lstUpdateCommKit.add(oComKit);
					bUpdate = false;
					mapLocalBenIdCommKitId.put(mapBenPassed.get(oComKit.BEN_Id__c).Local_Beneficiary_Id__c, oComKit.Id);
				}

				if(!mapLocalBenIdCommKitId.containsKey(mapBenPassed.get(oComKit.BEN_Id__c).Local_Beneficiary_Id__c))
				{
					mapLocalBenIdCommKitId.put(mapBenPassed.get(oComKit.BEN_Id__c).Local_Beneficiary_Id__c, oComKit.Id);
				}

				mapLocalBenidSponsorship.KeySet().remove(oComKit.BEN_Local_Id__c);

				if(bUpdate == true)
				{
					lstUpdateCommKit.add(ocomKit);
				}
			}
		}

		if(!lstUpdateCommKit.isEmpty())
		{
			removeDUplicateCommunicationTypes(lstUpdateCommKit);
			List<Database.SaveResult> lstUpdateResults = Database.update(lstUpdateCommKit, false);
			Map<Id, List<string>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(lstUpdateResults, lstUpdateCommKit, Constants.COMMUNICATION_KIT_API_NAME, Constants.CLASS_COMMUNICATION_KIT_HANDLER, 'findOrCreateCommKitRecord', Constants.SOURCE_SYSTEM_SFDC_CI, false);
		}

		list<Communication_Kit__c> lstNewCommKit = new  list<Communication_Kit__c>();

		for(Commitment__c oCommitment: mapLocalBenidCommitmentCorrespondent.values())
		{
			lstNewCommKit.add(createCommKitRecordExt(oCommitment, mapLocalBenIdBen, mapBenIdCommKitTypeForCDSPOnly.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c), Constants.COMMITMENT_TYPE_CORRESPONDENT));
		}

		for(Commitment__c oCommitment: mapLocalBenidSponsorship.values())
		{
			lstNewCommKit.add(createCommKitRecord(oCommitment, mapLocalBenIdBen, mapBenIdCommKitTypeForCDSPOnly.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c)));
		}

		if(lstNewCommKit.size() > 0)
		{
			for(Communication_Kit__c oCommRec: lstNewCommKit)
			{
				if(mapLocalBenIdSuppQuestions != null && mapLocalBenIdSuppQuestions.containsKey(mapBenPassed.get(oCommRec.BEN_ID__c).Local_Beneficiary_ID__c))
				{
					oCommRec.Supporter_Questions__c = mapLocalBenIdSuppQuestions.get(mapBenPassed.get(oCommRec.BEN_ID__c).Local_Beneficiary_ID__c);
				}
			}

			removeDUplicateCommunicationTypes(lstNewCommKit);

			List<Database.SaveResult> lstInsertResults = Database.insert(lstNewCommKit, false);
			Map<Id, List<string>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(lstInsertResults, lstNewCommKit, Constants.COMMUNICATION_KIT_API_NAME, Constants.CLASS_COMMUNICATION_KIT_HANDLER, 'findOrCreateGiftRecord', Constants.SOURCE_SYSTEM_SFDC_CI, false);
		}

		for(Communication_Kit__c oCommKit: lstNewCommKit)
		{
			mapLocalBenIdCommKitId.put(mapBenPassed.get(oCommKit.BEN_Id__c).Local_Beneficiary_Id__c, oCommKit.Id);
		}

		System.debug('mapLocalBenIdCommKitId : ' + mapLocalBenIdCommKitId);

		if(CommunicationKitHandler.bSendJSONResponse)
		{
			list<Communication_Kit__c> lstToSendResponse = new  list<Communication_Kit__c>();
			set<Id> setCommKitIds = new  set<Id>();
			setCommKitIds.addAll(mapLocalBenIdCommKitId.Values());

			string sQuery = 'Select ' + Utility.getFieldGroupElements(Constants.COMMUNICATION_RESPONSES_FG) + 'Name from Communication_Kit__c where Id IN: setCommKitIds';
			lstToSendResponse = database.query(sQuery);

			for(Communication_Kit__c oCommKit: lstToSendResponse)
			{
				oCOmmKit.INT_Communication_Kit_Id__c = oCommKit.Name;
			}

			Map<string, List<sObject>> mapOutputVar = new  Map<string, List<sObject>>();
			mapOutputVar.put(Constants.COMMUNICATION_RESPONSES_FG, lstToSendResponse);
			string sJsonResponse = JSONHandlerMethods.serialize(mapOutputVar, Constants.COMMUNICATION_RESPONSES_PN);

			system.debug('<><><> Akash' + sJsonResponse);

			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = blob.valueOf(sJsonResponse);
		}
	}


	/**
	* Method name  : createCommKitRecord
	* Description  : This method will create the communication kit record based on the parameters passed
	* Return Type  : Communication_Kit__c
	* Parameter    : Commitment__c, map<String, Account>, String
	**/
	private static Communication_Kit__c createCommKitRecord(Commitment__c oCommitment, map<string, Account> mapLocalBenIdBen, string sCommKitCommunicationType)
	{
		Communication_Kit__c oCommKitRec = new  Communication_Kit__c(BEN_Id__c = mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).Id, SUP_Id__c = oCommitment.SUP_Id__c, Status__c = Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED, Communication_Types__c = sCommKitCommunicationType, RecordTypeId = sRecordTypeB2S);

		if(sCommKitCommunicationType.Contains(Constants.CORRESPONDENCE_ITEM_TYPE))
		{
			oCommKitRec.Print_Allowed_Date__c = system.today();
		}
		else if(mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).BEN_Next_Allowed_Writing_Date__c != null && (system.today() >= mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).BEN_Next_Allowed_Writing_Date__c))
		{
			oCommKitRec.Print_Allowed_Date__c = system.today();
		}
		else if(mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).BEN_Next_Allowed_Writing_Date__c != null && (system.today() < mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).BEN_Next_Allowed_Writing_Date__c))
		{
			oCommKitRec.Print_Allowed_Date__c = mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).BEN_Next_Allowed_Writing_Date__c;
		}

		return oCommKitRec;
	}


	/**
	* Method name  : createCommKitRecordExt
	* Description  : This method will create the communication kit record based on the parameters passed
	* Return Type  : Communication_Kit__c
	* Parameter    : Commitment__c, map<String, Account>, String, String
	**/
	private static Communication_Kit__c createCommKitRecordExt(Commitment__c oCommitment, map<string, Account> mapLocalBenIdBen, string sCommKitCommunicationType, string sRelType)
	{
		Communication_Kit__c oCommKitRec = new  Communication_Kit__c(BEN_Id__c = mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).Id, SUP_Id__c = oCommitment.SUP_Id__c, Status__c = Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED, Communication_Types__c = sCommKitCommunicationType, RecordTypeId = sRecordTypeB2S);

		if(sCommKitCommunicationType.Contains(Constants.CORRESPONDENCE_ITEM_TYPE))
		{
			oCommKitRec.Print_Allowed_Date__c = system.today();
		}
		else if(mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).BEN_Next_Allowed_Writing_Date__c != null && (system.today() >= mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).BEN_Next_Allowed_Writing_Date__c))
		{
			oCommKitRec.Print_Allowed_Date__c = system.today();
		}
		else if(mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).BEN_Next_Allowed_Writing_Date__c != null && (system.today() < mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).BEN_Next_Allowed_Writing_Date__c))
		{
			oCommKitRec.Print_Allowed_Date__c = mapLocalBenIdBen.get(oCommitment.BEN_Id__r.Local_Beneficiary_Id__c).BEN_Next_Allowed_Writing_Date__c;
		}

		oCommKitRec.Relationship_Type__c = sRelType;

		return oCommKitRec;
	}


	/**
	* Method name  : removeDuplicateCommunicationTypes
	* Description  : This method will remove duplicate values from Communication Types multiselect
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>
	**/
	private static void removeDuplicateCommunicationTypes(list<Communication_Kit__c> lstCommKit)
	{
		for(Communication_Kit__c oCommKit: lstCommKit)
		{
			list<string> lstCommunicationTypes = new  list<string>();
			lstCommunicationTypes = oCommKit.Communication_Types__c.split(';');
			set<string> setCommunicationTypes = new  set<string>();
			setCommunicationTypes.addAll(lstCommunicationTypes);

			if(lstCommunicationTypes.size() != setCommunicationTypes.size())
			{
				oCommKit.Communication_Types__c = '';

				for(string sCommType: setCommunicationTypes)
				{
					if(oCommKit.Communication_Types__c == '')
					{
						oCommKit.Communication_Types__c = sCommType;
					}
					else
					{
						oCommKit.Communication_Types__c += ';' + sCommType;
					}
				}
			}
		}
	}


	/**
	* Method name  : sendCommKitToGpOrSDL
	* Description  : This method will receove the new and old map of communication kit, analyze if the
	status has changed and if the communication kit qualifies to be sent to GP or SDL
	* Return Type  : void
	* Parameter    : map<Id, Communication_Kit__c>, map<Id, Communication_Kit__c>
	**/
	private static void sendCommKitToGpOrSDL(map<Id, Communication_Kit__c> mapTriggerOld, map<Id, Communication_Kit__c> mapTriggerNew)
	{
		map<string, map<string, list<Communication_Kit__c>>> mapWhomToSendCommKitsToSend = new  map<string, map<string, list<Communication_Kit__c>>>();
		system.debug('******sendCommKitToGpOrSDL' + mapTriggerNew);
		map<string, Send_Communication_Kit_On_Status_Change__c> mapCustomSetting = new  map<string, Send_Communication_Kit_On_Status_Change__c>();
		mapCustomSetting = Send_Communication_Kit_On_Status_Change__c.getAll();
		map<string, list<Send_Communication_Kit_On_Status_Change__c>> mapCustomSettingUpdated = new  map<string, list<Send_Communication_Kit_On_Status_Change__c>>();
		
		for(Send_Communication_Kit_On_Status_Change__c oVar: mapCustomSetting.Values())
		{
			if(!mapCustomSettingUpdated.containsKey(oVar.Communication_Kit_Status__c))
			{
				mapCustomSettingUpdated.put(oVar.Communication_Kit_Status__c, new  list<Send_Communication_Kit_On_Status_Change__c>());
			}

			mapCustomSettingUpdated.get(oVar.Communication_Kit_Status__c).add(oVar);
		}

		map<Id, RecordType> mapRecordType = new  map<Id, RecordType>();
		mapRecordType = new  map<Id, RecordType>([SELECT
			Id, 
			Developername
		FROM
			RecordType
		WHERE
			SObjectType = : Constants.COMMUNICATION_KIT_API_NAME]);

		for(Communication_Kit__c oCommKit: mapTriggerNew.Values())
		{
			if(mapCustomSettingUpdated.containsKey(oCommKit.Status__c))
			{
				if(mapTriggerOld == null || (mapTriggerOld != null && (mapTriggerOld.get(oCommKit.Id).Status__c != oCommKit.Status__c || bUpdateFromPrintPortal)))
				{
					for(Send_Communication_Kit_On_Status_Change__c oVar: mapCustomSettingUpdated.get(oCommKit.Status__c))
					{
						if(oVar.RecordType_Developer_Name__c == null || oVar.RecordType_Developer_Name__c == '' || oVar.RecordType_Developer_Name__c.contains(mapRecordType.get(oCommKit.RecordTypeId).DeveloperName))
						{
							/* MV : Included a condition to restrict non-us sponsor communication to compass */
							if((oVar.Whom_To_Send__c == Constants.COMMUNICATION_TO_COMPASS && oCommKit.Global_Partner_ID__c == Constants.COMMUNICATION_TO_US && oVar.RecordType_Developer_Name__c == Constants.COMMUNICATION_KIT_S2B_RT) || (oVar.Whom_To_Send__c == Constants.COMMUNICATION_TO_COMPASS && oVar.RecordType_Developer_Name__c == Constants.COMMUNICATION_KIT_B2S_RT) || (oVar.Whom_To_Send__c != Constants.COMMUNICATION_TO_COMPASS))
							{
								if(!mapWhomToSendCommKitsToSend.containsKey(oVar.Class_to_call__c))
								{
									mapWhomToSendCommKitsToSend.put(oVar.Class_to_call__c, new  map<string, list<Communication_Kit__c>>());
								}

								if(!mapWhomToSendCommKitsToSend.get(oVar.Class_to_call__c).containsKey(oVar.Whom_To_Send__c))
								{
									mapWhomToSendCommKitsToSend.get(oVar.Class_to_call__c).put(oVar.Whom_To_Send__c, new  list<Communication_Kit__c>());
								}

								mapWhomToSendCommKitsToSend.get(oVar.Class_to_call__c).get(oVar.Whom_To_Send__c).add(oCommKit);
							}
						}
					}
				}
			}
		}

		system.debug('<><><>mapWhomToSendCommKitsToSend ' + mapWhomToSendCommKitsToSend);

		for(string sClassName: mapWhomToSendCommKitsToSend.keySet())
		{
			if(sClassName == 'SBCCommunicationDetails')
			{
				for(string sWhomToSend: mapWhomToSendCommKitsToSend.get(sClassName).keySet())
				{
					system.debug('sWhomToSend : ' + sWhomToSend);
					SBCCommunicationDetails.sendSBCCommunicationDetails(sWhomToSend, mapWhomToSendCommKitsToSend.get(sClassName).get(sWhomToSend));
				}
			}

			if(sClassName == 'CommunicationUpdates')
			{
				for(string sWhomToSend: mapWhomToSendCommKitsToSend.get(sClassName).keySet())
				{
					CommunicationUpdates.sendCommunicationUpdates(sWhomToSend, mapWhomToSendCommKitsToSend.get(sClassName).get(sWhomToSend));
				}
			}
		}
	}


	/**
	* Method name  : createReciprocalKitOnIncomingS2B
	* Description  : This method creates a reciprocal beneficiary to supporter whenever a supporter to beneficiary kit
	is updated to proper status
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>, map<Id, Communication_Kit__c>
	**/
	private static void createReciprocalKitOnIncomingS2B(list<Communication_Kit__c> lstTriggerNew, map<Id, Communication_Kit__c> mapTriggerOld)
	{
		map<Id, Account> mapBenIdBen = new  map<Id, Account>();
		set<Id> setBenIds = new  set<Id>();
		map<Id, string> mapSuppQuestions = new  map<Id, string>();
		System.debug('>>>> lstTriggerNew : ' + lstTriggerNew);

		for(Communication_Kit__c oCommKit: lstTriggerNew)
		{
			system.debug('>>>> oCommKit.RecordTypeId ' + oCommKit.RecordTypeId);
			system.debug('>>>> sRecordTypeS2B ' + sRecordTypeS2B);
			system.debug('>>>> oCommKit.Relationship_Type__c ' + oCommKit.Relationship_Type__c);
			system.debug('>>>> Constants.COMMITMENT_TYPE_ENCOURAGER ' + Constants.COMMITMENT_TYPE_ENCOURAGER);
			system.debug('>>>> mapTriggerOld ' + mapTriggerOld);

			if(oCommKit.RecordTypeId == sRecordTypeS2B && oCommKit.Relationship_Type__c != Constants.COMMITMENT_TYPE_ENCOURAGER && (mapTriggerOld == null || mapTriggerOld.get(oCommKit.Id).Status__c != Constants.Comm_Status) && oCommKit.Status__c == Constants.Comm_Status)
			{
				setBenIds.add(oCommKit.BEN_Id__c);

				if(oCommKit.Supporter_Questions__c != null || oCommKit.Supporter_Questions__c != '')
				{
					string sCurrValue = '';

					if(mapSuppQuestions.containsKey(oCommKit.BEN_Id__c))
					{
						sCurrValue = mapSuppQuestions.get(oCommKit.BEN_Id__c);
						sCurrValue += oCommKit.Supporter_Questions__c;
					}
					else
					{
						sCurrValue = oCommKit.Supporter_Questions__c;
					}

					mapSuppQuestions.put(oCommKit.BEN_Id__c, sCurrValue);
				}
			}
		}

		System.debug('>>>> setBenIds : ' + setBenIds);
		System.debug('>>>> mapSuppQuestions : ' + mapSuppQuestions);

		mapBenIdBen = new  map<Id, Account>([SELECT
			Id, 
			Local_Beneficiary_Id__c
		FROM
			Account
		WHERE
			Id in: setBenIds]);

		map<string, string> mapLocalBenIdCommType = new  map<string, string>();
		map<string, string> mapLocalBenIdSuppQuestions = new  map<string, string>();

		for(Id iBenId: setBenIds)
		{
			mapLocalBenIdCommType.put(mapBenIdBen.get(iBenId).Local_Beneficiary_Id__c, Constants.CORRESPONDENCE_ITEM_TYPE_RECIPROCAL_LETTER);
			mapLocalBenIdSuppQuestions.put(mapBenIdBen.get(iBenId).Local_Beneficiary_Id__c, mapSuppQuestions.get(iBenId));
		}

		CommunicationKitHandler.findOrCreateCommKitRecordExt(mapLocalBenIdCommType, mapLocalBenIdSuppQuestions);
	}


	/**
	* Method name  : updateLastCommunicationDate
	* Description  : This method updates the last communication date on communication kit whenever the status
	of the communication kit is changed
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>, map<Id, Communication_Kit__c>
	**/
	private static void updateLastCommunicationDate(list<Communication_Kit__c> lstTriggerNew, map<Id, Communication_Kit__c> mapTriggerOld)
	{
		set<Id> setSupporterId = new  set<Id>();

		for(Communication_Kit__c oCommKit: lstTriggerNew)
		{
			if(oCommKit.SUP_Id__c != null)
			{
				setSupporterId.add(oCommKit.SUP_Id__c);
			}
		}

		map<Id, Account> mapSupporter = new  map<Id, Account>();

		if(!setSupporterId.IsEmpty())
		{
			mapSupporter = new  map<Id, Account>([SELECT
				Id, 
				Name, 
				Global_Partner__r.Opted_in_for_SDL__c
			FROM
				Account
			WHERE
				Id in: setSupporterId]);
		}

		for(Communication_Kit__c oCommKit: lstTriggerNew)
		{
			if((mapTriggerOld == null && oCommKit.Status__c != null) || (mapTriggerOld != null && oCommKit.Status__c != mapTriggerOld.get(oCommKit.Id).Status__c))
			{
				if((oCommKit.RecordTypeId == sRecordTypeS2B && oCommKit.Status__c == Constants.COMMUNICATION_KIT_STATUS_RECEIVEDINTHESYSTEM) || ((oCommKit.RecordTypeId == sRecordTypeB2S && oCommKit.SUP_Id__c != null && mapSupporter.containsKey(oCommKit.SUP_Id__c)) && ((!mapSupporter.get(oCommKit.SUP_Id__c).Global_Partner__r.Opted_in_for_SDL__c && oCommKit.Status__c == Constants.COMMUNICATION_KIT_STATUS_TRANSLATION_QUALITY_CHECK_COMP) || (mapSupporter.get(oCommKit.SUP_Id__c).Global_Partner__r.Opted_in_for_SDL__c && oCommKit.Status__c == Constants.COMMUNICATION_KIT_STATUS_GLOBALPARTNERTRANSLATIONALQUEUE))))
				{
					oCommKit.Communication_Date__c = system.now();
				}
			}
		}
	}


	/**
	* Method name  : updateRelationType
	* Description  : This method validates all the conditions when Relation Type is changed
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>, map<Id, Communication_Kit__c>
	**/
	private static void updateRelationType(list<Communication_Kit__c> lstTriggerNew, map<Id, Communication_Kit__c> mapTriggerOld)
	{
		list<Communication_Kit__c> lstChangeRelationshipType = new  list<Communication_Kit__c>();
		set<Id> setSupAndBenId = new  set<Id>();

		for(Communication_Kit__c oCommKit: lstTriggerNew)
		{
			if(mapTriggerOld == null || oCommKit.SUP_Id__c != mapTriggerOld.get(oCommKit.Id).SUP_Id__c || oCommKit.BEN_Id__c != mapTriggerOld.get(oCommKit.Id).BEN_Id__c || oCommKit.Relationship_Type__c != mapTriggerOld.get(oCommKit.Id).Relationship_Type__c)
			{
				lstChangeRelationshipType.add(oCommKit);
				if(oCommKit.SUP_Id__c != null)
				{
					setSupAndBenId.add(oCommKit.SUP_Id__c);
				}

				if(oCommKit.BEN_Id__c != null)
				{
					setSupAndBenId.add(oCommKit.BEN_Id__c);
				}
			}
		}

		list<Commitment__c> lstCommitment = new  list<Commitment__c>();
		lstCommitment = [SELECT
			Id, 
			BEN_Id__c, 
			SUP_Id__c, 
			Status__c, 
			Relationship_Type__c
		FROM
			Commitment__c
		WHERE
			(BEN_Id__c in: setSupAndBenId OR SUP_Id__c in: setSupAndBenId) AND Status__c = : Constants.COMMITMENT_STATUS_ACTIVE
		ORDER BY
			Relationship_Type__c];

		map<Id, map<Id, Commitment__c>> mapBenIdSupIdCommitment = new  map<Id, map<Id, Commitment__c>>();

		for(Commitment__c oCommit: lstCommitment)
		{
			if(!mapBenIdSupIdCommitment.containsKey(oCommit.BEN_Id__c))
			{
				mapBenIdSupIdCommitment.put(oCommit.BEN_Id__c, new  map<Id, Commitment__c>());
			}
			mapBenIdSupIdCommitment.get(oCommit.BEN_Id__c).put(oCommit.SUP_Id__c, oCommit);
		}

		/* MV : Wil ad comments  */
		list<Commitment__c> lstAllCommitment = new  list<Commitment__c>();
		lstAllCommitment = [SELECT
			Id, 
			End_Date__c, 
			BEN_Id__c, 
			SUP_Id__c, 
			SUP_Id__r.Global_Number__c, 
			Status__c, 
			Relationship_Type__c
		FROM
			Commitment__c
		WHERE
			(BEN_Id__c in: setSupAndBenId OR SUP_Id__c in: setSupAndBenId) AND Status__c = : Constants.COMMITMENT_STATUS_INACTIVE];

		map<Id, date> mapBenIdSupIdInactiveCommitment = new  map<Id, date>();
		map<Id, string> mapBenIdSupId = new  map<Id, string>();
		map<Id, date> mapDateToCompare = new  map<Id, date>();

		for(Commitment__c oCommit: lstAllCommitment)
		{
			if(null != oCommit.End_Date__c)
			{
				if(!mapBenIdSupIdInactiveCommitment.containsKey(oCommit.BEN_Id__c))
				{
					mapBenIdSupIdInactiveCommitment.put(oCommit.BEN_Id__c, oCommit.End_Date__c);
				}
				mapBenIdSupId.put(oCommit.BEN_Id__c, oCommit.SUP_Id__r.Global_Number__c);
			}
		}

		Map<id, AccountHistory> mapAccandHistory = new  map<id, AccountHistory>();
		Datetime dtCreatedDate;
		Map<id, Date> mapBenfInactiveDate = new  map<id, Date>();
		mapAccandHistory = new  map<id, AccountHistory>([SELECT
			AccountId, 
			createddate, 
			Field, 
			OldValue, 
			NewValue
		FROM
			AccountHistory
		WHERE
			field = 'Beneficiary_Status__c' AND AccountId in: setSupAndBenId AND (Account.Beneficiary_Status__c = : constants.DRAFT OR Account.Beneficiary_Status__c = : Constants.INACTIVE)
		ORDER BY
			createddate]);

		for(Accounthistory oAccHis: mapAccandHistory.values())
		{
			if(string.valueOf(oAccHis.NewValue) == 'Constants.INACTIVE' || string.valueOf(oAccHis.NewValue) == 'constants.DRAFT')
			{
				if(!mapBenfInactiveDate.containsKey(oAccHis.AccountId))
				{
					dtCreatedDate = oAccHis.CreatedDate;
				}

				Date datevalue = date.newinstance(dtCreatedDate.year(), dtCreatedDate.month(), dtCreatedDate.day());
				mapBenfInactiveDate.put(oAccHis.AccountId, datevalue);
			}
		}

		/* MV :END  Wil ad comments  */
		for(Communication_Kit__c oCommKit: lstChangeRelationshipType)
		{
			if(oCommKit.BEN_Id__c == null)
			{
				if(System.Label.Disable_for_Data_Load_R3 != 'true')
				{
					oCommKit.BEN_Id__c.addError(Label.Communication_Error_Message_1);
				}
			}
			else if(oCommKit.BEN_Id__c != null && oCommKit.SUP_Id__c == null)
			{
				if(oCommKit.RecordTypeId == sRecordTypeB2S)
				{
					if(System.Label.Disable_for_Data_Load_R3 != 'true')
					{
						oCommKit.SUP_Id__c.addError(Label.Communication_Error_Message_2);
					}
				}
				else if(oCommKit.RecordTypeId == sRecordTypeS2B && oCommKit.Relationship_Type__c != null && oCommKit.Relationship_Type__c != Constants.COMMITMENT_TYPE_ENCOURAGER)
				{
					if(System.Label.Disable_for_Data_Load_R3 != 'true')
					{
						oCommKit.Relationship_Type__c.addError(Label.Communication_Error_Message_3);
					}
				}
				else if(oCommKit.RecordTypeId == sRecordTypeS2B && oCommKit.Relationship_Type__c == null)
				{
					oCommKit.Relationship_Type__c = Constants.COMMITMENT_TYPE_ENCOURAGER;
				}
			}
			else if(oCommKit.BEN_Id__c != null && oCommKit.SUP_Id__c != null)
			{
				if(mapBenfInactiveDate.containsKey(oCommKit.BEN_Id__c) || mapBenIdSupIdInactiveCommitment.containsKey(oCommKit.BEN_Id__c))
				{
					if(mapBenfInactiveDate.containsKey(oCommKit.BEN_Id__c) && mapBenIdSupIdInactiveCommitment.containsKey(oCommKit.BEN_Id__c))
					{
						if(mapBenfInactiveDate.get(oCommKit.BEN_Id__c) > mapBenIdSupIdInactiveCommitment.get(oCommKit.BEN_Id__c))
						{
							mapDateToCompare.put(oCommKit.BEN_Id__c, mapBenfInactiveDate.get(oCommKit.BEN_Id__c));
						}
						else
						{
							mapDateToCompare.put(oCommKit.BEN_Id__c, mapBenIdSupIdInactiveCommitment.get(oCommKit.BEN_Id__c));
						}
					}
					else if(mapBenfInactiveDate.containsKey(oCommKit.BEN_Id__c) && !mapBenIdSupIdInactiveCommitment.containsKey(oCommKit.BEN_Id__c))
					{
						mapDateToCompare.put(oCommKit.BEN_Id__c, mapBenfInactiveDate.get(oCommKit.BEN_Id__c));
					}
					else
					{
						mapDateToCompare.put(oCommKit.BEN_Id__c, mapBenIdSupIdInactiveCommitment.get(oCommKit.BEN_Id__c));
					}
				}

				if((mapDateToCompare.containsKey(oCommKit.BEN_Id__c) && (mapDateToCompare.get(oCommKit.BEN_Id__c).daysBetween(system.today()) > 90) && oCommKit.Communication_Types__c == constants.FINAL_LETTER && (mapBenIdSupIdInactiveCommitment.containskey(oCommKit.BEN_Id__c) || mapBenfInactiveDate.containskey(oCommKit.BEN_Id__c))) && oCommKit.RecordTypeId == sRecordTypeS2B)
				{
					bUpdateError = true;
					strGlobalPartnerSBCId = string.valueof(oCommKit.Local_GP_Kit_ID__c);
					strbenid = oCommKit.BEN_Local_ID__c;
					oCommKit.BEN_Id__c.addError(Label.Communication_Error_Message_4);
				}

				if(oCommKit.Relationship_Type__c != Constants.COMMITMENT_TYPE_ENCOURAGER)
				{
					if(!mapBenIdSupIdCommitment.containsKey(oCommKit.BEN_Id__c) && ((oCommKit.Communication_Types__c != constants.FINAL_LETTER || (mapDateToCompare.containsKey(oCommKit.BEN_Id__c) && (mapDateToCompare.get(oCommKit.BEN_Id__c).daysBetween(system.today()) > 90) && oCommKit.Communication_Types__c == constants.FINAL_LETTER && (mapBenIdSupIdInactiveCommitment.containskey(oCommKit.BEN_Id__c) || mapBenfInactiveDate.containskey(oCommKit.BEN_Id__c)))) && oCommKit.RecordTypeId == sRecordTypeS2B))
					{
						if(System.Label.Disable_for_Data_Load_R3 != 'true')
						{
							oCommKit.SUP_Id__c.addError(Label.Communication_Error_Message_4);
						}
					}
					else if(!mapBenIdSupIdCommitment.containsKey(oCommKit.BEN_Id__c) && ((oCommKit.Communication_Types__c != constants.FINAL_LETTER || (oCommKit.Communication_Types__c == constants.FINAL_LETTER && (!mapBenIdSupIdInactiveCommitment.containskey(oCommKit.BEN_Id__c)))) && oCommKit.RecordTypeId == sRecordTypeS2B))
					{
						if(System.Label.Disable_for_Data_Load_R3 != 'true')
						{
							oCommKit.SUP_Id__c.addError(Label.Communication_Error_Message_4);
						}
					}
					/*  if(!mapBenIdSupIdCommitment.containsKey(oCommKit.BEN_Id__c)){
					oCommKit.SUP_Id__c.addError(
					Label.Communication_Error_Message_4
					);
					}   */
					else if(oCommKit.RecordTypeId == sRecordTypeB2S && mapBenIdSupIdCommitment.containsKey(oCommKit.BEN_Id__c) && !mapBenIdSupIdCommitment.get(oCommKit.BEN_Id__c).containsKey(oCommKit.SUP_Id__c))
					{
						if(System.Label.Disable_for_Data_Load_R3 != 'true')
						{
							oCommKit.SUP_Id__c.addError(Label.Communication_Error_Message_4);
						}
					}
					else if(oCommKit.RecordTypeId == sRecordTypeS2B && mapBenIdSupIdCommitment.containsKey(oCommKit.BEN_Id__c) && !mapBenIdSupIdCommitment.get(oCommKit.BEN_Id__c).containsKey(oCommKit.SUP_Id__c) && oCommKit.Relationship_Type__c == null)
					{
						oCommKit.Relationship_Type__c = Constants.COMMITMENT_TYPE_ENCOURAGER;
					}
					else if(oCommKit.RecordTypeId == sRecordTypeS2B && mapBenIdSupIdCommitment.containsKey(oCommKit.BEN_Id__c) && !mapBenIdSupIdCommitment.get(oCommKit.BEN_Id__c).containsKey(oCommKit.SUP_Id__c) && oCommKit.Relationship_Type__c != null && oCommKit.Relationship_Type__c != Constants.COMMITMENT_TYPE_ENCOURAGER)
					{
						if(System.Label.Disable_for_Data_Load_R3 != 'true')
						{
							oCommKit.Relationship_Type__c.addError(Label.Communication_Error_Message_6);
						}
					}
					else if(mapBenIdSupIdCommitment.containsKey(oCommKit.BEN_Id__c) && mapBenIdSupIdCommitment.get(oCommKit.BEN_Id__c).containsKey(oCommKit.SUP_Id__c) && oCommKit.Relationship_Type__c != null && mapBenIdSupIdCommitment.get(oCommKit.BEN_Id__c).get(oCommKit.SUP_Id__c).Relationship_Type__c != oCommKit.Relationship_Type__c)
					{
						if(System.Label.Disable_for_Data_Load_R3 != 'true')
						{
							oCommKit.Relationship_Type__c.addError(Label.Communication_Error_Message_7 + mapBenIdSupIdCommitment.get(oCommKit.BEN_Id__c).get(oCommKit.SUP_Id__c).Relationship_Type__c + '"');
						}
					}
					else if(mapBenIdSupIdCommitment.containsKey(oCommKit.BEN_Id__c) && mapBenIdSupIdCommitment.get(oCommKit.BEN_Id__c).containsKey(oCommKit.SUP_Id__c) && oCommKit.Relationship_Type__c == null)
					{
						oCommKit.Relationship_Type__c = mapBenIdSupIdCommitment.get(oCommKit.BEN_Id__c).get(oCommKit.SUP_Id__c).Relationship_Type__c;
					}
				}
			}
		}
	}


	/**
	* Method name  : sendCommKitToCompass
	* Description  : This method is used to initiate the Communication Stub creation call to create
	communication kit in compass
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>, map<Id, Communication_Kit__c>
	**/
	/*private static void sendCommKitToCompass(list<Communication_Kit__c>
	lstTriggerNew, map<Id, Communication_Kit__c> mapTriggerOld) {
	set<Id> setSupporters = new set<Id>();
	map<Id, Account> mapSupporters = new map<Id, Account>();
	list<Communication_Kit__c> lstCommKitToSend = new list <
	Communication_Kit__c>();
	for (Communication_Kit__c oCommKit: lstTriggerNew) {
	if (oCommKit.RecordTypeId == sRecordTypeS2B && oCommKit.SUP_Id__c != null)
	setSupporters.add(oCommKit.SUP_Id__c);
	}
	mapSupporters = new map<Id, Account> ([Select Id, Name, Global_Partner__r.Opted_in_for_SDL__c
	from Account where Id IN: setSupporters
	]);
	for (Communication_Kit__c oCommKit: lstTriggerNew) {
	if (mapTriggerOld == null || oCommKit.Status__c != mapTriggerOld.get(
	oCommKit.Id).Status__c) {
	if ((oCommKit.RecordTypeId == sRecordTypeB2S && oCommKit.Status__c ==
	Constants.COMMUNICATION_KIT_STATUS_RECEIVEDINTHESYSTEM) || (oCommKit.RecordTypeId ==
	sRecordTypeS2B && oCommKit.SUP_Id__c != null && ((mapSupporters.get(
	oCommKit.SUP_Id__c).Global_Partner__r.Opted_in_for_SDL__c && oCommKit
	.Status__c == Constants.COMMUNICATION_KIT_STATUS_GLOBALPARTNERTRANSLATIONALQUEUE
	) || (!mapSupporters.get(oCommKit.SUP_Id__c).Global_Partner__r.Opted_in_for_SDL__c &&
	oCommKit.Status__c == Constants.COMMUNICATION_KIT_STATUS_PUBLISHEDTOGP
	)))) {
	lstCommKitToSend.add(oCommKit);
	}
	}
	}
	//if (!lstCommKitToSend.IsEmpty())
	//CommunicationStubCreation.sendCommunicationStubCreation(lstCommKitToSend);
	}*/


	/**
	* Method name  : updateStatus
	* Description  : This method updates the status of the communication based on the new communication status
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>
	**/
	private static void updateStatus(list<Communication_Kit__c> lstTriggerNew)
	{
		list<Communication_Kit__c> lstToUpdate = new  list<Communication_Kit__c>();

		for(Communication_Kit__c oCommKit: lstTriggerNew)
		{
			if(oCommKit.INT_New_Status__c != null && oCommKit.INT_New_Status__c != '')
			{
				//oCommKit.Status__c = oCommKit.INT_New_Status__c;
				//oCommKit.INT_New_Status__c = '';
				lstToUpdate.add(new  Communication_Kit__c(Id = oCommKit.Id, Status__c = oCommKit.INT_New_Status__c, INT_New_Status__c = ''));
			}
		}

		if(lstToUpdate.size() > 0)
		{
			// updates happen later on so that we have a track of what status came in and what did it change to
			List<Database.SaveResult> lstUpdateResults = Database.update(lstToUpdate, false);
			Map<Id, List<string>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(lstUpdateResults, lstToUpdate, 'Communnication_Kit__c', Constants.CLASS_COMMUNICATION_KIT_HANDLER, 'execute', 'SFDC-CI', false);
		}
	}


	/**
	* Method name  : checkPrintAllowedDate
	* Description  : This method populates Print Allowed Date for B2S Kits if it is not populated
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>
	**/
	private static void checkPrintAllowedDate(list<Communication_Kit__c> lstTriggerNew)
	{
		set<Id> setBenIds = new  set<Id>();

		for(Communication_Kit__c oCommKit: lstTriggerNew)
		{
			if(oCommKit.RecordTypeId == CommunicationKitHandler.sRecordTypeB2S && oCommKit.Print_Allowed_Date__c == null)
			{
				setBenIds.add(oCommKit.BEN_ID__c);
			}
		}

		map<Id, Account> mapBen = new  map<Id, Account>([SELECT
			Id, 
			BEN_Next_Allowed_Writing_Date__c
		FROM
			Account
		WHERE
			Id in: setBenIds]);

		for(Communication_Kit__c oCommKit: lstTriggerNew)
		{
			if(mapBen != null && mapBen.containskey(oCommKit.BEN_ID__c))
			{
				if(mapBen.get(oCommKit.BEN_ID__c).BEN_Next_Allowed_Writing_Date__c != null && mapBen.get(oCommKit.BEN_ID__c).BEN_Next_Allowed_Writing_Date__c >= system.today())
				{
					oCommKit.Print_Allowed_Date__c = mapBen.get(oCommKit.BEN_ID__c).BEN_Next_Allowed_Writing_Date__c;
				}
				else
				{
					oCommKit.Print_Allowed_Date__c = system.today();
				}
			}
		}
	}


	/**
	* Method name  : updateBenLastWroteDate
	* Description  : This method will update the communication's beneficiary's last wrote
	date based on the parameters passed
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>, map<id, Communication_Kit__c>
	**/
	private static void updateBenLastWroteDate(list<Communication_Kit__c> triggerNew, map<id, Communication_Kit__c> mapTriggerOld)
	{
		Set<Id> setOfAccIds = new  Set<Id>();

		for(Communication_Kit__c oCurrRec: triggerNew)
		{
			if(oCurrRec.RecordTypeId == CommunicationKitHandler.sRecordTypeB2S && oCurrRec.Status__c == Constants.COMMUNICATION_KIT_STATUS_RECEIVEDINTHESYSTEM && (mapTriggerOld == null || (mapTriggerOld != null && mapTriggerOld.get(oCurrRec.id).Status__c != Constants.COMMUNICATION_KIT_STATUS_RECEIVEDINTHESYSTEM)) && !string.isEmpty(oCurrRec.Communication_Types__c) && oCurrRec.Communication_Types__c.contains(Constants.COMMUNICATION_TYPE_BENEFICIARY_INITIATED))
			{
				setOfAccIds.add(oCurrRec.BEN_ID__c);
			}
		}

		List<Account> lstOfAccs = [SELECT
			id, 
			BEN_Last_Wrote__c
		FROM
			Account
		WHERE
			id in: setOfAccIds];

		for(Account oAcc: lstOfAccs)
		{
			oAcc.BEN_Last_Wrote__c = System.Today();
		}

		List<Database.SaveResult> lstUpdateResults = new  List<Database.SaveResult>();

		if(lstOfAccs.size() > 0)
		{
			lstUpdateResults = Database.update(lstOfAccs, false);
			Map<Id, List<string>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(lstUpdateResults, lstOfAccs, 'Account', Constants.CLASS_COMMUNICATION_KIT_HANDLER, 'updateBenLastWroteDate', 'SFDC CI', false);
		}
	}


	/**
	* Method name  : updateS2BKitStatus
	* Description  : This method will update the S2B communication's status
	based on the parameters passed
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>
	**/
	private static void updateS2BKitStatus(list<Communication_Kit__c> triggerNew)
	{
		for(Communication_Kit__c oCommKit: triggerNew)
		{
			if(oCommKit.RecordTypeId == CommunicationKitHandler.sRecordTypeS2B && oCommKit.Status__c == Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED)
			{
				oCommKit.Status__c = Constants.Comm_Status;
				oCommKit.Print_Allowed_Date__c = System.Today();
				oCommKit.Print_Date__c = System.Today();
			}

			system.debug('***********8entered the updates2bkit' + oCommKit);

			if(oCommKit.RecordTypeId == CommunicationKitHandler.sRecordTypeS2B && oCommKit.Status__c == Constants.COMMUNICATION_KIT_STATUS_RECEIVEDINTHESYSTEM && oCommKit.Template_ID__c == null)
			{
				oCommKit.Template_ID__c = oCommKit.Global_Partner_ID__c + Constants.CommKit_TemplateId;
			}
		}
	}


	/**
	* Method name  : settingB2SKitStatus
	* Description  : This method will update the B2S communications status
	based on the parameters passed
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>
	**/
	private static void settingB2SKitStatus(list<Communication_Kit__c> triggerNew)
	{
		set<Id> setAccountId = new  set<Id>();

		for(Communication_Kit__c oCommKit: triggerNew)
		{
			if(oCommKit.RecordTypeId == CommunicationKitHandler.sRecordTypeB2S && oCommKit.Status__c == Constants.COMMUNICATION_KIT_STATUS_RECEIVEDINTHESYSTEM)
			{
				oCommKit.Received_at_FO__c = system.today();
				setAccountId.add(oCommKit.BEN_ID__c);
				setAccountId.add(oCommKit.SUP_ID__c);
			}
		}

		list<Commitment__c> lstCommitment = new  list<Commitment__c>();

		lstCommitment = [SELECT
			Id, 
			Supporter_Correspondence_Language__c, 
			BEN_ID__r.Correspondence_Language__c, 
			SUP_ID__c, 
			BEN_ID__c
		FROM
			Commitment__c
		WHERE
			SUP_ID__c in: setAccountId OR BEN_ID__c in: setAccountId];

		map<Id, map<Id, Commitment__c>> mapBenIdSupIdLang = new  map<Id, map<Id, Commitment__c>>();

		for(Commitment__c oCommit: lstCommitment)
		{
			if(!mapBenIdSupIdLang.containsKey(oCommit.BEN_ID__c))
			{
				mapBenIdSupIdLang.put(oCommit.BEN_ID__c, new  map<Id, Commitment__c>());
			}
			mapBenIdSupIdLang.get(oCommit.BEN_ID__c).put(oCommit.SUP_ID__c, oCommit);
		}

		Map<Id, Account> mapOfAccsToUpdate = new  Map<Id, Account>();

		/*for(Communication_Kit__c oCommKit: triggerNew)
		{
		if(oCommKit.RecordTypeId == CommunicationKitHandler.sRecordTypeB2S && oCommKit.Status__c == Constants.COMMUNICATION_KIT_STATUS_RECEIVEDINTHESYSTEM)
		{
		if(mapBenIdSupIdLang.containsKey(oCommKit.BEN_ID__c) && mapBenIdSupIdLang.get(oCommKit.BEN_ID__c).containsKey(oCommKit.SUP_ID__c)){
		if(mapBenIdSupIdLang.get(oCommKit.BEN_ID__c).get(oCommKit.SUP_ID__c).Supporter_Correspondence_Language__c ==
		mapBenIdSupIdLang.get(oCommKit.BEN_ID__c).get(oCommKit.SUP_ID__c).BEN_ID__r.Correspondence_Language__c)
		oCommKit.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_QUALITY_CHECK_QUEUE;
		else if (mapBenIdSupIdLang.get(oCommKit.BEN_ID__c).get(oCommKit.SUP_ID__c).BEN_ID__r.Correspondence_Language__c == Constants.COMMITMENT_CORRESPONDENCE_LANGUAGE
		)
		oCommKit.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_QUALITY_CHECK_QUEUE;
		else
		oCommKit.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_FIELD_OFFICE_TRANSLATION_QUEUE;
		
		}
		}
		}*/
	}


	/**
	* Method name  : updateSupporterCorrespondenceLang
	* Description  : This method will update the Supporter Correspondence
	language field of the Communication record
	based on the parameters passed
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>
	**/
	private static void updateSupporterCorrespondenceLang(list<Communication_Kit__c> triggerNew)
	{
		set<Id> setBenIds = new  set<Id>();
		set<Id> setSupIds = new  set<Id>();

		for(Communication_Kit__c oCommKit: triggerNew)
		{
			if(oCommKit.Relationship_Type__c == Constants.COMMITMENT_TYPE_SPONSORSHIP || oCommKit.Relationship_Type__c == Constants.COMMITMENT_TYPE_CORRESPONDENT)
			{
				setBenIds.add(oCommKit.BEN_ID__c);
				setSupIds.add(oCommKit.SUP_ID__c);
			}
		}

		list<Commitment__c> lstCommitment = new  list<Commitment__c>();
		lstCommitment = [SELECT
			Id, 
			Relationship_Type__c, 
			BEN_ID__c, 
			SUP_ID__c, 
			Supporter_Correspondence_Language__c
		FROM
			Commitment__c
		WHERE
			BEN_ID__c in: setBenIds OR SUP_ID__c in: setSupIds];

		map<Id, map<Id, Commitment__c>> mapCommitment = new  map<Id, map<Id, Commitment__c>>();

		for(Commitment__c oCommit: lstCommitment)
		{
			if(!mapCommitment.containsKey(oCommit.BEN_ID__c))
			{
				mapCommitment.put(oCommit.BEN_ID__c, new  map<Id, Commitment__c>());
			}

			if(!mapCommitment.get(oCommit.BEN_ID__c).containsKey(oCommit.SUP_ID__c))
			{
				mapCommitment.get(oCommit.BEN_ID__c).put(oCommit.SUP_ID__c, oCommit);
			}
		}

		for(Communication_Kit__c oCommKit: triggerNew)
		{
			if(mapCommitment.containsKey(oCommKit.BEN_ID__c) && mapCommitment.get(oCommKit.BEN_ID__c).containsKey(oCommKit.SUP_ID__c))
			{
				if(oCommKit.RecordTypeId == sRecordTypeB2S || (oCommKit.RecordTypeId == sRecordTypeS2B && (null == oCommKit.INT_Supporter_Correspondence_Language__c)))
				{
					oCommKit.INT_Supporter_Correspondence_Language__c = mapCommitment.get(oCommKit.BEN_ID__c).get(oCommKit.SUP_ID__c).Supporter_Correspondence_Language__c;
				}
			}
		}
	}


	/**
	* Method name  : updateNumberOfPages
	* Description  : This method will update the Number of pages field of
	the B2S Communication record based on the parameters passed
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>
	**/
	private static void updateNumberOfPages(list<Communication_Kit__c> triggerNew)
	{
		for(Communication_Kit__c oCommKit: triggerNew)
		{
			if(oCommKit.RecordTypeId == sRecordTypeB2S)
			{
				if(oCommKit.Number_Of_Pages__c == 0 || oCommKit.Number_Of_Pages__c == null)
				{
					oCommKit.Number_Of_Pages__c = 2;
				}
			}
		}
	}


	/**
	* Method name  : updateLetterStatus
	* Description  : This method will update the status field of
	the B2S Communication record if translation
	from SDL is unsuccessfull
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>
	**/
	private static void updateLetterStatus(map<id, Communication_Kit__c> mapTriggerNew, map<id, Communication_Kit__c> mapTriggerOld)
	{
		list<Communication_Kit__c> lstToUpdate = new  list<Communication_Kit__c>();
		set<Id> setCommIds = new  set<id>();

		for(Communication_Kit__c oCurrRec: mapTriggerNew.values())
		{
			if(oCurrRec.RecordTypeId == CommunicationKitHandler.sRecordTypeB2S && oCurrRec.Status__c == Constants.COMMUNICATION_KIT_STATUS_QUALITY_CHECK_UNSUCCESSFUL && mapTriggerOld.get(oCurrRec.id).Status__c != Constants.COMMUNICATION_KIT_STATUS_QUALITY_CHECK_UNSUCCESSFUL)
			{
				setCommIds.add(oCurrRec.id);
			}
		}

		lstToUpdate = [SELECT
			id, 
			Status__c
		FROM
			Communication_Kit__c
		WHERE
			id in: setCommIds];

		for(Communication_Kit__c oCk: lstToUpdate)
		{
			oCk.Status__c = Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED;
		}

		if(lstToUpdate.size() > 0)
		{
			// updates happen later on so that we have a track of what status came in and what did it change to
			List<Database.SaveResult> lstUpdateResults = Database.update(lstToUpdate, false);
			Map<Id, List<string>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(lstUpdateResults, lstToUpdate, 'Communnication_Kit__c', Constants.CLASS_COMMUNICATION_KIT_HANDLER, 'updateLetterStatus', 'SFDC-CI', false);
		}
	}


	/**
	* Method name  : preventINTSupporterUpdate
	* Description  : This is to ensure that Supporter Correnpondence Lang do not get updated
	* Return Type  : void
	* Parameter    : list<Communication_Kit__c>, map<Id, Communication_Kit__c>
	**/
	private static void preventINTSupporterUpdate(list<Communication_Kit__c> lstTriggerNew, map<Id, Communication_Kit__c> mapTriggerOld)
	{
		for(Communication_Kit__c oCommKit: lstTriggerNew)
		{
			oCommKit.INT_Supporter_Correspondence_Language__c = mapTriggerOld.get(oCommKit.Id).INT_Supporter_Correspondence_Language__c;
		}
	}


	/******************INTEGRATION RELATED CODE SNIPPETS
	PLEASE ADD ALL THE METHODS ABOVE THIS**************************/
	/**
	* Method name  : responseForValidationWrapper
	* Description  : Wrapper class to send response back to integration classes
	**/
	public class responseForValidationWrapper
	{
		public boolean bError;
		public string sValue;
		public list<sObject> lstSObject;
		public Exception oEx;

		// For Beneficiary and Supporter Validation responses
		public responseForValidationWrapper(boolean bErrorReceived, string sValueReceived)
		{
			bError = bErrorReceived;
			sValue = sValueReceived;
		}

		//For deserializing the incoming jsons
		public responseForValidationWrapper(boolean bErrorReceived, list<sObject> lstSObjectReceived, Exception oExReceived)
		{
			bError = bErrorReceived;
			lstSObject = lstSObjectReceived;
			oEx = oExReceived;
		}
	}


	/**
	* Method name  : deserializeJson
	* Description  : This method deserializes the input JSON
	* Return Type  : responseForValidationWrapper
	* Parameter    : String, Boolean, String
	**/
	public static responseForValidationWrapper deserializeJson(string sInboundJson, Boolean bIsThereCommunicationTypes, string sProcessName)
	{
		// Handling boolean and null values in the incoming JSON 
		sInboundJson = sInboundJson.replace(Constants.SPECIAL_TRUE_WITHOUT_QUOTES, Constants.SPECIAL_TRUE_WITH_QUOTES);
		sInboundJson = sInboundJson.replace(Constants.SPECIAL_SPACE_TRUE_WITHOUT_QUOTES, Constants.SPECIAL_SPACE_TRUE_WITH_QUOTES);
		sInboundJson = sInboundJson.replace(Constants.SPECIAL_FALSE_WITHOUT_QUOTES, Constants.SPECIAL_FALSE_WITH_QUOTES);
		sInboundJson = sInboundJson.replace(Constants.SPECIAL_SPACE_FALSE_WITHOUT_QUOTES, Constants.SPECIAL_SPACE_FALSE_WITH_QUOTES);

		if(bIsThereCommunicationTypes)
		{
			// Handling Communoication Type in incoming JSON
			system.debug('<><><> sInboundJson ' + sInboundJson);
			list<string> lstTempRequest = new  list<string>();
			lstTempRequest = sInboundJson.split(Constants.SBC_TYPE_NAME);
			sInboundJson = '';

			for(Integer i = 0; i < lstTempRequest.size(); i++)
			{
				if(i == 0)
				{
					sInboundJson = lstTempRequest[i];
				}
				else
				{
					sInboundJson += Constants.SBC_TYPE_NAME + '"';
					string sTempString = lstTempRequest[i].substringAfter('[').substringBefore(']');
					sTempString = sTempString.replace('"', '');
					list<string> lstTempString = new  list<string>();
					lstTempString = sTempString.split(',');
					for(string sVar: lstTempString)
					{
						sInboundJson += sVar.trim() + ';';
					}
					sInboundJson = sInboundJson.subStringBeforeLast(';');
					sInboundJson += '"' + lstTempRequest[i].substringAfter(']');
				}
			}
		}

		// Removing enter statements
		sInboundJson = sInboundJson.replace('\\n', '');
		sInboundJson = sInboundJson.replace('\\r', '');
		sInboundJson = sInboundJson.replace('\\t', '');

		//Deserializing the JSON
		list<SObject> lstSObject = null;

		try
		{
			lstSObject = (list<SObject>)JSONHandlerMethods.deserialize(sInboundJson, sProcessName);
		}
		catch(Exception oEx)
		{
			return new  responseForValidationWrapper(true, null, oEx);
		}

		return new  responseForValidationWrapper(false, lstSObject, null);
	}


	/**
	* Method name  : BeneficiaryValidationForIntegrations
	* Description  : This method validates if proper beneficiary details were sent or not
	* Return Type  : responseForValidationWrapper
	* Parameter    : String, String, String, Map
	**/
	public static responseForValidationWrapper BeneficiaryValidationForIntegrations(string sBenGlobalId, string sBenLegacyId, string sBenLocalId, map<string, map<string, Account>> mapAccount)
	{
		// Ben Ids Validation
		// BENEFICIARY VALIDATIONS
		// For the Legacy, Global and Local Beneficiary Id passed, checingk if they were valid or not
		//For Legacy Id
		if(sBenLegacyId != null && mapAccount.containsKey(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID) && !mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).containsKey(sBenLegacyId))
		{
			return new  responseForValidationWrapper(true, Constants.ErrorString_8_INVALID + Constants.ErrorString_11_LEGACY_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenLegacyId);
		}
		//For Global Beneficiary Id
		else if(sBenGlobalId != null && mapAccount.containsKey(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID) && !mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID).containsKey(sBenGlobalId))
		{
			return new  responseForValidationWrapper(true, Constants.ErrorString_8_INVALID + Constants.ErrorString_12_GLOBAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenGlobalId);
		}
		//For Local Beneficiary Id
		/* MV-Start : Included logic to handle transferred Beneficiaries */
		else if(sBenLocalId != null && ((mapAccount.containsKey(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID) && !(mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).containsKey(sBenLocalId))) && (mapAccount.containsKey(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID) && !(mapAccount.get(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID).containsKey(sBenLocalId)))))
		{
			return new  responseForValidationWrapper(true, Constants.ErrorString_8_INVALID + Constants.ErrorString_13_LOCAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenLocalId);
		}
		// Legacy Id, Global Id and Local Beneficiary id, all were passed
		/* MV-Start : Included logic to handle transferred Beneficiaries */
		else if(sBenLegacyId != null && sBenLegacyId != '' && sBenGlobalId != null && sBenGlobalId != '' && sBenLocalId != null && sBenLocalId != '')
		{
			if(mapAccount.containsKey(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID) && mapAccount.containsKey(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID) && mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).get(sBenLegacyId).Id == mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID).get(sBenGlobalId).Id && (((mapAccount.containsKey(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID) && mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).containskey(sBenLocalId)) && mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).get(sBenLegacyId).Id == mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).get(sBenLocalId).Id) || ((mapAccount.containsKey(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID) && mapAccount.get(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID).containskey(sBenLocalId)) && mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).get(sBenLegacyId).Id == mapAccount.get(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID).get(sBenLocalId).Id)) && (((mapAccount.containsKey(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID) && mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).containskey(sBenLocalId)) && mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID).get(sBenGlobalId).Id == mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).get(sBenLocalId).Id) || ((mapAccount.containsKey(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID) && mapAccount.get(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID).containskey(sBenLocalId)) && mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID).get(sBenGlobalId).Id == mapAccount.get(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID).get(sBenLocalId).Id)))
			{
				// All good to move ahead
				return new  responseForValidationWrapper(false, mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).get(sBenLegacyId).Id);
			}
			else
			{
				return new  responseForValidationWrapper(true, Constants.ErrorString_11_LEGACY_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenLegacyId + Constants.ErrorString_15_COMMA + Constants.ErrorString_12_GLOBAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenGlobalId + Constants.ErrorString_17_AND + Constants.ErrorString_13_LOCAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenLocalId + Constants.ErrorString_14);
			}
		}
		// From three, any two of the beneficiary ids are passed 
		// 1. Compass Id and Global Beneficiary Id are passed
		else if((sBenLegacyId != null && sBenLegacyId != '') && (sBenGlobalId != null && sBenGlobalId != ''))
		{
			if(mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).get(sBenLegacyId).Id == mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID).get(sBenGlobalId).Id)
			{
				// All good to move ahead
				return new  responseForValidationWrapper(false, mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).get(sBenLegacyId).Id);
			}
			else
			{
				return new  responseForValidationWrapper(true, Constants.ErrorString_11_LEGACY_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenLegacyId + Constants.ErrorString_17_AND + Constants.ErrorString_12_GLOBAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenGlobalId + Constants.ErrorString_14);
			}
		}
		// 2. Compass Id and Local Beneficiary Id are passed
		/* MV-Start : Included logic to handle transferred Beneficiaries */
		else if((sBenLegacyId != null && sBenLegacyId != '') && (sBenLocalId != null && sBenLocalId != ''))
		{
			if(((mapAccount.containsKey(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID) && mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).containskey(sBenLocalId)) && mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).get(sBenLegacyId).Id == mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).get(sBenLocalId).Id) || ((mapAccount.containsKey(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID) && mapAccount.get(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID).containskey(sBenLocalId)) && mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).get(sBenLegacyId).Id == mapAccount.get(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID).get(sBenLocalId).Id))
			{
				// All good to move ahead
				return new  responseForValidationWrapper(false, mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).get(sBenLegacyId).Id);
			}
			else
			{
				return new  responseForValidationWrapper(true, Constants.ErrorString_11_LEGACY_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenLegacyId + Constants.ErrorString_17_AND + Constants.ErrorString_13_LOCAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenLocalId + Constants.ErrorString_14);
			}
		}
		// 3. Global Beneficiary Id and Local Beneficiary Id are passed
		/* MV-Start : Included logic to handle transferred Beneficiaries */
		else if((sBenGlobalId != null && sBenGlobalId != '') && (sBenLocalId != null && sBenLocalId != ''))
		{
			if(((mapAccount.containsKey(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID) && mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).containskey(sBenLocalId)) && mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID).get(sBenGlobalId).Id == mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).get(sBenLocalId).Id) || ((mapAccount.containsKey(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID) && mapAccount.get(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID).containskey(sBenLocalId)) && mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID).get(sBenGlobalId).Id == mapAccount.get(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID).get(sBenLocalId).Id))
			{
				// All good to move ahead
				return new  responseForValidationWrapper(false, mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID).get(sBenGlobalId).Id);
			}
			else
			{
				return new  responseForValidationWrapper(true, Constants.ErrorString_12_GLOBAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenGlobalId + Constants.ErrorString_17_AND + Constants.ErrorString_13_LOCAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenLocalId + Constants.ErrorString_14);
			}
		}
		// From three, only one id is passed
		// 1. Only Compass Id is passed
		else if(sBenLegacyId != null && sBenLegacyId != '')
		{
			// All good to move ahead
			return new  responseForValidationWrapper(false, mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).get(sBenLegacyId).Id);
		}
		// 2. Only Global Beneficiary Id is passed
		else if(sBenGlobalId != null && sBenGlobalId != '')
		{
			// All good to move ahead
			return new  responseForValidationWrapper(false, mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID).get(sBenGlobalId).Id);
		}
		// 3. Only Local Beneficiary Id is passed
		/* MV-Start : Included logic to avoid null pointer exception */
		else if(sBenLocalId != null && sBenLocalId != '')
		{
			if(mapAccount.containsKey(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID) && (mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).containsKey(sBenLocalId)))
			{
				// All good to move ahead
				return new  responseForValidationWrapper(false, mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).get(sBenLocalId).Id);
			}
			else
			{
				return new  responseForValidationWrapper(true, Constants.ErrorString_8_INVALID + Constants.ErrorString_13_LOCAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + sBenLocalId);
			}
		}
		// No beneficiary id is passed
		else
		{
			return new  responseForValidationWrapper(true, Constants.ErrorString_11_LEGACY_BENEFICIARY_ID + Constants.ErrorString_11_LEGACY_BENEFICIARY_ID + Constants.ErrorString_12_GLOBAL_BENEFICIARY_ID + Constants.ErrorString_17_AND + Constants.ErrorString_13_LOCAL_BENEFICIARY_ID + Constants.ErrorString_18_ALL + Constants.ErrorString_1);
		}
	}


	/**
	* Method name  : SupporterValidationForIntegrations
	* Description  : This method validates if proper supporter details were sent or not
	* Return Type  : responseForValidationWrapper
	* Parameter    : String, String, String, Map
	**/
	public static responseForValidationWrapper SupporterValidationForIntegrations(string sSupGlobalId, string sSupLegacyId, string sRelationshipType, map<string, map<string, Account>> mapAccount)
	{
		// SUPPORTER VALIDATIONS
		// For the legacy and Global Id passed, checking if they are valid or not
		if(sSupLegacyId != null && sSupLegacyId != '' && mapAccount.containsKey(Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID) && !mapAccount.get(Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID).containsKey(sSupLegacyId))
		{
			return new  responseForValidationWrapper(true, Constants.ErrorString_8_INVALID + Constants.ErrorString_20_LEGACY_SUPPORTER_ID + Constants.ErrorString_19_HYPHEN + sSupLegacyId);
		}
		// For Global Id
		else if(sSupGlobalId != null && sSupGlobalId != '' && mapAccount.containsKey(Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID) && !mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID).containsKey(sSupGlobalId))
		{
			return new  responseForValidationWrapper(true, Constants.ErrorString_8_INVALID + Constants.ErrorString_21_GLOBAL_SUPPORTER_ID + Constants.ErrorString_19_HYPHEN + sSupGlobalId);
		}
		// Legacy and Global Id, both were passed
		else if(sSupLegacyId != null && sSupLegacyId != '' && sSupGlobalId != null && sSupGlobalId != '')
		{
			if(mapAccount.containsKey(Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID) && mapAccount.containsKey(Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID) && mapAccount.get(Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID).get(sSupLegacyId).Id == mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID).get(sSupGlobalId).Id)
			{
				// ALl good to move ahead
				return new  responseForValidationWrapper(false, mapAccount.get(Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID).get(sSupLegacyId).Id);
			}
			else
			{
				return new  responseForValidationWrapper(true, Constants.ErrorString_20_LEGACY_SUPPORTER_ID + Constants.ErrorString_19_HYPHEN + sSupLegacyId + Constants.ErrorString_17_AND + Constants.ErrorString_21_GLOBAL_SUPPORTER_ID + Constants.ErrorString_19_HYPHEN + sSupGlobalId + Constants.ErrorString_14);
			}
		}
		// Only one of the supporter id is passed
		// Legacy Supporter Id is passed
		else if(sSupLegacyId != null && sSupLegacyId != '')
		{
			// ALl good to move alhead
			return new  responseForValidationWrapper(false, mapAccount.get(Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID).get(sSupLegacyId).Id);
		}
		// Global Id is passed
		else if(sSupGlobalId != null && sSupGlobalId != '')
		{
			// All good to move ahead
			return new  responseForValidationWrapper(false, mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID).get(sSupGlobalId).Id);
		}
		//When no Supporter Id is passed and only beneficiary id is passed - exception scenarios
		else
		{
			return new  responseForValidationWrapper(false, null);
		}
	}
}