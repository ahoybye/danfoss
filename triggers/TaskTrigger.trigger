trigger TaskTrigger on Task (before insert, before update, after insert, after update) {
	private static Id ContractExpiredtaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Expired Task').getRecordTypeId();
	private static Id ContracttaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Task').getRecordTypeId();	
	private static Id ContractHardCopyRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Hard Copy Task').getRecordTypeId();
	CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('TaskTrigger');
	if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {

		if(trigger.isinsert && trigger.isBefore) // BEFORE INSERT
		{
			TaskTriggerHandler.ProcessPardotTasks(Trigger.new);
			TaskTriggerHandler.clearTypeNonNPF(Trigger.new);	//for Customer Requests: clear the type field if request is not New Product Feature
		}
		
		if(trigger.isinsert && trigger.isAfter)  // AFTER INSERT
		{
			List<Task> lstTasks = new List<Task>();
			Set<Id> setTaskIDs = new Set<Id>();
			for (Task tsk:Trigger.newMap.values()) {
	            if (tsk.recordTypeId == ContracttaskRecordTypeId && tsk.Contract_Stage__c != null && !tsk.Contract_Stage__c.Contains('Expired')){ 
					setTaskIDs.add(tsk.Id);
				}
				else if (tsk.recordTypeId == ContractHardCopyRecordTypeId || (tsk.recordTypeId == ContractExpiredtaskRecordTypeId && tsk.Contract_Stage__c != null && tsk.Contract_Stage__c.Contains('Expired'))){
					lstTasks.add(tsk);	
				}
			}
			if (!setTaskIDs.isEmpty())
				ContractTaskHandler.SendEmailForContractTasksBATCH(Trigger.newMap.keySet());	//send email from contract task using template
			
			if (!lstTasks.isEmpty())
				ContractTaskHandler.SendEmailForContractTasks(lstTasks);
			
			TaskTriggerHandler.NotifyAssignee(Trigger.new);
		}
		
		if(trigger.isupdate && trigger.isBefore) // BEFORE UPDATE
		{
			ContractTaskHandler.StampContractApprovalTime(Trigger.new);	//stamps current time in contract task
            TaskTriggerHandler.StampCompletedDate(Trigger.new, Trigger.oldMap);	//stamps current time in danfoss and collaboration task rectypes
			TaskTriggerHandler.ProcessCRTasks(Trigger.new, Trigger.oldMap);  //for routing PS customer request BU tasks
		}
		
		if(trigger.isupdate && trigger.isAfter)  // AFTER UPDATE
		{	
			ContractTaskHandler.ContractApprovalFromTask(Trigger.new);		//passes info from task to contract
			
			Set<Id> setCustReqIds = new Set<Id>();
			for (Task tsk:Trigger.new) {
				if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == PS_Customer_Request__c.SObjectType)
					setCustReqIds.add(tsk.WhatId);
			}
			TaskTriggerHandler.updateCustomerRequest(setCustReqIds);
			TaskTriggerHandler.NotifyAssigneeIfReassigned(Trigger.new, Trigger.oldMap);
			TaskTriggerHandler.NotifyCreatorUponCompletion(Trigger.new, Trigger.oldMap);  //this needs to not send emails for contract approval and HC tasks
		}		
	}
}