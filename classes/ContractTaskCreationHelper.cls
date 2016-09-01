public without sharing class ContractTaskCreationHelper{
    
    static Id record_Type_Contract = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Task').getRecordTypeId();
    static Id record_Type_ContractHardCopy = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Hard Copy Task').getRecordTypeId();
    static string instructions = ContractTaskInstructions__c.getInstance('Instructions').Instructions__c;
  
    public static void CreateHardCopyTask(String strApprovalStatus, Contract__c contRec)
    {
        String taskSubject = '';        
        if(strApprovalStatus == 'Signed')
        {   
            List<Task> lstsentTask = [Select Id From Task where WhatId = :contRec.Id and Contract_Previous__c = false and Contract_Stage__c = 'Sent_to_Customer__c' limit 1];
            if (lstsentTask.isEmpty())
            {
                Task task = new Task();
                task.RecordTypeId = record_Type_ContractHardCopy;
                task.OwnerId = contRec.CreatedById;
                task.WhatId = contRec.Id;
                taskSubject = [SELECT id, subject FROM EmailTemplate WHERE DeveloperName = 'Contract_to_be_Sent'].Subject; 
                task.Subject = taskSubject.replace('{!Contract__c.Name}', contRec.Name).replace('{!Contract__c.Customer__c}', contRec.Customer_Name__c); 
                task.Contract_Instructions__c = instructions;
                task.Contract_Stage__c = 'Sent_to_Customer__c';
                task.ActivityDate = System.Date.Today().adddays(2);
                task.Status = 'Pending';
                task.IsReminderSet = true;
                task.ReminderDateTime = System.DateTime.now().adddays(1);
                insert task;
            }
        }
        
        if(strApprovalStatus == 'Sent')
        {
            List<Task> lstreturnedTask = [Select Id From Task where WhatId = :contRec.Id and Contract_Previous__c = false and Contract_Stage__c = 'Returned__c' limit 1];
            if (lstreturnedTask.isEmpty())
            {
                Task task = new Task();
                task.RecordTypeId = record_Type_ContractHardCopy;
                task.OwnerId = contRec.CreatedById;
                task.WhatId = contRec.Id;
                taskSubject = [SELECT id, subject FROM EmailTemplate WHERE DeveloperName = 'Contract_to_be_Returned'].Subject; 
                task.Subject = taskSubject.replace('{!Contract__c.Name}', contRec.Name).replace('{!Contract__c.Customer__c}', contRec.Customer_Name__c); 
                task.Contract_Instructions__c = instructions;
                task.Contract_Stage__c = 'Returned__c';
                task.ActivityDate = System.Date.Today().adddays(2);
                task.Status = 'Pending';
                task.IsReminderSet = true;
                task.ReminderDateTime = System.DateTime.now().adddays(1);
                insert task;
            }
        }
                        
        if(strApprovalStatus == 'Returned')
        {
            List<Task> lstfiledTask = [Select Id From Task where WhatId = :contRec.Id and Contract_Previous__c = false and Contract_Stage__c = 'Filed__c' limit 1];
            if (lstfiledTask.isEmpty())
            {
                Task task = new Task();
                task.RecordTypeId = record_Type_ContractHardCopy;
                task.OwnerId = contRec.Contract_Specialist__c;
                task.WhatId = contRec.Id;
                taskSubject = [SELECT id, subject FROM EmailTemplate WHERE DeveloperName = 'Contract_to_be_Filed'].Subject; 
                task.Subject = taskSubject.replace('{!Contract__c.Name}', contRec.Name).replace('{!Contract__c.Customer__c}', contRec.Customer_Name__c);
                task.Contract_Instructions__c = instructions;
                task.Contract_Stage__c = 'Filed__c';
                task.ActivityDate = System.Date.Today().adddays(2);
                task.Status = 'Pending';
                task.IsReminderSet = true;
                task.ReminderDateTime = System.DateTime.now().adddays(1);
                insert task;
            }
        }       
    }
    
    public static void CreateApprovalTask(string role, Id ApproverId, Contract__c contRec)
    {
        Task task = new Task();
        task.RecordTypeId = record_Type_Contract;
        task.OwnerId = ApproverId;
        task.WhatId = contRec.Id;
        task.Contract_Stage__c = role; 
        String taskSubject = [SELECT id, subject FROM EmailTemplate WHERE DeveloperName = 'Contract_to_be_Signed'].Subject; 
        task.Subject = taskSubject.replace('{!Contract__c.Name}', contRec.Name).replace('{!Contract__c.Customer__c}', contRec.Customer_Name__c);
        task.Contract_Instructions__c = instructions;
        task.ActivityDate = System.Date.Today().adddays(2);
        task.Status = 'Pending';
        task.IsReminderSet = true;
        task.ReminderDateTime = System.DateTime.now().adddays(1);
        insert task;
    }
}