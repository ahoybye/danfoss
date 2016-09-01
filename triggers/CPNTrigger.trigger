trigger CPNTrigger on Customer_Part_Number__c (after insert, after update, after delete) {
	CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('CPNTrigger');
	if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
		if(!trigger.isDelete){  //don't want to try deleting a record that is being manually deleted and invoking this trigger
			list<Customer_Part_Number__c> lstCustomerPartNumber = new  list<Customer_Part_Number__c>(); 
			for(Customer_Part_Number__c cpn : Trigger.New) {
				if(cpn.isDeleted__c) {
					lstCustomerPartNumber.add(cpn);
				}
			}
			if(!lstCustomerPartNumber.isEmpty()) {
				delete [select id from Customer_Part_Number__c where Id IN :lstCustomerPartNumber];
			}
		}  
		
		map<String,Customer_Part_Number__c> mpCustomerPartNumber = new map<String,Customer_Part_Number__c>(); 
		Set<Id> stProducts = new Set<Id>();
		Set<Id> stAccounts = new Set<Id>();
		for(Customer_Part_Number__c part : trigger.isDelete ? Trigger.Old : Trigger.New) {
			if(isValidCustomerPartNumber(part)) {
				mpCustomerPartNumber.put(part.Account__c + '-' + part.product__c, part);
				stProducts.add(part.product__c);
				stAccounts.add(part.Account__c);  
			}  
		}
		if(mpCustomerPartNumber.isEmpty()) {
			return;
		}
	  
		list < OpportunityLineItem > lstOpptyLineItem = [SELECT Id,PriceBookEntry.Product2Id,Opportunity.AccountId FROM OpportunityLineItem WHERE PriceBookEntry.Product2Id IN :stProducts AND Opportunity.AccountId IN :stAccounts AND Opportunity.IsClosed = false];
		for(OpportunityLineItem item : lstOpptyLineItem) {
			String key = item.Opportunity.AccountId + '-' + item.PriceBookEntry.Product2Id;
			if(mpCustomerPartNumber.containsKey(key)) {
				if(Trigger.isDelete) {
					item.Customer_Material_Number__c = NULL;
					continue; 
				} 
				Customer_Part_Number__c part = mpCustomerPartNumber.get(key);
				item.Customer_Material_Number__c = part.Material_Number__c;
			}   
		}
	  
		if(!lstOpptyLineItem.isEmpty()) {
			update lstOpptyLineItem;
		}
	  
		list < QuoteLineItem > lstQuoteLineItem = [SELECT Id,PriceBookEntry.Product2Id,Quote.Opportunity.AccountId	FROM QuoteLineItem WHERE PriceBookEntry.Product2Id IN :stProducts AND Quote.Opportunity.AccountId IN :stAccounts AND Quote.Opportunity.isClosed = false];
		for(QuoteLineItem item : lstQuoteLineItem) {
			String key = item.Quote.Opportunity.AccountId + '-' + item.PriceBookEntry.Product2Id;
			if(mpCustomerPartNumber.containsKey(key)) {
				if(Trigger.isDelete) {
					item.Customer_Part_Number__c = NULL;
					continue; 
				} 
				Customer_Part_Number__c part = mpCustomerPartNumber.get(key);
				item.Customer_Part_Number__c = part.Material_Number__c;
			}   
		}
	  
		if(!lstQuoteLineItem.isEmpty()) {
			update lstQuoteLineItem;
		}
	  
		list < Machine_Model_Product__c > lstMachineLineItem = [SELECT Id,Machine_Model_Product__c,Machine_Model__r.Account__c FROM Machine_Model_Product__c WHERE Machine_Model_Product__c IN :stProducts AND Machine_Model__r.Account__c IN :stAccounts];
		for(Machine_Model_Product__c  item : lstMachineLineItem) {
			String key = item.Machine_Model__r.Account__c + '-' + item.Machine_Model_Product__c;
			if(mpCustomerPartNumber.containsKey(key)) {
				if(Trigger.isDelete) {
					item.Customer_Material_Number__c = NULL;
					continue; 
				} 
				Customer_Part_Number__c part = mpCustomerPartNumber.get(key);
				item.Customer_Material_Number__c = part.Material_Number__c;
			}   
		}
	  
		if(!lstMachineLineItem.isEmpty()) {
			update lstMachineLineItem;
		}
	}  
	private Boolean isValidCustomerPartNumber(Customer_Part_Number__c part) {
		if(part.Account__c == NULL || part.product__c == NULL) {
			return false;
		} 
		if(Trigger.isInsert) {
			return true;
		}
		if(Trigger.isDelete) {
			return true;
		}
		if(Trigger.oldMap.get(part.Id).Account__c != part.Account__c || Trigger.oldMap.get(part.Id).product__c != part.product__c || Trigger.oldMap.get(part.Id).Material_Number__c != part.Material_Number__c) {
			return true;
		}
		return false;
	}
}