/**
Class : TermAndConditionController 
Description :  This class is used for displaying T&C content from T&C object based on region of that user.
Developed by : Manmeet Manethiya
Created Date : August 30, 2012

Last Modified By   : Shailendra Singh(Appirio Offshore)
Last Modified Date : 31st August 2012
Related Task	   : T-78971
Purpose			   : Display Terms & Conditions from Object based on user Country and Business org.
**/
public without sharing class TermAndConditionController {
	
	public Terms_and_Condition__c termAndCondition{get;set;}
	private User user;
	
	
	public TermAndConditionController(){
		initialize();
	}
	public Boolean hideButtons{get;set;}
	/**
	Update Terms_And_Conditions__c field of curret user with current time and Mark accepted = true
	@return PageReferance of portal home.
	*/	
	public Pagereference acceptConditions(){
			user.Terms_And_Conditions__c =  System.now();
			user.Terms_and_Conditions_Status__c = 'Accepted';
		    update user;
			return Page.PartnerPortalHome;
	}
	/**
	Update Terms_and_Conditions_Status__c = 'Declined' and Terms_And_Conditions__c with current time.
	@return send user on logout page.
	*/
	public Pagereference declineConditions(){
			user.Terms_And_Conditions__c = System.now();
			user.Terms_and_Conditions_Status__c = 'Declined';
			update user;
			return new Pagereference('/secur/logout.jsp');	
	}
	/**
		initialize page
	**/
	public void initialize(){
		Map<String,String> requestParameters = Apexpages.currentPage().getParameters();
		if(requestParameters.get('showonly') != null){
			hideButtons = true;
		}else{
			hideButtons = false;
		}
		user = [select contact.account.country__r.Name,Business_Org__c from User where id = : UserInfo.getUserId() limit 1];
		for(Terms_and_Condition__c tAndC : [select Description__c from Terms_and_Condition__c where Country__c INCLUDES  (:user.contact.account.country__r.Name) AND Business_Org__c = :user.Business_Org__c limit 1]){
			termAndCondition = tAndC;
		}		
	}
}