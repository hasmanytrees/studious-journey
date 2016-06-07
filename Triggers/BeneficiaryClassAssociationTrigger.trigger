trigger BeneficiaryClassAssociationTrigger on Beneficiary_Class_Association__c (after Insert, after Delete) {
    BeneficiaryClassAssociationHandler beneficiaryClassAssociationHandler = new BeneficiaryClassAssociationHandler();
    
    if( Trigger.IsAfter && Trigger.IsInsert ) {
        System.debug('After Insert');
        beneficiaryClassAssociationHandler.onAfterInsert(trigger.new);
    }
    if( Trigger.IsAfter && Trigger.IsDelete ) {
        System.debug('After Delete');
        beneficiaryClassAssociationHandler.onAfterDelete(trigger.old);
    }
}