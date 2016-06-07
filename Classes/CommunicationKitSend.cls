/******************************************************************************************************
Class Name         : CommunicationKitSend
Description        : This is a Queueable controller class for making callouts to external systems
Created By         : Akashdeep Vinnakota 
Created On         : 17-Oct-2015 
******************************************************************************************************/
public class CommunicationKitSend implements Queueable, Database.allowsCallouts {
    public String sResponse;
    public String sEndPoint;
    public String sHTTPVerb;
    public String sGPId;
    public Boolean sImmediateTransfer;

    /**
     * Method name  : CommunicationKitSend
     * Description  : This is constructor of the class responsible for initializing all the variables required
     * Return Type  : N/A
     * Parameter    : JSON String of Params, End Point URL, HTTP Method, GP Id, Immediate Transfer
     **/
    public CommunicationKitSend(String sResponse, String sEndPoint, String sHTTPVerb,
        String sGPId, Boolean sImmediateTransfer) {
        this.sResponse = sResponse;
        this.sEndpoint = sEndpoint;
        this.sHTTPVerb = sHTTPVerb;
        this.sGPId = sGPId;
        this.sImmediateTransfer = sImmediateTransfer;
    }

    /**
     * Method name  : execute
     * Description  : This is a method that makes the callouts to external systems
     * Return Type  : void
     * Parameter    : QueueableContext
     **/
    public void execute(QueueableContext context) {
        JSONParserForToken oJsonParserToken = null;
        oJsonParserToken = (null == oJsonParserToken) ? JSONParserForToken.getJSONParserForToken() :
            oJsonParserToken;
        system.debug('<><><> ' + oJsonParserToken);
        system.debug('<><><>sEndPoint ' + sEndPoint);
        system.debug('<><><> ' + ESB_URL__c.getValues(sEndPoint)
            .Process_ESB_URL__c);
        SendRequestToNeuron.bFlagForR3 = true;
        if(sHTTPVerb == 'PUT')
            SendRequestToNeuron.bPUTMethod = true;

        if(sGPId != null) {
            system.debug('*****sGPId' + sGPId);
            SendRequestToNeuron.sXcimToAddress = sGPId;
        }
        String sESB_URL = ESB_URL__c.getValues(sEndPoint)
            .Process_ESB_URL__c;
        if(!sImmediateTransfer)
            sESB_URL = sESB_URL.replace(Constants.TRUE_LOWER_CASE, Constants.FALSE_LOWER_CASE);
        system.debug('>>>> sESB_URL ' + sESB_URL);
        Map<HttpRequest, HttpResponse> mapResponse = SendRequestToNeuron.sendInfoToNeuron(
            sResponse, sESB_URL,
            oJsonParserToken);
        system.debug('<><><> mapResponse: ' + mapResponse);
        system.debug('<><><> sResponse: ' + sResponse);
        if(null == mapResponse) {
            ErrorLogUtility.logIntegrationInfoWithRetryExt(Constants.FALIURE, Constants.OUTBOUND,
                Constants.CLASS_NAME_COMMUNICATIONKITSEND, Constants.METHOD_NAME_FORCALLOUT,
                Constants.SOURCE_SYSTEM_SFDC_USA, null, Constants.ErrorString_25_FALIURE_TO_SEND_INFO +
                sResponse, sResponse, null, null, null, ESB_URL__c.getValues(sEndPoint)
                .Process_ESB_URL__c,
                sHTTPVerb, sGPId, 'SBCIntegration');
        } else if(mapResponse.Values()[0].getStatusCode() != 200 && mapResponse.Values()[
                0].getStatusCode() != 201) {
            ErrorLogUtility.logIntegrationInfoWithRetryExt(Constants.FALIURE, Constants.OUTBOUND,
                Constants.CLASS_NAME_COMMUNICATIONKITSEND, Constants.METHOD_NAME_FORCALLOUT,
                Constants.SOURCE_SYSTEM_SFDC_USA, mapResponse.Values()[0].getStatusCode(),
                Constants.ErrorString_25_FALIURE_TO_SEND_INFO + sResponse, sResponse,
                mapResponse.Values()[0].getBody(), mapResponse.Values()[0].getStatus(),
                null, ESB_URL__c.getValues(sEndPoint)
                .Process_ESB_URL__c,
                sHTTPVerb, sGPId, 'SBCIntegration');
        } else if(mapResponse.Values()[0].getStatusCode() == 200 || mapResponse.Values()[
                0].getStatusCode() == 201) {
            system.debug('<><><> ' + mapResponse.Values()[0].getBody());
            String sRequest = mapResponse.Values()[0].getBody()
                .trim();
            if(sRequest.contains('"Responses":')) {
                list<SObject> lstSObject = null;
                lstSObject = (list<SObject> ) JSONHandlerMethods.deserialize(sRequest,
                    Constants.COMMUNICATION_RESPONSES_PN);
                set<String> setCommKitName = new set<String>();
                map<String, Communication_Kit__c> mapCommKitName = new map<String,
                    Communication_Kit__c>();
                for(Communication_Kit__c oCommKit: (list<Communication_Kit__c> ) lstSObject) {
                    setCommKitName.add(oCommKit.INT_Communication_Kit_Id__c);
                    mapCommKitName.put(oCommKit.INT_Communication_Kit_Id__c, oCommKit);
                }
                list<Communication_Kit__c> lstQueryCommKit = new list <
                    Communication_Kit__c>();
                lstQueryCommKit = [select Id, Name, Local_GP_Kit_ID__c from Communication_Kit__c where Name IN:
                    setCommKitName
                ];
                for(Communication_Kit__c oCommKit: lstQueryCommKit) {
                    oCommKit.Local_GP_Kit_ID__c = mapCommKitName.get(oCommKit.Name)
                        .Local_GP_Kit_ID__c;
                }
                if(lstQueryCommKit.size()> 0) {
                    List<Database.SaveResult> lstUpdateResults = Database.update(
                        lstQueryCommKit, false);
                    Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                        lstUpdateResults, lstQueryCommKit, 'Communication_Kit__c',
                        'CommunicationKitSend', 'execute', 'SFDC-CI', false);
                }
            }
        }
    }


    /*public map<String, map<String, list <Communication_Kit__c>>> mapWhomToSendCommKitsToSend = new map<String, map<String, list <Communication_Kit__c>>>();
    public CommunicationKitSend(map<String, map<String, list <Communication_Kit__c>>> mapWhomToSendCommKitsToSend){
        this.mapWhomToSendCommKitsToSend = mapWhomToSendCommKitsToSend ;
    }
    public void execute(QueueableContext context){
        for (String sClassName: mapWhomToSendCommKitsToSend.keySet()) {
        if (sClassName == 'SBCCommunicationDetails') {
          for (String sWhomToSend: mapWhomToSendCommKitsToSend.get(sClassName).keySet()) {
            SBCCommunicationDetails.sendSBCCommunicationDetails(sWhomToSend,
              mapWhomToSendCommKitsToSend.get(sClassName).get(sWhomToSend));
          }
        }
        if (sClassName == 'CommunicationUpdates') {
          for (String sWhomToSend: mapWhomToSendCommKitsToSend.get(sClassName).keySet()) {
            CommunicationUpdates.sendCommunicationUpdates(sWhomToSend,
              mapWhomToSendCommKitsToSend.get(sClassName).get(sWhomToSend));
          }
        }
      }

    }*/
}