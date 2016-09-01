public with sharing class AccountPlanStrategyActionsController {
    
    public List<Task> actions {get;set;}
    
    public AccountPlanStrategyActionsController(ApexPages.StandardController controller) {
        actions = [SELECT Id, Subject, Status, ActivityDate, OwnerId, WhatId FROM Task WHERE IsClosed = False AND WhatId IN (SELECT Id From Danfoss_Tactics__c WHERE Account_Plan__c = :controller.getId()) order by WhatId];
    }
    
}