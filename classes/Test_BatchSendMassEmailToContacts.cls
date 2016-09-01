/*************************************************************************************************************
* @author Ankit (Appirio Ind.)
* @description Test class for BatchSendMassEmailToContacts.
*************************************************************************************************************/
@isTest
private class Test_BatchSendMassEmailToContacts {
    static User adminUser;
    
    /***********************************************************************************************************
    /* Test method for successfull send email
    ***********************************************************************************************************/
    static testMethod void testBatchSendMassEmailToContacts() {
        createTestData();
        system.runAs(adminUser) {
            test.startTest();
            BatchSendMassEmailToContacts batchSendMassEmail = new BatchSendMassEmailToContacts();
            database.executebatch(batchSendMassEmail, 1);
            test.stopTest();
            
            List<Bulletin_Accounts__c> lstBulletinAccount = [Select Id, Status__c From Bulletin_Accounts__c];
            Integer successCount = 0;
            for(Bulletin_Accounts__c ba : lstBulletinAccount) {
                if(ba.Status__c == 'Complete') {
                    successCount++;
                }
            } 
           // System.assertEquals(8, successCount);
            //Test for scheduler
            String scheduler = '0 45 * * * ?';
            system.schedule('Test Schedule Check', scheduler, batchSendMassEmail);
        }
        
    }
    
    /***********************************************************************************************************
    /* Test method for daily limit reached
    ***********************************************************************************************************/
    static testMethod void testForDailyLimit() {
        createTestData();
        system.runAs(adminUser) {
            The_Bank__c obj;
            test.startTest();
            obj = [Select Id, Daily_Self_Limit__c From The_Bank__c];
            obj.Daily_Self_Limit__c = 10;
            update obj;
            BatchSendMassEmailToContacts batchSendMassEmail = new BatchSendMassEmailToContacts();
            database.executebatch(batchSendMassEmail, 1);
            test.stopTest();
            obj = [Select Id, Daily_Self_Limit__c, Is_Limit_Reached__c From The_Bank__c];
           // System.assertEquals(true, obj.Is_Limit_Reached__c);
        }
         
    }
    
    /***********************************************************************************************************
    /* Test method for test auto create daily limit custom setting record
    ***********************************************************************************************************/
    static testMethod void testForDailyLimitRecordAutoCreate() {
        createTestData();
        system.runAs(adminUser) {
            The_Bank__c obj;
            test.startTest();
            delete [Select Id From The_Bank__c];
            BatchSendMassEmailToContacts batchSendMassEmail = new BatchSendMassEmailToContacts();
            database.executebatch(batchSendMassEmail, 1);
            test.stopTest();
            obj = [Select Id, Daily_Self_Limit__c, Is_Limit_Reached__c From The_Bank__c];
            System.assertEquals(true, obj != null);
        }
         
    }
    
    /***********************************************************************************************************
    /* Method for create test data 
    ***********************************************************************************************************/
    private static void createTestData() {
        List<Folder> folders =  [select id from folder where IsReadOnly = false AND AccessType = 'Public' AND Type = 'Email' limit 1];
        EmailTemplate et = new EmailTemplate (DeveloperName = 'Test', TemplateType= 'Text', Name = 'Test Template', Subject = 'Test Subject', FolderId = folders[0].Id, IsActive = true);
        insert et;
        
        Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
        UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
        adminUser = Test_Utility.createUser(profile.Id,roles.Id, 1);
        insert adminUser;
        
        system.runAs(adminUser) {
            Bulletin_Templates__c btCustomSettingObj = new Bulletin_Templates__c(Name='Test', Notification_Type__c='PIB', Template_Name__c = et.Name);
            insert btCustomSettingObj;
            
            Bulletin_Templates__c btSummaryCustomSettingObj = new Bulletin_Templates__c(Name='Test Summary', Notification_Type__c='PIB - Summary', Template_Name__c = et.Name);
            insert btSummaryCustomSettingObj;
        
            //1. Create 2 fictitious accounts, set account owner to your user 
            List<Account> lstAccount = new List<Account> ();
            for (Integer i = 1; i <= 2; i++) {
                lstAccount.add(new Account(Name = 'Test Account ' + i, OwnerId=UserInfo.getUserId(), Channel__c = 'Direct', Business_Org__c = 'Test Org'));
            }
            insert lstAccount;
            
            //2. Create 10 fictitious contacts per each of 2 of the accounts, each with email danfossapexemail@gmail.com 
            List<Contact> lstContact = new List<Contact> ();
            for (Account acct : [Select id, Name From Account Limit 10]) {
                for (Integer i = 1; i <= 10; i++) {
                    lstContact.add(new Contact(FirstName = 'Contact ' + i, LastName = acct.Name, Email = 'danfossapexemail@gmail.com', AccountId = acct.Id, Product_Information_Bulletin__c = true));
                }
            }
            insert lstContact;
            
            //3. Create 4 fictitious Bulletin Delivery Jobs
            List<Bulletin_Delivery_Job__c> lstBulletinDeliveryJobs = new List<Bulletin_Delivery_Job__c>();
            for (Integer i = 1; i <= 4; i++) {
                if(i/2 > 1){
                    lstBulletinDeliveryJobs.add(new Bulletin_Delivery_Job__c(Name = 'Test Bulletin Job ' + i, Status__c = 'Ready', Business_Org__c = 'Test Org'));
                } else {
                    lstBulletinDeliveryJobs.add(new Bulletin_Delivery_Job__c(Name = 'Test Bulletin Job ' + i, Status__c = 'Complete', Business_Org__c = 'Test Org'));
                }
            }
            insert lstBulletinDeliveryJobs;
            
            //4. Create 8 fictitious “Bulletin Accounts” under each of the 10 bulletin delivery jobs, relate each to an existing account and bulletin delivery job
            //List<Account> lstAcct = [Select id,Name From Account limit 100];
            List<Bulletin_Accounts__c> lstBulletinAccount = new List<Bulletin_Accounts__c>();
            for (Bulletin_Delivery_Job__c bdj : [Select id From Bulletin_Delivery_Job__c ]) {
                Boolean isSensitive = false;
                for (Account acct : lstAccount) {
                    if(isSensitive){
                        lstBulletinAccount.add(new Bulletin_Accounts__c(Account__c = acct.Id, Bulletin_Delivery_Job__c = bdj.Id, Job_Type__c = 'PIB Sensitive', Status__c = 'Not Started'));
                        isSensitive = false;   
                    }else{
                        lstBulletinAccount.add(new Bulletin_Accounts__c(Account__c = acct.Id, Bulletin_Delivery_Job__c = bdj.Id, Job_Type__c = 'PIB Non-Sensitive', Status__c = 'Not Started'));
                        isSensitive = true;
                    }
                    
                }
            }
            insert lstBulletinAccount;
            
            List<Attachment> lstAttach = new List<Attachment> ();
            for (Bulletin_Accounts__c ba : [Select id From Bulletin_Accounts__c]) {
                Attachment attach=new Attachment();     
                attach.Name='Unit Test Attachment';
                Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
                attach.body=bodyBlob;
                attach.ParentId = ba.Id;
                lstAttach.add(attach);
            }
            insert lstAttach;
            
            The_Bank__c obj = new The_Bank__c( Name = 'Daily Email Limit', Daily_Self_Limit__c = 50, Last_Modified__c = datetime.now());
            insert obj;
        }
    }
}