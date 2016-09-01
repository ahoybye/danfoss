@isTest
public class Test_AccountFilterExtension {
    
    public static testMethod void test() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Sub_Account__c s1 = new Sub_Account__c(Account__c = account.Id, Division__c = 'a');
        Sub_Account__c s2 = new Sub_Account__c(Account__c = account.Id, Division__c = 'a');
        Sub_Account__c s3 = new Sub_Account__c(Account__c = account.Id, Division__c = 'b');
        insert new List<Sub_Account__c> {s1, s2, s3};
        
        Test.startTest();
        
        AccountFilterExtension c = new AccountFilterExtension(new ApexPages.StandardController(account));
        System.assertEquals(2, c.divisionOptions.size());
        c.selectedDivision = 'a';
        c.filterSAP();
        System.assertEquals(2, c.getSAP().size());
    }
    
}