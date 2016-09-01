/**************************************************************************************
Class           : DisplayAccountTeamController_Test 
Developed by    : Shailendra Singh(Appirio Offshore)
Created Date    : 17/08/2012
Related Task    : T-70975
Description     : Test class for DisplayAccountTeamController
**************************************************************************************/
@isTest
private class Test_DisplayAccountTeamController {

    final static String ACCOUNT_OWNER = 'Account Owner';
    final static String CUSTOMER_SERVICE_REP= 'Customer Service Rep';
    final static String SALES_SPECIALIST = 'Sales Specialist';
    final static String SYSTEM_APPLICATION_ENGINEER = 'Systems & Applications Engineer';
    private static User portalUser;
     
    static testMethod void myUnitTest() {
        createTestData();
        System.runAs(portalUser){
            Test.startTest();
                DisplayAccountTeamController controller = new DisplayAccountTeamController();
            Test.stopTest();
            System.assertEquals(4,controller.teamMembers.size());
        }      
    }
    /**
     * Create Test Data
     */
    private static void createTestData(){
        User dummyUser = [select id, TimeZoneSidKey, LocaleSidKey,EmailEncodingKey, ProfileId, LanguageLocaleKey from User limit 1];
        
        Profile delegatedAdminProfile = [Select Name,Id From Profile p Where Name = 'System Administrator' Limit 1];
        User salesRep = Test_Utility.createUser(delegatedAdminProfile.id, null, 1);
        User custRep = Test_Utility.createUser(delegatedAdminProfile.id, null, 2);        
        List<User> users = new List<User>();
        users.add(salesRep);
        users.add(custRep);
        insert users;
        
        Account acc = Test_Utility.createAccount(1);
        acc.Business_Org__c = 'integrated';
        insert acc;
        
        List<AccountTeamMember> teamList = new List<AccountTeamMember>();
        AccountTeamMember team1 = new AccountTeamMember(accountId = acc.id,TeamMemberRole = SYSTEM_APPLICATION_ENGINEER,
                                  UserId = Userinfo.getUserId());
        AccountTeamMember team2 = new AccountTeamMember(accountId = acc.id,TeamMemberRole = CUSTOMER_SERVICE_REP,
                                  UserId = custRep.id);
        AccountTeamMember team3 = new AccountTeamMember(accountId = acc.id,TeamMemberRole = SALES_SPECIALIST,
                                  UserId = salesRep.id);                                                                
        teamList.add(team1);
        teamList.add(team2);
        teamList.add(team3);
        insert teamList;
        
        Profile portalUserProfile = [Select Name,Id From Profile p Where Name = 'PartnerLink - Delegated Admin' Limit 1];
        
        Contact contact = Test_Utility.createContact(acc.ID, 1);
        contact.AccountId = acc.id;
        contact.Email = 'test@testdomain.com';
        contact.Phone = '+1 (555) 555-1212';
        insert contact;
        portalUser = Test_Utility.createPortalUser(contact.ID, portalUserProfile.id);
        insert portalUser;      
    }
}