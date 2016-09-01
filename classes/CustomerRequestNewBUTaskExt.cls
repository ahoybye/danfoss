public with sharing class CustomerRequestNewBUTaskExt{

	private Task tsk;
	static Id BUtaskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Customer Request BU Task').getRecordTypeId();
	static Id MEtaskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Material Extension Task').getRecordTypeId();
	Id rectypeId; 
	Id creqId; 
	string rectype;
	public string creqname {get; set;}
	Integer HighestOrder = 0;
	static String prevOrder;
	static Date prevDate;	
	private List<Task> lstTasks;

	public CustomerRequestNewBUTaskExt(){
		creqname = ApexPages.currentPage().getParameters().get('crname');
		creqId = ApexPages.currentPage().getParameters().get('crID');
		rectype = ApexPages.currentPage().getParameters().get('rectype');
		if(rectype == 'ME')
			rectypeId = MEtaskRecTypeId;
		else
			rectypeId = BUtaskRecTypeId;
		lstTasks = new List<Task>([select Order__c, ActivityDate from Task where WhatId = :creqId and RecordTypeId = :rectypeId Order By Order__c DESC limit 1]);
	}
	
	public Task getTask() {	
		tsk = new Task();
		if(prevOrder != null){
			tsk.Est_Start_Date__c = prevDate;
			tsk.ActivityDate = prevDate.addDays(1);
			tsk.WhatId = creqId;
			tsk.Order__c = String.valueOf(integer.valueOf(prevOrder) + 1);
			tsk.RecordTypeId = rectypeId;
		}		
		else {
			if(!lstTasks.isEmpty() && lstTasks[0].Order__c != null && lstTasks[0].Order__c != ''){
				HighestOrder = integer.valueOf(lstTasks[0].Order__c);
				tsk.Est_Start_Date__c = lstTasks[0].ActivityDate;
				tsk.ActivityDate = lstTasks[0].ActivityDate.addDays(1);
			}
			else{
				tsk.Est_Start_Date__c = Date.today();
				tsk.ActivityDate = Date.today().addDays(1);
			}	
			tsk.WhatId = creqId;
			tsk.Order__c = String.valueOf(HighestOrder+1);
			tsk.RecordTypeId = rectypeId;  		
		}
	    return tsk;
	}
	
	public PageReference cSave(){
		if(tsk != null){
			try{
				insert tsk;
			}
			catch(DmlException ex){
      			return null;
			}
		}
		return new PageReference('/' + creqId);
	}
	
	public PageReference saveAndNew(){
		if(tsk != null){
			try{
				insert tsk;
				prevOrder = tsk.Order__c;
				prevDate = tsk.ActivityDate;
			}
			catch(DmlException ex){
      			return null;
			}
		}
		return new PageReference('/apex/CustomerRequestNewBUTask?crID='+creqId+'&rectype=BU&retURL=%2F'+creqId);
	}
	
	public PageReference cancel(){
		return new PageReference('/' + creqId);
	}
	
	public PageReference save(){
		return new PageReference('/' + creqId);
	}
}