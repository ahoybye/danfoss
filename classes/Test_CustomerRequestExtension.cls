@isTest
private class Test_CustomerRequestExtension {
	static User adminUser;
	static Id StdPBId;
	static PriceBookEntry stdpbe;
	static Product2 product;
	static List<Account> lstAccounts;
	static List<Opportunity> lstOpptys;
	static Account account1;
	static Account account2;
	static Opportunity oppty1;
	static Opportunity oppty2;
	static PS_Customer_Request__c custreq;
	static OpportunityLineItem oli;
	static Application__c appl;
	static List<CRSettings__c> lstcrs;
	static List<AccountTeamMember> teamList;
	static List<RecordType> lstRecordTypes;
	static List<PS_Customer_Request__c> lstCustReqs;
	static List<Task> lstTasks;
	static Map<String, RecordType> mapRecordTypes; 
	final static String CUSTOMER_SERVICE_REP= 'Customer Service Rep';
    final static String SALES_SPECIALIST = 'Sales Specialist';
    final static String SYSTEM_APPLICATION_ENGINEER = 'Systems & Applications Engineer';
	static User salesRep;
	static User custRep;
    static Id DanfosstaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Danfoss Task').getRecordTypeId();
	static Id BUtaskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Customer Request BU Task').getRecordTypeId();
    static Id CollabrecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Collaboration Task').getRecordTypeId();
	static Id MErecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Material Extension Task').getRecordTypeId();
	
	static testMethod void testTriggerHandlerAcctOnly() {
		createUsers();			
		system.runAs(adminUser) {
			createTestData();
		}		
		System.runAs(salesRep){
			Test.startTest();
			lstCustReqs = new List<PS_Customer_Request__c>();
			PS_Customer_Request__c custreq2 = new PS_Customer_Request__c(Account__c = account1.Id, RecordTypeId = mapRecordTypes.get('New Product').Id, Type__c = 'New Product');
			lstCustReqs.add(custreq2);
			PS_Customer_Request__c custreq3 = new PS_Customer_Request__c(Account__c = account1.Id, RecordTypeId = mapRecordTypes.get('Visitor Notification').Id, Type__c = 'Visitor Notification', ADC_Tour_Requested__c = true, Plant_of_Visit__c = 'AMS');
			lstCustReqs.add(custreq3);
			if(!lstCustReqs.isEmpty())
				insert lstCustReqs;
			Test.stopTest();
		}
	}
	
	static testMethod void testTriggerHandlerNewMat() {
		createUsers();			
		system.runAs(adminUser) {
			createTestData();
		}		
		System.runAs(salesRep){
			Test.startTest();
			lstCustReqs = new List<PS_Customer_Request__c>();
			PS_Customer_Request__c custreq6 = new PS_Customer_Request__c(Account__c = account1.Id, RecordTypeId = mapRecordTypes.get('New Material Number').Id, Type__c = 'New Material Number', Submit_To__c = 'Sales Specialist/CSR', Account_Region__c = 'Americas');
			lstCustReqs.add(custreq6);
			if(!lstCustReqs.isEmpty())
				insert lstCustReqs;
			custreq6.SubmittedInitially__c = true;
			update lstCustReqs;
			Test.stopTest();
		}
	}
	
	static testMethod void testTriggerHandlerLogistics() {
		createUsers();			
		system.runAs(adminUser) {
			createTestData();
		}		
		System.runAs(salesRep){
			Test.startTest();
			lstCustReqs = new List<PS_Customer_Request__c>();		
			PS_Customer_Request__c custreq4 = new PS_Customer_Request__c(Account__c = account1.Id, RecordTypeId = mapRecordTypes.get('Logistics Setup').Id, Type__c = 'Logistics Setup', Implement_Changes__c = 'No', Rejected_Reason__c = 'cuz');
			lstCustReqs.add(custreq4);
			if(!lstCustReqs.isEmpty())
				insert lstCustReqs;
			custreq4.SubmittedInitially__c = true;
			update lstCustReqs;
			Test.stopTest();
		}
	}
	
	static testMethod void testTriggerHandlerWithOppty() {
		createUsers();			
		system.runAs(adminUser) {
			createTestData();
		}		
		System.runAs(salesRep){
			oli = Test_Utility.createOpportunityLineItem(oppty1.Id, stdpbe.Id, 1);	
			insert oli;
			Test.startTest();
			lstCustReqs = new List<PS_Customer_Request__c>();
			PS_Customer_Request__c custreq1 = new PS_Customer_Request__c(Account__c = account1.Id, Opportunity__c = oppty1.Id, OpptyLineItemID__c = oli.Id, Product__c = product.Id, RecordTypeId = mapRecordTypes.get('System Model').Id, Type__c = 'System Model', Primary_BU__c = product.Business_Unit__c);
			lstCustReqs.add(custreq1);
			PS_Customer_Request__c custreq5 = new PS_Customer_Request__c(Account__c = account1.Id, Opportunity__c = oppty1.Id, OpptyLineItemID__c = oli.Id, Product__c = product.Id, RecordTypeId = mapRecordTypes.get('New Material Number').Id, Type__c = 'New Material Number', Submit_To__c = 'Sales Specialist/CSR');
			lstCustReqs.add(custreq5);
			PS_Customer_Request__c custreq7 = new PS_Customer_Request__c(Account__c = account1.Id, Opportunity__c = oppty1.Id, OpptyLineItemID__c = oli.Id, Product__c = product.Id, RecordTypeId = mapRecordTypes.get('New Material Number').Id, Type__c = 'New Material Number', Submit_To__c = 'Business Unit');
			lstCustReqs.add(custreq7);
			PS_Customer_Request__c custreq8 = new PS_Customer_Request__c(Account__c = account1.Id, Opportunity__c = oppty1.Id, OpptyLineItemID__c = oli.Id, Product__c = product.Id, Business_Unit__c = product.Business_Unit__c, RecordTypeId = mapRecordTypes.get('Drawing').Id, Type__c = 'Drawing');
			lstCustReqs.add(custreq8);
			if(!lstCustReqs.isEmpty())
				insert lstCustReqs;
			custreq1.Product_Second__c = product.Id;
			custreq1.Product_System__c = product.Id;
			custreq1.SubmittedInitially__c = true;
			custreq5.Application__c = appl.Id;
			custreq5.Customer_Material_Number__c = '12435';	
			custreq5.SubmittedInitially__c = true;
			custreq7.SubmittedInitially__c = true;
			custreq7.Status__c = 'In Progress';
			custreq8.SubmittedInitially__c = true;
			update lstCustReqs;
			Test.stopTest();
		}
	}
	
	static testMethod void testControllers() {
		createUsers();			
		system.runAs(adminUser) {
			createTestData();
		}		
		System.runAs(salesRep){
			oli = Test_Utility.createOpportunityLineItem(oppty1.Id, stdpbe.Id, 1);	
			insert oli;
			account1.Applications__c = appl.Name;
			update account1;
			custreq = new PS_Customer_Request__c(Account__c = account1.Id, Opportunity__c = oppty1.Id, OpptyLineItemID__c = oli.Id, Product__c = product.Id, RecordTypeId = mapRecordTypes.get('Drawing').Id, Type__c = 'Drawing');
			insert custreq;
			Test.startTest();
			PageReference pg = Page.CustomerRequestRedirect;
        	Test.setCurrentPage(pg);
        	ApexPages.currentPage().getParameters().put('id',custreq.Id);
        	ApexPages.currentPage().getParameters().put('type','Drawing');
			CustomerRequestRedirectController CRredirect = new CustomerRequestRedirectController();
			CRredirect.createAndRedirect();
			pg = Page.CustomerRequestNew;
        	Test.setCurrentPage(pg);
        	ApexPages.currentPage().getParameters().put('id',account1.Id);
			CustomerRequestNewController CRnew = new CustomerRequestNewController();
			CRnew.getItems();
			CRnew.getlstRecordTypes();
			CRnew.cancelRequest();
			CRnew.requestType = '6';
			CRnew.createRequest();
        	ApexPages.currentPage().getParameters().put('id',oli.id);
			CRnew = new CustomerRequestNewController();
			CRnew.requestType = '1';
			CRnew.createRequest();
			Test.stopTest();
		}
	}
	
    static testMethod void testNewBUTask() {
        createUsers();          
        system.runAs(adminUser) {
            createTestData();
        }       
        System.runAs(salesRep){
            oli = Test_Utility.createOpportunityLineItem(oppty1.Id, stdpbe.Id, 1);  
            insert oli;
            account1.Applications__c = appl.Name;
            update account1;
            custreq = new PS_Customer_Request__c(Account__c = account1.Id, Opportunity__c = oppty1.Id, OpptyLineItemID__c = oli.Id, Product__c = product.Id, RecordTypeId = mapRecordTypes.get('Drawing').Id, Type__c = 'Drawing');
            insert custreq;
            Test.startTest();
            PageReference pg = Page.CustomerRequestNewBUTask;
            Test.setCurrentPage(pg);
            ApexPages.currentPage().getParameters().put('crID',custreq.Id);
            CustomerRequestNewBUTaskExt CRnewBUtask = new CustomerRequestNewBUTaskExt();
            CRnewBUtask.getTask();
            CRnewBUtask.cSave();
            CRnewBUtask = new CustomerRequestNewBUTaskExt();
            CRnewBUtask.getTask();
            CRnewBUtask.saveAndNew();
            CRnewBUtask.getTask();
            CRnewBUtask.cancel();
            Test.stopTest();
        }
    }
	
	static testMethod void testCancelController() {
		createUsers();			
		system.runAs(adminUser) {
			createTestData();
		}		
		System.runAs(salesRep){
			Test.startTest();
			custreq = new PS_Customer_Request__c(Account__c = account1.Id, RecordTypeId = mapRecordTypes.get('Drawing').Id, Type__c = 'Drawing', Status__c = 'Not Submitted');
			insert custreq;			
			PageReference pg = Page.CustomerRequestCancel;
        	Test.setCurrentPage(pg);
        	ApexPages.currentPage().getParameters().put('pid', custreq.Account__c);
        	ApexPages.currentPage().getParameters().put('cid', custreq.Id);
			CustomerRequestCancelController CRcancel = new CustomerRequestCancelController();
			CRcancel.cancelAndRedirect();
			Test.stopTest();
		}
	}
	
	static testMethod void testViewControllers() {
		createUsers();			
		system.runAs(adminUser) {
			createTestData();
		}		
		System.runAs(salesRep){
			oli = Test_Utility.createOpportunityLineItem(oppty1.Id, stdpbe.Id, 1);	
			insert oli;
			Test.startTest();
			custreq = new PS_Customer_Request__c(Account__c = account1.Id, Opportunity__c = oppty1.Id, OpptyLineItemID__c = oli.Id, Product__c = product.Id, RecordTypeId = mapRecordTypes.get('Drawing').Id, Type__c = 'Drawing');
			insert custreq;			
			lstTasks = new List<Task>();
			Task tsk = new Task(WhatId = custreq.Id, RecordTypeId = BUtaskRecTypeId, Order__c = '1');
            lstTasks.add(tsk);
            tsk = new Task(WhatId = custreq.Id, RecordTypeId = DanfosstaskRecordTypeId, Status = 'Not Started', Type = 'CRPost', ActivityDate = DateTime.Now().Date());
            lstTasks.add(tsk);
            tsk = new Task(WhatId = custreq.Id, RecordTypeId = CollabrecTypeId, Status = 'Completed');
            lstTasks.add(tsk);            
            tsk = new Task(WhatId = custreq.Id, RecordTypeId = CollabrecTypeId, Status = 'Not Started', ActivityDate = DateTime.Now().Date(), Description = 'abc');
            lstTasks.add(tsk);            
            tsk = new Task(WhatId = custreq.Id, RecordTypeId = BUtaskRecTypeId, Status = 'Not Started', Order__c = '1', ActivityDate = DateTime.Now().Date());
            lstTasks.add(tsk);         
            tsk = new Task(WhatId = product.Id, RecordTypeId = MErecTypeId, Description = 'abc', Status = 'Not Started', Order__c = '1', ActivityDate = DateTime.Now().Date());
            lstTasks.add(tsk);
			if(!lstTasks.isEmpty())
				insert lstTasks;
			PageReference pg = Page.CustomerRequestViewPage;
        	Test.setCurrentPage(pg);
        	ApexPages.currentPage().getParameters().put('id',custreq.Id);
        	ApexPages.currentPage().getParameters().put('type','Drawing');
			CustomerRequestViewPageExtension CRview = new CustomerRequestViewPageExtension(new ApexPages.StandardController(custreq));
			CRview.createTaskSales();
			CRview.createTaskBU();
			CRview.submitToBU();
			
			Test.setCurrentPage(Page.CustomerRequestBURouting);
			CustomerRequestBURoutingController BUrouting = new CustomerRequestBURoutingController(new ApexPages.StandardController(product));
			BUrouting.submitToBU();
			Test.stopTest();
		}
	} 
	
	static testMethod void testExtension() {
		createUsers();			
		system.runAs(adminUser) {
			createTestData();
		}		
		System.runAs(salesRep){
			oli = Test_Utility.createOpportunityLineItem(oppty1.Id, stdpbe.Id, 1);	
			insert oli;
			Test.startTest();
			custreq = new PS_Customer_Request__c(Account__c = account1.Id, Opportunity__c = oppty1.Id, OpptyLineItemID__c = oli.Id, Product__c = product.Id, RecordTypeId = mapRecordTypes.get('Drawing').Id, Type__c = 'Drawing', Status__c = 'Not Submitted');
			insert custreq;			
			PageReference pg = Page.CustomerRequestOLI;
        	Test.setCurrentPage(pg);
        	ApexPages.currentPage().getParameters().put('id',custreq.Account__c);
        	ApexPages.currentPage().getParameters().put('oid', oppty1.Id);
			CustomerRequestExtension CRext = new CustomerRequestExtension(new ApexPages.StandardController(custreq));
			CRext.getStati();
			CRext.getOpptys();
			CRext.getItems();
			CRext.selectedStatus = 'Not Submitted';
			CRext.selectedOppty = null;
			CRext.requestType = 'nullvalue';
			CRext.getCRs();	
			CRext.selectedStatus = 'Not Submitted';
			CRext.selectedOppty = 'all';
			CRext.requestType = 'nullvalue';
			CRext.getCRs();	
			CRext.selectedStatus = 'nullvalue';
			CRext.selectedOppty = oppty1.Id;
			CRext.requestType = 'nullvalue';
			CRext.getCRs();		
			CRext.selectedStatus = 'nullvalue';
			CRext.selectedOppty = 'all';
			CRext.requestType = 'Drawing';
			CRext.getCRs();	
			CRext.selectedStatus = 'nullvalue';
			CRext.selectedOppty = oppty1.Id;
			CRext.requestType = 'Drawing';
			CRext.getCRs();	
			CRext.selectedStatus = 'Not Submitted';
			CRext.selectedOppty = 'all';
			CRext.requestType = 'Drawing';
			CRext.getCRs();	
			CRext.selectedStatus = 'Not Submitted';
			CRext.selectedOppty = null;
			CRext.requestType = 'Drawing';
			CRext.getCRs();	
			CRext.selectedStatus = 'Not Submitted';
			CRext.selectedOppty = oppty1.Id;
			CRext.requestType = 'nullvalue';
			CRext.getCRs();	
			CRext.requestType = 'Drawing';
			CRext.selectedOppty = oppty1.Id;
			CRext.selectedStatus = 'Not Submitted';
			CRext.getCRs();	
        	ApexPages.currentPage().getParameters().put('id',oli.Id);
			CRext = new CustomerRequestExtension(new ApexPages.StandardController(custreq));			
			CRext.getItems();
			CRext.sortField = 'Name';
			CRext.doSort();
			Test.stopTest();
		}
	}
	
	static void createTestData(){
    	Test_Utility.initTestData();   //create C&E pricebook
		product = Test_Utility.createProduct2();
		product.Business_Unit__c = 'Motors';
		product.ProductCode = '11111';
		product.Model_Code__c = 'modelcodetext';
		product.Business_Org__c = 'Danfoss';
		insert product;
		StdPBId = Test.getStandardPricebookId();
		stdpbe = new PricebookEntry(Pricebook2Id = StdPBId, Product2Id = product.Id, UnitPrice = 100, IsActive = true, CurrencyISOCode = 'DKK');
		insert stdpbe;
		appl = new Application__c(Name = 'Tractor', Market_Segment__c = 'Agricultural Machine', SAP_Application_Code__c = 'ABA');
		insert appl;
		lstAccounts = new List<Account>();			
    	account1 = Test_Utility.createAccount(1);
		account1.Applications__c = appl.Name;
		lstAccounts.add(account1);		
		if(!lstAccounts.isEmpty())
			insert lstAccounts;
		teamList = new List<AccountTeamMember>();
        AccountTeamMember team1 = new AccountTeamMember(accountId = account1.id,TeamMemberRole = SYSTEM_APPLICATION_ENGINEER, UserId = Userinfo.getUserId());
        AccountTeamMember team2 = new AccountTeamMember(accountId = account1.id,TeamMemberRole = CUSTOMER_SERVICE_REP, UserId = custRep.id);
        AccountTeamMember team3 = new AccountTeamMember(accountId = account1.id,TeamMemberRole = SALES_SPECIALIST,  UserId = salesRep.id);                                                                
        teamList.add(team1);
        teamList.add(team2);
        teamList.add(team3);
		if(!teamList.isEmpty())
        	insert teamList;
		lstOpptys = new List<Opportunity>();
		oppty1 = Test_Utility.createOpportunity(account1.Id, 1);
		oppty1.Application__c = null;
		lstOpptys.add(oppty1);
		if(!lstOpptys.isEmpty())
			insert lstOpptys;
		OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = oppty1.id,TeamMemberRole = SYSTEM_APPLICATION_ENGINEER,  UserId = salesRep.id);
		insert otm;
		mapRecordTypes = new Map<String, RecordType>();
		lstcrs = new List<CRSettings__c>();
		for(RecordType rt :[select Id, Name from RecordType where SobjectType = 'PS_Customer_Request__c']){
			mapRecordTypes.put(rt.Name, rt);
			CRSettings__c crs = new CRSettings__c();
			crs.Name = rt.Name;
			crs.Needs_BU_Routing_Section__c = true;
			crs.Account__c = true;
			if(rt.Name == 'New Material Number')
				crs.Initial_Owner__c = 'Submit_To__c';
			else if(rt.Name == 'Logistics Setup')
				crs.Initial_Owner__c = 'CR_CSR_Leaders';
			else
				crs.Initial_Owner__c = 'BU';
			crs.Opportunity_Product__c = true;
			crs.Requires_Confirmed_Date__c = true;	
			crs.Requires_SAE_Review__c = true;
			if(rt.Name == 'Drawing')
				crs.Order__c = '1';
			else if (rt.Name == 'System Model')
				crs.Order__c = '6';
			else
				crs.Order__c = '0';
			lstcrs.add(crs);
		}
		CRSettings__c crs = new CRSettings__c();
		crs.Name = 'AMS ADC Tour Requested';
		crs.Initial_Owner__c = UserInfo.getUserId();
		lstcrs.add(crs);
		if(!lstcrs.isEmpty())
			insert lstcrs;
		Folder lFolder = [select Id from Folder where Name = 'PS: Customer Requests'];
	    EmailTemplate et = new EmailTemplate(Name ='Submit for Review', DeveloperName = 'abc', FolderId = lFolder.Id, TemplateType = 'text',  TemplateStyle = 'freeForm', IsActive = true);   
		insert et;
	    ApprovalEmailTemplateMapping__c aetm = new ApprovalEmailTemplateMapping__c(Name = 'Submit for Review', Email_Template_ID__c=et.id);
		insert aetm;    
	    Contact con = new Contact(LastName='Test Last Name',AccountId=account1.id,Email='test@danfoss.com');
	    insert con;
		DOW_Report_Setting__c dow = new DOW_Report_Setting__c(Name = 'Integrated', Email_To_Contact__c = con.Id);
		insert dow;
		lFolder = [select Id from Folder where Name = 'Shared Documents'];
		Document lt = new Document(Name = 'Lead times', FolderId = lFolder.Id);
		insert lt;
	}
	
	private static void createUsers() {
		Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
		UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
		adminUser = Test_Utility.createUser(profile.Id, roles.Id, 1);
		adminUser.DelegatedApproverId = UserInfo.getUserId();
		salesRep = Test_Utility.createUser(profile.id, roles.Id, 2);
		salesRep.Business_Org__c = 'Danfoss';
        custRep = Test_Utility.createUser(profile.id, roles.Id, 3);        
        List<User> users = new List<User>();
		users.add(adminUser);
        users.add(salesRep);
        users.add(custRep);
		if(!users.isEmpty())
        	insert users;
	}
	
}