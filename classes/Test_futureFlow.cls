@IsTest
private class Test_futureFlow {

      static testMethod void test() {
           
        Test.startTest();
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
          
          id rt =[select id from recordtype where developername  ='Support_Case'].id;
        id q_id =[select Id, developername from Group where  Type = 'Queue' and developername ='Drives_AS_CER' and Type = 'Queue'].id;
        case ca = new case();
        ca.OwnerId = q_id;
        ca.origin = 'Internal';
		ca.RecordTypeId = rt;
		ca.Requestor_Internal_Users__c =  testUser.id;         
        insert ca;        
        System.assertEquals(true, (ca.OwnerId == q_id) );
    }
    
}