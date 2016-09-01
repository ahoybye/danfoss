/**************************************************************************************
Class           : ContactManagementController_Test 
Developed by    : Shailendra Singh(Appirio Offshore)
Created Date    : 17 Aug 2012
Description     : Test class for ContactManagementController 
Related Task    : T-77691
****************************************************************************************/
@isTest
private class Test_ContactManagementController {

    static testMethod void myUnitTest() {
        Profile delegatedAdminProfile = [Select Name,Id From Profile p Where Name = 'PartnerLink - Delegated Admin' Limit 1];
        Account acc = Test_Utility.createAccount(1);
        insert acc;
        Contact contact = Test_Utility.createContact(acc.id, 1);
        insert contact; 
        User user = Test_Utility.createPortalUser(contact.id, delegatedAdminProfile.id,1);
        System.runAs(user){
            Test.startTest();
            
            ApexPages.Standardcontroller sc = New ApexPages.StandardController(contact);
            ContactManagementController controller = new ContactManagementController(sc);
            
            Test.stopTest();
            // varefy that page display links
            System.assert(controller.canManageContact != null);
        }
    }
}