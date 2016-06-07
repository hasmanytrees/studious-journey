/******************************************************************************************************
Class Name         : SendBenefInfoToUS
Description        : This class is used for sending Beneficiary Mini Profile to US.
Created By         : Himanshu Raichandani
Created On         : 20-Aug-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class SendBenefInfoToUS implements Queueable,  Database.AllowsCallouts{

    private Set<Id> setBenefIds = null;
    
    public SendBenefInfoToUS(Set<Id> setBenefIds) {
        this.setBenefIds = setBenefIds;
    }
    
    /*
    * Method name  : execute
    * Description  : This method sends Beneficiary mini profile to US.
    * Return Type  : QueueableContext
    * Parameter    : void
    */
    public void execute(QueueableContext context) {
    
        String sFieldsQuery = Utility.getFieldGroupElements(Constants.SEND_BENEF_INFO_TO_US_FIELD_GROUP);
        sFieldsQuery = sFieldsQuery.removeEnd(',');
        String sQuery = 'Select ' + sFieldsQuery + ' from Account where Id in :setBenefIds';
        System.debug('sQuery '+sQuery);
        List<Account> lstBenefQueried = new List<Account>();
        try {
            lstBenefQueried = Database.query(sQuery);
        } 
        catch(System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'SendBenefInfoToUS',
            'execute', 'SFDC CI');
            return;
        }
        System.debug('lstBenefQueried: ' + lstBenefQueried);
        try{
            String sESBUrl = ESB_URL__c.getValues(Constants.USA_ESB_URL_FOR_BENEF_UPDATES).Process_ESB_URL__c;
            if(!lstBenefQueried.isEmpty()) {
                for(Account oBenef: lstBenefQueried) {
                    oBenef.Church_Name_Local_Language__c = Label.Compasssion_USA_Global_Partner_Name;
                    List<Account> lstBenefToSend = new List<Account>{oBenef};
                    Map<String, List<sObject>> mapOutput = new Map<String, List <
                    sObject>>();
                    mapOutput.put(Constants.SEND_BENEF_INFO_TO_US_FIELD_GROUP, lstBenefToSend);
                    String sResponse = JSONHandlerMethods.serialize(mapOutput,
                    Constants.SEND_BENEF_INFO_TO_US_PROCESS);
                    System.debug('sResponse: ' + sResponse);
                    
                    JSONParserForToken oJsonParserToken = JSONParserForToken.getJSONParserForToken();
                    System.debug('oJsonParserToken: ' + oJsonParserToken);
                    if(null == oJsonParserToken) {
                        ErrorLogUtility.logIntegrationInfoWithRetryExt('Failure', 'Outbound',
                        'SendBenefInfoToUS', 'sendBenefInfo',
                        'Mashery', null, Constants.Mashery_Err_In_Benef_US_Integ +setBenefIds, 
                         sResponse, null, null, null,sESBUrl,Constants.POST_METHOD, null, 'SendBenefInfoToUS');
                        return;
                    }
                    Map<HttpRequest, HttpResponse> mapReqResp = SendRequestToNeuron.sendInfoToNeuron(
                    sResponse, sESBUrl, oJsonParserToken);
                    
                    if(null == mapReqResp) {
                        ErrorLogUtility.logIntegrationInfoWithRetryExt('Failure', 'Outbound',
                        'SendBenefInfoToUS', 'sendBenefInfo',
                        'USA', null,Constants.ERR_IN_BENEF_US_INTEG +setBenefIds,
                         sResponse, null, null, null,sESBUrl ,Constants.POST_METHOD, null, 'SendBenefInfoToUS');
                    } 
                    else {
                        HttpResponse oResponse = (mapReqResp.values()
                        .size()> 0) ? mapReqResp.values()[0] : null;
                        if(null<> oResponse && oResponse.getStatusCode() != 200 && oResponse.getStatusCode() !=
                        201) {
                            ErrorLogUtility.logIntegrationInfoWithRetryExt('Failure', 'Outbound',
                            'SendBenefInfoToUS', 'sendBenefInfo',
                            'USA', oResponse.getStatusCode(),Constants.ERR_IN_BENEF_US_INTEG +setBenefIds,
                            sResponse, oResponse.getBody(), oResponse.getStatus(),
                            null,sESBUrl,Constants.POST_METHOD, null, 'SendBenefInfoToUS');
                        }
                    }
                }
            }
        }
        catch(Exception oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'SendBenefInfoToUS',
            'execute', 'SFDC CI');
            return;
        }
    }
}