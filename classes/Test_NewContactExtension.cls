@isTest
public class Test_NewContactExtension {
    
    static testMethod void test() {
        Test.startTest();
        
        NewContactExtension c = new NewContactExtension(new ApexPages.StandardController(new Contact()));
        C.getgotoCon();
        C.getBusOrg();
        C.getRecTypeId();
        
        Test.stopTest();
        
        System.assertNotEquals(null, c.getgotoCon());
    }
    
}