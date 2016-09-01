@isTest
public class QuoteBusiness_Test {
    @TestSetup
    private static void setup() {
        /* Price Book */
        Pricebook2 pb = Test_DataFactory.create_CE_PriceBook();        
        insert pb;
        
        Product2 p = Test_DataFactory.create_CE_Product( 'My Product 0001', 'SMC-0001');
        p.Description = 'My Product 0001 - Description';
        insert p;
        
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
        
        contact c = new contact();        
        c.Academic_Title__c = 'Jedi';
        c.AccountId = account.Id;
        c.FirstName = 'Luke';
        c.LastName = 'Skywalker';
        c.Phone = '+45 12345678';
        c.Email = 'ls=danfoss.com@example.com';
        insert c;
    }
    
    public static testMethod void test_shadow_opportunity() {
        
        account a = [SELECT id, name, CurrencyIsoCode FROM account WHERE name='Danfoss'];
        
        Id pb2Id=[SELECT Id FROM Pricebook2 WHERE Name='Climate and Energy'].Id;
        
        Test.startTest();
        insert QuoteBusiness.createShadowOpportunity('Shadow Opportunity',a.Id, a.CurrencyIsoCode, UserInfo.getUserId(), pb2Id);
        Test.stopTest();
        
        opportunity o = [SELECT id, name from opportunity WHERE name='Shadow Opportunity' and recordtype.developername='Shadow_Opportunity'];
        
        System.assertEquals('Shadow Opportunity', o.name);        
         
    }
    
    
    public static testMethod void clone_quote() {
        
        account a = [SELECT id, name, CurrencyIsoCode FROM account WHERE name='Danfoss'];        
        Id pb2Id=[SELECT Id FROM Pricebook2 WHERE Name='Climate and Energy'].Id;        
        opportunity o = QuoteBusiness.createShadowOpportunity('Shadow Opportunity',a.Id, a.CurrencyIsoCode, UserInfo.getUserId(), pb2Id);
        insert o;
        
        string configitQuoteId='9876543210';
        quote q = new Quote(ConfigitQuoteId__c = configitQuoteId, OpportunityId=o.Id, Status='In Progress');
        q.name = 'QUOTE ABC';
        q.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Quote' AND developername='CE_Quote' LIMIT 1].Id;        
        q.ConfigitQuoteRev__c = 'R0';
        q.ConfigitQuoteRef__c = 'QWERTY';
        q.Valid_From__c = date.today();
        q.Valid_To__c = date.today();
        q.ExpirationDate = date.today();
        q.Price_Valid_From__c = date.today();
        q.Price_Valid_To__c = date.today();  
        q.Customer_Request_Date__c = date.today();
        q.ConfigitSyncMessage__c = 'OK';   
        q.OpportunityId = o.Id;        
        insert q;
        
        Opportunity o_target = new Opportunity();
        o_target.AccountId = a.Id;
        o_target.name ='new opportunity';   
        o_target.StageName='Open';
        o_target.CloseDate=date.today();
        insert o_target;
        q.opportunity__c=o_target.Id;   
        
        Test.startTest();
        QuoteBusiness.deepCloneQuote(q, true);
        Test.stopTest();
        
        q=[SELECT Id, ConfigitQuoteId__c, opportunityId, status, ConfigitQuoteRev__c FROM quote WHERE ConfigitQuoteId__c=:configitQuoteId];
        System.assertEquals(q.OpportunityId, o_target.Id);        
        
    }

}