/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class PortalChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}    
    public Boolean isChanged{get;set;}    
    
    public PageReference changePassword() {
      try{	
      	/*
    	if(!Site.isPasswordExpired() && (oldPassword==null || oldPassword.trim()=='')){
    		apexpages.addmessage( new ApexPages.Message(ApexPages.Severity.ERROR,'Old Password: Validation Error: Value is required.'));
    	}
    	*/
    	if(newPassword == null || newPassword.trim()==''){
    		apexpages.addmessage( new ApexPages.Message(ApexPages.Severity.ERROR,'New Password: Value is required.'));
    	}
    	if(verifyNewPassword == null || verifyNewPassword.trim()==''){
    		apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Verify New Password: Value is required.'));
    	}
    	if(newPassword != verifyNewPassword){
    		apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'New password and Verify New Password must be same.'));
    	}
    	if(apexpages.hasMessages()){
    		return null;
		}
		System.setPassword(Userinfo.getUserId(),verifyNewPassword);
		isChanged = true;
      }catch(Exception ex){
		  if(ex.getMessage() == 'UNKNOWN_EXCEPTION: invalid repeated password')
		  	apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot use any of your 12 previously used PartnerLink passwords.'));
		  else
      		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }
      return null;    
    }     
    
   	public PortalChangePasswordController() {
   		isChanged = false;
   	}
    
    @IsTest public static void testChangePasswordControllerWithoutParameter() {
        PortalChangePasswordController controller = new PortalChangePasswordController();
        //call changePassword method without parameters
        System.assertEquals(controller.changePassword(),null);                           
    }
    
   	@IsTest public static void testChangePasswordController() {
        PortalChangePasswordController controller = new PortalChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';   
        //call changePassword method without parameters             
        System.assertEquals(controller.changePassword(),null);                           
    }    
}