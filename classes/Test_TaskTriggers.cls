@isTest
private class Test_TaskTriggers {
	
	static Account account;
	static Opportunity oppty;		
	static User adminUser;	
	static Id DanfossRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Danfoss Task').getRecordTypeId();
	static Id BUtaskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Customer Request BU Task').getRecordTypeId();
	static Id LogisticsRecTypeId = Schema.SObjectType.PS_Customer_Request__c.getRecordTypeInfosByName().get('Logistics Setup').getRecordTypeId();
	
    static testMethod void testCaseTask() { 
        createTestData();
		Case cse = new Case(Subject = 'Test Case');
		insert cse;
		List<Task> lstTasks = new List<Task>();
		Test.startTest();
		Task taskPricing = new Task(OwnerId = Userinfo.getUserId(), Subject = 'Annual Price Adjustment – Customer Price List', WhatId = cse.Id, Priority = 'Normal', Status = 'Not Started', RecordTypeId = DanfossRecordTypeId, Uploaded__c = True, ActivityDate = DateTime.Now().Date());
        lstTasks.add(taskPricing);          
		if(!lstTasks.isEmpty())
			insert lstTasks;
        taskPricing.Status = 'Completed';
        taskPricing.Closing_Comments__c = 'comment';
        update lstTasks;
		Test.stopTest(); 
    }
	
	 static testMethod void testCRTask() { 
        createTestData();		 
		PS_Customer_Request__c custreq = new PS_Customer_Request__c(Account__c = account.Id, RecordTypeId = LogisticsRecTypeId, Type__c = 'Logistics Setup');
		insert custreq;
		List<Task> lstTasks = new List<Task>();
		Test.startTest();		      
        Task tskbu = new Task(WhatId = custreq.Id, RecordTypeId = BUtaskRecTypeId, Status = 'Not Started', Order__c = '1', ActivityDate = DateTime.Now().Date());
        lstTasks.add(tskbu);  
		if(!lstTasks.isEmpty())
			insert lstTasks;
		tskbu.Status = 'Completed';
        update lstTasks;
		Test.stopTest(); 
    }
	
	 static testMethod void testExTask() { 
        createTestData();		 
		//createUsers();
		oppty = createOpportunity(account.Id, 1);
		insert oppty;  
		Test.startTest();
		Task task = new Task(OwnerId = Userinfo.getUserId(), Subject = 'Exhibition Follow-up Task:', WhatId = oppty.Id, Priority = 'Normal', Status = 'Not Started', RecordTypeId = DanfossRecordTypeId, ActivityDate = DateTime.Now().Date());
        insert task;
		/*task.OwnerId = adminUser.Id;
		update task;*/
        Attachment att = new Attachment(OwnerId = Userinfo.getUserId(), ParentId = task.Id, Name = 'test attachment', Body = Blob.valueOf('b'));
        insert att;
		Test.stopTest(); 
    }
	
	static void createTestData(){
		account = Test_Utility.createAccount(1);
		insert account;
		CRSettings__c crs = new CRSettings__c(Name = 'Logistics Setup', Initial_Owner__c = Userinfo.getUserId(), Requires_SAE_Review__c = false);
		insert crs;
	}
	
	private static Opportunity createOpportunity(Id accountId, Integer i){
        Opportunity opportunity = new Opportunity(
                                Name='Test opportunity name'+i,
                                CurrencyISOCode = 'DKK',
                                AccountId = accountId,
                                StageName = 'Evaluating Need',
                                Production_Start_Date__c = Date.today().addDays(10),
                                CloseDate = Date.today().addDays(5));
        return opportunity;
    }
	
	private static void createUsers() {
		Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
		UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
		adminUser = Test_Utility.createUser(profile.Id, roles.Id, 1);
		adminUser.DelegatedApproverId = UserInfo.getUserId();
		insert adminUser;
	}
}