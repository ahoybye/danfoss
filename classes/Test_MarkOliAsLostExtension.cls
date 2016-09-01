@isTest
public class Test_MarkOliAsLostExtension {
	static Id StdPBId;
	static PriceBookEntry stdpbe;
    
    public static testMethod void testMoveToLost() {
        Test_Utility.initTestData();
        Account account = Test_Utility.createAccount(0);
        insert account;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        insert opportunity;
        Product2 p = Test_Utility.insertProduct2();        		
		StdPBId = Test.getStandardPricebookId();
		stdpbe = new PricebookEntry(Pricebook2Id = StdPBId, Product2Id = p.Id, UnitPrice = 100, IsActive = true, CurrencyISOCode = 'DKK');
		insert stdpbe;
        OpportunityLineItem oli = Test_Utility.createOpportunityLineItem(opportunity.Id, stdpbe.Id, 0);
        insert oli;
        
        Test.startTest();
        
        MarkOliAsLostExtension c = new MarkOliAsLostExtension(new ApexPages.StandardController(oli));
        PageReference pr = c.moveToLost();
        
        Test.stopTest();
        
        System.assertNotEquals(null, pr);
        System.assertEquals(0, [select Id from OpportunityLineItem].size());
        System.assertEquals(1, [select Id from Opportunity_Lost_Product__c].size());
    }
    
}