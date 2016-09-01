@isTest
public class Test_OpportunityCloseExtension {
    
    static testMethod void test() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        opportunity.CE_Division__c = 'Heating';
        insert opportunity;
        
        Test.startTest();
        
        OpportunityCloseExtension c = new OpportunityCloseExtension(new ApexPages.StandardController(opportunity));
        opportunity.CE_HS_Sub_reason__c = 'xyz';
        PageReference pr = c.closeOpp();
        
        Test.stopTest();
        
        System.assert(ApexPages.getMessages().isEmpty());
        System.assertNotEquals(null, pr);
        System.assertEquals('xyz', [select Sub_reason__c from Opportunity].Sub_reason__c);
    }
    
}