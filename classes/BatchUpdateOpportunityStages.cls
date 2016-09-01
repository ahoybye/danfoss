// Batch class to update old stage values to new values
// Changelog:
// October 01, 2015: Madhav Kakani - Fluido Denmark - Initial implementation
global class BatchUpdateOpportunityStages implements Database.Batchable<sObject> {
    global final String query;
    global final Set<String> sPhase; // set of phase values
    global final Set<String> sStatus; // set of status values
    
    global BatchUpdateOpportunityStages() {
        sPhase = new Set<String> {'Identification', 'Qualification', 'Value Proposition', 'Quotation', 'Follow-up'}; 
        sStatus = new Set<String> {'In Progress', 'On hold', 'Lost', 'Assigned to Partner'}; 

        if(!Test.isRunningTest()) { 
            query = 'SELECT Id, StageName, CE_Phase__c, CE_Status__c FROM Opportunity '
                    + ' WHERE StageName = \'Open\' AND CE_Phase__c IN :sPhase AND CE_Status__c IN :sStatus'
                    + ' AND Account.business_org__c = \'Climate and Energy\''
                    + ' AND Owner.User_Country__c = \'IN\'';
        }
        else {
            query = 'SELECT Id, StageName, CE_Phase__c, CE_Status__c FROM Opportunity';
        }
    }   

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {        
        List<Opportunity> lUpdate = new List<Opportunity>();
        List<Opportunity> objList = scope;                                                                                              

        System.debug(LoggingLevel.INFO, 'Opportunities found ' + scope.size());   
        for(Opportunity opp : objList) {                    
            System.debug(LoggingLevel.INFO, 'Examining Opportunity: ' + opp);   
            if(opp.CE_Phase__c == 'Identification' || opp.CE_Phase__c == 'Qualification') {
                if(opp.CE_Status__c == 'In Progress' || opp.CE_Status__c == 'On hold' || opp.CE_Status__c == 'Assigned to Partner') opp.StageName = 'Identified Opportunity (CE)';
                else if(opp.CE_Status__c == 'Lost') opp.StageName = 'Closed-Lost';
            } 
            else if(opp.CE_Phase__c == 'Value Proposition') {
                if(opp.CE_Status__c == 'In Progress' || opp.CE_Status__c == 'On hold' || opp.CE_Status__c == 'Assigned to Partner') opp.StageName = 'Specifying Solution (CE)';
                else if(opp.CE_Status__c == 'Lost') opp.StageName = 'Closed-Lost';
            }
            else if(opp.CE_Phase__c == 'Quotation') {
                if(opp.CE_Status__c == 'In Progress' || opp.CE_Status__c == 'On hold' || opp.CE_Status__c == 'Assigned to Partner') opp.StageName = 'Evaluating Solution (CE)';
                else if(opp.CE_Status__c == 'Lost') opp.StageName = 'Closed-Lost';
            }
            else if(opp.CE_Phase__c == 'Follow-up') {
                if(opp.CE_Status__c == 'In Progress' || opp.CE_Status__c == 'On hold' || opp.CE_Status__c == 'Assigned to Partner') opp.StageName = 'Ordering Solution (CE)';
                else if(opp.CE_Status__c == 'Lost') opp.StageName = 'Closed-Lost';
            }
            System.debug(LoggingLevel.INFO, 'Updated stage on Opportunity: ' + opp);            
            lUpdate.add(opp);
        }
                        
        if(lUpdate.size() > 0) update lUpdate;
        System.debug(LoggingLevel.INFO, lUpdate.size() + ' opportunities updated');
    }
        
    global void finish(Database.BatchableContext BC) {
    }   
}