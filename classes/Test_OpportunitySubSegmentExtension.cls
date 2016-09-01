@isTest
public class Test_OpportunitySubSegmentExtension {
    
    static testMethod void testSecondarySubSegment() {
        Account account = Test_Utility.createAccount(0);
        account.Segment__c = 'prim-seg';
        account.Sub_Segment__c = 'prim-subseg';
        account.Secondary_Segment__c = 'sec-seg';
        account.Secondary_Sub_Segment__c = 'sec-subseg';
        insert account;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        opportunity.Account = account;
        insert opportunity;
        
        Test.startTest();
        
        OpportunitySubSegmentExtension c = new OpportunitySubSegmentExtension(new ApexPages.StandardController(opportunity));
        c.SecondarySubSegment();
        
        Test.stopTest();
        
        System.assertEquals(true, c.renderdirect);
        Opportunity opp2 = [select Chosen_Sub_Segment__c, Secondary_Segment__c from Opportunity where Id = :opportunity.Id];
        System.assertEquals('sec-subseg', opp2.Chosen_Sub_Segment__c);
        System.assertEquals(true, opp2.Secondary_Segment__c);
    }
    
    static testMethod void testPrimarySubSegment() {
        Account account = Test_Utility.createAccount(0);
        account.Segment__c = 'prim-seg';
        account.Sub_Segment__c = 'prim-subseg';
        account.Secondary_Segment__c = 'sec-seg';
        account.Secondary_Sub_Segment__c = 'sec-subseg';
        insert account;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        opportunity.Account = account;
        insert opportunity;
        
        Test.startTest();
        
        OpportunitySubSegmentExtension c = new OpportunitySubSegmentExtension(new ApexPages.StandardController(opportunity));
        c.PrimarySubSegment();
        
        Test.stopTest();
        
        System.assertEquals(true, c.renderdirect);
        Opportunity opp2 = [select Chosen_Sub_Segment__c, Secondary_Segment__c from Opportunity where Id = :opportunity.Id];
        System.assertEquals('prim-subseg', opp2.Chosen_Sub_Segment__c);
        System.assertEquals(false, opp2.Secondary_Segment__c);
    }
    
}