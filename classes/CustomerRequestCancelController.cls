public with sharing class CustomerRequestCancelController{

	private Id parentId = ApexPages.currentPage().getParameters().get('pid');
	private Id CRId = ApexPages.currentPage().getParameters().get('cid');
    private PS_Customer_Request__c currentCR;

	public CustomerRequestCancelController (){}
	
	public PageReference cancelAndRedirect(){
        currentCR = [select Id from PS_Customer_Request__c where Id = :CRId];
		delete currentCR;
        return new PageReference('/'+parentId);
    }
}