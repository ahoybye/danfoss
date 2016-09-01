/**
* @author Ankit (Appirio Ind.)
* @date 9 Dec, 2013
* @description Test Class for SelectContactForSendPibCtrl
*/
@isTest
private class Test_SelectContactForSendPibCtrl {
    static User adminUser;

    static testMethod void testSelectContactForSendPibCtrl() {
        List<Folder> folders =  [select id from folder where IsReadOnly = false AND AccessType = 'Public' AND Type = 'Email' limit 1];
        EmailTemplate et = new EmailTemplate (DeveloperName = 'Test', TemplateType= 'Text', Name = 'Test Template', Subject = 'Test Subject', FolderId = folders[0].Id, IsActive = true);
        insert et;
        
        Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
        UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
        adminUser = Test_Utility.createUser(profile.Id,roles.Id, 1);
        insert adminUser;
        Task task;
        List<Contact> lstContact = new List<Contact> ();
        system.runAs(adminUser) {
            Bulletin_Templates__c btCustomSettingObj = new Bulletin_Templates__c(Name='Test', Notification_Type__c='PIB', Template_Name__c = et.Name);
            insert btCustomSettingObj;
            Account acc = new Account(Name = 'Test Account', OwnerId=UserInfo.getUserId(), Channel__c = 'Direct', Business_Org__c = 'Test Org');
            insert acc;
            task = new Task(Subject = 'PIB Sensitive', WhatId = acc.Id, Status = 'In Progress', ActivityDate = DateTime.Now().Date());
            insert task;
            for (Integer i = 1; i <= 10; i++) {
                lstContact.add(new Contact(FirstName = 'Contact ' + i, 
                                            LastName = acc.Name, 
                                            Email = 'danfossapexemail@gmail.com', 
                                            AccountId = acc.Id, 
                                            Product_Information_Bulletin__c = true, 
                                            Inactive_Contact__c = false));
            }
            insert lstContact;
            
            Attachment attach=new Attachment();     
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.ParentId = task.Id;
            insert attach;
        
            ApexPages.Standardcontroller sc = New ApexPages.StandardController(task);
            SelectContactForSendPibCtrl ctrl = new SelectContactForSendPibCtrl(sc);
            for(Contact con : lstContact){
                ctrl.contactIds += con.Id + ',';
            }
            ctrl.sendEmail();
            task = [Select Id, Status From Task Where Id = :task.Id];
            //System.assertEquals('Completed', task.Status); ttk 12/20 changed to test "In Progress"
            //System.assertEquals('In Progress', task.Status);
        }
    }
}