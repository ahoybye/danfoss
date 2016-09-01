public with sharing class CustomerRequestNewController{
    
    private Id parentId = ApexPages.currentPage().getParameters().get('id');
    public String requestType { get; set; }
    List<CRSettings__c> lstValues = new List<CRSettings__c>();
	Set<String> setValues = new Set<String>();
	Map<String, String> mapCRSettings = new Map<String, String>();
	Map<String, Id> mapApplications = new Map<String, Id>();
	public Document leadtimes { get; set; }
       
    public CustomerRequestNewController (){
        leadtimes = [select Id from Document where Name = 'Lead times'];
		for(Application__c app :[select Id, Name From Application__c])
			mapApplications.put(app.Name, app.Id);
		for(CRSettings__c s :CRSettings__c.getall().values()){
			mapCRSettings.put(s.Order__c, s.Name);
            if(parentId.getSobjectType() == Account.SObjectType){
                if(s.Account__c){
                    lstValues.add(s);
					setValues.add(s.Name);
				}
            }
            else if(parentId.getSobjectType() == OpportunityLineItem.SObjectType){ 
                if(s.Opportunity_Product__c){
                    lstValues.add(s);
					setValues.add(s.Name);
				}
            }   
        }
	}
    
    public List<SelectOption> getItems() {        
		List<SelectOption> options = new List<SelectOption>();
        for(CRSettings__c lv :lstValues){
            options.add(new SelectOption(lv.Order__c, lv.Name));
        }
		options.sort(); 
        return options;
    } 
    
	public List<RecordType> getlstRecordTypes(){
		List<RecordType> lstRecordTypes = new List<RecordType>();
		for(RecordType rt :[select Name, Description from RecordType where SobjectType = 'PS_Customer_Request__c'])
			if(setValues.contains(rt.Name))
				lstRecordTypes.add(rt);
        return lstRecordTypes;
    }
    
    public PageReference createRequest() {
        Id CRrecTypeId = [select Id from RecordType where SobjectType = 'PS_Customer_Request__c' and Name = :mapCRSettings.get(requestType)].Id;
		PageReference CRURL;
        PS_Customer_Request__c c= new PS_Customer_Request__c(RecordTypeId = CRrecTypeId, Type__c = mapCRSettings.get(requestType));
        if(parentId.getSobjectType() == Account.SObjectType){
            c.Account__c = parentId;	
            if(CRSettings__c.getInstance(mapCRSettings.get(requestType)).Includes_Application__c){
    			Account acct = [select Id, Applications__c from Account where Id = :parentId];
    			if(acct.Applications__c != null){
    				if(acct.Applications__c.contains(','))
    				c.Application__c = mapApplications.get(acct.Applications__c.substringBefore(','));
    				else
    				c.Application__c = mapApplications.get(acct.Applications__c);
    			}
			}
        }
        else{
            OpportunityLineItem oli = [select Id, Product2Id, Product2.Business_Unit__c, OpportunityId, Opportunity.AccountId, Opportunity.Application__c, Customer_Material_Number__c, Customer_Requests__c from OpportunityLineItem where Id = :parentId];
            c.Account__c = oli.Opportunity.AccountId;
            c.Opportunity__c = oli.OpportunityId; 
            c.OpptyLineItemID__c = oli.Id;
            c.Product__c = oli.Product2Id;	
            if(CRSettings__c.getInstance(mapCRSettings.get(requestType)).Includes_Application__c)
			    c.Application__c = oli.Opportunity.Application__c;
			if(mapCRSettings.get(requestType)=='System Model' || mapCRSettings.get(requestType) == 'Special Tests & Certificates')
				c.Primary_BU__c = oli.Product2.Business_Unit__c;
			if(mapCRSettings.get(requestType)=='Drawing' || mapCRSettings.get(requestType) == 'New Material Number' || mapCRSettings.get(requestType) == 'PPAP')
				c.Customer_Material_Number__c = oli.Customer_Material_Number__c;
            if(oli.Customer_Requests__c != true){
                oli.Customer_Requests__c = true;
                update oli;
            }
        }
        insert c;
		CRURL = new PageReference('/'+c.Id+'/e');
		CRURL.getParameters().put('retURL', c.Id);
		CRURL.getParameters().put('cancelURL', 'apex/CustomerRequestCancel?cid='+c.Id+'&pid='+parentId);
		return CRURL;
    }
    
    public PageReference cancelRequest(){       
        return new PageReference('/' + parentId);
    }
}