/******************************************************************************************************
Class Name         : BeneficiaryStatusUpdateRestService
Description        : This class contains Rest methods to update Beneficiary Sponsorship status sent by Neuron.
Created By         : Himanshu Raichandani
Created On         : 03-Feb-2015 
******************************************************************************************************/
 
@RestResource(urlMapping = '/BeneficiaryStatusUpdate')
global class BeneficiaryStatusUpdateRestService {
 
    /**********************************
    Method Name : updateBenefeciaryStatus
    Description : This exposed web service updates Beneficiary Sponsorship status sent by Neuron.
    Return type : void
    Parameter   : void
    ************************************/
    @HttpPost
    global static void updateBenefeciaryStatus() {
        RestRequest oRequest = RestContext.request;
        RestResponse oResponse = RestContext.response;  
        String sJsonResponse = Constants.EMPTY_STRING;
        RestContext.response.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
        List<Account> lstBenef = new List<Account>();
        try {
            lstBenef = (List<Account> ) JSONHandlerMethods.deserialize(
                oRequest.requestBody.toString()
                .trim(), Constants.UPDATE_BENEF_STATUS_PROCESS_NAME);
        } catch(Exception oEx) {
            populateInternalServerIntegrationError(oEx,'updateBenefeciaryStatus',null);
            return;
        }
        Map<String, String> mapLocalBenefIdToStatus = new Map<String, String>
            ();
        Map<String, String> mapCompassIdToStatus = new Map<String, String>();
        Map<String, String> mapCompassIdToLocalBenefId = new Map<String, String>
            ();
        Map<String, String> mapLocalBenefIdToCompassId = new Map<String, String>
            ();
        Map<String, Date> mapLocalBenefIdToDate = new Map<String, Date>();
        Map<String, Date> mapCompassIdToDate = new Map<String, Date>();
        List<Account> lstBenefToUpdate = new List<Account>();
        List<Beneficiary_Lifecycle_Event__c> lstBLEToUpdate = new List<Beneficiary_Lifecycle_Event__c>
            ();
 
        for(Account oBenef: lstBenef) {
            if(!String.isEmpty(oBenef.Available_Banks__c)) {
                mapLocalBenefIdToStatus.put(oBenef.Available_Banks__c, oBenef.Sponsorship_Status__pc);
                mapLocalBenefIdToCompassId.put(oBenef.Available_Banks__c, oBenef.Compass_Id__c);
                if(null<>oBenef.Actual_First_Attendance_Date__c)               
                mapLocalBenefIdToDate.put(oBenef.Available_Banks__c, oBenef.Actual_First_Attendance_Date__c);
            }
            if(!String.isEmpty(oBenef.Compass_Id__c)) {
                mapCompassIdToStatus.put(oBenef.Compass_Id__c, oBenef.Sponsorship_Status__pc);
                mapCompassIdToLocalBenefId.put(oBenef.Compass_Id__c, oBenef.Available_Banks__c);
                if(null<>oBenef.Actual_First_Attendance_Date__c) 
                mapCompassIdToDate.put(oBenef.Compass_Id__c,oBenef.Actual_First_Attendance_Date__c);
            }
        }
        Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
        Id bleRegistRecId = Utility.getRecordTypeIdByDeveloperName(Beneficiary_Lifecycle_Event__c.SObjectType,
            Constants.BLE_REGISTRATION_RT_API_NAME);
        Map<Id, Account> mapIdToBenef = new Map<Id, Account>();
        try {
            mapIdToBenef = new Map<Id, Account> ([Select Id,
                Local_Beneficiary_Id__c, Compass_Id__c, Sponsorship_Status__pc from Account where Local_Beneficiary_Id__c in
                : mapLocalBenefIdToStatus.keySet() AND RecordtypeID = : cdspRecTypeId
            ]);
        } catch(Exception oEx) {
            populateInternalServerIntegrationError(oEx,'updateBenefeciaryStatus',null);
            return; 
        }
        Map<id,Beneficiary_Lifecycle_Event__c> mapBenfToBLE  = new Map<id, Beneficiary_Lifecycle_Event__c>();
         try{
            mapBenfToBLE  = new Map<id, Beneficiary_Lifecycle_Event__c>([Select Beneficiary__r.id,Beneficiary__r.Compass_Id__c,Date_of_Action__c,
               Beneficiary__r.Local_Beneficiary_Id__c from Beneficiary_Lifecycle_Event__c where Beneficiary__r.Local_Beneficiary_Id__c in
               : mapLocalBenefIdToDate.keySet() AND RecordtypeID = : bleRegistRecId and Beneficiary__r.RecordtypeID = : cdspRecTypeId
                ]);
         } catch(Exception oEX){
         
         populateInternalServerIntegrationError(oEx,'updateBenefeciaryStatus',null);
            return; 
         }  
        
        for(Id benefId: mapIdToBenef.keySet()) {
            Account oAcc = mapIdToBenef.get(benefId);
            if(null<> oAcc.Compass_Id__c && mapCompassIdToStatus.keySet()
                .contains(oAcc.Compass_Id__c)) {
                //oAcc.Sponsorship_Status__pc = mapCompassIdToStatus.get(oAcc.Compass_Id__c);
                oAcc.Local_Beneficiary_Id__c = mapCompassIdToLocalBenefId.get(oAcc.Compass_Id__c);
                lstBenefToUpdate.add(oAcc);
            } else if(null<> oAcc.Local_Beneficiary_Id__c && mapLocalBenefIdToStatus.keySet()
                .contains(oAcc.Local_Beneficiary_Id__c)) {
                //oAcc.Sponsorship_Status__pc = mapLocalBenefIdToStatus.get(oAcc.Local_Beneficiary_Id__c);
                oAcc.Compass_Id__c = mapLocalBenefIdToCompassId.get(oAcc.Local_Beneficiary_Id__c);
                lstBenefToUpdate.add(oAcc);
            }
        }
 
        if(!mapBenfToBLE.isEmpty()){
        for(Id bleBenfId : mapBenfToBLE.keySet() )
                 {
                 Beneficiary_Lifecycle_Event__c oble = mapBenfToBLE.get(bleBenfId);
                 if((null<> oble.Beneficiary__r.Local_Beneficiary_Id__c )&& (mapLocalBenefIdToDate.keySet()
                .contains(oble.Beneficiary__r.Local_Beneficiary_Id__c))&&(oble.Date_of_Action__c == Null))
                  {                                         
                    oble.Date_of_Action__c = mapLocalBenefIdToDate.get(oble.Beneficiary__r.Local_Beneficiary_Id__c) ;
                    lstBLEToUpdate.add(oble);                                     
                   }
                 else if((null<>oble.Beneficiary__r.Compass_Id__c) && (mapCompassIdToDate.keySet()
                .contains(oble.Beneficiary__r.Compass_Id__c))&&(oble.Date_of_Action__c == Null))
                  {   
                  oble.Date_of_Action__c = mapCompassIdToDate.get(oble.Beneficiary__r.Compass_Id__c) ;
                  lstBLEToUpdate.add(oble);                                
                 }                  
                }
               } 
 
        if(!lstBenefToUpdate.isEmpty()) {           
            if(!lstBLEToUpdate.isEmpty()){                         
            List<Database.SaveResult> lstUpdateBLEResults = Database.update(
            lstBLEToUpdate, false);  
             Map<Id, List<String>> mapBLEToErrorMsg; mapBLEToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateBLEResults , lstBLEToUpdate, 'Beneficiary_Lifecycle_Event__c',
                    'BeneficiaryStatusUpdateRestService', 'updateBenefeciaryStatus',
                    'SFDC CI', false);
            if(!mapBLEToErrorMsg.isEmpty()) {
                String sErrorMessage = Constants.EMPTY_STRING;
                for(Id bleId: mapBLEToErrorMsg.keySet()){
                    for(String sErrorMsg: mapBLEToErrorMsg.get(bleId)){
                        sErrorMessage+=sErrorMsg;
                    }
                }
                populateInternalServerIntegrationError(null,'updateBenefeciaryStatus',sErrorMessage);
                return; 
            }                          
            }    
            List<Database.SaveResult> lstUpdateResults = Database.update(
                lstBenefToUpdate, false);       
            Map<Id, List<String>> mapIdToErrorMsg =
                ErrorLogUtility.logDMLError(lstUpdateResults, lstBenefToUpdate, 'Account',
                    'BeneficiaryStatusUpdateRestService', 'updateBenefeciaryStatus',
                    'SFDC CI', false);
            if(!mapIdToErrorMsg.isEmpty()) {
                String sErrorMessage = Constants.EMPTY_STRING;
                for(Id accountId: mapIdToErrorMsg.keySet()){
                    for(String sErrorMsg: mapIdToErrorMsg.get(accountId)){
                        sErrorMessage+='  '+sErrorMsg;
                    }
                }
                populateInternalServerIntegrationError(null,'updateBenefeciaryStatus',sErrorMessage);
                return; 
            }
            RestContext.response.responseBody = Blob.valueOf(Constants.OK);
            ErrorLogUtility.logIntegrationInfo('Success', 'Inbound',
            'BeneficiaryStatusUpdateRestService', 'updateBenefeciaryStatus',
            '', null, 'Success in Beneficiary status update', oRequest.requestBody.toString()
            .trim(), Constants.OK, 'OK',null);
        }
        else{
            oResponse.statusCode = 400;
            sJsonResponse = Constants.SFDC_BAD_REQUEST_RESPONSE;
            oResponse.responseBody = blob.valueOf(sJsonResponse);
            ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
                'BeneficiaryStatusUpdateRestService', 'updateBenefeciaryStatus',
                'Neuron', null, 'Error in request. Beneficiary not found with ChildKey and CompassChildKey sent in request', oRequest.requestBody.toString()
                .trim(), sJsonResponse, sJsonResponse,null
            );
        }
    }
    
    /**********************************
    Method Name : populateInternalServerIntegrationError
    Description : This method logs integration info into Error Log objects by
                  calling ErrorLogUtility class
    Return type : void
    Parameter   : Exception oEx, String sMethodName, String sMessage
    ************************************/
    private static void populateInternalServerIntegrationError(Exception oEx, String sMethodName, String sMessage){
        RestContext.response.statusCode = 500;
        String sErrorMessage = (String.isBlank(sMessage))?oEx.getMessage():sMessage;
        String sJsonResponse = '{"response": {"status": "Failure", "message": "'+sErrorMessage+'"}}';
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        ErrorLogUtility.logIntegrationInfo('Failure', 'Inbound',
            'BeneficiaryStatusUpdateRestService', sMethodName,
            'SFDC CI', null, (String.isBlank(sMessage))?'Line Number: ' + oEx.getLineNumber() + ' Exception: ' +
            oEx.getMessage():sMessage, RestContext.request.requestBody.toString()
            .trim(),sJsonResponse ,
            sJsonResponse,oEx);
    }
}