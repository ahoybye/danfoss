public without sharing class ContractTriggerHandler{
	
    static final String MANAGER = 'Sales Manager';
    static final String DIRECTOR = 'Sales Director';
	static final String VP = 'Sales VP';
	static final String EXECUTIVE = 'Sales Executive';
    static final String EXPIRED = 'Expired';
    static final String ACTIVE = 'Active';
	static final String APPROVEDTEMPLATE = 'Danfoss Approved Template';
	static final string instructions = ContractTaskInstructions__c.getInstance('Instructions').Instructions__c;
	static Id record_Type_Contract = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Task').getRecordTypeId();
	static Id record_Type_ContractExpired = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Expired Task').getRecordTypeId();
	static Id ApprovalBypassRecTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Approval Bypass').getRecordTypeId();
	static Id ContractLockedRecTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Approval Locked').getRecordTypeId();
	
	public static void setLegacyFields(List<Contract__C> lstContracts)   //before insert
	{
		for (Contract__C cont :lstContracts){
			if(cont.RecordTypeId == ApprovalBypassRecTypeId){
				cont.Approval_Bypass__c = true;
				cont.Contract_Status__c = ACTIVE;
				cont.ActiveContractEmailSent__c = true;
				cont.FullyApprovedEmailSent__c = true;
				cont.Signed__c = true;
				cont.Sent_to_Customer__c = true;
				cont.Returned__c = true;
				cont.Filed__c = true;
				cont.Hard_Copy_Done__c = true;
			}
		}
	}
	
	public static void populateApprovers(List<Contract__C> lstContracts)   //before insert and update
	{
		map<Id, Account> mapAccounts = new map<Id, Account>();
		Set<Id> setCustomerIds = new set<Id>();
		Set<String> setContractTypes = new set<String>();
		Set<String> setContractRegions = new set<String>();
		string grpRegion;
		for (Contract__C cont :lstContracts){
			setCustomerIds.add(cont.Customer__c);
			setContractTypes.add(cont.Contract_Type__c);
			setContractRegions.add(cont.Region__c);
		}		
		for (Account a :[select Id, OwnerId, Sales_Manager__c, Country__r.Region__c From Account where Id IN :setCustomerIds]){
			mapAccounts.put(a.Id, a);
		}
		Map <String , ContractRegionalApprover__c> mapRegions = new Map <String , ContractRegionalApprover__c>();
		for (ContractRegionalApprover__c reg :[select Name, Sales_Director_DIST__c, Sales_Director_OEM__c, Sales_VP__c, Sales_Executive__c, Contract_Specialist__c From ContractRegionalApprover__c where Name IN :setContractRegions]){
			mapRegions.put(reg.Name, reg);
		}
		Map <String , Approval_Flow_By_Contract_Type__c> mapAFCT = new Map <String , Approval_Flow_By_Contract_Type__c>();
		for (Approval_Flow_By_Contract_Type__c a :[select Next_Stage__c, Amount__c From Approval_Flow_By_Contract_Type__c where Contract_Type__c IN :setContractTypes]){
			mapAFCT.put(a.Next_Stage__c, a);
		}
		for (Contract__C cont :lstContracts)
		{
			cont.Account_Manager__c = mapAccounts.get(cont.Customer__c).OwnerId;
        	cont.OwnerId = mapAccounts.get(cont.Customer__c).OwnerId;
    	  	cont.Sales_Manager_of_Account__c = mapAccounts.get(cont.Customer__c).Sales_Manager__c;
        	cont.Contract_Specialist__c = mapRegions.get(cont.Region__c).Contract_Specialist__c;
				        
			if(cont.Legacy__c || cont.Approval_Bypass__c)
				break;
					
			string channel = '';
			if (cont.Customer_Channel__c == 'Distributor' || cont.Customer_Channel__c == 'Indirect') {
        		channel = 'DIST';
			}
			else if (cont.Customer_Channel__c == 'Direct' || cont.Customer_Channel__c == 'Global') {
        		channel = 'OEM';
			}
			
			Boolean CEOreq = false;
			if((cont.Amount__c.contains('>17') && mapAFCT.get(EXECUTIVE) != null && mapAFCT.get(EXECUTIVE).Amount__c != null && mapAFCT.get(EXECUTIVE).Amount__c.contains('>17') && cont.Contract_Type__c != 'Product Improvement Programs') || 
			(cont.Amount__c.contains('- 17') && mapAFCT.get(EXECUTIVE) != null && mapAFCT.get(EXECUTIVE).Amount__c != null  && mapAFCT.get(EXECUTIVE).Amount__c.contains('- 17') && cont.Contract_Type__c != 'Product Improvement Programs') || 
			(cont.Cancellation_Clause__c == 'No' && cont.More_Than_3_Years__c == 'Yes') || cont.Customer_is_a_Competitor__c == 'Yes' || cont.Application_High_Risk__c == 'Yes' || cont.Market_Dominated_By_Danfoss__c == 'Yes'){
				CEOreq = true;
			}
			
			if (CEOreq == true){
                cont.Expected_Approver__c = mapRegions.get(cont.Region__c).Sales_Executive__c;
				cont.Expected_Role__c = EXECUTIVE;
			}
			else if (mapAFCT.get(MANAGER) != null && mapAFCT.get(MANAGER).Amount__c != null && mapAFCT.get(MANAGER).Amount__c.contains(cont.Amount__c)){
                cont.Expected_Approver__c = cont.Sales_Manager_of_Account__c; 
				cont.Expected_Role__c = MANAGER;
			}
			else if (mapAFCT.get(DIRECTOR) != null && mapAFCT.get(DIRECTOR).Amount__c != null && mapAFCT.get(DIRECTOR).Amount__c.contains(cont.Amount__c) && channel == 'DIST'){
				cont.Expected_Approver__c = mapRegions.get(cont.Region__c).Sales_Director_DIST__c;
				cont.Expected_Role__c = DIRECTOR + ' DIST';
			}
			else if (mapAFCT.get(DIRECTOR) != null && mapAFCT.get(DIRECTOR).Amount__c != null && mapAFCT.get(DIRECTOR).Amount__c.contains(cont.Amount__c) && channel == 'OEM'){
				cont.Expected_Approver__c = mapRegions.get(cont.Region__c).Sales_Director_OEM__c;
				cont.Expected_Role__c = DIRECTOR + ' OEM';
			}
			else if (mapAFCT.get(VP) != null && mapAFCT.get(VP).Amount__c != null && mapAFCT.get(VP).Amount__c.contains(cont.Amount__c)){
                cont.Expected_Approver__c = mapRegions.get(cont.Region__c).Sales_VP__c; 
				cont.Expected_Role__c = VP;
			}
			else if ((mapAFCT.get(EXECUTIVE) != null && mapAFCT.get(EXECUTIVE).Amount__c != null && mapAFCT.get(EXECUTIVE).Amount__c.contains(cont.Amount__c)) || cont.PS_CEO_Approval_Required__c == true){
                cont.Expected_Approver__c = mapRegions.get(cont.Region__c).Sales_Executive__c;
				cont.Expected_Role__c = EXECUTIVE;
			}
		}
    }
	
	public static void fieldChecks(List<Contract__C> lstContracts)   //before insert and update
	{		
		Set<String> setContractTypes = new set<String>();
		for (Contract__C cont :lstContracts){
			setContractTypes.add(cont.Contract_Type__c);
		}
		Map <String , Approval_Flow_By_Contract_Type__c> mapAFCT = new Map <String , Approval_Flow_By_Contract_Type__c>();
		for (Approval_Flow_By_Contract_Type__c a :[select Name, Current_Stage__c,Next_Stage__c, Amount__c, Contract_Type__c From Approval_Flow_By_Contract_Type__c where Contract_Type__c IN :setContractTypes]){
			mapAFCT.put(a.Next_Stage__c, a);
		}
		for (Contract__C cont :lstContracts)
		{   
			if(cont.Contract_Duration__c >= 1096)
				cont.More_Than_3_Years__c = 'Yes';
			else
				cont.More_Than_3_Years__c = 'No';
			if(cont.Amount__c != null){
				if((cont.Amount__c.contains('>17') && mapAFCT.get(EXECUTIVE) != null && mapAFCT.get(EXECUTIVE).Amount__c.contains('>17') && cont.Contract_Type__c != 'Product Improvement Programs') || (cont.Cancellation_Clause__c == 'No' && cont.More_Than_3_Years__c == 'Yes') || cont.Customer_is_a_Competitor__c == 'Yes' || cont.Application_High_Risk__c == 'Yes' || cont.Market_Dominated_By_Danfoss__c == 'Yes')
					cont.EC_Approval_Required__c = true;
				else
					cont.EC_Approval_Required__c = false;		
				
				if(cont.EC_Approval_Required__c == true || (cont.Amount__c.contains('- 17') && mapAFCT.get(EXECUTIVE) != null && mapAFCT.get(EXECUTIVE).Amount__c.contains('- 17') && cont.Contract_Type__c != 'Product Improvement Programs'))
					cont.PS_CEO_Approval_Required__c = true;
				else
					cont.PS_CEO_Approval_Required__c = false;		
				
				if(cont.PS_CEO_Approval_Required__c == true || (cont.Template__c != null && cont.Template__c.contains('Special')))
					cont.Legal_Review_Required__c = true;
				else
					cont.Legal_Review_Required__c = false;	
			}
		}
	}
	
	public static void createExpirationTask(List<Contract__c> lstContracts, Map<Id, Contract__c> mapContracts) //before update
	{
		Contract__c contRecOld = new Contract__c();
		List<Task> lstTasks = new List<Task>();
		for (Contract__c contRec:lstContracts)
		{	
			if (mapContracts != null)
				contRecOld = mapContracts.get(contRec.Id);	
			
			Task task = new Task();
			task.RecordTypeId = record_Type_ContractExpired;
		    task.OwnerId = contRec.Account_Manager__c;
		    task.WhatId = contRec.Id;
		    task.Status = 'Pending';
		    task.IsReminderSet = true;
			task.Contract_Instructions__c = instructions;
			
			if (contRec.Contract_Status__c == ACTIVE && contRec.Expiring_Extension_In_90_Days__c)
			{
				task.Subject = 'Contract Extension Ends Soon: ' + contRec.Name + ' for ' + contRec.Customer_Name__c; 
				task.Contract_Stage__c = EXPIRED + 'Ext90';
				task.ActivityDate = System.Date.today().addDays(90);
				task.ReminderDateTime = System.datetime.now().addDays(30);
				insert task;
				contRec.Expiring_Extension_In_90_Days__c = false;
			}		
			else if (contRec.Contract_Status__c == ACTIVE && contRec.Expiring_In_90_Days__c)
			{
				task.Subject = 'Contract Expiring Soon: ' + contRec.Name + ' for ' + contRec.Customer_Name__c; 
				task.Contract_Stage__c = EXPIRED + '90';
				task.ActivityDate = contRec.Valid_To__c.addDays(-90);
				task.ReminderDateTime = contRec.Valid_To__c.addDays(-30);
				insert task;
				contRec.Expiring_In_90_Days__c = false;
			}
			else if (contRec.Contract_Status__c == EXPIRED && contRec.Contract_Status__c != contRecOld.Contract_Status__c
				&& contRec.Expiration_Action__c != 'Renew' && contRec.Expiration_Action__c != 'Do Not Renew')				
			{				
				task.Subject = 'Contract has EXPIRED: Notify ' + contRec.Customer_Name__c + ' of ' + contRec.Name ; 
				task.Contract_Stage__c = EXPIRED;
				task.ActivityDate = System.Date.today().addDays(2);
				task.ReminderDateTime = System.datetime.now().addDays(1);
				insert task;
			}
		}
	}
		
	public static void checkAttachments(List<Contract__C> lstContracts)		//before update
	{
		Set<Id> setContractIds = new Set<Id>();
		Map<Id, List<Contract_Attachment__c>> mapContractAndAttachments = new Map<Id, List<Contract_Attachment__c>>();
		for (Contract__c contRec :lstContracts)
		{
			setContractIds.add(contRec.Id);
		}
		for (Contract_Attachment__c ca :[Select Id, Contract__c From Contract_Attachment__c where Contract__c IN :setContractIds])
		{
			if (!mapContractAndAttachments.containsKey(ca.Contract__c))
			{
				mapContractAndAttachments.put(ca.Contract__c, new List<Contract_Attachment__c>());
			}
			mapContractAndAttachments.get(ca.Contract__c).add(ca);
		}
		for (Contract__c contRec :lstContracts)
		{
			if (mapContractAndAttachments.isEmpty() || mapContractAndAttachments.get(contRec.Id).isEmpty())
			{
				contRec.File_Attached__c = false;
			}
		}
	}
	
	public static void RenewContract(List<Contract__c> lstContracts)		//before update
	{
		for (Contract__c contRec :lstContracts)
		{
			if (contRec.Expiration_Action__c == 'Renew' && contRec.Contract_New__c == null)
			{
				Contract__c newContRec = new Contract__c();
				newContRec.Contract_Old__c = contRec.Id;
				newContRec.Customer__c = contRec.Customer__c;
				newContRec.Contract_Type__c = contRec.Contract_Type__c;
				newContRec.Product__c = contRec.Product__c;
				newContRec.Amount__c = contRec.Amount__c;
				newContRec.Contract_Description__c = ContRec.Contract_Description__c;
				insert newContRec;
				contRec.Contract_New__c = newContRec.Id;
			}
		}
	}	
			
	public static void processApproval(List<Contract__c> lstContracts)
	{
		Contract__c contRecOld = new Contract__c();
		for (Contract__c contRec:lstContracts) {
			if (contRec.Submit_For_Approval__c && contRec.Contract_Status__c != 'Pending Approval'){
				contRec.Contract_Status__c = 'Pending Approval';
				contRec.RecordTypeId = ContractLockedRecTypeId;
				ContractTaskCreationHelper.CreateApprovalTask(contRec.Expected_Role__c, contRec.Expected_Approver__c, contRec);	//creates approval task
			}
			else if (contRec.Signed__c && !contRec.Sent_to_Customer__c)
				ContractTaskCreationHelper.CreateHardCopyTask('Signed', contRec);
			else if (!contRec.Hard_Copy_Done__c && !contRec.Submit_For_Approval__c) {				
				if (contRec.Sent_to_Customer__c && !contRec.Returned__c)
		          ContractTaskCreationHelper.CreateHardCopyTask('Sent', contRec);
		        else if (contRec.Sent_to_Customer__c && contRec.Returned__c)
		          ContractTaskCreationHelper.CreateHardCopyTask('Returned', contRec);
			}
		}
	}
}