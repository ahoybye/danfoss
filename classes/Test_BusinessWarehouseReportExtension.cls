@isTest
public class Test_BusinessWarehouseReportExtension {
    
    static testMethod void test() {
        insert new BusinessWarehouseReport__c(Name = 'test', Report_URL__c = 'http://sap.danfoss.net/report?accoutId={ID}');
        Sub_Account__c sa = new Sub_Account__c(SAP_Account_ID__c = '123', Name = '123');
        insert sa;
        
        Test.startTest();
        
        BusinessWarehouseReportExtension c = new BusinessWarehouseReportExtension(new ApexPages.StandardController(sa));
        System.assertEquals(1, c.getReports().size());
    }
    
}