/******************************************************************************************************
* @author Ankit (Appirio Ind.)
* @date 11/28/2013
* @Task T-216007
* @description Controller class for send email for PIB(Product Information Bulletin) Process for contacts from task
******************************************************************************************************/
public with sharing class SelectContactForSendPibCtrl {

  private Account acc;
  public Task task{get;set;}
  public List<Contact> contacts{get; set;}
  public String contactIds{get; set;}
  private static final String PIB_SUBJECT = 'PIB';
  private static final String SERVICE_BULLETIN_SUBJECT = 'Service Bulletin';
  private static final String ERROR_MSG = 'Unable to process request.';
  
  /******************************************************************************************************
   * Constructor
   ******************************************************************************************************/
  public SelectContactForSendPibCtrl(ApexPages.StandardController stdController) {
    this.task = (Task)stdController.getRecord();
    task = [Select Id, Status, WhatID, Subject  From Task Where Id = :task.Id];
      for(Account  a : [Select Id, Country__r.Name, Owner.Email From Account Where Id = :task.WhatId]) {
        acc = a;
      }
      if (task.Subject.containsIgnoreCase(PIB_SUBJECT)) {
        contacts = new List<Contact>([ Select Id, Name, Email 
                                       From Contact 
                                       Where AccountId = :acc.Id 
                                       And Inactive_Contact__c = false 
                                       AND Product_Information_Bulletin__c = true]);
      } 
      if (task.Subject.containsIgnoreCase(SERVICE_BULLETIN_SUBJECT)) {
        contacts = new List<Contact>([Select Id, Name, Email 
                                      From Contact 
                                      Where AccountId = :acc.Id 
                                      And Inactive_Contact__c = false 
                                      AND Service_Bulletin__c = true]);
      }
      
      
      if(contacts.isEmpty()) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.No_Contacts_Found));
      }
  }
  
  /******************************************************************************************************
   * Method for send email
   * @return void
  ******************************************************************************************************/
  public void sendEmail() {
    try {
        Map<String, EmailTemplate> mapBAAndTemplate = pibUtility.getNotificationTemplateMap();
        String countryName = acc.Country__r.Name;
        //Get email template
      String jobType = (task.Subject.containsIgnoreCase(PIB_SUBJECT) ? 'PIB' : (task.subject.containsIgnoreCase(SERVICE_BULLETIN_SUBJECT) ? 'SB' : task.Subject));
      String key = pibUtility.getTemplateKey(jobType, countryName);
      
      EmailTemplate et;
      if (mapBAAndTemplate.containsKey(key)) {
        et = mapBAAndTemplate.get(key);
      } else {
        key = pibUtility.getTemplateKey(jobType, null);
        et = mapBAAndTemplate.get(key);
      }
        if(et == null) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.Email_template_not_defined));
          return;
        }
        
      List<Attachment> attachments = new List<Attachment>([Select Id, Name, Body From Attachment Where ParentId = :task.Id]);
      List<Messaging.EmailFileAttachment> emailAttchments = new List<Messaging.EmailFileAttachment>();
      for(Attachment attachment : attachments) {
        Messaging.EmailFileAttachment emailAttach = new Messaging.EmailFileAttachment();
        emailAttach.setFileName(attachment.Name);
        emailAttach.setBody(attachment.body);
        emailAttchments.add(emailAttach);
      }
      
      List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
      for(Contact contact : contacts) {
          if(contactIds.contains(contact.Id)) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //mail.setCcAddresses(new String[] {acc.Owner.Email});
            if(!emailAttchments.isEmpty()) {
            mail.setFileAttachments(emailAttchments);
          }
          mail.setTemplateId(et.Id);
          mail.setTargetObjectId(contact.Id);
          mailList.add(mail);
          }
        }
        
      if(!mailList.isEmpty()) {
        Messaging.sendEmail(mailList);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.Mail_Send_Successful));
      } 
      
    } catch(Exception e) { 
      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ERROR_MSG + '\n' + e));
      return;
    }
  }
}