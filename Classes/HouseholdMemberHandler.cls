/******************************************************************************************************
Class Name         : HouseholdMemberHandler
Description        : This is single Class for Household_Member__c which will cover all it's trigger functionality.
                     These methods will be called from HouseholdMemberTrigger based on required trigger events.
Created By         : Himanshu Raichandani 
Created On         : 24-Nov-2014 
******************************************************************************************************/
public class HouseholdMemberHandler {

    /**
     * Method name  : OnBeforeInsert
     * Description  : This method will be called before any Household Member record is inserted
     * Return Type  : void
     * Parameter    : List<Household_Member__c> lstNewRecords
     **/
    public void onBeforeInsert(List<Household_Member__c> lstNewRecords) {
        updateHMBenefFlag(lstNewRecords, null);
        restrictMultiplePrimaryCaregiver(lstNewRecords, null) ; 
    }

    /**
     * Method name  : onBeforeUpdate
     * Description  : This method will be called before any Household Member record is updated
     * Return Type  : void
     * Parameter    : List<Household_Member__c> lstNewRecords, Map<Id,Household_Member__c> mapOldRecords
     **/
    public void onBeforeUpdate(List<Household_Member__c> lstNewRecords, Map <
        Id, Household_Member__c> mapOldRecords) {
        updateHMBenefFlag(lstNewRecords, mapOldRecords);
        restrictMultiplePrimaryCaregiver(lstNewRecords, mapOldRecords);
    }
    
    /**
     * Method name  : OnBeforeInsert
     * Description  : This method will be called before any Household Member record is inserted
     * Return Type  : void
     * Parameter    : List<Household_Member__c> lstNewRecords
     **/
    public void onAfterInsert(List<Household_Member__c> lstNewRecords) {
        updateBenOnChangeofPrimCaregiver (lstNewRecords, null);
    }

    /**
     * Method name  : onBeforeUpdate
     * Description  : This method will be called before any Household Member record is updated
     * Return Type  : void
     * Parameter    : List<Household_Member__c> lstNewRecords, Map<Id,Household_Member__c> mapOldRecords
     **/
    public void onAfterUpdate(List<Household_Member__c> lstNewRecords, Map <
        Id, Household_Member__c> mapOldRecords) {
        updateBenOnChangeofPrimCaregiver (lstNewRecords, mapOldRecords);
    }
    

    /**
    * Method name  : updateHMBenefFlag
    * Description  : This method updates flag which signifies if HM is beneficiary or not. Based on this field's value, number of beneficiaries in Household
                     is rolled up and used for Report purposes
    * Return Type  : void
    * Parameter    : List<Household_Member__c> lstNewRecords, Map<Id,Household_Member__c> mapOldRecords
    **/
    private void updateHMBenefFlag(List<Household_Member__c> lstNewRecords, Map <
        Id, Household_Member__c> mapOldRecords) {

        List<Household_Member__c> lstHMToUpdate = new List<Household_Member__c>
            ();
        for(Household_Member__c oMember: lstNewRecords)
            if((null == mapOldRecords && null <> oMember.Existing_Beneficiary__c) || (
                    null <> mapOldRecords && oMember.Existing_Beneficiary__c <>
                    mapOldRecords.get(oMember.Id)
                    .Existing_Beneficiary__c))
                lstHMToUpdate.add(oMember);

        for(Household_Member__c oMember: lstHMToUpdate)
            oMember.Is_Household_Member_Beneficiary__c = (null == oMember.Existing_Beneficiary__c) ?
            false : true;
    }
    
    /**
    * Method name  : restrictMultiplePrimaryCaregiver
    * Description  : To restrict mutiple primary caregiver on same household.
    * Return Type  : void
    * Parameter    : List<Household_Member__c> lstNewRecords, Map<Id,Household_Member__c> mapOldRecords
    **/
    private void restrictMultiplePrimaryCaregiver(List<Household_Member__c> lstNewRecords, Map <
        Id, Household_Member__c> mapOldRecords) {

        Set<Id> setHouseHoldIds = new Set<Id> () ; 
        Set<Id> setPChouseholdIds = new Set<Id> () ;
        
        for(Household_Member__c oHouseholdMem : lstNewRecords ) {
            if( Trigger.IsInsert && oHouseholdMem.Is_Primary_Caregiver__c ) {
                setHouseHoldIds.add( oHouseholdMem.Household__c ) ; 
            }
            if( Trigger.IsUpdate && ( oHouseholdMem.Is_Primary_Caregiver__c && !mapOldRecords.get(oHouseholdMem.Id).Is_Primary_Caregiver__c ) ) {
                setHouseHoldIds.add( oHouseholdMem.Household__c ) ; 
            }    
        } 
        
        for(Household_Member__c oPCMember :  [Select Household__c from Household_Member__c where Household__c IN: setHouseHoldIds AND Is_Primary_Caregiver__c = true ] ) {
            setPChouseholdIds.add( oPCMember.Household__c ) ; 
        }
        
        if( setPChouseholdIds != NULL && setPChouseholdIds.size() > 0 ){
            for(Household_Member__c oHouseholdMem : lstNewRecords ) {
                if( oHouseholdMem.Is_Primary_Caregiver__c && setPChouseholdIds.contains( oHouseholdMem.Household__c ) ) {
                    oHouseholdMem.Is_Primary_Caregiver__c.addError( System.Label.Error_multiple_Primary_Caregivers );     
                }    
            }
        }
         
    }
    
    /**
    * Method name  : updateBenOnChangeofPrimCaregiver 
    * Description  : To update Beneficiary on change of Primary caregiver.
    * Return Type  : void
    * Parameter    : List<Household_Member__c> lstNewRecords, Map<Id,Household_Member__c> mapOldRecords
    **/
    private void updateBenOnChangeofPrimCaregiver (List<Household_Member__c> lstNewRecords, Map <
        Id, Household_Member__c> mapOldRecords) {
        
        map<ID , ID> mapHouseHoldPCvals =  new map<ID , ID> () ; 
        
        for(Household_Member__c oHouseholdMem : lstNewRecords ) {
            if( Trigger.IsInsert && oHouseholdMem.Is_Primary_Caregiver__c ) {
                mapHouseHoldPCvals.put( oHouseholdMem.Household__c , oHouseholdMem.ID ) ; 
            }
            if( Trigger.IsUpdate && ( oHouseholdMem.Is_Primary_Caregiver__c != mapOldRecords.get(oHouseholdMem.Id).Is_Primary_Caregiver__c
                && oHouseholdMem.Is_Primary_Caregiver__c ) ) {
                    mapHouseHoldPCvals.put( oHouseholdMem.Household__c , oHouseholdMem.ID ) ;  
                    
            }    
        }  
        if( mapHouseHoldPCvals != NULL && mapHouseHoldPCvals.keyset().size() > 0 ){
            Id cdspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CDSP_BENEFICIARY_RT_API_NAME);
            Id cspRecTypeId = Utility.getRecordTypeIdByDeveloperName(Account.SObjectType,
            Constants.CSP_BENEFICIARY_RT_API_NAME);
            List<Account> lstBeneficiariesUpdate = new List<Account> () ; 
            
            try{
                lstBeneficiariesUpdate = [Select Primary_Caregiver__c ,Household__c from Account 
                                          where Household__c IN:mapHouseHoldPCvals.keyset() 
                                          AND (Recordtypeid =:cdspRecTypeId OR Recordtypeid =:cspRecTypeId)
                                          /*AND ( Beneficiary_Status__c = : Constants.ACTIVE OR Beneficiary_Status__c = : Constants.DRAFT)*/] ; 
            }catch(System.QueryException oQe) {
                ErrorLogUtility.logGeneralError(oQe, 'HouseholdMemberHandler ',
                    'updateBenOnChangeofPrimCaregiver', 'SFDC CI');
                return;
            }
            If( lstBeneficiariesUpdate != NULL && lstBeneficiariesUpdate.size() > 0){
                for( Account oBeneficary : lstBeneficiariesUpdate ){
                    oBeneficary.Primary_Caregiver__c = mapHouseHoldPCvals.get(oBeneficary.Household__c) ; 
                }

                system.debug('lstBeneficiariesUpdate>>>'+lstBeneficiariesUpdate ) ; 
                List<Database.SaveResult> lstUpdateResults =
                Database.update(lstBeneficiariesUpdate, false);
                system.debug('lstUpdateResults>>>'+lstUpdateResults  ) ;
                Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstBeneficiariesUpdate, 'Account',
                'HouseholdMemberHandler', 'updateBenOnChangeofPrimCaregiver', 'SFDC CI',
                false);
            }                           
        }   
    }
}