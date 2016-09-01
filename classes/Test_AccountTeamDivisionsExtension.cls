/**
 * @author Jesper Kristensen, Capgemini Sogeti, december 2014
 */
@isTest
public class Test_AccountTeamDivisionsExtension {
    
    public static testMethod void testAccountTeamDivisions() {
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
            
            AccountTeamMember t1 = new AccountTeamMember(AccountId = account.Id, UserId = u1.Id);
            AccountTeamMember t2 = new AccountTeamMember(AccountId = account.Id, UserId = u2.Id);
            insert new List<AccountTeamMember> {t1, t2};
            
            Test.startTest();
            
            AccountTeamDivisionsExtension c = new AccountTeamDivisionsExtension(new ApexPages.StandardController(account));
            
            Test.stopTest();
            
            System.assertEquals('aa, bb', c.udivs);
        }
    }
    
}