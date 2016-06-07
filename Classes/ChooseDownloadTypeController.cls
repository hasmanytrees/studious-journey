/******************************************************************************************************
Class Name         : ChooseDownloadTypeController
Deascription       : An apex controller for choosing the type of letter to download
Created By         : Rahul Aggarwal 
Created On         : 10/27/2015
******************************************************************************************************/
public class ChooseDownloadTypeController {
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
    public String letterType {
        get;
        set;
    }
    public String sChosenLetterType {
        get;
        set;
    }
    public String getsBlobFileStr() {
        //Get the file in visual force
        return sBlobFileStr;

    }
    public String sFileName {
        get;
        set;
    }
    public List<SelectOption> lstLetterTypeMenu {
        get;
        set;
    }

    public Communication_Kit__c oComm {
        get;
        set;
    }

    /**
     * Method name  : ChooseDownloadTypeController
     * Description  : This is a standard constructor for the class that initialises all the variables
     * Return Type  : N/A
     * Parameter    : void 
     **/
    public ChooseDownloadTypeController() {
        sCommunicationId = (ApexPages.currentPage()
            .getParameters()
            .get(Constants.contentId));
        lstLetterTypeMenu = new List<SelectOption>();
        oComm = new Communication_Kit__c();
        oComm = [select Id, Name, Original_Letter_Link__c, SUP_ID__r.Global_Number__c,
            Final_Composed_Letter_Link__c from Communication_Kit__c where Id = :
            sCommunicationId
        ];
        if(oComm.Original_Letter_Link__c != null) {
            lstLetterTypeMenu.add(new SelectOption(Constants.LetterType_Original, System.Label.ChooseDownType_Original));
        }
        if(oComm.Final_Composed_Letter_Link__c != null) {
            lstLetterTypeMenu.add(new SelectOption(Constants.LetterType_Final, System.Label.ChooseDownType_Final));
        }
        sFileName = '';
    }

    /**
     * Method name  : ConvertToBlob
     * Description  : This method calls the method that gets files from Perceptive
     * Return Type  : void
     * Parameter    : void 
     **/
    public void ConvertToBlob() {
        letterType = (ApexPages.currentPage()
            .getParameters()
            .get(Constants.TYPE));
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
                    sURL = sURL.replace(Constants.Download_FolderId, oComm.Original_Letter_Link__c.subStringAfter(
                            Constants.Download_doc)
                        .substringBefore(Constants.Download_Page));
                else if(oComm.Original_Letter_Link__c.contains(Constants.Download_Images))
                    sURL = sURL.replace(Constants.Download_FolderId, oComm.Original_Letter_Link__c.subStringAfter(
                            Constants.Download_Images)
                        .substringBefore(Constants.Download_Page));
                sURL = sURL.replace(Constants.Download_DocumentId, oComm.Original_Letter_Link__c.subStringAfter(
                    Constants.Download_Page1));
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
                    sURL = sURL.replace(Constants.Download_FolderId, oComm.Final_Composed_Letter_Link__c.subStringAfter(
                            Constants.Download_doc)
                        .substringBefore(Constants.Download_Page));
                else if(oComm.Final_Composed_Letter_Link__c.contains(Constants.Download_Images))
                    sURL = sURL.replace(Constants.Download_FolderId, oComm.Final_Composed_Letter_Link__c.subStringAfter(
                            Constants.Download_Images)
                        .substringBefore(Constants.Download_Page));
                //sURL = sURL.replace('{!FolderId}', oComm.Final_Composed_Letter_Link__c.subStringAfter('document/').substringBefore('/page'));
                sURL = sURL.replace(Constants.Download_DocumentId, oComm.Final_Composed_Letter_Link__c.subStringAfter(
                    Constants.Download_Page1));
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
            if(response.getStatus() == Constants.OK || response.getStatus() == Constants.Found) {
                sBlobFileStr = EncodingUtil.base64Encode(response.getBodyAsBlob());
                bShowLink = true;
                bShow = true;
                sFileName = oComm.Name + '-' + oComm.SUP_ID__r.Global_Number__c + '-' + letterType;
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