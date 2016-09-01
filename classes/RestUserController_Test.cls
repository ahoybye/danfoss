@isTest
public class RestUserController_Test {

    
    public static testMethod void Test_RestUserController() {
        
        // API user - for calling REST methods (some validation rules only allow for updates by an API profile)
        Profile profile = [SELECT Id FROM Profile WHERE Name='API Only User (CE)'];
		User apiUser = new User(Alias = 'APIusr18', Email='apiuser18@example.com',
		EmailEncodingKey='UTF-8', LastName='APIusr18', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = profile.Id,
		TimeZoneSidKey='America/Los_Angeles', UserName='apiuser18@example.com');

        User searchUser = new User(Alias = 'search18', Email='searchuser18@example.com',
		EmailEncodingKey='UTF-8', LastName='APIusr18', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = profile.Id,
		TimeZoneSidKey='America/Los_Angeles', UserName='searchuser18@example.com', User_ID__c='Y99999' );
        insert searchUser;
        string searchString = [SELECT User_ID__c from User WHERE User_ID__c!=null and isActive=true limit 1].User_ID__c;
        
        // TEST GET METHOD
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
		string baseURL = URL.getSalesforceBaseUrl().toExternalForm();
    	req.requestURI = baseURL + '/services/apexrest/RestInterfaceUser/';
        req.httpMethod = 'GET';
		req.addParameter('UserId', searchString);
    	RestContext.request = req;
    	RestContext.response = res;
        
        System.runAs(apiUser) {
            RestUserController.serviceResult a_result = RestUserController.getUser();
            System.assertEquals('OK', a_result.status, a_result.message);
        }
        
        req.params.clear();
        req.addParameter('UserId', 'X99999999999999');
    	RestContext.request = req;
    	RestContext.response = res;
        
        System.runAs(apiUser) {
            RestUserController.serviceResult b_result = RestUserController.getUser();
            System.assertNotEquals('OK', b_result.status, b_result.message);
        }
        
    }    

}