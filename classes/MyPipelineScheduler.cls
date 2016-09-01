/**
 * Scheduler to run the batch jobs required for My Pipeline Dashboard.
 *
 * Created by: rmohr@salesforce.com
 */
global class MyPipelineScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        // Opportunity Trending data
        Database.executeBatch(new OTAggregateResultRunQuery());
        // User statistics
        Database.executeBatch(new BatchMyPipelineUserStats());

    }
    
}