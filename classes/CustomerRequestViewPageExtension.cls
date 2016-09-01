public with sharing class CustomerRequestViewPageExtension{
	
	public List<Task> lstTasks{get;set;}  	  
	public List<Task> lstTasksSales{get;set;}  
	public List<Task> lstTasksSalesClosed{get;set;}  
    public PS_Customer_Request__c custreq{get;set;}
    static Id DanfosstaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Danfoss Task').getRecordTypeId();
	static Id BUtaskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Customer Request BU Task').getRecordTypeId();
    static Id CollabrecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Collaboration Task').getRecordTypeId();
    public Boolean showBUSection {get;set;} 		
	
    public CustomerRequestViewPageExtension(ApexPages.StandardController controller){
		Id creqId = controller.getId();
		this.custreq = [select Name, OwnerId, Type__c, SubmittedInitially__c, SentToBU__c, BUReviewComplete__c from PS_Customer_Request__c where Id = :creqId];
        if(custreq != null){
            lstTasks = fetchTasks();
            lstTasksSales = fetchTasksSales();
            lstTasksSalesClosed = fetchTasksSalesClosed();
        }
		showBUSection = CRSettings__c.getInstance(custreq.Type__c).Needs_BU_Routing_Section__c;
		ApexPages.getMessages().clear();
    }
		
    private List<Task> fetchTasks(){
        List<Task> lstTasks = new List<Task>();        
        for (Task  task : [Select Id, WhoId, WhatId, Subject, Status,Order__c, CreatedById, Description, OwnerId, ActivityDate, Est_Start_Date__c ,Actual_Finish_Date__c, Actual_Start_Date__c, Completed_By__c, AccountId 
						  From Task Where WhatId = :custreq.Id and RecordTypeId = :BUtaskRecTypeId and Order__c != null ORDER BY Order__c, ActivityDate]) { 
            lstTasks.add(task);            
        }       
        return lstTasks;
    }
	
	private List<Task> fetchTasksSales(){
        List<Task> lstTasks = new List<Task>();        
        for (Task  task : [Select WhoId,WhatId,Subject,Status,Description,Priority,OwnerId,IsClosed,Id,ActivityDate,AccountId
						  From Task Where WhatId = :custreq.Id and (RecordTypeId = :CollabrecTypeId or RecordTypeId = :DanfosstaskRecordTypeId) and IsClosed = false ORDER BY ActivityDate]) { 
            lstTasks.add(task);            
        }       
        return lstTasks;
    }
	
	private List<Task> fetchTasksSalesClosed(){
        List<Task> lstTasks = new List<Task>();        
        for (Task  task : [Select WhoId,WhatId,Subject,Status,Description,Priority,OwnerId,IsClosed,Id,ActivityDate,AccountId
						  From Task Where WhatId = :custreq.Id and (RecordTypeId = :CollabrecTypeId or RecordTypeId = :DanfosstaskRecordTypeId) and IsClosed = true ORDER BY ActivityDate]) { 
            lstTasks.add(task);            
        }       
        return lstTasks;
    }
	
	public PageReference createTaskSales(){
		return new PageReference('/00T/e?what_id='+custreq.Id+'&ent=Task&nooverride=1&RecordType='+CollabrecTypeId+'&retURL=%2F'+custreq.Id);
	}
	
	public PageReference createTaskBU(){
        return new PageReference('/apex/CustomerRequestNewBUTask?crID='+custreq.Id+'&crname='+custreq.name+'&rectype=BU&rectype=BU&retURL=%2F'+custreq.Id);
	}
	
	public PageReference submitToBU(){
		string lowestOrder = '0';
		List<Task> lstTasks = [select WhatId, Order__c, Status, ActivityDate, Actual_Start_Date__c, Subject, OwnerId, Description from Task where WhatId = :custreq.Id and Status = 'Not Started' and Order__c != null order by Order__c asc];
		if(!lstTasks.isEmpty() && lstTasks[0].Order__c != null && lstTasks[0].Order__c != '')
			lowestOrder = lstTasks[0].Order__c;
		List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
		if(!lstTasks.isEmpty()){
			for(Task tsk :lstTasks){
				if (tsk.Order__c == lowestOrder){
					Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();  
					msg.setTargetObjectId(tsk.OwnerId);
					String template = 'A new task has been assigned to you. Please review and complete. \n\n';
					template +='Subject: ' + tsk.Subject + '\n';
					if (tsk.ActivityDate != null) {
						DateTime ad = tsk.ActivityDate;
						template +='Due Date: '+ ad.format('dd-MMM-yyyy')+ '\n\n';
					}
					template +='For more details, click the following link: \n';
					template +=URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ tsk.Id;
					msg.setSaveAsActivity(false);
					msg.setPlainTextBody(template);
					msg.setSubject(custreq.Type__c + ' Customer Request ' + custreq.Name + ' is ready for your review');
					lstMsgsToSend.add(msg);
					tsk.Status = 'In Progress';
					tsk.Actual_Start_Date__c = Date.today();
				}
			}
		}
		else{				
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No future reviewers found.'));
            return null;
		}
		
        if (!lstMsgsToSend.isEmpty()){
			custreq.SentToBU__c = true;
			custreq.BUReviewComplete__c = false;	//set back to false so if this is a subsequent submit the flag can be set again to trigger the email to owner
			update custreq;
			update lstTasks;
            Messaging.SendEmail(lstMsgsToSend);	
		}
		return new PageReference('/' + custreq.Id);
	}
}