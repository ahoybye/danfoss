@isTest(seeAllData=true)
public class BatchMyPipelineUserStatsTest {
    static Integer countWon;
    static Integer countLost; 
    static Decimal amountWon;
    
    static integer batchSize = 100;
    static Integer s_num = 1;
    
    public static testMethod void test() {
        // Init counters
        countWon = 0;
        countLost = 0;
        amountWon = 0;
        
        sObject[] scope = getScope(100);
        //sObject[] reference = scope.deepclone(true, true, true);        
        //setExpectedResults(reference);
        
        Test.startTest();                   
        BatchMyPipelineUserStats job = new BatchMyPipelineUserStats();
        job.execute(new TestBatchableContext(), scope);
        Test.stopTest();
        
        // Not really possible to grab and compare the result set passed to the
        // Batch class - so this is just testing if the job runs without errors
    }
    
    /**
     * Set the expected results for the test.
     */
    private static void setExpectedResults(List<sObject> results) {
        System.debug(LoggingLevel.INFO, '@@ Got results: '+ results);    
        for (sObject o : results) {
           AggregateResult ar = (AggregateResult) o;
           System.debug(LoggingLevel.INFO, '@@ Aggregate Result: '+ ar);
           //String ownerId = (String) ar.get('OwnerId');
           //Integer averageAge = (Integer) ar.get('avg_age');
//           boolean isWon = (Boolean) ar.get('IsWon');
        }
    }
    
    /**
     * Fetches <size> number of aggregated results from the
     * Opportunity object.
     */
    private static List<sObject> getScope(Integer size){
        String query = 'SELECT OwnerId, IsWon, '
            + 'AVG(Opp_Age__c) avg_age, '
            + 'AVG(Amount) avg_amount '
            + 'FROM Opportunity '
            + 'WHERE Account.business_org__c=\'Climate and Energy\' '
            + 'AND (IsWon = true '
            + 'OR (IsClosed = true AND IsWon = false)) '
            + 'GROUP BY OwnerID, IsWon LIMIT :size ';
            
        sObject[] objects = Database.query(query);
        System.debug(LoggingLevel.INFO, '@@ Found objects: '+ objects);
        return objects;
    }
 
    public static String getFakeId(Schema.SObjectType sot){
            String result = String.valueOf(s_num++);
            return sot.getDescribe().getKeyPrefix() + 
                '0'.repeat(12-result.length()) + result;
    }
     
     /**
      * BatchableContext implementation that can be passed directly to
      * batch class' execute method
      */
     class TestBatchableContext implements Database.BatchableContext {

        public Id getChildJobId() { return getFakeId(AsyncApexJob.sObjectType); }        
        public Id getJobId() { return getFakeId(AsyncApexJob.sObjectType); }
        
        
    }   
}