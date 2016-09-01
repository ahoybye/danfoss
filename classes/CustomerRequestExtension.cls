public with sharing class CustomerRequestExtension{
	private Id parentId = ApexPages.currentPage().getParameters().get('id');
	private Id opptyId = ApexPages.currentPage().getParameters().get('oid');
	public string opptyname { get; set; }
	private Account acct;
	private Opportunity oppty;
	public String requestType { get; set; }
	public String selectedOppty { get; set; }
	public String selectedStatus { get; set; }
	private Boolean opptyNotNull;
	private Boolean typeNotNull;
	private Boolean statusNotNull;
	public string opptycrumb { get; set; }
	
	public CustomerRequestExtension(ApexPages.StandardController controller) {
		this.isAscending = false;
		this.sortField = 'Name';
		opptyNotNull = false;
		typeNotNull = false;
		statusNotNull = false;
		opptycrumb = '';
		if(opptyId != null){
			opptyname = ApexPages.currentPage().getParameters().get('oname');
			opptycrumb = opptyId;
		}		 	
	}
	    
	public List<PS_Customer_Request__c> getCRs(){		
		List<PS_Customer_Request__c> lstCRs;
		string sortingOrder = ' DESC';
		if(isAscending == false){
			sortingOrder = ' ASC';
		}    
		if(parentId.getSobjectType() == Account.SObjectType){		
			if(requestType != null && requestType != 'nullvalue')
				typeNotNull = true;
			else
				typeNotNull = false;
			if(selectedStatus != null && selectedStatus != 'nullvalue')
				statusNotNull = true;
			else
				statusNotNull = false;
			if(selectedOppty != null && selectedOppty == 'all')
				opptyNotNull = false;
			else
				if(selectedOppty != null && selectedOppty != 'nullvalue')
				opptyNotNull = true;
			else
				selectedOppty = null;
			if(opptyId != null){
				selectedOppty = opptyid;
				opptyId = null;
				opptyNotNull = true;
			}
				
			String query = 'Select id, Type__c, Status__c, OwnerId, Owner.Name, CreatedDate, Customer_Requested_Date__c, Name, Product__r.ProductCode, Opportunity__c from PS_Customer_Request__c where Account__c = :parentId';
			if(opptyNotNull && typeNotNull && statusNotNull)
				query += ' and Opportunity__c = :selectedOppty and Type__c = :requestType and Status__c = :selectedStatus';
			else if(opptyNotNull && typeNotNull)
				query += ' and Opportunity__c = :selectedOppty and Type__c = :requestType';
			else if(opptyNotNull && statusNotNull)
				query += ' and Opportunity__c = :selectedOppty and Status__c = :selectedStatus';
			else if(typeNotNull && statusNotNull)
				query += ' and Type__c = :requestType and Status__c = :selectedStatus';
			else if(opptyNotNull)
				query += ' and Opportunity__c = :selectedOppty';
			else if(typeNotNull)
				query += ' and Type__c = :requestType';
			else if(statusNotNull)
				query += ' and Status__c = :selectedStatus';
				
			query += ' ORDER BY ' + this.sortField + sortingOrder;			
			return Database.query(query);
		}		
		else{
			String query = 'Select id, OpptyLineItemID__c, Type__c, RecordType.Name, Status__c, OwnerId, Owner.Name, CreatedDate, Customer_Requested_Date__c, Name from PS_Customer_Request__c where OpptyLineItemID__c = :parentId ORDER BY ' + this.sortField + sortingOrder;
			return Database.query(query);
		}
	}
	
	public List<SelectOption> getStati(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('nullvalue', ''));
		Schema.DescribeFieldResult F = PS_Customer_Request__c.Status__c.getDescribe();
		for(Schema.PicklistEntry pl :F.getPicklistValues()){
			options.add(new SelectOption(pl.getValue(), pl.getValue()));
		}
		return options;
	}

	public List<SelectOption> getOpptys(){
		List < Opportunity > lstOppty = new List<Opportunity>([select Name from Opportunity where AccountId = :parentId]);
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('nullvalue', ''));
		options.add(new SelectOption('all', 'All Opportunities'));
		for(Opportunity o :lstOppty){
			options.add(new SelectOption(o.Id, o.Name));
		}
		return options;
	}
		
	public List<SelectOption> getItems() {
		List<String> lstValues = new List<String>();		
		for(CRSettings__c s :CRSettings__c.getall().values()){
			if(parentId.getSobjectType() == Account.SObjectType){
				if(s.Account__c == true)
					lstValues.add(s.Name);
			}
			else if(parentId.getSobjectType() == OpportunityLineItem.SObjectType || parentId.getSobjectType() == Opportunity.SObjectType){
				if(s.Opportunity_Product__c == true)
					lstValues.add(s.Name);
			}
			lstValues.sort();		
		}
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('nullvalue', ''));
		for(String lv :lstValues){
			options.add(new SelectOption(lv, lv));
		}
		return options;
	} 	
	//----------------Sorting variables---------------------//
	private String previousSortField = 'Name';
  
	public string sortField {
		get;
		set {
		this.previousSortField = sortField;
		this.sortField = value;
		setAscendingStatus();
		}
	} 
  
	private void setAscendingStatus() {
		if(previousSortField == sortField) {
			isAscending = !isAscending;
			return;
		}
		this.isAscending = true;  
	}
  
	public Boolean isAscending {get;set;}
  
	public PageReference doSort() {
		getCRs();
		return null;
	}  
}