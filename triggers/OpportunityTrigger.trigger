/******************************************************
* Author        :  Shailendra Singh (Appirio Offshore)
* Name          :  OpportunityManagement
* Date          :  09/08/2012
* Related Task  :  T-68281
* Updated       :  01MAY15 Erin Fink
*******************************************************/
trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {    
    CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('OpportunityTrigger');
    if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
        if (Trigger.isBefore && Trigger.isInsert)
        {
            OpportunityManagement.getSalesOrg(Trigger.new);
            OpportunityManagement.checkForCompetitorPrice(Trigger.new);
        }
        
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            OpportunityManagement.checkForCompetitorPrice(Trigger.new);
            OpportunityManagement.CompilePartNumbersFromOLI(Trigger.new);
        }
        
        if (Trigger.isAfter && Trigger.isInsert)
        {
            OpportunityManagement.notifyOpportunityAccountTeam(Trigger.newMap.keySet());  
            if (Test.isRunningTest()&&Limits.getFutureCalls()>=Limits.getLimitFutureCalls()) {
                system.debug(LoggingLevel.Error, 'Future method limit reached. Skipping...');
            }
            else {
                OpportunityManagement.updateOpptyOwner(Trigger.newMap.keySet());    
            }
        }
        
        if (Trigger.isAfter && Trigger.isUpdate)
        {
            OpportunityManagement.HandleReplacementBusiness(Trigger.New, Trigger.oldMap);
        }
    }
}