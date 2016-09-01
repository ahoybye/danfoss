/**
 * Batch class to update My Pipeline related settings on the user.
 * 
 * Created by: rmohr@salesforce.com, 2015-09-30
 */
global class BatchMyPipelineUserStats implements Database.Batchable<AggregateResult> { 

    global BatchMyPipelineUserStats() {
        system.debug('$$$ - Initializing BatchMyPipelineUserStats');
    }
    
    global Iterable<AggregateResult> start(Database.BatchableContext BC){ 
        System.debug('$$$ - Starting Batch');
        return new UserOpportunitiesIterable(); 
    } 
     
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        List<User> users = new List<User>();
        
        System.debug(LoggingLevel.INFO, '@@ Starting batch update for user');
        
        Map<String, User> userMap = new Map<String, User>();
        
        for(sObject s : scope){ 
            AggregateResult ar = (AggregateResult) s;
            String userId = (String) ar.get('OwnerId');
            User user = userMap.get(userId);
            if (user == null) {
                user = new User();
                user.Id = userId;
                userMap.put(userId, user);
            }
            // Switch on opportunity won or lost
            boolean isWon = (boolean) ar.get('IsWon');
            if (isWon) {
                user.Opportunity_Average_Age_Won__c = ((Decimal)ar.get('avg_age'));
                user.Average_Opportunity_Amount__c =  ((Decimal)ar.get('avg_amount'));
                // Check values - negative numbers may appear due to imported opptys
                if (user.Opportunity_Average_Age_Won__c < 0)
                        user.Opportunity_Average_Age_Won__c = 0;
                if (user.Average_Opportunity_Amount__c < 0)
                        user.Average_Opportunity_Amount__c = 0;
            }
            else {
                user.Opportunity_Average_Age_Lost__c = ((Decimal)ar.get('avg_age'));
                // Check values - negative numbers may appear due to imported opptys
                if (user.Opportunity_Average_Age_Lost__c < 0)
                    user.Opportunity_Average_Age_Lost__c = 0;
            }                        
        }
        update userMap.values();    
        System.debug(LoggingLevel.INFO, '@@ Updated ' + userMap + ' users');
    } 
     
    global void finish(Database.BatchableContext BC){ 
        AsyncApexJob a = 
            [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems,CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
        System.debug('$$$********: ' + a.Id);
    }
}