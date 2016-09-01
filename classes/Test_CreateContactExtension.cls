@isTest
public class Test_CreateContactExtension {
    
    public static testMethod void test() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('accid', account.Id);
        Contact contact = new Contact();
        CreateContactExtension c = new CreateContactExtension(new ApexPages.StandardController(contact));
        contact.FirstName = 'First';
        contact.LastName = 'Last';
        contact.Email = 'e@ma.il';
        c.createNew();
        
        Test.stopTest();
        
        System.assert(ApexPages.getMessages().isEmpty());
        System.assertEquals(true, c.navigateToEditCon);
        System.assertNotEquals(null, contact.Id);
        System.assertEquals(1, [select Id from Contact].size());
    }
    
}