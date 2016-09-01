//@isTest
public with sharing class Test_CheckOpptyProductCompTrigger {
 /*public static testMethod void testInit() {
        Account acct = Test_Utility.createAccount(1);
        insert acct;
        
        Product2 p1 = new Product2(
        name='tstprod',
        IsActive=true,
        Description='My Product',
        ProductCode='0723',
        CurrencyIsoCode='USD'
        );
        
        insert p1;       
      
        Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];
        stdPb.IsActive = true;
        update stdPb;       
        PriceBookEntry pbe = [select Id, UnitPrice from PriceBookEntry where Product2Id = :p1.Id and Pricebook2Id = :stdPb.Id and CurrencyISOCode = 'USD'];//Test_Utility.createPricebookEntry(p.Id, stdPb.Id, 'USD'); 
        
	 	Sales_Org__c so = new Sales_Org__c(Name = '1500', SAP_Sales_Org__c = '1500', Account__c = acct.Id);  
        insert so;
        Test.StartTest();
        Opportunity oppty = new Opportunity(AccountId = acct.Id, name = 'tstoppty2', Sales_Org__c = so.Id, Production_Start_Date__c = Date.Today(), stagename = 'Evaluating Need', CloseDate = Date.Today().addDays(-5), CurrencyIsoCode='USD');
        insert oppty;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppty.Id, TotalPrice = 1, Quantity = 23,PricebookEntryId=pbe.id);
        insert oli;


        oli = new OpportunityLineItem(OpportunityId = oppty.Id, TotalPrice = 1, Quantity = 23,PricebookEntryId=pbe.id, Competitor__c = '');
        insert oli;
        
        oppty = new Opportunity(AccountId = acct.Id, name = 'tstoppty3', Sales_Org__c = so.Id, Production_Start_Date__c = Date.Today(), stagename = 'Evaluating Need', Reason_Won_Lost__c = 'Price',Reason_Description__c ='Competition', CloseDate = Date.Today().addDays(-5), CurrencyIsoCode = 'USD');
        insert oppty;
        oli = new OpportunityLineItem(OpportunityId = oppty.Id, TotalPrice = 1, Quantity = 23,PricebookEntryId=pbe.id, Competitor__c = 'Bosch Rexroth', Approx_Competitor_Price__c = 1);
        insert oli;
        oppty.StageName='Closed Won';
        update oppty;
        Test.StopTest();
 }*/
}