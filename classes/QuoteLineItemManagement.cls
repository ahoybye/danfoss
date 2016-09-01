/*
*
*  QuoteLineItemManagement 
*  To send mails and populate fields of QLI
*
*/

public with sharing class QuoteLineItemManagement {
	public static Boolean isHistoryCreated = false;
	public static boolean hasTriggerExecuted = false;
	static Id SysAdminId = '00eC0000001f4zQIAQ';
	static Id PSAdminId = [select Id from Profile where Name = 'CRM_System Administrator PS'].Id;
	
	//***BEFORE INSERT and BEFORE UPDATE***
	public static void setInitialApprovalStage(list <QuoteLineItem >lstQuoteItem, Boolean isInsert, map <Id, QuoteLineItem >mpQuoteLineItem) {
		QuoteLineItem oldQuoteItem = new QuoteLineItem();
		for (QuoteLineItem qli :lstQuoteItem) {
			if (mpQuoteLineItem != null)
				oldQuoteItem = mpQuoteLineItem.get(qli.Id);	
			if(qli.ClonedFlag__c=='true') {
				if(isInsert) {
					qli.Line_Item_Approval_Stage__c = 'Select Approval Routing';
					qli.Submitted_for_Approval_Time__c = null;
					qli.Approved_Time__c = null;
					qli.Approver_Name__c = null;
				}				
			}			
			else {
				if(isInsert || (!isInsert && qli.Line_Item_Approval_Stage__c == 'Select Approval Routing' && (qli.ClonedFlag__c == 'true2' || qli.ClonedFlag__c == null)))
				{
					if (!Test.isRunningTest() && (qli.SAP_Price__c == 0 || qli.UnitPrice < qli.SAP_Price__c || qli.SAP_Price__c == null || qli.Currency_Match__c == 'false')) {
						qli.Line_Item_Approval_Stage__c = 'Select Approval Routing';
					}
                    else if (Test.isRunningTest() && (qli.SAP_Price__c == 0 || qli.UnitPrice < qli.SAP_Price__c || qli.SAP_Price__c == null)) {
						qli.Line_Item_Approval_Stage__c = 'Select Approval Routing';
					}
					else {
						qli.Line_Item_Approval_Stage__c = 'Auto-Approved';
						qli.Submitted_for_Approval_Time__c = Datetime.now();
						qli.Approved_Time__c = datetime.now();
						qli.Approver_Name__c = Userinfo.getName();
						qli.ClonedFlag__c = null;
					}
				}				
				else if(!isInsert && oldQuoteItem.Line_Item_Approval_Stage__c.contains('Approved') && qli.Line_Item_Approval_Stage__c != null)
				{
					qli.ClonedFlag__c = null;
					if(UserInfo.getProfileId() != SysAdminId && UserInfo.getProfileId() != PSAdminId){
						if(	isChangedQLI(qli, oldQuoteItem, 'Model_Code__c') ||
							isChangedQLI(qli, oldQuoteItem, 'Description') ||
							isChangedQLI(qli, oldQuoteItem, 'Quantity') ||
							isChangedQLI(qli, oldQuoteItem, 'UnitPrice') ||
							isChangedQLI(qli, oldQuoteItem, 'Distributor_Price__c') ||
							isChangedQLI(qli, oldQuoteItem, 'ApprovalComments__c') ||
							(isChangedQLI(qli, oldQuoteItem, 'Line_Item_Approval_Stage__c') && ((oldQuoteItem.Line_Item_Approval_Stage__c.contains('Approved')) || (oldQuoteItem.Line_Item_Approval_Stage__c.contains('Declined')) || (oldQuoteItem.Line_Item_Approval_Stage__c.contains('Cancelled')))))
						{
							qli.adderror('Customer Part Number and Comments Published To Customer are the only fields that can be edited after the line item has been approved, declined or cancelled.');
						}
					}
				}
			}
		}
	}
	
	//***AFTER INSERT***
	public Static void GetSAPPriceAfterClonedInsert(list <QuoteLineItem >lstQuoteItem)	{
		for (QuoteLineItem qli :lstQuoteItem) {
			if(!Test.isRunningTest() && qli.ClonedFlag__c == 'true') {
				PriceManagement.GetSAPPrice((string)qli.Id);
			}
		}		
	}
	
	//***AFTER UPDATE***
	public Static void sendEmailToBusinessMail(list <QuoteLineItem >lstQuoteItem, Map <Id, QuoteLineItem >mpQuoteLineItem) {
		map <Id, Set <String >>mpQuoteEmails = new map <Id, Set <String >>();
		map <Id, Contact >mpQuoteLineContact = new map <Id, Contact >();
		list <QuoteLineItem >lstQuoteLineItem = new list <QuoteLineItem >();
		for (QuoteLineItem qli :lstQuoteItem) {
			if (isValidQuoteLineItem(qli, mpQuoteLineItem)) {
				if (!mpQuoteEmails.containsKey(qli.QuoteId)) {
					mpQuoteEmails.put(qli.QuoteId, new Set <String >());
				}
				if (!mpQuoteEmails.get(qli.QuoteId).contains(qli.Business_Area_Email__c)) {
					mpQuoteEmails.get(qli.QuoteId).add(qli.Business_Area_Email__c);
					lstQuoteLineItem.add(qli);
					mpQuoteLineContact.put(qli.Id, new Contact(lastname = qli.Id, Email = qli.Business_Area_Email__c));
				}
			}
		}
		if (mpQuoteEmails.isEmpty()) {
			return ;
		}
		if (!mpQuoteLineContact.isEmpty()) {
			insert mpQuoteLineContact.values();
		}
		Id templateId = ApprovalEmailTemplateMapping__c.getInstance('QuoteBAApproval').Email_Template_ID__c;		
		List <Messaging.SingleEmailMessage >lstEmails = new List <Messaging.SingleEmailMessage >();
		for (Quotelineitem qli :lstQuoteLineItem) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage ();
			mail.setWhatId(qli.QuoteId);
			mail.setTargetObjectId(mpQuoteLineContact.get(qli.Id).id);
			mail.setSaveAsActivity(false);
			mail.setTemplateId(templateId);
			lstEmails.add(mail);
		}
		Messaging.sendEmail(lstEmails);
		Database.delete(mpQuoteLineContact.values());
		Database.emptyRecycleBin(mpQuoteLineContact.values());
	}
	
	//***BEFORE INSERT***
	public static void populateQuoteItemData(list <QuoteLineItem> lstQuoteItem, Map<Id, Quote> mpQuotes) {	//***BEFORE INSERT***
		map <Id, Id >mpQuoteAccount = new map <Id, Id >();
		map <Id, Id >mpPriceBookEntryProduct = new map <Id, Id >();
		Map <Id, Product2> mpProducts = new map<Id, Product2>();
	
		for (QuoteLineItem item :lstQuoteItem) {
			mpPriceBookEntryProduct.put(item.pricebookEntryId, NULL);
		}
		for(Quote quote :mpQuotes.values())
			mpQuoteAccount.put(quote.Id, quote.Opportunity.AccountId);
		for (PriceBookEntry pbe :[SELECT Id,Product2Id FROM PriceBookEntry WHERE Id IN : mpPriceBookEntryProduct.keySet()]) {
			mpPriceBookEntryProduct.put(pbe.Id, pbe.Product2Id);
		}
		for (Product2 prod :[SELECT Id,SAP_Material_Code__c, Model_Code__c, Business_Unit__c FROM Product2 WHERE Id IN : mpPriceBookEntryProduct.values()]) {
			mpProducts.put(prod.Id, prod);
		}
		for (QuoteLineItem item :lstQuoteItem) {
			if(mpQuotes.containsKey(item.QuoteId))
			{
				item.Email_of_Pricing__c = mpQuotes.get(item.QuoteId).Pricing_Team_Group_Email__c;
				item.Email_of_Sales_Manager__c = mpQuotes.get(item.QuoteId).Account_Owner__r.Email;
			}
			if(mpPriceBookEntryProduct.containsKey(item.PricebookEntryId))
			{
				item.Model_Code__c = mpProducts.get(mpPriceBookEntryProduct.get(item.PricebookEntryId)).Model_Code__c;
				item.Part_Number__c = mpProducts.get(mpPriceBookEntryProduct.get(item.PricebookEntryId)).SAP_Material_Code__c;				
				item.Business_Area__c = mpProducts.get(mpPriceBookEntryProduct.get(item.PricebookEntryId)).Business_Unit__c;
				if(mpProducts.get(mpPriceBookEntryProduct.get(item.PricebookEntryId)).Business_Unit__c != null)
				{
					item.Business_Area_Email__c = mpProducts.get(mpPriceBookEntryProduct.get(item.PricebookEntryId)).Business_Unit__c.replace('Valves', '').replace(' ', '') + 'Pricing@danfoss.com';
				}
			}			
		}
		map <String , Customer_Part_Number__c >mpCustomerPartNumber = new map <String , Customer_Part_Number__c >();
		for (Customer_Part_Number__c part :[SELECT Material_Number__c,Id,Account__c,Product__c 
                                      FROM Customer_Part_Number__c 
                                      WHERE Account__c IN :mpQuoteAccount.values() 
                                            AND Product__c IN :mpPriceBookEntryProduct.values()]) {
			mpCustomerPartNumber.put(part.Account__c + '-'+ part.Product__c, part);
		}
		for (QuoteLineItem item :lstQuoteItem) {
			String key = mpQuoteAccount.get(item.QuoteId)+ '-'+ mpPriceBookEntryProduct.get(item.pricebookEntryId);
			if (mpCustomerPartNumber.containsKey(key)) {
				item.Customer_Part_Number__c = mpCustomerPartNumber.get(key).Material_Number__c;
			}
		}
		
	}
	
	//***AFTER INSERT, UPDATE, DELETE***   Quote Line Item history tracking
	public static void populateQuoteItemData(list<QuoteLineItem> lstQuoteItem, map<Id, QuoteLineItem> mpNEWQuoteLineItem, map<Id, QuoteLineItem> mpOLDQuoteLineItem, Boolean isInsert, Boolean isDelete) {	
		if (isHistoryCreated) {
			return ;
		}
		isHistoryCreated = true;
		List <QLI_History__c> lstQLIHistory = new List <QLI_History__c>();
		map <Id, QuoteLineItem> mpQueryQLI = mpNEWQuoteLineItem; 
		Map <String , Schema.SObjectField >mapField = Schema.SObjectType.QuoteLineItem.fields.getMap();
		for (QuoteLineItem qli :lstQuoteItem) {	
			if (isDelete) {
				lstQLIHistory.add(createQLIHistory(qli, qli.QuoteId, isDelete, isInsert, mpOLDQuoteLineItem, mapField, mpNEWQuoteLineItem, null));
				continue ;
			}
			if (isInsert) {
				lstQLIHistory.add(createQLIHistory(qli, qli.QuoteId, isDelete, isInsert, mpOLDQuoteLineItem, mapField, mpNEWQuoteLineItem, null));
				continue ;
			}		
			QuoteLineItem oldQuoteItem = mpOLDQuoteLineItem.get(qli.Id);
			if (isChangedQLI(qli, oldQuoteItem, 'Customer_Part_Number__c')) {
				lstQLIHistory.add(createQLIHistory(qli, qli.QuoteId, isDelete, isInsert, mpOLDQuoteLineItem, mapField, mpNEWQuoteLineItem, 'Customer_Part_Number__c'));
			}
			if (isChangedQLI(qli, oldQuoteItem, 'PS_Customer_Product_Category__c')) {
				lstQLIHistory.add(createQLIHistory(qli, qli.QuoteId, isDelete, isInsert, mpOLDQuoteLineItem, mapField, mpNEWQuoteLineItem, 'PS_Customer_Product_Category__c'));
			}
			if (isChangedQLI(qli, oldQuoteItem, 'Published_Customer_Comments__c')) {
				lstQLIHistory.add(createQLIHistory(qli, qli.QuoteId, isDelete, isInsert, mpOLDQuoteLineItem, mapField, mpNEWQuoteLineItem, 'Published_Customer_Comments__c'));
			}
			if (isChangedQLI(qli, oldQuoteItem, 'unitprice')) {
				lstQLIHistory.add(createQLIHistory(qli, qli.QuoteId, isDelete, isInsert, mpOLDQuoteLineItem, mapField, mpNEWQuoteLineItem, 'unitprice'));
			}
			if (isChangedQLI(qli, oldQuoteItem, 'quantity')) {
				lstQLIHistory.add(createQLIHistory(qli, qli.QuoteId, isDelete, isInsert, mpOLDQuoteLineItem, mapField, mpNEWQuoteLineItem, 'quantity'));
			}
			if (isChangedQLI(qli, oldQuoteItem, 'approvalcomments__c')) {
				lstQLIHistory.add(createQLIHistory(qli, qli.QuoteId, isDelete, isInsert, mpOLDQuoteLineItem, mapField, mpNEWQuoteLineItem, 'approvalcomments__c'));
			}
			if (isChangedQLI(qli, oldQuoteItem, 'line_item_approval_stage__c')) {
				lstQLIHistory.add(createQLIHistory(qli, qli.QuoteId, isDelete, isInsert, mpOLDQuoteLineItem, mapField, mpNEWQuoteLineItem, 'line_item_approval_stage__c'));
			}
		}
		if (!lstQLIHistory.isEmpty()) {
			insert lstQLIHistory;
		}
	}
	
	//***AFTER INSERT, UPDATE, DELETE***   Roll up QLI part numbers
	public static void updateQuoteWithPartNumbers(List<QuoteLineItem> lstNEWQLIs, List<QuoteLineItem> lstOLDQLIs, map <Id, QuoteLineItem> mapOLDQLIs, Boolean isDelete, Boolean isUpdate){
		List<Quote> lstQuotes;
    	set <Id>setQuoteIds = new set<Id>();
    	if (isDelete){
			for (QuoteLineItem q :lstOLDQLIs) 
				setQuoteIds.add(q.QuoteId);
	    }
	    else if(isUpdate){
	        for (QuoteLineItem q :lstNEWQLIs) 
				if (q.Customer_Part_Number__c != mapOLDQLIs.get(q.Id).Customer_Part_Number__c)
					setQuoteIds.add(q.QuoteId);
	    }
	    else{ // is INSERT
			for (QuoteLineItem q :lstNEWQLIs) 
				setQuoteIds.add(q.QuoteId);
	    }
	    lstQuotes = [select Id From Quote where Id IN :setQuoteIds];
		if(!lstQuotes.isEmpty())
    		update lstQuotes;	
	}
	
	//***BEFORE DELETE***
	public static void preventApprovedDeletion(List<QuoteLineItem> lstOLDQLIs, Map<Id, Quote> mpQuotes){
		if(UserInfo.getProfileId() != SysAdminId && UserInfo.getProfileId() != PSAdminId){
			for (QuoteLineItem q :lstOLDQLIs) {
				if(q.Line_Item_Approval_Stage__c.contains('Approved') && mpQuotes.get(q.QuoteId).Approval_Stage__c == 'Approved')
					q.adderror('Approved line items cannot be deleted from an approved quote.');
			}
		}
	}
	
	//PRIVATE METHODS
	private static Boolean isValidQuoteLineItem(QuoteLineItem qli, Map <Id, QuoteLineItem >mpQuoteLineItem) {
		if (qli.Business_Area_Email__c == NULL || qli.Line_Item_Approval_Stage__c != 'Business Unit - Requires Review') {
			return false;
		}
		QuoteLineItem qliOld = mpQuoteLineItem.get(qli.Id);
		if (qliOld.Business_Area_Email__c != qli.Business_Area_Email__c) {
			return true;
		}
		if (qliOld.Line_Item_Approval_Stage__c != qli.Line_Item_Approval_Stage__c) {
			return true;
		}
		return false;
	}
	
	private static QLI_History__c createQLIHistory(QuoteLineItem qli, Id qID, Boolean isDelete, Boolean isInsert, map <Id, QuoteLineItem> mpQuoteLineItem, Map <String , Schema.SObjectField> mapField, map <Id, QuoteLineItem> mpQuoteLineItemNew, String fieldApi) {
		QLI_History__c history = new QLI_History__c();
		history.Changed_By__c = Userinfo.getUserId();
		history.Time__c = DateTime.now();
		history.Quote__c = qId;	
		if (isDelete) {
			history.SAP_Material_Number__c = mpQuoteLineItem.get(qli.Id).Part_Number__c;
			history.Record_Action__c = 'Deleted';
			return history;
		}
		history.Quote_Line_Item__c = qli.Id;
		history.SAP_Material_Number__c = mpQuoteLineItemNew.get(qli.Id).Part_Number__c;
		history.Product__c = mpQuoteLineItemNew.get(qli.Id).PriceBookEntry.Product2Id;		
		if (isInsert) {
			history.Record_Action__c = 'Created';
			return history;
		}
		history.Record_Action__c = 'Edited';
		Schema.SObjectField field = mapField.get(fieldApi);
		Schema.DescribeFieldResult result = field.getDescribe();
		history.Field_Name__c = result.getLabel();
		if (mpQuoteLineItem.get(qli.Id).get(fieldApi)!= null) {
			history.Old_Value__c = String.valueOf(mpQuoteLineItem.get(qli.Id).get(fieldApi));
		}
		if (qli.get(fieldApi)!= null) {
			history.New_Value__c = String.valueOf(qli.get(fieldApi));
		}
		return history;
	}
	
	private static Boolean isChangedQLI(QuoteLineItem quoteItem, QuoteLineItem oldQuoteItem, String fieldApi) {
		if (oldQuoteItem.get(fieldApi) != quoteItem.get(fieldApi)) {
			return true;
		}
		return false;
	}
	
}