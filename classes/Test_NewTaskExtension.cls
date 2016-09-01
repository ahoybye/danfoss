@isTest
public class Test_NewTaskExtension {
    
    static testMethod void test() {
        FieldID__c fieldid = FieldID__c.getOrgDefaults();
        fieldid.ActivityDivision__c = 'abc';
        fieldid.ActivityType__c = 'def';
        fieldid.CallDivision__c = 'ghi';
        insert fieldid;
        
        Test.startTest();
        
        Task task = new Task();
        ApexPages.StandardController controller = new ApexPages.StandardController(task);
        NewTaskExtension c = new NewTaskExtension(controller);
        c.getRecTypeId();
        
        Test.stopTest();
        
        System.assertNotEquals(null, c.gettaskURL());
    }
    
}