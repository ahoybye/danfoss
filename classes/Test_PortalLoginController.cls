/*******************************************************************
* Author        :  Harshit Jain(Appirio Offshore)
* Name          :  PortalLoginController_Test
* Date                  :    August 27,2012
* Related Task  :  T-77514
* Description   :  Verify functinality of PortalLoginController class                 
*******************************************************************/
@isTest
private class Test_PortalLoginController {
    
        //verify functionality when error come through URL
    static TestMethod void myTestWithParmenter() {
        Test.startTest();
        PageReference pageRef = Page.PortalLogin;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('msg', 'test Message....');
        // Instantiate a new controller with all parameters in the page
        PortalLoginController controller = new PortalLoginController();
        system.assert(controller.errorMsg != '');      
      Test.stopTest(); 
    }
  
        //verify login Functionality with all parameters 
    static TestMethod void myTestWithoutParmenter() {
        Test.startTest();
        PageReference pageRef = Page.PortalLogin;
        Test.setCurrentPageReference(pageRef);
        PortalLoginController controller1 = new PortalLoginController();
        //call login method with all parameters
        controller1.loginEmail = 'test@gmail.com';
        controller1.loginPassword = 'test1234';
            PageReference pg1 = controller1.login();
            System.assertEquals(controller1.errorMsg, '*Please enter valid Username and Password.');
            
            
        PortalLoginController controller = new PortalLoginController();
        //call login method without parameters 
        PageReference pg = controller.login();
        system.assertEquals(controller.errorMsg, '*Enter UserName and Password ');      
        Test.stopTest();
  }
}