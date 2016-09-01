/***********************************************************************************************************
* @author Ankit (Appirio Ind.)
* @date 11/25/2013 
* @Story S-162789
* @description Utility class for send email for PIB(Product Information Bulletin) Process
                From batch job and send email button on task.
***********************************************************************************************************/
global without sharing class PibUtility {
  
  /***********************************************************************************************************
   * Method for start process for send email to contacts and create tasks
   * @param lstBulletinAccounts list of bulletin accounts
   * @return void.
   ***********************************************************************************************************/
  
  public static void processSendEmailToContactAndCreateTask(List<Bulletin_Accounts__c> lstBulletinAccounts) {
      Set<Id> accountIds = new Set<Id>();
      Map<Id, Task> mapBulletinIdAndTask = new Map<Id, Task>();
      Map<Id, Bulletin_Accounts__c> mapBulletinAccount = new Map<Id, Bulletin_Accounts__c>();
      Map<Id, Bulletin_Accounts__c> mapBulletinNonSensitiveAccount = new Map<Id, Bulletin_Accounts__c>();
      Map<Id, List<Id>> mapOwnerIdAndAccounts = new Map<Id, List<Id>>();
      Map<Id, List<Attachment>> mapBulletinIdAndAttach = new Map<Id, List<Attachment>>();
      List<Bulletin_Accounts__c> doesNotMeetCriteriaBA = new List<Bulletin_Accounts__c>();
      string busArea = lstBulletinAccounts[0].Bulletin_Delivery_Job__r.Business_Area__c;
      Id recipient;
      for(Bulletin_Accounts__c bulletinAccount : lstBulletinAccounts) {
        
          if (bulletinAccount.Account__r.Owner.IsActive == true)
              recipient = bulletinAccount.Account__r.OwnerId;
          else if (bulletinAccount.Account__r.Sales_Manager__r.IsActive == true)
              recipient = bulletinAccount.Account__r.Sales_Manager__c;
          else
              recipient = bulletinAccount.Bulletin_Delivery_Job__r.CreatedById;
            
        if ((bulletinAccount.Account__r.Channel__c == 'Indirect') 
            || (bulletinAccount.Bulletin_Delivery_Job__r.Business_Org__c != bulletinAccount.Account__r.Business_Org__c)) {
          bulletinAccount.Status__c = 'Does not meet criteria';
          doesNotMeetCriteriaBA.add(bulletinAccount);
          continue;
        }
        mapBulletinAccount.put(bulletinAccount.Id, bulletinAccount);
        accountIds.add(bulletinAccount.Account__c);
        if(bulletinAccount.Job_Type__c == 'PIB Sensitive') {
          //Create task
          Task task = createTask(bulletinAccount, recipient);
          mapBulletinIdAndTask.put(bulletinAccount.Id, task);
        } else if(bulletinAccount.Job_Type__c == 'PIB Non-Sensitive' || bulletinAccount.Job_Type__c == 'Service Bulletin') {
          if(!mapOwnerIdAndAccounts.containsKey(bulletinAccount.Account__r.OwnerId)) {
            mapOwnerIdAndAccounts.put(bulletinAccount.Account__r.OwnerId, new List<Id>());
          }
          //Map<Account Manager, List<Account>>
          mapOwnerIdAndAccounts.get(bulletinAccount.Account__r.OwnerId).add(bulletinAccount.Account__c);
          mapBulletinNonSensitiveAccount.put(bulletinAccount.Id, bulletinAccount);
        }
      }
      
    mapBulletinIdAndAttach = getBulletinIdAndAttachMap(mapBulletinAccount.values());
      
      //Insert task for PIB Sensitive type
      if(mapBulletinIdAndTask.size() > 0) {
        List<Bulletin_Delivery_Log__c> lstLogs = new List<Bulletin_Delivery_Log__c>();
        
        Database.DMLOptions dmlo = new Database.DMLOptions(); 
        //dmlo.EmailHeader.triggerUserEmail = true; 
        database.insert(mapBulletinIdAndTask.values(), dmlo);
        //insert mapBulletinIdAndTask.values();
        
        for(Id bultId : mapBulletinIdAndTask.keySet()) {
          Bulletin_Accounts__c bultAcc = mapBulletinAccount.get(bultId);
          bultAcc.Status__c = 'Complete';
          bultAcc.Account_Manager_Name__c = bultAcc.Account__r.OwnerId;
          lstLogs.add(new Bulletin_Delivery_Log__c( Account_Name__c = bultAcc.Account__c, 
                              Bulletin_Account__c = bultId));
        }
        update mapBulletinAccount.values();
        insert lstLogs;
      }
      
      //Insert attachments for inserted tasks
      List<Attachment> finalInsertTaskAttachments = new List<Attachment>();
      for(Id bulletinAccId : mapBulletinIdAndTask.keySet()) {
        
        if (mapBulletinIdAndAttach.containsKey(bulletinAccId) && mapBulletinIdAndAttach.get(bulletinAccId) != null) {
          List<Attachment> lstAttachments = mapBulletinIdAndAttach.get(bulletinAccId);
          Task task = mapBulletinIdAndTask.get(bulletinAccId);
          for(Attachment attach : lstAttachments) {
            finalInsertTaskAttachments.add(new Attachment(name = attach.name, 
                                    body = attach.body, 
                                    ParentId = task.Id, 
                                    ownerId = task.OwnerId));
          }
        }
      }
      if (!finalInsertTaskAttachments.isEmpty()) {
        insert finalInsertTaskAttachments;
      }
      
    if(mapBulletinNonSensitiveAccount.size() > 0) {
        Map<Id, List<Contact>> mapAccountIdAndContacts = new Map<Id, List<Contact>>();
        Map<Id, String> mapAccountIdAndOwnerEmail = new Map<Id, String>();
        
        for(Contact contact : [ Select Id, Name, AccountId, Email, Service_Bulletin__c, Product_Information_Bulletin__c, Title, Role__c, Department 
                                From Contact
                                Where AccountId IN :accountIds 
                                And PIB_BU__c INCLUDES (:busArea)
                                And Inactive_Contact__c = false ]) {

          if(contact.Email != null) {
            if(!mapAccountIdAndContacts.containsKey(contact.AccountId)) {
              mapAccountIdAndContacts.put(contact.AccountId, new List<Contact>());
            }
            mapAccountIdAndContacts.get(contact.AccountId).add(contact);
          }
          
        }
        
        for( User user : [Select Id, Email From User Where Id IN :mapOwnerIdAndAccounts.keySet()]) {
          if(user.Email != null) {
            for(Id accId : mapOwnerIdAndAccounts.get(user.Id)) {
              mapAccountIdAndOwnerEmail.put(accId, user.Email);
            }
          }
        }
        
        sendEmailToContacts(mapAccountIdAndOwnerEmail, mapAccountIdAndContacts, mapBulletinIdAndAttach, mapBulletinNonSensitiveAccount, busArea, recipient);
    }
      
      // Update status as 'Does not meet criteria' of bulletin accounts
      if(!doesNotMeetCriteriaBA.isEmpty()){
        update doesNotMeetCriteriaBA;
      }
  }
  
  /***********************************************************************************************************
   * Method for send email to contacts and executes from batch job
   * @param Maps of AccountIds, Bulletin AccountIds, Attachments and Contacts
   * @return void.
  ***********************************************************************************************************/
  public static void sendEmailToContacts(
              Map<Id, String> mapAccountIdAndOwnerEmail, 
              Map<Id, List<Contact>> mapAccountIdAndContacts, 
              Map<Id, List<Attachment>> mapBulletinIdAndAttach, 
              Map<Id, Bulletin_Accounts__c> mapBulletinAccount,
              String busArea, Id recipient) {
      
    The_Bank__c bankObj;
    for(The_Bank__c obj : [Select Name, Current_Actual__c, Daily_Self_Limit__c, Is_Limit_Reached__c From The_Bank__c order by CreatedDate desc Limit 1]) {
      bankObj = obj;
      if(bankObj.Current_Actual__c ==  null) {
        bankObj.Current_Actual__c = 0;
      }
    }
    system.debug('bankObj.Current_Actual__c1: ' +bankObj.Current_Actual__c);
    system.debug('bankObj.Is_Limit_Reached__c1: ' +bankObj.Is_Limit_Reached__c);
    if (bankObj == null) {
      bankObj = new The_Bank__c(Name = 'Daily Email Limit', Daily_Self_Limit__c = 500, Current_Actual__c = 0); 
      insert bankObj;
    }
    Map<Id, Task> mapBulletinIdAndTask = new Map<Id, Task>();
    List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
    List<Bulletin_Delivery_Log__c> lstLogs = new List<Bulletin_Delivery_Log__c>();
    List<Task> lstTasks = new List<Task>();
    EmailTemplate et; 
    EmailTemplate etSummary;
    Map<Id, Set<Attachment>> mapAccountIdAndPibs = new Map<Id, Set<Attachment>>();
    Map<String, EmailTemplate> mapBAAndTemplate = getNotificationTemplateMap();
    Set<Contact> contacts = new Set<Contact>();
    for(Id bulletinId : mapBulletinAccount.keySet()) {
      Bulletin_Accounts__c bulletinAcc = mapBulletinAccount.get(bulletinId);
      Id accId = bulletinAcc.Account__c;
      String countryName = bulletinAcc.Account__r.Country__r.Name;
      String ownerEmail = mapAccountIdAndOwnerEmail.get(accId);
      
      //Get email template
      String jobType = (bulletinAcc.job_type__c.containsIgnoreCase('PIB') ? 'PIB' : (bulletinAcc.job_type__c.containsIgnoreCase('Service Bulletin') ? 'SB' : bulletinAcc.job_type__c));
      String key = getTemplateKey(jobType, countryName);
      
      String jobTypeSummary = (bulletinAcc.job_type__c.containsIgnoreCase('PIB') ? 'PIB - Summary' : (bulletinAcc.job_type__c.containsIgnoreCase('Service Bulletin') ? 'SB - Summary' : bulletinAcc.job_type__c + ' - Summary'));
      String keySummary = getTemplateKey(jobTypeSummary, countryName);
      
      if (mapBAAndTemplate.containsKey(key)) {
        et = mapBAAndTemplate.get(key);
      } else {
        key = getTemplateKey(jobType, null);
        et = mapBAAndTemplate.get(key);
      }
      
      //Get email template for summary email for account owner
      if (mapBAAndTemplate.containsKey(keySummary)) {
        etSummary = mapBAAndTemplate.get(keySummary);
      } else {
        keySummary = getTemplateKey(jobTypeSummary, null);
        etSummary = mapBAAndTemplate.get(keySummary);
      }
      
      if(et == null || etSummary == null) {
        if (et == null) {
          bulletinAcc.Status__c = 'Failed';
          bulletinAcc.Error_Message__c = 'No Email Template defined for ' + countryName + '.';
        } else if(etSummary == null) {
            bulletinAcc.Status__c = 'Failed';
            bulletinAcc.Error_Message__c = 'No Email Template defined for summary email of account owner.';
        }
        continue;
      }
      
      Boolean isPib = bulletinAcc.Job_Type__c == 'PIB Non-Sensitive' ? true : false;
      List<Bulletin_Delivery_Log__c> lstLogForBA = new List<Bulletin_Delivery_Log__c>();
      if(mapAccountIdAndContacts.containsKey(accId)){
          for(Contact contact : mapAccountIdAndContacts.get(accId)) {
            if ((!isPib && contact.Service_Bulletin__c == true) || (isPib && contact.Product_Information_Bulletin__c == true)) {
              contacts.add(contact);
              lstLogForBA.add(new Bulletin_Delivery_Log__c(
                          Account_Name__c = accId, 
                          Bulletin_Account__c = bulletinId, 
                          Contact_Name__c = contact.Id,
                          Business_Area__c = busArea));
            }
          }
      }
      if(bankObj == null || (bankObj.Current_Actual__c + contacts.size() + 1) > bankObj.Daily_Self_Limit__c) {
        bankObj.Is_Limit_Reached__c = true;
        continue;
      }
      system.debug('bankObj.Current_Actual__c2: ' +bankObj.Current_Actual__c);
    system.debug('bankObj.Is_Limit_Reached__c2: ' +bankObj.Is_Limit_Reached__c);
    
      //Populate contact selection creteria on bulletin account
      String contactSelectionCriteria = (bulletinAcc.job_type__c.containsIgnoreCase('PIB') ? 'PIB box checked, ' : (bulletinAcc.job_type__c.containsIgnoreCase('Service Bulletin') ? 'Service Bulletin checked, ' : ''));
      contactSelectionCriteria += 'Business Area = ' + bulletinAcc.Bulletin_Delivery_Job__r.Business_Area__c;
      bulletinAcc.Criteria__c = contactSelectionCriteria;
      
        List<Messaging.EmailFileAttachment> emailAttchments = new List<Messaging.EmailFileAttachment>();
        if(mapBulletinIdAndAttach != null && mapBulletinIdAndAttach.containsKey(bulletinId)) {
            for(Attachment attachments : mapBulletinIdAndAttach.get(bulletinId)) {
              Messaging.EmailFileAttachment emailAttach = new Messaging.EmailFileAttachment();
              emailAttach.setFileName(attachments.Name);
              emailAttach.setBody(attachments.body);
              emailAttchments.add(emailAttach);
            }
        }   
        if(!contacts.isEmpty()) {
                for(Contact contact : contacts) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setFileAttachments(emailAttchments);
                    mail.setTemplateId(et.Id);
                    mail.setTargetObjectId(contact.Id);
                    mail.setWhatId(bulletinAcc.Id);
                    bankObj.Current_Actual__c ++;
                    mailList.add(mail);
                }            
            //Create mail for account owner
                Messaging.SingleEmailMessage ownerMail = new Messaging.SingleEmailMessage();
                ownerMail.setTemplateId(etSummary.Id);
                ownerMail.setTargetObjectId(recipient); 
                ownerMail.setWhatId(bulletinId);
                //bankObj.Current_Actual__c ++;
                ownerMail.saveAsActivity = false;
                mailList.add(ownerMail); 
          } else {
                Task task = createTask(bulletinAcc, recipient);
                mapBulletinIdAndTask.put(bulletinAcc.Id, task);
          }
      
          bulletinAcc.Status__c = 'Complete';
          bulletinAcc.Account_Manager_Name__c = bulletinAcc.Account__r.OwnerId;
          if(!mapAccountIdAndPibs.containsKey(bulletinAcc.Account__c)) {
            mapAccountIdAndPibs.put(bulletinAcc.Account__c, new Set<Attachment>());
          }
          if(mapBulletinIdAndAttach.containsKey(bulletinId)){
            mapAccountIdAndPibs.get(bulletinAcc.Account__c).addAll(mapBulletinIdAndAttach.get(bulletinId));
          }
          lstLogs.addAll(lstLogForBA);
        }
    
        
        if(!mailList.isEmpty() && !Test.isRunningTest()) {
            try{
                Messaging.sendEmail(mailList);
            } catch (System.EmailException ex){
                /*FeedItem post = new FeedItem(); 
                post.ParentId = '0F9C0000000GuAM'; //Chatter Group
                post.Body = 'Email exception';
                insert post;*/
            }
          
        }
        
        if(!lstLogs.isEmpty() && !mailList.isEmpty()) {
          insert lstLogs;
        }

    update mapBulletinAccount.values();
    if(!contacts.isEmpty()) {
     //create note on account when email was sent to contacts (link to the attachment will be included in summary email to AM)
        createNoteForEachPIB(mapAccountIdAndPibs); 
    }
    //if(!lstTasks.isEmpty()) {
   if(mapBulletinIdAndTask.size() > 0) {
      Database.DMLOptions dmlo = new Database.DMLOptions(); 
      //dmlo.EmailHeader.triggerUserEmail = true; 
        database.insert(mapBulletinIdAndTask.values(), dmlo);
      //database.insert(lstTasks, dmlo);
      //insert lstTasks;
    }
 //Insert attachments for inserted tasks
      List<Attachment> finalInsertTaskAttachments = new List<Attachment>();
      for(Id bulletinAccId : mapBulletinIdAndTask.keySet()) {
        
        if (mapBulletinIdAndAttach.containsKey(bulletinAccId) && mapBulletinIdAndAttach.get(bulletinAccId) != null) {
          List<Attachment> lstAttachments = mapBulletinIdAndAttach.get(bulletinAccId);
          Task task = mapBulletinIdAndTask.get(bulletinAccId);
          for(Attachment attach : lstAttachments) {
            finalInsertTaskAttachments.add(new Attachment(name = attach.name, 
                                    body = attach.body, 
                                    ParentId = task.Id, 
                                    ownerId = task.OwnerId));
          }
        }
      }
      if (!finalInsertTaskAttachments.isEmpty()) {
        insert finalInsertTaskAttachments;
      }
      
    if(bankObj != null) {
      update bankObj;
    }
    system.debug('bankObj.Current_Actual__c3: ' +bankObj.Current_Actual__c);
    system.debug('bankObj.Is_Limit_Reached__c3: ' +bankObj.Is_Limit_Reached__c);
                  
  }
  
  /***********************************************************************************************************
   * Method for create Note For Each PIB For Non Sensitive
   * @param mapAccountIdAndPibs Map of account ids and attchments
   * @return void.
  ***********************************************************************************************************/
  public static void createNoteForEachPIB(Map<Id, Set<Attachment>> mapAccountIdAndPibs) {
    List<Note> lstNote = new List<Note>();
    for(Id accId : mapAccountIdAndPibs.keySet()) {
      for(Attachment attach : mapAccountIdAndPibs.get(accId)) {
        note n = new note();
        n.parentId = accId;
        n.title = (attach.Name.length() > 80 ? attach.Name.substring(0,80) : attach.Name);
        n.body = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + attach.Id;
        lstNote.add(n);
      }
    }
    insert lstNote;
  }
  
  /***********************************************************************************************************
   * Method for create Task
   * @param isInsert
   * @param bulletinAccount
   * @return Task.
  ***********************************************************************************************************/
  public static Task createTask(Bulletin_Accounts__c bulletinAccount, Id recipient) {
    Task task = new Task();
    task.OwnerId = recipient; //bulletinAccount.Account__r.OwnerId;
    task.WhatId = bulletinAccount.Account__c;    
    task.Subject = bulletinAccount.Job_Type__c + (bulletinAccount.Bulletin_Delivery_Job__r.Name != null ? ': ' + bulletinAccount.Bulletin_Delivery_Job__r.Name : ''); 
    task.Description = bulletinAccount.Bulletin_Delivery_Job__r.Comments__c;
    task.Priority = bulletinAccount.Bulletin_Delivery_Job__r.Priority__c;
    task.ActivityDate = bulletinAccount.Bulletin_Delivery_Job__r.Due_Date__c;
    task.Uploaded__c = true;
    task.Status = 'In Progress';
    task.IsReminderSet = true;
    task.ReminderDateTime = bulletinAccount.Bulletin_Delivery_Job__r.Due_Date__c.addDays(-7);
    task.Business_Area__c = bulletinAccount.Bulletin_Delivery_Job__r.Business_Area__c;
    task.Bulletin_Delivery_Job__c = bulletinAccount.Bulletin_Delivery_Job__c;
    return task;
  }
  
  /***********************************************************************************************************
   * Returns Map <BulletinAccountId, List<Attachments>>
   * @param countryName
   * @return EmailTemplate.
  ***********************************************************************************************************/
  private static Map<Id, List<Attachment>> getBulletinIdAndAttachMap (List<Bulletin_Accounts__c> lstBulletinAccounts) {
    Map<Id, List<Attachment>> mapAttachments = new Map<Id, List<Attachment>>();
    Map<Id, Id> mapAttachIdAndBA = new Map<Id, Id>();
    Set<Id> parentIds = new Set<Id>();
    
    for (Bulletin_Accounts__c ba : lstBulletinAccounts) {
      if (ba.Generic_Attachment_ID__c != null && ba.Generic_Attachment_ID__c != '') {
        //Below try catch block handle improper url of attachments. 
        try {
            mapAttachIdAndBA.put((ID)ba.Generic_Attachment_ID__c, ba.Id);
        } catch (Exception ex) {
            //do Nothing
        }
      }
      parentIds.add(ba.Id);
    }
    //Query BA Attachment
    for(Attachment attach : [ Select Id, Name, body, ParentId 
                              From Attachment 
                              Where ParentId IN :parentIds 
                              or id in :mapAttachIdAndBA.keySEt()]) {
      if (mapAttachIdAndBA.containsKey(attach.Id)) {
        Id parentId = mapAttachIdAndBA.get(attach.Id);
        if(!mapAttachments.containsKey(parentId)) {
          mapAttachments.put(parentId, new List<Attachment>());
        }
        mapAttachments.get(parentId).add(attach);
      } else {
            if(!mapAttachments.containsKey(attach.ParentId)) {
                mapAttachments.put(attach.ParentId, new List<Attachment>());
            }
            mapAttachments.get(attach.ParentId).add(attach);
      }
      
    }
    return mapAttachments;
  }
  
    /***********************************************************************************************************
       * Returns a Map<JobType + Country, Email Template Name>
       * @param countryName
       * @return EmailTemplate. 
  ***********************************************************************************************************/
  public static Map<String, EmailTemplate> getNotificationTemplateMap() {
    Map<String, String> mapJobTypeAndTemplate = new Map<String, String>();
    Map<String, List<String>> mapTemplateNameAndJobType = new Map<String, List<String>>();
    for (Bulletin_Templates__c bt : Bulletin_Templates__c.getAll().values()) {
        String key = getTemplateKey(bt.Notification_Type__c, bt.Country__c);
        mapJobTypeAndTemplate.put(key, bt.Template_Name__c);
         if (!mapTemplateNameAndJobType.containsKey(bt.Template_Name__c)) {
            mapTemplateNameAndJobType.put(bt.Template_Name__c, new List<String>());
        }
        mapTemplateNameAndJobType.get(bt.Template_Name__c).add(key);
    }
        system.debug('mapJobTypeAndTemplate: ' + mapJobTypeAndTemplate);
        system.debug('mapJobTypeAndTemplate.values(): ' + mapJobTypeAndTemplate.values());
        system.debug('mapTemplateNameAndJobType: ' + mapTemplateNameAndJobType);
      system.debug('mapTemplateNameAndJobType.values(): ' + mapTemplateNameAndJobType.values());
       
    Map<String, EmailTemplate> mapTemplate = new Map<String, EmailTemplate>();
    for (EmailTemplate eTemplate : [SELECT Id, Name, Subject  
                                    FROM EmailTemplate 
                                    WHERE Name = :mapJobTypeAndTemplate.values()]) {
        for (String key : mapTemplateNameAndJobType.get(eTemplate.Name)) {
            mapTemplate.put(key, eTemplate);
        }
    }
      system.debug('mapTemplate: ' + mapTemplate);
    return mapTemplate;
  }
  
  /***********************************************************************************************************
     * Returns key for finding email template
     * @param jobType
     * @return country.
  ***********************************************************************************************************/
  public static String getTemplateKey(String jobType, String country) {
    return jobType + (country != null ? country : '');
  }

}