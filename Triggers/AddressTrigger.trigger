/******************************************************************************************************
Class Name         : AddressTrigger
Deascription       : This is single trigger for Address which will cover all the trigger events.
                     All the functionality on Address should be called from this trigger. Methods 
                     to cover all address functionality will be defined in AddressHandler class named
                     AddressHandler.
Created By         : Danish Ahmed
Created On         : 06-Aug-2015 
******************************************************************************************************/
trigger AddressTrigger on Address__c (after insert, after update) {
    AddressHandler oAddressHandler = new AddressHandler();
    if( Trigger.isInsert && Trigger.isAfter ) {
        oAddressHandler.onAfterInsert(Trigger.new, Trigger.oldMap);
    }
    if( Trigger.isUpdate && Trigger.isAfter ) {
        oAddressHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
        

}