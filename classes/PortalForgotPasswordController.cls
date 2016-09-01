/*********************************************************************
    Author: Appirio Offshore (Ranjeet Singh)
    Date  : Augest 14, 2012 
    Usage : Controller class to PortalForgotPassword.page the portal user from site
*********************************************************************/
public with sharing class PortalForgotPasswordController {
    public String username {get; set;}   
       
    public PortalForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
  		if(username==null || username.trim()==''){
  			apexpages.addmessage( new ApexPages.Message(ApexPages.Severity.ERROR,'Username validation Error: Value is required.'));
  			return null;  			
  		}
  		PageReference pr = Page.CommunitiesForgotPasswordConfirm;
  		if (Site.getPrefix() == '/MyComatrol') {
  	 		username = username + '.mycomatrol';
			pr = Page.MyComatrolPortalForgotPasswordConfirm;
  		}
  		boolean success = Site.forgotPassword(username);
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null;
  	}
  	
}