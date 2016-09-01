@isTest
public class Test_ShowMarketingAttributesExtension {
    
    static testMethod void test() {
        Account_Division_Data_config__c cfg1 = new Account_Division_Data_config__c(Division__c = 'All');
        Account_Division_Data_config__c cfg2 = new Account_Division_Data_config__c(Division__c = 'abc');
        Account_Division_Data_config__c cfg3 = new Account_Division_Data_config__c(Division__c = 'def');
        insert new List<Account_Division_Data_config__c> {cfg1, cfg2, cfg3};
        
        Account account = Test_Utility.createAccount(0);
        insert account;
        Account_Division_Data__c attr1 = new Account_Division_Data__c(Account__c = account.Id, Account_Division_Data_Config__c = cfg1.Id);
        Account_Division_Data__c attr2 = new Account_Division_Data__c(Account__c = account.Id, Account_Division_Data_Config__c = cfg2.Id);
        Account_Division_Data__c attr3 = new Account_Division_Data__c(Account__c = account.Id, Account_Division_Data_Config__c = cfg3.Id);
        insert new List<Account_Division_Data__c> {attr1, attr2, attr3};
        
        Test.startTest();
        
        ShowMarketingAttributesExtension c = new ShowMarketingAttributesExtension(new ApexPages.StandardController(account));
        System.assertEquals(3, c.getADDs().size());
        
        c.selectedValue = 'abc';
        c.filterADDs();
        System.assertEquals(2, c.getADDs().size());
        
       	System.assertNotEquals(null, c.CreateADD());
        
        c.selectedADD = attr2.Id;
        System.assertNotEquals(null, c.EditADD());
        
        c.selectedADD = attr2.Id;
        c.DeleteADD();
        System.assertEquals(2, [select Id from Account_Division_Data__c].size());
    }
    
}