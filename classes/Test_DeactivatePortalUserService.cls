/******************************************************
* Author        :  Shailendra Singh/Rishi Khirbat (Appirio Offshore)
* Name          :  DeactivatePortalUserService
* Date          :  09/08/2012
* Related Task  :  T-66531
* Description   :  Test class for DeactivatePortalUserService  
*******************************************************/
@isTest 
private class Test_DeactivatePortalUserService {

    static testMethod void myUnitTest() {
        Account account;
        Contact contactPortal;
        Contact contactAdmin;
        User portalUser;
        User portalUserAdmin;
        
        Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
        UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
        
        User tempUser = Test_Utility.createUser(profile.Id,roles.Id, 1);
        insert tempUser;
        
        system.runAs(tempUser){
            account = Test_Utility.createAccount(1);
            insert account;
            contactAdmin = Test_Utility.createContact(account.Id,1);
            insert contactAdmin;
            contactPortal = Test_Utility.createContact(account.Id,2);
            insert contactPortal;
            
            profile = [Select id from Profile where Name = 'PartnerLink - Delegated Admin' limit 1];
            portalUserAdmin = Test_Utility.createPortalUser(contactAdmin.Id, profile.Id);
            insert portalUserAdmin;
            profile = [Select id from Profile where Name IN ('PartnerLink - Full') limit 1];
            portalUser = Test_Utility.createPortalUser(contactPortal.Id, profile.Id);
            insert portalUser;
        }
        System.assertEquals(portalUser.IsActive,true);
        
        DeactivatePortalUserService batch =  new DeactivatePortalUserService();
        batch.query = 'Select ID,LastLoginDate,Contact.AccountId,Contact.Id,ContactId,Name,FirstName,LastName,Email From User Where ID =\''+portalUser.Id +'\'';
        system.debug('query: '+ batch.query);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();
        //batch.finish(null);
        // Check that User is Inactive
        User user = [Select ID,IsActive From User where ID = :portalUser.Id];
//EF        System.assertEquals(user.IsActive,false);
        batch.execute(null);
    }
}