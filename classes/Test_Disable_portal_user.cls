/**************************************************************************************
Class           : Disable_portal_user_Test 
Developed by    : Shailendra Singh(Appirio Offshore)
Created Date    : 04 Aug 2012
Related Task    : T-67673
Description     : Test class for Disable_portal_user. 
****************************************************************************************/
  @isTest 
 public without sharing class Test_Disable_portal_user {

     static testMethod void testTriggerApproval() {
        Account acc = Test_Utility.createAccount(1);
        insert acc;
        
        Contact contact = Test_Utility.createContact(acc.Id,1);
        insert contact;
        ApexPages.Standardcontroller sc = New ApexPages.StandardController(contact);
        Disable_portal_user controller = new Disable_portal_user(sc);
        controller.triggerApproval();
        System.assertEquals(true,controller.isSubmitted);
        controller = new Disable_portal_user(sc);
        controller.triggerApproval(); // duplicate request
        System.assertEquals(false,controller.isSubmitted);
    }
}