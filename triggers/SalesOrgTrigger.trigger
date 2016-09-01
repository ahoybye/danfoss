trigger SalesOrgTrigger on Sales_Org__c (before insert, after insert, before update, after update, after delete) 
{
    CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('SalesOrgTrigger');
    if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
        Map<string, Application__c> mapApplications = new Map<String, Application__c>();
        for(Application__c app :[Select Name, Market_Segment__c, SAP_Application_Code__c from Application__c]){
            mapApplications.put(app.SAP_Application_Code__c, app);      
        }   
        
        if(Trigger.isBefore)    //BEFORE
        {
            SalesOrgTriggerHandler.populateSalesOrgFields(Trigger.New, mapApplications);
        }
        
        if(Trigger.isAfter)     //AFTER
        {   
            Set<Id> setaccountIds = new Set<Id>();
            for (Sales_Org__c sOrg : trigger.isDelete ? Trigger.Old : Trigger.New) {
                if(sOrg.Account__c != null)
                    setaccountIds.add(sOrg.Account__c);
            }
            SalesOrgTriggerHandler.populateAccountFields(setaccountIds, mapApplications);
        }
    }
}