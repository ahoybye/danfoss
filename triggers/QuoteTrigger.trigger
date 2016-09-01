trigger QuoteTrigger on Quote (before insert, before update) {
    CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('QuoteTrigger');    
	public static ID ceQuoteRecordTypeId = [select Id from RecordType where SobjectType = 'Quote' and DeveloperName = 'CE_Quote'].Id;
	List<Quote> lstQuotesPSonly = new List<Quote>();
	Map<Id, Quote> mapQuotesPSonly = new Map<Id, Quote>();
    if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
		for(Quote q : Trigger.New) {
			if (q.RecordTypeId != ceQuoteRecordTypeId) {
		        lstQuotesPSonly.add(q);
		    }
		}
        if(Trigger.isBefore && Trigger.isUpdate && lstQuotesPSonly.size()>0)
        {
			for(Quote q : Trigger.old) {
				if (q.RecordTypeId != ceQuoteRecordTypeId) {
			        mapQuotesPSonly.put(q.Id, q);
			    }
			}
            QuoteTriggerHandler.PrepopulateFields(lstQuotesPSonly);
            QuoteTriggerHandler.ChangeStage(lstQuotesPSonly, mapQuotesPSonly);
            QuoteTriggerHandler.CheckForDelegatedApprover(lstQuotesPSonly);
            QuoteTriggerHandler.CompilePartNumbersFromQLI(lstQuotesPSonly);
        }
        
        if(Trigger.isBefore && Trigger.isInsert && lstQuotesPSonly.size()>0)
        {
            QuoteTriggerHandler.PrepopulateFields(lstQuotesPSonly);
        }
    }
}