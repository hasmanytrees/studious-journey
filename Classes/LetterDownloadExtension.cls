/******************************************************************************************************
Class Name         : LetterDownloadExtension
Deascription       : An apex controller for downloading files from Perceptive
Created By         : Rahul Aggarwal 
Created On         : 10/27/2015
******************************************************************************************************/
public class LetterDownloadExtension {
    public Transient String sBlobFileStr;
    private String sCommunicationId;
    public boolean bShowLink {
        get;
        set;
    }
    public String sMIMEType {
        get;
        set;
    }
    public boolean bShow {
        get;
        set;
    }
    public String sResponse {
        get;
        set;
    }
    public String sURL {
        get;
        set;
    }
    public Transient String letterType {
        get;
        set;
    }
    public String getsBlobFileStr() {
        //Get the file in visual force
        return sBlobFileStr;

    }

    public Communication_Kit__c oComm {
        get;
        set;
    }

    /**
     * Method name  : LetterDownloadExtension
     * Description  : This is a standard constructor for the class that initialises all the variables
     * Return Type  : N/A
     * Parameter    : void 
     **/
    public LetterDownloadExtension() {

        sCommunicationId = String.escapeSingleQuotes(ApexPages.currentPage()
            .getParameters()
            .get(Constants.ID));
        oComm = new Communication_Kit__c();
        oComm = [select Id, Original_Letter_Link__c, Final_Composed_Letter_Link__c from Communication_Kit__c where Id = :
            sCommunicationId
        ];
        bShowLink = false;
        getFileFromPerceptive();
    }

    /**
     * Method name  : getFileFromPerceptive
     * Description  : this method is used to make call out ESB and get file from 
     *                Perceptive.
     * Return Type  : Void
     * Parameter    : void
     **/
    public void getFileFromPerceptive() {
        letterType = String.escapeSingleQuotes(ApexPages.currentPage()
            .getParameters()
            .get(Constants.TYPE));
        Http http = new Http();
        sMIMEType = Constants.LetterDownload_MimeType;
        HttpResponse response;
        try {
            sURL = ESB_URL__c.getValues(Constants.LetterDownload)
                .Process_ESB_URL__c;
            if(letterType == Constants.LetterType_Original) {
                if(oComm.Original_Letter_Link__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        System.Label.Letter_Download_Error1));
                    bShow = true;
                    return;
                }
                oComm.Original_Letter_Link__c = oComm.Original_Letter_Link__c.replace(
                    Constants.Download_tiff, '');
                oComm.Original_Letter_Link__c = oComm.Original_Letter_Link__c.replace(
                    Constants.Download_tif, '');
                if(oComm.Original_Letter_Link__c.contains(Constants.Download_doc))
                    sURL = sURL.replace(Constants.Download_FolderId, oComm.Original_Letter_Link__c
                        .subStringAfter(Constants.Download_doc)
                        .substringBefore(Constants.Download_Page));
                else if(oComm.Original_Letter_Link__c.contains(Constants.Download_Images))
                    sURL = sURL.replace(Constants.Download_FolderId, oComm.Original_Letter_Link__c
                        .subStringAfter(Constants.Download_Images)
                        .substringBefore(Constants.Download_Page));
                sURL = sURL.replace(Constants.Download_DocumentId, oComm.Original_Letter_Link__c
                    .subStringAfter(Constants.Download_Page1));
            } else if(letterType == Constants.LetterType_Final) {
                if(oComm.Final_Composed_Letter_Link__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        System.Label.Letter_Download_Error2));
                    bShow = true;
                    return;
                }
                oComm.Final_Composed_Letter_Link__c = oComm.Final_Composed_Letter_Link__c.replace(
                    Constants.Download_tiff, '');
                oComm.Final_Composed_Letter_Link__c = oComm.Final_Composed_Letter_Link__c.replace(
                    Constants.Download_tif, '');
                if(oComm.Final_Composed_Letter_Link__c.contains(Constants.Download_doc))
                    sURL = sURL.replace(Constants.Download_FolderId, oComm.Final_Composed_Letter_Link__c
                        .subStringAfter(Constants.Download_doc)
                        .substringBefore(Constants.Download_Page));
                else if(oComm.Final_Composed_Letter_Link__c.contains(Constants.Download_Images))
                    sURL = sURL.replace(Constants.Download_FolderId, oComm.Final_Composed_Letter_Link__c
                        .subStringAfter(Constants.Download_Images)
                        .substringBefore(Constants.Download_Page));
                //sURL = sURL.replace(Constants.Download_FolderId, oComm.Final_Composed_Letter_Link__c.subStringAfter(Constants.Download_doc).substringBefore(Constants.Download_Page));
                sURL = sURL.replace(Constants.Download_DocumentId, oComm.Final_Composed_Letter_Link__c
                    .subStringAfter(Constants.Download_Page1));
            }
            HttpRequest request = new HttpRequest();
            request.setEndpoint(sURL);
            request.setMethod(Constants.HTTPMethod_Get);
            request.setTimeout(120000);
            JSONParserForToken oJsonParserToken = JSONParserForToken.getJSONParserForToken();
            String sAuthHeader = Constants.HTTPMethod_AuthHeader_Bearer + ' ' + String.valueof(
                oJsonParserToken.access_token);

            request.setHeader(Constants.HTTPMethod_AuthHeader_Authorization,
                sAuthHeader);
            response = http.send(request);
            if(response.getStatus() == Constants.OK || response.getStatus() ==
                Constants.Found) {
                sBlobFileStr = EncodingUtil.base64Encode(response.getBodyAsBlob());
                bShowLink = true;
                bShow = true;
                return;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    System.Label.Letter_Download_Error3));
                bShow = true;
                return;
            }
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                System.Label.Letter_Download_Error3));
            bShow = true;
            return;
        }
    }

}