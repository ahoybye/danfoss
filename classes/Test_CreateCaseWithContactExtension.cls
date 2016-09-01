@isTest
public class Test_CreateCaseWithContactExtension {
    
    static testMethod void testSplitPhoneNumber() {
        ApexPages.currentPage().getParameters().put('ANI', '+451234');
        CreateCaseWithContactExtension c = new CreateCaseWithContactExtension();
        System.assertEquals('DK: Denmark (+45)', c.contact.Phone_Country__c);
        System.assertEquals('1234', c.contact.Phone_Local__c);
    }
    
    static testMethod void testFoundCaseName() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Contact contact = test_Utility.createContact(account.Id, 0);
        insert contact;
        Case theCase = new Case(Subject = 'some case', SuppliedName = 'Test Name', SuppliedCompany = 'company name');
        insert theCase;
        
        Test.startTest();
        
        CreateCaseWithContactExtension c = new CreateCaseWithContactExtension();
        c.contact.FirstName = 'Test';
        c.contact.LastName = 'Name 0';
        c.account.Name = 'foo';
        c.contact.Email = '';
        c.contact.Phone_Country__c = 'foo(+12)';
        c.contact.Phone_Local__c = '34';
        Test.setFixedSearchResults(new List<ID> {theCase.Id});
        c.search();
        
        System.assertEquals(1, c.casesCon.getResultSize());
        System.assertEquals(0, c.contactsCon.getResultSize());
        System.assertEquals(0, c.accountsCon.getResultSize());
        
        c.selectedCaseId = c.getCases()[0].Id;
        c.selectCase();
        
        System.assertNotEquals(null, c.createCaseUrl);
        
        Test.stopTest();
        
        System.assertEquals(1, [select count() from Account]);
        System.assertEquals(1, [select count() from Contact]);
        System.assertEquals(1, [select count() from Case]);
    }
    
    static testMethod void testFoundContactName() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Contact contact = test_Utility.createContact(account.Id, 0);
        insert contact;
        
        Test.startTest();
        
        CreateCaseWithContactExtension c = new CreateCaseWithContactExtension();
        c.contact.FirstName = 'Test';
        c.contact.LastName = 'Name 0';
        c.account.Name = 'foo';
        c.contact.Email = '';
        c.contact.Phone_Country__c = 'foo(+12)';
        c.contact.Phone_Local__c = '34';
        Test.setFixedSearchResults(new List<ID> {contact.Id});
        c.search();
        
        System.assertEquals(0, c.casesCon.getResultSize());
        System.assertEquals(0, c.contactsCon.getResultSize());
        System.assertEquals(0, c.accountsCon.getResultSize());
        
      //  c.selectedContactId = c.getContacts()[0].Id;
      //  c.selectContact();
        
      //  System.assertEquals('+1234', c.getPhone());
        
        c.createCase();
        
        System.assertNotEquals(null, c.createCaseUrl);
        
        Test.stopTest();
        
        System.assertEquals(1, [select count() from Account]);
        System.assertEquals(1, [select count() from Contact]);
        System.assertEquals(1, [select count() from Case]);
    }
    
    static testMethod void testFoundContactEmail() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Contact contact = test_Utility.createContact(account.Id, 0);
        insert contact;
        
        Test.startTest();
        
        CreateCaseWithContactExtension c = new CreateCaseWithContactExtension();
        c.contact.FirstName = 'foo';
        c.contact.LastName = 'foo';
        c.account.Name = 'foo';
        c.contact.Email = 'test0contact@test.com';
        c.contact.Phone_Country__c = 'foo(+12)';
        c.contact.Phone_Local__c = '34';
        Test.setFixedSearchResults(new List<ID> {contact.Id});
        c.search();
        
        System.assertEquals(0, c.casesCon.getResultSize());
        System.assertEquals(0, c.contactsCon.getResultSize());
        System.assertEquals(0, c.accountsCon.getResultSize());
        
     //   c.selectedContactId = c.getContacts()[0].Id;
     //   c.selectContact();
        
     //   System.assertEquals('+1234', c.getPhone());
        
        c.updateContactPhone();
        
//        System.assertNotEquals(null, c.createCaseUrl);
        
        Test.stopTest();
        
        System.assertEquals(1, [select count() from Account]);
        System.assertEquals(1, [select count() from Contact]);
  
    }
    
    static testMethod void testFoundAccountName() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Contact contact = test_Utility.createContact(account.Id, 0);
        insert contact;
        
        Test.startTest();
        
        CreateCaseWithContactExtension c = new CreateCaseWithContactExtension();
        c.contact.FirstName = 'foo';
        c.contact.LastName = 'foo';
        c.account.Name = 'Test Account';
        c.contact.Email = '';
        c.contact.Phone_Country__c = 'foo(+12)';
        c.contact.Phone_Local__c = '34';
        Test.setFixedSearchResults(new List<ID> {account.Id});
        c.search();
        
        System.assertEquals(0, c.casesCon.getResultSize());
        System.assertEquals(0, c.contactsCon.getResultSize());
        System.assertEquals(1, c.accountsCon.getResultSize());
        
        c.selectedAccountId = c.getAccounts()[0].Id;
        c.selectAccount();
        
        System.assertNotEquals(null, c.createCaseUrl);
        
        Test.stopTest();
        
        System.assertEquals(1, [select count() from Account]);
        System.assertEquals(2, [select count() from Contact]);
        System.assertEquals(1, [select count() from Case]);
    }
    
    static testMethod void testFoundNothing() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Contact contact = test_Utility.createContact(account.Id, 0);
        insert contact;
        
        Test.startTest();
        
        CreateCaseWithContactExtension c = new CreateCaseWithContactExtension();
        c.contact.FirstName = 'foo';
        c.contact.LastName = 'foo';
        c.account.Name = 'foo';
        c.contact.Email = '';
        c.contact.Phone_Country__c = 'foo(+12)';
        c.contact.Phone_Local__c = '34';
        Test.setFixedSearchResults(new List<ID> {});
        c.search();
        
        System.assertEquals(0, c.casesCon.getResultSize());
        System.assertEquals(0, c.contactsCon.getResultSize());
        System.assertEquals(0, c.accountsCon.getResultSize());
        
        c.selectNothing();
        
        System.assertNotEquals(null, c.createCaseUrl);
        
        Test.stopTest();
        
        System.assertEquals(2, [select count() from Account]);
        System.assertEquals(2, [select count() from Contact]);
        System.assertEquals(1, [select count() from Case]);
    }
    
    static testMethod void testNoContact() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Contact contact = test_Utility.createContact(account.Id, 0);
        insert contact;
        
        Test.startTest();
        
        CreateCaseWithContactExtension c = new CreateCaseWithContactExtension();
        c.contact.FirstName = 'foo';
        c.contact.LastName = 'foo';
        c.account.Name = 'foo';
        c.contact.Email = '';
        c.contact.Phone_Country__c = 'foo(+12)';
        c.contact.Phone_Local__c = '34';
        Test.setFixedSearchResults(new List<ID> {});
        c.search();
        
        System.assertEquals(0, c.casesCon.getResultSize());
        System.assertEquals(0, c.contactsCon.getResultSize());
        System.assertEquals(0, c.accountsCon.getResultSize());
        
        c.selectNoContact();
        
        System.assertNotEquals(null, c.createCaseUrl);
        
        Test.stopTest();
        
        System.assertEquals(1, [select count() from Account]);
        System.assertEquals(1, [select count() from Contact]);
        System.assertEquals(1, [select count() from Case]);
    }
    
}