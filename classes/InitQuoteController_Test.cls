@isTest
public class InitQuoteController_Test {

 	public static testMethod void test() {
		/* Price Book */
        Pricebook2 pb = Test_DataFactory.create_CE_PriceBook();        
        insert pb;
        
        /* Create CE Customer */        
        Account account = Test_DataFactory.create_CE_Customer('Danfoss', 'USD', 'DK', 'CER');
        account.ShippingCountry = 'DK';
        account.ShippingPostalCode = '6430';
        account.ShippingCity = 'Nordborg';
        account.ShippingStreet = 'Nordborgvej 81';        
        insert account;
                
        Sales_Area_Master__c sam = Test_DataFactory.create_SalesAreaMaster('2300','00','00');
        insert sam;
                        
        Sub_Account__c sa = Test_DataFactory.create_SubAccount(account.name, '23456789', account);
        insert sa;
        
        Sales_Area__c sao = Test_DataFactory.create_salesArea(sa, sam);
        insert sao;               
        
        Test_DataFactory.setMaster(account, sa);        
        update account;
        
        contact c = new contact();        
        c.Academic_Title__c = 'Jedi';
        c.AccountId = account.Id;
        c.FirstName = 'Luke';
        c.LastName = 'Skywalker';
        c.Phone = '+45 12345678';
        c.Email = 'ls=danfoss.com@example.com';
        insert c;
        
        Case ca = new Case();
        ca.Subject = 'My Case';
        ca.AccountId = account.Id;
        ca.Business_Org__c = account.Business_Org__c;
        ca.ContactId = c.Id;
        ca.RecordTypeId = [SELECT Id FROM recordtype WHERE sObjectType='Case' and DeveloperName = 'Product_Inquiry' and IsActive=true LIMIT 1].Id;
        insert ca;
                
        InitQuoteController.createOpptyAndRedirect('CASE',ca.id);        
        InitQuoteController.createOpptyAndRedirect('CONTACT',c.id);
        
	 }
    
}