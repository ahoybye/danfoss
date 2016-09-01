@isTest
private class Test_QuotePDFExtension {
	static Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
	static User adminUser;
    static User salesRep;
	static Region__c usaRegion;
	static Region__c japanRegion;
	static Id StdPBId;
	static PriceBookEntry stdpbe;
	static Product2 p;
	static List<Account> lstAccounts;
	static List<Opportunity> lstOpptys;
	static List<Quote> lstQuotes;
	static Opportunity opptyIndirectT;
	static Opportunity opptyDirectT;
	static Opportunity opptyDistT;
	static Opportunity opptyIndirectC;
	static Opportunity opptyDirectC;
	static Opportunity opptyDistC;
	static Opportunity opptyIndirectI;
	static Opportunity opptyDirectI;
	static Opportunity opptyDistI;
	
	static testMethod void testIntegratedDirect() {
		createUsers();
		system.runAs(adminUser) {
			createTestData();	
        }       
        System.runAs(salesRep){		
			Test.startTest();
			Quote quoteDirectI = new Quote(OpportunityId = opptyDirectI.Id, name = 'test', Pricebook2Id=StdPBId, Country_Specific_Template__c = usaRegion.id, Description = 'abc', Footer_Comments__c = 'xyz');
			insert quoteDirectI;	
			List<QuoteLineItem> lstQLIs = new List<QuoteLineItem>();
			for(integer i=0; i<=10; i++){
				QuoteLineItem qli = new QuoteLineItem(QuoteId = quoteDirectI.id, PricebookEntryId=stdpbe.Id, Quantity = i+1, SAP_Price__c = i+2, UnitPrice = i+3,  Line_Item_Approval_Stage__c = 'Approved');
				lstQLIs.add(qli);
				i++;
			}
			if(!lstQLIs.isEmpty())
				insert lstQLIs;
			
			Apexpages.Standardcontroller stdcont = new Apexpages.Standardcontroller(quoteDirectI);
			QuotePDFExtension cont = new QuotePDFExtension(stdcont);			
			string docurl = cont.getDocumentLogoURL();	
			PageReference pg = Page.QuotePDF;
        	Test.setCurrentPage(pg);
        	ApexPages.currentPage().getParameters().put('id',quoteDirectI.Id);
			QuoteLineItemPDFExtension contI = new QuoteLineItemPDFExtension();	
			Test.stopTest();
		}
	}
	
	static testMethod void testIntegratedIndirect() {
		createUsers();
		system.runAs(adminUser) {
			createTestData();	
        }       
        System.runAs(salesRep){		
			Test.startTest();
			Quote quoteIndirectI = new Quote(OpportunityId = opptyIndirectI.Id, name = 'test', Pricebook2Id=StdPBId, Country_Specific_Template__c = usaRegion.id, Description = 'abc', Footer_Comments__c = 'xyz');
			insert quoteIndirectI;
			List<QuoteLineItem> lstQLIs = new List<QuoteLineItem>();
			for(integer i=0; i<=10; i++){
				QuoteLineItem qli = new QuoteLineItem(QuoteId = quoteIndirectI.id, PricebookEntryId=stdpbe.Id, Quantity = i+1, SAP_Price__c = i+2, UnitPrice = i+3,  Line_Item_Approval_Stage__c = 'Select Approval Routing');
				lstQLIs.add(qli);
				i++;
			}
			if(!lstQLIs.isEmpty())
				insert lstQLIs;
			
			lstQLIs[0].Line_Item_Approval_Stage__c = 'Account Owner - Approved';
			
			Apexpages.Standardcontroller stdcont = new Apexpages.Standardcontroller(quoteIndirectI);
			QuotePDFExtension cont = new QuotePDFExtension(stdcont);
			
			PageReference pg = Page.QuotePDF;
        	Test.setCurrentPage(pg);
        	ApexPages.currentPage().getParameters().put('id',quoteIndirectI.Id);
			QuoteLineItemPDFExtension contI = new QuoteLineItemPDFExtension();	
			lstQLIs[1].Description = 'x';
			lstQLIs[2].Published_Customer_Comments__c = 'x'; 
			lstQLIs[3].Customer_Part_Number__c = 'x';  		
			lstQLIs[4].Description = 'x';
			lstQLIs[4].Published_Customer_Comments__c = '';
			lstQLIs[5].Published_Customer_Comments__c = 'x';
			lstQLIs[5].Customer_Part_Number__c = '';    
			update lstQLIs;
			contI = new QuoteLineItemPDFExtension();
			Test.stopTest();
		}
	}
		
	static testMethod void testIntegratedDist() {
		createUsers();
		system.runAs(adminUser) {
			createTestData();	
        }       
        System.runAs(salesRep){		
			Test.startTest();	
			
			Quote quoteDistI = new Quote(OpportunityId = opptyDistI.Id, name = 'test', Pricebook2Id=StdPBId, Country_Specific_Template__c = japanRegion.id, Footer_Comments__c = 'xyz', Description = 'x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x');
			insert quoteDistI;		
			List<QuoteLineItem> lstQLIs = new List<QuoteLineItem>();
			for(integer i=0; i<=10; i++){
				QuoteLineItem qli = new QuoteLineItem(QuoteId = quoteDistI.id, PricebookEntryId=stdpbe.Id, Part_Number__c = p.ProductCode, Quantity = i+1, SAP_Price__c = i+2, UnitPrice = i+3,  Line_Item_Approval_Stage__c = 'Approved', Distributor_Price__c = i+3);
				lstQLIs.add(qli);
				i++;
			}
			if(!lstQLIs.isEmpty())
				insert lstQLIs;
			
			Apexpages.Standardcontroller stdcont = new Apexpages.Standardcontroller(quoteDistI);
			QuotePDFExtension cont = new QuotePDFExtension(stdcont);
			
			PageReference pg = Page.QuotePDF;
        	Test.setCurrentPage(pg);
        	ApexPages.currentPage().getParameters().put('id',quoteDistI.Id);
			QuoteLineItemPDFExtension contI = new QuoteLineItemPDFExtension();
			lstQLIs[1].Description = 'x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x '; 
			lstQLIs[3].Customer_Part_Number__c = null;
			lstQLIs[2].Published_Customer_Comments__c = 'x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x '; 
			lstQLIs[3].Customer_Part_Number__c = 'x'; 		
			lstQLIs[4].Description = 'x';
			lstQLIs[4].Published_Customer_Comments__c = '';
			lstQLIs[5].Published_Customer_Comments__c = 'x';
			lstQLIs[5].Customer_Part_Number__c = '';  
			update lstQLIs;
			contI = new QuoteLineItemPDFExtension();
			
			Test.stopTest();
		}
	}
	
	static testMethod void testComatrol() {
		createUsers();
		system.runAs(adminUser) {
			Folder lFolder = [select Id from Folder where Name = 'Logos'];
			Document Clogo = new Document(Name = 'Comatrol Logo', DeveloperName = 'Comatrol_Logo', FolderId = lFolder.Id);
			try{
				insert Clogo;
			}
			catch (Exception ex){}
			createTestData();			
			Test.startTest();
			lstQuotes = new List<Quote>();
			Quote quoteIndirectC = new Quote(OpportunityId = opptyIndirectC.Id, name = 'test', Pricebook2Id=StdPBId, Country_Specific_Template__c = usaRegion.id, Description = 'abc', Footer_Comments__c = 'xyz');
			lstQuotes.add(quoteIndirectC);
			Quote quoteDirectC = new Quote(OpportunityId = opptyDirectC.Id, name = 'test', Pricebook2Id=StdPBId, Country_Specific_Template__c = japanRegion.id, Description = 'abc', Footer_Comments__c = 'xyz');
			lstQuotes.add(quoteDirectC);
			Quote quoteDistC = new Quote(OpportunityId = opptyDistC.Id, name = 'test', Pricebook2Id=StdPBId, Country_Specific_Template__c = usaRegion.id, Description = 'abc', Footer_Comments__c = 'xyz');
			lstQuotes.add(quoteDistC);
			if(!lstQuotes.isEmpty())
				insert lstQuotes;		
			QuoteLineItem qli = new QuoteLineItem(QuoteId = quoteDirectC.id, PricebookEntryId=stdpbe.Id, Quantity = 10, UnitPrice = 25, ClonedFlag__c = 'true', Business_Area_Email__c = 'a@a.com', Line_Item_Approval_Stage__c = 'Approved', SAP_Price__c = 20, SAP_Currency__c = 'DKK', SAP_List_Price__c = 20);
			insert qli;			
			Apexpages.Standardcontroller stdcont = new Apexpages.Standardcontroller(quoteIndirectC);
			QuotePDFExtension cont = new QuotePDFExtension(stdcont);
			string docurl = cont.getDocumentLogoURL();	
			stdcont = new Apexpages.Standardcontroller(quoteDirectC);
			cont = new QuotePDFExtension(stdcont);
			stdcont = new Apexpages.Standardcontroller(quoteDistC);
			cont = new QuotePDFExtension(stdcont);	
			
			PageReference pg = Page.QuotePDF;
        	Test.setCurrentPage(pg);
        	ApexPages.currentPage().getParameters().put('id',quoteDirectC.Id);
			QuoteLineItemPDFExtension contC = new QuoteLineItemPDFExtension();
			 
			Test.stopTest();
		}
    }	
	
	static testMethod void testTurolla() {
		createUsers();
		system.runAs(adminUser) {
			createTestData();
			Test.startTest();
			lstQuotes = new List<Quote>();
			Quote quoteIndirectT = new Quote(OpportunityId = opptyIndirectT.Id, name = 'test', Pricebook2Id=StdPBId, Country_Specific_Template__c = japanRegion.id, Description = 'abc', Footer_Comments__c = 'xyz');
			lstQuotes.add(quoteIndirectT);
			Quote quoteDirectT = new Quote(OpportunityId = opptyDirectT.Id, name = 'test', Pricebook2Id=StdPBId, Country_Specific_Template__c = usaRegion.id, Description = 'abc', Footer_Comments__c = 'xyz');
			lstQuotes.add(quoteDirectT);
			Quote quoteDistT = new Quote(OpportunityId = opptyDistT.Id, name = 'test', Pricebook2Id=StdPBId, Country_Specific_Template__c = usaRegion.id, Description = 'abc', Footer_Comments__c = 'xyz');
			lstQuotes.add(quoteDistT);			
			if(!lstQuotes.isEmpty())
				insert lstQuotes;		
			QuoteLineItem qli = new QuoteLineItem(QuoteId = quoteIndirectT.id, PricebookEntryId=stdpbe.Id, Quantity = 10, UnitPrice = 30, ClonedFlag__c = 'true2', Line_Item_Approval_Stage__c = 'Select');
			insert qli;					
			
			Apexpages.Standardcontroller stdcont = new Apexpages.Standardcontroller(quoteIndirectT);
			QuotePDFExtension cont = new QuotePDFExtension(stdcont);			
			string docurl = cont.getDocumentLogoURL();
			stdcont = new Apexpages.Standardcontroller(quoteDirectT);
			cont = new QuotePDFExtension(stdcont);	
			stdcont = new Apexpages.Standardcontroller(quoteDistT);
			cont = new QuotePDFExtension(stdcont);			
			
			PageReference pg = Page.QuotePDF;
        	Test.setCurrentPage(pg);
        	ApexPages.currentPage().getParameters().put('id',quoteIndirectT.Id);
			QuoteLineItemPDFExtension contT = new QuoteLineItemPDFExtension();
			Test.stopTest();
		}
	}
	
	private static void createTestData(){
    	Test_Utility.initTestData();   //create C&E pricebook
		p = Test_Utility.createProduct2();        
		p.Business_Unit__c = 'Motors';
		p.ProductCode = '1234567';
		p.Model_Code__c = 'model code';
		insert p;        		
		StdPBId = Test.getStandardPricebookId();
		stdpbe = new PricebookEntry(Pricebook2Id = StdPBId, Product2Id = p.Id, UnitPrice = 100, IsActive = true, CurrencyISOCode = 'DKK');
		insert stdpbe;
		usaRegion = new Region__c(Name = 'USA', Country_Code__c = 'US', Region__c = 'Americas');
		insert usaRegion;
		japanRegion = new Region__c(Name = 'Japan', Country_Code__c = 'JP', Region__c = 'APAC');
		insert japanRegion;		
       /* Sales_Org__c so = new Sales_Org__c(Name = '1500', SAP_Sales_Org__c = '1500', Account__c = accountId);
        insert so;*/
		
		lstAccounts = new List<Account>();		
		Account accountDirectT = createAccount(5, 'Turolla', 'Direct', usaRegion.Id);
		lstAccounts.add(accountDirectT);
		
		Account accountDistT = createAccount(4, 'Turolla', 'Distributor', usaRegion.Id);
		lstAccounts.add(accountDistT);
		
		Account accountIndirectT = createAccount(8, 'Turolla', 'Indirect', usaRegion.Id);
		lstAccounts.add(accountIndirectT);			
		
		Account accountDirectC = createAccount(7, 'Comatrol', 'Direct', usaRegion.Id);
		lstAccounts.add(accountDirectC);
		
		Account accountDistC = createAccount(9, 'Comatrol', 'Distributor', usaRegion.Id);
		lstAccounts.add(accountDistC);
		
		Account accountIndirectC = createAccount(6, 'Comatrol', 'Indirect', usaRegion.Id);
		lstAccounts.add(accountIndirectC);
		
		Account accountDirectI = createAccount(1, 'Integrated', 'Direct', usaRegion.Id);
		//accountDirectI.SAP_Account_ID__c = '800';
		//accountDirectI.Account_Group__c = '0001';
		lstAccounts.add(accountDirectI);
					
		Account accountDistI = createAccount(2, 'Integrated', 'Distributor', usaRegion.Id);
		//accountDistI.SAP_Account_ID__c = '700';
		//accountDistI.Account_Group__c = '0002';
		accountDistI.ParentId = accountDirectI.Id;
		lstAccounts.add(accountDistI);			
				
		Account accountIndirectI = createAccount(3, 'Integrated', 'Indirect', usaRegion.Id);
		accountIndirectI.ParentId = accountDistI.Id;		
		lstAccounts.add(accountIndirectI);			
		
		if(!lstAccounts.isEmpty())
			insert lstAccounts;
		
		lstOpptys = new List<Opportunity>();
		opptyIndirectT = createOpportunity(accountIndirectT.Id, 4);    //Indirect, Turolla
		lstOpptys.add(opptyIndirectT);
		opptyDirectT = createOpportunity(accountDirectT.Id, 5);    //Direct, Turolla	
		lstOpptys.add(opptyDirectT);
		opptyDistT = createOpportunity(accountDistT.Id, 6);   //Distributor, Turolla 	
		lstOpptys.add(opptyDistT);
		
		opptyIndirectC = createOpportunity(accountIndirectC.Id, 7);    //Indirect, Comatrol
		lstOpptys.add(opptyIndirectC);
		opptyDirectC = createOpportunity(accountDirectC.Id, 8);    //Direct, Comatrol	
		lstOpptys.add(opptyDirectC);
		opptyDistC = createOpportunity(accountDistC.Id, 9);   //Distributor, Comatrol 	
		lstOpptys.add(opptyDistC);
		
		opptyIndirectI = createOpportunity(accountIndirectI.Id, 1);    //Indirect, Integrated
		lstOpptys.add(opptyIndirectI);
		opptyDirectI = createOpportunity(accountDirectI.Id, 2);    //Direct, Integrated	
		lstOpptys.add(opptyDirectI);
		opptyDistI = createOpportunity(accountDistI.Id, 3);   //Distributor, Integrated 	
		lstOpptys.add(opptyDistI);
		
		if(!lstOpptys.isEmpty())
			insert lstOpptys;
	}
	
	private static Account createAccount(Integer i, String busorg, String channel, Id region){
        Account account = new Account(
                                Name='Test Account Name' + i,
                                Business_Org__c = busorg,
								Channel__c = channel,
                                Country__c = region,
                                RecordTypeId = acctRecordTypeId);
        						account.OwnerId = UserInfo.getUserId();
        return account;
    }
	
    private static Opportunity createOpportunity(Id accountId, Integer i){
        Opportunity opportunity = new Opportunity(
                                Name='Test opportunity name'+i,
                                CurrencyISOCode = 'DKK',
                                AccountId = accountId,
                                StageName = 'Evaluating Need',
                                Production_Start_Date__c = Date.today().addDays(10),
                                CloseDate = Date.today().addDays(5));
        return opportunity;
    }
	
	private static void createUsers() {
		Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
		UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
		adminUser = Test_Utility.createUser(profile.Id, roles.Id, 1);
		adminUser.DelegatedApproverId = UserInfo.getUserId();
        salesRep = Test_Utility.createUser(profile.id, roles.Id, 2);
        salesRep.Business_Org__c = 'Danfoss';
        List<User> users = new List<User>();
        users.add(adminUser);
        users.add(salesRep);
        if(!users.isEmpty())
            insert users;
	}
}