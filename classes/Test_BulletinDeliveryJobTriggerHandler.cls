/*************************************************************************************************************
* @author Neeraj (Appirio Ind.)
* @date 12/09/2013
* @Task T-213767, I-85267
* @description  Test class for BulletinDeliveryJobTrigger
*************************************************************************************************************/
@isTest
private class Test_BulletinDeliveryJobTriggerHandler {
  /***********************************************************************************************************
  Test Defect Correction Job for inserts and updates
  ***********************************************************************************************************/
  static testMethod void testDefectCorrectionPositiveCase() {
    Account acc = Test_Utility.createAccount(1);
    insert acc;
    
    //Create 200 Bulletin Delivery Jobs
    List<Bulletin_Delivery_Job__c> lstBulletinJobs = new List<Bulletin_Delivery_Job__c>();
    for (Integer i = 0; i < 10; i++) {
        Bulletin_Delivery_Job__c bdj = Test_Utility.createBulletinDeliveryJob('Test Bulletin Job ' + i, false);
        lstBulletinJobs.add(bdj);
    }
    insert lstBulletinJobs;
    
    //Create 10 bulletin Account in Each Delivery job
    List<Bulletin_Accounts__c> lstBulletinAccs = new List<Bulletin_Accounts__c>();
    for (Bulletin_Delivery_Job__c bdjJob : lstBulletinJobs) {
        for (Integer i = 0; i < 5; i++) {
            lstBulletinAccs.add(Test_Utility.createBulletinAccounts(bdjJob.Id, acc.Id, false));
        }
    }
    insert lstBulletinAccs;
    
    //Add attachments for all bulletin accounts
    List<Bulletin_Delivery_Log__c> lstBDLogs = new List<Bulletin_Delivery_Log__c>();
    List<Attachment> lstAttach = new List<Attachment>(); 
    for (Bulletin_Accounts__c ba : lstBulletinAccs) {
        lstAttach.add(Test_Utility.createAttachment(ba.Id, false));
        lstBDLogs.add(Test_Utility.createBullDelLog('Test Log 1', ba.Id, false));
    }
    insert lstBDLogs;
    insert lstAttach;
    
    //Query bulletin account with all fields
    lstBulletinAccs = 
          [Select Id, Generic_Attachment_ID__c, Job_Type__c, Status__c, CreatedDate,  
                  Account__c, Account__r.Sales_Manager__r.IsActive, Account__r.OwnerId, Account__r.Owner.IsActive, Account__r.Country__r.Name, 
                  Account__r.Business_Org__c, Account__r.Channel__c, Bulletin_Delivery_Job__r.Name, Bulletin_Delivery_Job__r.Business_Org__c, 
                  Bulletin_Delivery_Job__c, Bulletin_Delivery_Job__r.Comments__c, Bulletin_Delivery_Job__r.Due_Date__c, 
                  Bulletin_Delivery_Job__r.CreatedBy.IsActive, Bulletin_Delivery_Job__r.Priority__c, Bulletin_Delivery_Job__r.Business_Area__c
          From Bulletin_Accounts__c 
          Where Id in :lstBulletinAccs
          Order by Bulletin_Delivery_Job__r.Status__c, CreatedDate];
    
    //Execute pibUtility method to create tasks for sensitive jobs
    //Create Tasks for Sensitive Bulletin Delivery Jobs
    PibUtility.processSendEmailToContactAndCreateTask(lstBulletinAccs);
    List<Task> lstTasks = [Select id from Task Where status = 'In Progress'];
    System.assertEquals(50, lstTasks.size()); //there should be 1000 tasks created one for each BA
    System.assertEquals(50, [Select count() from Attachment  Where ParentId in :lstTasks]); //1000 attachment 1 for each BA
    
    Test.startTest();
    //CASE 1: Insert 50 bulletin Delivery job with defect correction set to true and defective job created above. 
    //This should result in 500 tasks to created.
    List<Bulletin_Delivery_Job__c> lstNewBulletinJobs = new List<Bulletin_Delivery_Job__c>();
    for (Integer i = 0; i < 10; i++) {
      Bulletin_Delivery_Job__c bdj = Test_Utility.createBulletinDeliveryJob('Test Bulletin Job ' + i, false);
        bdj.Defective_Bulletin_Delivery_Job__c = lstBulletinJobs.get(i).Id;
        bdj.Defect_Correction__c = true;
        lstNewBulletinJobs.add(bdj); 
    }
    insert lstNewBulletinJobs;
    System.assertEquals(50, [Select count() from Task  Where status = 'Cancelled']); //there should be 500 tasks with status as cancelled.
    //There should only be 500 attachments left as attachments related to cancelled tasks are deleted.
    System.assertEquals(0, [Select count() from Attachment  Where ParentId in :lstTasks]); 
    //there should be 500 tasks with status as cancelled.
    
    //CASE 2: Validate update logic (update rest 50 jobs with defective job populated)
    lstNewBulletinJobs.clear();
    for (Integer i = 5; i < 10; i++) {
      Bulletin_Delivery_Job__c bdj = Test_Utility.createBulletinDeliveryJob('Test Bulletin Job ' + i, false);
      lstNewBulletinJobs.add(bdj); 
    }
    insert lstNewBulletinJobs;
    
    Integer i = 5;
    for (Bulletin_Delivery_Job__c bdj : lstNewBulletinJobs) {
      bdj.Defective_Bulletin_Delivery_Job__c = lstBulletinJobs.get(i++).Id;
      bdj.Defect_Correction__c = true;
    }
    update lstNewBulletinJobs;
    System.assertEquals(50, [Select count() from Task  Where status = 'Cancelled']);  //All tasks should get cancelled out
    System.assertEquals(0, [Select count() from Attachment  Where ParentId in :lstTasks]);  //All attachment will be deleted
    Test.stopTest();
  }
  
  /***********************************************************************************************************
  Test Defect Correction Job for inserts and updates
  ***********************************************************************************************************/
  static testMethod void testDefectCorrectionNegativeCase() {
    Account acc = Test_Utility.createAccount(1);
    insert acc;
    
    //Create 200 Bulletin Delivery Jobs
    List<Bulletin_Delivery_Job__c> lstBulletinJobs = new List<Bulletin_Delivery_Job__c>();
    for (Integer i = 0; i < 10; i++) {
      Bulletin_Delivery_Job__c bdj = Test_Utility.createBulletinDeliveryJob('Test Bulletin Job ' + i, false);
      lstBulletinJobs.add(bdj);
    }
    insert lstBulletinJobs;
    
    //Create 10 bulletin Account in Each Delivery job
    List<Bulletin_Accounts__c> lstBulletinAccs = new List<Bulletin_Accounts__c>();
    for (Bulletin_Delivery_Job__c bdjJob : lstBulletinJobs) {
      for (Integer i = 0; i < 5; i++) {
        lstBulletinAccs.add(Test_Utility.createBulletinAccounts(bdjJob.Id, acc.Id, false));
      }
    }
    insert lstBulletinAccs;
    
    //Add attachments for all bulletin accounts
    List<Bulletin_Delivery_Log__c> lstBDLogs = new List<Bulletin_Delivery_Log__c>();
    List<Attachment> lstAttach = new List<Attachment>(); 
    for (Bulletin_Accounts__c ba : lstBulletinAccs) {
      lstAttach.add(Test_Utility.createAttachment(ba.Id, false));
      lstBDLogs.add(Test_Utility.createBullDelLog('Test Log 1', ba.Id, false));
    }
    insert lstBDLogs;
    insert lstAttach;
    
    //Query bulletin account with all fields
    lstBulletinAccs = 
          [Select Id, Generic_Attachment_ID__c, Job_Type__c, Status__c, CreatedDate,  
                  Account__c, Account__r.Sales_Manager__r.IsActive, Account__r.OwnerId, Account__r.Owner.IsActive, Account__r.Country__r.Name, 
                  Account__r.Business_Org__c, Account__r.Channel__c, Bulletin_Delivery_Job__r.Name, Bulletin_Delivery_Job__r.Business_Org__c, 
                  Bulletin_Delivery_Job__c, Bulletin_Delivery_Job__r.Comments__c, Bulletin_Delivery_Job__r.Due_Date__c, 
                  Bulletin_Delivery_Job__r.CreatedBy.IsActive, Bulletin_Delivery_Job__r.Priority__c, Bulletin_Delivery_Job__r.Business_Area__c
          From Bulletin_Accounts__c 
          Where Id in :lstBulletinAccs
          Order by Bulletin_Delivery_Job__r.Status__c, CreatedDate];
    
    //Execute pibUtility method to create tasks for sensitive jobs
    //Create Tasks for Sensitive Bulletin Delivery Jobs
    PibUtility.processSendEmailToContactAndCreateTask(lstBulletinAccs);
    List<Task> lstTasks = [Select id from Task Where status = 'In Progress'];
    System.assertEquals(50, lstTasks.size()); //there should be 1000 tasks created one for each BA
    System.assertEquals(50, [Select count() from Attachment  Where ParentId in :lstTasks]); //1000 attachment 1 for each BA
    
    Test.startTest();
    
    //  CASE 1: Defect Correction is not checked but defective job is set
    //  Expected Result: No Tasks should get created
    List<Bulletin_Delivery_Job__c> lstNewBulletinJobs = new List<Bulletin_Delivery_Job__c>();
    for (Integer i = 0; i < 10; i++) {
      Bulletin_Delivery_Job__c bdj = Test_Utility.createBulletinDeliveryJob('Test Bulletin Job ' + i, false);
      bdj.Defective_Bulletin_Delivery_Job__c = lstBulletinJobs.get(i).Id;
      bdj.Defect_Correction__c = false;
      lstNewBulletinJobs.add(bdj); 
    }
    insert lstNewBulletinJobs;
    lstTasks = [Select id from Task Where status = 'Cancelled'];
    System.assertEquals(0, lstTasks.size());
    System.assertEquals(0, [Select count() from Attachment  Where ParentId in :lstTasks]); 
    
    //  CASE 2: Defect Correction is checked but defective job is blank
    //  Expected Result: No Tasks should get created
    for (Bulletin_Delivery_Job__c bdj : lstNewBulletinJobs) {
      bdj.Defective_Bulletin_Delivery_Job__c = null;
      bdj.Defect_Correction__c = true;
    }
    try {
      update lstNewBulletinJobs;
    } catch (Dmlexception ex) {
        system.assert(ex.getMessage().contains('Please select Defective Bulletin Delivery Job.'));
    }
    System.assertEquals(0, [Select count() from Task  Where status = 'Cancelled']);
    System.assertEquals(0, [Select count() from Attachment  Where ParentId in :lstTasks]); 
    
    Test.stopTest();
  }
  
}