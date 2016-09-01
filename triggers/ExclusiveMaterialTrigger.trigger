//updates the Proprietary checkbox on the product record
trigger ExclusiveMaterialTrigger on Exclusive_Material__c (after insert, after update, after delete) {
	CS_Key_IDs__c fireTrigger = CS_Key_IDs__c.getInstance('ExclusiveMaterialTrigger');
	if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
		
		if(Trigger.isInsert || Trigger.isUpdate){
			ExclusiveMaterialTriggerHandler.onUpdateDeleteEM(Trigger.new);	
		}
		if(Trigger.isDelete){
			ExclusiveMaterialTriggerHandler.onDeleteCheckProduct(Trigger.old);
		}
												  
	}		
	   				  
}