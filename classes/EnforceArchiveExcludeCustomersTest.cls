@isTest
private class EnforceArchiveExcludeCustomersTest
{
    static testMethod void runAsNormal()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='ServiceDesk Client'];
        User u = new User(Alias = 'newUser', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='EnforceArchiveExcludeCustomers@testorg.com');

        System.runAs(u)
        {
            //try
            //{
            //    CollaborationGroup newGroup = new CollaborationGroup
            //    (
            //        IsAutoArchiveDisabled = true
            //    );
            //    insert newGroup;
            //}
            //catch(Exception e)
            //{
             //   Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot disable auto archiving') ? true : false;
             //   System.AssertEquals(expectedExceptionThrown, true);
            //}
            
            try
            {
                CollaborationGroup newGroup = new CollaborationGroup
                (
                    CanHaveGuests = true
                );
                insert newGroup;
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('You do not have sufficient permission to create a Chatter group that includes external customers, please contact an Administrator') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            
            try
            {
                CollaborationGroup newGroup = new CollaborationGroup
                (
                    CanHaveGuests = true,
                    IsAutoArchiveDisabled = true
                );
                insert newGroup;
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  
                    e.getMessage().contains('You cannot disable auto archiving. You do not have sufficient permission to create a Chatter group that includes external customers, please contact an Administrator') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }       
    }
    
    static testMethod void runAsAdmin()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User u = new User(Alias = 'newUser', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='EnforceArchiveExcludeCustomers@testorg.com');

        System.runAs(u)
        {           
            CollaborationGroup newGroup = new CollaborationGroup
            (
                Name = 'Test_EnforceArchiveExcludeCustomersGroup',
                CollaborationType = 'Private',
                CanHaveGuests = true,
                IsAutoArchiveDisabled = true
            );
            insert newGroup;
        }       
    }
}