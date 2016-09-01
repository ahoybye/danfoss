trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, after insert, after update, after delete) {
	CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('OpportunityLineItemTrigger');
	if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
		//BEFORE events
		if(Trigger.isBefore){
			map<Id,Id> mpOpportunityAccount = new map<Id,Id>();
			map<Id,Id> mpPriceBookEntryProduct = new map<Id,Id>();
			for(OpportunityLineItem item : Trigger.New) {
				if(Trigger.isInsert){
					item.Customer_Requests__c = false;		//to clear the checkbox on cloned OLIs
				}
				mpOpportunityAccount.put(item.OpportunityId, NULL);
				mpPriceBookEntryProduct.put(item.pricebookEntryId, NULL);
			}  	  
		  
			for(Opportunity oppty : [SELECT Id,AccountId FROM Opportunity WHERE Id IN : mpOpportunityAccount.keySet()]) {
				mpOpportunityAccount.put(oppty.Id, oppty.AccountId);
			}
		  
			for(PriceBookEntry pbe : [SELECT Id,Product2Id FROM PriceBookEntry WHERE Id IN : mpPriceBookEntryProduct.keySet()]) {
				mpPriceBookEntryProduct.put(pbe.Id, pbe.Product2Id);
			}
		  
			map<String,Customer_Part_Number__c> mpCustomerPartNumber = new map<String,Customer_Part_Number__c>(); 
			for(Customer_Part_Number__c part : [SELECT Material_Number__c,Id,Account__c,Product__c FROM Customer_Part_Number__c WHERE Account__c IN :mpOpportunityAccount.values() AND Product__c IN :mpPriceBookEntryProduct.values()]) {
			mpCustomerPartNumber.put(part.Account__c + '-' + part.Product__c, part);
			}

			for(OpportunityLineItem item : Trigger.New) {
				String key = mpOpportunityAccount.get(item.OpportunityId) + '-' + mpPriceBookEntryProduct.get(item.pricebookEntryId);
				if(mpCustomerPartNumber.containsKey(key)) {
					item.Customer_Material_Number__c = mpCustomerPartNumber.get(key).Material_Number__c;
				}
			}
		}
		//AFTER events
		if(Trigger.isAfter){
			List<Opportunity> lstOpportunitys;
		    set <Id>setOpportunityIds = new set<Id>();
		    if (Trigger.IsDelete){
		        lstOpportunitys = [select Id From Opportunity where Id IN :Trigger.oldMap.keySet()];
		    }
		    else if(Trigger.isUpdate){
		        for (OpportunityLineItem o :Trigger.new) {
		            if (o.Customer_Material_Number__c != Trigger.oldMap.get(o.Id).Customer_Material_Number__c)
		                setOpportunityIds.add(o.OpportunityId);
		        }
		        lstOpportunitys = [select Id From Opportunity where Id IN :setOpportunityIds];
		    }
		    else{ // is INSERT
		        lstOpportunitys = [select Id From Opportunity where Id IN :Trigger.newMap.keySet()];
		    }
		    if(!lstOpportunitys.isEmpty())
		        update lstOpportunitys;
		}
	}
}