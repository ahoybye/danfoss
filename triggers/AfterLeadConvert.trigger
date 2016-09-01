/*---------------------------------------------------------------------
  Author        :   Appirio Offshore(Nikita Jain)
  Date          :   July 25, 2012
  Description   :   Trigger on Lead maps custom address fields of lead to
  									Shipping address field of account and mailing address of contact
  Related Task  :   Task T-65155    
//---------------------------------------------------------------------*/
 
trigger AfterLeadConvert on Lead (after update) {
	
	map<Id,Lead> mapAccountIdLead = new map<Id,Lead>();
	map<Id,Lead> mapContactIdLead = new map<Id,Lead>();
	set<Account> accountSet = new set<Account>();
	set<Contact> contactSet = new set<Contact>();
	
	list<Account> accountTobeUpdated = new list<Account>();
	list<Contact> contactTobeUpdated = new list<Contact>();
	Map<ID,ID> leadOpportunityMap = new Map<ID,ID>();
	Map<ID,ID> leadApprovalSubmitter = new Map<ID,ID>();
	List<AccountTeamMember> members = new List<AccountTeamMember>();
	for(Lead lead : trigger.new){
		if(trigger.oldMap.get(lead.Id).isConverted != true && lead.isConverted == true){			
			mapAccountIdLead.put(lead.ConvertedAccountId , lead);
			mapContactIdLead.put(lead.ConvertedContactId , lead);
			if(lead.ConvertedOpportunityId != null){
				leadOpportunityMap.put(lead.id,lead.ConvertedOpportunityId);
			}					
		}
	}
	
	map<Id,Lead> mapIdLead = new map<Id,Lead>([Select State_Province__r.name , country__r.name from Lead
	                                           where id in :mapContactIdLead.values()]);
	
	for(Account acc :[Select Id, Business_Org__c, Channel__c, ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, ShippingCity
	                  FROM Account where id in : mapAccountIdLead.keySet()]){
		accountSet.add(acc);
	}
	
	for(Contact cnt :[Select Id, MailingCountry, MailingPostalCode, MailingState, MailingCity, MailingStreet
	                 FROM Contact where id in : mapContactIdLead.keySet()]){
		contactSet.add(cnt);
	}
	
	
	for(Account acc : accountSet){
		if(mapAccountIdLead.ContainsKey(acc.Id)){
			if (acc.ShippingStreet == '' || acc.ShippingStreet == null)
				acc.ShippingStreet = mapAccountIdLead.get(acc.Id).Street__c;			
			if(mapIdLead.ContainsKey(mapAccountIdLead.get(acc.Id).Id) ){
				if (acc.ShippingState == '' || acc.ShippingState == null)
					acc.ShippingState = mapIdLead.get(mapAccountIdLead.get(acc.Id).Id).State_Province__r.name;
				if (acc.ShippingCountry == '' || acc.ShippingCountry == null)
					acc.ShippingCountry = mapIdLead.get(mapAccountIdLead.get(acc.Id).Id).country__r.name;
			}
			if (acc.ShippingPostalCode == '' || acc.ShippingPostalCode == null)
				acc.ShippingPostalCode = mapAccountIdLead.get(acc.Id).Zip_Code__c;
			if (acc.ShippingCity == '' || acc.ShippingCity == null)
				acc.ShippingCity = mapAccountIdLead.get(acc.Id).City__c;
			if (acc.Business_Org__c == '' || acc.Business_Org__c == null)
				acc.Business_Org__c = mapAccountIdLead.get(acc.Id).Business_Org__c;	
			if (acc.Channel__c == '' || acc.Channel__c == null)
				acc.Channel__c =  mapAccountIdLead.get(acc.Id).Channel__c;
			
			//use partner account's owner as the owner of the newly created account.
			if (mapAccountIdLead.get(acc.Id).Account_Manager__c != null) { 
				acc.OwnerId = mapAccountIdLead.get(acc.Id).Account_Manager__c;
			}
			accountTobeUpdated.add(acc);
			// Create Account Team Member for Partner Portal User
			if (mapAccountIdLead.get(acc.Id).Distributor__c != null) { 
				AccountTeamMember member = new AccountTeamMember();
				member.AccountId = acc.id;
				member.TeamMemberRole = 'Partner';
				member.UserId = mapAccountIdLead.get(acc.Id).Distributor__c;
				members.add(member);
			}
	    }	
		
	}
	if (!members.isEmpty()) {
		insert members;
	}
	// get all of the team members' sharing records and set access to read/write
	List<AccountShare> shares = [select Id, AccountAccessLevel,RowCause from AccountShare where AccountID IN :accountSet and RowCause = 'Team'];
	for (AccountShare share : shares) 
	  share.AccountAccessLevel = 'Edit';	
	if (!shares.isEmpty()) {
		update shares;
	}
	for(Contact cnt : contactSet){
		if(mapContactIdLead.ContainsKey(cnt.Id)){
			if (cnt.MailingStreet == '' || cnt.MailingStreet == null)
				cnt.MailingStreet = mapContactIdLead.get(cnt.Id).Street__c;
			if(mapIdLead.ContainsKey(mapContactIdLead.get(cnt.Id).Id) ){
				if (cnt.MailingState == '' || cnt.MailingState == null)
					cnt.MailingState = mapIdLead.get(mapContactIdLead.get(cnt.Id).Id).State_Province__r.name;		
				if (cnt.MailingCountry == '' || cnt.MailingCountry == null)
					cnt.MailingCountry = mapIdLead.get(mapContactIdLead.get(cnt.Id).Id).country__r.name;
			}
			if (cnt.MailingPostalCode == '' || cnt.MailingPostalCode == null)
					cnt.MailingPostalCode = mapContactIdLead.get(cnt.Id).Zip_Code__c;
			if (cnt.MailingCity == '' || cnt.MailingCity == null)
					cnt.MailingCity = mapContactIdLead.get(cnt.Id).City__c;
			contactTobeUpdated.add(cnt);
		}
	}
	
	
	if(accountTobeUpdated.size() > 0){
		update accountTobeUpdated;
	}
	
	if(contactTobeUpdated.size() > 0){
		update contactTobeUpdated;
	}
	// Assign Portal user as the Opp owner when Danfoss Manager approves and converts the lead
	List<Opportunity> oppList = new List<Opportunity>();
	for(ProcessInstance processInst : [Select p.TargetObjectId, p.Status, p.Id,CreatedByID From ProcessInstance p Where TargetObjectId IN :leadOpportunityMap.keySet() AND Status = 'Pending']){
		leadApprovalSubmitter.put(processInst.TargetObjectId,processInst.CreatedByID);
	}
	for(ID leadId :leadOpportunityMap.keySet()){
		if(leadApprovalSubmitter.get(leadId) != null){
			oppList.add(new Opportunity(Id = leadOpportunityMap.get(leadId),OwnerID = leadApprovalSubmitter.get(leadId)));
		}
	}
	if(!oppList.isEmpty()){
		update oppList;
	}
}