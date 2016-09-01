/**
 * @author Jesper Kristensen, Capgemini Sogeti, december 2014
 */
@isTest
public class Test_ContactTeamDivisionsExtension {
    
    public static testMethod void testContactTeamDivisions() {
        Id profileId = [select Id from Profile where UserLicense.LicenseDefinitionKey = 'SFDC' limit 1].Id;
        Id roleId = [select Id from UserRole where PortalType = 'None' limit 1].Id;
        User u1 = Test_Utility.createUser(profileId, roleId, 1);
        u1.Division__c = 'aa';
        User u2 = Test_Utility.createUser(profileId, roleId, 2);
        u2.Division__c = 'bb';
        insert new List<User> {u1, u2};
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account account = Test_Utility.createAccount(0);
            insert account;
            Contact contact = Test_Utility.createContact(account.Id, 0);
            insert contact;
            
            Contact_Team__c t1 = new Contact_Team__c(Contact__c = contact.Id, User__c = u1.Id);
            Contact_Team__c t2 = new Contact_Team__c(Contact__c = contact.Id, User__c = u2.Id);
            insert new List<Contact_Team__c> {t1, t2};
            
            Test.startTest();
            
            ContactTeamDivisionsExtension c = new ContactTeamDivisionsExtension(new ApexPages.StandardController(contact));
            
            Test.stopTest();
            
            System.assertEquals('aa, bb', c.udivs);
        }
    }
    
}