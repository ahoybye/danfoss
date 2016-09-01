public with sharing class CustomerRequestRedirectController{
    
    Id parentId = ApexPages.currentPage().getParameters().get('id');
    String rectype = ApexPages.currentPage().getParameters().get('type');
    String isClone = ApexPages.currentPage().getParameters().get('clone');
	Id CRrecTypeId;
    PS_Customer_Request__c currentCR;
	String requesttype;
	PS_Customer_Request__c c;
    
    public CustomerRequestRedirectController (){
        CRrecTypeId = [select Id from RecordType where SobjectType = 'PS_Customer_Request__c' and DeveloperName = :rectype].Id;
        currentCR = [select Account__c, Opportunity__c, OpptyLineItemID__c, Product__c, Additional_Comments__c, Contact__c, Customer_Requested_Date__c, Drawing_format__c, Type_of_Drawing__c from PS_Customer_Request__c where Id = :parentId];
		requesttype = rectype.replaceAll('_', ' ');
	}
    
    public PageReference createAndRedirect(){
        c = createOrCloneRequest();
		if(requesttype == 'Drawing' && isClone == '1'){
			c.Customer_Requested_Date__c = currentCR.Customer_Requested_Date__c;
			c.Drawing_format__c = currentCR.Drawing_format__c;
			c.Type_of_Drawing__c = currentCR.Type_of_Drawing__c;
			c.Product__c = null;
		}		
        insert c;
        return new PageReference('/'+c.Id+'/e?retURL=%2F'+c.Id);
    }

	private PS_Customer_Request__c createOrCloneRequest(){
		PS_Customer_Request__c cr = new PS_Customer_Request__c(RecordTypeId = CRrecTypeId, Type__c = requesttype);
        cr.Account__c = currentCR.Account__c;
        cr.Opportunity__c = currentCR.Opportunity__c; 
        cr.OpptyLineItemID__c = currentCR.OpptyLineItemID__c;
        cr.Product__c = currentCR.Product__c;
        cr.Contact__c = currentCR.Contact__c;
        cr.Additional_Comments__c = currentCR.Additional_Comments__c;
		return cr;
	}
}