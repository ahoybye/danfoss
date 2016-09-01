/*---------------------------------------------------------------------
  Author        :   Appirio Offshore(Nikita Jain)
  Date          :   July 25, 2012
  Description   :   Trigger on Lead that copies custom address fields from standard ones. Country and state are queried from the related objects to populate the custom references.
  Related Task  :   Task T-64473    
  related to    :   Copy custom address Lead field (street, city, state, zip, country) values to Standard text address only if the standard address (all fields) are empty (T-65156)
//---------------------------------------------------------------------*/
trigger BeforeLeadInsertUpdate on Lead (before insert, before update) {
    
    map<String , Id> countryNameId = new map<String , Id>();
    map<Id , String> countryIdName = new map<Id , String>();
    map<String , Id> stateNameId = new map<String , Id>();
    map<Id , String> stateIdName = new map<Id , String>();
    set<String> countryNameSet = new set<String>();
    set<String> stateNameSet = new set<String>();
    set<ID> countryIDSet = new set<Id>();
    set<ID> stateIDSet = new set<ID>();
    Set<ID> leadIds = new Set<ID>();
    Boolean isPortal = false;
    User portalUser;
     
    for (User user : [Select ID,Contact.Account.OwnerId From User where ID = :Userinfo.getUserId() AND ContactID != null limit 1]) {
		isPortal = true;	
		portalUser = user; 
	}
    for(Lead lead : trigger.new){
        if(lead.country != null && lead.country != '')
            countryNameSet.add(lead.country.tolowercase());
        if(lead.state != null && lead.state != '')
            stateNameSet.add(lead.state.tolowercase());
    }
    
    for(Region__c reg : [Select id , name from Region__c where name in: countryNameSet AND name != null]){
        countryNameId.put(reg.name.tolowercase() , reg.Id);
    }
    
    for(State_Province__c state :[Select id , name from State_Province__c where name in :stateNameSet AND name != null]){
        stateNameId.put(state.name.tolowercase() , state.Id);
    }   
        
    for(Lead lead : trigger.new){
            if((lead.PostalCode != null && trigger.isInsert) ||
              (trigger.isUpdate && trigger.oldMap.get(lead.id).PostalCode != lead.PostalCode)){
                lead.Zip_Code__c = lead.PostalCode;
            }
            if((lead.City != null && trigger.isInsert) ||
              (trigger.isUpdate && trigger.oldMap.get(lead.id).City != lead.City)){
                lead.City__c = lead.City;
            }
            if((lead.Street != null && trigger.isInsert) ||
              (trigger.isUpdate && trigger.oldMap.get(lead.id).Street != lead.Street)){
                lead.Street__c = lead.Street;
            }
            if((lead.Country != null && trigger.isInsert) ||
              (trigger.isUpdate && trigger.oldMap.get(lead.id).Country != lead.Country)){
                if(lead.Country != null && countryNameId.ContainsKey(lead.Country.tolowercase())){
                    lead.Country__c = countryNameId.get(lead.country.tolowercase());
                }else{
                    lead.Country__c = null;
                }
            }
            if((lead.State != null && trigger.isInsert) ||
              (trigger.isUpdate && trigger.oldMap.get(lead.id).State != lead.State)){
                if(lead.State != null && stateNameId.ContainsKey(lead.State.tolowercase())){
                    lead.State_Province__c = stateNameId.get(lead.State.tolowercase());
                }else{
                    lead.State_Province__c = null;
                }    
            }           
    }
    
    for(Lead lead : Trigger.new) {
    	if(lead.Country__c != null)
            countryIDSet.add(lead.Country__c);
        if(lead.State_Province__c != null)
            stateIDSet.add(lead.State_Province__c);
    }    
     for(Region__c reg : [Select id , name from Region__c where ID in: countryIDSet AND name != null]){
       countryIdName.put(reg.Id , reg.name);
    }    
    for(State_Province__c state :[Select id , name from State_Province__c where ID in :stateIdSet AND name != null]){
        stateIdName.put(state.Id , state.name);
    } 
    for(Lead lead : Trigger.new) {
    	if((trigger.isInsert || trigger.isUpdate) && lead.PostalCode == null && lead.City == null && lead.Street == null
    			&& lead.Country == null && lead.State == null) {
    			lead.City = lead.City__c;
    			lead.PostalCode = lead.Zip_Code__c;
    			lead.Street = lead.Street__c;
    			lead.Country = countryIdName.get(lead.Country__c);
    			lead.State = stateIdName.get(lead.State_Province__c);
    	}
    	// All lead created From Portal are marked validate = true and Account_Manager__c = Account Owner of the logged in portal user
    	if(isPortal && trigger.isInsert){ 
    		lead.Validated__c = true;
    		lead.Account_Manager__c = portalUser.Contact.Account.OwnerId;
    	}
    }
}