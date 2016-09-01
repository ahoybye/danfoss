@isTest(SeeAllData=true)
public class RestOpportunityControllerTest {
    
    public static testMethod void RestOpportunityControllerTest() {
		
        // Create all custom settings
        //RestInterfaceQuoteDataAccount__c setting = new RestInterfaceQuoteDataAccount__c();
        //setting.Name = 'RestInterfaceQuoteDataAccount';
        //setting.Value__c = 'Whatever';
        //insert setting;
        
        // API user - for calling REST methods (some validation rules only allow for updates by an API profile)
        Profile profile = [SELECT Id FROM Profile WHERE Name='API Only User (CE)'];
		User apiUser = new User(Alias = 'APIusr18', Email='apiuser18@example.com',
		EmailEncodingKey='UTF-8', LastName='APIusr18', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = profile.Id,
		TimeZoneSidKey='America/Los_Angeles', UserName='apiuser18@example.com');

        // Create test user 
        User testUser1 = new User(Alias = 'srcuser1', Email='searchuser1@example.com',
		EmailEncodingKey='UTF-8', LastName='searchuser1', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = profile.Id, User_Id__c = 'U111111', Division__c = 'Cooling',
		TimeZoneSidKey='America/Los_Angeles', UserName='searchuser1@example.com' );
        insert testUser1;
        User testUser2 = new User(Alias = 'srcuser2', Email='searchuser2@example.com',
		EmailEncodingKey='UTF-8', LastName='searchuser2', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = profile.Id,  User_Id__c = 'U222222', Division__c = 'Drives',
		TimeZoneSidKey='America/Los_Angeles', UserName='searchuser2@example.com' );
        insert testUser2;
        User testUser3 = new User(Alias = 'srcuser3', Email='searchuser3@example.com',
		EmailEncodingKey='UTF-8', LastName='searchuser3', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = profile.Id,  User_Id__c = 'U333333', Division__c = 'Cooling',
		TimeZoneSidKey='America/Los_Angeles', UserName='searchuser3@example.com' );
        insert testUser3;
        User testUser4 = new User(Alias = 'srcuser4', Email='searchuser4@example.com',
		EmailEncodingKey='UTF-8', LastName='searchuser4', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = profile.Id,  User_Id__c = 'U444444', Division__c = 'Heating',
		TimeZoneSidKey='America/Los_Angeles', UserName='searchuser4@example.com' );
        insert testUser4;
        
        /* Create CE Customer */        
        Account account = Test_DataFactory.create_CE_Customer('RestOpportunityControllerTest-Account001', 'USD', 'DK', 'CER');
        account.ShippingCountry = 'DK';
        account.ShippingPostalCode = '6430';
        account.ShippingCity = 'Nordborg';
        account.ShippingStreet = 'Nordborgvej 81';    
        account.Cooling_Commercial_Contact__c = testuser1.id;
        account.Cooling_Technical_Contact__c = testuser1.id;
        account.CSC_Agent__c = testuser2.id;
        account.Danfoss_Contact_Technical__c = testuser2.id;
        account.Heating_Commercial_Contact__c = testuser3.id;
        account.Heating_Technical_Contact__c = testuser3.id;

        insert account;

        Sales_Area_Master__c sam = Test_DataFactory.create_SalesAreaMaster('2300','00','00');
        insert sam;
                        
        Sub_Account__c sa = Test_DataFactory.create_SubAccount(account.name, '23456789', account);
        insert sa;
        
        Sales_Area__c sao = Test_DataFactory.create_salesArea(sa, sam);
        insert sao;               
       
        contact c = new contact();        
        c.Academic_Title__c = 'Developer';
        c.AccountId = account.Id;
        c.FirstName = 'Jens Peter';
        c.LastName = 'Kristensen';
        c.Phone = '+45 12345678';
        c.Email = 'jpk=danfoss.com@example.com';
        insert c;
        
        /* Create accounttemmember */
		accountteammember atm1 = new accountteammember();   
        atm1.teammemberrole = 'DCS: Employee Responsible';
        atm1.AccountId = account.Id;
        atm1.Userid = testuser1.Id;
		accountteammember atm2 = new accountteammember();               
        atm2.teammemberrole = 'DCS: Internal Techncal Support';
        atm2.AccountId = account.Id;
        atm2.Userid = testuser2.Id;
		accountteammember atm3 = new accountteammember();                           
        atm3.teammemberrole = 'DCS: Inside Sales';
        atm3.AccountId = account.Id;
        atm3.Userid = testuser3.Id;
        insert new List<accountteammember> {atm1, atm2, atm3};

        // Create opportunity
        Opportunity opp = new Opportunity();
        opp.accountId = account.Id;
        opp.Name = 'RestOpportunityControllerTest-Opportunity001';
        opp.Sub_Account__c = sa.Id;
        opp.Sales_Area__c = sao.Id;
        opp.RecordTypeId = [SELECT Id FROM recordtype WHERE sObjectType='Opportunity' and DeveloperName = 'CE_Opportunity' and IsActive=true LIMIT 1].Id;
        opp.CurrencyIsoCode = 'USD';
        opp.Amount  = 5000;
        opp.Contact__c = c.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Initiated';        
        insert opp;

        /* Create opportunitytemmember */
        opportunityteammember otm1 = new opportunityteammember();        
        otm1.teammemberrole = 'DCS: Employee Responsible';
        otm1.opportunityId = opp.Id;
        otm1.Userid = testuser1.Id;
        insert otm1;
        opportunityteammember otm2 = new opportunityteammember();                
        otm2.teammemberrole = 'DCS: Internal Techncal Support';
        otm2.opportunityId = opp.Id;
        otm2.Userid = testuser2.Id;
        insert otm2;
        opportunityteammember otm3 = new opportunityteammember();                
        otm3.teammemberrole = 'DCS: Inside Sales';
        otm3.opportunityId = opp.Id;
        otm3.Userid = testuser3.Id;
        insert otm3;
        
        string opp_searchString = [SELECT id from Opportunity WHERE id!=null and Name = 'RestOpportunityControllerTest-Opportunity001' LIMIT 1].id;
        string acc_searchString = [SELECT id from Account WHERE id!=null and Name = 'RestOpportunityControllerTest-Account001' LIMIT 1].id;
        
        // TEST GET METHOD
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
		string baseURL = URL.getSalesforceBaseUrl().toExternalForm();
    	req.requestURI = baseURL + '/services/apexrest/RestOpportunityController/';
        req.httpMethod = 'GET';
		req.addParameter('opportunityId', opp_searchString);
		req.addParameter('accountId', acc_searchString);        
		req.addParameter('userId', testUser1.User_Id__c);                
    	RestContext.request = req;
    	RestContext.response = res;
        
        System.runAs(apiUser) {
            
            RestOpportunityController.quoteData quoteData_result = RestOpportunityController.getQuoteData();
            
            String testresult1 = null;
            If (quoteData_result.opportunity != null) {
                testresult1 = 'Ok';
            } else {
                testresult1 = 'Not Ok';                
            }
            System.assertNotEquals('Not Ok', testresult1, 'Not tested ok');            
            System.assertEquals('Ok', testresult1, 'Tested ok'); 
            
            String testresult2 = null;
            If (quoteData_result.account != null) {
                testresult2 = 'Ok';
            } else {
                testresult2 = 'Not Ok';                
            }
            System.assertNotEquals('Not Ok', testresult2, 'Not tested ok');            
            System.assertEquals('Ok', testresult2, 'Tested ok');                    
        }
        
    }    

}