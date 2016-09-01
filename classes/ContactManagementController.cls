/**************************************************************************************
Class 			: ContactManagementController 
Developed by 	: Shailendra Singh(Appirio Offshore)
Created Date 	: 27 Aug 2012
Description		: Inline Visulfoce page(ContactManagement) controller that display links to call approval process. 
Related Task 	: T-77691
****************************************************************************************/
public with sharing class ContactManagementController {
	
	public Boolean canManageContact{get;set;}
	public Contact contact;
	public Boolean portalEnabled{get;set;}
	
	private String CSR_PROFILE_NAME = 'CRM_CSR';
	private String CSR_PROFILE_NAME_COMATROL = 'CRM_CSR COMATROL';
	private String PARTNER_DELEGATED_ADMIN = 'PartnerLink Delegated Admin';
	private String SALES_SPECIALIST = 'CRM_Sales Specialist';
	private String SYSTEM_ADMIN = 'System Administrator';
	
	public ContactManagementController(ApexPages.StandardController controller){
		contact = (Contact)controller.getRecord();
		if(contact != null){
			initialize();
		}
	}
	
	/**
		initialize page
	**/
	private void initialize(){
		Set<ID> authoriseProfiles = new Set<ID>();
		for (Profile profile : [Select ID from Profile Where 
							(Name = :CSR_PROFILE_NAME OR Name =:PARTNER_DELEGATED_ADMIN
							OR name=:SALES_SPECIALIST OR name =:SYSTEM_ADMIN
							OR name =:CSR_PROFILE_NAME_COMATROL)]) {
			authoriseProfiles.add(profile.ID);
		}
		if (authoriseProfiles.contains(UserInfo.getprofileID())) {
			canManageContact = true;
			List<User> userList = [Select ID,IsActive,IsPortalEnabled FROM User Where ContactID != null AND ContactID =:contact.ID AND IsActive = true];
			if(userList.isEmpty()){
				portalEnabled = false;
			}else{
				portalEnabled = true;
			}
		}else{
			canManageContact = false;
		}		
	}
}