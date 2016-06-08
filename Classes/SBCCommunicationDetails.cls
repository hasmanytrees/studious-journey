/******************************************************************************************************
Class Name         : SBCCommunicationDetails
Description        : This is the class that recieves list of Communication kits
and it returns all the communication kits along with its
attachments to the GPs or SDL based on the parameter passed.
Created By         : Rahul Agarwal
Created On         : 14-Jul-2015
******************************************************************************************************/
@RestResource (urlMapping = '/SBCCommunicationDetails' )
global class SBCCommunicationDetails
{
	/**
	* Method name  : sendSBCCommunicationDetails
	* Description  : This method will bind the communication kits along with the attachments in JSON
	* Return Type  : void
	* Parameter    : Boolean, Set<Id>
	**/
	@HttpPost
	global static void reqSBCCommunicationDetails()
	{
		RestRequest request = RestContext.request;
		RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
		string sRequest = request.requestBody.toString().trim();
		
        // Deserealizing the JSON
		list<Communication_Kit__c> lstCommKitFromJSON = new  list<Communication_Kit__c>();
		
        CommunicationKitHandler.responseForValidationWrapper oDesJSON = CommunicationKitHandler.deserializeJson(sRequest, true, Constants.SBCCOMMUNICATIONDETAILS_REQ_PN);
		
        system.debug('<><><> ' + oDesJSON);
		
        if(oDesJSON.bError)
		{
			populateInternalServerIntegrationError(oDesJSON.oEx, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, null);
			return;
		}
		else
		{
			lstCommKitFromJSON = (list<Communication_Kit__c>)oDesJSON.lstSObject;
		}
		
        ///lstCommKitFromJSON = (list<Communication_Kit__c> ) lstSObject;
		List<Account> lstOfSupporters = new  List<Account>();
		
        // Querying the record types
		list<RecordType> lstRecordTypes = new  list<RecordType>();
		lstRecordTypes = [SELECT
			Id, 
			Name, 
			DeveloperName
		FROM
			RecordType
		WHERE
			SObjectType = : Constants.COMMUNICATION_KIT_API_NAME];

		map<string, RecordType> mapRecordType = new  map<string, RecordType>();
		
        for(RecordType oRT: lstRecordTypes)
		{
			mapRecordType.put(oRT.DeveloperName.toUpperCase(), oRT);
			// Finding which Communication Kits needs to be updated; finding their beneficiaries and supporters
		}
		
        set<string> setCommunicationKitIds = new  set<string>();
		set<string> setBenGlobalId = new  set<string>();
		set<string> setBenLocalId = new  set<string>();
		set<string> setSupLegacyId = new  set<string>();
		set<string> setSupGlobalId = new  set<string>();
		set<string> setBenLegacyId = new  set<string>();
		set<string> setGPSBCId = new  set<string>();
		set<ID> setCommId = new  set<ID>();
		
        Map<id, Communication_Kit__c> mapIdToCommlst = new  Map<id, Communication_Kit__c>();
		map<id, string> mapErrorMessage = new  map<Id, string>();
		
        for(Communication_Kit__c oCommKit: lstCommKitFromJSON)
		{
			if(oCommKit.INT_Communication_Kit_Id__c != null)
			{
				setCommunicationKitIds.add(oCommKit.INT_Communication_Kit_Id__c);
			}
			if(oCommKit.BEN_INT_Id__c != null)
			{
				setBenGlobalId.add(oCommKit.BEN_INT_Id__c);
			}
			if(oCommKit.BEN_INT_Local_Id__c != null)
			{
				setBenLocalId.add(oCommKit.BEN_INT_Local_Id__c);
			}
			if(oCommKit.COMPASS_con_pk__c != null)
			{
				setSupLegacyId.add(oCommKit.COMPASS_con_pk__c);
			}
			if(oCommKit.SUP_INT_Id__c != null)
			{
				setSupGlobalId.add(oCommKit.SUP_INT_Id__c);
			}
			if(oCommKit.COMPASS_child_id__c != null)
			{
				setBenLegacyId.add(oCommKit.COMPASS_child_id__c);
			}
			if(oCommKit.Local_GP_Kit_ID__c != null)
			{
				setGPSBCId.add(oCommKit.Local_GP_Kit_ID__c);
			}
		}
		
        // Querying all supporters and beneficiaries
		map<Id, Account> mapAllBenAndSup = new  map<Id, Account>();
		mapAllBenAndSup = new  map<Id, Account>([SELECT
			Id, 
			RecordTypeId, 
			Global_Number__c, 
			Local_Beneficiary_Id__c, 
			GP_Supporter_Id__c, 
			BEN_INT_Have_Correspondent__c, 
			Compass_Id__c
		FROM
			Account
		WHERE
			Global_Number__c in: setSupGlobalId OR Global_Number__c in: setBenGlobalId OR Local_Beneficiary_Id__c in: setBenLocalId OR GP_Supporter_Id__c in: setSupLegacyId OR Compass_Id__c in: setBenLegacyId]);
		
        // Arranging all supporters and beneficiaries
		map<string, map<string, Account>> mapAccount = new map<string, map<string, Account>>{
			Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID => new  map<string, Account>(), 
			Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID => new  map<string, Account>(), 
			Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID => new  map<string, Account>(), 
			Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID => new  map<string, Account>(), 
			Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID => new  map<string, Account>(), 
			Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID => new  map<string, Account>()};
		
        for(Account oAcc: mapAllBenAndSup.Values())
		{
			system.debug('****oAcc' + oAcc);
			if(oAcc.Local_Beneficiary_Id__c == null && oAcc.Global_Number__c != null)
			{
				mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID).put(oAcc.Global_Number__c, oAcc);
			}
			if(oAcc.GP_Supporter_Id__c != null)
			{
				mapAccount.get(Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID).put(oAcc.GP_Supporter_Id__c, oAcc);
			}
			if(oAcc.Compass_Id__c != null)
			{
				mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID).put(oAcc.Compass_Id__c, oAcc);
			}
			if(oAcc.Local_Beneficiary_Id__c != null && oAcc.Global_Number__c != null)
			{
				mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID).put(oAcc.Global_Number__c, oAcc);
			}
			if(oAcc.Local_Beneficiary_Id__c != null)
			{
				mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID).put(oAcc.Local_Beneficiary_Id__c, oAcc);
			}
		}

		/* MV-Start : Included logic to handle transferred Beneficiaries */
		Map<id, AccountHistory> mapAccandHistory = new  map<id, AccountHistory>();
		mapAccandHistory = new  map<id, AccountHistory>([SELECT
			AccountId, 
			Field, 
			OldValue, 
			NewValue
		FROM
			AccountHistory
		WHERE
			field = 'local_beneficiary_id__c' AND (Account.local_beneficiary_id__c in: setBenLocalId OR Account.Global_Number__c in: setSupGlobalId OR Account.Global_Number__c in: setBenGlobalId OR Account.GP_Supporter_Id__c in: setSupLegacyId OR Account.Compass_Id__c in: setBenLegacyId)]);
		
        for(Accounthistory oAccHis: mapAccandHistory.values())
		{
			if(string.valueOf(oAccHis.oldvalue) != '' || string.valueOf(oAccHis.oldvalue) != null)
			{
				mapAccount.get(Constants.CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID).put(string.valueOf(oAccHis.oldvalue), mapAllBenAndSup.get(oAccHis.Accountid));
			}
		}

		/* MV-End */
		//Querying all active commitments
		list<Commitment__c> lstCommitments = new  list<Commitment__c>();
		lstCommitments = [SELECT
			Id, 
			Status__c, 
			Relationship_Type__c, 
			BEN_Id__c, 
			SUP_Id__c, 
			SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c, 
			Supporter_Correspondence_Language__c, 
			BEN_Id__r.Correspondence_Language__c, 
			SUP_Id__r.Global_Number__c
		FROM
			Commitment__c
		WHERE
			(SUP_Id__r.Global_Number__c in: setSupGlobalId OR BEN_Id__r.Global_Number__c in: setBenGlobalId OR BEN_Id__r.Local_Beneficiary_Id__c in: setBenLocalId OR SUP_Id__r.GP_Supporter_Id__c in: setSupLegacyId) AND Status__c = : Constants.COMMITMENT_STATUS_ACTIVE
		ORDER BY
			Relationship_Type__c];
		
        //MV : Querying all Inactive commitments
		list<Commitment__c> lstInactiveCommitments = new  list<Commitment__c>();
		lstInactiveCommitments = [SELECT
			Id, 
			Status__c, 
			Relationship_Type__c, 
			BEN_Id__c, 
			SUP_Id__c, 
			SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c, 
			Supporter_Correspondence_Language__c, 
			BEN_Id__r.Correspondence_Language__c, 
			SUP_Id__r.Global_Number__c
		FROM
			Commitment__c
		WHERE
			(SUP_Id__r.Global_Number__c in: setSupGlobalId OR BEN_Id__r.Global_Number__c in: setBenGlobalId OR BEN_Id__r.Local_Beneficiary_Id__c in: setBenLocalId OR SUP_Id__r.GP_Supporter_Id__c in: setSupLegacyId) AND Status__c = : Constants.COMMITMENT_STATUS_INACTIVE
		ORDER BY
			Relationship_Type__c];
		
        system.debug('@@lstCommitments ' + lstCommitments);
		
        // store BenId + Supid for all active commitments
		map<Id, map<Id, Commitment__c>> mapHaveActiveCommitment = new  map<Id, map<Id, Commitment__c>>();
		
        for(Commitment__c oCommit: lstCommitments)
		{
			if(!mapHaveActiveCommitment.containsKey(oCommit.BEN_Id__c))
			{
				mapHaveActiveCommitment.put(oCommit.BEN_Id__c, new  map<Id, Commitment__c>());
			}
			mapHaveActiveCommitment.get(oCommit.BEN_Id__c).put(oCommit.SUP_Id__c, oCommit);
		}
		
        // MV : store BenId + Supid for all Inactive commitments
		map<Id, map<Id, Commitment__c>> mapHaveInActiveCommitment = new  map<Id, map<Id, Commitment__c>>();
		
        for(Commitment__c oCommit: lstInactiveCommitments)
		{
			if(!mapHaveInActiveCommitment.containsKey(oCommit.BEN_Id__c))
			{
				mapHaveInActiveCommitment.put(oCommit.BEN_Id__c, new  map<Id, Commitment__c>());
			}
			mapHaveInActiveCommitment.get(oCommit.BEN_Id__c).put(oCommit.SUP_Id__c, oCommit);
		}
		
        // Querying all Comm Kits
		list<Communication_Kit__c> lstCommKitToUpdate = new  list<Communication_Kit__c>();
		lstCommKitToUpdate = [SELECT
			Id, 
			Name, 
			Local_GP_Kit_ID__c, 
			INT_Supporter_Correspondence_Language__c, 
			BEN_ID__c, 
			BEN_ID__r.Correspondence_Language__c, 
			SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c
		FROM
			Communication_Kit__c
		WHERE
			(Name in: setCommunicationKitIds OR Local_GP_Kit_ID__c in: setGPSBCId)];
		
        map<string, Communication_Kit__c> mapCommKitsToUpdate = new  map<string, Communication_Kit__c>();
		map<string, Communication_Kit__c> mapCommGPKitsToUpdate = new  map<string, Communication_Kit__c>();
		
        for(Communication_Kit__c oCommKit: lstCommKitToUpdate)
		{
			mapCommKitsToUpdate.put(oCommKit.Name, oCommKit);
			mapCommGPKitsToUpdate.put(oCommKit.Local_GP_Kit_ID__c, oCommKit);
		}

		map<string, Record_Type_Mapping_For_SBC_Integration__c> mapRecordTypeMapping = new  map<string, Record_Type_Mapping_For_SBC_Integration__c>();
		mapRecordTypeMapping = Record_Type_Mapping_For_SBC_Integration__c.getAll();
		map<string, Record_Type_Mapping_For_SBC_Integration__c> mapRecordTypeMapping2 = new  map<string, Record_Type_Mapping_For_SBC_Integration__c>();
		
        for(Record_Type_Mapping_For_SBC_Integration__c oVar: mapRecordTypeMapping.Values())
		{
			mapRecordTypeMapping2.put(oVar.RecordType_Name_For_Integration__c.toUpperCase(), oVar);
		}

		Integer iStatusCode = 201;
		Boolean bFirstRecordProcessed = false;
		
        // Inserting/Updating Comm Kits 
		list<Communication_Kit__c> lstNewB2SKits = new  list<Communication_Kit__c>();
		list<Communication_Kit__c> lstUpsertCommKits = new  list<Communication_Kit__c>();
		
        for(Communication_Kit__c oCommKit: lstCommKitFromJSON)
		{
			Communication_Kit__c oC = new  Communication_Kit__c();
			oC = oCommKit.clone(false, false, false, false);
			
            //Source System Valdiation
			if(string.isEmpty(oC.INT_Source_System__c))
			{
				populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, Constants.ErrorString_2_SOURCE_SYSTEM + Constants.ErrorString_1, oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.BEN_INT_Local_Id__c, oCommKit.COMPASS_con_pk__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_child_id__c);
				return;
			}
			
            // Checking for StatusLocal_GP_Kit_ID__c
			if(string.isEmpty(oC.Status__c))
			{
				populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, Constants.ErrorString_3_STATUS + Constants.ErrorString_1, oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.BEN_INT_Local_Id__c, oCommKit.COMPASS_con_pk__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_child_id__c);
				return;
			}

			// Checking for Template Id
			/* if (oC.INT_RecordType_Name__c <> Constants.B2S  && (oC.Template_Id__c == '' || oC.Template_Id__c == null)) {
			populateInternalServerIntegrationError(null,
			Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS,
			Constants.ErrorString_4_TEMPLATE_ID + Constants.ErrorString_1);
			return;
			}*/

			// When source system is PERCEPTIVE
			if(oC.INT_Source_System__c != null && oC.INT_Source_System__c.toUpperCase() == Constants.SOURCE_SYSTEM_PERCEPTIVE)
			{
				// Checking for Transaction Id
				if(string.isEmpty(oC.Transaction_Id__c))
				{
					populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, Constants.ErrorString_6_TRANSACTION_ID + Constants.ErrorString_1, oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.BEN_INT_Local_Id__c, oCommKit.COMPASS_con_pk__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_child_id__c);
					return;
				}

				// Checking for Original Letter URL
				if(string.isEmpty(oC.Original_Letter_Link__c))
				{
					populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, Constants.ErrorString_7_ORIGINAL_LETTER_URL + Constants.ErrorString_1, oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.BEN_INT_Local_Id__c, oCommKit.COMPASS_con_pk__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_child_id__c);
					return;
				}
			}

			// Comm Kit Id Validation
			if(oC.INT_Communication_Kit_Id__c != null && mapCommKitsToUpdate.containsKey(oC.INT_Communication_Kit_Id__c))
			{
				oC.Id = mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).Id;

				if(!bFirstRecordProcessed)
				{
					iStatusCode = 200;
				}
			}
			else if(oC.Local_GP_Kit_ID__c != null && mapCommGPKitsToUpdate.containsKey(oC.Local_GP_Kit_ID__c))
			{
				oC.Id = mapCommGPKitsToUpdate.get(oC.Local_GP_Kit_ID__c).Id;

				if(!bFirstRecordProcessed)
				{
					iStatusCode = 200;
				}
			}
			else if(oC.INT_Communication_Kit_Id__c != null && !mapCommKitsToUpdate.containsKey(oC.INT_Communication_Kit_Id__c))
			{
				populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, Constants.ErrorString_8_INVALID + Constants.ErrorString_9_COMMUNICATION_KIT_ID + Constants.ErrorString_19_HYPHEN + oC.INT_Communication_Kit_Id__c, oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.BEN_INT_Local_Id__c, oCommKit.COMPASS_con_pk__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_child_id__c);
				return;
			}

			// Record Type Validation   
			if(oC.INT_RecordType_Name__c != null && mapRecordTypeMapping2.containsKey(oC.INT_RecordType_Name__c.toUpperCase()))
			{
				oC.INT_RecordType_Name__c = mapRecordTypeMapping2.get(oC.INT_RecordType_Name__c.toUpperCase()).Name.toUpperCase();
			}
			
            if(oC.INT_RecordType_Name__c != null && mapRecordType.containsKey(oC.INT_RecordType_Name__c.toUpperCase()))
			{
				oC.RecordTypeId = mapRecordType.get(oC.INT_RecordType_Name__c.toUpperCase()).Id;
			}
			else if(oC.INT_RecordType_Name__c != null && !mapRecordType.containsKey(oC.INT_RecordType_Name__c.toUpperCase()))
			{
				populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, Constants.ErrorString_8_INVALID + Constants.ErrorString_10_COMMUNICATION_DIRECTION + Constants.ErrorString_19_HYPHEN + oC.INT_RecordType_Name__c, oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.BEN_INT_Local_Id__c, oCommKit.COMPASS_con_pk__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_child_id__c);
				return;
			}
			else if(oC.INT_RecordType_Name__c == null)
			{
				populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, Constants.ErrorString_10_COMMUNICATION_DIRECTION + Constants.ErrorString_1, oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.BEN_INT_Local_Id__c, oCommKit.COMPASS_con_pk__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_child_id__c);
				return;
			}

			// Ben Ids Validation
			system.debug('<><><> ' + oC);
			
            CommunicationKitHandler.responseForValidationWrapper oBenValidation = CommunicationKitHandler.BeneficiaryValidationForIntegrations(oC.BEN_INT_Id__c, oC.COMPASS_child_id__c, oC.BEN_INT_Local_Id__c, mapAccount);
			
            system.debug('<><><> ' + oBenValidation);
			
            if(oBenValidation.bError)
			{
				populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQCOMMITMENTUPDATES, oBenValidation.sValue, oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.BEN_INT_Local_Id__c, oCommKit.COMPASS_con_pk__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_child_id__c);
				return;
			}
			else
			{
				oC.BEN_ID__c = oBenValidation.sValue;
			}

			// SUPPORTER VALIDATIONS
			CommunicationKitHandler.responseForValidationWrapper oSupValidation = CommunicationKitHandler.SupporterValidationForIntegrations(oC.SUP_INT_Id__c, oC.COMPASS_con_pk__c, oC.Relationship_Type__c, mapAccount);
			
            if(oSupValidation.bError)
			{
				populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQCOMMITMENTUPDATES, oSupValidation.sValue, oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.BEN_INT_Local_Id__c, oCommKit.COMPASS_con_pk__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_child_id__c);
				return;
			}
			else
			{
				//This is for the scenario when a supporter Id is not send along with communication.
				if(oC.Relationship_Type__c != Constants.COMMITMENT_TYPE_ENCOURAGER && mapHaveActiveCommitment.containsKey(oC.BEN_Id__c))
				{
					for(Commitment__c com: mapHaveActiveCommitment.get(oC.BEN_Id__c).values())
					{
						if(com.Relationship_Type__c == Constants.COMMITMENT_TYPE_CORRESPONDENT)
						{
							oC.SUP_ID__c = com.SUP_Id__c;
							break;
						}
						else
						{
							oC.SUP_ID__c = com.SUP_Id__c;
						}
					}
				}

				if(oSupValidation.sValue != null)
				{
					oC.SUP_ID__c = oSupValidation.sValue;
				}
			}

			if(oC.Id == null)// Commitment Validation to be performed ONLY on the insertion of Communication record and NOT on update.
			{
				// Active Commitment Validation
				if(oC.SUP_Id__c == null && (oC.Relationship_Type__c != null && oC.Relationship_Type__c != Constants.COMMITMENT_TYPE_ENCOURAGER))
				{
					populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, Constants.ErrorString_23_INCORRECT_RELATIONSHIP_TYPE + Constants.ErrorString_12_GLOBAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + oC.BEN_INT_Id__c + Constants.ErrorString_15_COMMA + Constants.ErrorString_13_LOCAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + oC.BEN_INT_Local_Id__c + Constants.ErrorString_17_AND + Constants.ErrorString_11_LEGACY_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + oC.COMPASS_child_id__c);
					return;
				}
				else if(oC.SUP_Id__c != null && oC.Relationship_Type__c == null && mapHaveActiveCommitment.containsKey(oC.BEN_Id__c) && mapHaveActiveCommitment.get(oC.BEN_Id__c).containsKey(oC.SUP_Id__c))
				{
					oC.Relationship_Type__c = mapHaveActiveCommitment.get(oC.BEN_Id__c).get(oC.Sup_Id__c).Relationship_Type__c;
				}
				else if(oC.Sup_Id__c != null && oC.Relationship_Type__c != null)
				{
					if(mapHaveActiveCommitment.containsKey(oC.BEN_Id__c) && mapHaveActiveCommitment.get(oC.BEN_Id__c).containsKey(oC.Sup_Id__c) && mapHaveActiveCommitment.get(oC.BEN_Id__c).get(oC.Sup_Id__c).Relationship_Type__c != oC.Relationship_Type__c)
					{
						populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, Constants.ErrorString_23_INCORRECT_RELATIONSHIP_TYPE + Constants.ErrorString_12_GLOBAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + oC.BEN_INT_Id__c + Constants.ErrorString_15_COMMA + Constants.ErrorString_13_LOCAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + oC.BEN_INT_Local_Id__c + Constants.ErrorString_15_COMMA + Constants.ErrorString_11_LEGACY_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + oC.COMPASS_child_id__c + Constants.ErrorString_15_COMMA + Constants.ErrorString_21_GLOBAL_SUPPORTER_ID + Constants.ErrorString_19_HYPHEN + oC.SUP_INT_Id__c + Constants.ErrorString_17_AND + Constants.ErrorString_20_LEGACY_SUPPORTER_ID + Constants.ErrorString_19_HYPHEN + oC.COMPASS_con_pk__c);
						return;
					}
					else if((!mapHaveActiveCommitment.containsKey(oC.BEN_Id__c) || (mapHaveActiveCommitment.containsKey(oC.BEN_Id__c) && !mapHaveActiveCommitment.get(oC.BEN_Id__c).containsKey(oC.Sup_Id__c))) && oC.Relationship_Type__c != Constants.COMMITMENT_TYPE_ENCOURAGER)
					{
						populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, Constants.ErrorString_23_INCORRECT_RELATIONSHIP_TYPE + Constants.ErrorString_12_GLOBAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + oC.BEN_INT_Id__c + Constants.ErrorString_15_COMMA + Constants.ErrorString_13_LOCAL_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + oC.BEN_INT_Local_Id__c + Constants.ErrorString_15_COMMA + Constants.ErrorString_11_LEGACY_BENEFICIARY_ID + Constants.ErrorString_19_HYPHEN + oC.COMPASS_child_id__c + Constants.ErrorString_15_COMMA + Constants.ErrorString_21_GLOBAL_SUPPORTER_ID + Constants.ErrorString_19_HYPHEN + oC.SUP_INT_Id__c + Constants.ErrorString_17_AND + Constants.ErrorString_20_LEGACY_SUPPORTER_ID + Constants.ErrorString_19_HYPHEN + oC.COMPASS_con_pk__c);
						return;
					}
				}
			}

			// VALIDATING INCOMING New S2B Kit
			if(oC.Id == null && oC.RecordTypeId == CommunicationKitHandler.sRecordTypeS2B && oC.Sup_Id__c != null && mapHaveActiveCommitment.containsKey(oC.BEN_Id__c) && mapHaveActiveCommitment.get(oC.BEN_Id__c).containsKey(oC.SUP_Id__c))
			{
				if(!mapHaveActiveCommitment.get(oC.BEN_Id__c).get(oC.SUP_Id__c).SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c && mapHaveActiveCommitment.get(oC.BEN_Id__c).get(oC.SUP_Id__c).BEN_Id__r.Correspondence_Language__c != mapHaveActiveCommitment.get(oC.BEN_Id__c).get(oC.SUP_Id__c).Supporter_Correspondence_Language__c && mapHaveActiveCommitment.get(oC.BEN_Id__c).get(oC.SUP_Id__c).Supporter_Correspondence_Language__c != Constants.COMMITMENT_CORRESPONDENCE_LANGUAGE && (string.isEmpty(oC.Translated_Text_English__c)))
				{
					populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, 'For Global Partner not using SDL with different Supporter and Beneficiary Langague pairing and with Supporter language different then english, send English Tranlsted Text as well.', oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.BEN_INT_Local_Id__c, oCommKit.COMPASS_con_pk__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_child_id__c);
					return;
				}
			}

			// MV : VALIDATING INCOMING S2B Kit - OriginalLanguage
			if(oC.Id == null && oC.RecordTypeId == CommunicationKitHandler.sRecordTypeS2B && (oC.INT_Supporter_Correspondence_Language__c != null))
			{
				string sLanguage = system.label.Supporter_Preferred_Languages_S2B;
				if(!sLanguage.contains(oC.INT_Supporter_Correspondence_Language__c))
				{
					populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, 'Not a Valid Language', oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.BEN_INT_Local_Id__c, oCommKit.COMPASS_con_pk__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_child_id__c);
					return;
				}
			}
			//MV:VALIDATING INCOMING S2B Kit with Final letter
			if(oC.RecordTypeId == CommunicationKitHandler.sRecordTypeS2B && mapHaveInActiveCommitment.containsKey(oC.BEN_Id__c) && !mapHaveInActiveCommitment.get(oC.BEN_Id__c).containsKey(oC.SUP_Id__c) && oC.Communication_Types__c == constants.FINAL_LETTER)
			{
				populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, 'No Commitment with this Suppotor', oCommKit.INT_Communication_Kit_Id__c, oCommKit.BEN_INT_Id__c, oCommKit.SUP_INT_Id__c, oCommKit.COMPASS_con_pk__c, 'S2B', 'Final Letter', oCommKit.Local_GP_Kit_ID__c);
				return;
			}
			// VALIDATING INCOMING S2B Kit from SDL (including Encourager)
			if(oC.Id != null && oC.RecordTypeId == CommunicationKitHandler.sRecordTypeS2B && oC.INT_Source_System__c == 'SDL')
			{
				// if translation is complete
				if(oC.Status__c == Constants.COMMUNICATION_KIT_STATUS_TRANSLATION_QUALITY_CHECK_COMP)
				{
					//KN: Adding fix to ensure that comm records with odd no of pages always go to XMPie// KN: Odd or even                       
					Integer iRemainder = math.mod(integer.valueof(oC.Number_Of_Pages__c), 2);
					if((mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c != mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c))
					{
						if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c == 'English' && mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c != 'English')
						{
							//na-yes-no-na
							if(string.isEmpty(oC.Final_Translated_Text__c))
							{
								mapIdToCommlst.put(oC.id, oCommKit);
								setCommId.add(oC.id);
								mapErrorMessage.put(oC.id, Constants.ErrorString_32_NULL_FINALTXT);
								break;
							}
							else
							{
								oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
							}
						}
						else if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c)
						{
							if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c != 'English' && mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c != 'English')
							{
								//yes-no-no-yes
								if(string.isEmpty(oC.Final_Translated_Text__c) && string.isEmpty(oC.Translated_Text_English__c))
								{
									mapIdToCommlst.put(oC.id, oCommKit);
									setCommId.add(oC.id);
									mapErrorMessage.put(oC.id, Constants.ErrorString_33_NULL_FINAL_ENG);
									break;
								}
								else
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
							}
							else if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c != 'English' && mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c == 'English')
							{
								//yes-no-yes-NA
								if(!string.isEmpty(oC.Final_Translated_Text__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
								else if(string.isEmpty(oC.Final_Translated_Text__c) && !string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.Final_Translated_Text__c = oC.Translated_Text_English__c;
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
								else
								{
									mapIdToCommlst.put(oC.id, oCommKit);
									setCommId.add(oC.id);
									mapErrorMessage.put(oC.id, Constants.ErrorString_33_NULL_FINAL_ENG);
									break;
								}
							}
						}
						else if(!mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c)
						{
							if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c != 'English' && mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c != 'English')
							{
								//no-no-no-yes
								if(string.isEmpty(oC.Final_Translated_Text__c))
								{
									mapIdToCommlst.put(oC.id, oCommKit);
									setCommId.add(oC.id);
									mapErrorMessage.put(oC.id, constants.ErrorString_32_NULL_FINALTXT);
									break;
								}
								else
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
							}
							else if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c != 'English' && mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c == 'English')
							{
								if(!string.isEmpty(oC.Final_Translated_Text__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
								else if(string.isEmpty(oC.Final_Translated_Text__c) && !string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.Final_Translated_Text__c = oC.Translated_Text_English__c;
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
								else
								{
									mapIdToCommlst.put(oC.id, oCommKit);
									setCommId.add(oC.id);
									mapErrorMessage.put(oC.id, Constants.ErrorString_33_NULL_FINAL_ENG);
									break;
								}
							}
						}
					}
					else
					{
						if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c == 'English')
						{
							//Na-yes-yes-no
							if(!string.isEmpty(oC.Final_Translated_Text__c))
							{
								oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
							}
							else if(string.isEmpty(oC.Final_Translated_Text__c) && !string.isEmpty(oC.Translated_Text_English__c))
							{
								oC.Final_Translated_Text__c = oC.Translated_Text_English__c;
								oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
							}
							else
							{
								if(iRemainder == 0)// KN: If even no. of pages                         
								
								{
									oC.Final_Composed_Letter_Link__c = oC.Original_Letter_Link__c;
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED;
								}
								else
								{
									// KN: If odd no. of pages
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
							}
						}
						else
						{
							//Na-no-no-no
							if(!string.isEmpty(oC.Final_Translated_Text__c))
							{
								oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
							}
							else if(string.isEmpty(oC.Final_Translated_Text__c) && string.isEmpty(oC.Translated_Text_English__c))
							{
								if(iRemainder == 0)// KN: If even no. of pages      
								
								{
									oC.Final_Composed_Letter_Link__c = oC.Original_Letter_Link__c;
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED;
								}
								else
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
							}
							else
							{
								mapIdToCommlst.put(oC.id, oCommKit);
								setCommId.add(oC.id);
								mapErrorMessage.put(oC.id, Constants.ErrorString_33_NULL_ENGTXT);
								break;
							}
						}
					}
				}
			}
			// VALIDATING INCOMING B2S Kit from SDL
			if(oC.Id != null && oC.RecordTypeId == CommunicationKitHandler.sRecordTypeB2S && oC.Sup_Id__c != null && oC.INT_Source_System__c == 'SDL')
			{
				if(oC.Status__c == Constants.COMMUNICATION_KIT_STATUS_QUALITY_CHECK_UNSUCCESSFUL)
				{
					oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED;
					oC.Print_Allowed_Date__c = System.today();
				}
				else if(oC.Status__c == Constants.COMMUNICATION_KIT_STATUS_TRANSLATION_QUALITY_CHECK_COMP)
				{
					if((mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c != mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c))
					{
						if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c != 'English' && mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c != 'English')
						{
							// yes-no-no-yes
							if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c)
							{
								if(!string.isEmpty(oC.Final_Translated_Text__c) && !string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
								else if(string.isEmpty(oC.Final_Translated_Text__c))
								{
									mapIdToCommlst.put(oC.id, oCommKit);
									setCommId.add(oC.id);
									mapErrorMessage.put(oC.id, Constants.ErrorString_32_NULL_FINALTXT);
									break;
								}
								else
								{
									mapIdToCommlst.put(oC.id, oCommKit);
									setCommId.add(oC.id);
									mapErrorMessage.put(oC.id, Constants.ErrorString_33_NULL_ENGTXT);
									break;
								}
							}
							else
							{
								//NO-No-NO-Yes
								if(!string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.Final_Translated_Text__c = oC.Translated_Text_English__c;
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
								else
								{
									mapIdToCommlst.put(oC.id, oCommKit);
									setCommId.add(oC.id);
									mapErrorMessage.put(oC.id, Constants.ErrorString_33_NULL_ENGTXT);
									break;
								}
							}
						}
						else if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c == 'English' && mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c != 'English')
						{
							// yes-no-yes-yes
							// no-no-yes-yes
							if(string.isEmpty(oC.Translated_Text_English__c))
							{
								mapIdToCommlst.put(oC.id, oCommKit);
								setCommId.add(oC.id);
								mapErrorMessage.put(oC.id, Constants.ErrorString_32_NULL_FINALTXT);
								break;
							}
							else if(string.isEmpty(oC.Final_Translated_Text__c) && !string.isEmpty(oC.Translated_Text_English__c))
							{
								oC.Final_Translated_Text__c = oC.Translated_Text_English__c;
								oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
							}
							else if(!string.isEmpty(oC.Final_Translated_Text__c) && !string.isEmpty(oC.Translated_Text_English__c))
							{
								oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
							}
						}
						else if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c != 'English' && mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c == 'English')
						{
							//Yes - Yes - no - yes
							if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c)
							{
								if(!string.isEmpty(oC.Final_Translated_Text__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
								else if(string.isEmpty(oC.Final_Translated_Text__c))
								{
									mapIdToCommlst.put(oC.id, oCommKit);
									setCommId.add(oC.id);
									mapErrorMessage.put(oC.id, Constants.ErrorString_32_NULL_FINALTXT);
									break;
								}
							}
							else
							{
								// no-yes-no-yes
								oC.Final_Composed_Letter_Link__c = oC.Original_Letter_Link__c;
								oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_PUBLISHEDTOGP;
							}
						}
					}
					else if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c == mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c)
					{
						if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).INT_Supporter_Correspondence_Language__c == 'English' && mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).BEN_ID__r.Correspondence_Language__c == 'English')
						{
							if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c)
							{
								//yes-yes-yes-no
								if(!string.isEmpty(oC.Final_Translated_Text__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
								else if(string.isEmpty(oC.Final_Translated_Text__c) && !string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.Final_Translated_Text__c = oC.Translated_Text_English__c;
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
								else if(string.isEmpty(oC.Final_Translated_Text__c) && string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_PUBLISHEDTOGP;
									oC.Final_Composed_Letter_Link__c = oC.Original_Letter_Link__c;
								}
							}
							else
							{
								//No-yes-yes-no
								if(!string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.Final_Translated_Text__c = oC.Translated_Text_English__c;
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
								else if(string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_PUBLISHEDTOGP;
									oC.Final_Composed_Letter_Link__c = oC.Original_Letter_Link__c;
								}
							}
						}
						else
						{
							if(mapCommKitsToUpdate.get(oC.INT_Communication_Kit_Id__c).SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c)
							{
								//yes-No-No-no
								if(!string.isEmpty(oC.Final_Translated_Text__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS;
								}
								else if(string.isEmpty(oC.Final_Translated_Text__c) && !string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_PUBLISHEDTOGP;
									oC.Final_Composed_Letter_Link__c = oC.Original_Letter_Link__c;
								}
								else if(string.isEmpty(oC.Final_Translated_Text__c) && string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_PUBLISHEDTOGP;
									oC.Final_Composed_Letter_Link__c = oC.Original_Letter_Link__c;
								}
							}
							else
							{
								//no-no-no-no
								if(string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_PUBLISHEDTOGP;
									oC.Final_Composed_Letter_Link__c = oC.Original_Letter_Link__c;
								}
								else if(!string.isEmpty(oC.Translated_Text_English__c))
								{
									oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_PUBLISHEDTOGP;
								}
								oC.Final_Composed_Letter_Link__c = oC.Original_Letter_Link__c;
							}
						}
					}
					else
					{
						mapIdToCommlst.put(oC.id, oCommKit);
						setCommId.add(oC.id);
						mapErrorMessage.put(oC.id, 'Unknown Error');
						break;
					}
				}
			}

			// VALIDATING INCOMING B2S && S2B Kit from XMPIE
			if(oC.Id != null && oC.INT_Source_System__c == Constants.SOURCE_SYSTEM_XMPieSmallCase)
			{
				//B2S letter
				if(oC.RecordTypeId == CommunicationKitHandler.sRecordTypeB2S)
				{
					oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_PUBLISHEDTOGP;
					//S2B Letter
				}

				if(oC.RecordTypeId == CommunicationKitHandler.sRecordTypeS2B)
				{
					oC.INT_New_Status__c = Constants.COMMUNICATION_KIT_STATUS_READYTOBEPRINTED;
					oC.Print_Allowed_Date__c = system.today();
				}
			}

			/* Exception scenario for B2S templates to set the communication types correctly*/
			if(oC.RecordTypeId == CommunicationKitHandler.sRecordTypeB2S && oC.Template_Id__c != '' && oC.Template_Id__c != null)
			{
				List<string> lstTemplateParts = oC.Template_Id__c.split('-');
				string templateGrouping = '';
				if(lstTemplateParts != null && lstTemplateParts.size() > 2)
				{
					templateGrouping = lstTemplateParts[1];
					if(templateGrouping == 'G' || (templateGrouping == 'A' && oC.Communication_Types__c == ''))
					{
						oC.Communication_Types__c = Constants.COMMUNICATION_TYPE_BENEFICIARY_INITIATED;
					}
					else if(templateGrouping == 'H')
					{
						oC.Communication_Types__c = Constants.FINAL_LETTER;
					}
				}
			}

			lstUpsertCommKits.add(oC);
			
            /* Akash's Changes for Supporter Mandatory Review Required field Update*/
			if(oC.Sup_Id__c != null)
			{
				Account acc = new  Account();
				acc.Id = oC.Sup_Id__c;
				acc.Mandatory_Review_Flag__c = oC.INT_Supporter_Review_Required__c;
				lstOfSupporters.add(acc);
			}

			/* Akash's Changes for Supporter Mandatory Review Required field Update*/
			oC.BEN_INT_Id__c = '';
			oC.BEN_INT_Local_Id__c = '';
			oC.INT_RecordType_Name__c = '';
			oC.COMPASS_con_pk__c = '';
			oC.SUP_INT_Id__c = '';
			oC.INT_Communication_Kit_Id__c = '';
			oC.INT_Source_System__c = Constants.SOURCE_SYSTEM_SFDC_CI;
			oC.INT_Supporter_Review_Required__c = false;
			oC.COMPASS_child_id__c = '';

			if(!bFirstRecordProcessed)
			{
				bFirstRecordProcessed = true;
			}
		}

		//MV :  Error Messges for Populate SDL Scenarios 
		if(setCommId.size() > 0)
		{
			updateStatusOnException(setCommId, mapErrorMessage);

			for(id oCommKit: mapIdToCommlst.keyset())
			{
				populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, mapErrorMessage.get(oCommkit), mapIdToCommlst.get(oCommkit).INT_Communication_Kit_Id__c, mapIdToCommlst.get(oCommkit).BEN_INT_Id__c, mapIdToCommlst.get(oCommkit).BEN_INT_Local_Id__c, mapIdToCommlst.get(oCommkit).COMPASS_con_pk__c, mapIdToCommlst.get(oCommkit).SUP_INT_Id__c, mapIdToCommlst.get(oCommkit).COMPASS_child_id__c);
			}

			return;
		}

		if(!lstUpsertCommKits.isEmpty())
		{
			try
			{
				Upsert lstUpsertCommKits;
			}
			catch(Exception oEx)
			{
				if(CommunicationKitHandler.bUpdateError)
				{
					populateInternalServerIntegrationError(null, 'updateRelationType', 'Final letter error', null, CommunicationKitHandler.strBenID, null, null, constants.S2B, 'Final Letter', CommunicationKitHandler.strGlobalPartnerSBCId);
				}
				else
				{
					populateInternalServerIntegrationError(oEx, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, null);
				}

				return;
			}
		}

		/* Akash's Changes for Supporter Mandatory Review Required field Update*/
		if(!lstOfSupporters.isEmpty())
		{
			try
			{
				Update lstOfSupporters;
			}
			catch(Exception oEx)
			{
				populateInternalServerIntegrationError(oEx, Constants.METHOD_NAME_REQSBCCOMMUNICATIONDETAILS, null);
				return;
			}
		}

		/* Akash's Changes for Supporter Mandatory Review Required field Update*/
		list<Communication_Kit__c> lstToSendResponse = new  list<Communication_Kit__c>();
		lstToSendResponse = [SELECT
			Id, 
			Name, 
			Local_GP_Kit_ID__c, 
			INT_Communication_Kit_ID__c, 
			Status__c
		FROM
			Communication_Kit__c
		WHERE
			Id in: lstUpsertCommKits];
		
        for(Communication_Kit__c oCommKit: lstToSendResponse)
		{
			oCOmmKit.INT_Communication_Kit_Id__c = oCommKit.Name;
		}
		
        Map<string, List<sObject>> mapOutputVar = new  Map<string, List<sObject>>();
		mapOutputVar.put(Constants.COMMUNICATION_RESPONSES_FG, lstToSendResponse);
		string sJsonResponse = JSONHandlerMethods.serialize(mapOutputVar, Constants.COMMUNICATION_RESPONSES_PN);
		system.debug('<><><> ' + sJsonResponse);
		RestContext.response.statusCode = iStatusCode;
		RestContext.response.responseBody = blob.valueOf(sJsonResponse);
	}


	/**
	* Method name  : UpdatestatusOnException
	* Description  :
	* Return Type  : void
	* Parameter    :
	**/
	public static void updateStatusOnException(Set<ID> setCommid, Map<id, string> mapErrorMessage)
	{
		if(setCommid.size() > 0)
		{
			List<Communication_Kit__c> lstcomm = [SELECT
				id, 
				Error_Description__c, 
				Status__c
			FROM
				Communication_Kit__c
			WHERE
				id in: setCommid];

			if(!lstcomm.isempty())
			{
				for(Communication_Kit__c oCommKit: lstcomm)
				{
					oCommKit.Status__c = 'System Error';
					oCommKit.Error_Description__c = mapErrorMessage.get(oCommKit.id);
				}
				Update lstcomm;
			}
		}

		return;
	}


	/**
	* Method name  : sendSBCCommunicationDetails
	* Description  : This method is accept the list of Communications, serealize it in JSON and send accross
	* Return Type  : void
	* Parameter    : String, list<Communication_Kit__c>
	**/
	public static void sendSBCCommunicationDetails(string sWhomToSend, list<Communication_Kit__c> lstCommKits)
	{
		set<Id> setCommKitIds = new  set<Id>();
		set<Id> setBenIds = new  set<Id>();
		set<Id> setSupIds = new  set<Id>();
		
        for(Communication_Kit__c oCommKit: lstCommKits)
		{
			setCommKitIds.add(oCommKit.Id);
			setBenIds.add(oCommKit.BEN_Id__c);
			setSupIds.add(oCommKit.SUP_Id__c);
		}

		list<Commitment__c> lstCommitments = new  list<Commitment__c>();
		lstCommitments = [SELECT
			Id, 
			BEN_Id__c, 
			SUP_Id__c, 
			Supporter_Correspondence_Language__c
		FROM
			Commitment__c
		WHERE
			BEN_Id__c in: setBenIds OR SUP_Id__c in: setSupIds];
		
        map<Id, map<Id, Commitment__c>> mapBenSupCommitment = new  map<Id, map<Id, Commitment__c>>();
		
        for(Commitment__c oCommitment: lstCommitments)
		{
			if(!mapBenSupCommitment.containsKey(oCommitment.BEN_Id__c))
			{
				mapBenSupCommitment.put(oCommitment.BEN_Id__c, new  map<Id, Commitment__c>());
			}
			mapBenSupCommitment.get(oCommitment.BEN_Id__c).put(oCommitment.SUP_Id__c, oCommitment);
		}

		string sFieldsQuery = Utility.getFieldGroupElements(Constants.COMM_KIT_FIELD_GROUP);
		string sQuery = 'Select ' + sFieldsQuery + 'CreatedById from Communication_Kit__c where Id IN: setCommKitIds';
		
        System.Debug('sQuery: ' + sQuery);
		
        list<Communication_Kit__c> lstCommKitForJSON = new  list<Communication_Kit__c>();
		
        try
		{
			lstCommKitForJSON = database.query(sQuery);
		}
		catch(System.QueryException oQe)
		{
			ErrorLogUtility.logGeneralError(oQe, Constants.CLASS_NAME_SBCCOMMUNICATIONDETAILS, Constants.METHOD_NAME_SENDCOMMUNICATIONDETAILS, Constants.SOURCE_SYSTEM_SFDC_CI);
		}

		map<string, Record_Type_Mapping_For_SBC_Integration__c> mapRecordTypeMapping = new  map<string, Record_Type_Mapping_For_SBC_Integration__c>();
		mapRecordTypeMapping = Record_Type_Mapping_For_SBC_Integration__c.getAll();
		
        set<string> setRecordTypeMappingValues = new  set<string>();
		//setRecordTypeMappingValues.addAll(mapRecordTypeMapping.Values());
		
        for(Record_Type_Mapping_For_SBC_Integration__c oVar: mapRecordTypeMapping.Values())
		{
			setRecordTypeMappingValues.add(oVar.RecordType_Name_For_Integration__c);
		}
		
        list<RecordType> lstRecordType = new  list<RecordType>();
		lstRecordType = [SELECT
			Id, 
			Name, 
			DeveloperName
		FROM
			RecordType
		WHERE
			SObjectType = : Constants.COMMUNICATION_KIT_API_NAME];
		
        map<string, RecordType> mapRecordType = new  map<string, RecordType>();
		
        for(RecordType oRecType: lstRecordType)
		{
			mapRecordType.put(oRecType.Name, oRecType);
			// Fixing Original and Translation Language
		}

		map<string, map<string, List<sObject>>> mapOuterOutputVar = new  map<string, map<string, List<sObject>>>();
		Boolean bImmTransfer = true;

		for(Communication_Kit__c oCommKit: lstCommKitForJSON)
		{
			/*if(oCommKit.original_text__c != null)
			oCommKit.original_text__c = oCommKit.original_text__c.unescapeHtml4();
			
			if(oCommKit.Final_Translated_Text__c != null)
			oCommKit.Final_Translated_Text__c = oCommKit.Final_Translated_Text__c.unescapeHtml4();
			
			if(oCommKit.Translated_Text_English__c != null)
			oCommKit.Translated_Text_English__c = oCommKit.Translated_Text_English__c.unescapeHtml4();*/

			if(!setRecordTypeMappingValues.contains(oCommKit.RecordType.Name))
			{
				oCommKit.RecordType.Name = mapRecordTypeMapping.get(mapRecordType.get(oCommKit.RecordType.Name).DeveloperName).RecordType_Name_For_Integration__c;
			}

			string sBenLanguage = oCommKit.BEN_Id__r.Correspondence_Language__c;
			
            system.debug('**********oCommKit' + oCommKit);
			
            if(oCommKit.RecordType.Name == Constants.B2S)
			{
				oCommKit.BEN_Id__r.Correspondence_Language__c = oCommKit.INT_Supporter_Correspondence_Language__c;
				oCommKit.INT_Supporter_Correspondence_Language__c = sBenLanguage;
			}

			if(sWhomToSend == Constants.DEST_SYSTEM_XMPIE && oCommKit.RecordType.Name == Constants.S2B && !CommunicationKitHandler.bUpdateFromPrintPortal)
			{
				bImmTransfer = false;
			}

			if(sWhomToSend.contains(Constants.SOURCE_SYSTEM_XMPIE) && string.isEmpty(oCommKit.SUP_Id__r.Preferred_Name__pc) && !string.isEmpty(oCommKit.SUP_Id__r.Name))
			{
				oCommKit.SUP_Id__r.Preferred_Name__pc = oCommKit.SUP_Id__r.Name;
			}

			system.debug('>>>> sWhomToSend: ' + sWhomToSend);

			if(sWhomToSend == Constants.GP)
			{
				if(mapOuterOutputVar.containsKey(oCommKit.Global_Partner_ID__c))
				{
					map<string, List<sObject>> mapInner = mapOuterOutputVar.get(oCommKit.Global_Partner_ID__c);

					if(mapInner.containsKey(Constants.COMM_KIT_FIELD_GROUP))
					{
						List<sObject> CommList = mapInner.get(Constants.COMM_KIT_FIELD_GROUP);
						CommList.add(oCommKit);
						mapInner.put(Constants.COMM_KIT_FIELD_GROUP, CommList);
					}
					else
					{
						List<sObject> CommList = new  List<sObject>();
						CommList.add(oCommKit);
						mapInner.put(Constants.COMM_KIT_FIELD_GROUP, CommList);
					}

					mapOuterOutputVar.put(oCommKit.Global_Partner_ID__c, mapInner);
				}
				else
				{
					List<sObject> CommList = new  List<sObject>();
					CommList.add(oCommKit);
					map<string, List<sObject>> mapInner = new  map<string, List<sObject>>();
					mapInner.put(Constants.COMM_KIT_FIELD_GROUP, CommList);
					mapOuterOutputVar.put(oCommKit.Global_Partner_ID__c, mapInner);
				}
			}
		}

		if(sWhomToSend == Constants.GP)
		{
			for(string sGPId: mapOuterOutputVar.keyset())
			{
				System.debug('sGPId : ' + sGPId);

				map<string, List<sObject>> mapOutputVar = mapOuterOutputVar.get(sGPId);
				callCommunicationKitSend(mapOutputVar, sWhomToSend, sGPId, true);
			}
		}
		else
		{
			System.debug('lstCommKitForJSON : ' + lstCommKitForJSON);

			map<string, List<sObject>> mapOutputVar = new  map<string, List<sObject>>();
			mapOutputVar.put(Constants.COMM_KIT_FIELD_GROUP, lstCommKitForJSON);

			if(bImmTransfer)
			{
				callCommunicationKitSend(mapOutputVar, sWhomToSend, null, true);
			}
			else
			{
				callCommunicationKitSend(mapOutputVar, sWhomToSend, null, false);
			}
		}
		/* Akash's changes for Onramp URL */
	}


	private static void callCommunicationKitSend(map<string, List<sObject>> mapOutputVar, string sWhomToSend, string GpString, Boolean bImmTransfer)
	{
		System.Debug('mapOutputVar: ' + mapOutputVar.values());

		string sResponse = JSONHandlerMethods.serialize(mapOutputVar, Constants.COMM_KIT_PROCESS_NAME);

		system.debug('-----JSON STRUCTURE----' + sResponse);

		// Fixing type in outgoing JSON
		list<string> lstStrings = new  list<string>();
		lstStrings = sResponse.split(Constants.SBC_TYPE_NAME);
		sResponse = '';

		for(Integer i = 0; i < lstStrings.size(); i++)
		{
			if(i == 0)
			{
				sResponse = lstStrings[i];
			}
			else
			{
				list<string> lstCommTypes = lstStrings[i].subStringBefore(',').remove('"').split(';');
				string sTempCommTypes = Constants.SBC_TYPE_NAME + '[';
				for(string sVar: lstCommTypes)
				{
					sTempCommTypes += '"' + sVar + '",';
				}
				sTempCommTypes = sTempCommTypes.subStringBeforeLast(',') + '],';
				sResponse += sTempCommTypes + lstStrings[i].subStringAfter(',');
			}
		}

		sResponse = sResponse.replace(Constants.TRUE_WITH_QUOTES, Constants.TRUE_WITHOUT_QUOTES);
		sResponse = sResponse.replace(Constants.FALSE_WITH_QUOTES, Constants.FALSE_WITHOUT_QUOTES);
		sResponse = sResponse.replace('\\\""', '$$SubstituteString$$');//Added By Ankit
		sResponse = sResponse.replace('""', 'null');
		sResponse = sResponse.replace('\\\'', '\'');//Added By Ankit
		sResponse = sResponse.replace('"null"', 'null');
		sResponse = sResponse.replace('$$SubstituteString$$', '\\""');// Added By Ankit
        
		system.debug('-----JSON STRUCTURE----' + sResponse);

		if(sWhomToSend != null && !test.isRunningTest())
		{
			if(bImmTransfer)
			{
				system.enqueueJob(new  CommunicationKitSend(sResponse, 'SBCCommunicationDetails_' + sWhomToSend, Constants.POST_METHOD, GpString, true));
			}
			else
			{
				system.enqueueJob(new  CommunicationKitSend(sResponse, 'SBCCommunicationDetails_' + sWhomToSend, Constants.POST_METHOD, GpString, false));
			}
		}
	}


	/**
	* Method name  : populateInternalServerIntegrationError
	* Description  : This method is used to make outbound calls
	* Return Type  : void
	* Parameter    : Exception, String, String
	**/
	global static void populateInternalServerIntegrationError(Exception oEx, string sMethodName, string sMessage)
	{
		RestContext.response.statusCode = 500;
		RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
		string sErrorMessage = (string.isBlank(sMessage)) ? oEx.getMessage() : sMessage;
		string sJsonResponse = Constants.CONTENT_FAILURE_RESPONSE + sErrorMessage + '"}}';
		RestContext.response.responseBody = blob.valueOf(sJsonResponse);
		ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound', Constants.CLASS_NAME_SBCCOMMUNICATIONDETAILS, sMethodName, Constants.SOURCE_SYSTEM_SFDC_CI, null, (string.isBlank(sMessage)) ? 'Stack Trace: ' + oEx.getStackTraceString() + ' Exception: ' + oEx.getMessage() : sMessage, RestContext.request.requestBody.toString().trim(), sJsonResponse, sJsonResponse, oEx);
	}


	/**
	* Method name  : populateInternalServerIntegrationError
	* Description  : This method is used to make outbound calls
	* Return Type  : void
	* Parameter    : Exception, String, String, String, String, String, String, String, String
	**/
	global static void populateInternalServerIntegrationError(Exception oEx, string sMethodName, string sMessage, string sComKitID, string sBenGlobalId, string sBenLocalId, string sSupLegacyId, string sSupGlobalId, string sBenLegacyId)
	{
		sComKitID = sComKitID == null ? '' : sComKitID;
		sBenGlobalId = sBenGlobalId == null ? '' : sBenGlobalId;
		sBenLocalId = sBenLocalId == null ? '' : sBenLocalId;
		sSupLegacyId = sSupLegacyId == null ? '' : sSupLegacyId;
		sSupGlobalId = sSupGlobalId == null ? '' : sSupGlobalId;
		sBenLegacyId = sBenLegacyId == null ? '' : sBenLegacyId;

		RestContext.response.statusCode = 500;
		RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
		
        string sErrorMessage = (string.isBlank(sMessage)) ? oEx.getMessage() : sMessage;
		string sJsonResponse = Constants.CONTENT_FAILURE_RESPONSE + sErrorMessage + '", "CompassionSBCId":"' + sComKitID + '", "Beneficiary_GlobalId": "' + sBenGlobalId + '", "Beneficiary_LocalId": "' + sBenLocalId + '", "Supporter_CompassConstituentId ": "' + sSupLegacyId + '", "Supporter_GlobalId ": "' + sSupGlobalId + '", "Beneficiary_CompassId ": "' + sBenLegacyId + '"}}';
		
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
		
        //SSHANKAR - 02-JUN-2016 - Replace the method name of ErrorLogUtility class and passed it as a param to capture Comm ID
		ErrorLogUtility.logIntegrationInfoWithRecordId('Failure', 'Inbound', Constants.CLASS_NAME_SBCCOMMUNICATIONDETAILS, sMethodName, Constants.SOURCE_SYSTEM_SFDC_CI, null, (string.isBlank(sMessage)) ? 'Stack Trace: ' + oEx.getStackTraceString() + ' Exception: ' + oEx.getMessage() : sMessage, RestContext.request.requestBody.toString().trim(), sJsonResponse, sJsonResponse, oEx, sComKitID);
	}


	/**
	* Method name  : populateInternalServerIntegrationError
	* Description  : This method is used to make outbound calls
	* Return Type  : void
	* Parameter    : Exception, String, String, String, String, String, String, String, String
	**/
	private static void populateInternalServerIntegrationError(Exception oEx, string sMethodName, string sMessage, string sComKitID, string sBenLocalId, string sSupLegacyId, string sSupGlobalId, string sDirection, string sSBCTypes, string sGlobalPartnerSBCId)
	{
		sBenLocalId = sBenLocalId == null ? '' : sBenLocalId;
		sSupLegacyId = sSupLegacyId == null ? '' : sSupLegacyId;
		sSupGlobalId = sSupGlobalId == null ? '' : sSupGlobalId;
		sDirection = sDirection == null ? '' : sDirection;
		sSBCTypes = sSBCTypes == null ? '' : sSBCTypes;
		sGlobalPartnerSBCId = sGlobalPartnerSBCId == null ? '' : sGlobalPartnerSBCId;
		
        RestContext.response.statusCode = 200;
		RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
		
        string sErrorMessage = (string.isBlank(sMessage)) ? oEx.getMessage() : sMessage;
		string sJsonResponse = Constants.CONTENT_FAILURE_RESPONSE_OTHER_FORMATE + ', "CompassionSBCId":"' + sComKitID + '","GlobalPartnerSBCId": "' + sGlobalPartnerSBCId + '"}]}';
		
        system.debug('@@' + sJsonResponse);
		
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
		
        //SSHANKAR - 02-JUN-2016 - Replace the method name of ErrorLogUtility class and passed it as a param to capture Comm ID
		ErrorLogUtility.logIntegrationInfoWithRecordId('Failure', 'Inbound', 'CommunicationKitHandler', sMethodName, Constants.SOURCE_SYSTEM_SFDC_CI, null, (string.isBlank(sMessage)) ? 'Stack Trace: ' + oEx.getStackTraceString() + ' Exception: ' + oEx.getMessage() : sMessage, RestContext.request.requestBody.toString().trim(), sJsonResponse, sJsonResponse, oEx, sComKitID);
	}
}