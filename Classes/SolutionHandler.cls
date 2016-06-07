/******************************************************************************************************
Class Name         : SolutionHandler
Description        : This is single Class for Solution which will cover all the Solution Functionality.
                     All Methods to cover oSolution functionality will be defined in this class. These methods
                     will be called from SolutionTrigger based on required trigger events.
Created By         : Sfurti Pandey 
Created On         : 01-Oct-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public class SolutionHandler {
    /**
     * Method name  : onBeforedelete
     * Description  : This method will be called before any Solution record is deleted.
     * Return Type  : void
     * Parameter    : List<Solution>
     **/
    public void onBeforedelete(List <Solution> lstOldRecords) {
        validateProfileForDelete(lstOldRecords);
    }
    /**
    * Method name  : validateProfileForDelete
    * Description  : This method validated that profiles other that businessadmin/system admin should not be allowed to delete solutions .
    * Return Type  : void
    * Parameter    : List<Solution>
    
    **/
    private void validateProfileForDelete(List <Solution>
        lstOldRecords) {
         Profile p = [Select id from profile where Name=:Label.Business_Admin limit 1];
         For(Solution oSol :lstOldRecords){
             If(UserInfo.GetProfileid()!=(Utility.getSystemAdminProfileId())&&(UserInfo.GetProfileid()!=p.id))
             {
                 oSol.AddError(Label.You_Do_Not_Have_Access_to_Delete_Solution);
             }
         }
    }
}