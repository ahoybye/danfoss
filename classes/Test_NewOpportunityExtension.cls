@isTest
public class Test_NewOpportunityExtension {
    
    static testMethod void test() {
        Test.startTest();
        
        NewOpportunityExtension c = new NewOpportunityExtension (new ApexPages.StandardController(new Opportunity()));
        C.getGoToOpp();
        C.getBusOrg();
        C.getRecTypeId();
        
        Test.stopTest();
        
        System.assertNotEquals(null, c.getGoToOpp());
    }
    
}