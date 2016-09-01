@isTest
public class RestQuoteController_Test {
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
        
        Opportunity opp2 = new Opportunity();
        opp2.accountId = account.Id;
        opp2.Name = 'My Test Opportunity II';
        opp2.Sub_Account__c = sa.Id;
        opp2.Sales_Area__c = sao.Id;
        opp2.RecordTypeId = [SELECT Id FROM recordtype WHERE sObjectType='Opportunity' and DeveloperName = 'CE_Opportunity' and IsActive=true LIMIT 1].Id;
        opp2.CurrencyIsoCode = 'USD';
        opp2.Amount  = 5000;
        opp2.Contact__c = c.id;
        opp2.CloseDate = Date.today();
        opp2.StageName = 'Initiated';        
        insert opp2;
    }
        
    public static testMethod void test_with_opportunity() {
        
        // API user - for calling REST methods (some validation rules only allow for updates by an API profile)
        Profile profile = [SELECT Id FROM Profile WHERE Name='API Only User (CE)'];
        User apiUser = new User(Alias = 'APIusr18', Email='apiuser18@example.com',
        EmailEncodingKey='UTF-8', LastName='APIusr18', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = profile.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='apiuser18@example.com');

        Opportunity opp = [SELECT id, AccountId, Contact__c FROM Opportunity WHERE name = 'My Test Opportunity' limit 1];        
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        req.requestURI = baseURL + '/services/apexrest/RestInterfaceQuote/';  
        req.httpMethod = 'POST';
        //req.requestBody = '';
        RestContext.request = req;
        RestContext.response = res;

        // to be inserted
        RestQuoteController.QLI qli = new RestQuoteController.QLI();
        
        qli.materialID = 'SMC-0001'; //SAP material code for product 
        qli.description = 'Material from SAP';
        qli.quantity = 10;
        qli.discount=0;
        qli.unitPrice = 100;
        qli.totalValue = 1000;
        
        RestQuoteController.serviceResult A_result;
        RestQuoteController.serviceResult C_result;
        RestQuoteController.serviceResult D_result;
        Test.startTest();
        
        System.runAs(apiUser) {
    
            // Test with existing opportunity
            qli.configitLineId = 'A-qli-1';            
            A_result = RestQuoteController.createQuote('A-12345678', '0', 'QWERTY', 'Quote with Oppty', opp.accountId, opp.Id, opp.Contact__c, '23456789', '','2300', '00', '00', 'USD', Date.today(), Date.today(), Date.today(), Date.today(), Date.today(), '', '', '', new RestQuoteController.QLI[] {qli});            
            System.assertEquals('OK', A_result.status, A_result.message);
            
            
            // Set quote status to sent - and check that it cannot be updated with same revision            
            A_result.quote.Status='Sent';
            update A_result.quote;
            qli.configitLineId = 'C-qli-1';            
            C_result = RestQuoteController.createQuote('A-12345678', '0', 'QWERTY', 'Quote with Oppty', opp.accountId, opp.Id, opp.Contact__c, '23456789', '','2300', '00', '00', 'USD', Date.today(), Date.today(), Date.today(), Date.today(), Date.today(), '', '', '', new RestQuoteController.QLI[] {qli});            
            
            
            // Verify that it is OK - with updated revision number
            qli.configitLineId = 'D-qli-1';            
            D_result = RestQuoteController.createQuote('A-12345678', '1', 'QWERTY', 'Quote with Oppty', opp.accountId, opp.Id, opp.Contact__c, '23456789', '','2300', '00', '00', 'USD', Date.today(), Date.today(), Date.today(), Date.today(), Date.today(), '', '', '', new RestQuoteController.QLI[] {qli});
            
                      
        }                

        // TEST PUT METHOD - FOR UPLOADING DOCUMENTS
        req.params.clear();
        req.httpMethod = 'PUT';
        req.addParameter('opportunityId', 'A-12345678');
        req.addParameter('configitQuoteId', 'A-12345678');
        req.addParameter('configitRevisionId', '1');
        req.addParameter('extension', 'pdf');
        req.addParameter('type', 'print');        
        req.requestBody =  Blob.valueof('%PDF-1.5');
        RestContext.request = req;
        RestContext.response = res;
        
        System.runAs(apiUser) {            
            quote q_result = RestQuoteController.addQuoteDocument();            
        }
        
        Test.stopTest();  
        
        System.assertEquals('A-12345678', A_result.quote.ConfigitQuoteId__c);
        System.assertNotEquals('OK', C_result.status, C_result.message);
        System.assertEquals('OK', D_result.status, D_result.message);
    }

    public static testMethod void test_without_opportunity() {
        
        // API user - for calling REST methods (some validation rules only allow for updates by an API profile)
        Profile profile = [SELECT Id FROM Profile WHERE Name='API Only User (CE)'];
        User apiUser = new User(Alias = 'APIusr18', Email='apiuser18@example.com',
        EmailEncodingKey='UTF-8', LastName='APIusr18', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = profile.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='apiuser18@example.com');
        
        Contact c = [SELECT id, AccountId FROM contact WHERE lastname = 'Skywalker' limit 1];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        req.requestURI = baseURL + '/services/apexrest/RestInterfaceQuote/';  
        req.httpMethod = 'POST';
        //req.requestBody = '';
        RestContext.request = req;
        RestContext.response = res;

        // to be inserted
        RestQuoteController.QLI qli = new RestQuoteController.QLI();
        
        qli.materialID = 'SMC-0001'; //SAP material code for product 
        qli.description = 'Material from SAP';
        qli.quantity = 10;
        qli.discount=0;
        qli.unitPrice = 100;
        qli.totalValue = 1000;
        
        RestQuoteController.serviceResult B_result;
        RestQuoteController.serviceResult E_result;
        Test.startTest();
        System.runAs(apiUser) {
               
            // Test without opportunity
            qli.configitLineId = 'B-qli-1';
            
            B_result = RestQuoteController.createQuote('B-12345678', '0', 'QWERTY', 'Quote - No Oppty', c.accountId, '', c.Id, '23456789', '','2300', '00', '00', 'USD', Date.today(), Date.today(), Date.today(), Date.today(), Date.today(), '', '', '12345', new RestQuoteController.QLI[] {qli});           
        }
        
        // TEST GET METHOD 
        req.params.clear();
        req.httpMethod = 'GET';
        req.addParameter('configitQuoteId', 'B-12345678');
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(apiUser) {            
            E_result = RestQuoteController.getQuoteData();          
        }
        Test.stopTest();
        
        System.assertEquals('OK', B_result.status, B_result.message);
        System.assertEquals('B-12345678', B_result.quote.ConfigitQuoteId__c);
        System.assertEquals('OK', E_result.status, E_result.message);
    }      
}