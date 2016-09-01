@isTest
public class Test_CaseNewEmailExtension {

     static testMethod void test() {
           
        Test.startTest();
        
        case ca = new case();
        insert ca;  
        ApexPages.StandardController controller = new ApexPages.StandardController(ca);
        CaseNewEmailExtension c = new CaseNewEmailExtension(controller);       
        Test.stopTest();
        
        System.assertNotEquals(null, c.emailURL);
    }
    
    
    
}