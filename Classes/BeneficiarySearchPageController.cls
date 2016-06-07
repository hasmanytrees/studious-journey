/******************************************************************************************************
Class Name         : BeneficiarySearchPageController
Description        : This is the controller class for the Search Letters page
Created By         : Akashdeep Vinnakota 
Created On         : 30-Nov-2015 
******************************************************************************************************/
public class BeneficiarySearchPageController {
    public String sBenLocalID {
        get;
        set;
    }

    public String sGlobalSupId {
        get;
        set;
    }

    public String sLegSupId {
        get;
        set;
    }

    public String sGlobalCommId {
        get;
        set;
    }

    public String sLegBenId {
        get;
        set;
    }

    public Communication_Kit__c oUtilityObj {
        get;
        set;
    }

    public Communication_Kit__c oUtilityObj2 {
        get;
        set;
    }

    public boolean bShowResTbl {
        get;
        set;
    }

    public boolean bIsError {
        get;
        set;
    }

    public boolean bChecked {
        get;
        set;
    }

    public transient List<Communication_Kit__c> lstResult {
        get;
        set;
    }

    public String sLoggedInUserGPId {
        get;
        set;
    }

    public List<SelectOption> lstLetterType {
        get;
        set;
    }

    public String sChosenLetterType {
        get;
        set;
    }

    public Boolean bS2BCriteria {
        get;
        set;
    }

    public Boolean bB2SCriteria {
        get;
        set;
    }

    public Boolean bShowCriteriaBlock {
        get;
        set;
    }
    
    public Boolean bShowPage {
        get;
        set;
    }
    
    public Boolean bShowError {
        get;
        set;
    }

    public String sBenStatus {
        get;
        set;
    }
    
    public String sDisplay {
        get;
        set;
    }

    public static final String sRecordTypeS2B = Utility.getRecordTypeIdByDeveloperName(
        Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_S2B_RT);
    public static final String sRecordTypeB2S = Utility.getRecordTypeIdByDeveloperName(
        Communication_Kit__c.SObjectType, Constants.COMMUNICATION_KIT_B2S_RT);
    /**
     * Method name  : BeneficiarySearchPageController
     * Description  : This is constructor of the class responsible for initializing all the variables required
     * Return Type  : N/A
     * Parameter    : void
     **/
    public BeneficiarySearchPageController() {
        sBenLocalID = '';
        sLegSupId = '';
        sGlobalCommId = '';
        sLegBenId = '';
        sChosenLetterType = '';
        sGlobalSupId = '';
        sDisplay = 'none';
        sBenStatus = Constants.COMMUNICATION_KIT_STATUS_PUBLISHEDTOGP;
        bShowResTbl = false;
        bIsError = false;
        bChecked = false;
        oUtilityObj = new Communication_Kit__c();
        oUtilityObj2 = new Communication_Kit__c();
        lstResult = new List<Communication_Kit__c>();
        lstLetterType = new List<SelectOption>();
        bS2BCriteria = false;
        bB2SCriteria = false;
        bShowCriteriaBlock = false;
        bShowPage = true;

        lstLetterType.add(new SelectOption(Constants.Ben_Search_S2B, Constants.Ben_Search_S2B));
        lstLetterType.add(new SelectOption(Constants.Ben_Search_B2S, Constants.Ben_Search_B2S));

        String sUserType = UserInfo.getUserType();
        System.Debug('sUserType: ' + sUserType);

        //Checking for Logged-in User's GP Id
        User u = [Select id, Contact.AccountID, Contact.Account.Name from User where id = : userinfo.getuserid()];
        sLoggedInUserGPId = u.Contact.AccountID;
        if(sLoggedInUserGPId == null) {
            sLoggedInUserGPId = '';
        }
        else if (sLoggedInUserGPId != null )
        {
            String sGpName = u.Contact.Account.Name;
            if( sGpName != System.Label.Global_Partner_New_Zealand && sGpName != System.Label.Global_Partner_Netherlands && sGpName != System.Label.Global_Partner_Italy)
            {
                System.Debug(' Curr User GP : ' + sGpName);
                bShowPage = false;
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,System.Label.Search_Letters_Error_Msg3);
                ApexPages.addMessage(myMsg);
                return;
            }
                
        }
        System.Debug(' Check This: ' + sLoggedInUserGPId);

    }

    /**
     * Method name  : showFilterCriteria
     * Description  : This method is used to show the filter criteria based on Letter Type chosen on the page
     * Return Type  : void
     * Parameter    : N/A
     **/
    public void showFilterCriteria() {
        if(String.escapeSingleQuotes(sChosenLetterType) == Constants.Ben_Search_S2B) {
            bB2SCriteria = false;
            bS2BCriteria = true;
        } else if(String.escapeSingleQuotes(sChosenLetterType) == Constants.Ben_Search_B2S) {
            bB2SCriteria = true;
            bS2BCriteria = false;
        }
        bShowCriteriaBlock = true;
    }

    /**
    * Method name  : search
    * Description  : This method is used to search Communication records 
                     based on the search criteria chosen on the page
    * Return Type  : void
    * Parameter    : N/A
    **/
    public void search() {
        if(String.ValueOf(sLegSupId) == '' && String.ValueOf(sGlobalCommId) == '' &&
            String.ValueOf(sGlobalSupId) == '' && oUtilityObj.Print_Date__c == null &&
            oUtilityObj2.Print_Date__c == null) {
            bShowError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,
                System.Label.Search_Letters_Error_Msg1);
            ApexPages.addMessage(myMsg);
            return;
        }
        if(String.ValueOf(sLegSupId) != '') {
            Account oAcc = new Account();
            if(String.ValueOf(sLegSupId) != '') {
                oAcc = [Select id, Global_Number__c, Global_Partner__c from Account where GP_Supporter_ID__c = :
                    String.escapeSingleQuotes(sLegSupId)
                ];
            }
            if(oAcc != null && sLoggedInUserGPId != '' && oAcc.Global_Partner__c !=
                sLoggedInUserGPId) {
                System.debug('oAcc.Global_Number__c: ' + oAcc.Global_Partner__c +
                    ' sLoggedInUserGPId: ' + sLoggedInUserGPId);
                bShowError = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,
                    System.Label.Search_Letters_Error_Msg2);
                ApexPages.addMessage(myMsg);
                return;
            }
        }
        String DbQuery =
            'Select id, Name, Status__c, Original_Letter_Link__c, Final_Composed_Letter_Link__c,' +
            ' SUP_ID__r.Global_Partner__c, SUP_Global_ID__c, GP_Supporter_ID__c, SUP_ID__r.Preferred_Name__pc, SUP_ID__r.Delivery_Preference__c,' +
            ' SUP_ID__r.Name, SUP_ID__r.Gender__c, BEN_Global_ID__c, BEN_Compass_ID__c, BEN_Local_ID__c, BEN_ID__r.Name, ' +
            ' Original_Text__c, Final_Translated_Text__c, Translated_Text_English__c, ' +
            ' Communication_Types__c from Communication_Kit__c where id != null ';
        if(String.ValueOf(sLegSupId) != '') {
            DbQuery += ' AND GP_Supporter_ID__c = \'' + String.escapeSingleQuotes(
                sLegSupId) + '\'';
        }
        if(String.ValueOf(sGlobalSupId) != '') {
            DbQuery += ' AND SUP_Global_ID__c = \'' + String.escapeSingleQuotes(
                sGlobalSupId) + '\'';
        }
        if(String.ValueOf(sGlobalCommId) != '') {
            DbQuery += ' AND Name = \'' + String.escapeSingleQuotes(sGlobalCommId) +
                '\'';
        }
        if(String.escapeSingleQuotes(sChosenLetterType) == Constants.Ben_Search_S2B) {
            DbQuery += ' AND RecordTypeId = \'' + sRecordTypeS2B + '\'';
        } else if(String.escapeSingleQuotes(sChosenLetterType) == Constants.Ben_Search_B2S) {
            DbQuery += ' AND RecordTypeId = \'' + sRecordTypeB2S + '\'';
            DbQuery += ' AND Status__c = \'' + sBenStatus + '\'';
        }
        if(UserInfo.getUserType() == Constants.POWERPARTNER)
            DbQuery += ' AND SUP_ID__r.Global_Partner__c = \'' + sLoggedInUserGPId +
            '\'';

        if(oUtilityObj.Print_Date__c != null) {
            DateTime dPrint = Datetime.newinstance(oUtilityObj.Print_Date__c.year(),
                oUtilityObj.Print_Date__c.month(), oUtilityObj.Print_Date__c.day());
            DbQuery = DbQuery + ' AND CreatedDate>= ' + dPrint.format(
                'yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }
        if(oUtilityObj2.Print_Date__c != null) {
            DateTime dPrint = Datetime.newinstance(oUtilityObj2.Print_Date__c.year(),
                oUtilityObj2.Print_Date__c.month(), oUtilityObj2.Print_Date__c.day() + 1);
            DbQuery = DbQuery + ' AND CreatedDate <= ' + dPrint.format(
                'yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }
        DbQuery = DbQuery + ' LIMIT 5000';
        system.debug('DbQuery : ' + DbQuery);
        lstResult = Database.query(DbQuery);
        bShowResTbl = true;
        sDisplay = 'block';
    }    
}