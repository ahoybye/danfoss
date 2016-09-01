@isTest 
private class Test_ContractApprovals {
	static User adminUser;
	static User salesRep;
	static Account acct;
	static Account acctOEM;
	static Contract__c cont;
	static Contract__c cont2;
	static Contract__c cont3;
	static Contract__c cont4;
	static Contract__c cont5;
	static Contract__c cont6;
	static Contract__c cont7;
	static Contract_Attachment__c ca1;
	static Contract_Attachment__c ca2;
	static Contract_Attachment__c ca3;
	static Contract_Attachment__c ca4;
    static List<Task> lstTasks = new List<Task>();
    static Task task;
    static Task task2;
    static Task task3;
    static Task task4;
    static Task task5;
    static Task task6;
	static Id ContracttaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Task').getRecordTypeId();
	static Id ContractExpiredtaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Expired Task').getRecordTypeId();
    static Id CollabrecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Collaboration Task').getRecordTypeId();
	static Id record_Type_ContractHardCopy = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Hard Copy Task').getRecordTypeId();
	static Id ContractLegacyRecTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Legacy Contract').getRecordTypeId();
	
	static testMethod void runTestApprove(){
	    createUsers();			
		system.runAs(adminUser) {
			setupData();
		}
        System.runAs(salesRep) //Approve as SM User.
        {                
			createTestData(); 
	        createTestTasks();
			Test.startTest();
	        
	        try //Submit Approval
	        {
	            cont.Submit_For_Approval__c=true;
	            update cont;
	        }catch(Exception ex){}
            
            try
            {
                task.Contract_Expiration_Action__c = 'Extend';
                task.Contract_Extension_End_Date__c = System.Today().addDays(90);
                task.Status = 'Completed';                
                update task;
            }catch(Exception ex){}
			
           Test.stopTest();
        }
	}
	
	static testMethod void runTestHardCopy(){
	    createUsers();			
		system.runAs(adminUser) {
			setupData();
		}
        System.runAs(salesRep) //Approve as SM User.
        {                
			createTestData(); 
	        createTestTasks();
			Test.startTest();
			try //Submit Approval
	        {
				System.debug(cont5.Submit_for_Approval__c);
				System.debug(cont5.Signed__c);
				System.debug(cont5.Sent_to_Customer__c);
				System.debug(cont5.Returned__c);
				System.debug(cont5.Filed__c);
				System.debug(cont5.Hard_Copy_Done__c);
                task3.Status = 'Approved';
				update task3;
	            update cont5;
				
				System.debug(cont5.Submit_for_Approval__c);
				System.debug(cont5.Signed__c);
				System.debug(cont5.Sent_to_Customer__c);
				System.debug(cont5.Returned__c);
				System.debug(cont5.Filed__c);
				System.debug(cont5.Hard_Copy_Done__c);
                task4.Status = 'Completed';
				update task4;
	            update cont5;
				
				System.debug(cont5.Submit_for_Approval__c);
				System.debug(cont5.Signed__c);
				System.debug(cont5.Sent_to_Customer__c);
				System.debug(cont5.Returned__c);
				System.debug(cont5.Filed__c);
				System.debug(cont5.Hard_Copy_Done__c);
				task5.Status = 'Completed';
				update task5;
	            update cont5;
				
				System.debug(cont5.Submit_for_Approval__c);
				System.debug(cont5.Signed__c);
				System.debug(cont5.Sent_to_Customer__c);
				System.debug(cont5.Returned__c);
				System.debug(cont5.Filed__c);
				System.debug(cont5.Hard_Copy_Done__c);
				task6.Status = 'Completed';
				update task6;
	            update cont5;
				
				System.debug(cont5.Submit_for_Approval__c);
				System.debug(cont5.Signed__c);
				System.debug(cont5.Sent_to_Customer__c);
				System.debug(cont5.Returned__c);
				System.debug(cont5.Filed__c);
				System.debug(cont5.Hard_Copy_Done__c);
	        }
			catch(Exception ex){}
            
           Test.stopTest();
        }
	}

	static testMethod void  runTestApprovalControllers() {
	    createUsers();			
		system.runAs(adminUser) {
			setupData();
		}
		system.runAs(salesRep) {
			createTestData();
	        createTestTasks();
	    	Test.startTest();
	        Test.setCurrentPage(Page.ContractViewPage);
	        ApexPages.StandardController sc = new ApexPages.StandardController(cont);
	        ContractApprovalsExtension cls= new ContractApprovalsExtension(sc);
	        cls.Contract = cont;
	        cls.getTasks();
	        cls.getPastTasks();
	        cls.getCollabTasks();
			cls.getFieldHistory(); 
			cls.createTask();
			Test.stopTest();
		}
    }
    
	static testMethod void  runTestAttachmentController() {
	    createUsers();			
		system.runAs(adminUser) {
			setupData();
		}
		system.runAs(salesRep) {
			createTestData();
	    	Test.startTest();
	        Test.setCurrentPage(Page.ContractViewPage);
	        ApexPages.StandardController sc = new ApexPages.StandardController(cont);
	        ContractAttachmentsExtension ext = new ContractAttachmentsExtension(sc);
			ext.contAtt = ca1;
			List<Attachment> lstAtts = new List<Attachment>();
			Attachment att= new Attachment(Name='An attachment',body=blob.valueof('b'),parentId=ca1.Id);
			lstAtts.add(att);
			Attachment att2= new Attachment(Name='An attachment',body=blob.valueof('b'),parentId=ca2.Id);
			lstAtts.add(att2);
			Attachment att3= new Attachment(Name='An attachment',body=blob.valueof('b'),parentId=ca3.Id);
			lstAtts.add(att3);
			Attachment att4= new Attachment(Name='An attachment',body=blob.valueof('b'),parentId=ca4.Id);
			lstAtts.add(att4);
			insert lstAtts;
			ext.getAttachments();
			ext.addAttachment();
	        sc = new ApexPages.StandardController(cont3);
	        ext = new ContractAttachmentsExtension(sc);  
	        sc = new ApexPages.StandardController(cont5);
	        ext = new ContractAttachmentsExtension(sc);  
			update att;
			ext.contAtt = ca3;
			ext.attachmentToDel = att4.Id;
			ext.contAttToDel = ca4.Id;
	        ext.deleteAttachment();  
	        
			Test.setCurrentPage(Page.ContractAttach);
	        sc = new ApexPages.StandardController(ca1);
	        ContractAttachController cls= new ContractAttachController(sc);
			cls.contAtt = ca1;
			cls.attach.Name = null;
			cls.Upload();
			cls.getAttachments();
			cls.saveandReturn();
			cls.cancel();
	        sc = new ApexPages.StandardController(ca2);
	        cls= new ContractAttachController(sc);
			cls.contAtt = ca2;
			cls.attach.Name = att.Name;
			cls.attach.Body = att.body;
			cls.Upload();
			cls.saveandReturn();
	        sc = new ApexPages.StandardController(ca3);
	        cls= new ContractAttachController(sc);
			cls.contAtt = ca3;
			cls.attach.Name = att.Name;
			cls.attach.Body = att.body;
			cls.Upload();
			cls.saveandReturn();
			//delete att;
			Test.stopTest();
		}
    }
	
	private static void setupData(){   
		ContractTaskInstructions__c cti = new ContractTaskInstructions__c(Name='Instructions', Instructions__c = 'xyz');
		insert cti; 
	    ContractRegionalApprover__c regappr = new ContractRegionalApprover__c(Name='EMEA', Sales_Director_DIST__c=Userinfo.getUserId(), Sales_Director_OEM__c=Userinfo.getUserId(), Sales_VP__c =Userinfo.getUserId(), Sales_Executive__c=Userinfo.getUserId());        
	    insert regappr;    
		List<Approval_Flow_By_Contract_Type__c> lstAFCT = new List<Approval_Flow_By_Contract_Type__c>();
		Approval_Flow_By_Contract_Type__c AFCT1 = new Approval_Flow_By_Contract_Type__c(Next_Stage__c='Sales Manager', Amount__c='<500,001', Contract_Type__c='Development Agreement');
		lstAFCT.add(AFCT1);
	    Approval_Flow_By_Contract_Type__c AFCT2 = new Approval_Flow_By_Contract_Type__c(Next_Stage__c='Sales Director', Amount__c='500,001 > 5,000,000', Contract_Type__c='Development Agreement');         
		lstAFCT.add(AFCT2);  
		Approval_Flow_By_Contract_Type__c AFCT3 = new Approval_Flow_By_Contract_Type__c(Next_Stage__c='Sales VP', Amount__c='5,000,001 > 10,000,000', Contract_Type__c='Development Agreement');
		lstAFCT.add(AFCT3);
	    Approval_Flow_By_Contract_Type__c AFCT4 = new Approval_Flow_By_Contract_Type__c(Next_Stage__c='Sales Executive', Amount__c='10,000,001 > 15,000,000', Contract_Type__c='Development Agreement');      
		lstAFCT.add(AFCT4);
	    insert lstAFCT;    
		Folder lFolder = [select Id from Folder where Name = 'Contracts'];
	    EmailTemplate et = new EmailTemplate(Name ='Contract - Submitted For Approval', DeveloperName = 'abc', FolderId = lFolder.Id, TemplateType = 'Text', IsActive = true);   
		insert et;
	    ApprovalEmailTemplateMapping__c aetm = new ApprovalEmailTemplateMapping__c(Name = 'To Be Approved', Email_Template_ID__c=et.id);
		insert aetm;
	}
	
	private static void createTestData(){
		Region__c reg = new Region__c(Name='Europe', Contract_Region__c = 'EMEA', Region__c='Europe',Country_Code__c='UK');
	    insert reg;  
		List<Account> lstAccts = new List<Account>();
	    acct = Test_Utility.createAccount(1);
		acct.Sales_Manager__c = Userinfo.getUserId();
	    acct.Country__c = reg.Id;
		acct.Channel__c = 'Distributor';
	    lstAccts.add(acct);      
	    acctOEM = Test_Utility.createAccount(2);
		acctOEM.Sales_Manager__c = Userinfo.getUserId();
	    acctOEM.Country__c = reg.Id;
		acctOEM.Channel__c = 'Direct';
	    lstAccts.add(acctOEM);      
		insert lstAccts;
		Contact con = new Contact(LastName='Test Last Name',AccountId=acct.id,Email='test@danfoss.com');
	    insert con;
		DOW_Report_Setting__c dow = new DOW_Report_Setting__c(Name = 'Integrated', Email_To_Contact__c = con.Id);
		insert dow;
		List<Contract__c> lstContracts = new List<Contract__c>();
		cont = new Contract__c(Customer__c=acct.id,Contract_Type__c='Development Agreement', Amount__c='<500,001', Valid_From__c = Date.today(), Valid_To__c = Date.today().addDays(1100), Contract_Status__c = 'Collaboration');
        lstContracts.add(cont);
		cont2 = new Contract__c(Customer__c=acct.id,Contract_Type__c='Development Agreement', Amount__c='500,001 > 5,000,000', Valid_From__c = Date.today().addDays(-1000), Valid_To__c = Date.today().addDays(-1), Contract_Status__c = 'Expired', Expiration_Action__c = 'Renew', Expiring_In_90_Days__c=true);
        lstContracts.add(cont2);
		cont3 = new Contract__c(Customer__c=acct.id,Contract_Type__c='Development Agreement', Amount__c='5,000,001 > 10,000,000', Valid_From__c = Date.today(), Valid_To__c = Date.today().addDays(1100), Contract_Status__c = 'Active', Expiring_In_90_Days__c=true);
        lstContracts.add(cont3);
		cont4 = new Contract__c(Customer__c=acct.id,Contract_Type__c='Development Agreement', Amount__c='10,000,001 > 15,000,000', Valid_From__c = Date.today(), Valid_To__c = Date.today().addDays(1100), Contract_Status__c = 'Active', Expiring_Extension_In_90_Days__c =true);
        lstContracts.add(cont4);
		cont5 = new Contract__c(Customer__c=acctOEM.id,Contract_Type__c='Development Agreement', Amount__c='500,001 > 5,000,000', Valid_From__c = Date.today(), Valid_To__c = Date.today().addDays(1100), Contract_Status__c = 'Pending Approval');
        lstContracts.add(cont5);
		cont6 = new Contract__c(Customer__c=acct.id,Contract_Type__c='Development Agreement', Amount__c='5,000,001 > 10,000,000', Valid_From__c = Date.today(), Valid_To__c = Date.today().addDays(1100), Contract_Status__c = 'Active', RecordTypeId = ContractLegacyRecTypeId);
		lstContracts.add(cont6);
		cont7 = new Contract__c(Customer__c=acct.id,Contract_Type__c='Development Agreement', Amount__c='<500,001', Valid_From__c = Date.today(), Valid_To__c = Date.today().addDays(1100), Contract_Status__c = 'Collaboration', Customer_is_a_Competitor__c = 'Yes');
        lstContracts.add(cont7);
		insert lstContracts;
		List<Contract_Attachment__c> lstContractAttachments = new List<Contract_Attachment__c>();
		ca1 = new Contract_Attachment__c(Contract__c = cont.Id, Type__c = '1 - Rough');
		lstContractAttachments.add(ca1);
		ca2 = new Contract_Attachment__c(Contract__c = cont.Id, Type__c = '2 - Signed');
		lstContractAttachments.add(ca2);
		ca3 = new Contract_Attachment__c(Contract__c = cont5.Id, Type__c = '3 - Final');
		lstContractAttachments.add(ca3);
		ca4 = new Contract_Attachment__c(Contract__c = cont5.Id, Type__c = '1 - Rough');
		lstContractAttachments.add(ca4);
		insert lstContractAttachments;
	}

	private static void createTestTasks(){
		Id uId = Userinfo.getUserId();	       
        task = new Task(OwnerId = uId, Subject = 'Test Task', WhatId = cont3.Id, Priority = 'Normal', Status = 'Pending', ActivityDate = DateTime.Now().Date(), Contract_Stage__c = 'Expired', RecordTypeId = ContractExpiredtaskRecordTypeId);
		lstTasks.add(task);
		task2 = new Task(OwnerId = uId, Subject = 'Test Task 2:', WhatId = cont.Id, Priority = 'Normal', Status = 'Pending', RecordTypeId = ContracttaskRecordTypeId, ActivityDate = DateTime.Now().Date(), Contract_Stage__c = 'Sales Manager');
        lstTasks.add(task2);
        task3 = new Task(OwnerId = uId, Subject = 'Test Task 3:', WhatId = cont5.Id, Priority = 'Normal', Status = 'Pending', RecordTypeId = ContracttaskRecordTypeId, ActivityDate = DateTime.Now().Date(), Contract_Stage__c = 'Sales Manager');
        lstTasks.add(task3);
        task4 = new Task(OwnerId = uId, Subject = 'Test Task 4:', WhatId = cont5.Id, Priority = 'Normal', Status = 'Pending', RecordTypeId = record_Type_ContractHardCopy, ActivityDate = DateTime.Now().Date(), Contract_Stage__c = 'Sent_to_Customer__c');
        lstTasks.add(task4);
        task5 = new Task(OwnerId = uId, Subject = 'Test Task 5:', WhatId = cont5.Id, Priority = 'Normal', Status = 'Pending', RecordTypeId = record_Type_ContractHardCopy, ActivityDate = DateTime.Now().Date(), Contract_Stage__c = 'Returned__c');
        lstTasks.add(task5);
        task6 = new Task(OwnerId = uId, Subject = 'Test Task 6:', WhatId = cont5.Id, Priority = 'Normal', Status = 'Pending', RecordTypeId = record_Type_ContractHardCopy, ActivityDate = DateTime.Now().Date(), Contract_Stage__c = 'Filed__c');
        lstTasks.add(task6);
		if(!lstTasks.isEmpty())
			insert lstTasks;
	}

	private static void createUsers() {
		Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
		UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
		adminUser = Test_Utility.createUser(profile.Id, roles.Id, 1);
        adminUser.DelegatedApproverId = UserInfo.getUserId();
		salesRep = Test_Utility.createUser(profile.id, roles.Id, 2);
		salesRep.Business_Org__c = 'Danfoss';  
        List<User> users = new List<User>();
		users.add(adminUser);
        users.add(salesRep);
		if(!users.isEmpty())
        	insert users;
	}
}