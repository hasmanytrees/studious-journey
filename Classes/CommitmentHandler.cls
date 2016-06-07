/******************************************************************************************************
Class Name         : CommitmentHandler
Description        : This is single Class for Commitment Object which will cover all it's trigger functionality.
                     These methods will be called from CommitmentTrigger based on required trigger events.
Created By         : Rahul Agarwal 
Created On         : 13-Aug-2015
******************************************************************************************************/
public class CommitmentHandler {

    /**
     * Method name  : onBeforeInsert
     * Description  : This method will be called before any Commitment record is inserted
     * Return Type  : void
     * Parameter    : Map<Id, Commitment__c>
     **/
    public static void onBeforeInsert(List<Commitment__c> lstNewRecords) {
        if(System.Label.Disable_for_Data_Load_R3 != 'true') {
          //  checkforActiveBeneficiary(lstNewRecords);
            checkForExistingCorrespondence(lstNewRecords);
        }
        setCorrespondenceLanguage(lstNewRecords);
    }

    /**
     * Method name  : onBeforeUpdate
     * Description  : This method will be called before any Commitment record is updated
     * Return Type  : void
     * Parameter    : Map<Id, Commitment__c>
     **/
    public static void onBeforeUpdate(List<Commitment__c> lstNewRecords) {
        if(System.Label.Disable_for_Data_Load_R3 != 'true') {
           // checkforActiveBeneficiary(lstNewRecords);
            checkForExistingCorrespondence(lstNewRecords);
        }
    }


    /**
     * Method name  : onAfterInsert
     * Description  : This method will be called after any Commitment record is inserted
     * Return Type  : void
     * Parameter    : Map<Id, Commitment__c>
     **/
    public static void onAfterInsert(map<Id, Commitment__c> mapTriggerNew) {
        if(System.Label.Disable_for_Data_Load_R3 != 'true') {
            checkForCorrespondence(mapTriggerNew);
            updateSponsorshipStatus(mapTriggerNew, null);
            sendUpdateToUS(mapTriggerNew, null);
        }
    }

    /**
     * Method name  : onAfterUpdate
     * Description  : This method will be called after any Commitment record is updated
     * Return Type  : void
     * Parameter    : Map<Id, Commitment__c>, Map<Id, Commitment__c>
     **/
    public static void onAfterUpdate(map<Id, Commitment__c> mapTriggerNew, map <
        Id, Commitment__c> mapTriggerOld) {
        if(System.Label.Disable_for_Data_Load_R3 != 'true') {
            checkForCorrespondence(mapTriggerNew);
            updateSponsorshipStatus(mapTriggerNew, mapTriggerOld);
            sendUpdateToUS(mapTriggerNew, mapTriggerOld);
        }

    }

    /**
     * Method name  : checkforActiveBeneficiary
     * Description  : This method will see if the commitment's beneficiary is Active 
                      or not   
     * Return Type  : void
     * Parameter    : Map<Id, Commitment__c>
     **/
    private static void checkforActiveBeneficiary(List<Commitment__c>
        lstNewRecords) {
        Map<ID, Commitment__c> BenMap = new Map<ID, Commitment__c>();
        Map<ID, String> BenStatusMap = new Map<ID, String>();
        for(Commitment__c CurrRec: lstNewRecords) {
            BenMap.put(CurrRec.BEN_Id__c, CurrRec);
            BenStatusMap.put(CurrRec.BEN_Id__c, CurrRec.Status__c);
        }

        for(Account oAcc: [Select id, Beneficiary_Status__c from Account where id IN:
                BenMap.keyset()
            ]) {
            if(oAcc.Beneficiary_Status__c != Constants.COMMITMENT_STATUS_ACTIVE &&
                BenStatusMap.get(oAcc.id) == Constants.COMMITMENT_STATUS_ACTIVE) {
                BenMap.get(oAcc.id)
                    .addError(System.Label.Commitment_No_Active_Beneficiary_Error);
            }
        }
    }

    /**
     * Method name  : checkForExistingCorrespondence
     * Description  : This method will see if there already exists a commitment of the type 
                      being inserted between the supporter & the beneficiary
     * Return Type  : void
     * Parameter    : Map<Id, Commitment__c>
     **/
    private static void checkForExistingCorrespondence(List<Commitment__c>
        lstNewRecords) {

        Map<ID, Commitment__c> BenMap = new Map<ID, Commitment__c>();
        for(Commitment__c CurrRec: lstNewRecords) {
            BenMap.put(CurrRec.BEN_Id__c, CurrRec);
        }

        for(Commitment__c CommRec: [Select id, BEN_Id__c, Status__c,
                Relationship_Type__c from Commitment__c where BEN_Id__c IN: BenMap.keyset()
            ]) {
            system.debug('>>>> CommRec.Relationship_Type__c' + CommRec.Relationship_Type__c);
            system.debug('>>>> BenMap.get(CommRec.BEN_Id__c).Relationship_Type__c' +
                BenMap.get(CommRec.BEN_Id__c)
                .Relationship_Type__c);
            if(CommRec.Relationship_Type__c == BenMap.get(CommRec.BEN_Id__c)
                .Relationship_Type__c && CommRec.Status__c == Constants.COMMITMENT_STATUS_ACTIVE &&
                CommRec.id != BenMap.get(CommRec.BEN_Id__c)
                .id
            ) {
                system.debug('>>>> Throwing Error ');
                system.debug('>>>> id : ' + BenMap.get(CommRec.BEN_Id__c)
                    .id);
                BenMap.get(CommRec.BEN_Id__c)
                    .addError(System.Label.Commitment_Already_Exists_Error + CommRec.Relationship_Type__c +
                        System.Label.Commitment_Cannot_Insert_Error);
            }

        }


    }


    /**
     * Method name  : updateSponsorshipStatus
     * Description  : This method will update the commitment's beneficiary's Sponsorship status 
     * Return Type  : void
     * Parameter    : Map<Id, Commitment__c>
     **/
      private static void updateSponsorshipStatus(map<Id, Commitment__c>
        mapTriggerNew, map<id, Commitment__c> mapTriggerOld) {
        Set<ID> setAcc = new Set<ID>();

        List<Account> lstOfAcc = new List<Account>();
        map<String, String> mapLocalBenIdCommType = new map<String, String>();

        if(mapTriggerOld == null) {
            Set<ID> setAccLetter = new Set<ID>();            
            for(ID RecId: mapTriggerNew.keyset()) {
                Commitment__c oCurrComm = mapTriggerNew.get(RecId);
                if(oCurrComm.Relationship_Type__c == Constants.COMMITMENT_TYPE_SPONSORSHIP &&
                    oCurrComm.Status__c == Constants.COMMITMENT_STATUS_ACTIVE) {
                    setAcc.add(oCurrComm.BEN_Id__c);
                    if(oCurrComm.New_Sponsor_Letter_Required__c == true) {
                        setAccLetter.add(oCurrComm.BEN_Id__c);
                    }
                }
            }
           /* MV: Added code to cause sponsorship status flip to unsponsored when backdated commitment 
          records with end dates are inserted and there is no active commitment */ 
            
            Set<ID> setAccToUnsponsr = new Set<ID>();
            map<Id , Commitment__c> mapBenfCommitment =  new map<Id ,Commitment__c>([select id ,Relationship_Type__c , 
                     BEN_Id__r.Active_Commitment_Count__c,Status__c,End_Date__c  from Commitment__c
                       where id in: mapTriggerNew.keyset()]);
           if(null != mapBenfCommitment.keyset()){
           for(ID RecId : mapBenfCommitment.keyset())
            {
            Commitment__c ocommit = mapBenfCommitment.get(RecId);
                
            if(ocommit.Relationship_Type__c == Constants.COMMITMENT_TYPE_SPONSORSHIP &&
                 ocommit.Status__c == Constants.COMMITMENT_STATUS_INACTIVE && 
                  ocommit.BEN_Id__r.Active_Commitment_Count__c < 1 && (null <> ocommit.End_Date__c)&&
                  !(oCommit.End_Date__c > Date.today()))
                    {
                    setAccToUnsponsr.add(ocommit.BEN_Id__c);                     
                    }             
              } 
            }
             if(!setAcc.isEmpty() || !setAccToUnsponsr.isEmpty()){
            lstOfAcc = [Select id, Sponsorship_Status__pc, Beneficiary_Status__c,
                Local_Beneficiary_ID__c from Account where id IN: setAcc OR id IN:setAccToUnsponsr
            ];
            for(Account CurrAcc: lstOfAcc) {
            if(setAcc.contains(CurrAcc.id))
                {
                CurrAcc.Sponsorship_Status__pc = Constants.BENEFICIARY_SPONSORED;
                }
                if(setAccLetter.contains(CurrAcc.id) && CurrAcc.Beneficiary_Status__c ==
                    Constants.ACTIVE) {
                    mapLocalBenIdCommType.put(String.ValueOf(CurrAcc.Local_Beneficiary_ID__c),
                        Constants.NEW_SPONSOR_LETTER);
                }
                  /* MV: Added code to cause sponsorship status flip to unsponsored when backdated commitment 
             records with end dates are inserted and there is no active commitment */
             
                if(setAccToUnsponsr.contains(CurrAcc.id)&& !(setAcc.contains(CurrAcc.id)))
                {
                    CurrAcc.Sponsorship_Status__pc = Constants.BENEFICIARY_UNSPONSORED;
                }
            }
            }
            
            
        } else {
            Set<ID> setAccSponsored = new Set<ID>();
            Set<ID> setAccUnsponsored = new Set<ID>();
            Set<ID> setAccLetter = new Set<ID>();
            for(ID RecId: mapTriggerNew.keyset()) {
                Commitment__c oCurrComm = mapTriggerNew.get(RecId);
                if(oCurrComm.Relationship_Type__c == Constants.COMMITMENT_TYPE_SPONSORSHIP &&
                    oCurrComm.Status__c != mapTriggerOld.get(RecId)
                    .Status__c) {
                    if(oCurrComm.Status__c == Constants.COMMITMENT_STATUS_ACTIVE) {
                        setAccSponsored.add(oCurrComm.BEN_Id__c);
                        if(oCurrComm.New_Sponsor_Letter_Required__c == true) {
                            setAccLetter.add(oCurrComm.BEN_Id__c);
                        }
                    } else if(oCurrComm.Status__c == Constants.COMMITMENT_STATUS_INACTIVE) {
                        setAccUnsponsored.add(oCurrComm.BEN_Id__c);
                    }
                }
            }

            List<Account> lstOfAccBoth = [Select id, Sponsorship_Status__pc,
                Beneficiary_Status__c, Local_Beneficiary_ID__c from Account where id IN:
                setAccSponsored OR id IN: setAccUnsponsored
            ];
            for(Account CurrAcc: lstOfAccBoth) {
                if(setAccSponsored.contains(CurrAcc.id)) {
                    CurrAcc.Sponsorship_Status__pc = Constants.BENEFICIARY_SPONSORED;
                    if(setAccLetter.contains(CurrAcc.id) && CurrAcc.Beneficiary_Status__c ==
                        Constants.ACTIVE) {
                        mapLocalBenIdCommType.put(String.ValueOf(CurrAcc.Local_Beneficiary_ID__c),
                            Constants.NEW_SPONSOR_LETTER);
                    }
                } else if(setAccUnsponsored.contains(CurrAcc.id)) {
                    CurrAcc.Sponsorship_Status__pc = Constants.BENEFICIARY_UNSPONSORED;
                }
            }
            lstOfAcc.addall(lstOfAccBoth);
        }

        if(!lstOfAcc.isEmpty()) {
            List<Database.SaveResult> lstUpdateResults =
                Database.update(lstOfAcc, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstOfAcc, 'Account',
                'CommitmentHandler', 'updateSponsorshipStatus', 'SFDC CI', false);
        }

        CommunicationKitHandler.findOrCreateCommKitRecord(mapLocalBenIdCommType,
            null);

    }

    /**
     * Method name  : checkForCorrespondence
     * Description  : This method will see if the commitment of type correspondent is either getting
                      added or removed from a beneficiary and mark the same on beneficiary
     * Return Type  : void
     * Parameter    : Map<Id, Commitment__c>
     **/
    private static void checkForCorrespondence(map<Id, Commitment__c>
        mapTriggerNew) {
        set<Id> setBenIds = new set<Id>();
        set<Id> setCheckForBenIds = new set<Id>();
        for(Commitment__c oCommitment: mapTriggerNew.Values())
            if(oCommitment.Relationship_Type__c != null && oCommitment.Status__c !=
                null &&
                oCommitment.Relationship_Type__c == COnstants.COMMITMENT_TYPE_CORRESPONDENT &&
                oCommitment.Status__c ==
                Constants.COMMITMENT_STATUS_ACTIVE && oCommitment.BEN_Id__c != null)
                setBenIds.add(oCommitment.BEN_Id__c);
            else if(oCommitment.BEN_Id__c != null)
            setCheckForBenIds.add(oCommitment.BEN_Id__c);



        list<Commitment__c> lstCommitment = new list<Commitment__c>();
        try {
            lstCommitment = [select Id, BEN_Id__c from Commitment__c where BEN_Id__c IN:
                setCheckForBenIds AND Status__c = : Constants.COMMITMENT_STATUS_ACTIVE
                AND Relationship_Type__c = : Constants.COMMITMENT_TYPE_CORRESPONDENT
            ];
        } catch(System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'CommitmentHandler',
                'checkForCorrespondence', 'SFDC CI');
        }
        for(Commitment__c oCommitment: lstCommitment) {
            setBenIds.add(oCommitment.BEN_Id__c);
            setCheckForBenIds.remove(oCommitment.BEN_Id__c);
        }



        list<Account> lstBeneficiaries = new list<Account>();
        try {
            lstBeneficiaries = [select Id, BEN_INT_Have_Correspondent__c from Account where(
                Id IN: setBenIds AND BEN_INT_Have_Correspondent__c = false) OR(Id IN:
                setCheckForBenIds AND BEN_INT_Have_Correspondent__c = true)];
        } catch(System.QueryException oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'CommitmentHandler',
                'checkForCorrespondence', 'SFDC CI');
        }
        for(Account oAcc: lstBeneficiaries)
            oAcc.BEN_INT_Have_Correspondent__c = !oAcc.BEN_INT_Have_Correspondent__c;

        if(!lstBeneficiaries.isEmpty()) {
            List<Database.SaveResult> lstUpdateResults =
                Database.update(lstBeneficiaries, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstBeneficiaries, 'Account',
                'CommitmentHandler', 'checkForCorrespondence', 'SFDC CI', false);
        }
    }


    /**
     * Method name  : sendUpdateToUS
     * Description  : This method will see if the commitment of type correspondent/sponsor is either getting
                      added or removed from a beneficiary and mark the same on beneficiary
     * Return Type  : void
     * Parameter    : Map<Id, Commitment__c>
     **/
    
    private static void sendUpdateToUS(Map<Id, Commitment__c> mapTriggerNew,
            Map<Id, Commitment__c> mapTriggerOld) {

            Set<Id> setBenefIDToSend = new Set<Id>();
            Set<Id> setBenefIDToQuery = new Set<Id>();
            Commitment__c oComm = null;
            try {
            /* MV-Start:Modified logic to send information to US only if commitment is related to a US sponsor */ 
            String scompassionUSA = label.Compasssion_USA_Global_Partner_Name ;
            map<Id , Commitment__c> mapBenfCommitment =  new map<Id ,Commitment__c>([select id ,BEN_Id__c, 
                    Status__c,End_Date__c,SUP_Id__r.Global_Partner__r.name  from Commitment__c
                    where id in: mapTriggerNew.keyset() and SUP_Id__r.Global_Partner__r.name =:scompassionUSA]);
            if(null != mapBenfCommitment.keySet()){                                  
            for(Id comID: mapBenfCommitment.keySet()) {           
                oComm = mapBenfCommitment.get(comID);
                
                if(null<> mapTriggerOld && null<> mapTriggerOld.get(comID) &&
                 ((mapTriggerOld.get(comID).Status__c) <> oComm.Status__c) && (null<> oComm.Status__c && 
                 !TriggerContextUtility.setBenefIdsSentToUS.contains(oComm.BEN_Id__c) &&
                  (Constants.COMMITMENT_STATUS_ACTIVE.equals(oComm.Status__c) || 
                  Constants.COMMITMENT_STATUS_INACTIVE.equals(oComm.Status__c)))) {                    
                    setBenefIDToQuery.add(oComm.BEN_Id__c);
                    TriggerContextUtility.setBenefIdsSentToUS.add(oComm.BEN_Id__c); 
                    system.debug('@@update Integration call');                       
                        }
                
               Else if (null == mapTriggerOld && null<> oComm.Status__c && 
               !TriggerContextUtility.setBenefIdsSentToUS.contains(oComm.BEN_Id__c) &&
                (Constants.COMMITMENT_STATUS_ACTIVE.equals(oComm.Status__c) || 
                Constants.COMMITMENT_STATUS_INACTIVE.equals(oComm.Status__c))&&
                (null <> oComm.End_Date__c)&&!(oComm.End_Date__c > Date.today())) {                        
                    setBenefIDToQuery.add(oComm.BEN_Id__c);
                    TriggerContextUtility.setBenefIdsSentToUS.add(oComm.BEN_Id__c);
                    system.debug('@@Insert Integration call');
                }
            }
            }
           /* MV-End:Modified logic to send information to US only if commitment is related to a US sponsor */
           
            if(!setBenefIDToQuery.isEmpty()) {
                List<Account> lstBenefQueried = [Select Id from Account where Id in :
                    setBenefIDToQuery];
                if(!lstBenefQueried.isEmpty()) {
                system.debug('lstBenefQueried'+lstBenefQueried.size());
                    for(Account oBenef: lstBenefQueried) {
                        setBenefIDToSend.add(oBenef.Id);
                    }
                    
                    /* AB:11-02-16:Start:Logic to divide the set into 50 records per set */
                        if(!setBenefIDToSend.isEmpty()){
                        system.debug('setBenefIDToSend'+setBenefIDToSend.size());
                        Integer iStartIndexToCopy = 0;
                        List<Id> lstBenefIDToSend = new List<Id>(setBenefIDToSend);
                        Integer iRemBenefToSend = lstBenefIDToSend.size();
                        List<Id> lstBenefToSend = null;
                        while(iRemBenefToSend > 0){
                            lstBenefToSend = new List<Id>();
                            Integer iEndIndexToCopy = (iRemBenefToSend < = 50)?iStartIndexToCopy+iRemBenefToSend:iStartIndexToCopy+50;
                            for(Integer i = iStartIndexToCopy; i < iEndIndexToCopy; i++){
                                lstBenefToSend.add(lstBenefIDToSend.get(i));
                            }
                            iRemBenefToSend -= 50;
                            iStartIndexToCopy += 50;
                            iRemBenefToSend = (iRemBenefToSend<50)?Math.mod(iRemBenefToSend,50):iRemBenefToSend ;                       
                    System.debug('Calling SendBenefInfoToUS from CommitmentHandler with following lstBenefToSend:'+lstBenefToSend);
                    /* AB:11-02-16:End:Logic to divide the set into 50 records per set */  
                    System.enqueueJob(new SendBenefInfoToUS(new Set<Id>(lstBenefToSend)));
                    }
                }
            }  
        }
        }catch(Exception oQe) {
            ErrorLogUtility.logGeneralError(oQe, 'CommitmentHandler',
                'sendUpdateToUS', 'SFDC CI');
        }                
    }
    
    
        /**
         * Method name  : setCorrespondenceLanguage
         * Description  : This method sets Correspondence Language on Commitment from the GP
         * Return Type  : void
         * Parameter    : list<Commitment__c>
         **/
    private static void setCorrespondenceLanguage(list<Commitment__c>
        lstTriggerNew) {
        set<Id> setSupposrterIds = new set<Id>();
        for(Commitment__c oCommit: lstTriggerNew) {
            if(oCommit.SUP_ID__c != null)
                setSupposrterIds.add(oCommit.SUP_ID__c);
        }

        map<Id, Account> mapSupporter = new map<Id, Account> ([select Id,
            Global_Partner__c, Global_Partner__r.GP_Correspondence_Language__c from Account where Id IN:
            setSupposrterIds AND Global_Partner__c != null
        ]);
        for(Commitment__c oCommit: lstTriggerNew) {
            if(oCommit.SUP_ID__c != null && mapSupporter != null && mapSupporter.containsKey(
                    oCommit.SUP_ID__c) && mapSupporter.get(oCommit.SUP_ID__c)
                .Global_Partner__c !=
                null && mapSupporter.get(oCommit.SUP_ID__c)
                .Global_Partner__r.GP_Correspondence_Language__c !=
                null && oCommit.Supporter_Correspondence_Language__c == null)
                oCommit.Supporter_Correspondence_Language__c = mapSupporter.get(oCommit.SUP_ID__c)
                .Global_Partner__r.GP_Correspondence_Language__c;
        }
    }
}