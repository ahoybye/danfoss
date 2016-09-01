// Test class for the Batch class BatchUpdateOpportunityStages
// Changelog:
// October 01, 2015: Madhav Kakani - Fluido Denmark - Initial implementation
@isTest
private class BatchUpdateOpportunityStages_TEST {
    static testMethod void runTest() {   
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Division__c = 'Cooling';
        insert acct;
        
        system.assert(acct.Id != null);
        
       /* List<String> sPhases = new List<String> {'Identification', 'Value Proposition', 'Quotation', 'Follow-up'};
        List<Opportunity> lstOpp = new List<Opportunity>();
        for(Integer i= 0; i < 4; i++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp'+ String.valueof(i);
            opp.AccountId = acct.Id;
            opp.Amount = 100000;
            opp.CE_Sales_model__c = 'End user';
            opp.CE_Phase__c = sPhases[i];
            opp.CE_Status__c = 'In Progress';
            opp.CloseDate = Date.today() + 30;      
            opp.StageName = 'Open';
            lstOpp.add(opp);
        }
        
        // Lost opportunity
        for(Integer i= 0; i < 4; i++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp'+ String.valueof(i);
            opp.AccountId = acct.Id;
            opp.Amount = 100000;
            opp.CE_Sales_model__c = 'End user';
            opp.CE_Phase__c = sPhases[i];
            opp.CE_Status__c = 'Lost';
            opp.Reason__c = 'Test';
            opp.CloseDate = Date.today() + 30;      
            opp.StageName = 'Open';
            lstOpp.add(opp);
        }
        
        insert lstOpp;
            */                                
        Test.startTest();

        BatchUpdateOpportunityStages batch = new BatchUpdateOpportunityStages();
        Id batchId = Database.executeBatch(batch, 8);
            
        Test.stopTest();
    }
}