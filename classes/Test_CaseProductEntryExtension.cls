@isTest
public class Test_CaseProductEntryExtension {
    
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
        insert product;
        Case theCase = new Case();
        insert theCase;
        
        Test.startTest();
        
        // Load the page
        CaseProductEntryExtension c = new CaseProductEntryExtension(new ApexPages.StandardController(theCase));
        c.init();
        System.assert(ApexPages.getMessages().isEmpty());
        System.assertEquals(0, c.shoppingCart.size());
        System.assertEquals(5, c.getDivisions().size());
        System.assertEquals(1, c.getProductLines().size());
        
        // Search for products
        c.ProductLine = 'xyzBU';
        c.search();
        System.assertEquals(1, c.getAvailableProducts().size());
        
        // Add product
        c.toSelect = c.getAvailableProducts()[0].Id;
        c.addToShoppingCart();
        System.assertEquals(0, c.getAvailableProducts().size());
        System.assertEquals(1, c.shoppingCart.size());
        
        // Set quantity
        c.shoppingCart[0].Quantity__c = 2;
        
        // Save changes
        c.onSave();
        System.assert(ApexPages.getMessages().isEmpty());
        
        Test.stopTest();
        
        System.assertEquals(true, c.backToCase);
        System.assertEquals(1, [select Id from Case_Product__c].size());
    }
    
    public static testMethod void testRemoveProduct() {
        initProductGroups();
        Product2 product = Test_Utility.createProduct2();
        product.Business_Unit__c = 'xyzBU';
        insert product;
        Case theCase = new Case();
        insert theCase;
        Case_Product__c cp = new Case_Product__c(Case__c = theCase.Id, Product__c = product.Id, Quantity__c = 2);
        insert cp;
        
        Test.startTest();
        
        // Load the page
        CaseProductEntryExtension c = new CaseProductEntryExtension(new ApexPages.StandardController(theCase));
        c.init();
        System.assert(ApexPages.getMessages().isEmpty());
        System.assertEquals(1, c.shoppingCart.size());
        c.getDivisions();
        c.getProductLines();
        
        // Remove product
        c.toUnselect = c.shoppingCart[0].Product__c;
        c.removeFromShoppingCart();
        System.assertEquals(0, c.shoppingCart.size());
        
        // Save changes
        c.onSave();
        System.assert(ApexPages.getMessages().isEmpty());
        
        Test.stopTest();
        
        System.assertEquals(true, c.backToCase);
        System.assertEquals(0, [select Id from Case_Product__c].size());
    }
    
}