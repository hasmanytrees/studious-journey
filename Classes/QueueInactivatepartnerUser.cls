/******************************************************************************************************
Class Name         : QueueInactivatepartnerUser
Description        : This is a Queable Interface that updates the User when the related contact is updated.
Created By         : Danish Ahmed
Created On         : 26-Nov-2015 
******************************************************************************************************/

public class QueueInactivatepartnerUser implements Queueable {

    set<Id> setContactIds;
    
    /**
     * Method name  : QueueInactivatepartnerUser
     * Description  : This method inactivates the User associated with the Contact 
     * 				  whose Connect Status is changed from Active to Inactive.
     * Return Type  : NA
     * Parameter    : set<Id> 
     **/  
    public QueueInactivatepartnerUser(set<Id> setContactIds){
        this.setContactIds = setContactIds;   
    }
    
     public void execute(QueueableContext context) {
        list<User> lstUsersToUpdate = new list<User>();
        lstUsersToUpdate = [SELECT Id, ContactId, IsActive from User where ContactId in: setContactIds];
        System.debug('lstUsersToUpdate: '+lstUsersToUpdate);
        for(User oUser: lstUsersToUpdate) {
            oUser.IsActive = false;
        }
        System.debug('lstUsersToUpdate: '+lstUsersToUpdate);
        
        if(!lstUsersToUpdate.isEmpty()) {
            List<Database.SaveResult> lstUpdateResults =
                Database.update(lstUsersToUpdate, false);
            Map<Id, List<String>> mapIdToErrorMsg = ErrorLogUtility.logDMLError(
                lstUpdateResults, lstUsersToUpdate, 'User',
                'ContactHandler', 'inactivateUsers', 'SFDC CI', false);
        }
     }
}