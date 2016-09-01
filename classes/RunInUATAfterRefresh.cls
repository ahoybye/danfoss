global class RunInUATAfterRefresh implements Database.Batchable<sObject> {
    String query;
    
	global RunInUATAfterRefresh(string whichtable) {
        system.debug('Initializing RunInUATAfterRefresh' + whichtable);
    
        String likequery = '%@example.com%';
        
        if (whichtable.equals('USER')) 
        {
        // Run through all users
            query = 'select Id, email from User';
            
      		//RunInUATAfterRefresh RefreshBatch1 = new RunInUATAfterRefresh('USER');
	        //ID batchprocessid1 = Database.executeBatch(RefreshBatch1,200);            
        }
        
        if (whichtable.equals('CONTACT')) 
        {
            //query = 'select Id, email, department__c, role__c, pib_bu__c, same_address_as_account__c from Contact WHERE email != null';
            query = 'select Id, email, department__c, role__c, pib_bu__c, same_address_as_account__c from Contact WHERE email != null AND (NOT email like ' + String.escapeSingleQuotes(likeQuery) + ')';          
        } 
        
        if (whichtable.equals('ACCOUNT')) 
        {
            String
            //query = 'select Id, email__c from Account WHERE email__c != null';
            query = 'select Id, email__c from Account WHERE email__c != null AND (NOT email__c like ' + String.escapeSingleQuotes(likeQuery) + ')';  
        } 
        
        system.debug('Query RunInUATAfterRefresh' + query); 
    }    
    
   global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
   }
     
   global void execute(Database.BatchableContext BC, List<sObject> sObject_list){ 
        
       String SandboxName;
       if(UserInfo.getUserName().substringAfterLast('.com')!= null) {
           SandboxName = '.' + UserInfo.getUserName().substringAfterLast('.');
       }            
       
       // Check if we are in production or in a sandbox
       Boolean productionOrg;
       String orgId = UserInfo.getOrganizationId();
       If (orgId == '00DC0000000Qm80') {
           productionOrg = True;
           return;
       } else {
           productionOrg = False;                
       }       
       
       // Running through all user
       IF (sObject_list[0].getSObjectType() == New User().getSObjectType()) {    
            system.debug('$$RunInUATAfterRefresh$$User$$');
                        
            List<User> user_list = sObject_list;
            
            for(User user : user_list){
                
                //update user;
            }            
       }

       // Running through all contacts       
       IF (sObject_list[0].getSObjectType() == New Contact().getSObjectType()) {    
            system.debug('$$RunInUATAfterRefresh$$Contact$$');           
           
            List<Contact> contact_list = sObject_list;
            
            for(Contact contact : contact_list){
                
                contact.Email = contact.Email.replace('@','=');
                contact.Email = contact.Email + '@example.com';

                If (contact.Product_Information_Bulletin__c = true && contact.PIB_BU__c == null) {
                    contact.Product_Information_Bulletin__c = false;
                  	//account.PIB_BU__c = 'Corporate';
                }

                
                If (contact.Department__c == null) {
                	contact.Department__c 				= 'Corporate';
                    contact.Role__c 					= 'Manager';
                    contact.PIB_BU__c 					= 'Corporate';
                    contact.Same_Address_as_Account__c 	= FALSE;
                }    
                
                update contact;
                
                system.debug('$$RunInUATAfterRefresh$$Contact-Update$$' + contact.Name);                  
            }            
       }

       // Running through all accounts       
       IF (sObject_list[0].getSObjectType() == New Account().getSObjectType()) {  
            system.debug('$$RunInUATAfterRefresh$$Account$$');           
           
            List<Account> account_list = sObject_list;
            
            for(Account account : account_list){

                account.Email__c = account.Email__c.replace('@','=');
                account.Email__c = account.Email__c + '@example.com';
                
                //If (account.Region__c != null) {
                //  	account.Region__c = '  ';
                //}                

                update account;
                
                system.debug('$$RunInUATAfterRefresh$$Account-Update$$' + account.Name);                  
            }            
       }
       
       
   }
    
   global void finish(Database.BatchableContext BC){
        
   }
}