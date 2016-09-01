/**
	* MachineTrigger - <description>
	* Created by BrainEngine Cloud Studio
	* @author: Erin Fink
	* @date: 13MAY15
	* @version: 1.0
*/

trigger MachineTrigger on Machine_Model__c bulk (before insert,before update,after update,after delete) {
	CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('MachineTrigger');
	if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
		if(Trigger.IsBefore && Trigger.IsInsert){
			MachineTriggerHandler.GetAccountCurrency(Trigger.new);
		}

		if(Trigger.IsBefore && Trigger.IsUpdate){
			MachineTriggerHandler.CalculateTotalMachinePotential(Trigger.new);
		}
		
		if(Trigger.IsAfter){
			if (MachineProductTriggerHandler.hasTriggerExecuted) //not sure if this is still necessary? 30 JUN 14 EF
				return ;
			MachineTriggerHandler.UpdateAcctMetrics(Trigger.old);
		}
	}
}