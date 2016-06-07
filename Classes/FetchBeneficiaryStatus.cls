/************************************************************************************************** 
Class Name   : FetchBeneficiaryStatus
Created By   : Himanshu Raichandani
Created Date : 03/25/2015
Description  : This class contains Rest method to fetch Beneficiary's Status and send it to 
               requesting client i.e. Neuron
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@RestResource(urlMapping = '/FetchBeneficiaryStatus')
global class FetchBeneficiaryStatus {
    
    /**********************************
    Method Name : fetchBeneficiaryStatus
    Description : This exposed web service method fetches Beneficiary's 
                  status from Salesforce
    Return type : void
    Parameter   : void
    ************************************/
    @HttpPost
    global static void fetchBeneficiaryStatusValue() {
        RestRequest oRequest = RestContext.request;
        RestResponse oResponse = RestContext.response;
        String sJsonResponse = Constants.EMPTY_STRING;
        RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
        List<Account> lstBenef = new List<Account>();
        List<Id> lstBenefId = new List<Id>();
        List<Account> lstBenefQueried = new List<Account>();
        Boolean ifInsertScenario = false;
        try {
            lstBenef = (List<Account> ) JSONHandlerMethods.deserialize(
                oRequest.requestBody.toString()
                .trim(), Constants.FETCH_BENEF_STATUS_REQUEST_PROCESS);
        } catch(Exception oEx) {
            populateInternalServerIntegrationError(oEx, 'fetchBeneficiaryStatus', null);
            return;
        }
        String sLocalBenId = lstBenef[0].Local_Beneficiary_ID__c;

        if(String.IsNotEmpty(sLocalBenId)) {
            String sFieldsQuery = Utility.getFieldGroupElements(Constants.FETCH_BENEF_STATUS_RESPONSE_FIELD_GROUP);
            sFieldsQuery = sFieldsQuery.removeEnd(',');
            String sQuery = 'Select ' + sFieldsQuery;
            sQuery += ' from Account where Local_Beneficiary_ID__c = :sLocalBenId limit 1';
            System.debug('sQuery '+sQuery);
            try {
                lstBenefQueried = Database.query(sQuery);
                 System.debug('**lstBenefQueried'+lstBenefQueried);
            } catch(System.QueryException oQe) {
                populateInternalServerIntegrationError(oQe,'fetchBeneficiaryStatus',null);
                return;
            }
        }
        if(lstBenefQueried.isEmpty()) {
            oResponse.statusCode = 404;
            sJsonResponse = Constants.BENEFICIARY_RECORD_DOESNT_EXISTS;
            oResponse.responseBody = blob.valueOf(sJsonResponse);
            ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
                'FetchBeneficiaryStatus', 'fetchBeneficiaryStatus',
                'Neuron', null, sJsonResponse, oRequest.requestBody.toString()
                .trim(), sJsonResponse, sJsonResponse, null
            );
            return;
        }
        
        Map<String,List<SObject>> outputMap= new Map<String,List<SObject>>();
        outputMap.put(Constants.FETCH_BENEF_STATUS_RESPONSE_FIELD_GROUP,lstBenefQueried);
        sJsonResponse=JSONHandlerMethods.serialize(outputMap,
                        Constants.FETCH_BENEF_STATUS_RESPONSE_PROCESS);
        RestContext.response.responseBody = Blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo('Success', 'Inbound',
            'FetchBeneficiaryStatus', 'fetchBeneficiaryStatus',
            'Neuron', null, 'Success in retrieving Beneficiary Status', oRequest.requestBody.toString()
            .trim(), sJsonResponse, 'OK', null);
    }
        
    /**********************************
    Method Name : populateInternalServerIntegrationError
    Description : This method logs integration info into Error Log objects by
                  calling ErrorLogUtility class
    Return type : void
    Parameter   : Exception oEx, String sMethodName, String sMessage
    ************************************/
    private static void populateInternalServerIntegrationError(Exception oEx,
        String sMethodName, String sMessage) {
        RestContext.response.statusCode = 500;
        String sJsonResponse = (String.isBlank(sMessage)) ? oEx.getMessage() : sMessage;
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
            'FetchBeneficiaryStatus', sMethodName,
            'SFDC CI', null, (String.isBlank(sMessage)) ? 'Line Number: ' + oEx.getLineNumber() +
            ' Exception: ' +
            oEx.getMessage() : sMessage, RestContext.request.requestBody.toString()
            .trim(), sJsonResponse,
            sJsonResponse, oEx);
    }
}