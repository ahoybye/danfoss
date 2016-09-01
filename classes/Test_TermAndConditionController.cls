/**
Class           : TermAndConditionController_Test 
Developed by    : Shailendra Singh(Appirio Offshore)
Created Date    : 01 Sept 2012
Description     : Test class for TermAndConditionController 
Related Task    : T-78971
**/
@isTest
private class Test_TermAndConditionController {

    static testMethod void myUnitTest() {
        User user = createTestUser();
        Terms_and_Condition__c conditions = Test_Utility.createTermsAndCondition('USA', 'Integrated');
        insert conditions;
        System.runAs(user){
            Test.startTest();
                TermAndConditionController controller = new TermAndConditionController();
                controller.acceptConditions();
                user = [Select ID,Terms_And_Conditions__c,Terms_and_Conditions_Status__c from User Where ID =:user.id];
                System.assertEquals(user.Terms_and_Conditions_Status__c,'Accepted');
                // declined Cse
                controller.declineConditions();
                user = [Select ID,Terms_And_Conditions__c,Terms_and_Conditions_Status__c from User Where ID =:user.id];
                System.assertEquals(user.Terms_and_Conditions_Status__c,'Declined');
            Test.stopTest();            
        }
    }
    /*
    create portal user and return instance of new portal user.
    @return portal user instance
    */
    private static User createTestUser(){
        Profile portlProfile = [Select ID from Profile Where Name = 'PartnerLink - Delegated Admin' limit 1];
        Region__c region = Test_Utility.createRegion();
        insert region;
        Account account = Test_Utility.createAccount(1);
        account.Country__c = region.Id;
        insert account;
        Contact contact = Test_Utility.createContact(account.id,1);
        insert contact;
        User user = Test_Utility.createPortalUser(contact.id,portlProfile.ID);
        user.Business_Org__c = 'Integrated';
        insert user;
        return user;        
    }    
}