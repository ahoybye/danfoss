@isTest
public class Test_TaskWithContactAccountActionExt {
    
    public static testMethod void test() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Contact contact1 = Test_Utility.createContact(account.Id, 1);
        Contact contact2 = Test_Utility.createContact(account.ID, 2);
        insert new List<Contact> {contact1, contact2};
        
        Test.startTest();
        
        TaskWithContactAccountActionExtension c = new TaskWithContactAccountActionExtension(new ApexPages.StandardController(account));
        Date x = c.duedate;
        c.t.Subject = 'test';
        c.duedate = Date.today();
        c.t.WhoId = contact1.Id;
        c.CreateTask();
        
        Test.stopTest();
        
        System.assertNotEquals(null, c.t.Id);
        System.assertEquals(1, [select Id from Task].size());
    }
    
}