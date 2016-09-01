@isTest
public class QuoteTabController_Test {

    public static testMethod void test_QuoteTab() {
		Quote q = createTestData();
        
        Task t = new Task();        
        t.Subject = 'My Follow-up task';
        t.ActivityDate = Date.today();        
        t.WhatId = q.Id;
        insert t;
        
        QuoteTabController qtc = new QuoteTabController();
        
        for (SelectOption o : qtc.listViewOptions) {
        	qtc.selectedListView = o.getValue();
        	qtc.getQuotes();    
        }        
        
    }
    
    public static quote createTestData () {
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
        c.Academic_Title__c = 'Professor';
        c.AccountId = account.Id;
        c.FirstName = 'Anders';
        c.LastName = 'Breinholt';
        c.Phone = '+45 12345678';
        c.Email = 'ab=danfoss.com@example.com';
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.accountId = account.Id;
        opp.Name = 'My Test Opportunity';
        opp.Sub_Account__c = sa.Id;
        opp.Sales_Area__c = sao.Id;
        opp.RecordTypeId = [SELECT Id FROM recordtype WHERE sObjectType='Opportunity' and DeveloperName = 'CE_Opportunity' and IsActive=true LIMIT 1].Id;
        opp.CurrencyIsoCode = 'USD';
        opp.Amount  = 5000;
        opp.Contact__c = c.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Initiated';        
        insert opp;
        
        Quote q = new Quote(ConfigitQuoteId__c = '012345678', OpportunityId=opp.Id, Status='In Progress');
        q.RecordTypeId = [SELECT Id FROM recordtype WHERE sObjectType='Quote' and DeveloperName = 'CE_Quote' and IsActive=true LIMIT 1].Id;
		q.ConfigitQuoteRev__c = 'R1';
		q.ExpirationDate = Date.today(); 
        q.Name= 'My Test Quote';
        q.Status = 'In Progress';
		q.ContactId=c.Id;
        q.Custom_Account_Lookup__c=account.Id;
        q.Sub_Account__c = sa.Id;
		q.Pricebook2Id = pb.Id;
        q.Responsible__c = UserInfo.getUserId();
		insert q;
               
        
        return q;
    }
}