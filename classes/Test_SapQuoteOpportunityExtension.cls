@isTest
public class Test_SapQuoteOpportunityExtension {
    
    static testMethod void testBlankSubAccount() {
        insert new SAP_URLs__c(SetupOwnerId = UserInfo.getOrganizationId(), Create_SAP_CRM_Quote_URL__c = 'test={SAPID}');
        insert new Region__c(Name = 'Germany', Country_Code__c = 'DE');
        Account account = Test_Utility.createAccount(0);
        insert account;
        Sub_Account__c s1 = new Sub_Account__c(Account__c = account.Id, SAP_Account_ID__c = '123');
        insert s1;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        insert opportunity;
        
        Test.startTest();
        
        SapQuoteOpportunityExtension c = new SapQuoteOpportunityExtension(new ApexPages.StandardController(opportunity));
        System.assertEquals(null, c.init());
        System.assertEquals(1,c.getDiv().size());
        c.selectedDD = c.getDiv()[0].Id;
        PageReference pr = c.CreateQuote();
        
        Test.stopTest();
        
        System.assertNotEquals(null, pr);
        System.assertEquals(s1.Id, [select Sub_Account__c from Opportunity].Sub_Account__c);
    }
    
    static testMethod void testNotBlankSubAccount() {
        insert new SAP_URLs__c(SetupOwnerId = UserInfo.getOrganizationId(), Create_SAP_CRM_Quote_URL__c = 'test={SAPID}');
        insert new Region__c(Name = 'Germany', Country_Code__c = 'DE');
        Account account = Test_Utility.createAccount(0);
        insert account;
        Sub_Account__c s1 = new Sub_Account__c(Account__c = account.Id, SAP_Account_ID__c = '123');
        insert s1;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        opportunity.Sub_Account__c = s1.Id;
        insert opportunity;
        
        Test.startTest();
        
        SapQuoteOpportunityExtension c = new SapQuoteOpportunityExtension(new ApexPages.StandardController(opportunity));
        PageReference pr = c.init();
        
        Test.stopTest();
        
        System.assertNotEquals(null, pr);
    }
    
    static testMethod void testWithoutSubAccount() {
        insert new SAP_URLs__c(SetupOwnerId = UserInfo.getOrganizationId(), Create_SAP_CRM_Quote_URL__c = 'test={SAPID}');
        insert new Region__c(Name = 'Germany', Country_Code__c = 'DE');
        Account account = Test_Utility.createAccount(0);
        insert account;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        insert opportunity;
        
        Test.startTest();
        
        SapQuoteOpportunityExtension c = new SapQuoteOpportunityExtension(new ApexPages.StandardController(opportunity));
        PageReference pr = c.init();
        
        Test.stopTest();
        
        System.assertNotEquals(null, pr);
    }
    
}