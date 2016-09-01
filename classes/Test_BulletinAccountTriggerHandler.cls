/**
* @author Ankit (Appirio Ind.)
* @date 9 Dec, 2013
* @description Test Class for Bulletin Account Trigger and its handler class (BulletinAccountTriggerHandler)
*/
@isTest
private class Test_BulletinAccountTriggerHandler {
  /***********************************************************************************************************
   * Test status update of bulletin delivery job
  ***********************************************************************************************************/  
	static testMethod void runPositiveTestCases() {
    	Account acc = Test_Utility.createAccount(1);
	    insert acc;
	    
	    //Create 200 Bulletin Delivery Jobs
	    List<Bulletin_Delivery_Job__c> lstBulletinJobs = new List<Bulletin_Delivery_Job__c>();
	    for (Integer i = 0; i < 100; i++) {
	    	Bulletin_Delivery_Job__c bdj = Test_Utility.createBulletinDeliveryJob('Test Bulletin Job ' + i, false);
	    	lstBulletinJobs.add(bdj);
	    }
	    insert lstBulletinJobs;
	    
	    //Create 10 bulletin Account in Each Delivery job
	    List<Bulletin_Accounts__c> lstBulletinAccs = new List<Bulletin_Accounts__c>();
	    for (Bulletin_Delivery_Job__c bdjJob : lstBulletinJobs) {
	    	for (Integer i = 0; i < 10; i++) {
	    		lstBulletinAccs.add(Test_Utility.createBulletinAccounts(bdjJob.Id, acc.Id, false));
	    	}
	    }
	    insert lstBulletinAccs;
    	
    	Test.startTest();
    	//For test is status update of bulletin delivary job on bulletin account's status update
    	for(Bulletin_Accounts__c ba : lstBulletinAccs){
    		ba.Status__c = 'Complete';
    	}
    	update lstBulletinAccs;
    	lstBulletinJobs = [Select Id, Status__c From Bulletin_Delivery_Job__c];
    	for(Bulletin_Delivery_Job__c bdj : lstBulletinJobs) {
    		System.assertEquals('Completed', bdj.Status__c);
    	}
    	Test.stopTest();
   }
  
  /***********************************************************************************************************
   * Method for update status of Bulletin Delivery Job status
  ***********************************************************************************************************/
  static testMethod void runNegativeTestCases() {
  	Account acc = Test_Utility.createAccount(1);
    insert acc;
    
    //Create 200 Bulletin Delivery Jobs
    List<Bulletin_Delivery_Job__c> lstBulletinJobs = new List<Bulletin_Delivery_Job__c>();
    for (Integer i = 0; i < 100; i++) {
    	Bulletin_Delivery_Job__c bdj = Test_Utility.createBulletinDeliveryJob('Test Bulletin Job ' + i, false);
    	lstBulletinJobs.add(bdj);
    }
    insert lstBulletinJobs;
    
    //Create 10 bulletin Account in Each Delivery job
    List<Bulletin_Accounts__c> lstBulletinAccs = new List<Bulletin_Accounts__c>();
    for (Bulletin_Delivery_Job__c bdjJob : lstBulletinJobs) {
    	for (Integer i = 0; i < 10; i++) {
    		lstBulletinAccs.add(Test_Utility.createBulletinAccounts(bdjJob.Id, acc.Id, false));
    	}
    }
    insert lstBulletinAccs;
	
	Test.startTest();
	//For test is status update of bulletin delivary job on bulletin account's status update
	for(Bulletin_Accounts__c ba : lstBulletinAccs){
		ba.Status__c = 'Failed';
	}
	update lstBulletinAccs;
	lstBulletinJobs = [Select Id, Status__c From Bulletin_Delivery_Job__c];
	for(Bulletin_Delivery_Job__c bdj : lstBulletinJobs) {
		System.assertEquals('Fail', bdj.Status__c);
	}
	Test.stopTest();
  }    
}