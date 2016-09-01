public with sharing class CustomerRequestBURoutingController{

	public Product2 prod{get;set;}
	private static Id MErecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Material Extension Task').getRecordTypeId();
	
	public CustomerRequestBURoutingController(ApexPages.StandardController controller){
		prod = [select Id, ProductCode, Name from Product2 where Id = :controller.getId()];
    }
	
	public PageReference submitToBU(){		
		string lowestOrder = '0';
		List<Task> lstTasks = [select WhatId, Order__c, Status, ActivityDate, Actual_Start_Date__c, Subject, OwnerId, Description from Task 
							   where WhatId = :prod.Id and RecordTypeId = :MErecTypeId and Status = 'Not Started' order by Order__c asc];
		if(!lstTasks.isEmpty() && lstTasks[0].Order__c != null && lstTasks[0].Order__c != '')
			lowestOrder = lstTasks[0].Order__c;
		List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
		for(Task tsk :lstTasks){
			if(tsk.Order__c == lowestOrder){
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
				msg.setSubject('Material Extension task for '+ prod.ProductCode + ' - ' + prod.Name + ' is ready for your review');
				lstMsgsToSend.add(msg);				
				tsk.Status = 'In Progress';
				tsk.Actual_Start_Date__c = Date.today();
			}
		}
        if (!lstMsgsToSend.isEmpty()){
			update lstTasks;
            Messaging.SendEmail(lstMsgsToSend);	
        }

		return new PageReference('/' + prod.Id);
	}
}