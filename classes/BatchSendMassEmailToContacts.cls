/*************************************************************************************************************
* @author Ankit (Appirio Ind.)
* @description  Batch class for send email to PIB and service bulletin contacts
*************************************************************************************************************/
global class BatchSendMassEmailToContacts implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
   global Boolean resetCustomSetting; 
   /**********************************************************************************************************
    * Start method of batch class.
    * @param Database.BatchableContext
    * @return database.Querylocator.
    *********************************************************************************************************/
    global database.Querylocator start(Database.BatchableContext BC) {
        if(resetCustomSetting == null) {
            resetCustomSetting = true;
        }
        setupBankObject(resetCustomSetting);
        return Database.getQueryLocator(
                [ Select Id, Generic_Attachment_ID__c, Job_Type__c, Status__c, CreatedDate,  
                  Account__c, Account__r.Sales_Manager__r.IsActive, Account__r.OwnerId, Account__r.Owner.IsActive, Account__r.Country__r.Name, 
                  Account__r.Business_Org__c, Account__r.Channel__c, Bulletin_Delivery_Job__r.Name, Bulletin_Delivery_Job__r.Business_Org__c, 
                  Bulletin_Delivery_Job__c, Bulletin_Delivery_Job__r.Comments__c, Bulletin_Delivery_Job__r.Due_Date__c, 
                  Bulletin_Delivery_Job__r.CreatedBy.IsActive, Bulletin_Delivery_Job__r.Priority__c, Bulletin_Delivery_Job__r.Business_Area__c     
                From Bulletin_Accounts__c 
                    Where Bulletin_Delivery_Job__r.Status__c IN ('Ready', 'In Progress')  
                    AND Status__c = 'Not Started'
                    Order by Bulletin_Delivery_Job__r.Status_Formula__c, CreatedDate asc limit 1]);
                    
    }
    
    /***********************************************************************************************************
    * Execute method of batch class.
    * @param Database.BatchableContext
    * @param SObject[]
    * @return void.
    *********************************************************************************************************/
    global void execute(Database.BatchableContext BC, SObject[] scope) {
        The_Bank__c bankJob;
        for(The_Bank__c obj : [Select Name, Current_Actual__c, Daily_Self_Limit__c, Is_Limit_Reached__c From The_Bank__c order by CreatedDate desc Limit 1]){
            bankJob = obj;
        }
        if(bankJob != null && bankJob.Current_Actual__c >= bankJob.Daily_Self_Limit__c ) {
            bankJob.Is_Limit_Reached__c = true;
            update bankJob; 
            return; 
        }
        PibUtility.processSendEmailToContactAndCreateTask((List<Bulletin_Accounts__c>) scope);
    }
    
    /***********************************************************************************************************
    * Finish method of batch class.
    * @param Database.BatchableContext
    * @return void.
    *********************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        The_Bank__c bankJob;
        for(The_Bank__c obj : [Select Name, Current_Actual__c, Daily_Self_Limit__c, Is_Limit_Reached__c From The_Bank__c order by CreatedDate desc Limit 1]){
            bankJob = obj;
        }
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                      FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        try {
            Messaging.reserveSingleEmailCapacity((Integer)bankJob.Current_Actual__c);
            /*FeedItem post = new FeedItem();
 
            post.ParentId = '0F9C0000000GuAM'; //Chatter Group
            post.Body = 'Under email limit: '+ bankJob.Current_Actual__c;
 
            insert post;*/
        } catch (Exception e) {
                    // This code will never be reached when going over the daily email limit
                    // Limit exceptions cannot be caught
           /* FeedItem post = new FeedItem();
 
            post.ParentId = '0F9C0000000GuAM'; //Chatter Group
            post.Body = 'Over email limit: ' + bankJob.Current_Actual__c;
 
            insert post;*/
        }       
       if (a.TotalJobItems > 0 && !bankJob.Is_Limit_Reached__c) {
        BatchSendMassEmailToContacts batchSendEmail = new BatchSendMassEmailToContacts(); 
        batchSendEmail.resetCustomSetting = false;
        database.executebatch(batchSendEmail, 1);
       }
    }
    
    /***********************************************************************************************************
    * Execute method of scheduler class.
    * @param SchedulableContext
    * @return void.
    *********************************************************************************************************/
    global void execute(SchedulableContext sc) {         
        
        BatchSendMassEmailToContacts batchSendEmail = new BatchSendMassEmailToContacts(); 
        database.executebatch(batchSendEmail, 1);
    }
    
    /***********************************************************************************************************
    * setupBankObject method for The_Bank__c custom setting.
    * @return The_Bank__c.
    *********************************************************************************************************/
    private The_Bank__c setupBankObject(Boolean setCurrentActual) {
        The_Bank__c bankObj;
        for(The_Bank__c obj : [Select Name, Current_Actual__c, Daily_Self_Limit__c, Is_Limit_Reached__c, Last_Modified__c From The_Bank__c order by CreatedDate desc Limit 1]) {
          bankObj = obj;
        }
        if (bankObj == null) {
          bankObj = new The_Bank__c(Name = 'Daily Email Limit', Daily_Self_Limit__c = 900, Current_Actual__c = 0, Last_Modified__c = DateTime.now()); 
        }
        if(setCurrentActual == null || setCurrentActual == true) {
             bankObj.Current_Actual__c = 0;
             bankObj.Is_Limit_Reached__c = false;
             bankObj.Last_Modified__c = datetime.now();
        }
        system.debug('bankObj.Current_Actual__c0: ' +bankObj.Current_Actual__c);
        system.debug('bankObj.Is_Limit_Reached__c0: ' +bankObj.Is_Limit_Reached__c);
    
        upsert bankObj;
        return bankObj;
    }
}