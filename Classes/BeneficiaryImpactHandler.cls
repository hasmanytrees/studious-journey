/******************************************************************************************************
Class Name         : BeneficiaryImpactHandler
Description        : This is single Class for Beneficiary_Impact__c which will cover all it's trigger 
					 functionality. These methods will be called from BeneficiaryImpactTrigger based 
					 on required trigger events.
Created By         : Sudipta Nayak
Created On         : 24-Jul-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class BeneficiaryImpactHandler {

	/**
	 * Method name  : onBeforeInsert
	 * Description  : This method will be called before any Beneficiary Impact record is inserted
	 * Return Type  : void
	 * Parameter    : List<Beneficiary_Impact__c>
	 **/
	public void onBeforeInsert(List<Beneficiary_Impact__c> lstNewRecords) {
		updateSupporterInformation(lstNewRecords);
	}

	/**
	 * Method name  : updateSupporterInformation
	 * Description  : This method will auto-populate the Supporter Information on the Beneficiary Impact record
	 * Return Type  : void
	 * Parameter    : List<Beneficiary_Impact__c>
	 **/
    private void updateSupporterInformation(List<Beneficiary_Impact__c> lstNewRecords) {
        
        Set<Id> setBeneficiaryIds = new Set<Id>();
        Set<Id> setSupporterIds = new Set<Id>();
        list<Commitment__c> lstCommitments = new list<Commitment__c>();
        map<Id, list<Commitment__c>> mapBeneficiaryToSupporter = new map<Id, list<Commitment__c>>();
        map<Id, Account> mapSupporterToGlobalPartner = new map<Id, Account>();
        
        for(Beneficiary_Impact__c oBenImpact: lstNewRecords) {
            setBeneficiaryIds.add(oBenImpact.BEN_Name__c);
        }
        
        if(!setBeneficiaryIds.isEmpty()) {
            lstCommitments = [SELECT id, BEN_Id__c, SUP_Id__c, Relationship_Type__c, Status__c from Commitment__c 
                              where BEN_Id__c in: setBeneficiaryIds AND Status__c =: Constants.ACTIVE 
                             ];
        }
        
        if(!lstCommitments.isEmpty()) {
            
            for(Commitment__c oCommitment: lstCommitments) {
                
                if(!mapBeneficiaryToSupporter.containsKey(oCommitment.BEN_Id__c)) 
                    mapBeneficiaryToSupporter.put(oCommitment.BEN_Id__c, new list<Commitment__c>{oCommitment});
                else
                    mapBeneficiaryToSupporter.get(oCommitment.BEN_Id__c).add(oCommitment);
                setSupporterIds.add(oCommitment.SUP_Id__c);
            }
            if(!setSupporterIds.isEmpty()) {
                
                mapSupporterToGlobalPartner = new Map<Id, Account> ([Select Id,
                                                                     Global_Partner__r.Name, 
                                                                     GP_Supporter_ID__c, 
                                                                     Global_Number__c 
                                                                     from Account
                                                                     where Id in :setSupporterIds
                                                                    ]);
                
                if(!mapSupporterToGlobalPartner.isEmpty() && !mapBeneficiaryToSupporter.isEmpty()) {
                    for(Beneficiary_Impact__c oBenImpact: lstNewRecords) {
                        list<Commitment__c> lstCommitment = new list<Commitment__c>();
                        Account  oGlobalPartnerRelatedToFirstSupporter =  new Account();
                        Account  oGlobalPartnerRelatedToSecondSupporter =  new Account();
                        
                        if(mapBeneficiaryToSupporter.containsKey(oBenImpact.BEN_Name__c)) {
                        	lstCommitment.addAll(mapBeneficiaryToSupporter.get(oBenImpact.BEN_Name__c));
                        }
                        if(lstCommitment.size() == 1) {
                            oGlobalPartnerRelatedToFirstSupporter = mapSupporterToGlobalPartner.get(lstCommitment[0].SUP_Id__c);
                        }
                        else if(lstCommitment.size() == 2) {
                            oGlobalPartnerRelatedToFirstSupporter = mapSupporterToGlobalPartner.get(lstCommitment[0].SUP_Id__c);
                            oGlobalPartnerRelatedToSecondSupporter = mapSupporterToGlobalPartner.get(lstCommitment[1].SUP_Id__c);
                        }
                        
                        if(!lstCommitment.isEmpty() && oGlobalPartnerRelatedToFirstSupporter != NULL) {
                            if(lstCommitment.size() == 1 &&
                               lstCommitment[0].Relationship_Type__c == 
                               Constants.COMMITMENT_TYPE_CORRESPONDENT) {
                                   
                                   oBenImpact.Correspondent_ID__c = oGlobalPartnerRelatedToFirstSupporter.GP_Supporter_ID__c;
                                   oBenImpact.Correspondent_Country__c = oGlobalPartnerRelatedToFirstSupporter.Global_Partner__r.Name;
                                   oBenImpact.Correspondent_Global_ID__c = oGlobalPartnerRelatedToFirstSupporter.Global_Number__c;
                               }
                            else if(lstCommitment.size() == 1 &&
                                    lstCommitment[0].Relationship_Type__c == 
                                    Constants.COMMITMENT_TYPE_SPONSORSHIP) {
                                        
                                        oBenImpact.Sponsor_ID__c = oGlobalPartnerRelatedToFirstSupporter.GP_Supporter_ID__c;
                                        oBenImpact.Sponsor_Country__c = oGlobalPartnerRelatedToFirstSupporter.Global_Partner__r.Name;
                                        oBenImpact.Sponsor_Global_ID__c = oGlobalPartnerRelatedToFirstSupporter.Global_Number__c;
                                    }
                            else if (lstCommitment.size() == 2) {
                                if(lstCommitment[0].Relationship_Type__c == 
                                   Constants.COMMITMENT_TYPE_SPONSORSHIP) {
                                       oBenImpact.Sponsor_ID__c = oGlobalPartnerRelatedToFirstSupporter.GP_Supporter_ID__c;
                                       oBenImpact.Sponsor_Country__c = oGlobalPartnerRelatedToFirstSupporter.Global_Partner__r.Name;
                                       oBenImpact.Sponsor_Global_ID__c = oGlobalPartnerRelatedToFirstSupporter.Global_Number__c;
                                       
                                       oBenImpact.Correspondent_ID__c = oGlobalPartnerRelatedToSecondSupporter.GP_Supporter_ID__c;
                                       oBenImpact.Correspondent_Country__c = oGlobalPartnerRelatedToSecondSupporter.Global_Partner__r.Name;
                                       oBenImpact.Correspondent_Global_ID__c = oGlobalPartnerRelatedToSecondSupporter.Global_Number__c;
                                   }
                                else {
                                    oBenImpact.Correspondent_ID__c = oGlobalPartnerRelatedToFirstSupporter.GP_Supporter_ID__c;
                                    oBenImpact.Correspondent_Country__c = oGlobalPartnerRelatedToFirstSupporter.Global_Partner__r.Name;
                                    oBenImpact.Correspondent_Global_ID__c = oGlobalPartnerRelatedToFirstSupporter.Global_Number__c;
                                    
                                    oBenImpact.Sponsor_ID__c = oGlobalPartnerRelatedToSecondSupporter.GP_Supporter_ID__c;
                                    oBenImpact.Sponsor_Country__c = oGlobalPartnerRelatedToSecondSupporter.Global_Partner__r.Name;
                                    oBenImpact.Sponsor_Global_ID__c = oGlobalPartnerRelatedToSecondSupporter.Global_Number__c;
                                }
                            }
                            else if(lstCommitment.size() > 2) {
                                System.debug('Incorrect data. Beneficiary should have only 2 commitment record');
                            }
                        }
                    }
                }
            }
        }
    }
}