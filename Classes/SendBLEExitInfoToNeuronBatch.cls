/******************************************************************************************************
Class Name         : SendBLEExitInfoToNeuronBatch
Description        : This class is used for archiving all the case on regular intervals defined in the
                     corresponding Scheduler job.
Created By         : Himanshu Raichandani
Created On         : 20-May-2015 
******************************************************************************************************/
public class SendBLEExitInfoToNeuronBatch implements Database.Batchable<SObject>,
                                Database.AllowsCallouts, Database.Stateful {

		private JSONParserForToken oJsonParserToken = null;
		/**
		 * Method name  : start
		 * Description  : This method queries all the Exit BLEs whose Compass_Update_Pending__c flag is set to true
		 * Return Type  : Database.Querylocator
		 * Parameter    : Database.BatchableContext
		 **/
		public Database.Querylocator start(Database.BatchableContext oBC) {

			Id planExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
				Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_RT_API_NAME);
			Id unplanExitRecTypeId = Utility.getRecordTypeIdByDeveloperName(
				Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_RT_API_NAME);
			Id planExitReadOnlyRecTypeId = Utility.getRecordTypeIdByDeveloperName(
				Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_PLANNED_EXIT_READONLY_RT_API_NAME);
			Id unplanExitReadOnlyRecTypeId = Utility.getRecordTypeIdByDeveloperName(
				Beneficiary_Lifecycle_Event__c.SObjectType, Constants.BLE_UNPLANNED_EXIT_READONLY_RT_API_NAME);
			List<Id> lstRecTypeIds = new List<Id> {
				planExitRecTypeId, unplanExitRecTypeId, planExitReadOnlyRecTypeId,
				unplanExitReadOnlyRecTypeId};

			String sFieldsQuery = Utility.getFieldGroupElements(Constants.EXIT_BLE_RESPONSE_FIELD_GROUP);
			String sQuery = 'Select ' + sFieldsQuery +
				'Beneficiary__r.Name,Record_Type__c,Beneficiary__r.Compass_Id__c,Beneficiary__r.ICP__r.Name,' +
				'Beneficiary__r.Religious_Affiliation__c,Beneficiary__r.Formal_Education_Status__c,' +
				'Id,Beneficiary__r.Local_Beneficiary_ID__c,Beneficiary__r.ICP__r.ICP_Id__c,' +
				'RecordType.DeveloperName';
			sQuery +=' from Beneficiary_Lifecycle_Event__c where RecordTypeId in :lstRecTypeIds' +
				' and Compass_Update_Pending__c=true';

			return Database.getQueryLocator(sQuery);
		}

		/**
		 * Method name  : execute
		 * Description  : This method updates Compass for all BLEs queried in start method
		 * Return Type  : void
		 * Parameter    : Database.BatchableContext
		 **/
		public void execute(Database.BatchableContext oBC, List<sObject> lstScope) {

			List<Beneficiary_Lifecycle_Event__c> lstBleEvent = (List <
				Beneficiary_Lifecycle_Event__c> ) lstScope;
			oJsonParserToken = (null == oJsonParserToken) ? JSONParserForToken.getJSONParserForToken() :
				oJsonParserToken;
			System.debug('oJsonParserToken ' + oJsonParserToken);
			if(null == oJsonParserToken) {
				ErrorLogUtility.logIntegrationInfo('Failure', 'Outbound',
					'SendBLEExitInfoToNeuronBatch', 'execute','Neuron', null,
					'Failure in getting token from Neuron. Cannot send Exit updates to Neuron for following Beneficiary Id: '+
					lstBleEvent[0].Beneficiary__r.Local_Beneficiary_ID__c, null, null, null,null);
				return;
			}

			Map<String, List<sObject>> mapOutput = new Map<String, List <
				sObject>>();
			String sJson = null;
			Map<HttpRequest, HttpResponse> mapResponse = new Map<HttpRequest,
				HttpResponse>();

			for(Beneficiary_Lifecycle_Event__c oBle: lstBleEvent) {
				oBle.Reason__c = oBle.Record_Type__c; //For RecordTypeName
				oBle.Comments__c = oBle.Beneficiary__r.Name; //For BeneficiaryName
				oBle.Ben_Life_Cycle_Event_Id_For_Data_Load__c = oBle.Beneficiary__r.ICP__r.Name; //For NewCurrentICPName
				oBle.Other_Reasons_For_Request__c = oBle.Beneficiary__r.Religious_Affiliation__c; //For ReligiousAffiliation
				oBle.Other_Reinstatement_Reason__c = oBle.Beneficiary__r.Formal_Education_Status__c; //For FormalEducationStatus
				oBle.Reason_For_Delay_In_Processing__c = oBle.Beneficiary__r.Compass_Id__c; //For COMPASSId
				oBle.Reinstatement_Description__c = oBle.Beneficiary__r.Local_Beneficiary_ID__c; //For BeneficiaryId
				oBle.Transfer_Instructions__c = oBle.Beneficiary__r.ICP__r.ICP_Id__c; //For NewCurrentICPId

				mapOutput.put(Constants.EXIT_BLE_RESPONSE_FIELD_GROUP, new List <Beneficiary_Lifecycle_Event__c> {oBle});
				try {
					sJson = JSONHandlerMethods.serialize(mapOutput, Constants.EXIT_BLE_DATA_RESPONSE_PROCESS_NAME);
					mapResponse = SendRequestToNeuron.sendInfoToNeuron(sJson, ESB_URL__c.getValues(
							'NeuronURLForExitBLE')
						.Process_ESB_URL__c, oJsonParserToken);

					if(null == mapResponse) {
						ErrorLogUtility.logIntegrationInfo('Failure', 'Outbound',
							'SendBLEExitInfoToNeuronBatch', 'execute',
							'Neuron', null, 'Exit Update to Neuron failed for Beneficiary Id: ' +
							oBle.Reinstatement_Description__c+'. Detailed error would be logged in separate Error Log record'
							, sJson,null, null, null);
						return;
					}
					for(HttpRequest oHttpReq: mapResponse.keySet()) {
						HttpResponse oHttpResponse = mapResponse.get(oHttpReq);
						System.debug('oHttpResponse: ' + oHttpResponse);
						if(String.valueOf(oHttpResponse.getStatusCode()).startsWith('2')) {
							ErrorLogUtility.logIntegrationInfo('Success', 'Outbound',
								'SendBLEExitInfoToNeuronBatch', 'execute', '',oHttpResponse.getStatusCode(),
								'Success in sending Exit Request to Neuron for Beneficiary Id: ' +
								oBle.Reinstatement_Description__c,oHttpReq.getBody(), oHttpResponse.getBody(),
								oHttpResponse.getStatus(),null);
						} else {
							ErrorLogUtility.logIntegrationInfo('Failure', 'Outbound',
								'SendBLEExitInfoToNeuronBatch', 'execute', 'Neuron', oHttpResponse.getStatusCode(),
								'Failure in sending request to Neuron for Beneficairy Id: ' + oBle.Reinstatement_Description__c +
								'. Please see response message or response body for more details',
								oHttpReq.getBody(), oHttpResponse.getBody(), oHttpResponse.getStatus(),null);
						}
					}
					mapOutput.clear();
				} catch(Exception oExp) {
					ErrorLogUtility.logIntegrationInfo('Failure', 'Outbound',
						'SendBLEExitInfoToNeuronBatch', 'execute', 'Neuron', null,
						'Failure in sending request to Neuron for Beneficairy Id: ' + oBle.Reinstatement_Description__c +
						'. Exception: ' + oExp.getMessage() + '. Stack Trace: ' + oExp.getStackTraceString(),
						null, null, null, null);
				} finally {
					updateBLEFlag(lstBleEvent[0].Id, false);
				}
			}
		}

		/**
		 * Method name  : updateBLEFlag
		 * Description  : This method updates Compass_Update_Pending__c flag of BLE
		 * Return Type  : void
		 * Parameter    : Id, Boolean
		 **/
		private void updateBLEFlag(Id bleId, Boolean bIsCompassUpdatePending) {

			Beneficiary_Lifecycle_Event__c oBle = new Beneficiary_Lifecycle_Event__c();
			oBle.Id = bleId;
			oBle.Compass_Update_Pending__c = bIsCompassUpdatePending;
			try {
				update oBle;
			} catch(Exception oEx) {
				ErrorLogUtility.logGeneralError(oEx, 'SendBLEExitInfoToNeuronBatch',
					'updateBLEFlag', 'SFDC CI');
			}
		}

		/**
		 * Method name  : finish
		 * Description  : This method performs tasks that needs to be done afterjob is finished.
		 * Return Type  : void
		 * Parameter    : Database.BatchableContext
		 **/
		public void finish(Database.BatchableContext oBC) {}

	}