/******************************************************
* Author        :  Harshit Jain(Appirio)
* Name          :  OpportunityManagement_Test
* Date          :  27/08/2012
* Related Task  :  T-77514
* Description   :  verify the functionality of PortalForgotPasswordController class
*******************************************************/
@isTest
private class Test_PortalForgotPasswordController {

    static testMethod void testWithoutUserName() {
        PortalForgotPasswordController controller = new PortalForgotPasswordController();
        controller.username = '';
            //call forgotPassword method without userName       
        System.assertEquals(controller.forgotPassword(), null); 
    }
    
    static testMethod void testWithUserName() {
        PortalForgotPasswordController controller = new PortalForgotPasswordController();
        controller.username = 'testUser@gmail.com';
        //call forgotPassword method without userName   
        System.assertEquals(controller.forgotPassword(), null);
    }
}