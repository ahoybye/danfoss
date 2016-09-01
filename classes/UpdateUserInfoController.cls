/**
 * Author		: Shailendra Singh (Appirio offshore)
 * Name			: UpdateUserInfoController
 * Date			: 17/08/2012
 * Related Task	: T-70527
 * Purpose		: Give portal user ability to update their personal info	
 */
 public with sharing class UpdateUserInfoController {

	public User user{get;set;}
	
	private static String SUCCESS_MESSAGE = 'Your changes has been saved!.' ;
	
	/**
	 * Initializes a newly created object to display user Information on UpdateUserInfo page.
	 */
	public UpdateUserInfoController(ApexPages.StandardController controller){
		user = (User) controller.getRecord();
		/*Receive Salesforce CRM Content Email Alerts - checkbox & 
		 'Receive Salesforce CRM Content Alerts as Daily Digest' are displayed 
		  checked if uncheckd and uncheckd if checked so toggle values.  
		*/
		toggleUserContentPreference();
	}
	/**
	 * Update User Records 
	 * @return Pagereference no navigation
	 */
	public Pagereference updateUser(){
	  try{
		toggleUserContentPreference();
		update user;
		toggleUserContentPreference();
		// Copy Values to contact as well
		if (user.ContactId != null) {
			Contact contact = new Contact(ID = user.ContactId, Fax = user.Fax, Phone = user.Phone, MobilePhone = user.MobilePhone);
			Contact.Title = user.Title;
			update contact;
		}
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,SUCCESS_MESSAGE));
	  }catch(DMLException ex){
	  	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getDmlMessage(0)));	
	  }
	  return null;
	}
	/**
	 * @return Pagereference navigate to home page.
	 */
	public Pagereference cancelRequest(){
		return new Pagereference('/');
	}
	
	/**
	 * Toggle Receive Salesforce CRM Content Email Alerts and Receive Salesforce CRM Content Alerts as Daily Digest
	 * Values
	 */
	private void toggleUserContentPreference(){
		user.UserPreferencesContentNoEmail = !user.UserPreferencesContentNoEmail;
		user.UserPreferencesContentEmailAsAndWhen = !user.UserPreferencesContentEmailAsAndWhen;		
	}
}