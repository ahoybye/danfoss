@isTest
public class Test_OpportunityProductEntryExtension {

    private static void initProductGroups() {
        Test_Utility.initTestData();
        insert new List<Product_Groups__c> {
            new Product_Groups__c(Name = 'PL06', Group_Code__c = 'PL06', Division__c = 'Commercial Compressors'),
            new Product_Groups__c(Name = 'PL12', Group_Code__c = 'PL12', Division__c = 'Refrigeration Controls'),
            new Product_Groups__c(Name = 'PL08', Group_Code__c = 'PL08', Division__c = 'District Energy'),
            new Product_Groups__c(Name = 'PL34', Group_Code__c = 'PL34', Division__c = 'Heating Solutions'),
            new Product_Groups__c(Name = 'PL09', Group_Code__c = 'PL09', Division__c = 'Danfoss Drives'),
            new Product_Groups__c(Name = 'PL99', Group_Code__c = 'PL09', Division__c = 'Heating Solutions')                
        };
    }
    
    public static testMethod void testAddProduct() {
        initProductGroups();
        Product2 product = Test_Utility.createProduct2();
        product.Business_Unit__c = 'xyzBU';
        product.isProductGroupOnly__c=true;        
        insert product;
        ID pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = Test_Utility.createPricebookEntry(product.Id, pricebookId, 'USD');
        insert pbe;
        Account account = Test_Utility.createAccount(0);
        insert account;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        opportunity.Pricebook2Id = pricebookId;
        opportunity.CurrencyIsoCode = 'USD';
        insert opportunity;
        
        Test.startTest();
        
        // Load the page
        OpportunityProductEntryExtension c = new OpportunityProductEntryExtension(new ApexPages.StandardController(opportunity));
        System.assertEquals(null, c.init());
        System.assert(ApexPages.getMessages().isEmpty());
        System.assertEquals(0, c.Total);
        System.assertEquals(0, c.shoppingCart.size());
        System.assertEquals(5, c.getDivisions().size());
        //System.assertEquals(2, c.getProductLines().size());
        
        // Search for products
        
        c.ProductLine = 'xyz*';
        c.search();
        //System.assertEquals(1, c.getAvailableProducts().size());
        
        c.ProductLine = 'xyzBU';
        c.search();
        System.assertEquals(1, c.getAvailableProducts().size());
        
        
        
        
        // Add product
        c.toSelect = c.getAvailableProducts()[0].Id;
        c.addToShoppingCart();
        System.assertEquals(0, c.getAvailableProducts().size());
        System.assertEquals(1, c.shoppingCart.size());
        System.assertEquals(0, c.Total);

        // Set quantity and price
        c.shoppingCart[0].oppLine.Quantity = 2;
        c.shoppingCart[0].oppLine.UnitPrice = 2;
        c.refreshTotals();
        System.assertEquals(4, c.Total);
        
        PageReference pr1 = c.changepricebook();
        PageReference pr2 = c.goToProductSelector();
        PageReference pr3 = c.goToProductGroupSelector();
        
        // Save changes
        PageReference pr = c.onSave();
        System.assert(ApexPages.getMessages().isEmpty());
        
        
        
        Test.stopTest();
        
        System.assertNotEquals(null, pr);
        System.assertEquals(1, [select Id from OpportunityLineItem].size());
    }
    
    public static testMethod void testRemoveProduct() {
        initProductGroups();
        Product2 product = Test_Utility.createProduct2();
        product.Business_Unit__c = 'xyzBU';
        insert product;
        ID pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = Test_Utility.createPricebookEntry(product.Id, pricebookId, 'USD');
        insert pbe;
        Account account = Test_Utility.createAccount(0);
        insert account;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        opportunity.Pricebook2Id = pricebookId;
        opportunity.CurrencyIsoCode = 'USD';
        insert opportunity;
        OpportunityLineItem oli = Test_Utility.createOpportunityLineItem(opportunity.Id, pbe.Id, 0);
        oli.Quantity = 2;
        oli.TotalPrice = 4;
        insert oli;
        
        Test.startTest();
        
        // Load the page
        OpportunityProductEntryExtension c = new OpportunityProductEntryExtension(new ApexPages.StandardController(opportunity));
        System.assertEquals(null, c.init());
        System.assert(ApexPages.getMessages().isEmpty());
        System.assertEquals(4, c.Total);
        System.assertEquals(1, c.shoppingCart.size());
        c.getDivisions();
        c.getProductLines();
        
        // Remove product
        c.toUnselect = c.shoppingCart[0].oppLine.PriceBookEntryId;
        c.removeFromShoppingCart();
        System.assertEquals(0, c.shoppingCart.size());
        System.assertEquals(0, c.Total);
        
        // Save changes
        PageReference pr = c.onSave();
        System.assert(ApexPages.getMessages().isEmpty());
        
        Test.stopTest();
        
        System.assertNotEquals(null, pr);
        System.assertEquals(0, [select Id from OpportunityLineItem].size());
    }
    
    public static testMethod void testSelectPricebook() {
        initProductGroups();
        Pricebook2 pb = [select Id from Pricebook2 where Name = 'Climate and Energy'];
        Account account = Test_Utility.createAccount(0);
        insert account;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        opportunity.CurrencyIsoCode = 'USD';
        insert opportunity;
        
        Test.startTest();
        
        // Load the page
        OpportunityProductEntryExtension c = new OpportunityProductEntryExtension(new ApexPages.StandardController(opportunity));
        System.assertEquals(null, c.init());
        System.assert(ApexPages.getMessages().isEmpty());
        
        Test.stopTest();
        
        System.assertEquals(pb.Id, opportunity.Pricebook2Id);
        System.assertEquals(pb.Id, [select Pricebook2Id from Opportunity].Pricebook2Id);
    }
    
    public static testMethod void testFetchPrices() {
        initProductGroups();
        insert new List<SAP_Integration__c> {
            new SAP_Integration__c(Name = 'CE_User', Value__c = 'test'),
            new SAP_Integration__c(Name = 'CE_Password', Value__c = 'test'),
            new SAP_Integration__c(Name = 'CE_URL', Value__c = 'test')
        };
        Product2 product = Test_Utility.createProduct2();
        product.Business_Unit__c = 'xyzBU';
        insert product;
        ID pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = Test_Utility.createPricebookEntry(product.Id, pricebookId, 'USD');
        insert pbe;
        Sales_Area_Master__c salesAreaMaster = new Sales_Area_Master__c(
            Sales_Org__c = 'a',
            Channel__c = 'b',
            Division__c = 'c'
        );
        insert salesAreaMaster;
        Account account = Test_Utility.createAccount(0);
        insert account;
        Sub_Account__c subAccount = new Sub_Account__c(
            Account__c = account.Id,
            SAP_Account_ID__c = 'SAP1234'
        );
        insert subAccount;
        Sales_Area__c salesArea = new Sales_Area__c(
            Sales_Area_Master__c = salesAreaMaster.Id,
            Sales_Area_Master__r = salesAreaMaster,
            Sub_Account__c = subAccount.Id,
            Sub_Account__r = subAccount
        );
        insert salesArea;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        opportunity.Pricebook2Id = pricebookId;
        opportunity.CurrencyIsoCode = 'USD';
        //opportunity.Sub_Account__c = subAccount.Id;
        //opportunity.Sales_Area__c = salesArea.Id;
        //opportunity.Sales_Area__r = salesArea;
        insert opportunity;
        OpportunityLineItem oli = Test_Utility.createOpportunityLineItem(opportunity.Id, pbe.Id, 0);
        oli.Quantity = 2;
        oli.TotalPrice = 4;
        insert oli;
        
        Test.setMock(WebServiceMock.class, new Test_SAP_CEPriceWsdlMock());
        
        Test.startTest();
        
        // Load the page
        OpportunityProductEntryExtension c = new OpportunityProductEntryExtension(new ApexPages.StandardController(opportunity));
        System.assertEquals(null, c.init());
        System.assert(ApexPages.getMessages().isEmpty());
        System.assertEquals(4, c.Total);
        System.assertEquals(1, c.shoppingCart.size());
        c.getDivisions();
        c.getProductLines();
        
        // Fetch prices
        c.fetchPrices();
        
        Test.stopTest();
        
        System.assert(!ApexPages.hasMessages(), ApexPages.getMessages());
        System.assertEquals(1, c.shoppingCart.size());
        System.assertEquals(33, c.shoppingCart[0].oppLine.UnitPrice);
        System.assertEquals(66, c.Total);
        System.assertEquals(salesArea.Id, opportunity.Sales_Area__c); // Only one available sales area, should be selected automatically
    }
}