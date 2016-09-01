/******************************************************
* Author        :  Shailendra Singh (Appirio Offshore)
* Name          :  DeactivatePortalUserService
* Date          :  09/08/2012
* Related Task  :  T-66531
* Description   :  Deactivate Portal User if not logged in 60 days and send email notification to Delegated admins (Delegated Admin Profile) 
*******************************************************/ 
global class DeactivatePortalUserService implements Database.Batchable<Sobject>,Schedulable{
   public String query = 'Select ID,LastLoginDate,Contact.AccountId,Contact.Id,ContactId,Name,FirstName,LastName,Email From User Where LastLoginDate < LAST_N_DAYS:60 AND ContactId != null AND IsActive = true';
   //public String query = 'Select ID,LastLoginDate,Contact.AccountId,Contact.Id,ContactId,Name,FirstName,LastName,Email From User Where LastLoginDate < LAST_N_DAYS:1 AND ContactId != null AND IsActive = true';
    
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<sObject> scope){
    
        EmailTemplate template = [Select Id,DeveloperName,body,HtmlValue ,subject From EmailTemplate Where DeveloperName = 'Deactivate_Portal_User' Limit 1];
        Profile delegatedAdminProfile = [Select Name,Id From Profile p Where Name = 'PartnerLink - Delegated Admin' Limit 1];
        Map<ID,List<User>> accountAdmins = new Map<ID,List<User>>();
        Set<ID> accountID = new set<ID>();
        List<User> users = new List<User>();
        for(Sobject obj :scope){
            User user = (User) obj;
            accountID.add(user.Contact.AccountId);  
            user.IsActive = false;
            users.add(user);
        }
        if(!users.isEmpty()){
            update users;
        }
        for(User user : [Select ID,Contact.AccountId,Contact.Id,ContactId,FirstName,LastName,Email,Name From User Where Contact.AccountId IN :accountID AND IsActive = true AND ProfileId = :delegatedAdminProfile.id]){
            if(accountAdmins.get(user.Contact.AccountId) == null){
                accountAdmins.put(user.Contact.AccountId, new List<User>());
            }
            accountAdmins.get(user.Contact.AccountId).add(user);
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String body = template.htmlValue;
        for(User user : users){
            if(accountAdmins.containsKey(user.Contact.AccountId)){
                for(User admin : accountAdmins.get(user.Contact.AccountId)){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String email = '';
                    email = admin.email;
                    String templateBbody = body.replace('{!User.Name}', user.name).replace('{!User.Link}',URL.getSalesforceBaseUrl().toExternalForm()+ '/' +user.Id);
                    templateBbody = templateBbody.replace(']]>','');
                    templateBbody = templateBbody.replace('http:','https:');
                    mail.setSubject(template.subject.replace('{!User.Name}', user.name));
                    mail.setHtmlBody(templateBbody);
                    mail.setToAddresses(new String[] {email});
                    mail.setSaveAsActivity(false);
                    emails.add(mail);
                }
            }
        }
        Messaging.sendEmail(emails,false);
   }
  global void execute(SchedulableContext SC) {
     System.debug('.........Batch DeactivatePortalUserService has been started..............');
     Database.executeBatch(this);
   }
   global void finish(Database.BatchableContext BC){
        System.debug('..................Batch DeactivatePortalUserService ended............................');
   }    
   
}