/*******************************************************************
* Author        :  Shailendra Singh (Appirio Offshore)
* Name          :  AfterLeadInsertUpdate
* Related Task  :  T-67976
* Description   :  Update SLA tracking field of Lead.                 
*******************************************************************/
trigger AfterLeadInsertUpdate on Lead (after insert, after update) {
	Set<ID> leadIds = new Set<ID>();
	Map<ID,Lead> leadMap = new Map<ID,Lead>();
	for(Lead lead : trigger.new){
	    if(Trigger.isInsert || lead.OwnerId != Trigger.oldMap.get(lead.id).ownerID){
        	leadIds.add(lead.id);
        }
        if(lead.OwnerId != lead.CreatedById){
        	leadMap.put(lead.ID,lead);
        }
	}
	if(!leadIds.isEmpty()){
		LeadManagement.updateSLANotificationFields(leadIds);
	}
	//~~~~~ COMMENTED OUT 28AUG15 PER MOLLY: LEADS SHOULD NEVER BE SHARED WITH THE CREATOR; NOT RELEVANT~~~~~
	/*if(!leadMap.isEmpty()){
		LeadManagement.shareLeadsWithCreater(leadMap.values(), leadMap.keySet());
	}*/
}