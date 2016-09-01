@isTest (seealldata=true)
private class Test_AttachmentGenerator {

    static testMethod void myUnitTest() {
        AttachmentGenerator ag = new AttachmentGenerator();
        Account account = Test_Utility.createAccount(1);
		  account.Sales_Manager__c = UserInfo.getUserId();
		  insert account;
		  Opportunity oppty = Test_Utility.createOpportunity(account.Id, 1);
		  oppty.currencyIsoCode = 'USD';
		  insert oppty;     
		  Pricebook2 pricebook1 = [SELECT Id FROM PriceBook2 WHERE NAME = 'Danfoss'];
		  Region__c reg = [select Id From Region__c limit 1];
		  Quote quote = new Quote(OpportunityId = oppty.Id,Name='qli',PriceBook2Id = pricebook1.Id, Country_Specific_Template__c = reg.Id);
		  insert quote; 
        
        PageReference pageRef = new PageReference('/apex/QuotePDF?Id='+quote.Id);
        Blob content = blob.valueof('p');
        AttachmentGenerator.AttachPDFToQuote(quote.Id);
        AttachmentGenerator.SaveAndEmail(quote.Id);
    }
}