public class ContractApprovalsExtension
{
    public Contract__c Contract{get;set;}
    static Id ApprovalrecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Task').getRecordTypeId();
    static Id CollabrecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Collaboration Task').getRecordTypeId();
	static Id ContractLegacyRecTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Legacy Contract').getRecordTypeId();
	public Boolean legacy{get;set;}
	
    public ContractApprovalsExtension(ApexPages.StandardController stdController) {
        this.Contract = [Select Id, Expected_Approver__c, Expected_Approver__r.Name, Expected_Role__c, RecordTypeId, Contract_Status__c From Contract__c where Id = :stdController.getRecord().id];   
		if(Contract.RecordTypeId == ContractLegacyRecTypeId)
			legacy = true;
    }
        
    public List<Task> getTasks()    //Approval tasks
    {
        List<Task> lstRtnTasks = new List<Task>();
        Map<String, Task> mapStageandTasks = new Map<String, Task>();   
        
        for (Task t :[Select Id, WhatId, Subject, Description, IsClosed, OwnerId, Owner.Name, Contract_Stage__c, Contract_Approved_Time__c, Status from Task where WhatId =:Contract.Id and RecordTypeId = :ApprovalrecTypeId order by Contract_Approved_Time__c ASC NULLS LAST]){  //existing task records (currently pending or already approved tasks)
            if(!t.Contract_Stage__c.contains('_'))
				mapStageandTasks.put(t.Contract_Stage__c, t);
			else if(t.Status == 'Approved' || (t.Description != null && t.Description != ''))
				lstRtnTasks.add(t);
        }
        
        if(mapStageandTasks.containsKey(Contract.Expected_Role__c)){    //task for this role (s) already exists so use that task
			lstRtnTasks.add(mapStageandTasks.get(Contract.Expected_Role__c));
        }
        else if(Contract.Expected_Approver__c != null && (Contract.Contract_Status__c == 'Collaboration' || Contract.Contract_Status__c == 'Pending Approval')){     //no task yet for this role so use fake task
            lstRtnTasks.add(new Task(OwnerId = Contract.Expected_Approver__c, Contract_Stage__c = Contract.Expected_Role__c, Subject = Contract.Expected_Approver__r.Name));
        }
		            
        List <Task> lstHardCopyTasks = [Select Id, WhatId, Description, IsClosed, OwnerId, Owner.Name, Contract_Stage__c, Contract_Previous__c, Contract_Approved_Time__c, Subject, Status from Task where WhatId =:Contract.id and (Contract_Stage__c IN ('Sent_to_Customer__c', 'Returned__c', 'Filed__c') or (Contract_Stage__c = 'Signed__c' and Status = 'Completed')) order by Contract_Approved_Time__c ASC NULLS LAST];
        for (Task t:lstHardCopyTasks){
            lstRtnTasks.add(t);
        }

        return lstRtnTasks; 
    }
    
    public List<Task> getpastTasks()    //past Approval tasks if there is a rejection
    {
        return [Select Id, Description, Owner.Name, Contract_Stage__c, CreatedById, Contract_Previous__c, Contract_Approved_Time__c, Subject, Status from Task where WhatId =:Contract.Id and RecordTypeId = :ApprovalrecTypeId and isClosed = true and Contract_Previous__c = true order by Contract_Approved_Time__c DESC]; 
    }
      
    public List<Task> getCollabTasks()  //Collaboration tasks
    {
        return [Select WhoId,WhatId,Subject,Status,Description,Priority,OwnerId,IsClosed,Id,ActivityDate,AccountId From Task Where WhatId = :Contract.Id and RecordTypeId = :CollabrecTypeId ORDER BY ActivityDate]; 
    }
    
    public PageReference createTask(){  //create collaboration task
        return new PageReference('/00T/e?what_id='+Contract.Id+'&ent=Task&RecordType='+CollabrecTypeId+'&nooverride=1&retURL=%2F'+Contract.Id);
    }
    
    public List<Contract__History> getFieldHistory()
    {
        List<Contract__History> lstContHistory = new List<Contract__History>();
        for(Contract__History rec:[Select Id,parentid,field,NewValue,oldValue,CreatedById,CreatedBy.Name,CreatedDate 
                from Contract__History where parentid=:Contract.id and field ='Comments__c' order by CreatedDate DESC])
        {
            //Add changed comments to list.
            if(rec.newValue!=null)
                lstContHistory.add(rec);
        }  
        return lstContHistory;      
    }
}