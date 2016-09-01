public without sharing class CustomerRequestTriggerHandler{
	static Id InitialOwnerId;
	static Map<String, QueueSobject> mapCRQueues = new Map<String, QueueSobject>();
	final static String CUSTOMER_SERVICE_REP= 'Customer Service Rep';
    final static String SALES_SPECIALIST = 'Sales Specialist';
    final static String SYSTEM_APPLICATION_ENGINEER = 'Systems & Applications Engineer';
	static String CRtype;
	static Map<String, CRSettings__c> mapCRSettings = new Map<String, CRSettings__c>();
	
	//BEFORE INSERT (upon background insert) and BEFORE UPDATE
	public static void populateFields(List<PS_Customer_Request__c> lstReqs, set<Id> setAcctIds, map<Id, List<AccountTeamMember>> mapAccountTeamMembers, Map<Id, Product2> mapProducts, Boolean isInsert){
		Id SAE;
		Boolean validExclusive = true;
		for(CRSettings__c s :CRSettings__c.getall().values()){
			mapCRSettings.put(s.Order__c, s);
		}
		for(PS_Customer_Request__c cr :lstReqs){				
			if(cr.Product__c != null){
				validExclusive = checkValidExclusive(mapProducts.get(cr.Product__c).ProductCode, cr.Account__c);
				if(!validExclusive){
					cr.Product__c.addError('Material is exclusive to another customer.');
				}
			}
			cr.Requires_SAE_Review__c = CRSettings__c.getInstance(cr.Type__c).Requires_SAE_Review__c; 
			if(cr.Product__c != null ){
				cr.Material_Number__c = mapProducts.get(cr.Product__c).ProductCode;
				cr.Model_Code__c = mapProducts.get(cr.Product__c).Model_Code__c;
				cr.Business_Unit__c = mapProducts.get(cr.Product__c).Business_Unit__c;
				cr.Product_Set__c = mapProducts.get(cr.Product__c).Product_Set__c;
				if(cr.Type__c == 'System Model'){
					if(cr.Product_Second__c != null ){
						cr.Material_Number_Second__c = mapProducts.get(cr.Product_Second__c).ProductCode;
						cr.Model_Code_Second__c = mapProducts.get(cr.Product_Second__c).Model_Code__c;
						cr.Business_Unit_Second__c = mapProducts.get(cr.Product_Second__c).Business_Unit__c;
					}
					if(cr.Product_System__c != null ){
						cr.Material_Number_System__c = mapProducts.get(cr.Product_System__c).ProductCode;
						cr.Model_Code_System__c = mapProducts.get(cr.Product_System__c).Model_Code__c;
						cr.Business_Unit_System__c = mapProducts.get(cr.Product_System__c).Business_Unit__c;
					}
				}
			}
			if(mapAccountTeamMembers.containsKey(cr.Account__c)){
		        for(AccountTeamMember mem :mapAccountTeamMembers.get(cr.Account__c)){
					if(mem.TeamMemberRole == SALES_SPECIALIST){
						cr.Sales_Specialist__c = mem.UserId;
					}
					else if(mem.TeamMemberRole == CUSTOMER_SERVICE_REP){
						cr.CSR__c = mem.UserId;
					}
					else if(mem.TeamMemberRole == SYSTEM_APPLICATION_ENGINEER){
						SAE = mem.UserId;
					}
				}
			}
			if(cr.Opportunity__c != null){
				for(OpportunityTeamMember otm :[select Id, OpportunityId, TeamMemberRole, UserId from OpportunityTeamMember where OpportunityId = :cr.Opportunity__c]){
				if(otm.TeamMemberRole == SYSTEM_APPLICATION_ENGINEER){
						SAE = otm.UserId;
					}
				}
			}
			cr.SAE__c = SAE;			
        	
			if(cr.Type__c == 'Visitor Notification' && cr.ADC_Tour_Requested__c && (cr.Plant_of_Visit__c == 'AMS' || cr.Plant_of_Visit__c == 'NOR' || cr.Plant_of_Visit__c == 'NMS')){
				String plant;
				if(cr.Plant_of_Visit__c == 'AMS')
					plant = 'AMS';
				else
					plant = 'NOR';
				string adc = CRSettings__c.getInstance(plant + ' ' + 'ADC Tour Requested').Initial_Owner__c;
				cr.ADC_Contact__c = adc;
			}
			if(cr.Type__c =='Logistics Setup' && cr.Implement_Changes__c == 'No'){
				cr.Completed_Date__c = Datetime.now();
				cr.Status__c = 'Rejected';
			}
		}		
	}
	
	//BEFORE UPDATE
	public static void AssignRequest(List<PS_Customer_Request__c> lstReqs, Map<Id, PS_Customer_Request__c> mapReqs, set<Id> setAcctIds, map<Id, List<AccountTeamMember>> mapAccountTeamMembers){	
		for(QueueSobject q :[select Queue.DeveloperName from QueueSobject where SObjectType = 'PS_Customer_Request__c']){
			mapCRQueues.put(q.Queue.DeveloperName, q);
		}
        for(PS_Customer_Request__c cr :lstReqs){
			PS_Customer_Request__c crOld = mapReqs.get(cr.Id);
			String initOwner = CRSettings__c.getInstance(cr.Type__c).Initial_Owner__c;
			//New Product auto-completion
			if(cr.Type__c =='New Product' && cr.Completed_Date__c == null){
				cr.Completed_Date__c = Datetime.now();
				cr.Status__c = 'Completed';
			}
			if(cr.SubmittedInitially__c && !crOld.SubmittedInitially__c){	
				if(initOwner == 'Submit_To__c'){  //picklist of Business Unit or Sales Specialist/CSR
					if(cr.Submit_To__c == 'Business Unit')
						initOwner = 'BU'; 
					else{
						if(cr.Account_Region__c == 'Americas')
							InitialOwnerId = cr.Sales_Specialist__c; 
						else 
							InitialOwnerId = cr.CSR__c;
					}
				}
				if(initOwner == 'BU'){
					if((cr.Type__c == 'System Model' || cr.Type__c == 'Special Tests & Certificates') && cr.Primary_BU__c != null && cr.Primary_BU__c != ''){						
						String buq = 'CR_' + cr.Primary_BU__c.Replace(' ', '_');
						InitialOwnerId = mapCRQueues.get(buq).QueueId;
					}
					else if(cr.Business_Unit__c != null && cr.Business_Unit__c != ''){
						String buq = 'CR_' + cr.Business_Unit__c.Replace(' ', '_');
						InitialOwnerId = mapCRQueues.get(buq).QueueId;
					}
				}
				else if(initOwner.startsWith('CR_')){
					InitialOwnerId = mapCRQueues.get(initOwner).QueueId;
				}

				if(InitialOwnerId != null){
        			cr.OwnerId = InitialOwnerId;
				}
				else{
	        		cr.OwnerId = mapCRQueues.get('CR_Admin').QueueId;
				}		
			}
        } 
	}  
	
	//AFTER INSERT
	public static void FollowRequest(List<PS_Customer_Request__c> lstReqs){
		List<EntitySubscription> lstES = new List<EntitySubscription>();
		for(PS_Customer_Request__c cr :lstReqs){
			EntitySubscription follow = new EntitySubscription(ParentId = cr.Id, SubscriberId = cr.CreatedById);
			lstES.add(follow);
		}
		if(!lstES.isEmpty())
			insert lstES;
	}
	
	//AFTER UPDATE
	public static void FollowRequest(List<PS_Customer_Request__c> lstReqs, Map<Id, PS_Customer_Request__c> mapReqs){
		List<EntitySubscription> lstES = new List<EntitySubscription>();
		Set<Id> setparentIDsdel = new Set<Id>();
		Set<Id> setsubsIDsdel = new Set<Id>();
		Boolean delESlist = false;
		for(PS_Customer_Request__c cr :lstReqs){
			PS_Customer_Request__c crOld = mapReqs.get(cr.Id);
			if(crOld.TookOwnership__c == null && cr.TookOwnership__c != null && cr.CreatedById != cr.TookOwnership__c){
				EntitySubscription follow = new EntitySubscription(ParentId = cr.Id, SubscriberId = cr.TookOwnership__c);
				lstES.add(follow);
			}
			if(crOld.Status__c != 'Completed' && cr.Status__c == 'Completed'){
				delESlist = true;
				setparentIDsdel.add(cr.Id);
				setsubsIDsdel.add(cr.TookOwnership__c);
				setsubsIDsdel.add(cr.CreatedById);
			}
		}
		if(!lstES.isEmpty())
			insert lstES;
		if(delESlist)
			delete [select Id from EntitySubscription where ParentId IN :setparentIDsdel and SubscriberId IN :setsubsIDsdel LIMIT 1000];
	}

	//AFTER UPDATE
	public static void OtherUpdates(List<PS_Customer_Request__c> lstReqs, Map<Id, PS_Customer_Request__c> mapReqs, set<Id> setAcctIds){
		Boolean updateOppty = false;
		Boolean updateOLI = false;
		Set<Id> setOpptys = new Set<Id>();
		Set<Id> setOLIs = new Set<Id>();
		Map<Id, Opportunity> mapOpptys;
		Map<Id, OpportunityLineItem> mapOLIs;
		for(PS_Customer_Request__c cr :lstReqs){
			if(cr.Opportunity__c != null)
				setOpptys.add(cr.Opportunity__c);
			if(cr.OpptyLineItemID__c != null && cr.OpptyLineItemID__c != '')
				setOLIs.add(cr.OpptyLineItemID__c);
		}
		mapOpptys = new Map<Id, Opportunity>([select Id, Application__c, Used_Application_Development_Center__c from Opportunity where Id IN :setOpptys]);
		mapOLIs = new Map<Id, OpportunityLineItem>([select Id, Customer_Material_Number__c from OpportunityLineItem where Id IN :setOLIs]);
		for(PS_Customer_Request__c cr :lstReqs){
			if(cr.Opportunity__c != null){
				if((cr.Application__c != null && mapOpptys.get(cr.Opportunity__c).Application__c == null) || (cr.Type__c == 'Visitor Notification' && cr.ADC_Tour_Requested__c != null && mapOpptys.get(cr.Opportunity__c).Used_Application_Development_Center__c == null)){
					mapOpptys.get(cr.Opportunity__c).Application__c = cr.Application__c;
					mapOpptys.get(cr.Opportunity__c).Used_Application_Development_Center__c = true;
					updateOppty = true;
				}
				if(cr.Customer_Material_Number__c != null && mapOLIs.get(cr.OpptyLineItemID__c).Customer_Material_Number__c == null){
					mapOLIs.get(cr.OpptyLineItemID__c).Customer_Material_Number__c = cr.Customer_Material_Number__c;
					updateOLI = true;
				}
			}
		}
		if(updateOppty)
			update mapOpptys.values();
		if(updateOLI)
			update mapOLIs.values();
	}
	
	//AFTER UPDATE
	public static void CreateFollowupTasks(List<PS_Customer_Request__c> lstReqs, Map<Id, Account> mapAccts, Map<Id, PS_Customer_Request__c> mapReqs){
		Task tsk = new Task();
		for(PS_Customer_Request__c cr :lstReqs){
			PS_Customer_Request__c crOld = mapReqs.get(cr.Id);
			if(cr.Requires_SAE_Review__c && crOld.Status__c != 'Completed' && cr.Status__c == 'Completed'){
				tsk = new Task(WhatId = cr.Id, Type = 'CRPost', Subject = 'Verify Customer Cross Reference and Material Determination');	
				tsk.Description = 'This customer request for ' + mapAccts.get(cr.Account__c).Name + ' was completed. Do the following: \n\n';
				tsk.Description += '1. Create/Update/Verify that the Customer Cross Reference is Correct for all Sales Orgs per SW-3380. \n';
				tsk.Description += '2. Create/Update/Verify that material determination is set for each SAP account that will need to purchase this product. \n\n';
				tsk.Description += 'When you have completed these actions, change the status of the task to Completed. \n';
				if(cr.Account_Region__c == 'Americas' && cr.Sales_Specialist__c != null)
					tsk.OwnerId = cr.Sales_Specialist__c; 
				else if(cr.CSR__c != null)
					tsk.OwnerId = cr.CSR__c;
				if(tsk.OwnerId != null)
					insert tsk;
				
				tsk = new Task(WhatId = cr.Id, Type = 'CRPost', Subject = 'Verify Need for Quote');	
				tsk.Description = 'This customer request for ' + mapAccts.get(cr.Account__c).Name + ' was completed. Do the following: \n\n';
				tsk.Description += 'Create a new quote, if needed, and send to the customer. If necessary, change the owner of the task to your inside sales support person so they can issue the quote. Once the quote is sent, change the status of the task to Completed.\n\n';
				tsk.Description += 'If a new quote is not needed, change the status of the task to Completed.';
				tsk.OwnerId = mapAccts.get(cr.Account__c).OwnerId; 
				insert tsk;				
			}
		}
	}
		
	//AFTER UPDATE
	public static void updateOpportunityLineItem(List<PS_Customer_Request__c> lstReqs, Map<Id, PS_Customer_Request__c> mapReqs){
		for(PS_Customer_Request__c cr :lstReqs){
			PS_Customer_Request__c crOld = mapReqs.get(cr.Id);
			if((cr.Status__c == 'In Progress' || cr.Status__c == 'In SAE Review') && cr.Requires_SAE_Review__c){	//only run for New Material Number, New Product Feature and System Model
				if(cr.Requested_Model_Code__c == cr.Model_Code__c && cr.OpptyLineItemID__c != null && crOld.OpptyLineItemID__c == cr.OpptyLineItemID__c){// && crOld.Product__c == cr.Product__c){
					PriceManagement.GetSAPPriceOLI(cr.OpptyLineItemID__c, cr.Product__c);
				}
			}
		}
	}	
	
	//AFTER UPDATE
	public static void cancelOpenTasks(List<PS_Customer_Request__c> lstReqs, Map<Id, PS_Customer_Request__c> mapReqs){
		List<Task> lstTasks = new List<Task>();
		Map<Id, Task> mapTasks = new Map<Id, Task>();
		for(Task tsk :[select Id, Status, WhatId from Task where WhatId IN :mapReqs.keySet() and isClosed = false])
			mapTasks.put(tsk.WhatId, tsk);
		for(PS_Customer_Request__c cr :lstReqs){
			PS_Customer_Request__c crOld = mapReqs.get(cr.Id);
			if(crOld.Status__c != 'Cancelled' && cr.Status__c == 'Cancelled' && mapTasks.get(cr.Id) != null){
				mapTasks.get(cr.Id).Status = 'Cancelled';
				lstTasks.add(mapTasks.get(cr.Id));
			}
		}
		update lstTasks;
	}

 	private static Boolean checkValidExclusive(String pcode, Id accountId){
	    Boolean ret = true;
	    list<Id> exclAccnt = new list<Id>();
	    if (pcode != null && pcode != ''){
	        for(Exclusive_Material__c exAccount : [select Account__c from Exclusive_Material__c WHERE isDeleted__c = false and Product__r.ProductCode =:pcode]) {
	            if(exAccount.Account__c != null) {
	             exclAccnt.add(exAccount.Account__c);
	            }
	        }
	        if (!exclAccnt.isEmpty()){
	            ret = false;
	            for(Id accId : exclAccnt){
	                if (accId == accountId){
	                    ret = true;
	                }
	            }           
	        }
	    }
	    return ret;
	 } 	
}