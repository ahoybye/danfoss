public with sharing class TaskTriggerHandler{

    private static Id DanfosstaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Danfoss Task').getRecordTypeId();
    private static Id CRBUtaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Customer Request BU Task').getRecordTypeId();
	private static Id MEtaskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Material Extension Task').getRecordTypeId();
    private static Id CollabrecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Collaboration Task').getRecordTypeId();
	
    public static void ProcessPardotTasks (List<Task> lstTasks) // BEFORE INSERT
    {
        set<Id> setContactIds = new set<Id>();
        for(Task tsk :lstTasks){
            if(tsk.RecordTypeId == DanfosstaskRecordTypeId && tsk.WhatId == null && tsk.WhoId != null && tsk.WhoId.getSobjectType() == Contact.SObjectType && tsk.Subject.contains('Exhibition Follow-up Task:'))
            {
                setContactIds.add(tsk.WhoId);       
            }
        }
        Map<Id, Contact> mapContacts = new Map<Id, Contact>([select Id, PS_Tradeshow_Comments__c from Contact where Id IN :setContactIds]);
        for(Task tsk :lstTasks){
            if(mapContacts.containsKey(tsk.WhoId))
                tsk.Description = mapContacts.get(tsk.WhoId).PS_Tradeshow_Comments__c;
        }
    } 

    public static void clearTypeNonNPF (List<Task> lstTasks) // BEFORE INSERT
    {
        set<Id> setCustReqIds = new set<Id>();
        for(Task tsk :lstTasks){
            if(tsk.RecordTypeId == CollabrecTypeId && tsk.WhatId != null && tsk.WhatId.getSobjectType() == PS_Customer_Request__c.SObjectType){
                setCustReqIds.add(tsk.WhatId);       
            }
        }
        Map<Id, PS_Customer_Request__c> mapCustReqs = new Map<Id, PS_Customer_Request__c>([select Id, Type__c from PS_Customer_Request__c where Id IN :setCustReqIds]);
        for(Task tsk :lstTasks){
            if(mapCustReqs.containsKey(tsk.WhatId) && mapCustReqs.get(tsk.WhatId).Type__c != 'New Product Feature')
                tsk.Type = '';
        }
    }      
    
    public static void StampCompletedDate(List<Task> lstTasks, Map<Id, Task> mapTasks) // BEFORE UPDATE
    {
         for(Task tsk: lstTasks) 
         {
             Task taskOld = mapTasks.get(tsk.Id);        
             if ((tsk.RecordTypeId == DanfosstaskRecordTypeId || tsk.RecordTypeId == CollabrecTypeId) && (taskOld.Status != tsk.Status && tsk.Status == 'Completed'))
             {
                tsk.Completed_Date__c = System.now();
             }
         }
    }
    
    public static void ProcessCRTasks (List<Task> lstTasks, Map<Id, Task> mapTasks) // BEFORE UPDATE
    {
		Integer CurrentOrder;
        String NextOrder;       
        List<Task> lstCurrentOrderTasks = new List<Task>();
        List<Task> lstNextOrderTasks = new List<Task>();
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        Set<Id> setCustReqIds = new Set<Id>();
        Set<Id> setProdIds = new Set<Id>();
        Map<Id, PS_Customer_Request__c> mapCustReqs = new Map<Id, PS_Customer_Request__c>();
        Map<Id, Product2> mapProds = new Map<Id, Product2>();
        for(Task tsk :lstTasks){
            if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == Product2.SObjectType)
                setProdIds.add(tsk.WhatId);
            else if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == PS_Customer_Request__c.SObjectType)
                setCustReqIds.add(tsk.WhatId);
            if((tsk.RecordTypeId == CRBUtaskRecordTypeId || tsk.RecordTypeId == MEtaskRecTypeId) && tsk.WhatId != null && tsk.Order__c != null && tsk.Order__c != ''){
                CurrentOrder = integer.valueOf(tsk.Order__c); // order on this task
                NextOrder = String.valueOf(CurrentOrder+1);
                Task taskOld = mapTasks.get(tsk.Id);        
                if(taskOld.Status != tsk.Status && tsk.Status == 'Completed'){
                    tsk.Completed_By__c = UserInfo.getUserId();
                    lstCurrentOrderTasks = [select Order__c from task where WhatId = :tsk.WhatId and Order__c = :tsk.Order__c and Status != 'Completed' and Id != :tsk.Id];
                    if(lstCurrentOrderTasks.isEmpty()){
                        lstNextOrderTasks = [select Order__c, Status, ActivityDate, Actual_Start_Date__c, Subject, OwnerId, WhatId, Description from task where WhatId = :tsk.WhatId and Order__c = :NextOrder and Status = 'Not Started'];
                    }
                }
            }
        }   
        if(!setCustReqIds.isEmpty())
            mapCustReqs = new Map<Id, PS_Customer_Request__c>([select id, Type__c, Name from PS_Customer_Request__c where Id IN :setCustReqIds]);
        else if(!setProdIds.isEmpty())
            mapProds = new Map<Id, Product2>([select id, ProductCode, Name from Product2 where Id IN :setProdIds]);
        if(!lstNextOrderTasks.isEmpty()){
            for(Task tsk :lstNextOrderTasks){
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();  
                msg.setTargetObjectId(tsk.OwnerId);  
                String template = 'A new task has been assigned to you. Please review and complete. \n\n';
                template +='Subject: ' + tsk.Subject + '\n';
                if (tsk.ActivityDate != null) {
                    DateTime ad = tsk.ActivityDate;
                    template +='Due Date: '+ ad.format('dd-MMM-yyyy')+ '\n\n';
                }
                if(tsk.Description != null)
                    template +='Comments: '+ tsk.Description + '\n\n';
                template +='For more details, click the following link: \n';
                template +=URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ tsk.Id;
                msg.setSaveAsActivity(false);
                msg.setPlainTextBody(template); 
                string recName = '';
                if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == PS_Customer_Request__c.SObjectType)
                    recName = mapCustReqs.get(tsk.WhatId).Type__c + ' Customer Request ' + mapCustReqs.get(tsk.WhatId).Name;
                else if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == Product2.SObjectType)
                    recName = 'Material Extension task for ' + mapProds.get(tsk.WhatId).ProductCode + ' - ' + mapProds.get(tsk.WhatId).Name;
                msg.setSubject(recName + ' is ready for your review');
                lstMsgsToSend.add(msg);
                tsk.Status = 'In Progress';
                tsk.Actual_Start_Date__c = Date.today();
            }
            update lstNextOrderTasks;
        }
        if (!lstMsgsToSend.isEmpty())
            Messaging.SendEmail(lstMsgsToSend);
    }
    
    public static void NotifyAssignee(List <Task >lstTasks) // AFTER INSERT
    {
        List <Messaging.SingleEmailMessage >lstMsgsToSend = new List <Messaging.SingleEmailMessage >();
        Set<Id> setCustReqIds = new Set<Id>();     
        Set<Id> setOwnerIds = new Set<Id>();
        set<Id> setContractIds = new Set<Id>();
        for(Task tsk: lstTasks) {
            setOwnerIds.add(tsk.OwnerId);
            setOwnerIds.add(tsk.CreatedById);
            if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == Contract__c.SObjectType)
                setContractIds.add(tsk.WhatId);
            if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == PS_Customer_Request__c.SObjectType)
                setCustReqIds.add(tsk.WhatId);
        }  
        Map<Id, Contract__c> mapContracts = new Map<Id, Contract__c>([Select Id, Name From Contract__c where Id IN :setContractIds]);
        Map<Id, PS_Customer_Request__c> mapCustReqs = new Map<Id, PS_Customer_Request__c>([select id, Type__c, Name from PS_Customer_Request__c where Id IN :setCustReqIds]);
        Map<Id, User> mapUsers = new Map<Id, User>([Select Id, Name From User where Id IN :setOwnerIds]);
        for (Task tsk :lstTasks) {  //Customer Request post-completion task or Contract / Customer Request collaboration task
            if (!tsk.IsClosed && ((tsk.RecordTypeId == DanfosstaskRecordTypeId && tsk.WhatId != null && tsk.WhatId.getSobjectType() == PS_Customer_Request__c.SObjectType && tsk.Type != null && tsk.Type == 'CRPost')
             || tsk.RecordTypeId == CollabrecTypeId)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(tsk.OwnerId);
                String template = mapUsers.get(tsk.CreatedById).Name + ' has assigned you the following new task: '+ '\n\n';
                template +='Subject: '+ tsk.Subject + '\n';
                if (tsk.ActivityDate != null) {
                    DateTime ad = tsk.ActivityDate;
                    template +='Due Date: '+ ad.format('dd-MMM-yyyy')+ '\n';
                }
                if(tsk.Description != null)
                    template +='Comments: '+ tsk.Description + '\n\n';
                template +='For more details, click the following link: \n\n';
                template +=URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ tsk.Id;
                mail.setSaveAsActivity(false);
                mail.setPlainTextBody(template);
                if(tsk.WhatId.getSobjectType() == PS_Customer_Request__c.SObjectType)
                	mail.setSubject('New Task for ' + mapCustReqs.get(tsk.WhatId).Type__c + ' Customer Request ' + mapCustReqs.get(tsk.WhatId).Name + ' - ' + tsk.Subject);
                else if(tsk.WhatId.getSobjectType() == Contract__c.SObjectType)
                	mail.setSubject('New Task for Contract ' + mapContracts.get(tsk.WhatId).Name + ' - ' + tsk.Subject);
                lstMsgsToSend.add(mail);
            }
        }
        if (!lstMsgsToSend.isEmpty())
            Messaging.SendEmail(lstMsgsToSend);
    }  
	
	public static void NotifyAssigneeIfReassigned(List <Task >lstTasks, Map<Id, Task> mapTasks) // AFTER UPDATE
    {
		List <Messaging.SingleEmailMessage >lstMsgsToSend = new List <Messaging.SingleEmailMessage >();     
        Set<Id> setOwnerIds = new Set<Id>();		
        for(Task tsk: lstTasks) {
            setOwnerIds.add(tsk.OwnerId);
            setOwnerIds.add(tsk.CreatedById);
		}
		Map<Id, User> mapUsers = new Map<Id, User>([Select Id, Name From User where Id IN :setOwnerIds]);
        for (Task tsk :lstTasks) {				
            Task tskOld = mapTasks.get(tsk.Id);       
			if (!tsk.IsClosed && tsk.OwnerId != tskOld.OwnerId){
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(tsk.OwnerId);
                String template = mapUsers.get(tsk.CreatedById).Name + ' has assigned you the following task: '+ '\n\n';
                template +='Subject: '+ tsk.Subject + '\n';
                if (tsk.ActivityDate != null) {
                    DateTime ad = tsk.ActivityDate;
                    template +='Due Date: '+ ad.format('dd-MMM-yyyy')+ '\n';
                }
                if(tsk.Description != null)
                    template +='Comments: '+ tsk.Description + '\n\n';
                template +='For more details, click the following link: \n\n';
                template +=URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ tsk.Id;
                mail.setSaveAsActivity(false);
                mail.setPlainTextBody(template);
				mail.setSubject(tsk.Subject);
                lstMsgsToSend.add(mail);
            }
        }
        if (!lstMsgsToSend.isEmpty())
            Messaging.SendEmail(lstMsgsToSend);
    }  
  
    public static void updateCustomerRequest(Set<Id> setCustReqIds) // AFTER UPDATE
    {
        Map<Id, PS_Customer_Request__c> mapCustReqs = new Map<Id, PS_Customer_Request__c>();
        List<Task> lstTasks = new List<Task>([select Id, WhatId, Status from task where WhatId IN :setCustReqIds and RecordTypeId = :CRBUtaskRecordTypeId and (Status = 'Not Started' or Status = 'In Progress')]);
        List<PS_Customer_Request__c> lstCustReqs = new List<PS_Customer_Request__c>([Select Id, Status__c, BUReviewComplete__c From PS_Customer_Request__c where Id IN :setCustReqIds]);
        for(PS_Customer_Request__c custreq :lstCustReqs){			
			if(lstTasks.isEmpty() && custreq.Status__c != 'Cancelled'){	//if there are no open tasks for this customer request, BU review is complete
                custreq.BUReviewComplete__c = true; 
                mapCustReqs.put(custreq.Id, custreq);
            }
        }
        if(!mapCustReqs.isEmpty())
            update mapCustReqs.values();
    }
    
    public static void NotifyCreatorUponCompletion (List<Task> lstTasks, Map<Id, Task> mapTasks)    // AFTER UPDATE
    {
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        Set<Id> setCustReqIds = new Set<Id>();     
        Set<Id> setOwnerIds = new Set<Id>();
        set<Id> setContractIds = new Set<Id>();
        Set<Id> setProdIds = new Set<Id>();
        for(Task tsk: lstTasks) {
            setOwnerIds.add(tsk.OwnerId);
            if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == Product2.SObjectType)
                setProdIds.add(tsk.WhatId);
            else if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == Contract__c.SObjectType)
                setContractIds.add(tsk.WhatId);
            else if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == PS_Customer_Request__c.SObjectType)
                setCustReqIds.add(tsk.WhatId);
        }
        Map<Id, User> mapOwners = new Map<Id, User>([Select Id, Name From User where Id IN :setOwnerIds]);
        Map<Id, PS_Customer_Request__c> mapCustReqs = new Map<Id, PS_Customer_Request__c>([select id, Type__c, Name from PS_Customer_Request__c where Id IN :setCustReqIds]);
        Map<Id, Contract__c> mapContracts = new Map<Id, Contract__c>([Select Id, Name From Contract__c where Id IN :setContractIds]);
        Map<Id, Product2> mapProds = new Map<Id, Product2>([select id, ProductCode, Name from Product2 where Id IN :setProdIds]);
        for(Task tsk: lstTasks) {
            Task taskOld = mapTasks.get(tsk.Id);
            if(taskOld.Status != tsk.Status && tsk.Status == 'Completed' && tsk.Actual_Finish_Date__c == null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();           
                mail.setTargetObjectId(tsk.CreatedById);
                String template = 'The task you assigned to ' + mapOwners.get(tsk.OwnerId).Name + ' on ' + tsk.CreatedDate.format('dd-MMM-yyyy') + ' has been marked completed. \n\n';
                if (tsk.Closing_Comments__c != '' && tsk.Closing_Comments__c != null)
                    template+= 'Closing Comments: ' + tsk.Closing_Comments__c + '\n\n';
                template+= URL.getSalesforceBaseUrl().toExternalForm() + '/' + tsk.Id;
                mail.setSaveAsActivity(false);
                mail.setPlainTextBody(template); 
                string recName = '';
                if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == PS_Customer_Request__c.SObjectType)
                    recName = mapCustReqs.get(tsk.WhatId).Type__c + ' Customer Request ' + mapCustReqs.get(tsk.WhatId).Name;
                else if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == Contract__c.SObjectType)
                    recName = mapContracts.get(tsk.WhatId).Name;
                else if(tsk.WhatId != null && tsk.WhatId.getSobjectType() == Product2.SObjectType)
                    recName = 'Material Extension: ' + mapProds.get(tsk.WhatId).ProductCode + ' - ' + mapProds.get(tsk.WhatId).Name;
                if (tsk.RecordTypeId == CollabrecTypeId || tsk.RecordTypeId == MEtaskRecTypeId){   //only for collaboration customer request and contract tasks, not approval and hard-copy contract tasks, or material extension tasks
                    mail.setSubject(recName + ': '+ tsk.Subject + ' - Task has been Completed');
                    lstMsgsToSend.add(mail);
                }
                else if(tsk.RecordTypeId == DanfosstaskRecordTypeId){   //standard task created manually by user
                    mail.setSubject(tsk.Subject + ' - Task has been Completed');
                    lstMsgsToSend.add(mail);
                }         
            }
        }
        if(!lstMsgsToSend.isEmpty())
            Messaging.SendEmail(lstMsgsToSend);
    }
}