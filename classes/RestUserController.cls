@RestResource(urlMapping='/RestInterfaceUser/*')
global with sharing class RestUserController {
    
    @HttpGet
	global static serviceResult getUser() {
        RestContext.response.addHeader('Content-Type', 'text/plain');
        
        serviceResult result =  new serviceResult();
        String userId = RestContext.request.params.get('UserId');
         try {
             result.user = [SELECT Id, firstname, lastname, title, Division__c, CompanyName, email, country, PostalCode, City, Street, Phone, MobilePhone, Default_Print_Logo__c, LanguageLocaleKey, LocaleSidKey FROM user WHERE User_ID__c=:userId and IsActive=true limit 1]; 
             result.status='OK';
             result.message='';
             
         } catch (exception ex) {
             result.status='ERROR';
             result.message='No active user found (' + UserId + ')';
         }
         
        
        return result;
                 
    }
    
    
    
    global class serviceResult {
        public string status {get; set;}
        public string message {get; set;}
        public string return_url {get; set;}
        public user user {get;set;}
    }
        

}