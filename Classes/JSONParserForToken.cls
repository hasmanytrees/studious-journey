/******************************************************************************************************
Class Name         : JSONParserForToken 
Description        : This is single Class which is called before any Neuron call in order to get authorization token
Created By         : Himanshu Raichandani
Created On         : 23-Jan-2015
******************************************************************************************************/
public class JSONParserForToken {

    public String sId;
    public String sIssuedAt;
    public String token_type;
    public String sInstanceUrl;
    public String sSignature;
    public String access_token;

    /**
     * Method name  : parse
     * Description  : This method calls to OOB deserialize methof of JSON class
     * Return Type  : JSONParserForToken
     * Parameter    : String json
     **/
    public static JSONParserForToken parse(String json) {
        return(JSONParserForToken) System.JSON.deserialize(json, JSONParserForToken.class);
    }

    /**
     * Method name  : getJSONParserForToken
     * Description  : This method interacts with Neuron for authorization and returns valid token.
     * Return Type  : JSONParserForToken
     * Parameter    : void
     **/
    public static JSONParserForToken getJSONParserForToken() {
        HttpResponse oHttpResponse = new HttpResponse();
        String sBody = '';
        Boolean bSuccessCode = false;
        JSONParserForToken oJT = null;
        try {
            HttpRequest oHttpRequest = new HttpRequest();
            oHttpRequest.setMethod(Constants.POST_METHOD);
            oHttpRequest.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_X_WWW_FORM_URLENCODED);
            oHttpRequest.setHeader(Constants.HOST_HEADER, ESB_URL__c.getValues(
                    'NeuronEndpointSettings')
                .Neuron_Domain__c);
            oHttpRequest.setHeader(Constants.CONTENT_LENGTH, Constants.CONTENT_LENGTH_46);
            oHttpRequest.setHeader(Constants.CONNECTION, Constants.KEEP_ALIVE);
            oHttpRequest.setEndpoint(ESB_URL__c.getValues('NeuronEndpointSettings')
                .Neuron_Endpoint__c);
            oHttpRequest.setTimeout(120000);
            String sUserName = ESB_URL__c.getValues('NeuronEndpointSettings')
                .Username__c;
            String sPassword = ESB_URL__c.getValues('NeuronEndpointSettings')
                .Password__c;
            Blob blobHeaderValue = Blob.valueOf(sUserName + ':' + sPassword);
            String sAuthHeader = Constants.BASIC_AUTHHEADER + EncodingUtil.base64Encode(
                blobHeaderValue);
            oHttpRequest.setHeader(Constants.AUTHORIZATION_HEADER, sAuthHeader);

            sBody = Constants.BODY_GRANT_TYPE;
            oHttpRequest.setBody(sBody);
            System.debug('@@@oHttpRequest'+oHttpRequest);
            System.debug('@@@oHttpRequest'+oHttpRequest.getBody());
            Http http = new Http();
            if(!test.isrunningtest()){
                oHttpResponse = http.Send(oHttpRequest);
                System.debug('@@@oHttpResponse'+oHttpResponse);
                System.debug('@@@oHttpResponse.getBody()'+oHttpResponse.getBody());
                System.debug('@@@oHttpResponse.getStatusCode()'+oHttpResponse.getStatusCode());
            }
            else{
                oHttpResponse.setBody('{"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSIsImtpZCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSJ9.eyJjbGllbnRfaWQiOiJjbGllbnQiLCJzY29wZSI6WyJyZWFkIiwid3JpdGUiXSwiaXNzIjoiaHR0cHM6Ly9pZHNydjMuY29tIiwiYXVkIjoiaHR0cHM6Ly9pZHNydjMuY29tL3Jlc291cmNlcyIsImV4cCI6MTQyNzgwOTQ2OCwibmJmIjoxNDI3ODA1ODY4fQ.OLovbmCYb3PNgmrSDEBdO-XvNEBl2dJeSx1xin6YlQy_eei6OMHE4Z-OitxSPNz-SKH5WPIug3sqjP-R9tPTjp7w-EWxvQ0r70HOagZn6TlzlJyXNbSPH9Zs6pYd_h3Mb5IMXOVVjpqtWEWAcd_FGtbv13xzP1sfoS5Anh_T1EOSozwdBYq6GwQqws4UIQ5tkuNXe5pisqIk62MEBzqnu2Rl-53WJAou6JITk1hZMI0jvF1WRXlg7VZrifN4O6aNkGhnlWZLn0tEhlRKkPNm_IbjCwpa-PQs0S_qFReByQ5EQ7__j9k0Y9--3qnp4ZhIq1PJFOz56I-RdkpMQQdcLg","expires_in":3600,"token_type":"Bearer"}');
                oHttpResponse.setStatusCode(200);
            } 
            bSuccessCode = String.valueOf(oHttpResponse.getStatusCode())
                .startsWith('2');
            if(bSuccessCode) {
                oJT = JSONParserForToken.parse(oHttpResponse.getBody());
            } else {
                ErrorLogUtility.logIntegrationInfo('Failure', 'Outbound','JSONParserForToken',
                          'getJSONParserForToken','Mashery', oHttpResponse.getStatusCode(),'Bad response from Mashery for OAuth.'
                          ,sBody,oHttpResponse.getBody(),oHttpResponse.getStatus(),null);
                return null;     
            }
            return oJT;
        } catch(Exception oExp) {
            ErrorLogUtility.logIntegrationInfo('Failure', 'Outbound','JSONParserForToken',
                    'getJSONParserForToken','Mashery', null,'Exception while sending request to Mashery for OAuth. Exception: '
                    +oExp.getMessage()+'. Stack Trace: '+oExp.getStackTraceString(),null,null,null,null);
            return null;
        }

    }
}