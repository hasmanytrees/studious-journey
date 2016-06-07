/******************************************************************************************************
    Class Name         : CommitmentUpdates
    Description        : This class receives the list of all the Commitments and update/insert them
                         accordingly.
    Created By         : Rahul Agarwal
    Created On         : 18-Aug-2015
 ******************************************************************************************************/
@
RestResource(urlMapping = '/CommitmentUpdates')
global class CommitmentUpdates {
    /**
     * Method name  : reqCommitmentUpdates
     * Description  : This method will receive the JSON and process it
     * Return Type  : void
     * Parameter    : void
     **/
    @
    HttpPost
    global static void reqCommitmentUpdates() {
            RestRequest request = RestContext.request;
            RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
            String sRequest = request.requestBody.toString()
                .trim();
            // Deserealizing the JSON
            list<SObject> lstSObject = new list<SObject>();
            CommunicationKitHandler.responseForValidationWrapper oDesJSON =
                CommunicationKitHandler.deserializeJson(sRequest, true, Constants.COMMITMENT_UPDATES_REQ_PN);
            system.debug('<><><> ' + oDesJSON);
            if(oDesJSON.bError) {
                populateInternalServerIntegrationError(oDesJSON.oEx, Constants.METHOD_NAME_REQCOMMITMENTUPDATES,
                    null);
                return;
            } else {
                lstSObject = oDesJSON.lstSObject;
            }

            list<Commitment__c> lstCommitmentFromJSON = new list<Commitment__c>();
            for(SObject oVar: lstSObject) {
                Commitment__c oCommit = new Commitment__c();
                oCommit = (Commitment__c) oVar;
                lstCommitmentFromJSON.add(oCommit);
            }

            set<String> setCommitmentId = new set<String>();
            set<String> setBenGlobalId = new set<String>();
            set<String> setSupLegacyId = new set<String>();
            set<String> setSupGlobalId = new set<String>();
            set<String> setBenLegacyId = new set<String>();
            for(Commitment__c oCommit: lstCommitmentFromJSON) {
                if(oCommit.COMPASS_cm_pk__c != null && oCommit.COMPASS_cm_pk__c != '')
                    setCommitmentId.add(oCommit.COMPASS_cm_pk__c);
                if(oCommit.BEN_INT_Global_ID__c != null)
                    setBenGlobalId.add(oCommit.BEN_INT_Global_ID__c);
                if(oCommit.COMPASS_con_pk__c != null)
                    setSupLegacyId.add(oCommit.COMPASS_con_pk__c);
                if(oCommit.SUP_INT_Global_ID__c != null)
                    setSupGlobalId.add(oCommit.SUP_INT_Global_ID__c);
                if(oCommit.COMPASS_child_id__c != null)
                    setBenLegacyId.add(oCommit.COMPASS_child_id__c);
            }
            // Fetching all the existing commitments based in the legacy commitment id
            list<Commitment__c> lstExistingCommitment = new list<Commitment__c>();
            lstExistingCommitment = [Select Id, COMPASS_cm_pk__c, BEN_ID__c, SUP_ID__c from Commitment__c where COMPASS_cm_pk__c IN:
                setCommitmentId
            ];

            map<String, Commitment__c> mapCommitmentLegacyId = new map<String,
                Commitment__c>();

            for(Commitment__c oCommit: lstExistingCommitment) {
                mapCommitmentLegacyId.put(oCommit.COMPASS_cm_pk__c, oCommit);
            }
            // Querying all the coomunication with sent beneficiary and supporter
            map<Id, set<Id>> mapBenSupId = new map<Id, set<Id>>();
            list<Communication_Kit__c> lstCommKit = new list<Communication_Kit__c>
                ();
            lstCommKit = [select Id, BEN_ID__c, SUP_ID__c from Communication_Kit__c where
                BEN_ID__r.Global_Number__c IN: setBenGlobalId OR BEN_ID__r.Compass_Id__c
                IN: setBenLegacyId OR SUP_ID__r.Global_Number__c IN:
                setSupGlobalId OR SUP_ID__r.GP_Supporter_Id__c IN: setSupLegacyId
            ];
            for(Communication_Kit__c oCommKit: lstCommKit) {
                if(oCommKit.BEN_ID__c != null) {
                    if(!mapBenSupId.containsKey(oCommKit.BEN_ID__c)) {
                        mapBenSupId.put(oCommKit.BEN_ID__c, new set<Id>());
                    }
                    if(oCommKit.SUP_ID__c != null)
                        mapBenSupId.get(oCommKit.BEN_ID__c)
                        .add(oCommKit.SUP_ID__c);
                }
            }

            //Fetching all the beneficiary and suuporter based on passed details
            map<Id, Account> mapAllBenAndSup = new map<Id, Account>();
            try {
                mapAllBenAndSup = new map<Id, Account> ([select Id, RecordTypeId,
                    Global_Number__c, Local_Beneficiary_Id__c, GP_Supporter_Id__c,
                    BEN_INT_Have_Correspondent__c, Compass_Id__c from Account where Global_Number__c IN:
                    setSupGlobalId OR Global_Number__c IN: setBenGlobalId OR GP_Supporter_Id__c IN:
                    setSupLegacyId OR Compass_Id__c IN: setBenLegacyId
                ]);
            } catch(QueryException oEx) {
                populateInternalServerIntegrationError(oEx, Constants.METHOD_NAME_REQCOMMITMENTUPDATES,
                    null);
                return;
            }

            // Arranging all supporters and beneficiaries
            map<String, map<String, Account>> mapAccount = new map <
                String, map <
                String, Account>> {
                    Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID => new map<String,
                    Account>(),
                    Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID => new map<String,
                    Account>(),
                    Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID => new map<String,
                    Account>(),
                    Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID => new map<String,
                    Account>(),
                    Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID => new map<String,
                    Account>()
                };


            for(Account oAcc: mapAllBenAndSup.Values()) {
                if(oAcc.Local_Beneficiary_Id__c == null && oAcc.Global_Number__c != null)
                    mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_SUPPORTER_ID)
                    .put(oAcc.Global_Number__c,
                        oAcc);
                if(oAcc.GP_Supporter_Id__c != null)
                    mapAccount.get(Constants.CODE_VARIABLE_LEGACY_SUPPORTER_ID)
                    .put(oAcc.GP_Supporter_Id__c,
                        oAcc);
                if(oAcc.Compass_Id__c != null)
                    mapAccount.get(Constants.CODE_VARIBALE_LEGACY_BENEFICIARY_ID)
                    .put(oAcc.Compass_Id__c,
                        oAcc);
                if(oAcc.Local_Beneficiary_Id__c != null && oAcc.Global_Number__c != null)
                    mapAccount.get(Constants.CODE_VARIABLE_GLOBAL_BENEFICIARY_ID)
                    .put(oAcc.Global_Number__c,
                        oAcc);
                if(oAcc.Local_Beneficiary_Id__c != null)
                    mapAccount.get(Constants.CODE_VARIABLE_LOCAL_BENEFICIARY_ID)
                    .put(oAcc.Local_Beneficiary_Id__c,
                        oAcc);
            }

            //Querying all commitments
            list<Commitment__c> lstCommitments = new list<Commitment__c>
                ();
            try {
                lstCommitments = [Select Id, Status__c, Relationship_Type__c, BEN_Id__c,
                    SUP_Id__c, SUP_Id__r.Global_Partner__r.Opted_in_for_SDL__c,
                    Supporter_Correspondence_Language__c, BEN_Id__r.Correspondence_Language__c from Commitment__c where(
                        SUP_Id__r.Global_Number__c IN: setSupGlobalId OR BEN_Id__r.Global_Number__c IN:
                        setBenGlobalId OR SUP_Id__r.GP_Supporter_Id__c IN: setSupLegacyId) AND Status__c = :
                    Constants.COMMITMENT_STATUS_ACTIVE
                ];
            } catch(QueryException oEx) {
                populateInternalServerIntegrationError(oEx, Constants.METHOD_NAME_REQCOMMITMENTUPDATES,
                    null);
                return;
            }


            // store BenId + Supid for all active commitments
            map<Id, map<Id, Commitment__c>> mapHaveActiveCommitment = new map<Id,
                map<Id, Commitment__c>>();
            for(Commitment__c oCommit: lstCommitments) {
                if(!mapHaveActiveCommitment.containsKey(oCommit.BEN_Id__c))
                    mapHaveActiveCommitment.put(oCommit.BEN_Id__c, new map<Id, Commitment__c>
                        ());
                mapHaveActiveCommitment.get(oCommit.BEN_Id__c)
                    .put(oCommit.SUP_Id__c,
                        oCommit);
            }

            for(Commitment__c oCommit: lstCommitmentFromJSON) {
                // If commitment already exist
                if(oCommit.COMPASS_cm_pk__c != null && mapCommitmentLegacyId.containsKey(
                        oCommit.COMPASS_cm_pk__c)) {
                    oCommit.Id = mapCommitmentLegacyId.get(oCommit.COMPASS_cm_pk__c)
                        .Id;
                }
                //Relationship Type Validation
                if(null == oCommit.Relationship_Type__c || (oCommit.Relationship_Type__c !=
                        Constants.COMMITMENT_TYPE_SPONSORSHIP && oCommit.Relationship_Type__c !=
                        Constants.COMMITMENT_TYPE_CORRESPONDENT)) {
                    populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQCOMMITMENTUPDATES,
                        Constants.ErrorString_23_INCORRECT_RELATIONSHIP_TYPE + Constants.ErrorString_19_HYPHEN +
                        oCommit.Relationship_Type__c, oCommit.COMPASS_child_id__c, oCommit.COMPASS_con_pk__c ,oCommit.BEN_INT_Global_Id__c, oCommit.SUP_INT_Global_Id__c);
                    return;
                }
                // Ben Ids Validation
                CommunicationKitHandler.responseForValidationWrapper oBenValidation =
                    CommunicationKitHandler.BeneficiaryValidationForIntegrations(oCommit.BEN_INT_Global_Id__c,
                        oCommit.COMPASS_child_id__c, null, mapAccount);
                if(oBenValidation.bError) {
                    populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQCOMMITMENTUPDATES,
                        oBenValidation.sValue, oCommit.COMPASS_child_id__c, oCommit.COMPASS_con_pk__c , oCommit.BEN_INT_Global_Id__c, oCommit.SUP_INT_Global_Id__c);
                    return;
                } else {
                    oCommit.BEN_ID__c = oBenValidation.sValue;
                }
                system.debug('oCommit.SUP_INT_Global_Id__c' + oCommit.SUP_INT_Global_Id__c);
                system.debug('oCommit.COMPASS_con_pk__c' + oCommit.COMPASS_con_pk__c);
                system.debug('oCommit.Relationship_Type__c' + oCommit.Relationship_Type__c);
                system.debug('mapAccount' + mapAccount);


                // SUPPORRTER VALIDATIONS
                CommunicationKitHandler.responseForValidationWrapper oSupValidation =
                    CommunicationKitHandler.SupporterValidationForIntegrations(oCommit.SUP_INT_Global_Id__c,
                        oCommit.COMPASS_con_pk__c, oCommit.Relationship_Type__c, mapAccount);
                if(oSupValidation.bError) {
                    populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQCOMMITMENTUPDATES,
                        oSupValidation.sValue, oCommit.COMPASS_child_id__c, oCommit.COMPASS_con_pk__c , oCommit.BEN_INT_Global_Id__c, oCommit.SUP_INT_Global_Id__c);
                    return;
                } else {
                    oCommit.SUP_ID__c = oSupValidation.sValue;
                }

                /* MV-Start: Adding End date not future date check */    
                if(oCommit.End_Date__c != null && !(oCommit.End_Date__c > Date.today())) {
                    oCommit.Status__c = Constants.COMMITMENT_STATUS_INACTIVE;
                   }
                 /* MV-End*/

                // If the commitment record is a new commitment record
                if(null == oCommit.COMPASS_cm_pk__c || (oCommit.COMPASS_cm_pk__c != null &&
                        !mapCommitmentLegacyId.containsKey(oCommit.COMPASS_cm_pk__c))) {
                    // Start Date cannot be empty

                    if(null == oCommit.Start_Date__c) {
                        populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQCOMMITMENTUPDATES,
                            Constants.ErrorString_27_START_DATE + Constants.ErrorString_1, 
                            oCommit.COMPASS_child_id__c, oCommit.COMPASS_con_pk__c , oCommit.BEN_INT_Global_Id__c, oCommit.SUP_INT_Global_Id__c);
                        return;
                    }




                    // Checking if Beneficiary already contain an active commitment of same relationship type
                    if(mapHaveActiveCommitment.containsKey(oCommit.BEN_Id__c) &&
                        mapHaveActiveCommitment.get(oCommit.BEN_ID__c)
                        .containsKey(oCommit.SUP_ID__c) &&
                        mapHaveActiveCommitment.get(oCommit.BEN_ID__c)
                        .get(oCommit.SUP_ID__c)
                        .Relationship_Type__c ==
                        oCommit.Relationship_Type__c) {
                        populateInternalServerIntegrationError(null, Constants.METHOD_NAME_REQCOMMITMENTUPDATES,
                            Constants.ErrorString_28_ALREADY_HAVE_COMMITMENT + oCommit.Relationship_Type__c
                        , oCommit.COMPASS_child_id__c, oCommit.COMPASS_con_pk__c , oCommit.BEN_INT_Global_Id__c, oCommit.SUP_INT_Global_Id__c);
                        return;
                    }
                }
                // checking for new sponsor checkbox
                if(null == oCommit.Id && mapBenSupId.containsKey(oCommit.BEN_ID__c) &&
                    mapBenSupId.get(oCommit.BEN_ID__c)
                    .contains(oCommit.SUP_ID__c)) {
                    oCommit.New_Sponsor_Letter_Required__c = false;
                } else if(null == oCommit.Id) {
                    oCommit.New_Sponsor_Letter_Required__c = true;
                }
            }
            try {
                upsert lstCommitmentFromJSON;
            } catch(Exception oEx) {
                populateInternalServerIntegrationError(oEx, Constants.METHOD_NAME_REQCOMMITMENTUPDATES,
                    null);
                return;
            }
            RestContext.response.statusCode = 200;
            String sJsonResponse = Constants.Commitment_Updates_SuccesRes;
            RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        }
        /**
         * Method name  : populateInternalServerIntegrationError
         * Description  : This method is used to log error in error log and respond the same
         * Return Type  : void
         * Parameter    : Exception, String, String
         **/
    private static void populateInternalServerIntegrationError(Exception oEx,
        String sMethodName, String sMessage) {
        RestContext.response.statusCode = 500;
        SYSTEM.DEBUG(sMessage);
        String sErrorMessage = (String.isBlank(sMessage)) ? oEx.getMessage() :
            sMessage;
        String sJsonResponse = Constants.CONTENT_FAILURE_RESPONSE +
            sErrorMessage + '"}}';
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo(Constants.FALIURE, Constants.INBOUND,
            Constants.METHOD_NAME_REQCOMMITMENTUPDATES, sMethodName,
            Constants.SOURCE_SYSTEM_SFDC_CI, null, (String.isBlank(sMessage)) ?
            Constants.Commitment_Updates_LineNo + oEx.getLineNumber() +
            Constants.Commitment_Updates_Exec +
            oEx.getMessage() : sMessage, RestContext.request.requestBody.toString()
            .trim(), sJsonResponse,
            sJsonResponse, oEx);
    }
    
    private static void populateInternalServerIntegrationError(Exception oEx,
        String sMethodName, String sMessage, String LegBenId, String LegSupId, String GlobalBenId, String GlobalSupId) {
        RestContext.response.statusCode = 500;
        SYSTEM.DEBUG(sMessage);
        String sErrorMessage = (String.isBlank(sMessage)) ? oEx.getMessage() :
            sMessage;
        String sJsonResponse = Constants.CONTENT_FAILURE_RESPONSE +
            sErrorMessage + Constants.SBC_Commitment_LegBenId + LegBenId + Constants.SBC_Commitment_LegSupId + LegSupId +
            Constants.SBC_Commitment_GlobalBenId + GlobalBenId + Constants.SBC_Commitment_GlobalSupId + GlobalSupId +'" }}';
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo(Constants.FALIURE, Constants.INBOUND,
            Constants.METHOD_NAME_REQCOMMITMENTUPDATES, sMethodName,
            Constants.SOURCE_SYSTEM_SFDC_CI, null, (String.isBlank(sMessage)) ?
            Constants.Commitment_Updates_LineNo + oEx.getLineNumber() +
            Constants.Commitment_Updates_Exec +
            oEx.getMessage() : sMessage, RestContext.request.requestBody.toString()
            .trim(), sJsonResponse,
            sJsonResponse, oEx);
    }
}