/*
*ClassName    :TestDisplayDocumentCon
*Author Name  :Harshit Jain(Appirio Offshore)
*CreatedDate  :26,July 2012
*Description  :Verify the following functionality (Send email notification to Portal Admin & Account Owner when portal user record is set to inactive). 
*/
@isTest
private class Test_UserTrigger {

    static testMethod void myUnitTest() {
        UserRole role = new UserRole(name = 'SFDC_Platform Administrator');
        insert role;
        Profile p = [select id from profile where name = 'Standard User'];
        User user = new User(alias = 'testUs', email = 'testUser@testorg.com', 
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', 
            localesidkey = 'en_US', profileid = p.Id, IsActive = true, 
            timezonesidkey = 'America/Los_Angeles', username = 'testUser@testorg.com_unitTest', UserRoleId = role.Id, Business_Org__c = 'Integrated');
        insert user;
        Group grp =[Select g.Id From Group g where Name = '*Danfoss Power Solutions'];
        //Assign user to intergrated group
        GroupMember groupMember = new GroupMember(UserOrGroupId = user.Id, GroupId = grp.Id);
        insert groupMember;
        system.runAs(user) {
            PartnerAdminInfo__c adminInfo = new PartnerAdminInfo__c(Name = 'Email', Email__c = 'p@p.com');
            insert adminInfo; 
            //Create account data
            Account accT = new Account(Name = 'Test Account', Channel__c = 'Distributor', Business_Org__c = 'Comatrol', Channel_Attributes__c = 'Partial Line');
            insert accT; 
            //Create contact data
            List<Contact> lstContacts = new List<Contact>();
            Contact conA = new Contact(FirstName = 'Test', LastName = 'contactA', Email = 'A@test.com', AccountID = accT.Id);
            lstContacts.add(conA);
            Contact conP = new Contact(FirstName = 'Test', LastName = 'contactP', Email = 'P@test.com', AccountID = accT.Id);
            lstContacts.add(conP);
            Contact conE = new Contact(FirstName = 'Test', LastName = 'contactE', Email = 'E@test.com', AccountID = accT.Id);
            lstContacts.add(conE);
            Contact conC = new Contact(FirstName = 'Test', LastName = 'contactC', Email = 'C@test.com', AccountID = accT.Id);
            lstContacts.add(conC);
            if(!lstContacts.isEmpty())
                insert lstContacts;
            //get portal profile information 
            Profile profile = [select id from profile where name = 'PartnerLink - Full'];
            //Create partner portal user 
            List<User> lstPortalUsers = new List<User>();
            User portalUserA = Test_Utility.createPortalUser(conA.Id, profile.Id, 1);
            portalUserA.Business_Org__c = 'Integrated';
            portalUserA.Region__c = 'PS: Americas';
            lstPortalUsers.add(portalUserA);  
            User portalUserP = Test_Utility.createPortalUser(conP.Id, profile.Id, 2);
            portalUserP.Business_Org__c = 'Integrated';
            portalUserP.Region__c = 'PS: APAC';
            lstPortalUsers.add(portalUserP);  
            User portalUserE = Test_Utility.createPortalUser(conE.Id, profile.Id, 3);
            portalUserE.Business_Org__c = 'Integrated';
            portalUserE.Region__c = 'PS: Europe';
            lstPortalUsers.add(portalUserE);  
            User portalUserC = Test_Utility.createPortalUser(conC.Id, profile.Id, 4);
            portalUserC.Business_Org__c = 'Integrated';
            portalUserC.Region__c = 'PS: China';
            lstPortalUsers.add(portalUserC);  
            if(!lstPortalUsers.isEmpty())
                insert lstPortalUsers;
            //Assign partner portal user to Intergrated group
            GroupMember grpMember = new GroupMember(UserOrGroupId = portalUserA.Id, GroupId = grp.Id);
            insert grpMember;
            //verify type of user(is it portal user or not)
            System.assert([select isPortalEnabled from user where id = :portalUserA.id].isPortalEnabled);
            
            Test.startTest();
            //deactivate the portal user to send email notification
            portalUserA.IsActive = false;
            update portalUserA;
            Test.stopTest();               
        }
    }
}