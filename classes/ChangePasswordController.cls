/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}     
    public Boolean isChanged{get;set;}           
    
    public PageReference changePassword() {
		try{
	        return Site.changePassword(newPassword, verifyNewPassword, oldPassword);  			
			isChanged = true;
        }
		catch(Exception ex){
      		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      	}
      	return null;    
    }     
    
   	public ChangePasswordController() {
   		isChanged = false;
	}
    
   	@IsTest(SeeAllData=true) public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }    
}