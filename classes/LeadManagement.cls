/*******************************************************************
* Author        :  Shailendra Singh (Appirio Offshore)
* Name          :  LeadManagement
* Related Task  :  T-67976
* Description   :  contains halper methods for functionality around Lead.                 
*******************************************************************/
public without sharing class LeadManagement {
    static final String MARKETING_TEAM = 'Marketing Team';
    static final String PARTNER_MANAGER_QUEUE = 'Partner Manager Queue';
    static final String DISTRIBUTOR = 'Distributor';
    static final String PARTNER_MANAGER = 'Account Manager';
    static final String QUEUE = 'Queue';
    static final String GROUP_PREFIX = '00G';
    static final String READ_WRITE_ACCESS = 'Edit';
    /**
     * Populate Lead SLA notification fields in future call so Workflow rules are fired even
     * Lead records are updated because of Assignment Rules
     */
	@future
	public static void updateSLANotificationFields(Set<ID> leadIds){
	    Map<String,Set<ID>> queueNames = new Map<String,Set<ID>>();  
	    Set<ID> portalUsers = new Set<ID>();
	    Set<ID> leadOwners = new Set<ID>();
	    List<Lead> leadList = new List<Lead>();
	    List<Lead> leadToBeUpdated = new List<Lead>(); 
	    Map<ID,ID> portalAcountOwner = new Map<ID,ID>();	
	    for (Lead lead: [Select ID,ownerID,Assigned_To__c,Assigned_Date__c from Lead Where ID in :leadIds]) {
	    	 leadList.add(lead);
		     if (!String.ValueOf(lead.ownerID).startsWith(GROUP_PREFIX)) { // Owner is not queue
        		leadOwners.add(lead.ownerID);
        	 }	    	
	    }	
	    for (User user:[Select ID,Contact.Account.OwnerID from User where ID IN :leadOwners AND ContactID != null]) {
	    	portalUsers.add(user.id);
	    	portalAcountOwner.put(user.id, user.Contact.Account.OwnerID);
	    }
	    queueNames.put('MARKETING',new Set<ID>());
	    queueNames.put('PARTNER_MANAGER',new Set<ID>());
	    for (Group groupObj : [Select g.Type, g.Name, g.Id, g.Email From Group g Where g.Type =:QUEUE] ) {
	    	if (groupObj.Name.endsWith('Marketing')) { // Marketing Queue
	    		queueNames.get('MARKETING').add(groupObj.id);
	    	} else if(groupObj.Name.startsWith('*SD Lead')) { // Partner Manager Queue
	    		queueNames.get('PARTNER_MANAGER').add(groupObj.id);
	    	}
	    }
	    for (Lead lead :leadList) {
	    	if (String.ValueOf(lead.ownerID).startsWith(GROUP_PREFIX)) {// Owner is Queue
	    			if (queueNames.get('MARKETING').contains(lead.OwnerId)) {
	    				lead.Assigned_Date__c = System.today(); // Assigned Time to Markeing Queue
	    				lead.Assigned_To__c = MARKETING_TEAM;
	    				leadToBeUpdated.add(lead);
	    			} else if(queueNames.get('PARTNER_MANAGER').contains(lead.OwnerId)) {
	    				lead.Assigned_Date__c = System.today(); // Assigned Time to Partner Manager Queue
	    				lead.Assigned_To__c = PARTNER_MANAGER_QUEUE;
	    				leadToBeUpdated.add(lead);
	    			}
	    	} else {
	    		if (portalUsers.contains(lead.ownerID)) {
	    			// Assigned To Distributator
	    			lead.Assigned_Date__c = System.today();
	    			lead.Assigned_To__c = DISTRIBUTOR;
	    			//Set Partner account's owner as account manager when lead ownership is changed to portal user
	    			lead.Account_Manager__c = portalAcountOwner.get(lead.ownerID);
	    			// Update Distributor__c field with Portal User Owner
	    			lead.Distributor__c = lead.OwnerId;
	    			leadToBeUpdated.add(lead);
	    		}
	    		if (lead.Assigned_To__c == PARTNER_MANAGER) {
	    			lead.Assigned_Date__c = System.today();
	    			leadToBeUpdated.add(lead);
	    		}
	    }
	 }
	 if (!leadToBeUpdated.isEmpty()) {
	 	update leadToBeUpdated;
	 }
   }
   
   /**  ~~~~~ COMMENTED OUT 28AUG15 PER MOLLY: LEADS SHOULD NEVER BE SHARED WITH THE CREATOR; NOT RELEVANT~~~~~
	
    * Share Leads with Creater of Lead
    * @param List of Lead
    * @param Set of Id
    */
   /*public static void shareLeadsWithCreater(List<Lead> leadList, Set<ID> leadIds){
		Set<ID> createrIds = new Set<ID>();
		Map<ID, Set<ID>> alreadySharedLead = new Map<ID, Set<ID>>();
		for (Lead lead : leadList) {
			createrIds.add(lead.CreatedByID);
		}  
		// Create Lead Manual Sharing Rules if not existing
		for (LeadShare sharingRule : [Select ID,LeadId,UserOrGroupId from LeadShare Where LeadAccessLevel =: READ_WRITE_ACCESS 
									  AND UserOrGroupId =: createrIds AND LeadId =: leadIds]) {
			if (alreadySharedLead.get(sharingRule.LeadId) == null) {
			   alreadySharedLead.put(sharingRule.LeadId , new Set<ID>());
			}
			alreadySharedLead.get(sharingRule.LeadId).add(sharingRule.UserOrGroupId);
		}
		List<LeadShare> sharingRules = new List<LeadShare>();
		for (Lead lead : leadList) { // Lead does not have manual sharing with creater
			if (alreadySharedLead.get(lead.ID) == null || !alreadySharedLead.get(lead.ID).contains(lead.CreatedById)) {
				LeadShare leadShare = new LeadShare(LeadAccessLevel = READ_WRITE_ACCESS, LeadId = lead.Id,
													UserOrGroupId = lead.CreatedById 
												    );	
				sharingRules.add(leadShare);												  
			}
		}
		if (!sharingRules.isEmpty()) { 	
			insert sharingRules;
		}
   }*/
}