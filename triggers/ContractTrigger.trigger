trigger ContractTrigger on Contract__c(before insert, before update) {
	CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('ContractTrigger');
	if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
		
		if(trigger.isinsert && trigger.isBefore)
		{
			ContractTriggerHandler.fieldChecks(Trigger.New);
			ContractTriggerHandler.populateApprovers(Trigger.New);
			ContractTriggerHandler.setLegacyFields(Trigger.New);
		}
		if(trigger.isUpdate && trigger.isBefore)
		{
			ContractTriggerHandler.fieldChecks(Trigger.New);
			ContractTriggerHandler.populateApprovers(Trigger.New);
			ContractTriggerHandler.createExpirationTask(Trigger.New, Trigger.oldMap);
			ContractTriggerHandler.processApproval(Trigger.New);
			ContractTriggerHandler.RenewContract(Trigger.New);	
			ContractTriggerHandler.checkAttachments(Trigger.New);	
		}
	}
}