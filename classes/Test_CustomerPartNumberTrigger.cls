@isTest
private class Test_CustomerPartNumberTrigger {
	static User adminUser;
	static Region__c usaRegion;
	static Id StdPBId;
	static PriceBookEntry stdpbe;
	static Product2 product;
	
	static testMethod void testDeleteCustomerPartNumberTriggerQuote() {
		createUsers();
		system.runAs(adminUser) {
			createTestData();
			Account account = Test_Utility.createAccount(3);
			insert account;
			Opportunity oppty = Test_Utility.createOpportunity(account.Id, 1);
			insert oppty;
			OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppty.Id,PriceBookEntryId = stdpbe.Id,UnitPrice = 10,Quantity =10);
        	insert oli;
			/*Quote quote = new Quote(OpportunityId = oppty.Id, Name = 'qli', PriceBook2Id = StdPBId, Country_Specific_Template__c = usaRegion.Id);
			insert quote;
			QuoteLineItem qli = new QuoteLineItem(QuoteId = quote.Id, PriceBookEntryId = stdpbe.Id, UnitPrice = 10, Quantity = 10);
			insert qli;*/
			Machine_Model__c machine = new Machine_Model__c(Name = 'mach', Account__c = account.Id, Annual_Production_Volume__c = 10, Annual_Production_Volume_Plus2__c = 10, Annual_Production_Volume_Plus3__c = 10);
			insert machine;
			Machine_Model_Product__c mli = new Machine_Model_Product__c(Machine_Model__c = machine.Id, Machine_Model_Product__c = product.Id);
			insert mli;
			Test.startTest();
			List<Customer_Part_Number__c> lstCPNs = new List<Customer_Part_Number__c>();
			Customer_Part_Number__c part = new Customer_Part_Number__c(Material_Number__c = '123456-ABCDE', Account__c = account.Id, Product__c = product.Id, SAP_Customer_Material_Id__c = '123477');
			lstCPNs.add(part);
			Customer_Part_Number__c part2 = new Customer_Part_Number__c(Material_Number__c = '123456-ABCDE', Account__c = account.Id, Product__c = product.Id, SAP_Customer_Material_Id__c = '123455');
			lstCPNs.add(part2);
			if(!lstCPNs.isEmpty())
				insert lstCPNs;
			part.isDeleted__c = true;
			part2.Material_Number__c = '123';
			update lstCPNs;
			/*Customer_Part_Number__c part3 = new Customer_Part_Number__c(Material_Number__c = '123456-ABCDE', Account__c = account.Id, SAP_Customer_Material_Id__c = '123453');
			insert part3;*/
			
			Exclusive_Material__c excl = new Exclusive_Material__c(Account__c = account.Id, SAP_Exclusive_Material_Id__c = '1234', Product__c = product.Id);
			insert excl;
			/*Exclusive_Material__c excl1 = new Exclusive_Material__c(Account__c = account.Id, SAP_Exclusive_Material_Id__c = '12345', Product__c = product.Id);
			insert excl1;*/
			excl.isDeleted__c = true;
			update excl;
			/*excl1.isDeleted__c = true;
			update excl1;*/
			Test.stopTest();
		}
	}

	private static void createTestData(){
    	Test_Utility.initTestData();   //create C&E pricebook
		product = Test_Utility.createProduct2();
		product.SAP_Material_Code__c = '1234';
		insert product;
		StdPBId = Test.getStandardPricebookId();
		stdpbe = new PricebookEntry(Pricebook2Id = StdPBId, Product2Id = product.Id, UnitPrice = 100, IsActive = true, CurrencyISOCode = 'DKK');
		insert stdpbe;
		usaRegion = new Region__c(Name = 'USA', Country_Code__c = 'US', Region__c = 'Americas');
		insert usaRegion;
	}
	
	private static void createUsers() {
		Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
		UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
		adminUser = Test_Utility.createUser(profile.Id, roles.Id, 1);
		adminUser.DelegatedApproverId = UserInfo.getUserId();
		insert adminUser;
	}
}