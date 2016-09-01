@isTest
public class Test_CloseCaseRedirectExtension {

     static testMethod void test() {
           
        Test.startTest();
        
        case ca = new case();
        insert ca;
        ApexPages.StandardController controller = new ApexPages.StandardController(ca);
        CloseCaseRedirectExtension c = new CloseCaseRedirectExtension(controller);       
        Test.stopTest();
        
        System.assertNotEquals(null, c.closeURL);
    }
    
    
    
}