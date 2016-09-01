@isTest
private class Test_QuoteClone{
    static Id StdPBId;
    static PriceBookEntry stdpbe;
    static testMethod void myUnitTest() {
       Region__c region = new Region__c(name='United States', country_code__c = 'xx');
       insert region;
       Account parent1 = Test_Utility.createAccount(1);
       parent1.SAP_Account_ID__c = '80000';
       parent1.Account_Group__c = '0001';
       insert parent1;
       Account parent2 = Test_Utility.createAccount(2);
       parent2.SAP_Account_ID__c = '70000';
       parent2.Account_Group__c = '0002';
       parent2.ParentId = parent1.Id;
       insert parent2;
       Account account = Test_Utility.createAccount(3);
       account.ParentId = parent2.Id;
       insert account;
       Opportunity oppty = Test_Utility.createOpportunity(account.Id, 1);      
       insert oppty;    
        
        Test_Utility.initTestData();   //create C&E pricebook
        Product2 p = Test_Utility.createProduct2();        
        p.Business_Unit__c = 'Motors';
        insert p;
        StdPBId = Test.getStandardPricebookId();
        stdpbe = new PricebookEntry(Pricebook2Id = StdPBId, Product2Id = p.Id, UnitPrice = 100, IsActive = true, CurrencyISOCode = 'DKK');
        insert stdpbe;
        
        Quote quote = new Quote(OpportunityId = oppty.Id, name = 'test', Pricebook2Id=StdPBId, Country_Specific_Template__c = region.id);
        insert quote;
        QuoteLineItem qli = new QuoteLineItem(QuoteId = quote.id, PricebookEntryId=stdpbe.Id, Quantity = 10, UnitPrice = 10);
        insert qli;
        Test.startTest();
        QuoteClonePageControllerExtension cont = new QuoteClonePageControllerExtension(new ApexPages.StandardController(quote));
        Apexpages.Standardcontroller stdcont = new Apexpages.Standardcontroller(quote);
       
        QuoteCloneUtility xclone = new QuoteCloneUtility();
        cont = new QuoteClonePageControllerExtension(stdcont);
        
        string fieldsNames = '';
        string recId = quote.Id; 
        String objAPIName= 'QuoteLineItem';          
        String queryString = 'select count(id) total from QuoteLineItem where QuoteId=\'' + String.escapeSingleQuotes(recId) + '\'';
        SObject result = Database.query(queryString);
        if((Integer)result.get('total')>0)
            fieldsNames = fieldsNames + objAPIName + ','; 
        list<String> selectedChildObjAPINames=New list<String>();
        if(fieldsNames.length()>0) {
            for(String childObjAPIName:fieldsNames.split(',')) {
                selectedChildObjAPINames.add(childObjAPIName);
            }
        }
        
        xclone.startsClone(quote.Id, selectedChildObjAPINames, 'number', 'name');
        PageReference pr = cont.chainClone();
        Test.stopTest();
    }
}