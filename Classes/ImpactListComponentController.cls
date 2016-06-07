/******************************************************************************
Class Name         : ImpactListComponentController
Description        : It is the component controller which is used to implement
                     both ICP and Beneficiary Impact List functionality
Created By         : Sudipta Nayak 
Created On         : 16-Oct-2015 
********************************************************************************
Modification History:

********************************************************************************/

public class ImpactListComponentController {
    
    public List<Beneficiary_Impact__c> lstBeneficiaryToDisplay {
        get;
        set;
    }
    public List<ICP_Impact__c> lstICPToDisplay {
        get;
        set;
    }
}