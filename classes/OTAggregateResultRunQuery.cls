global class OTAggregateResultRunQuery implements Database.Batchable<AggregateResult> { 
// AggregateResultRunQuery batchquery = new AggregateResultRunQuery();        
//Database.executeBatch(batchquery, 200);

    global OTAggregateResultRunQuery () {
        system.debug(LoggingLevel.INFO, '@@ Initializing OTAggregateResultRunQuery');
        removeCurrentPeriodData();
    }
    
    global Iterable<AggregateResult> start(Database.BatchableContext BC){
        System.debug(LoggingLevel.INFO, '@@ OTAggregateResultRunQuery start - Job ID: ' + BC.getJobId());
        return new OTAggregateResultIterable(); 
    } 
     
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Opportunity_Trending__c> OppTrendList = new List<Opportunity_Trending__c>();
        
        System.debug(LoggingLevel.INFO, '@@ Starting batch update for Opportunity Trending');
        
        for(sObject s : scope){ 
            AggregateResult ar = (AggregateResult) s;
            System.debug(LoggingLevel.INFO, '@@ AggregateResult: ' + ar);       
            Opportunity_Trending__c OppTrend = new Opportunity_Trending__c();
            OppTrend.OwnerId__c= (String)ar.get('OwnerId');
            OppTrend.Team__c = (String) ar.get('team');
            OppTrend.Period__c= Date.today();
            OppTrend.Segment__c= (String)ar.get('Segment');
            OppTrend.Region__c= (String)ar.get('Region__c');
            OppTrend.Country__c= (String)ar.get('country');

            OppTrend.Stage__c= (String)ar.get('StageName');
            OppTrend.Amount__c= ((Decimal)ar.get('sum_amount'));            
            OppTrend.Amount_at_Risk__c=((Decimal)ar.get('risk_amount'));
            
            OppTrend.Opportunity_count__c= ((Decimal)ar.get('cnt'));            
            OppTrend.Overdue_count__c= ((Decimal)ar.get('count_overdue'));
            OppTrend.Overdue_Amount__c = (Decimal) ar.get('overdue_amount');
            OppTrend.Inactive_count__c= ((Decimal)ar.get('count_inactive'));
            OppTrend.Inactive_Amount__c = ((Decimal)ar.get('inactive_amount'));
            OppTrend.Stalled_count__c= ((Decimal)ar.get('count_stalled'));
            OppTrend.Stalled_in_Stage_Amount__c = (Decimal) ar.get('stalled_amount');
            OppTrend.ExtraLarge_count__c= ((Decimal)ar.get('count_extralarge'));
            OppTrend.ExtraLarge_Amount__c = ((Decimal)ar.get('extralarge_amount'));
            OppTrend.Overaged_count__c= ((Decimal)ar.get('count_overaged'));
            OppTrend.Overaged_Amount__c = (Decimal) ar.get('overaged_amount');
            OppTrend.TimeSlip_count__c= ((Decimal)ar.get('count_timeslip'));
            OppTrend.TimeSlip_Amount__c = ((Decimal)ar.get('timeslip_amount'));
            OppTrend.SizeChange_count__c= ((Decimal)ar.get('count_sizechange'));
            OppTrend.SizeChange_Amount__c = ((Decimal)ar.get('sizechange_amount'));
            OppTrend.Average_Probability__c = ((Decimal)ar.get('avg_probability'));
            // Insert weighted score - this should be divided by the selected number of opportunities
            // E.g. If user A has a score of 200 and user B 180 and the is 22 the end weighted probability
            // will be 380/22
            OppTrend.Average_Probability_Weighted__c = OppTrend.Average_Probability__c * OppTrend.Opportunity_count__c;
            
            OppTrendList.add(OppTrend);
            System.debug(LoggingLevel.INFO, '@@ Added Opportunity Trending record: ' + OppTrend);
            
        } 
        insert OppTrendList;
        System.debug(LoggingLevel.INFO, '@@ Inserted ' + oppTrendList.size() + ' Opportunity Trending entries');
        
        // Debugging only
        for (Opportunity_Trending__c ot : OppTrendList) {
            System.debug(LoggingLevel.INFO, '@@ OT: ' + ot.ownerId__c + ', ' + ot);
        }
    } 
     
    global void finish(Database.BatchableContext BC){ 
        AsyncApexJob a = 
            [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems,CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
        System.debug(LoggingLevel.INFO, '@@ Finished batch job ********: ' + a.Id);
    }
    
    /**
     * Removes previously inserted summary data for the current reporting period.
     */
    private void removeCurrentPeriodData() {
        try {
            System.debug(LoggingLevel.INFO, '@@ Removing existing data from current reporting period');
            delete [SELECT Id FROM Opportunity_Trending__c WHERE Period__c = THIS_MONTH];    
        }
        catch(DMLException e) {
            System.debug(LoggingLevel.ERROR, '@@ Failed to remove previous data: ' + e.getMessage());
        }
    }
}