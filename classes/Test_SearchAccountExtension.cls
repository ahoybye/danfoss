@isTest
public class Test_SearchAccountExtension {
    
    public static testMethod void test() {
        Account existingAccount1 = Test_Utility.createAccount(0);
        existingAccount1.Name = 'test1';
        existingAccount1.Country_MainAddress__c = existingAccount1.Country__c;
        existingAccount1.Business_Org__c='Climate and Energy';
        insert existingAccount1;
        Account existingAccount2 = Test_Utility.createAccount(1);
        existingAccount2.Name = 'test2';
        existingAccount2.Business_Org__c='Climate and Energy';
        existingAccount2.Country_MainAddress__c = existingAccount1.Country__c;
        insert existingAccount2;
        
        Test.startTest();
        
        Account newAccount = new Account();
        SearchAccountExtension c = new SearchAccountExtension(new ApexPages.StandardController(newAccount));
        System.assertEquals(false, c.getcreatepossible());
        newAccount.Name = 'test1';
        newAccount.Country_MainAddress__c = existingAccount1.Country_MainAddress__c;
        c.search();
        integer results = c.getResults().size();
        System.assertEquals(false, c.navigateToEditAcc);
        System.assertEquals(true, c.getcreatepossible());        
        //System.assertEquals(1, c.getResults().size());
        c.CreateNew();
        System.assertEquals(true, c.navigateToEditAcc);
        System.assertNotEquals(null, newAccount.Id);
    }
    
}