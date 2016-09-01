@isTest
public class Test_SetAsOwner {

     static testMethod void test() {
           
        Test.startTest();
        
        case ca = new case();
        insert ca;
           Profile testProfile = [SELECT Id 
                           FROM profile
                           WHERE Name = 'System Administrator' 
                           LIMIT 1];
          User testUser = new User(LastName = 'test user 1', 
                             Username = 'test.user.1@example.com', 
                             Email = 'test.1@example.com', 
                             Alias = 'testu1', 
                             TimeZoneSidKey = 'GMT', 
                             LocaleSidKey = 'en_GB', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             ProfileId = testProfile.Id, 
                             LanguageLocaleKey = 'en_US');    
         insert testUser;
         
        ApexPages.StandardController controller = new ApexPages.StandardController(ca);
        SetAsOwner c = new SetAsOwner(controller);
        c.Caseid = ca.id;
        c.Userid =  testUser.id;
        c.gotoCase(); 
        Test.stopTest();
        system.debug('ca.ownerid' + ca.id);
        id caseownerid = [select ownerid from case where id=:ca.id].ownerid; 
        System.assertNotEquals(null, caseownerid);
    }
    
    
    
}