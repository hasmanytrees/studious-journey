/******************************************************************************************************
Class Name         : SendRequestToNeuron
Description        : This class is used for authentication to mashery and then making a call out to
                     the Neuron system. This class is used in various integration classes for this
                     purpose.
Created By         : Himanshu Raichandani
Created On         : 27-Jan-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class SendRequestToNeuron {
    public static HttpResponse oHttpResponse;

    /**
    * Method name  : sendInfoToNeuron
    * Description  : Use this method when JSONParserToken is already in code and you are looping on the information you 
                     need to send to Neuron, eventually saving couple of service calls whiel sending multiple JSONs
    * Return Type  : HttpResponse
    * Parameter    : String, String, JSONParserForToken
    **/
    public static boolean bFlagForR3 = false;
    public static boolean bPUTMethod = false;
    public static boolean bGETMethod = false;
    public static String sXcimToAddress = '';
 
    public static Map<HttpRequest,HttpResponse> sendInfoToNeuron(String sJsonString, String sEndpoint,
        JSONParserForToken oJsonParserToken) {
        String sBody = Constants.EMPTY_STRING;
        oHttpResponse = new HttpResponse();
        Map<HttpRequest,HttpResponse> mapToReturn = new Map<HttpRequest,HttpResponse>();
        try {
            HttpRequest oHttpRequest = new HttpRequest();
            if(!bPUTMethod)
                oHttpRequest.setMethod(Constants.POST_METHOD);
            else if(bPUTMethod)
                oHttpRequest.setMethod(Constants.PUT_METHOD);
            if(bGETMethod){
                oHttpRequest.setMethod('GET');
            }
            if(sXcimToAddress != '')
            {
                oHttpRequest.setHeader('x-cim-GPId',sXcimToAddress);
            }
            oHttpRequest.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
            oHttpRequest.setEndpoint(sEndpoint);
            oHttpRequest.setTimeout(120000);
            String sAuthHeader = 'Bearer ' + String.valueof(oJsonParserToken.access_token);
            oHttpRequest.setHeader(constants.AUTHORIZATION_HEADER, sAuthHeader);

            sBody = sJsonString;
            if(sBody <> ''){
                if(!SendRequestToNeuron.bFlagForR3)
                    sBody = sBody.ReplaceAll('(?i)Null', Constants.EMPTY_STRING);
                oHttpRequest.setBody(sBody);
        }
            Http oHttp = new Http();
            System.debug('HTTP Request: '+sBody);
            if(!test.isRunningTest()){
                oHttpResponse = oHttp.Send(oHttpRequest);
            }
            System.debug('HTTP Response: '+oHttpResponse);
            mapToReturn.put(oHttpRequest,oHttpResponse);
            return mapToReturn;
        } catch(Exception oExp) {
            ErrorLogUtility.logIntegrationInfo('Failure', 'Outbound','SendRequestToNeuron',
                    'sendInfoToNeuron',null, null,'Exception while sending request to External System. Exception: '
                    +oExp.getMessage()+'. Stack Trace: '+oExp.getStackTraceString(),null,null,null,null);
            return null;
        }

    }
}