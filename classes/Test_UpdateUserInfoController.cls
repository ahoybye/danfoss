/************************************************************
* Author        : Shailendra Singh (Appirio offshore)
* Name          : UpdateUserInfoController_Test
* Date          : 17/08/2012
* Related Task  : T-70527
* Purpose       : Test class UpdateUserInfoController_Test
*************************************************************/
@isTest
private class Test_UpdateUserInfoController {
    
    /**
     * Test functionality of UpdateUserInfoController
     */
    static testMethod void myUnitTest() {   
        User user = createPortalUser();
        System.runAs(user){
            Test.startTest();
            
            ApexPages.Standardcontroller sc = New ApexPages.StandardController(user); 
            UpdateUserInfoController controller = new UpdateUserInfoController(sc);
            controller.user.Phone = '+1 (555) 555-1212';
            controller.updateUser();
            controller.cancelRequest();
            
            Test.stopTest();
        }
        for (User userObj :[Select ID,Phone,User.Contact.Phone from User where id =: user.ID Limit 1]) {
            user = userObj;
            System.assertEquals(user.Phone,'+1 (555) 555-1212');
            System.assertEquals(user.Contact.Phone,'+1 (555) 555-1212');
        }
    }
    /**
     * Create portal user and return instance of portal user record.
     * @return Instance of User record. 
     */
    private static User createPortalUser(){
        Profile delegatedAdminProfile = [Select Name,Id From Profile p Where Name = 'PartnerLink - Delegated Admin' Limit 1];
        Account acc = Test_Utility.createAccount(1);
        insert acc;
        Contact contact = Test_Utility.createContact(acc.id, 1);
        insert contact;
        User user = Test_Utility.createPortalUser(contact.id, delegatedAdminProfile.id);
        insert user;
        return user;
    }
}