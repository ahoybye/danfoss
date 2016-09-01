/**
 * Retrieves the average amount and average age of won/lost opportunities.
 * 
 * Created by: rmohr@salesforce.com
 */
global class UserOpportunitiesIterator implements Iterator<AggregateResult> { 
 
    AggregateResult [] results {get;set;} 
    Integer index {get;set;}
 
    global UserOpportunitiesIterator(){ 
        index=0;
        String query = 'SELECT OwnerId, IsWon, '
            + 'AVG(Opp_Age__c) avg_age, '
            + 'AVG(Amount) avg_amount '
            + 'FROM Opportunity '
            + 'WHERE Account.business_org__c=\'Climate and Energy\' '
            + 'AND (IsWon = true '
            + 'OR (IsClosed = true AND IsWon = false)) '
            + 'GROUP BY OwnerID, IsWon';
                  
        system.debug(LoggingLevel.INFO, '@@ Run query: ' + query);
        results = Database.query(query); 
        system.debug(LoggingLevel.INFO, '@@ Query size: ' + results.size());
    } 
    
    global boolean hasNext(){ 
        return results !=null && !results.isEmpty() && index < results.size(); 
    } 
     
    global AggregateResult next(){ 
        return results[index++]; 
    } 
}