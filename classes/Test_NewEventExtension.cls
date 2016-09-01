@isTest
public class Test_NewEventExtension {
    
    static testMethod void test() {
        FieldID__c fieldid = FieldID__c.getOrgDefaults();
        fieldid.ActivityDivision__c = 'abc';
        insert fieldid;
        
        Test.startTest();
        
        NewEventExtension c = new NewEventExtension(new ApexPages.StandardController(new Event()));
        
        Test.stopTest();
        
        System.assertNotEquals(null, c.geteventURL());
    }
    
}