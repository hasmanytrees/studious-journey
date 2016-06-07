/******************************************************************************************************
Class Name         : CommSubPageController
Description        : This is a class that will be used by Global Partners to submit supporter letters
Created By         : Akashdeep Vinnakota 
Created On         : 28-Oct-2015
******************************************************************************************************/
public class CommSubPageController {
    public String sBenLocalID {
        get;
        set;
    }

    public String sBenLegacyID {
        get;
        set;
    }

    public String sBenGlobalID {
        get;
        set;
    }

    public String sSupGlobalID {
        get;
        set;
    }

    public String sSupCompassID {
        get;
        set;
    }

    public String sOriTxt {
        get;
        set;
    }

    public String sEngTxt {
        get;
        set;
    }

    public String sTemplateId {
        get;
        set;
    }

    public boolean bEnableCommRecSection {
        get;
        set;
    }

    public transient Blob oAttach {
        get;
        set;
    }

    public List<Commitment__c> lstResult {
        get;
        set;
    }

    public Boolean bShowSuccessPanel {
        get;
        set;
    }

    public Boolean bShowUploadPanel {
        get;
        set;
    }

    public Communication_Kit__c oCk {
        get;
        set;
    }

    public Boolean bOriginalMailed {
        get;
        set;
    }

    public Boolean bAttachmentMailed {
        get;
        set;
    }

    public Boolean bAttachmentNotMailed {
        get;
        set;
    }

    public String sChosenTemplate {
        get;
        set;
    }

    public List<SelectOption> lstTemplatePicklist {
        get;
        set;
    }


    public String sContentLink {
        get;
        set;
    }
    
    public String sLoggedInUserGPId {
        get;
        set;
    }
    
     public Boolean bShowPage {
        get;
        set;
    }

    public Account oGpAcc {
        get;
        set;
    }
    
    public Integer iNumberOfPages {
        get;
        set;
    }

    /**
     * Method name  : CommSubPageController
     * Description  : This is constructor of the class responsible for initializing all the variables required
     * Return Type  : N/A
     * Parameter    : void
     **/
    public CommSubPageController() {
        sContentLink = '';
        sChosenTemplate = '';
        bEnableCommRecSection = false;
        lstResult = new List<Commitment__c>();
        lstTemplatePicklist = new List<SelectOption>();
        bShowSuccessPanel = false;
        bShowUploadPanel = false;
        bOriginalMailed = false;
        bAttachmentMailed = false;
        bAttachmentNotMailed = false;
        oGpAcc = new Account();
        bShowPage = true;
        iNumberOfPages = null;

        lstTemplatePicklist.add(new SelectOption(Constants.NONE_VALUE, System.Label.CommSubPage_None));
        lstTemplatePicklist.add(new SelectOption(Constants.CommSubPage_1S11,
            System.Label.CommSubPage_Layout1));
        lstTemplatePicklist.add(new SelectOption(Constants.CommSubPage_2S01,
            System.Label.CommSubPage_Layout2));
        lstTemplatePicklist.add(new SelectOption(Constants.CommSubPage_3S01,
            System.Label.CommSubPage_Layout3));
        lstTemplatePicklist.add(new SelectOption(Constants.CommSubPage_4S01,
            System.Label.CommSubPage_Layout4));
        lstTemplatePicklist.add(new SelectOption(Constants.CommSubPage_5S01,
            System.Label.CommSubPage_Layout5));
        lstTemplatePicklist.add(new SelectOption(Constants.CommSubPage_6S01,
            System.Label.CommSubPage_Layout6));
        lstTemplatePicklist.add(new SelectOption(Constants.CommSubPage_7S11,
            System.Label.CommSubPage_Layout7));
        lstTemplatePicklist.add(new SelectOption(Constants.CommSubPage_8S01,
            System.Label.CommSubPage_Layout8));
            
        User u = [Select id, Contact.AccountID, Contact.Account.Name from User where id = : userinfo.getuserid()];
        sLoggedInUserGPId = u.Contact.AccountID;
        
        if (sLoggedInUserGPId != null )
        {
            String sGpName = u.Contact.Account.Name;
            if( sGpName != System.Label.Global_Partner_New_Zealand && sGpName != System.Label.Global_Partner_Netherlands && sGpName != System.Label.Global_Partner_Italy)
            {
                System.Debug(' Curr User GP : ' + sGpName);
                bShowPage = false;
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, System.Label.CommSubPage_Error_Message12);
                ApexPages.addMessage(myMsg);
                return;
            }
                
        }
        
    }

    /**
     * Method name  : clickUpload
     * Description  : This method will perform attachment validations
     * Return Type  : void
     * Parameter    : void
     **/

    public void clickUpload() {
        if(oAttach == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.CommSubPage_Error_Message10);
            ApexPages.addMessage(myMsg);
            return;
        }
        //Check for Attachement Limit of 2MB
        else if(oAttach.size()> 2097152) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.CommSubPage_Error_Message11);
            ApexPages.addMessage(myMsg);
            return;
        }
        postFileToPerceptive();
        oAttach = null;
    }

    /**
     * Method name  : postFileToPerceptive
     * Description  : This method will upload attachment to Perceptive via outbound call
     * Return Type  : void
     * Parameter    : void
     **/
    public void postFileToPerceptive() {
        Http http = new Http();
        HttpResponse response;

        HttpRequest request = new HttpRequest();
        String sURL = ESB_URL__c.getValues(Constants.LetterUpload)
            .Process_ESB_URL__c;
        request.setEndpoint(sURL);
        request.setMethod(Constants.POST_METHOD);
        request.setTimeout(120000);
        JSONParserForToken oJsonParserToken = JSONParserForToken.getJSONParserForToken();
        String sAuthHeader = Constants.HTTPMethod_AuthHeader_Bearer + ' ' + String.valueof(
            oJsonParserToken.access_token);
        request.setHeader(Constants.HTTPMethod_AuthHeader_Authorization, sAuthHeader);
        request.setHeader(Constants.CONTENT_TYPE, Constants.LetterUpload_ContentType);
        //Sending the Blob File as body
        request.setBodyAsBlob(oAttach);
        System.debug('request: ' + request);
        if(!Test.isRunningTest()) {
            response = http.send(request);
        }
        if(response != null && response.getStatus() == Constants.LetterUpload_CreatedStatus) {
            sContentLink = response.getBody();
            bShowUploadPanel = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,
                System.Label.CommSubPage_Error_Message8);
            ApexPages.addMessage(myMsg);

            //Only once the upload is succesfull, Communication is inserted            
            oCk.Original_Letter_Link__c = sContentLink;
            try {
                INSERT oCk;
            } catch(DmlException ex) {
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.Error,
                    ex.getMessage());
                ApexPages.addMessage(oMsg);
                ErrorLogUtility.logGeneralError(ex, 'CommSubPageController',
                    'postFileToPerceptive', 'SFDC CI');
            }
            oCk = [Select id, Name from Communication_Kit__c where id = : oCk.id];
            bShowSuccessPanel = true;
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.CommSubPage_Error_Message9);
            ApexPages.addMessage(myMsg);
            return;
        }
    }

    /**
     * Method name  : clickSave
     * Description  : This method validates & saves Communication information entered by the user.
     * Return Type  : void
     * Parameter    : void
     **/
    public void clickSave() {
        //Logged-in User's GP Id is noted
        

        if(sLoggedInUserGPId<> null) {
            oGpAcc = [Select id, Opted_In_For_SDL__c, Global_Partner_Code__c from Account where id = :
                sLoggedInUserGPId
            ];
        }

        if(String.ValueOf(sBenLocalID) == '' && String.ValueOf(sBenLegacyID) == '' &&
            String.ValueOf(sBenGlobalID) == '') {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.CommSubPage_Error_Message7);
            ApexPages.addMessage(myMsg);
            return;
        }

        if(String.ValueOf(sSupGlobalID) == '' && String.ValueOf(sSupCompassID) == '') {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.CommSubPage_Error_Message6);
            ApexPages.addMessage(myMsg);
            return;
        }

        if(String.ValueOf(sChosenTemplate) == Constants.NONE_VALUE) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.CommSubPage_Error_Message5);
            ApexPages.addMessage(myMsg);
            return;
        }
        
        System.Debug('iNumberOfPages : ' + iNumberOfPages);
        
        if(iNumberOfPages == 0 ) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.CommSubPage_Error_Message13);
            ApexPages.addMessage(myMsg);
            return;
        }

        if(String.ValueOf(sSupGlobalID) != '' || String.ValueOf(sSupCompassID) != '') {
            Account oAcc = new Account();
            if(String.ValueOf(sSupGlobalID) != '' && String.ValueOf(sSupCompassID) ==
                '') {
                try
                {
                	oAcc = [Select id, Global_Number__c, Global_Partner__c from Account where Global_Number__c = :
                    String.escapeSingleQuotes(sSupGlobalID)
                	];
                }
                catch(Exception ex) {
		            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
		                System.Label.CommSubPage_Error_Message14);
		            ApexPages.addMessage(myMsg);
		            return;
		        }
                
            } else if(String.ValueOf(sSupGlobalID) == '' && String.ValueOf(
                    sSupCompassID) != '') {
                try
                {
                	oAcc = [Select id, Global_Number__c, Global_Partner__c from Account where GP_Supporter_ID__c = :
                    	String.escapeSingleQuotes(sSupCompassID)
                	];
                }
                catch(Exception ex) {
		            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
		                System.Label.CommSubPage_Error_Message15);
		            ApexPages.addMessage(myMsg);
		            return;
		        }
            } else if(String.ValueOf(sSupGlobalID) != '' && String.ValueOf(
                    sSupCompassID) != '') {
                try
                {
	                oAcc = [Select id, Global_Number__c, Global_Partner__c from Account where Global_Number__c = :
	                    String.escapeSingleQuotes(sSupGlobalID) AND GP_Supporter_ID__c = :
	                    String.escapeSingleQuotes(sSupCompassID)
	                ];
                }
                catch(Exception ex) {
		            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
		                System.Label.CommSubPage_Error_Message16);
		            ApexPages.addMessage(myMsg);
		            return;
		        }
            }
            if(oAcc != null && sLoggedInUserGPId != null && oAcc.Global_Partner__c !=
                sLoggedInUserGPId && UserInfo.getUserType() == Constants.POWERPARTNER) {
                System.debug('oAcc.Global_Number__c: ' + oAcc.Global_Partner__c +
                    ' sLoggedInUserGPId: ' + sLoggedInUserGPId);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                    System.Label.CommSubPage_Error_Message4);
                ApexPages.addMessage(myMsg);
                return;
            }
        }

        String DbQuery =
            'Select id, Name, Status__c, BEN_Id__c, BEN_Id__r.Correspondence_Language__c, SUP_Id__c, Relationship_Type__c, Supporter_Correspondence_Language__c from Commitment__c where id != null ';
        if(String.ValueOf(sBenLocalID) != '') {
            DbQuery += ' AND BEN_Id__r.Local_Beneficiary_ID__c = \'' + String.escapeSingleQuotes(
                sBenLocalID) + '\'';
        }
        if(String.ValueOf(sBenGlobalID) != '') {
            DbQuery += ' AND BEN_Id__r.Global_Number__c = \'' + String.escapeSingleQuotes(
                sBenGlobalID) + '\'';
        }
        if(String.ValueOf(sSupGlobalID) != '') {
            DbQuery += ' AND SUP_Id__r.Global_Number__c = \'' + String.escapeSingleQuotes(
                sSupGlobalID) + '\'';
        }
        if(String.ValueOf(sBenLegacyID) != '') {
            DbQuery += ' AND BEN_Id__r.Compass_Id__c = \'' + String.escapeSingleQuotes(
                sBenLegacyID) + '\'';
        }
        if(String.ValueOf(sSupCompassID) != '') {
            DbQuery += ' AND SUP_Id__r.GP_Supporter_ID__c = \'' + String.escapeSingleQuotes(
                sSupCompassID) + '\'';
        }
        DbQuery += ' AND Status__c = \'Active\'';
        System.Debug('DbQuery: ' + DbQuery);
        lstResult = Database.query(DbQuery);

        if(lstResult.size() == 0) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.CommSubPage_Error_Message1);
            ApexPages.addMessage(myMsg);
            return;
        } else if(lstResult.size() == 1) {
            if(lstResult[0].Relationship_Type__c == Constants.COMMITMENT_TYPE_SPONSORSHIP) {
                List<Commitment__c> lstCommitment = [Select id, Status__c from Commitment__c where Relationship_Type__c = :
                    Constants.COMMITMENT_TYPE_CORRESPONDENT
                    AND Status__c = : Constants.COMMITMENT_STATUS_ACTIVE
                    AND BEN_Id__c = : lstResult[0].BEN_Id__c
                ];
                if(lstCommitment.size()> 0) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                        System.Label.CommSubPage_Error_Message2);
                    ApexPages.addMessage(myMsg);
                    return;
                }
            }
        }

        if(String.ValueOf(sEngTxt) == '' && oGpAcc.Opted_In_For_SDL__c == false &&
            lstResult[0].Supporter_Correspondence_Language__c != Constants.COMMITMENT_CORRESPONDENCE_LANGUAGE &&
            lstResult[
                0].Supporter_Correspondence_Language__c != lstResult[0].BEN_Id__r.Correspondence_Language__c
        ) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.CommSubPage_Error_Message3);
            ApexPages.addMessage(myMsg);
            return;
        }

        if(oGpAcc.Global_Partner_Code__c<> null) {
            sTemplateId = oGpAcc.Global_Partner_Code__c + '-A-' + String.escapeSingleQuotes(
                sChosenTemplate) + '-1';
        }

        //A new insatnce of Communication is created
        oCk = new Communication_Kit__c();
        oCk.RecordTypeId = Utility.getRecordTypeIdByDeveloperName(
            Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_S2B_RT);
        oCk.BEN_ID__c = lstResult[0].BEN_Id__c;
        oCk.SUP_ID__c = lstResult[0].SUP_Id__c;
        oCk.Original_Text__c = sOriTxt;
        oCk.Translated_Text_English__c = sEngTxt;
        oCk.Template_ID__c = sTemplateId != '' ? sTemplateId : '';

        oCk.Status__c = Constants.COMMUNICATION_KIT_STATUS_RECEIVEDINTHESYSTEM;
        oCk.Print_Allowed_Date__c = null;
        oCk.Original_Mailed__c = bOriginalMailed;
        oCk.Attachment_Mailed__c = bAttachmentMailed;
        oCk.Attachment_Not_Mailed__c = bAttachmentNotMailed;
        oCk.Number_Of_Pages__c = iNumberOfPages;
        bShowUploadPanel = true;

    }
}