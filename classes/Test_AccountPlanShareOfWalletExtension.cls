@isTest
public class Test_AccountPlanShareOfWalletExtension {
    
    static testMethod void test() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Account_Plan__c ap = new Account_Plan__c(Account__c = account.Id);
        insert ap;
        
        Test.startTest();
        
        AccountPlanShareOfWalletExtension c = new AccountPlanShareOfWalletExtension(new ApexPages.StandardController(ap));
        c.init();
        c.getSoW();
        c.getSoWComp();
        
        Test.stopTest();
        
        System.assertNotEquals(null, c.SoWSum);
        System.assertNotEquals(null, c.SoWSumComp);
        // We are just initializing standard controllers, not much to assert
    }
    
}