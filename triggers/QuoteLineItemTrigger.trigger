trigger QuoteLineItemTrigger on QuoteLineItem(before insert, after insert, before update, after update, before delete, after delete ) {
    CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('QuoteLineItemTrigger');
    public static ID ceQuoteRecordTypeId = [select Id from RecordType where SobjectType = 'Quote' and DeveloperName = 'CE_Quote'].Id;
    List<QuoteLineItem> lstQLIsPSonlyNew = new List<QuoteLineItem>();
    List<QuoteLineItem> lstQLIsPSonlyOld = new List<QuoteLineItem>();
    Map<Id, QuoteLineItem> mapQLIsPSonlyNew = new Map<Id, QuoteLineItem>();
    Map<Id, QuoteLineItem> mapQLIsPSonlyOld = new Map<Id, QuoteLineItem>();
    Map<Id, Id> mapQLIQuoteIds = new Map<Id, Id>();
    Map<Id, Quote> mapQuotes;
    if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
        for(QuoteLineItem qli : Trigger.isDelete ? Trigger.old : Trigger.new){
            if(!mapQLIQuoteIds.containsKey(qli.Id)){
                mapQLIQuoteIds.put(qli.Id, qli.QuoteId);
            }
        }
        mapQuotes = new Map<Id, Quote>([select Id, Approval_Stage__c, RecordTypeId, Opportunity.AccountId, Pricing_Team_Group_Email__c, Account_Owner__r.Email from Quote where Id IN :mapQLIQuoteIds.values()]);
        if(!Trigger.isDelete){
            for(QuoteLineItem qli : Trigger.new) {
                if (mapQuotes.get(qli.QuoteId).RecordTypeId != ceQuoteRecordTypeId) {
                    lstQLIsPSonlyNew.add(qli);
                    mapQLIsPSonlyNew.put(qli.Id, qli);
                }
            }
        }
        if(!Trigger.isInsert){          
            for(QuoteLineItem qli : Trigger.old) {
                if (mapQuotes.get(qli.QuoteId).RecordTypeId != ceQuoteRecordTypeId) {
                    lstQLIsPSonlyOld.add(qli);
                    mapQLIsPSonlyOld.put(qli.Id, qli);
                }
            }
        }        
		
		//***BEFORE INSERT***
		if (Trigger.isBefore && Trigger.isInsert && lstQLIsPSonlyNew.size()>0) {	
            QuoteLineItemManagement.populateQuoteItemData(lstQLIsPSonlyNew, mapQuotes);
            QuoteLineItemManagement.setInitialApprovalStage(lstQLIsPSonlyNew, true, null); //for normally selected new line items
        }
		
		//***AFTER INSERT***
        if (Trigger.isAfter && Trigger.isInsert && lstQLIsPSonlyNew.size()>0) {
            QuoteLineItemManagement.GetSAPPriceAfterClonedInsert(lstQLIsPSonlyNew);//for cloned line items
        }	
        
		//***BEFORE UPDATE***
		if (Trigger.isBefore && Trigger.isUpdate) {		
            QuoteLineItemManagement.setInitialApprovalStage(lstQLIsPSonlyNew, false, mapQLIsPSonlyOld); //for cloned line items
        }
		
		//***AFTER UPDATE***
        if (Trigger.isAfter && Trigger.isUpdate && lstQLIsPSonlyNew.size()>0) {		
            if (QuoteLineItemManagement.hasTriggerExecuted)return ; //not sure if this is still necessary? 30 JUN 14 EF
            QuoteLineItemManagement.hasTriggerExecuted = true;
            QuoteLineItemManagement.sendEmailToBusinessMail(lstQLIsPSonlyNew, mapQLIsPSonlyOld);
        }
		
		//***AFTER INSERT, UPDATE, DELETE***
        if (Trigger.isAfter && (lstQLIsPSonlyNew.size()>0 || lstQLIsPSonlyOld.size()>0))  {	
            QuoteLineItemManagement.populateQuoteItemData(Trigger.isDelete ? lstQLIsPSonlyOld :lstQLIsPSonlyNew, mapQLIsPSonlyNew, mapQLIsPSonlyOld, Trigger.isInsert, Trigger.isDelete);
            QuoteLineItemManagement.updateQuoteWithPartNumbers(lstQLIsPSonlyNew, lstQLIsPSonlyOld, mapQLIsPSonlyOld, Trigger.isDelete, Trigger.isUpdate);
        }
        
		//***BEFORE DELETE***
        if (Trigger.isBefore && Trigger.isDelete && lstQLIsPSonlyOld.size()>0)  {	
            QuoteLineItemManagement.preventApprovedDeletion(lstQLIsPSonlyOld, mapQuotes);
        }
    }
}