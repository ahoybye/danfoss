@isTest
public class Test_setContactonStakeHolderMapping {
    
    static testMethod void testSetContact() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Sub_Account__c s1 = new Sub_Account__c(Account__c = account.Id, SAP_Account_ID__c = '123');
        insert s1;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        insert opportunity;
        Contact contact = Test_Utility.createContact(account.Id, 0);
        insert contact;
        Associated_Account__c stakeholder = new Associated_Account__c(Associated_Account__c = account.Id, Project_Opportunity__c = opportunity.Id );
        insert stakeholder;        
        
        Test.startTest();
        setContactonStakeholderMappingExtension c = new setContactonStakeholderMappingExtension(new ApexPages.StandardController(stakeholder));
        c.selectedContactId = contact.id;
        c.updatewithContact();
        System.assertEquals(stakeholder.Contact__c , contact.Id);
        Test.stopTest();
        }
    static testMethod void testNotSetContact() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Sub_Account__c s1 = new Sub_Account__c(Account__c = account.Id, SAP_Account_ID__c = '123');
        insert s1;
        Opportunity opportunity = Test_Utility.createOpportunity(account.Id, 0);
        insert opportunity;
      
        Associated_Account__c stakeholder = new Associated_Account__c(Associated_Account__c = account.Id, Project_Opportunity__c = opportunity.Id );
        insert stakeholder;        
        
        Test.startTest();
        setContactonStakeholderMappingExtension c = new setContactonStakeholderMappingExtension(new ApexPages.StandardController(stakeholder));
        c.navigatewithoutContact();
        System.assertEquals(stakeholder.Contact__c , null);
        Test.stopTest();
        }
    
}