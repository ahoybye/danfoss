@isTest (SeeAllData=true)
private class Test_Content {
    static Account account;
    static Contact contactPortal;
    static User portalUser;
    static User adminUser;
    
    static testMethod void myUnitTest() {
         set<id>accountIds = new set<id>();
         createUsers();
         system.runAs(adminUser) {
            account = Test_Utility.createAccount(1);
            insert account;
            contactPortal = Test_Utility.createContact(account.Id,2);
            User_Type_Department_Match__c ut = User_Type_Department_Match__c.getValues(contactPortal.Department__c);
            contactPortal.Department__c = 'Corporate';
            insert contactPortal;
            List<Profile> portalUserProfiles = [Select id from Profile where Name IN ('PartnerLink - Basic','PartnerLink - Full') limit 1];
            system.assertEquals(portalUserProfiles.size(), 1);
            portalUser = Test_Utility.createPortalUser(contactPortal.Id, portalUserProfiles.get(0).Id, 1);
            insert portalUser;
            account.Manager_Library__c = 'testML1';
            account.User_Library__c = 'testUL1';
            update account;
            contactPortal.Department__c = 'Finance';
            update contactPortal;
            account.Manager_Library__c = 'testML2';
            account.User_Library__c = 'testUL2';
            update account;
            Map<Id,Account> lst = new Map<Id,Account>([Select id, Business_Org__c,Channel__c, SAP_Account_ID__c ,Manager_Library__c,User_Library__c,
                            Country__c, Customer_Segment__c, Price_Schedule__c, 
                            Region__c, Channel_Attributes__c, Name From Account limit 1]);
            accountIds.add(account.Id);
            //ContentUtils.ProcessforAccounts(lst.values(),true, lst); 
            //ContentUtils.ProcessforAccounts(accountIds);
        }
     }
         
     private static void createUsers() {
          Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
          UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
          adminUser = Test_Utility.createUser(profile.Id,roles.Id, 1);
          insert adminUser; 
    }
}