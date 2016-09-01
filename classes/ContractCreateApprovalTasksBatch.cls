global class ContractCreateApprovalTasksBatch implements Database.Batchable<Task>{ 

	global List<Task> lstTasks;

	global ContractCreateApprovalTasksBatch(List<Task> lstTasks){		
		this.lstTasks = lstTasks;
	}
	
	global Iterable<Task> start(Database.BatchableContext BC){
		return this.lstTasks;
	}
	global void execute(Database.batchableContext BC, List<Task> scope){
		Contract__c contRec;
        ApprovalEmailTemplateMapping__c custEmailTemplate;
		DOW_Report_Setting__c dow = DOW_Report_Setting__c.getInstance('Integrated');
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
		for(Task tsk: scope) {       
            if (tsk.WhatId != null && tsk.WhatId.getSobjectType() == Contract__c.SObjectType){      
                if (tsk.Contract_Stage__c != null && tsk.Contract_Stage__c.contains('Sales'))
                    custEmailTemplate = ApprovalEmailTemplateMapping__c.getInstance('To Be Approved');
                else if (tsk.Contract_Stage__c != null)
                    custEmailTemplate = ApprovalEmailTemplateMapping__c.getInstance(tsk.Contract_Stage__c);
                if (custEmailTemplate != null)
                {
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();  
                    msg.setTemplateId(custEmailTemplate.Email_Template_ID__c); 
                    msg.setTargetObjectId((Id)dow.Email_To_Contact__c); 
                    msg.setWhatId(tsk.WhatId);
                    msg.setSaveAsActivity(false);
                    msg.setReplyTo('noreply@danfoss.com');
                    Savepoint sp = Database.setSavepoint(); 
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});
                    Database.rollback(sp);        
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTargetObjectId(tsk.OwnerId);                    
                    email.setSaveAsActivity(false);
                    email.setPlainTextBody(msg.getPlainTextBody());  
                    email.setHTMLBody(msg.getHtmlBody() + '</br></br><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + tsk.Id + '">Link to Task</a>'); 
                    email.setSubject(msg.getSubject());
                    lstMsgsToSend.add(email);
                }
                else
                {
					contRec = [select Name from Contract__c where Id = :tsk.WhatId];
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();           
                    mail.setTargetObjectId(tsk.OwnerId);
                    mail.setSubject(contRec.Name + ' Task: ' + tsk.Subject);  
                    String template = 'You have been assigned the following new task for Contract: ' + contRec.Name + '\n\n';
                    template+= 'Subject: ' + tsk.Subject + '\n\n';
                    if(tsk.Description != null)
    					template+= 'Comments: ' + tsk.Description + '\n\n';
                    template+= 'For more details, click the following link:\n\n';
                    template+= URL.getSalesforceBaseUrl().toExternalForm() + '/' + tsk.Id;
                    mail.setSaveAsActivity(false);
                    mail.setPlainTextBody(template); 
                    lstMsgsToSend.add(mail);
                }
        }
        if (!lstMsgsToSend.isEmpty())
            Messaging.SendEmail(lstMsgsToSend);
            }
	}

	global void finish(Database.batchableContext info){
		 System.debug('Success');
	}
}