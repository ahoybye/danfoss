@isTest
public class Test_GetTeamsExtension {
    
    public static testMethod void testAddTeam() {
        Id profileId = [select Id from Profile where UserLicense.LicenseDefinitionKey = 'SFDC' limit 1].Id;
        Id roleId = [select Id from UserRole where PortalType = 'None' limit 1].Id;
        User user1 = Test_Utility.createUser(profileId, roleId, 1);
        User user2 = Test_Utility.createUser(profileId, roleId, 2);
        User user3 = Test_Utility.createUser(profileId, roleId, 3);
        insert new List<User> {user1, user2, user3};
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account account = Test_Utility.createAccount(0);
            account.ShippingPostalCode = '1234';
            account.Country_MainAddress__c = 'XY: Xxyy';
            insert account;
            Team__c team1 = new Team__c(Name = 't1');
            Team__c team2 = new Team__c(Name = 't2');
            Team__c team3 = new Team__c(Name = 't3');
            insert new List<Team__c> {team1, team2, team3};
            Location__c loc1 = new Location__c(Country__c = 'XY', Postal_Code_From__c = '1000', Postal_Code_To__c = '2000', Team__c = team1.Id);
            Location__c loc2 = new Location__c(Country__c = 'XY', Postal_Code_From__c = '2000', Postal_Code_To__c = '3000', Team__c = team2.Id);
            Location__c loc3 = new Location__c(Country__c = 'AB', Postal_Code_From__c = '1000', Postal_Code_To__c = '2000', Team__c = team3.Id);
            insert new List<Location__c> {loc1, loc2, loc3};
            TeamMember__c tm1 = new TeamMember__c(Team__c = team1.Id, User__c = user1.Id);
            TeamMember__c tm2 = new TeamMember__c(Team__c = team2.Id, User__c = user2.Id);
            TeamMember__c tm3 = new TeamMember__c(Team__c = team3.Id, User__c = user3.Id);
            insert new List<TeamMember__c> {tm1, tm2, tm3};
                
            Test.startTest();
            
            GetTeamsExtension c = new GetTeamsExtension(new ApexPages.StandardController(account));
            System.assertEquals(1, c.getTeams().size());
            c.selectedDD = c.getTeams()[0].Id;
            c.AddTeam();
            
            Test.stopTest();
            
            List<AccountTeamMember> teamMembers = [select UserId from AccountTeamMember];
            System.assertEquals(1, teamMembers.size());
            System.assertEquals(user1.Id, teamMembers[0].UserId);
        }
    }
    
    public static testMethod void testAddMe() {
        Id profileId = [select Id from Profile where UserLicense.LicenseDefinitionKey = 'SFDC' limit 1].Id;
        Id roleId = [select Id from UserRole where PortalType = 'None' limit 1].Id;
        User user1 = Test_Utility.createUser(profileId, roleId, 1);
        User user2 = Test_Utility.createUser(profileId, roleId, 2);
        User user3 = Test_Utility.createUser(profileId, roleId, 3);
        insert new List<User> {user1, user2, user3};
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account account = Test_Utility.createAccount(0);
            account.ShippingPostalCode = '1234';
            account.Country_MainAddress__c = 'XY: Xxyy';
            insert account;
            Team__c team1 = new Team__c(Name = 't1');
            Team__c team2 = new Team__c(Name = 't2');
            Team__c team3 = new Team__c(Name = 't3');
            insert new List<Team__c> {team1, team2, team3};
            Location__c loc1 = new Location__c(Country__c = 'XY', Postal_Code_From__c = '1000', Postal_Code_To__c = '2000', Team__c = team1.Id);
            Location__c loc2 = new Location__c(Country__c = 'XY', Postal_Code_From__c = '2000', Postal_Code_To__c = '3000', Team__c = team2.Id);
            Location__c loc3 = new Location__c(Country__c = 'AB', Postal_Code_From__c = '1000', Postal_Code_To__c = '2000', Team__c = team3.Id);
            insert new List<Location__c> {loc1, loc2, loc3};
            TeamMember__c tm1 = new TeamMember__c(Team__c = team1.Id, User__c = user1.Id);
            TeamMember__c tm2 = new TeamMember__c(Team__c = team2.Id, User__c = user2.Id);
            TeamMember__c tm3 = new TeamMember__c(Team__c = team3.Id, User__c = user3.Id);
            insert new List<TeamMember__c> {tm1, tm2, tm3};
                
            Test.startTest();
            
            GetTeamsExtension c = new GetTeamsExtension(new ApexPages.StandardController(account));
            System.assertEquals(1, c.getTeams().size());
            c.selectedDD = c.getTeams()[0].Id;
            
            c.userTeamMember.UserId = UserInfo.getUserId();
            c.userTeamMember.TeamMemberRole = 'PE: Employee Responsible';

            c.addUser();
            
            List<AccountTeamMember> teamMembers = [select UserId from AccountTeamMember];
            System.assertEquals(1, teamMembers.size());
            System.assertEquals(UserInfo.getUserId(), teamMembers[0].UserId);
            teamMembers.clear();
            
            c.removeUser();
            
            Test.stopTest();            
            
            teamMembers = [select UserId from AccountTeamMember];
            System.assertEquals(0, teamMembers.size());
            
        }
    }
   
    public static testMethod void testAddTeamMember() {
        Id profileId = [select Id from Profile where UserLicense.LicenseDefinitionKey = 'SFDC' limit 1].Id;
        Id roleId = [select Id from UserRole where PortalType = 'None' limit 1].Id;
        User user1 = Test_Utility.createUser(profileId, roleId, 1);
        User user2 = Test_Utility.createUser(profileId, roleId, 2);
        User user3 = Test_Utility.createUser(profileId, roleId, 3);
        insert new List<User> {user1, user2, user3};
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account account = Test_Utility.createAccount(0);
            account.ShippingPostalCode = '1234';
            account.Country_MainAddress__c = 'XY: Xxyy';
            insert account;
            Team__c team1 = new Team__c(Name = 't1');
            Team__c team2 = new Team__c(Name = 't2');
            Team__c team3 = new Team__c(Name = 't3');
            insert new List<Team__c> {team1, team2, team3};
            Location__c loc1 = new Location__c(Country__c = 'XY', Postal_Code_From__c = '1000', Postal_Code_To__c = '2000', Team__c = team1.Id);
            Location__c loc2 = new Location__c(Country__c = 'XY', Postal_Code_From__c = '2000', Postal_Code_To__c = '3000', Team__c = team2.Id);
            Location__c loc3 = new Location__c(Country__c = 'AB', Postal_Code_From__c = '1000', Postal_Code_To__c = '2000', Team__c = team3.Id);
            insert new List<Location__c> {loc1, loc2, loc3};
            TeamMember__c tm1 = new TeamMember__c(Team__c = team1.Id, User__c = user1.Id);
            TeamMember__c tm2 = new TeamMember__c(Team__c = team2.Id, User__c = user2.Id);
            TeamMember__c tm3 = new TeamMember__c(Team__c = team3.Id, User__c = user3.Id);
            insert new List<TeamMember__c> {tm1, tm2, tm3};
                
            Test.startTest();
            
            GetTeamsExtension c = new GetTeamsExtension(new ApexPages.StandardController(account));
            System.assertEquals(1, c.getTeams().size());
            c.selectedDD = c.getTeams()[0].Id;

            c.anyUserTeamMember.UserId = UserInfo.getUserId();
            c.anyUserTeamMember.TeamMemberRole = 'PE: Employee Responsible';

            c.addTeamMember();
            
            List<AccountTeamMember> teamMembers = [select Id, UserId from AccountTeamMember];
            System.assertEquals(1, teamMembers.size());
            System.assertEquals(UserInfo.getUserId(), teamMembers[0].UserId);

            c.selectedATMId = teamMembers[0].Id;

            teamMembers.clear();                
                
            c.removeTeamMember();
            
            Test.stopTest();
            
            teamMembers = [select UserId from AccountTeamMember];
            System.assertEquals(0, teamMembers.size());            
        }
    }
   
    
}