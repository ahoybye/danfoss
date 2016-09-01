@isTest(SeeAllData=true)
private class Test_AddProducts {
    
    static testMethod void testSearchProduct() {
           Account account = Test_Utility.createAccount(1);
      insert account; 
      Pricebook2 pricebook= [SELECT Id FROM PriceBook2 WHERE IsStandard=True];
      pricebook.IsActive = true;
      update pricebook;
      Pricebook2 pricebook1 = [SELECT Id FROM PriceBook2 WHERE NAME = 'Danfoss'];        
      
      Opportunity oppty = Test_Utility.createOpportunity(account.Id, 1);
      oppty.currencyIsoCode = 'USD';
      insert oppty;  
      Product2 product = Test_Utility.insertProduct2();
      PriceBookEntry pbe = [select Id, UnitPrice from PriceBookEntry where Product2Id = :product.Id and Pricebook2Id = :pricebook.Id and CurrencyISOCode = 'USD']; 
    
      pbe = Test_Utility.createPricebookEntry(product.Id, pricebook1.Id, 'USD'); 
      insert pbe; 
      
      Region__c reg = [select Id From Region__c limit 1];
      Quote q = new Quote(name='Erin test quote', OpportunityId = Oppty.Id, Country_Specific_Template__c = reg.Id);
      insert q;
      Customer_Part_Number__c cpn = new Customer_Part_Number__c();
      cpn.Account__c = account.Id;
      cpn.Material_Number__c = '12345-ABCDE';
      cpn.Product__c = product.Id;
      cpn.SAP_Customer_Material_Id__c = 'qwerty';
      insert cpn;
      Exclusive_Material__c em = new Exclusive_Material__c();
      em.Account__c = account.Id;
      em.Product__c = product.Id;
      em.SAP_Exclusive_Material_Id__c = '1234';
      insert em;
        PageReference pg = Page.AddOpportunityProduct;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id',oppty.Id);
        ApexPages.currentPage().getParameters().put(product.Id,'1'); 
        AddProducts add = new AddProducts();
        add.Name = 'TestProduct*';
        add.ProductCode = 'x';
        add.Model_Code = 'x';
        add.Family = 'x';
        add.ProductSet = 'x';
        add.ProductLine = 'x';
        add.doSort();
        add.Search();
        add.SelectProduct(); 
        add.cancel();
              PageReference pgq = Page.AddQuoteProduct;
              Test.setCurrentPage(pgq);
              ApexPages.currentPage().getParameters().put('id',q.Id);
              ApexPages.currentPage().getParameters().put(product.Id,'1'); 
              add = new AddProducts();
              add.Name = 'TestProduct*';
              add.doSort();        
              add.Search();
              add.SelectProduct();      
              add.cancel();
           /*   AddLDIProducts addldi = new AddLDIProducts();
              addldi.Name = 'TestProduct*';
              addldi.doSort();
              addldi.Search();
              addldi.SelectProduct();      
              addldi.cancel();*/
      
    }  
}