@isTest
public class Test_SetAsMainAccountExtension {
    
    static testMethod void test() {
        Account account1 = Test_Utility.createAccount(1);
        Account account2 = Test_Utility.createAccount(2);
        insert new List<Account> {account1, account2};
        Opportunity opportunity = Test_Utility.createOpportunity(account1.Id, 0);
        opportunity.Sales_Org__c = null;
        insert opportunity;
        Associated_Account__c aa = new Associated_Account__c(Associated_Account__c = account2.Id, Project_Opportunity__c = opportunity.Id);
        insert aa;
        
        Test.startTest();
        
        SetAsMainAccountExtension c = new SetAsMainAccountExtension(new ApexPages.StandardController(aa));
        c.gotoOpp();
        
        Test.stopTest();
        
        System.assertEquals(account2.Id, [select AccountId from Opportunity].AccountId);
        System.assertEquals('Main Account', [select Type_of_Association__c from Associated_Account__c where Id = :aa.Id].Type_of_Association__c);
    }
    
}