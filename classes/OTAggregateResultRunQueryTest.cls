@isTest
private class OTAggregateResultRunQueryTest {
    
    static testMethod void test() {
        // Simple test to see if the batch job runs without errors
        Test.startTest();
        OTAggregateResultRunQuery job = new OTAggregateResultRunQuery();
        Database.executeBatch(job);
        Test.stopTest();    
    }

}