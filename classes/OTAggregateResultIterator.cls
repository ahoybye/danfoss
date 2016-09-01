global class OTAggregateResultIterator Implements Iterator<AggregateResult>{ 
 
    AggregateResult [] results {get;set;} 
    Integer index {get;set;} 
 
    global OTAggregateResultIterator(){ 
        index=0;
        String query = 'Select owner.division__c segment, '
            + 'owner.Region__c, '
            + 'owner.User_Country__c country, ' 
            + 'owner.Business_Segment__c team, '
            + 'OwnerId, '
            + 'StageName, '
            + 'sum(overdue__c) count_overdue, '
            + 'sum(Q_Overdue_Amount__c) overdue_amount, '
            + 'sum(inactive__c) count_inactive, '
            + 'sum(Q_Inactive_Amount__c) inactive_amount, '
            + 'sum(Q_Over_Aged__c) count_overaged, '
            + 'sum(Q_Over_Aged_Amount__c) overaged_amount ,'
            + 'sum(Q_Stalled_in_Stage__c) count_stalled, '
            + 'sum(Q_Stalled_in_Stage_Amount__c) stalled_amount,'
            + 'sum(Q_Time_Slippage__c) count_timeslip, ' 
            + 'sum(Q_Time_Slippage_Amount__c) timeslip_amount, '
            + 'sum(Q_Size_Change__c) count_sizechange, '
            + 'sum(Q_Size_Change_Amount__c) sizechange_amount,'
            + 'sum(Q_Extra_Large__c) count_extralarge, '
            + 'sum(Q_Extra_Large_Amount__c) extralarge_amount, '
            + 'count(Id) cnt, '
            + 'avg(Probability) avg_probability, '
            + 'sum(amount) sum_amount, '
            + 'avg(amount) avg_amount, '
            + 'sum(Amount_At_Risk__c) risk_amount '
            + 'FROM opportunity  '
            + 'WHERE account.business_org__c=\'Climate and Energy\' '
            + 'AND IsClosed = False '
            + 'GROUP BY owner.division__c, owner.Region__c, owner.User_Country__c, '
            + 'owner.Business_Segment__c,OwnerId, StageName';
        
        system.debug(LoggingLevel.INFO, '@@ Opportunity query: ' + query);
        results = Database.query(query); 
        system.debug(LoggingLevel.INFO, '@@ Opportunity query results: (' + results.size() + ') ' + results);
    } 
     
    global boolean hasNext(){ 
        return results !=null && !results.isEmpty() && index < results.size(); 
    } 
     
    global AggregateResult next(){ 
        return results[index++]; 
    } 
}