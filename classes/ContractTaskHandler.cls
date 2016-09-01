public without sharing class ContractTaskHandler{
	
	static Id record_Type_Contract = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Task').getRecordTypeId();
	static Id record_Type_ContractExpired = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Expired Task').getRecordTypeId();
	static Id record_Type_ContractHardCopy = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Hard Copy Task').getRecordTypeId();
	
    public static void SendEmailForContractTasksBATCH(Set<Id> setTaskIDs)     // AFTER INSERT - send email from contract task using template
    {
        List<Task> lstTasks = [select Id, WhatId, Contract_Stage__c, OwnerId, Subject, Description From Task where Id IN :setTaskIDs];
        ContractCreateApprovalTasksBatch contBatch = new ContractCreateApprovalTasksBatch(lstTasks);
        ID batchprocessid = Database.executeBatch(contBatch,lstTasks.size());
    }
    
    public static void SendEmailForContractTasks(List<Task> lstTasks)     // AFTER INSERT - send email from contract task using template
    {
        Contract__c contRec;
        ApprovalEmailTemplateMapping__c custEmailTemplate;
        DOW_Report_Setting__c dow = DOW_Report_Setting__c.getInstance('Integrated');
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        for(Task tsk: lstTasks) {        
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
                    template+= 'Comments: ' + tsk.Description + '\n\n';
                    template+= 'For more details, click the following link:\n\n';
                    template+= URL.getSalesforceBaseUrl().toExternalForm() + '/' + tsk.Id;
                    mail.setSaveAsActivity(false);
                    mail.setPlainTextBody(template); 
                    lstMsgsToSend.add(mail);
                }
            }
        }
        if (!lstMsgsToSend.isEmpty())
            Messaging.SendEmail(lstMsgsToSend);
    }
    
    public static void StampContractApprovalTime(List<Task> lstTasks)    // BEFORE UPDATE
    {
         for(Task tsk: lstTasks) 
         {
             if (tsk.Contract_Stage__c != '' && tsk.Contract_Stage__c != null && tsk.Status != 'Pending' && tsk.Contract_Approved_Time__c == null)
             {
                tsk.Contract_Approved_Time__c = System.now();
             }
         }
    }
    
    public static void ContractApprovalFromTask(List<Task> lstTasks)        // AFTER UPDATE - passes info from task to contract
    {
        string strContractIds = '';
        List<Task> lstClosedContractTasks = new List<Task>();
        for (Task t :lstTasks){
            system.debug('task: ' + t);
            if (t.IsClosed && t.Contract_Stage__c != '' && t.Contract_Stage__c != null){
                strContractIds = t.WhatId;
                lstClosedContractTasks.add(t);      
            }
        }
        if (strContractIds=='') return;
        String sqlQuery = 'select Id, Hard_Copy_Done__c, Signed__c, Sent_to_Customer__c, Returned__c, Filed__c';
        Contract__c Contract = Database.Query(sqlQuery + ' From Contract__c where Id =\''+ strContractIds+'\'');
        
        for (Task t :lstClosedContractTasks){
			if (t.Status == 'Approved' && t.recordTypeId == record_Type_Contract){
				Contract.Submit_For_Approval__c = false;
				Contract.Contract_Status__c = 'Approved';
				Contract.Signed__c = true;
			}
            else if(t.Contract_Stage__c.contains('Expired') && t.recordTypeId == record_Type_ContractExpired){
                Contract.Expiration_Action__c = t.Contract_Expiration_Action__c;
                if(t.Contract_Extension_End_Date__c != null)
                    Contract.Review_Date__c = t.Contract_Extension_End_Date__c;
            }
            else if(t.Contract_Stage__c == 'Sent_to_Customer__c' && !Contract.Sent_to_Customer__c && t.recordTypeId == record_Type_ContractHardCopy)
            {
                Contract.Sent_to_Customer__c = true;
            }
            else if(t.Contract_Stage__c == 'Returned__c' && !Contract.Returned__c && t.recordTypeId == record_Type_ContractHardCopy)
            {
                Contract.Returned__c = true;
                Contract.Contract_Status__c = 'Active';
            }
            else if(t.Contract_Stage__c == 'Filed__c'  && !Contract.Filed__c && t.recordTypeId == record_Type_ContractHardCopy)
            {
                Contract.Filed__c = true;
                Contract.Hard_Copy_Done__c = true;
            }
            update Contract;
        }
    }    
}