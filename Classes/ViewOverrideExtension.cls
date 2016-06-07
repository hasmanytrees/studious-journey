/************************************************************************************************** 
Class Name   : ViewOverrideExtension
Created By   : Manzoor Shaik
Created Date : 20-July-2015
Description  : This extension class is written for VF page OverrideView.
               This will redirect user to standard or custom account page.
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public  class ViewOverrideExtension{
    Public Account record;
    
    /**
    * Method name  : ViewOverrideExtension
    * Description  : This is a constructor used for Setting record values..
    * Return Type  : NA
    * Parameter    : ApexPages.StandardController
    **/
    public ViewOverrideExtension(ApexPages.StandardController controller){
        record = (Account)controller.getrecord();
        
    }
    
    /**
    * Method name  : gatherRelatedData
    * Description  : This method is used to redirect users to Standard or Custom page
                     of Account.
    * Return Type  : void
    * Parameter    : NA
    **/
    public Pagereference customStandardViewLogic(){
        Set<Id> setProfileId = new Set<Id>();
        for(Profile oProfile: [Select Id from Profile where Name =: Constants.ICP_FULL_ACCESS_PROFILE OR Name =: Constants.ICP_READ_ONLY_PROFILE OR Name =: Constants.ICP_PROGRAM_IMPLEMENTER_PROFILE]){
            setProfileId.add(oProfile.Id);
        }
        if(setProfileId.Contains(UserInfo.getProfileId()))  {
            If(record.Check_Record__c == Constants.MY_RECORD || record.RecordType.DeveloperName == Constants.FIELD_OFFICE_RT_API_NAME){
                pagereference pg = new pagereference ( '/'+record.Id+Constants.NOOVERRIDE) ; 
                pg.setRedirect(true);
                return pg;            
            }
            else{
                pagereference pg = new pagereference ( Constants.ICP_READ_ONLY_PAGE+record.Id) ; 
                pg.setRedirect(true);
                return pg;                
            }
        }
        else{
            pagereference pg = new pagereference ( '/'+record.Id+Constants.NOOVERRIDE) ; 
            pg.setRedirect(true);
            return pg;            
        }
        return null;
    }
    
}