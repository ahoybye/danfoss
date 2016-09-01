@isTest
private class Test_RefreshSAPPrice {
		
	static User adminUser;	
	static Region__c reg;
	static Id StdPBId;
	static PriceBookEntry stdpbe;
	static Product2 p;
	static Opportunity oppty;
	static OpportunityLineItem oli;
	static Quote quote;
	static QuoteLineItem qli;
	static Machine_Model__c model;
	static Machine_Model_Product__c mmprod;
	
    static testMethod void RefreshSAPPriceTestOppty() {
		createUsers();
		system.runAs(adminUser) {
			createTestData();
	        oli = new OpportunityLineItem(OpportunityId = oppty.Id, PriceBookEntryId = stdpbe.Id, UnitPrice = 10, Quantity =10);
	        insert oli;
		}	
		Test.startTest();
		PageReference pg = Page.RefreshOpportunitySAPPrice;
		Test.setCurrentPage(pg);
		ApexPages.currentPage().getParameters().put('id',oppty.Id);
		ApexPages.currentPage().getParameters().put('opportunityLineItemId',oli.Id);
		Test.setMock(WebServiceMock.class, new Test_QuoteWebServiceMockImpl());
		RefreshSAPPrice refreshSAP = new RefreshSAPPrice(new ApexPages.StandardController(oppty));
		refreshSAP.autorun();
		refreshSAP.saveAndReturn();
		Test.stopTest();
    }
    
    static testMethod void RefreshSAPPriceTestMachine() {
		createUsers();
		system.runAs(adminUser) {
			createTestData();
	        mmprod = new Machine_Model_Product__c(Name = 'mmprod1', Machine_Model__c = model.Id, Machine_Model_Product__c = p.Id, Price__c = 2.00, Number_Per_Machine__c = 1, Adoption_Rate__c = 100, Subsystem__c = 'Steering Function', Competitiveness__c = 'High');
	        insert mmprod;
		}	
		Test.startTest();
		PageReference pg = Page.RefreshMachineSAPPrice;
		Test.setCurrentPage(pg);
		ApexPages.currentPage().getParameters().put('id',model.Id);
		ApexPages.currentPage().getParameters().put('mmprodId',mmprod.Id);
		Test.setMock(WebServiceMock.class, new Test_QuoteWebServiceMockImpl());
		RefreshSAPPrice refreshSAP = new RefreshSAPPrice(new ApexPages.StandardController(model));
		refreshSAP.autorun();
		refreshSAP.saveAndReturn();
		Test.stopTest();
    }
    
    static testMethod void RefreshSAPPriceTestQuote() {
		createUsers();
		system.runAs(adminUser) {
			createTestData();
			quote = new Quote(OpportunityId = oppty.Id, Name='qli', PriceBook2Id = StdPBId, Country_Specific_Template__c = reg.Id);
			insert quote;      
	        qli = new QuoteLineItem(QuoteId = quote.Id, PriceBookEntryId = stdpbe.Id, UnitPrice = 10, Quantity =10);
	        insert qli;
		}
		Test.startTest();
		PageReference pg = Page.RefreshOpportunitySAPPrice;
		Test.setCurrentPage(pg);
		ApexPages.currentPage().getParameters().put('id',quote.Id);
		ApexPages.currentPage().getParameters().put('quoteLineItemId',qli.Id);
		Test.setMock(WebServiceMock.class, new Test_QuoteWebServiceMockImpl());
		RefreshSAPPrice refreshSAP = new RefreshSAPPrice(new ApexPages.StandardController(quote));
		refreshSAP.autorun();
		refreshSAP.saveAndReturn();
		Test.stopTest();
    }
	
	
	private static void createTestData(){
		Test_Utility.initTestData();   //create C&E pricebook
		p = Test_Utility.createProduct2();   
		p.Business_Unit__c = 'Motors';
		p.Model_Code__c = 'code';
		p.SAP_Material_Code__c = '1234';
		insert p;        		
		StdPBId = Test.getStandardPricebookId();
		stdpbe = new PricebookEntry(Pricebook2Id = StdPBId, Product2Id = p.Id, UnitPrice = 100, IsActive = true, CurrencyISOCode = 'DKK');
		insert stdpbe;
		reg = new Region__c(Name = 'USA', Country_Code__c = 'US', Region__c = 'Americas');
		insert reg;
		Account account = Test_Utility.createAccount(2);
		insert account; 
		oppty = Test_Utility.createOpportunity(account.Id, 1);
		insert oppty;	
		model = new Machine_Model__c(Name = 'machine', Account__c = account.Id, Annual_Production_Volume__c = 10, Annual_Production_Volume_Plus1__c=10, Annual_Production_Volume_Plus2__c=10, Annual_Production_Volume_Plus3__c=10,Total_Machine_Potential__c = 10.00);
    insert model;
	}
	
    private static void createUsers() {
		Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
		UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
		adminUser = Test_Utility.createUser(profile.Id, roles.Id, 1);
		adminUser.DelegatedApproverId = UserInfo.getUserId();
		insert adminUser;
	}
}