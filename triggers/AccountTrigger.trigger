trigger AccountTrigger on Account (after insert, after update) {
    CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('AccountTrigger');
    if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
        if(Trigger.isAfter & Trigger.isInsert)
        {
            AccountTriggerHandler.PopulateAccountFields(Trigger.newMap.keySet());
            AccountTriggerHandler.ContentDocumentSetupOnAccount(Trigger.new, null, true);
        }
        if(Trigger.isAfter & Trigger.isUpdate)
        {
            AccountTriggerHandler.ContentDocumentSetupOnAccount(Trigger.new, Trigger.oldMap, false);
            AccountTriggerHandler.ChangeuserGroupOnLibraryChange(Trigger.new, Trigger.newMap, Trigger.oldMap);
            AccountTriggerHandler.UpdateNamesOnOtherRecords(Trigger.new, Trigger.oldMap);
        }
    }
}