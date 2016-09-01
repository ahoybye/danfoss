@isTest
public class Test_SapQuoteStakeholderExtension {
    
    static testMethod void testBlankSubAccount() {
        insert new SAP_URLs__c(SetupOwnerId = UserInfo.getOrganizationId(), Create_SAP_CRM_Quote_URL__c = 'test={SAPID}');
        insert new Region__c(Name = 'Germany', Country_Code__c = 'DE');
        Account account = Test_Utility.createAccount(0);
        insert account;
        Sub_Account__c s1 = new Sub_Account__c(Account__c = account.Id, SAP_Account_ID__c = '123');
        insert s1;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        insert opportunity;
        Associated_Account__c stakeholder = new Associated_Account__c(Associated_Account__c = account.Id, Project_Opportunity__c = opportunity.Id );
        insert stakeholder;        
        
        Test.startTest();
        
        SapQuoteStakeholderExtension c = new SapQuoteStakeholderExtension(new ApexPages.StandardController(stakeholder));
        System.assertEquals(null, c.init());
        System.assertEquals(1,c.getDiv().size());
        c.selectedDD = c.getDiv()[0].Id;
        PageReference pr = c.CreateQuote();
        
        Test.stopTest();
        
        System.assertNotEquals(null, pr);
        System.assertEquals(s1.Id, [select SubAccount__c from Associated_Account__c].SubAccount__c);
    }
    
    static testMethod void testNotBlankSubAccount() {
        insert new SAP_URLs__c(SetupOwnerId = UserInfo.getOrganizationId(), Create_SAP_CRM_Quote_URL__c = 'test={SAPID}');
        insert new Region__c(Name = 'Germany', Country_Code__c = 'DE');
        Account account = Test_Utility.createAccount(0);
        insert account;
        Sub_Account__c s1 = new Sub_Account__c(Account__c = account.Id, SAP_Account_ID__c = '123');
        insert s1;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        insert opportunity;
        Associated_Account__c stakeholder = new Associated_Account__c(Associated_Account__c = account.Id, Project_Opportunity__c = opportunity.Id );
        stakeholder.SubAccount__c = s1.Id;
        insert stakeholder;   
        
        Test.startTest();
        
        SapQuoteStakeholderExtension c = new SapQuoteStakeholderExtension(new ApexPages.StandardController(stakeholder));
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
        Associated_Account__c stakeholder = new Associated_Account__c(Associated_Account__c = account.Id, Project_Opportunity__c = opportunity.Id );
        insert stakeholder;  
        
        Test.startTest();
        
        SapQuoteStakeholderExtension c = new SapQuoteStakeholderExtension(new ApexPages.StandardController(stakeholder));
        PageReference pr = c.init();
        
        Test.stopTest();
        
        System.assertNotEquals(null, pr);
    }
    
}