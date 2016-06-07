public with sharing class ICPPortalPageExtension {

    public ICPPortalPageExtension(ApexPages.StandardController controller) {
   

    }
  
    //Modified the query to fetch correct Account ID - Ashish Vanarse
    public Pagereference icpRecordDetail(){
        try{
            User oCurrentUserInfo = [SELECT AccountId FROM User WHERE Id= :UserInfo.getUserId()];
            pagereference pg = new pagereference ( '/'+oCurrentUserInfo.AccountId) ; 
            return pg;
        }
        catch(Exception oEx) {
            ErrorLogUtility.logGeneralError(oEx, 'ICPPortalPageExtension','icpRecordDetail', 'NULL');
            return null;            
        }        
    }
         
}