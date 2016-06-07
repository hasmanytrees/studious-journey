/************************************************************************
*Name               : ContentDownloadExtension
*Description        : This is a extension class for ContentDownload page used for getting
                      Image content and to display on page.   
*Created By         : Nayana Prabhakar
*Created On         : 28-Jan-2015
********************************************************************************/

public with sharing class ContentDownloadExtension {
    public String sImageData {
        get;
        set;
    }
    public Content__c oContRecord {
        get;
        set;
    }
    public String sContentType {
        get;
        set;
    }

    /**********************************
    Method Name : ContentDownloadExtension
    Description : Constructor for this class.
    Return type : 
    Parameter   : 
    ************************************/
    public ContentDownloadExtension(ApexPages.StandardController controller) {
        oContRecord = (Content__c) controller.getRecord();
        Content__c oCon = new Content__c();
        oCon = [Select Content_Download_Type__c from Content__c where id = :
             oContRecord.Id
        ];
        if(String.isNotEmpty(oCon.Content_Download_Type__c))
            sContentType = oCon.Content_Download_Type__c;
        if(sContentType == null)
            sContentType = Constants.IMAGE_JPEG_CONTENT_TYPE;
    }

    /**********************************
    Method Name : calloutForImageDwnld
    Description : This method sends request to Neuron to get Image content so that it can be displayed to User.
    Return type : void
    Parameter   : 
    ************************************/
    public void calloutForImageDwnld() {
        
        if(oContRecord.Content_Link__c != NULL) {
            String userAgent = ApexPages.currentPage().getHeaders().get(Constants.USER_AGENT);
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName(Constants.CONTENT_LIST_TOKEN);
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField(Constants.CONTENT_LINK_TOKEN, string.valueof(
                oContRecord.Content_Link__c));
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
            gen.close();
            string sJSONString = gen.getAsString();
            Map<HttpRequest,HttpResponse> mapResponse = New Map<HttpRequest, HttpResponse>();
            JSONParserForToken oJsonParserToken = JSONParserForToken.getJSONParserForToken();
            if(null == oJsonParserToken){
            	ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,
                    Constants.EXTERNAL_SYSTEM_CONNECTION_ERROR);
                apexpages.addmessage(msg);
                return;
            }
            mapResponse = SendRequestToNeuron.sendInfoToNeuron(sJSONString,
                ESB_URL__c.getValues('NeuronURLForImageDownload').Process_ESB_URL__c,oJsonParserToken);
            HttpResponse response = (mapResponse.values().size()>0)?mapResponse.values()[0]:null;
            if(null == response){
                ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,
                    Constants.INTERNAL_SERVER_ERROR);
                apexpages.addmessage(msg);
                return;
            }else if(response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                pagereference pageRef = apexpages.Currentpage();
                ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,
                    (null<>response.getStatus())?response.getStatus():Constants.INTERNAL_SERVER_ERROR);
                apexpages.addmessage(msg);
                return;
            }
            if(response != null)
                sImageData = EncodingUtil.base64Encode(response.getBodyasBlob());
            if(!sContentType.contains(Constants.IMAGE) && (!sContentType.contains(Constants.PDF)||
            (sContentType.contains(Constants.PDF) && userAgent.contains(Constants.CHROME_BROWSER)))) { 
                pagereference pageRef = apexpages.Currentpage();
                ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,
                    System.Label.Content_Downloaded_Successfully);
                apexpages.addmessage(msg);
                return;
            }
        }
        else{
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,
                    Constants.NO_PERCEPTIVE_URI_PRESENT );
                apexpages.addmessage(msg);
            return;
        }
    }

}