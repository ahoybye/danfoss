public with sharing class CustomerRequestRedirectController{
	
	private Id parentId = ApexPages.currentPage().getParameters().get('id');
    private String rectype = ApexPages.currentPage().getParameters().get('type');
    private PS_Customer_Request__c currentCR;
	
	public CustomerRequestRedirectController (){}
	
	public PageReference createAndRedirect(){
        Id CRrecTypeId = [select Id from RecordType where SobjectType = 'PS_Customer_Request__c' and DeveloperName = :rectype].Id;
        currentCR = [select Account__c, Opportunity__c, OpptyLineItemID__c, Product__c, Additional_Comments__c, Contact__c from PS_Customer_Request__c where Id = :parentId];
        PS_Customer_Request__c c= new PS_Customer_Request__c(RecordTypeId = CRrecTypeId, Type__c = rectype.replaceAll('_', ' '));
        c.Account__c = currentCR.Account__c;
        c.Opportunity__c = currentCR.Opportunity__c; 
        c.OpptyLineItemID__c = currentCR.OpptyLineItemID__c;
        c.Product__c = currentCR.Product__c;
        c.Contact__c = currentCR.Contact__c;
        c.Additional_Comments__c = currentCR.Additional_Comments__c;
        insert c;
        return new PageReference('/'+c.Id+'/e?retURL=%2F'+c.Id);
    }

}