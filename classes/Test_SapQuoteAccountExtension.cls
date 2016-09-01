@isTest
public class Test_SapQuoteAccountExtension {
    
    public static testMethod void testWithSubAccounts() {
        insert new SAP_URLs__c(SetupOwnerId = UserInfo.getOrganizationId(), Create_SAP_CRM_Quote_URL__c = 'test={SAPID}');
        insert new Region__c(Name = 'Germany', Country_Code__c = 'DE');
        Account account = Test_Utility.createAccount(0);
        insert account;
        Sub_Account__c s1 = new Sub_Account__c(Account__c = account.Id, SAP_Account_ID__c = '123');
        insert s1;
        
        Test.startTest();
        
        SapQuoteAccountExtension c = new SapQuoteAccountExtension(new ApexPages.StandardController(account));
        System.assertEquals(null, c.init());
        System.assertEquals(1,c.getDiv().size());
        c.selectedDD = c.getDiv()[0].Id;
        PageReference pr = c.CreateQuote();
        
        Test.stopTest();
        
        System.assertNotEquals(null, pr);
    }
    
    public static testMethod void testWithoutSubAccounts() {
        insert new SAP_URLs__c(SetupOwnerId = UserInfo.getOrganizationId(), Create_SAP_CRM_Quote_URL__c = 'test={SAPID}');
        insert new Region__c(Name = 'Germany', Country_Code__c = 'DE');
        Account account = Test_Utility.createAccount(0);
        insert account;
        
        Test.startTest();
        
        SapQuoteAccountExtension c = new SapQuoteAccountExtension(new ApexPages.StandardController(account));
        PageReference pr = c.init();
        
        Test.stopTest();
        
        System.assertNotEquals(null, pr);
    }
    
}