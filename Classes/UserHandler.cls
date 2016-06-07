/******************************************************************************************************
Class Name         : UserHandler
Deascription       : This is single Class for User which will cover all the User Functionality.
                     All Methods to cover User functionality will be defined in this class. These methods
                     will be called from UserTrigger based on required trigger events.
Created By         : Danish Ahmed 
Created On         : 27-Apr-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class UserHandler{

    /**
     * Method name  : onBeforeUpdate
     * Description  : This method will be called before any User record is udpated
     * Return Type  : void
     * Parameter    : List<User> lstNewRecords, Map<Id,User> mapOldRecords
     **/    
    public void onBeforeUpdate(List<User> lstNewRecords, Map<Id,
        User> mapOldRecords) {
        if(Boolean.ValueOf(System.Label.Trigger_PreventUserUpdate_UserHandler)){
            preventUserUpdate(lstNewRecords, mapOldRecords);
        }
        
    }
      /**
     * Method name  : onBeforeInsert
     * Description  : This method will be called before any ICP User record is Created
     * Return Type  : void
     * Parameter    : List<User> lstNewRecords
     **/    
    public void onBeforeInsert(List<User> lstNewRecords) {   
        updateUserFieldOffice(lstNewRecords);          
    }
       
    /**
     * Method name  : onAfterInsert
     * Description  : This method will be called after any User record is Inserted
     * Return Type  : void
     * Parameter    : List<User> lstNewRecords, Map<Id,User> mapOldRecords
     **/    
    public void onAfterInsert(List<User> lstNewRecords, Map<Id,
        User> mapOldRecords) {
        shareRecordsWithUser(lstNewRecords, mapOldRecords);
    }
    
    /**
     * Method name  : onAfterUpdate
     * Description  : This method will be called after any User record is Updated
     * Return Type  : void
     * Parameter    : List<User> lstNewRecords, Map<Id,User> mapOldRecords
     **/    
    public void onAfterUpdate(List<User> lstNewRecords, Map<Id,
        User> mapOldRecords) {
        shareRecordsWithUser(lstNewRecords, mapOldRecords);            
    }
    
     /**
     * Method name  : preventUserUpdate
     * Description  : This method will update Timezone and Locale of the user with 
                      the previous value if the record is updated by One Login user.                        
     * Return Type  : void
     * Parameter    : List<User> lstNewRecords, Map<Id,User> mapOldRecords
     **/ 
    private void preventUserUpdate(List<User> lstNewRecords, Map<Id,
        User> mapOldRecords){
        Id oneLoginUserId = Org_Level_Settings__c.getOrgDefaults().One_Login_User_Id__c;
        for(User oUser: lstNewRecords){
            if(userinfo.getUserId() == oneLoginUserId && oUser.Id != oneLoginUserId)
            {
                oUser.TimeZoneSidKey = mapOldRecords.get(oUser.Id).TimeZoneSidKey;
                oUser.LocaleSidKey = mapOldRecords.get(oUser.Id).LocaleSidKey;
                oUser.LanguageLocaleKey = mapOldRecords.get(oUser.Id).LanguageLocaleKey;
            }
            
        }
    }
    
    /**
     * Method name  : shareRecordsWithUser
     * Description  : This method will call batch class to share records with active 
                      community user and delete share records for inactive 
                      community users 
     * Return Type  : void
     * Parameter    : List<User> lstNewRecords, Map<Id,User> mapOldRecords
     **/    
    private void shareRecordsWithUser(List<User> lstNewRecords,  Map<Id,
        User> mapOldRecords) {
        Set<Id> setProfileId = new Set<Id>();
        List<User> lstUser = new List<User>();
        List<GroupMember> lstGroupMember = new List<GroupMember>();
        
        for(Profile oProfile: [Select Id from Profile Where Name =: Constants.ICP_FULL_ACCESS_PROFILE OR Name =: Constants.ICP_READ_ONLY_PROFILE OR Name =: Constants.ICP_PROGRAM_IMPLEMENTER_PROFILE]){
            setProfileId.add(oProfile.Id);
        }
        Set<Id> setUserId = new Set<Id>();
        Set<Id> setInactiveUserId = new Set<Id>();
        for(User oUser: lstNewRecords){
            if(setProfileId.contains(oUser.ProfileId)){    
                if(trigger.isInsert && oUser.isActive == true){
                    setUserId.add(oUser.Id);
                }else if(trigger.isUpdate && oUser.Is_Sharing_Completed__c == false && oUser.isActive == true){
                    setUserId.add(oUser.Id);
                }else if(trigger.isUpdate && oUser.Is_Sharing_Completed__c == true && oUser.isActive == false){
                    setInactiveUserId.add(oUser.Id);
                }
            }
        }
        if(!setUserId.isEmpty()){
            if(trigger.isInsert){
                lstUser = [Select Id,Account.Field_Office__c from User where Id IN: setUserId];
                List<Group> lstGroup = [Select id, Name from Group where Name Like : Constants.ALL_PARTNER_COMMUNITY_USERS];
                Map<String, String> mapGroupNameToId = new Map<String, String>();
                for(Group oGroup: lstGroup ){
                    String sFOName = oGroup.Name.substringBefore(Constants.ALL_PARTNER_COMMUNITY);
                    mapGroupNameToId.put(sFOName, oGroup.Id);
                }
                if(!mapGroupNameToId.isEmpty()){
                    for(User oUser: lstUser){
                        if(mapGroupNameToId.containsKey(oUser.Account.Field_Office__c)){
                            GroupMember oGM = new GroupMember();
                            oGM.GroupId = mapGroupNameToId.get(oUser.Account.Field_Office__c);
                            oGM.UserOrGroupId = oUser.Id;
                            lstGroupMember.add(oGM);        
                        }
                    }
                }
                if(!lstGroupMember.isEmpty()){
                    List<Database.SaveResult> lstInsertResults =
                        Database.Insert(lstGroupMember, false);
                    Map<Id,List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                        lstInsertResults, lstGroupMember,
                        'GroupMember',
                        'UserHandler', 'shareRecordsWithUser', 'SFDC CI', false
                    );
                }
                
            }
            ShareRecordsToUserBatch oBatch = new ShareRecordsToUserBatch(setUserId);
            database.executeBatch(oBatch,1);
            
        }
        if(!setInactiveUserId.isEmpty()){
            BatchDeleteShareRecordsToUserClass oBatch = new BatchDeleteShareRecordsToUserClass(setInactiveUserId);
            database.executeBatch(oBatch,1);
        }       
        
    } 
     /**
     * Method name  : updateUserFieldOffice
     * Description  : This method will default Field Office of ICP User  
                      upon creation of the user                       
     * Return Type  : void
     * Parameter    : List<User> lstNewRecords, Map<Id,User> mapOldRecords
     **/  
    private void updateUserFieldOffice(List<User> lstNewRecords)
    {       
     List<User> lstUsers =  New List<User>();
     Set<Id> setProfileId = new Set<Id>(); 
     Set<Id> setContactId = new Set<Id>();
     for(Profile oProfile: [Select Id from Profile Where Name =: Constants.ICP_FULL_ACCESS_PROFILE OR Name =: Constants.ICP_READ_ONLY_PROFILE OR Name =: Constants.ICP_PROGRAM_IMPLEMENTER_PROFILE]){
            setProfileId.add(oProfile.Id);
        }
       if(!setProfileId.isempty()){
       for(User oUser : lstNewRecords){
       if(setProfileId.contains(oUser.profileId)){
       setContactId.add(oUser.contactid);   
          }       
       }
     }
    if(!setContactId.isempty()){
        
    Map<Id , Contact> mapContactFo =  New Map<Id,Contact>([select Id , Account.Field_Office__c from Contact
                   where id in :setContactId ]);   
        for(User oUser :lstNewRecords )
            {
             if (mapContactFo.containskey(oUser.Contactid)&&
                (Null <> mapContactFo.get(oUser.Contactid).Account.Field_Office__c))
             {
                 oUser.Field_Office__c = mapContactFo.get(oUser.Contactid).Account.Field_Office__c;
                 oUser.Is_Icp_User__c = True;
             }
    
            }   
        }      
    }   
}