@isTest
private class Test_AddLineItems {
	
	static Id StdPBId;
	static PriceBookEntry stdpbe;
	static Product2 product;
	static Region__c usaRegion;
	static Account account;
	static Opportunity oppty;
	static Machine_Model__c machine;
	
    static testMethod void testAddLineItem() {  
		createTestData();
		Test.startTest();
		PageReference pg = Page.AddOpptyLineItems;
		Test.setCurrentPage(pg);
		ApexPages.currentPage().getParameters().put('id',oppty.Id);
		ApexPages.currentPage().getParameters().put('priceBookEntryId',stdpbe.Id);
		Test.setMock(WebServiceMock.class, new Test_QuoteWebServiceMockImpl());

		AddLineItems ext = new AddLineItems();
		ext.quote = new Quote(); 
		ext.SaveLineItems();
		List<OpportunityLineItem> lstLineItem = ext.getOpportunityLineItems();
		lstLineItem[0].UnitPrice = 12;
		lstLineItem[0].Quantity = 21;    
		ext.SaveAndMore();
		ext.GetSAPPrice();
		AddLineItems.getTotalPrice('2', '2');
		AddLineItems.getThousandSeparator();
		Test.stopTest();
    }
	
    static testMethod void testAddLineItemMachine() {  
		createTestData();
		Test.startTest();
		PageReference pg = Page.AddMachineLineItems;
		Test.setCurrentPage(pg);
		ApexPages.currentPage().getParameters().put('id',Machine.Id);
		ApexPages.currentPage().getParameters().put('priceBookEntryId',stdpbe.Id);
		ApexPages.currentPage().getParameters().put('salesorg','1500');
		ApexPages.currentPage().getParameters().put('subsystem','Transmission');
		Test.setMock(WebServiceMock.class, new Test_QuoteWebServiceMockImpl());

		AddLineItems ext = new AddLineItems();	
		ext.machine = new Machine_Model__c();
		ext.SaveLineItems();
		List<Machine_Model_Product__c> lstLineItem = ext.getMachineLineItems();
		lstLineItem[0].Product_Type__c = 'Transmission Pump';
		lstLineItem[0].Competitiveness__c = 'High';
		lstLineItem[0].Adoption_Rate__c = 100;
		lstLineItem[0].Number_per_machine__c = 1;
		ext.SaveAndMore();
		ext.GetSAPPrice(); 
		AddLineItems.getTotalPrice('2', '2');
		AddLineItems.getThousandSeparator();
		ext.cancel();
		Test.stopTest();
    }
  
    static testMethod void testAddLineItemQuote() { 
		createTestData();
		Quote quote = new Quote(OpportunityId = oppty.Id,Name='qli',PriceBook2Id = StdPBId, Country_Specific_Template__c = usaRegion.Id);
		insert quote;
		
		Test.startTest();
		PageReference pg = Page.AddOpptyLineItems;
		Test.setCurrentPage(pg);
		ApexPages.currentPage().getParameters().put('id',quote.Id);
		ApexPages.currentPage().getParameters().put('priceBookEntryId',stdpbe.Id);
		Test.setMock(WebServiceMock.class, new Test_QuoteWebServiceMockImpl());

		AddLineItems ext = new AddLineItems();
		ext.quote = new Quote(); 
		ext.SaveLineItems();
		List<QuoteLineItem> lstQuoteLineItem = ext.getQuoteLineItems();
		lstQuoteLineItem[0].UnitPrice = 12;
		lstQuoteLineItem[0].Quantity = 21;    
		ext.SaveAndMore();
		//ext.GetSAPPrice();
		AddLineItems.getTotalPrice('2', '2');
		AddLineItems.getThousandSeparator();
		Test.stopTest();
  }
	
	static void createTestData(){
    	Test_Utility.initTestData();   //create C&E pricebook
		product = Test_Utility.createProduct2();
		product.Business_Unit__c = 'Motors';
		product.ProductCode = '11111';
		product.Model_Code__c = 'modelcodetext';
		product.Business_Org__c = 'Danfoss';
		insert product;
		StdPBId = Test.getStandardPricebookId();
		stdpbe = new PricebookEntry(Pricebook2Id = StdPBId, Product2Id = product.Id, UnitPrice = 100, IsActive = true, CurrencyISOCode = 'DKK');
		insert stdpbe;
		usaRegion = new Region__c(Name = 'USA', Country_Code__c = 'US', Region__c = 'Americas');
		insert usaRegion;
		account = Test_Utility.createAccount(1);
		insert account;
		machine = new Machine_Model__c(Name = 'machine', Account__c = account.Id, Annual_Production_Volume__c = 10, Annual_Production_Volume_Plus1__c=10, Annual_Production_Volume_Plus2__c=10, Annual_Production_Volume_Plus3__c=10,Total_Machine_Potential__c = 10.00);
        insert machine;
		oppty = Test_Utility.createOpportunity(account.Id, 1);
		insert oppty;  
	}	
}