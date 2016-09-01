trigger UserTrigger on User (after Insert, after Update) 
{
	CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('UserTrigger');
	if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
	    if(trigger.isAfter && trigger.isInsert){
	        Map<id,User> mapContactId = new Map<id,User>();
	        for(User u:trigger.New)
	        {
	            if(u.ContactId!=null)
	                mapContactId.put(u.ContactId,u);
	        }
	        ContentUtils.updateUsersGroupSettings(mapContactId);
	    }
	    
	    if(trigger.isAfter && trigger.isUpdate){
	        set<Id> setUserIds = new Set<Id>();
	        for(User u:trigger.New)
	        {
	            if(!u.IsActive)
	                setUserIds.add(u.Id);
	        }
	        UserTriggerHandler.removeUserFromGroups(setUserIds);
	        UserTriggerHandler.addPartnerUserToGroup(trigger.new);
	        UserTriggerHandler.SendEmailNotificationWhenPortalUserInactive(trigger.new, trigger.oldMap);
	    }
    }
}