public with sharing class QuoteTriggerHandler{
    
	public static Map<Id, User> mapUsers = new Map<Id, User>();
	public static set<Id> setUserIds = new set<Id>();
				
	public static void PrepopulateFields(List<Quote> lstQuotes)  //BEFORE INSERT and UPDATE
	{
		User u;
	    Account parent8M;
		Account parent;
		Opportunity oppty = new Opportunity();
	    string custHierarchy;
	    string custName;
		String key;
		Map<String, Sales_Org__c> mapSO = new Map<String, Sales_Org__c>();
		Set<String> setSAPAcctIDs = new set<String>();
		Set<String> setOpptySOs = new set<String>();
		map<Id, Id> mapQuoteandOpptyIDs = new map<Id, Id>();
		map<Id, Opportunity> mapOpptys = new map<Id, Opportunity>();
		map<Id, Account> mapAccounts = new map<Id, Account>();
		set<Id> setAccountIds = new set<Id>();
		for(Quote q :lstQuotes)
		{
			mapQuoteandOpptyIDs.put(q.Id, q.OpportunityId);
		}
		for(Opportunity o :[select AccountId, Account.ParentId, Account.OwnerId, Account.Sales_Manager__c, Account.Name, Account.SAP_Account_ID__c, Account.Account_Group__c, 
			Sales_Org__r.Name, Sales_Org__r.SAP_Account_Sales_Org__c From Opportunity where Id IN :mapQuoteandOpptyIDs.values()])
		{
			setUserIds.add(o.Account.OwnerId);
			setUserIds.add(o.Account.Sales_Manager__c);
			setSAPAcctIDs.add(o.Account.SAP_Account_ID__c);
			setOpptySOs.add(o.Sales_Org__r.Name);
			mapOpptys.put(o.Id, o);
			setAccountIds.add(o.AccountId);		//account
			setAccountIds.add(o.Account.ParentId);	//account.parent
		}	
				System.debug('setAccountIds 1: ' + setAccountIds);
		for(Account act :[select Id, Name, SAP_Account_ID__c, ParentId, Parent.Id, Account_Group__c from Account where Id = :setAccountIds]){
			setAccountIds.add(act.ParentId);	//account.parent.parent (will not re-add duplicates of account.parent
			//setAccountIds.add(act.Parent.Id);	//account.parent.parent.parent (will not re-add duplicates of account.parent or account.parent.parent
			/*if(!mapAccounts.containsKey(act.Id))
				mapAccounts.put(act.Id, act);*/
		}
				System.debug('setAccountIds 2: ' + setAccountIds);
		for(Account act :[select Id, Name, SAP_Account_ID__c, ParentId, Account_Group__c from Account where Id = :setAccountIds]){
			setAccountIds.add(act.ParentId);	//account.parent.parent.parent (will not re-add duplicates of account.parent or account.parent.parent
			
			if(!mapAccounts.containsKey(act.Id))
				mapAccounts.put(act.Id, act);
		}
				System.debug('setAccountIds 3: ' + setAccountIds);
		for(Account act :[select Id, Name, SAP_Account_ID__c, ParentId, Account_Group__c from Account where Id = :setAccountIds]){
			//setAccountIds.add(act.ParentId);
			if(!mapAccounts.containsKey(act.Id))
				mapAccounts.put(act.Id, act);
		}
			System.debug('mapAccounts: ' + mapAccounts);
		
		mapUsers = new Map<Id, User>([select Id, DelegatedApproverId From User where Id IN :setUserIds]);
		for (Quote q :lstQuotes) 
		{        
			oppty = mapOpptys.get(mapQuoteandOpptyIDs.get(q.Id));
			if (oppty.Account.ParentId != null)
			{
				parent8M = mapAccounts.get(oppty.Account.ParentId);
				//parent8M = [select Id, Name, SAP_Account_ID__c, ParentId, Account_Group__c from Account where Id = :oppty.Account.ParentId];
				parent = parent8M;
				System.debug('parent: ' + parent);
			}
			//get customer hierarchy
			while (parent != null) 
			{
				if (parent.SAP_Account_ID__c != null && parent.SAP_Account_ID__c.left(1)== '8') 
				{
					custHierarchy = parent.SAP_Account_ID__c;
					custName = parent.Name;
					break ;
				}
				else if (parent.ParentId != null)
				{
					parent = mapAccounts.get(parent.ParentId);
					System.debug('parent: ' + parent);
					//parent = [select Name, SAP_Account_ID__c, ParentId from Account where Id = :parent.ParentId];
				}
				else
					break;
            }
			q.Customer_Hierarchy__c = custHierarchy;
			q.Customer_Hierarchy_Name__c = custName;
			//end get customer hierarchy
			
			//get names from oppty/quote's account
			q.Account_Owner__c = oppty.Account.OwnerId;
			if (oppty.Account.Sales_Manager__c == null) 
			{
				if (mapUsers.get(oppty.Account.OwnerId).DelegatedApproverId != null)
					q.Sales_Manager_of_Account__c = mapUsers.get(oppty.Account.OwnerId).DelegatedApproverId;
				else 
					q.Sales_Manager_of_Account__c = oppty.Account.OwnerId;
			}
			else 
			{
				if (mapUsers.get(oppty.Account.Sales_Manager__c).DelegatedApproverId != null)
					q.Sales_Manager_of_Account__c = mapUsers.get(oppty.Account.Sales_Manager__c).DelegatedApproverId;
				else 
					q.Sales_Manager_of_Account__c = oppty.Account.Sales_Manager__c;
			}
			//end get names from oppty/quote's account
			
			//using account group, climb up to get terms from sales org
			if (oppty.Account.Account_Group__c != null && oppty.Account.Account_Group__c == '0001') 
			{
				key = oppty.Account.SAP_Account_ID__c + oppty.Sales_Org__r.Name;  
			}
			else 
			{
				while (parent8M != null)
				{
					if (parent8M.Account_Group__c != null && parent8M.Account_Group__c == '0001') 
					{
						key = parent8M.SAP_Account_ID__c + oppty.Sales_Org__r.Name;
						setSAPAcctIDs.add(parent8M.SAP_Account_ID__c);  
			            break;
					}
					else if (parent8M.ParentId != null)
					{
						parent8M = mapAccounts.get(parent.ParentId);
						System.debug('parent8M: ' + parent8M);
						//parent8M = [select Id, SAP_Account_ID__c, Account_Group__c, ParentId from Account where Id = :parent8M.ParentId];
	                }
					else
						break;
				}
			}						
		}
		if (key != '' && key != null)
		{
			for(Sales_Org__c s :[select Name, SAP_Account_Sales_Org__c, Payment_terms__c, Incoterms__c From Sales_Org__c where Name IN :setOpptySOs and SAP_Account_Id__c IN :setSAPAcctIDs and SAP_Account_Id__c != '' and SAP_Account_Sales_Org__c != ''])
				mapSO.put(s.SAP_Account_Sales_Org__c, s);
			for (Quote q :lstQuotes) 
			{
				q.Payment_Terms__c = mapSO.containsKey(key) ? mapSO.get(key).Payment_terms__c : '';
				q.IncoTerms__c = mapSO.containsKey(key) ? mapSO.get(key).Incoterms__c : '';				
			}
		}		
	}
	
    public static void ChangeStage(List<Quote> lstQuotes, Map<Id, Quote> mapQuotes)  //BEFORE UPDATE
	{
        String pricingemail;
        String qNum;
        string bURL;
        string region;
        ID qOwnerId;
        ID qId;
        Boolean sendpricingmail = false;		
		Id rtN = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('New Quote').getRecordTypeId();
        Id rtA = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Approved Quote').getRecordTypeId();
        Id rtAA = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Auto-Approved Quote').getRecordTypeId();        
        
		//if no QLIs are Auto-Approved then don't run checks for quote stage change - the quote stage should not change 
		//problem is caused by fact that Lines Approved field counts Auto-Approved and throws off the last else if and sets quote stage to Approved - discovered
		//this when a quote had all A-A line items
		List<QuoteLineItem> lstQLIs = [select QuoteId, Line_Item_Approval_Stage__c From QuoteLineItem where QuoteId IN :mapQuotes.keyset() and Line_Item_Approval_Stage__c = 'Auto-Approved'];
        map<Id, List<QuoteLineItem>> mapQLIs = new map<Id, List<QuoteLineItem>>();
        for (QuoteLineItem qli :lstQLIs) {
            if (!mapQLIs.containsKey(qli.QuoteId)) {
                mapQLIs.put(qli.QuoteId,new List<QuoteLineItem>());
            }
            mapQLIs.get(qli.QuoteId).add(qli);
        }   
        for (Quote q :lstQuotes) {
			if (q.Merge_Formula_BusOrg__c == 'Comatrol' || q.Merge_Formula_BusOrg__c == 'Turolla')// && record_Type_Quote != null && !Test.isRunningTest())  // if is 'Not Routed Quote' record type, don't run this method
				return;
        	string stage = '';
            pricingemail = q.Pricing_Team_Group_Email__c;
            qNum = q.Name;
            qId = q.Id;
            qOwnerId = q.Account_Owner__c;
            region = q.Merge_Formula_Region__c;
            List <QuoteLineItem> lstThisQuoteQLIs = mapQLIs.get(qId);
            if (lstThisQuoteQLIs != null && lstThisQuoteQLIs.size() == q.LineItemCount)
            {
                q.Approval_Stage__c = 'Auto-Approved';
                q.RecordTypeId = rtAA;
				q.Approval_Date__c = Date.today();
            }
            else if (q.LineItemCount == 0 || q.Lines_Undefined_Approver__c > 0)
            {
                q.Approval_Stage__c = 'Pending';            
                q.RecordTypeId = rtN;
				q.Approval_Date__c = null;
            }
           else if (q.LineItemCount == q.Lines_Declined_by_BA__c || ((q.Lines_Declined_by_BA__c) > 0 && q.LineItemCount == (q.Lines_Declined_by_BA__c + q.Lines_Cancelled__c)))
           {
                q.Approval_Stage__c = 'Declined';
                q.RecordTypeId = rtN;
           }
           else if (q.LineItemCount == q.Lines_Cancelled__c)
           {
                q.Approval_Stage__c = 'Cancelled';
                q.RecordTypeId = rtN;
           }
           else if (q.Lines_Approved__c > 0 && (q.Lines_Declined_by_BA__c) > 0 && q.LineItemCount == (q.Lines_Declined_by_BA__c + q.Lines_Cancelled__c + q.Lines_Approved__c))     
           {
                q.Approval_Stage__c = 'Partially Approved';
                stage = 'Partially Approved';
           }
           else if (q.Lines_Pending_Business_Area_Approval__c == 0 
                && q.Lines_Pending_Pricing_Approval__c == 0
                && q.Lines_Pending_Sales_Manager_Approval__c == 0
                && q.Lines_Undefined_Approver__c == 0
                && q.Lines_Countered_by_Business_Area__c == 0
                && q.Lines_Countered_by_Pricing__c == 0
                && q.Lines_Countered_by_Sales_Manager__c == 0
                && q.LineItemCount > 0)
            {
                q.Approval_Stage__c = 'Approved';
                stage = 'Approved';
            }
            Quote qOld = mapQuotes.get(q.Id);
            if (q.Approval_Date__c == null && ((stage == 'Approved' && qOld.Approval_Stage__c != 'Approved') || (stage == 'Partially Approved' && qOld.Approval_Stage__c != 'Partially Approved')))
			{
                q.Approval_Date__c = Date.today();
                q.RecordTypeId = rtA;
				sendpricingmail = true;
			}
        }
        if (sendpricingmail) 
        {
            ApprovalEmailTemplateMapping__c custEmailTemplate = ApprovalEmailTemplateMapping__c.getInstance('QuotePricingTeamAlert');
            List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();                                       
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage(); 
            bURL = URL.getSalesforceBaseUrl().toExternalForm();
            msg.setSubject(region + ' Region Pricing Entry/Review Needed on Quote ' + qNum);
            msg.setPlainTextBody('This quote is fully approved and pricing is ready to be updated and/or reviewed in SAP. \n\n' + bURL + '/' + qId + '\n\nPlease remember to record completion date using the "Pricing Updated in SAP" field.');
            msg.setToAddresses(new list<String> {pricingemail}); 
            lstEmails.add(msg);
            Messaging.sendEmail( lstEmails );   
        }
    }
	
	public static void CheckForDelegatedApprover(List<Quote> lstQuotes)  //BEFORE UPDATE
	{		
		/*for (Quote q :lstQuotes) {
			setUserIds.add(q.Sales_Manager_of_Account__c);
		}
		mapUsers = new Map<Id, User>([select Id, DelegatedApproverId From User where Id IN :setUserIds]);
		for (Quote q :lstQuotes) {
			if(q.Sales_Manager_of_Account__c != null)
				if (mapUsers.get(q.Sales_Manager_of_Account__c).DelegatedApproverId != null) 
		            q.Sales_Manager_of_Account__c = mapUsers.get(q.Sales_Manager_of_Account__c).DelegatedApproverId;
		} */    
	}
	
	public static void CompilePartNumbersFromQLI(List<Quote> lstQuotes)  //BEFORE UPDATE
	{
		List<QLI_History__c> lstQLIHistory = new List<QLI_History__c>();
		List <QuoteLineItem> lstQLIs = new List <QuoteLineItem>();
        Map<Id, List <string>> mapQLIs = new Map<Id, List <string>>();
        for (Quote quote :lstQuotes)
        {
            if(!mapQLIs.containsKey(quote.Id)){
                mapQLIs.put(quote.Id, new List<string>());
            }      
        }
		lstQLIHistory = [Select Field_Name__c, Old_Value__c, New_Value__c, Quote__c from QLI_History__c WHERE Field_Name__c = 'Customer Part Number' and Quote__c IN :mapQLIs.keySet()];
		for(QLI_History__c qlih :lstQLIHistory){
			mapQLIs.get(qlih.Quote__c).add(qlih.Old_Value__c);
			mapQLIs.get(qlih.Quote__c).add(qlih.New_Value__c);
		}
        lstQLIs = [select QuoteId, PricebookEntry.ProductCode, Customer_Part_Number__c From QuoteLineItem where QuoteId IN :mapQLIs.keySet()];
		if (!lstQLIs.isEmpty())
		{
	    	for (QuoteLineItem qli :lstQLIs)
			{
				mapQLIs.get(qli.QuoteId).add(qli.PricebookEntry.ProductCode);
				if(qli.Customer_Part_Number__c != '' && qli.Customer_Part_Number__c != null)
					mapQLIs.get(qli.QuoteId).add(qli.Customer_Part_Number__c);
			}
			
			if (!mapQLIs.values().isEmpty()){
				for(Quote quote :lstQuotes)
				{
					quote.QLInumbers__c = '';
					List<String> lstStrMaterials = mapQLIs.get(quote.Id);
					for (string s :lstStrMaterials){
						if(s != null){
							if (quote.QLInumbers__c == '' || quote.QLInumbers__c == null)
								quote.QLInumbers__c = s + ', ';
							else if(!quote.QLInumbers__c.contains(s))
								quote.QLInumbers__c += s + ', ';
						}
					}
				}	
			}
		}
		else
			for (Quote quote :lstQuotes)
				if(mapQLIs.get(quote.Id).isEmpty())
					quote.QLInumbers__c = '';
	}
}