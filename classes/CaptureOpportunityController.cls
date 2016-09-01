/**************************************************************************************
Class 			: CaptureOpportunityController 
Developed by 	: Shailendra Singh(Appirio Offshore)
Created Date 	: 28 Aug 2012
Description		: Force.com Site page to capture Opportunity Information. 
Related Task 	: T-77780
****************************************************************************************/
public without sharing class CaptureOpportunityController {
	
	public Opportunity opportunity{get;set;}
	
	private static final String INTEGRATED_CLOSED_RECORDTYPE = 'Open Opportunities'; 
	
	public CaptureOpportunityController(){
		opportunity = new Opportunity();
		String contactID = Apexpages.currentPage().getParameters().get('contactID');
		String campaignID = Apexpages.currentPage().getParameters().get('campaignID');
		for(Campaign campaign :[Select ID,Name from Campaign Where ID =:campaignID Limit 1]){
			opportunity.Name = campaign.Name;
			opportunity.CampaignId = campaign.ID;
		}
		for(Contact contact : [Select ID,AccountID,Account.Name from Contact Where ID = :contactID Limit 1]){
			opportunity.AccountId = contact.AccountId;
			opportunity.Name = contact.Account.Name + '-'+opportunity.Name;
		}
		// fetch Opportunity Record Type
		Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
		opportunity.RecordTypeId = rtMapByName.get(INTEGRATED_CLOSED_RECORDTYPE).getRecordTypeId(); // Set opportunity Record Type
	}
	
	public Pagereference save(){
		
		// HardCode required fields for prototype
		opportunity.Type = 'Existing Business';
		opportunity.Production_Start_Date__c = System.today().addDays(90);
		opportunity.CloseDate = System.today();
		opportunity.StageName = 'Evaluating Need';
		opportunity.CurrencyIsoCode = 'USD';
		
		insert opportunity;
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Information has been captured.Thank you!'));
		return null;
	}
}