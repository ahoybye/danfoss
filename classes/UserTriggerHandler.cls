public with sharing class UserTriggerHandler{
	
	public static void addPartnerUserToGroup(List<User> lstUsers){	//AFTER UPDATE
		List<Group> lstGroups = [select Id,DeveloperName from group where DeveloperName like 'PS_Partner_Users%'];
		Map<string,Id> mapGroupNameToId = new Map<string,Id>();
		List<GroupMember> toInsert = new List<GroupMember>();
		GroupMember gm;
		for(Group g: lstGroups)
            mapGroupNameToId.put(g.DeveloperName,g.Id);
		Map<Id, Profile> pNames = new Map<Id, Profile>([select Id, Name from Profile where Name like 'PartnerLink%']);
		for(User u:lstUsers){
				if(u.Region__c != null && u.IsActive && pNames.containsKey(u.ProfileId)){
					if(u.Region__c == 'PS: Americas'){
						gm = new groupMember(GroupId = mapGroupNameToId.get('PS_Partner_Users_AMER'));
					}
					else if(u.Region__c == 'PS: APAC'){
						gm = new groupMember(GroupId = mapGroupNameToId.get('PS_Partner_Users_APAC'));
					}
					else if(u.Region__c == 'PS: China'){
						gm = new groupMember(GroupId = mapGroupNameToId.get('PS_Partner_Users_CHINA'));
					}
					else if(u.Region__c == 'PS: Europe'){
						gm = new groupMember(GroupId = mapGroupNameToId.get('PS_Partner_Users_EU'));
					}
					gm.UserorGroupId = u.Id;
					toInsert.add(gm);
				}
		}		
		if(toInsert.size()>0)
            insert toInsert;		
	}
	
	public static void removeUserFromGroups(Set<Id> setUserIds){	//AFTER UPDATE
		List<GroupMember> lstGroupMembers = new List<GroupMember>([Select id, UserOrGroupId from GroupMember where UserOrGroupId IN :setUserIds and Group.Name like '%Contract%']);
		delete lstGroupMembers;
	}
	
	public static void SendEmailNotificationWhenPortalUserInactive(List<User> lstUsers, Map<Id, User> mapOldUsers){	//AFTER UPDATE
		Map<Id,User> userMap = new Map<Id,User>();
		for(User user:lstUsers) 
	        if(user.IsPortalEnabled == true && user.IsActive == false && user.IsActive != mapOldUsers.get(user.Id).IsActive) 
	            userMap.put(user.Id,user);        
                
	    if(!userMap.isEmpty()) {	        
	        List<Messaging.SingleEmailMessage> mailToBeSend=new List<Messaging.SingleEmailMessage>();	        
	        String orgURL = URL.getSalesforceBaseUrl().toExternalForm();
	        String PortalAdminEmail = [Select p.Name, p.Email__c From PartnerAdminInfo__c p].Email__c;
	        for(User user:[Select Username, contactId, Contact.Account.Name, Contact.Account.Owner.Email From User u where Id in:userMap.KeySet()]) {
	            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	            List<String> toAddresses = new List<String>();
	            toAddresses.add(user.Contact.Account.Owner.Email);
	            if(PortalAdminEmail != null) {
	                toAddresses.add(PortalAdminEmail);
	            }
	            mail.setToAddresses(toAddresses);
	            mail.setSubject('Portal user deactivated');
	            mail.setHtmlBody('Dear Account Owner,<br/><br/>The User ' +user.Username+ ' has been deactivated for this ' + user.Contact.Account.Name+ '. Here is the link to the contact record.<br/>'+ orgURL + '/' + user.ContactId);
	            mailToBeSend.add(mail);     
	        }
	        
	        if(mailToBeSend.size() > 0) 
	            Messaging.sendEmail(mailToBeSend);        
	    }   
	}
}