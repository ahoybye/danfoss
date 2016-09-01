trigger CustomerRequestTrigger on PS_Customer_Request__c (before insert, after insert, before update, after update) {
	set<Id> setAcctIds = new set<Id>();
	Map<Id, Account> mapAccts = new Map<Id, Account>();
	List<AccountTeamMember> lstAcctsTeam;
	Map<Id, Product2> mapProducts = new Map<Id, Product2>();
	List<Product2> lstProducts = new List<Product2>(); 
	map<Id, List<AccountTeamMember>> mapAccountTeamMembers = new map<Id, List<AccountTeamMember>>();
	CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('CustomerRequestTrigger');
	if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
		System.debug('in trigger');
		for(PS_Customer_Request__c cr :Trigger.New){
            setAcctIds.add(cr.Account__c);
			if(!mapProducts.containsKey(cr.Product__c)){
				mapProducts.put(cr.Product__c, null);				
			}
			if(!mapProducts.containsKey(cr.Product_Second__c)){
				mapProducts.put(cr.Product_Second__c, null);				
			}
			if(!mapProducts.containsKey(cr.Product_System__c)){
				mapProducts.put(cr.Product_System__c, null);				
			}
        }
		for(Account acct :[select id, OwnerId, Name from Account where Id IN :setAcctIds]){
			mapAccts.put(acct.Id, acct);
		}
		lstProducts = [select ProductCode, Model_Code__c, Business_Unit__c, Product_Set__c from Product2 where Id IN :mapProducts.keySet()];
		for(Product2 prod :lstProducts){
			mapProducts.put(prod.Id, prod);
		}
		lstAcctsTeam = [select Id, AccountId, TeamMemberRole, UserId from AccountTeamMember where AccountId IN :setAcctIds];
        for(AccountTeamMember atm :lstAcctsTeam){
            if(!mapAccountTeamMembers.containsKey(atm.AccountId))
                mapAccountTeamMembers.put(atm.AccountId, new List<AccountTeamMember>());
            mapAccountTeamMembers.get(atm.AccountId).add(atm);
        }
		
		//TRIGGER CODE
		if(Trigger.isBefore && Trigger.isInsert)	//BEFORE INSERT
		{
			CustomerRequestTriggerHandler.populateFields(Trigger.New, setAcctIds, mapAccountTeamMembers, mapProducts, Trigger.isInsert);
		}
		
		if(Trigger.isAfter && Trigger.isInsert)	//AFTER INSERT
		{
			CustomerRequestTriggerHandler.FollowRequest(Trigger.New);
		}
		
		if(Trigger.isBefore && Trigger.isUpdate)	//BEFORE UPDATE
		{
			CustomerRequestTriggerHandler.populateFields(Trigger.New, setAcctIds, mapAccountTeamMembers, mapProducts, Trigger.isInsert);
			CustomerRequestTriggerHandler.AssignRequest(Trigger.New, Trigger.oldMap, setAcctIds, mapAccountTeamMembers);
		}
		
		if(Trigger.isAfter && Trigger.isUpdate)	//AFTER UPDATE
		{
			CustomerRequestTriggerHandler.OtherUpdates(Trigger.New, Trigger.oldMap, setAcctIds);
			CustomerRequestTriggerHandler.CreateFollowupTasks(Trigger.New, mapAccts, Trigger.oldMap);
			CustomerRequestTriggerHandler.FollowRequest(Trigger.New, Trigger.oldMap);
			CustomerRequestTriggerHandler.updateOpportunityLineItem(Trigger.New, Trigger.oldMap);
			CustomerRequestTriggerHandler.cancelOpenTasks(Trigger.New, Trigger.oldMap);
		}
	}
}