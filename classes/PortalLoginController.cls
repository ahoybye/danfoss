/*********************************************************************
    Author: Appirio Offshore (Ranjeet Singh)
    Date  : Augest 14, 2012 
    Usage : Controller class to Login the portal user from site
*********************************************************************/
public without sharing class PortalLoginController {

    public String loginEmail{get;set;}
    public String loginPassword{get;set;}
    public String errorMsg{get;set;}  
  //Constructor
  public PortalLoginController (){
    errorMsg = '';
    if(apexpages.currentPage().getParameters().get('msg') != null) {
       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,apexpages.currentPage().getParameters().get('msg'));         
       if(myMsg.getDetail() != ''){
          apexpages.addmessage(myMsg);
          errorMsg = myMsg.getDetail();
       } 
    }   
   
  }
  //login with user
public Pagereference login() {
	Pagereference pg;
	errorMsg = '';
	if (loginEmail == null ||loginEmail.trim()== '') {
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, '*Enter UserName');
		apexpages.addmessage(myMsg);
		errorMsg = myMsg.getDetail();
	}
	if (loginPassword == null ||loginPassword.trim()== '') {
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, '*Enter password');
		apexpages.addmessage(myMsg);
		errorMsg = errorMsg != ''?'*Enter UserName and Password ':myMsg.getDetail();
	}
	if (apexpages.hasMessages()) {
		return null;
	}
	else {
		if (Site.getPrefix()== '/MyComatrol') {
			loginEmail = loginEmail + '.mycomatrol';
			pg = Site.login(loginEmail, loginPassword, '/apex/MyComatrolPortalHome');
		}
		else {
			pg = Site.login(loginEmail, loginPassword, '/apex/PartnerPortalHome');
		}
		if (pg == null) {
			loginEmail = loginEmail.replace('.mycomatrol', '');
			errorMsg = '*Please enter valid Username and Password.';
		}
		else pg.setRedirect(true);
		return pg;
	}
}
}