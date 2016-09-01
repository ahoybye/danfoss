@isTest
private class Test_QuoteTriggers {
	
	static Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
	static User adminUser;	
	static Region__c usaRegion;
	static Id StdPBId;
	static PriceBookEntry stdpbe;
	static List<Account> lstAccounts;
	static List<Opportunity> lstOpptys;
	static List<Quote> lstQuotes;
	static List<QuoteLineItem> lstQLIs;
	static Account account1;
	static Account account2;
	static Account account3;
	static Opportunity oppty1;
	static Opportunity oppty2;
	
    static testMethod void testTriggers () {
		createUsers();
		system.runAs(adminUser) {
			createTestData();
			lstQuotes = new List<Quote>();
			lstQLIs = new List<QuoteLineItem>();		
			
			Test.startTest();
			Quote quote1 = new Quote(OpportunityId = oppty1.Id, Name = 'quote1', PriceBook2Id = StdPBId, Country_Specific_Template__c = usaRegion.Id, Description = 'abc', Footer_Comments__c = 'xyz');
			lstQuotes.add(quote1);
			Quote quote2 = new Quote(OpportunityId = oppty2.Id, Name = 'quote2', PriceBook2Id = StdPBId, Country_Specific_Template__c = usaRegion.Id, Description = 'abc', Footer_Comments__c = 'xyz', Approval_Date__c = null);
			lstQuotes.add(quote2);
			
			if(!lstQuotes.isEmpty())
				insert lstQuotes;
						
			QuoteLineItem qli = new QuoteLineItem(QuoteId = quote2.Id, PricebookEntryId = stdpbe.id, SAP_Price__c = 1, UnitPrice = 10, Quantity = 1, SAP_Currency__c  = 'DKK', Business_Area_Email__c = 'abc@xyz.com');	
			qli.Line_Item_Approval_Stage__c = 'Business Unit - Requires Review';
			qli.ClonedFlag__c = 'true';
			lstQLIs.add(qli);
			QuoteLineItem qli2 = new QuoteLineItem(QuoteId = quote2.Id, PricebookEntryId = stdpbe.id, SAP_Price__c = 2, UnitPrice = 20, Quantity = 2, SAP_Currency__c  = 'DKK', Business_Area_Email__c = 'abc@xyz.com');
			qli2.Line_Item_Approval_Stage__c = 'Auto-Approved';
			lstQLIs.add(qli2);
			QuoteLineItem qli3 = new QuoteLineItem(QuoteId = quote2.Id, PricebookEntryId = stdpbe.id, SAP_Price__c = 3, UnitPrice = 30, Quantity = 3, SAP_Currency__c  = 'DKK', Business_Area_Email__c = 'abc@xyz.com');
			lstQLIs.add(qli3);
			
			if(!lstQLIs.isEmpty())
				insert lstQLIs;
			
			/*qli.ClonedFlag__c = '';		
			qli.Business_Area_Email__c = 'def@xyz.com';*/
			//qli.Line_Item_Approval_Stage__c = 'Business Unit - Requires Review';
			//qli.Published_Customer_Comments__c = 'blah';
			qli3.Line_Item_Approval_Stage__c = 'Account Owner - Approved';
			update qli3;
			/*update lstQLIs;*/
			
			delete qli;
			Test.stopTest();
		}
    }
	
	/*static testMethod void testCloneController () {
		createUsers();
		system.runAs(adminUser) {
			createTestData();
			lstQuotes = new List<Quote>();
			lstQLIs = new List<QuoteLineItem>();
			Quote quote1 = new Quote(OpportunityId = oppty1.Id, Name = 'quote1', PriceBook2Id = StdPBId, Country_Specific_Template__c = usaRegion.Id, Description = 'abc', Footer_Comments__c = 'xyz');
			lstQuotes.add(quote1);
			if(!lstQuotes.isEmpty())
				insert lstQuotes;
			QuoteLineItem qli1 = new QuoteLineItem(QuoteId = quote1.Id, PricebookEntryId = stdpbe.id, SAP_Price__c = 3, UnitPrice = 30, Quantity = 3, SAP_Currency__c  = 'DKK', Business_Area_Email__c = 'abc@xyz.com');
			lstQLIs.add(qli1);
			
			if(!lstQLIs.isEmpty())
				insert lstQLIs;
			
			Test.startTest();
			PageReference pg = Page.QuoteClonePage;
			Test.setCurrentPage(pg);		
	        Apexpages.Standardcontroller stdcont = new Apexpages.Standardcontroller(quote1);
			QuoteClonePageControllerExtension cont = new QuoteClonePageControllerExtension(stdcont);
	        PageReference pr = cont.chainClone();
			Test.stopTest();
		}
	}*/
	
    static void createTestData() {
		Test_Utility.initTestData();   //create C&E pricebook
		Product2 p = Test_Utility.createProduct2();        
		p.Business_Unit__c = 'Motors';
		p.Model_Code__c = 'code';
		p.SAP_Material_Code__c = '1234';
		insert p;        		
		StdPBId = Test.getStandardPricebookId();
		stdpbe = new PricebookEntry(Pricebook2Id = StdPBId, Product2Id = p.Id, UnitPrice = 100, IsActive = true, CurrencyISOCode = 'DKK');
		insert stdpbe;
		usaRegion = new Region__c(Name = 'USA', Country_Code__c = 'US', Region__c = 'Americas');
		insert usaRegion;
		lstAccounts = new List<Account>();			
		account1 = createAccount(1, 'Integrated', 'Distributor');
		account1.SAP_Account_ID__c = '80000000';
		account1.Account_Group__c = '0001';
		lstAccounts.add(account1);
		
		account2 = createAccount(2, 'Integrated', 'Distributor');
		account2.SAP_Account_ID__c = '70000000';
		account2.Account_Group__c = '0002';
		lstAccounts.add(account2);
		
		account3 = createAccount(3, 'Integrated', 'Distributor');
		account3.Sales_Manager__c = adminUser.Id;
		account3.OwnerId = UserInfo.getUserId();
		lstAccounts.add(account3);
		if(!lstAccounts.isEmpty())
		insert lstAccounts;
		lstOpptys = new List<Opportunity>();
		oppty1 = Test_Utility.createOpportunity(account3.Id, 1);
		lstOpptys.add(oppty1);
		oppty2 = Test_Utility.createOpportunity(account2.Id, 2);
		lstOpptys.add(oppty2);
		if(!lstOpptys.isEmpty())
		insert lstOpptys;
		account1.SAP_Account_ID__c = '710000';
		account2.ParentId = account1.Id;
		account2.SAP_Account_ID__c = '810000';
		account3.ParentId = account2.Id;
		update lstAccounts;
	}
	
	private static Account createAccount(Integer i, String busorg, String channel){
		usaRegion = [select Id from Region__c where Name = 'USA'];
        Account account = new Account(
                                Name='Test Account Name' + i,
                                Business_Org__c = busorg,
								Channel__c = channel,
                                Country__c = usaRegion.Id,
                                RecordTypeId = acctRecordTypeId);
        account.OwnerId = UserInfo.getUserId();
        return account;
    }
	
    private static void createUsers() {
		Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
		UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
		adminUser = Test_Utility.createUser(profile.Id, roles.Id, 1);
		adminUser.DelegatedApproverId = UserInfo.getUserId();
		insert adminUser;
	}
}