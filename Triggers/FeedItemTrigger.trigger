/******************************************************************************************************
Class Name         : FeedItemTrigger
Deascription       : This is single trigger for Feed Item which will cover all the trigger events.
                     All the functionality on Feed Item should be called from this trigger. Methods 
                     to cover all account functionality will be defined in Handler class named
                     FeedItemHandler.
Created By         : Himanshu Raichandani
Created On         : 22-Jan-2015 
******************************************************************************************************/

trigger FeedItemTrigger on FeedItem(after Insert, after update) {

	List<Id> feedContentLst = new List<Id>();

	for(FeedItem feedItem: Trigger.new) {
		String parentIdString = String.valueOf(feedItem.parentId);
		if(parentIdString.startsWith(Content__c.sObjectType.getDescribe()
				.getKeyPrefix()) && feedItem.Type == Constants.FEED_ITEM_TYPE) {
			feedContentLst.add(feedItem.parentId);
		}
	}

	if(Trigger.isAfter) {
		if(!feedContentLst.isEmpty()) {
			FeedItemHandler.webServiceCallMethod(feedContentLst);
		}
	}

}