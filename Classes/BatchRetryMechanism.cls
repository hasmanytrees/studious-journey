/******************************************************************************************************
Class Name         : BatchRetryMechanism
Description        : This class is used to implement Retry logic for integrations in CI.
Created By         : Rahul Agarwal
Created On         : 15-Oct-2015 
******************************************************************************************************/
global class BatchRetryMechanism implements Database.Batchable<sObject>, database.stateful, Database.AllowsCallouts{
    
    global Map<String,boolean> mapLastServicerequest=new  Map<String,boolean> ();
    /**
    * Method name  : start
    * Description  : This method fetches all the error log that needs retry
    * Return Type  : Database.QueryLocator
    * Parameter    : Database.BatchableContext
    **/
    global Database.QueryLocator start(Database.BatchableContext oBC){
        String sQuery = '';
        String sIgnoredClasses = System.Label.Retry_Ignore_Class;
            sQuery = 'Select Id, ESB_URL__c, IsRepeatEnabled__c, Urgency__c, Impact__c, Is_Escalated__c, Error_Occurred_in_Class__c, Error_Category__c, Integration_Name__c, Xcim_To_Address__c, Request_Body__c, Number_of_times_retried__c, Error_Body__c, Status__c, Response_Body__c, Response_Message__c, HTTP_Verb__c from Error_Log__c where IsRepeatEnabled__c=true AND Status__c = \'Awaiting Retry\' AND Type__c = \'Outbound\' AND Error_Occurred_in_Class__c NOT IN (' + sIgnoredClasses + ') AND ESB_URL__c != null';
        return database.getQueryLocator(sQuery);
    }
    
    /**
    * Method name  : execute
    * Description  : This method creates the Scheduled Letters 
    * Return Type  : void
    * Parameter    : Database.BatchableContext, List<Account>
    **/
    global void execute(Database.BatchableContext oBC, List<SObject> lstScope){
        
        Error_Log__c oErr = new Error_Log__c();
        oErr = (Error_Log__c)(lstScope[0]); // Ensuring only one callout per execute method
        Set<String> setErrorLogStatus=new Set<String>();
        Map<Id,Error_Log__c> mapErrorLog=new Map<Id,Error_Log__c>();
        
        if(!String.isEmpty(oErr.Request_Body__c))
        {
            if(oErr.HTTP_Verb__c == null || oErr.HTTP_Verb__c == '')
                oErr.HTTP_Verb__c = Constants.POST_METHOD;
                
            
            JSONParserForToken oJsonParserToken = null;
            oJsonParserToken = (null == oJsonParserToken) ? JSONParserForToken.getJSONParserForToken() : oJsonParserToken;
            
            HttpResponse oHttpResponse = new HttpResponse();
            
            try
            {
                String sAuthHeader = Constants.HTTPMethod_AuthHeader_Bearer + ' ' + String.valueof(oJsonParserToken.access_token);
                HttpRequest oHttpRequest = new HttpRequest();
                oHttpRequest.setMethod(oErr.HTTP_Verb__c);
                oHttpRequest.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
                oHttpRequest.setEndpoint(oErr.ESB_URL__c);
                
                oHttpRequest.setTimeout(120000);
                oHttpRequest.setHeader(constants.AUTHORIZATION_HEADER, sAuthHeader);
                if(!String.isEmpty(oErr.Xcim_To_Address__c))
                {
                    oHttpRequest.setHeader(Constants.XCIM_HEADER,oErr.Xcim_To_Address__c);
                }
                Map<HttpRequest,HttpResponse> mapResponse = new Map<HttpRequest,HttpResponse>();
                
                Http oHttp = new Http();
                System.debug('HTTP Request: '+ oErr.Request_Body__c);
                oHttpRequest.setBody(oErr.Request_Body__c);
                
                if(!test.isRunningTest()){
                    oHttpResponse = oHttp.Send(oHttpRequest);
                }
                 
                System.debug('HTTP Response: '+oHttpResponse);
                mapResponse.put(oHttpRequest,oHttpResponse);
                // All the process of this map
                System.debug('mapResponse:*****'+mapResponse);
                
                if (null == mapResponse)
                {
                    if(oErr.Number_of_times_retried__c == null)
                        oErr.Number_of_times_retried__c = 0;
                    oErr.Number_of_times_retried__c += 1;
                    oErr.Error_Body__c = oErr.Error_Body__c + Constants.Retry_NewLine + Constants.Retry_NewLine + Constants.Retry_Number + oErr.Number_of_times_retried__c + Constants.Retry_Error + Constants.ErrorString_25_FALIURE_TO_SEND_INFO;
                    if(oErr.Integration_Name__c == Constants.IntName_SBC)
                    {
                        oErr.Error_Category__c = Constants.IntName_SBC;
                    }
                    if(oErr.Integration_Name__c == Constants.IntName_BeneMinProfile)
                    {
                        oErr.Error_Category__c = Constants.IntName_BeneMinProfile;
                    }
                    
                     
                }
                else if (mapResponse.Values()[0].getStatusCode() != 200 && mapResponse.Values()[
                    0].getStatusCode() != 201) 
                {
                    if(oErr.Number_of_times_retried__c == null)
                        oErr.Number_of_times_retried__c = 0;
                    oErr.Number_of_times_retried__c += 1;
                    oErr.Error_Body__c = oErr.Error_Body__c + Constants.Retry_NewLine + Constants.Retry_NewLine + Constants.Retry_Number + oErr.Number_of_times_retried__c + Constants.Retry_Error + mapResponse.Values()[0].getBody();
                    if(oErr.Integration_Name__c == Constants.IntName_SBC)
                    {
                        oErr.Error_Category__c = Constants.IntName_SBC;
                    }
                    if(oErr.Integration_Name__c == Constants.IntName_BeneMinProfile)
                    {
                        oErr.Error_Category__c = Constants.IntName_BeneMinProfile;
                    }
                }
                else if (mapResponse.Values()[0].getStatusCode() == 200 || mapResponse.Values()[
                    0].getStatusCode() == 201) 
                {
                    oErr.Status__c = Constants.Retry_Completed;
                    oErr.IsRepeatEnabled__c = false; 
                    if(oErr.Error_Occurred_in_Class__c == Constants.CLASS_NAME_COMMUNICATIONKITSEND)
                    {
                        CommunicationKitSendRetryUpdateRecs oClassObj = new CommunicationKitSendRetryUpdateRecs();
                        oClassObj.updateCommRecs(mapResponse);
                    }
                     
                }
            }
            catch(Exception oEx)
            {
                // Processing the error
                if(oErr.Number_of_times_retried__c == null)
                oErr.Number_of_times_retried__c = 0;
                oErr.Number_of_times_retried__c += 1;
                oErr.Error_Body__c = oErr.Error_Body__c + Constants.Retry_NewLine + Constants.Retry_Number + oErr.Number_of_times_retried__c + Constants.Retry_Error + oEx.getMessage();
            }
            
            List<Error_Log__c> lstErrorLogWithRaisedCase = new  List<Error_Log__c>();
            List<Error_Log__c> lstErrorLogWithCaseToRaise = new  List<Error_Log__c>();
            String sErrLogCategory = oErr.Error_Category__c==null?'':oErr.Error_Category__c;
            lstErrorLogWithRaisedCase =[select Id, Error_Category__c from Error_Log__c where Error_Category__c  =: sErrLogCategory and Is_Escalated__c=true and CreatedDate=TODAY];
            System.Debug('>>>> lstErrorLogWithRaisedCase : ' + lstErrorLogWithRaisedCase);
            Integer iCheck=0;
            for(Error_Log__c oErrorLogTmpVar: lstErrorLogWithRaisedCase)
            {
                if(oErr.Error_Category__c==oErrorLogTmpVar.Error_Category__c)
                {
                    mapLastServicerequest.put(oErr.Error_Category__c,true);
                    iCheck++;
                }
                         
            }
            
            if(iCheck == 0 && !mapLastServicerequest.containsKey(oErr.Error_Category__c))
            {
                mapLastServicerequest.put(oErr.Error_Category__c,false);
            }
            
            System.Debug('>>>> mapLastServicerequest before: ' + mapLastServicerequest);
                
            oErr.Urgency__c = Error_Log_Repeats__c.getValues(oErr.Integration_Name__c).Urgency__c;
            oErr.Impact__c = Error_Log_Repeats__c.getValues(oErr.Integration_Name__c).Impact__c;
          
            if(( Error_Log_Repeats__c.getValues(oErr.Integration_Name__c).Maximum_Iterations__c 
                                           <= oErr.Number_of_times_retried__c) 
                                           && (oErr.Error_Category__c)!=null 
                                           && (oErr.IsRepeatEnabled__c=true))
            {
                System.Debug('>>>> Came Inside if : ');
                oErr.IsRepeatEnabled__c = false;
                oErr.Status__c =  Constants.Retry_Failed;
                if (mapLastServicerequest.get(oErr.Error_Category__c)==false)
                {
                    lstErrorLogWithCaseToRaise.add(oErr);
                    oErr.Is_Escalated__c = true;
                    mapLastServicerequest.put(oErr.Error_Category__c,true);
                }
            }
          
            System.Debug('>>>> mapLastServicerequest after: ' + mapLastServicerequest);
          
            
            Id templateId = [select id, name from EmailTemplate where developername = : Constants.Retry_EmailTemplate].id;
            Id checkWhatId = [select id from Contact where id = :Label.ErrorLogServiceNowContact].id;
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for (Error_Log__c oErrorLogVar: lstErrorLogWithCaseToRaise)
            {
                       
                // Step 1: Create a new Email
                Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
                //mail.setTemplateId(templateId);
                mail.setSaveAsActivity(false);
                mail.setWhatId(oErrorLogVar.id);
                // Step 2: Set list of people who should get the email
                mail.setTargetObjectId(checkWhatId);
                List<String> lstToAddressString = new List<String>();
                lstToAddressString.add(System.label.ErrorLogUserId);
                mail.setToAddresses(lstToAddressString);
                // Step 3: Set who the email is sent from
                //mail.setReplyTo(UserInfo.getUserEmail());
                mail.setSenderDisplayName(UserInfo.getName());
                // (Optional) Set list of people who should be CC'ed
                mail.setTemplateId(templateId);
                //mail.setWhatId(oErrorLogVar.Id);
                // Step 5. Add your email to the master list
                mails.add(mail);
                Messaging.sendEmail(mails);
                      
            }
         
             
            
            try{
                update oErr;
            }
            catch(Exception oEx)
            {
                if(oErr.Number_of_times_retried__c == null)
                    oErr.Number_of_times_retried__c = 0;
                oErr.Number_of_times_retried__c += 1;
                update oErr;
            }
        }
    }
    
     /**
    * Method name  : finish
    * Description  : This method executes upon completion of the batch process
    * Return Type  : void
    * Parameter    : Database.BatchableContext
    **/
     global void finish(Database.BatchableContext BC){
        
        
    }
}