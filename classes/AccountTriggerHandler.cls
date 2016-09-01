public with sharing class  AccountTriggerHandler{
	public static User u = [select IsPortalEnabled, ContactId from User where Id = :UserInfo.getUserId()];
	static Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
	static Id CustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
	
	@future
	public static void PopulateAccountFields(Set<Id> setAcctIDs)	//AFTER INSERT
	{
		if (u.IsPortalEnabled)
		{
			List<Account> acctList = [Select Id, ParentId, Parent.OwnerId, Parent.Business_Org__c, Country__r.Name From Account Where Id IN :setAcctIDs];
			Contact c = [select AccountId, Account.OwnerId, Account.Business_Org__c from Contact where Id = :u.ContactId];
			
			for(Account act : acctList)
			{			
				act.Pardot_Country__c = act.Country__r.Name;
	       		act.business_org__c= c.Account.Business_Org__c;
	            act.ParentId = c.AccountId;
				act.ownerId = c.Account.OwnerId;
				//Create Account Team Member for Partner Portal User
				List<AccountTeamMember> members = new List<AccountTeamMember>();
				AccountTeamMember member = new AccountTeamMember();
				member.AccountId = act.Id;
				member.TeamMemberRole = 'Partner';
				member.UserId = u.id;
				members.add(member);
				
				if (!members.isEmpty()) {
					insert members;
				}
				List<AccountShare> shares = [select Id, OpportunityAccessLevel, RowCause, UserOrGroupId from AccountShare where AccountId = :act.Id and UserOrGroupId = :u.Id];
				// set Partner team members access as follows: ACCOUNT: Read (default), CONTACT: Read (preferrably Read/Write for Prospect Accounts - if only one option is available default to Read/Write), 							OPPORTUNITY Read/Write, CASE: Private (default)
				for (AccountShare share : shares)  {
				    share.OpportunityAccessLevel = 'Edit';
					share.ContactAccessLevel = 'Edit';
				}
				update shares; 
			}
		update acctList;
       	}		
	}

	public static void ContentDocumentSetupOnAccount(List<Account> lstAccts, Map<Id, Account> mapOldAccts, Boolean isInsert)	//AFTER INSERT and UPDATE
	{
		List<Account> accountToProceed = new List<account>();
    	set<id> accountIds = new set<id>();
		for (Account act :lstAccts)
		{
			accountIds.add(act.Id);
			boolean proceed = false;
	        if(act.RecordTypeId != acctRecordTypeId) //Not a Prospect
	        {
	            if(isInsert)
	                proceed = true;
	            else
	            {
					Account oldAcct = mapOldAccts.get(act.Id);
	                if(act.Channel__c != oldAcct.Channel__c || act.Business_Org__c != oldAcct.Business_Org__c)
	                    proceed = true;
	                if(act.Manager_Library__c != oldAcct.Manager_Library__c || act.User_Library__c != oldAcct.User_Library__c)
	                    proceed = true;
	                if(act.Country__c != oldAcct.Country__c
	                       || act.Customer_Segment__c != oldAcct.Customer_Segment__c
	                       || act.Price_Schedule__c != oldAcct.Price_Schedule__c
	                       || act.Channel_Attributes__c != oldAcct.Channel_Attributes__c)
	                    proceed = true;
	               
	            }
	        }
	        if(proceed)
	            accountToProceed.add(act);
		}
	    if(accountToProceed.size()>0)
	    {
	        if (Test.isRunningTest()&&Limits.getFutureCalls()>=Limits.getLimitFutureCalls()) {
				system.debug(LoggingLevel.Error, 'Future method limit reached. Skipping...');
			}
			else {
			        ContentUtils.ProcessforAccounts(accountIds); 
			}
		}  
	}
	
	public static void ChangeuserGroupOnLibraryChange(List<Account> lstAccts, Map<Id, Account> mapAccts, Map<Id, Account> mapOldAccts) 	//AFTER UPDATE
	{
	    Set<id> accountToOperate = new Set<id>();
	    Map<id,String> RemoveFrom = new Map<id,String>();
	    Map<id,String> AddTo = new Map<id,String>();
	    for(Account act:lstAccts)
	    {
	        account actOld = mapOldAccts.get(act.Id);
	        if(act.Manager_Library__c != actOld.Manager_Library__c || act.User_Library__c != actOld.User_Library__c)
	            accountToOperate.add(act.Id);
	    }
	    for(User usr:[Select id, Contact.department__c,ContactId, Contact.AccountId from User where Contact.AccountId in :accountToOperate])
	    {
	        Account act = mapAccts.get(usr.Contact.AccountId);
	        Account actOld = mapOldAccts.get(act.Id);
	        string uType = 'U';
	        User_Type_Department_Match__c utold=null;
	        if(usr.Contact.department__c!=null)
	        {
	            User_Type_Department_Match__c ut = User_Type_Department_Match__c.getValues(usr.Contact.department__c);
	            if(ut!=null && ut.Type__c=='Restricted') 
	                uType  = 'M';
	        }
	        if(act.Manager_Library__c != actOld.Manager_Library__c && uType=='M')
	        {
	            if(act.Manager_Library__c!=null)
	                addTo.put(usr.Id,act.Manager_Library__c);
	            if(actOld.Manager_Library__c!=null)
	                RemoveFrom.put(usr.Id,actOld.Manager_Library__c);
	        }
	        if(act.User_Library__c != actOld.User_Library__c)
	        {
	            if(act.User_Library__c!=null)
	                addTo.put(usr.Id,act.User_Library__c);
	            if(actOld.User_Library__c!=null)
	                RemoveFrom.put(usr.Id,actOld.User_Library__c);
	        }
	    }
	    if (accountToOperate.size() > 0)
		{
			if (Test.isRunningTest()&&Limits.getFutureCalls()>=Limits.getLimitFutureCalls()) {
				system.debug(LoggingLevel.Error, 'Future method limit reached. Skipping...');
			}
			else {
	    		ContentUtils.UpdateUserGroupWhenLibraryChange(accountToOperate, RemoveFrom,AddTo);
			}
		}
	}
		
	public static void UpdateNamesOnOtherRecords(List<Account> lstAccts, Map<Id, Account> mapOldAccts) 	//AFTER UPDATE
	{
		Set<Id> setAcctIds = new Set<Id>();
        for(Account act:lstAccts) {
        	if(act.RecordTypeId == CustomerRecordTypeId){
	        	Account actOld = mapOldAccts.get(act.Id);
	        	if(act.OwnerId != actOld.OwnerId || act.Sales_Manager__c != actOld.Sales_Manager__c)
	        		setAcctIds.add(act.Id);
        	}
        }
		List<Case> lstCases = new List<Case>([select Id, Sales_Manager__c from Case where AccountId IN :setAcctIds and isClosed = false]);
		List<Contract__c> lstContracts = new List<Contract__c>([select Id, Account_Manager__c, Sales_Manager_of_Account__c from Contract__c where Customer__c IN :setAcctIds]);
		List<Deviated_Lead_time_Request__c> lstDLRs = new List<Deviated_Lead_time_Request__c>([select Id, Account_Owner__c from Deviated_Lead_time_Request__c where Account__c IN :setAcctIds]);
		List<Quote> lstQuotes = new List<Quote>([select Id, Opportunity.Account.OwnerId, Opportunity.Account.Sales_Manager__c from Quote where Opportunity.AccountId IN :setAcctIds and Approval_Stage__c = 'Pending']);
		
		if(!lstCases.isEmpty())
			update lstCases;
		if(!lstContracts.isEmpty())
			update lstContracts;
		if(!lstDLRs.isEmpty())
			update lstDLRs;
		if(!lstQuotes.isEmpty())
			update lstQuotes;
	}
}