/**
	Author: Erin Fink
	Date: 14MAY15
	Version 1.0
*/

trigger MachineProductTrigger on Machine_Model_Product__c bulk (before insert, before update, after insert, after update, after delete) {
	CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('MachineProductTrigger');
	if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
		if(Trigger.isBefore){
			MachineProductTriggerHandler.UpdatePartNumbers(Trigger.new);
		}	
		
		if(Trigger.isAfter){
			MachineProductTriggerHandler.UpdateMachineAndAcctMetrics(Trigger.new, Trigger.old, Trigger.IsDelete, Trigger.isInsert);
		}	
	}
}