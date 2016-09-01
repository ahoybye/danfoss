global class UploadUsersFromAD implements Database.Batchable<sObject> {
    String query; 

    Integer countInactive = 0;
    Integer countCreated = 0; 
    Integer countUpdated = 0;    
    
	global UploadUsersFromAD() {
        system.debug('$$UploadUsersFromAD$$START$$');
    
		List<String> fields = new List<String>(UploadUsers__c.SObjectType.getDescribe().fields.getMap().keySet());
		query = 'select ' + String.join(fields, ',') + ' from UploadUsers__c';     
        
		system.debug('$$UploadUsersFromAD$$Query$$'+ query);
        
        //Select Id, UPNValue__c, FederationIdentifier__c, User_ID_c__c, LastName__c, FirstName__c, Phone__c, MobilePhone__c, BMCServiceDesk_Account_Name_c__c, Username__c, Email__c, PersNo_c__c, TimeZoneSidKey__c, LocaleSidKey__c, EmailEncodingKey__c, LanguageLocalKey__c, BusinessOrg__c, Department__c, Manager__c, ManagerLastName__c, ManagerFirstName__c, ManagerEmail__c FROM UploadUsers__c 
        
        //query = 'select Id, email__c, firstname__c, lastname__c from UploadUsers__c';
        
  		//UploadUsersFromAD UserBatch1 = new UploadUsersFromAD('UPLOADUSERS');
  		//UploadUsersFromAD UserBatch1 = new UploadUsersFromAD();
        //ID batchprocessid1 = Database.executeBatch(UserBatch1,200);          
    }    
    
   global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
   }
     
   global void execute(Database.BatchableContext BC, List<sObject> sObject_list){ 
		system.debug('$$UploadUsersFromAD$$execute$$');                   
    
		//DanfossLog__c danfosslog_item = new DanfossLog__c(); 
       
        IF (sObject_list[0].getSObjectType() == New UploadUsers__c().getSObjectType()) {        

            List<UploadUsers__c> user_list = sObject_list;
            
            String SandboxName;
            if(UserInfo.getUserName().substringAfterLast('.com')!= null) {
               	SandboxName = '.' + UserInfo.getUserName().substringAfterLast('.');
			}            
            
            // Check if we are in production or in a sandbox
            Boolean productionOrg;
            String orgId = UserInfo.getOrganizationId();
            If (orgId == '00DC0000000Qm80MAC') {
                productionOrg = True;
            } else {
                productionOrg = False;                
            }
            
			//Organization org = [select id,IsSandbox from Organization];
            //If org.IsSandbox = True {
            //}
            
            String adminRoleId = '00EC0000001LM0W';
            String apiOnlyProfile = '00eC000000192RM';
            
            //Integer countInactive = 0;
            //Integer countCreated = 0; 
            //Integer countUpdated = 0;
            
            Boolean errorWhenSave = false;
            
            User upload_user 				= new User();
            User manager 	 				= new User();
            Account RemedyAccount 			= new Account();
            PermissionSetAssignment permset	= new PermissionSetAssignment();
            
            for(UploadUsers__c usr : user_list){
				errorWhenSave = false;
                
                upload_user.clear();
                manager.clear();
                RemedyAccount.clear();
                permset.clear();
                
                IF (usr.Email__c != null && usr.Email__c != '' && usr.Email__c != '0') {
                    upload_user = null;
                    
                    // If we are in a sandbox then change the email address to search for
                    IF (productionOrg == False) {
                        usr.Email__c = usr.Email__c.replace('@','=');
                        usr.Email__c = usr.Email__c + '@example.com';
                        
                        usr.UserName__c = usr.UserName__c + SandboxName;
                        
                        system.debug('$$UploadUsersFromAD$$Email&UserNameChanged$$'+ usr.Email__c + '*' + usr.UserName__c);                      
                    }
                    
                    // First check if this person is an admin/apiuser because then he should not be touched at all
                    // First check if hit with a active user and don't change admin's
                    try {
                        //upload_user = Database.query('select id, UserName, Email, User_ID__c, IsActive from user where IsActive = true AND ProfileId !=\'' + apiOnlyProfile + '\' + AND UserRoleId !=\'' + adminRoleId +
                        //upload_user = Database.query('select id, UserName, Email, User_ID__c, IsActive, ProfileId, UserRoleId from user where IsActive = true AND (username=\'' + usr.Email__c + '\' OR email =\'' + usr.Email__c + '\' OR User_ID__c =\'' + usr.User_ID__c + '\' OR FederationIdentifier =\'' + usr.User_ID__c + '\') ORDER BY LastLoginDate DESC LIMIT 1');
                        upload_user = Database.query('select id, UserName, Email, User_ID__c, IsActive from user where IsActive = true AND ProfileId !=\'' + apiOnlyProfile + '\' AND UserRoleId !=\'' + adminRoleId +
                                                     '\' AND (username=\'' + usr.Email__c + '\' OR email =\'' + usr.Email__c + '\' OR User_ID__c =\'' + usr.User_ID__c + '\') ORDER BY LastLoginDate DESC LIMIT 1');                        
                    } catch (Exception e) {   
                        upload_user = new User();
                    }                    
                    
                    IF (upload_user.Id == null) {
                        try {
                        	upload_user = Database.query('select id, UserName, Email, User_ID__c, IsActive from user where ProfileId !=\'' + apiOnlyProfile + '\' AND UserRoleId !=\'' + adminRoleId +
                                                         '\' AND (username=\'' + usr.Email__c + '\' OR email =\'' + usr.Email__c + '\' OR User_ID__c =\'' + usr.User_ID__c + '\') ORDER BY LastLoginDate DESC LIMIT 1');                             
                            
                            //upload_user = Database.query('select id, UserName, Email, User_ID__c, IsActive from user where ProfileId !=\'' + apiOnlyProfile + '\' + AND UserRoleId !=\'' + adminRoleId + '\' AND (username=\'' + usr.Email__c + '\' OR email =\'' + usr.Email__c + '\' OR User_ID__c =\'' + usr.User_ID__c + '\') ORDER BY LastLoginDate DESC LIMIT 1');                            
                            // '\' AND (username=\'' + usr.Email__c + '\' OR email =\'' + usr.Email__c + '\' OR User_ID__c =\'' + usr.User_ID__c + '\') ORDER BY LastLoginDate DESC LIMIT 1');
                        } catch (Exception e) {   
                            upload_user = new User();
                        }                    
                    }
                    
                    // Inactivate a user                     
                    IF (usr.Extension__c == 'Rem' || usr.Extension__c == 'Del' || usr.Extension__c == 'Withdrawn') {
						IF (upload_user.Id != null && upload_user.IsActive) {                        
                            upload_user.IsActive = False;

                            try {
                            	update upload_user;
                            } catch (Exception e) {
                            	System.debug('Error when updating: ' + e.getMessage());
                                
                                errorWhenSave = true;
                            } 
                            
                            If (!errorWhenSave) {                       
	                            system.debug('$$UploadUsersFromAD$$UserUpdated$$ User has been inactivated : '+ upload_user.Id + '*' + upload_user.UserName);  
                            
     	                        countInactive = countInactive + 1;                            
                            }
                        }
                    } else {
                        // Update user
                        IF (upload_user.Id != null) {
                            system.debug('$$UploadUsersFromAD$$UserUpdated$$'+ upload_user.Id + '*' + upload_user.UserName);  
                            
                            IF (upload_user.UserName != usr.UserName__c) {
                                upload_user.UserName = usr.UserName__c; 
                            }
                            //IF (upload_user.Email != usr.Email__c) {
                            //    upload_user.Email = usr.Email__c; 
                            //}
                            IF (upload_user.User_ID__c != usr.User_ID__c) { 
                                upload_user.User_ID__c = usr.User_ID__c; 
                                upload_user.FederationIdentifier = usr.User_ID__c;
                            }
                            
                            If ((usr.PersNo__c != null) && (usr.PersNo__c != '') && (usr.PersNo__c != '0')) {
                            	upload_user.PersNo__c 		= usr.PersNo__c;
                            }
                            
                            //If ((usr.FirstName__c != null) && (usr.FirstName__c != '') && (usr.FirstName__c != '0')) {                            
                            //	upload_user.FirstName 		= usr.FirstName__c;                    
                            //}
                                
                            //If ((usr.LastName__c != null) && (usr.LastName__c != '') && (usr.LastName__c != '0')) {                                
                            //	upload_user.LastName 		= usr.LastName__c;   
                            //}                            
                                
                            If ((usr.Phone__c != null) && (usr.Phone__c != '') && (usr.Phone__c != '0')) {
                           		upload_user.Phone 			= usr.Phone__c;                   
                            }
                            
                            If ((usr.MobilePhone__c != null) && (usr.MobilePhone__c != '') && (usr.MobilePhone__c != '0')) {
                                upload_user.MobilePhone 	= usr.MobilePhone__c;                    
                            }

                            If ((usr.Fax__c != null) && (usr.Fax__c != '') && (usr.Fax__c != '0')) {
                            	upload_user.Fax 			= usr.Fax__c;       
                            }
                            
                            //If ((usr.StreetAddress__c != null) && (usr.StreetAddress__c != '') && (usr.StreetAddress__c != '0')) {                            
                            //	upload_user.Street	 		= usr.StreetAddress__c;          
                            //}
                            
                            If ((usr.City__c != null) && (usr.City__c != '') && (usr.City__c != '0')) {                                
                            	upload_user.City 			= usr.City__c;                   
                            }
                            
                            If ((usr.PostalCode__c != null) && (usr.PostalCode__c != '') && (usr.PostalCode__c != '0')) {                                
                            	upload_user.Postalcode 		= usr.PostalCode__c;             
                            }
                                
                            If ((usr.Country__c != null) && (usr.Country__c != '') && (usr.Country__c != '0')) {                                
                            	upload_user.Country 		= usr.Country__c;   
                            }                            
                                
                            If ((usr.Department__c != null) && (usr.Department__c != '') && (usr.Department__c != '0')) {                                                            
                            	upload_user.Department 		= usr.Department__c;                
                            }                                                            
                                
                            //If ((usr.Title__c != null) && (usr.Title__c != '') && (usr.Title__c != '0')) {                                                            
                            //	upload_user.Title   		= usr.Title__c;                
                            //}                              
                            
                            If ((usr.BusinessOrg__c != null) && (upload_user.Business_Org__c == null)) {
                            //If (upload_user.Business_Org__c == null) {                                  
                            	upload_user.Business_Org__c	= usr.BusinessOrg__c; 
                            }
                                
                            // Find the id of the RemedyForce account
                            If ((usr.BMCServiceDesk_Account_Name__c != '#N/A') && (usr.BMCServiceDesk_Account_Name__c != null) && (usr.BMCServiceDesk_Account_Name__c != '') && (usr.BMCServiceDesk_Account_Name__c != '0')) {
                                try{
                                    RemedyAccount = Database.query('select id from account where name=\'' + usr.BMCServiceDesk_Account_Name__c + '\'');
                                } catch (Exception e) {
                                    RemedyAccount = new Account();
                                } 
                                
                                IF (RemedyAccount.Id != null) {
                                    upload_user.BMCServiceDesk__Account_ID__c   = RemedyAccount.Id;
                                    upload_user.BMCServiceDesk__Account_Name__c = usr.BMCServiceDesk_Account_Name__c;
                                } 
                            }
                                
                            // Find the id of the manager
                            try{
                            	manager = Database.query('select id from user where (username=\'' + usr.ManagerEmail__c + '\' or email =\'' + usr.ManagerEmail__c + '\' or User_ID__c =\'' + usr.Manager__c + '\' )');
                            } catch (Exception e) {
                                manager = new User();
                            } 
                            
                            IF (manager.Id != null) {
                                upload_user.ManagerId = manager.Id; 
                            }
                            
                            IF (upload_user.IsActive != True) {
                                system.debug('$$UploadUsersFromAD$$UserUpdated$$ User was inactive : '+ upload_user.Id + '*' + usr.FirstName__c + '*' + usr.LastName__c);                         
                                
                                upload_user.IsActive = True; 
                                
                                // Add role / profile (client)
                                upload_user.ProfileId	= '00eC000000192dJ';	
                                upload_user.UserRoleId 	= '00EC00000016tnr';                       
                            } 
                       
                            If (upload_user.UserRoleId == null) {
								upload_user.UserRoleId 	= '00EC00000016tnr';                             
                        	}
                        
                            try {
                            	update upload_user;
                            } catch (Exception e) {
                            	System.debug('Error when updating: ' + e.getMessage());
                                
                                errorWhenSave = true;
                            } 
                            
                            If (!errorWhenSave) {
                            	countUpdated = countUpdated + 1;
                                
                            	system.debug('$$UploadUsersFromAD$$UserUpdated$$ User has been updated : '+ upload_user.Id + '*' + usr.FirstName__c + '*' + usr.LastName__c);                     
                            }
                        } else {
                            // Create user
                            system.debug('$$UploadUsersFromAD$$UserCreated$$'+ usr.FirstName__c + '*' + usr.LastName__c); 
                            
                            upload_user.Email 				= usr.Email__c; 
                            If ((usr.FirstName__c != null) && (usr.FirstName__c != '') && (usr.FirstName__c != '0') && (usr.LastName__c != null) && (usr.LastName__c != '') && (usr.LastName__c != '0')) { 
                                IF ((usr.FirstName__c.Length() > 1) && (usr.LastName__c.Length() > 1)) {
	                                upload_user.CommunityNickname	= usr.FirstName__c.substring(0,2) + usr.LastName__c.substring(0,2);
    	                            upload_user.Alias 				= usr.FirstName__c.substring(0,2) + usr.LastName__c.substring(0,2);   
                                }
                            }
                            upload_user.User_ID__c			= usr.User_ID__c;
                            upload_user.FederationIdentifier = usr.User_ID__c;
                            upload_user.PersNo__c 			= usr.PersNo__c;
                            upload_user.FirstName 			= usr.FirstName__c;                    
                            upload_user.LastName 			= usr.LastName__c;                    
                            upload_user.Phone 				= usr.Phone__c;                   
                            upload_user.MobilePhone 		= usr.MobilePhone__c;                    
                            upload_user.UserName			= usr.UserName__c;                    
                            upload_user.Department 			= usr.Department__c;                
                            upload_user.Business_Org__c		= usr.BusinessOrg__c; 
                            upload_user.Fax 				= usr.Fax__c;       
                            upload_user.Street	 			= usr.StreetAddress__c;                    
                            upload_user.City 				= usr.City__c;                   
                            upload_user.Postalcode 			= usr.PostalCode__c;                    
                            upload_user.Country 			= usr.Country__c;   
							upload_user.Title   			= usr.Title__c;    
                            
                            upload_user.LanguageLocaleKey		= 'en_US';	
                            upload_user.TimeZoneSidKey			= 'Europe/Amsterdam';
                            upload_user.LocaleSidKey			= 'da_DK';
                            upload_user.EmailEncodingKey		= 'ISO-8859-1';
                            upload_user.DefaultCurrencyIsoCode 	= 'EUR';
                            
                            // Find the id of the RemedyForce account
                            try{
                                RemedyAccount = Database.query('select id from account where name=\'' + usr.BMCServiceDesk_Account_Name__c + '\'');
                            } catch (Exception e) {
                                RemedyAccount = new Account();
                            } 
                            IF (RemedyAccount.Id != null) {
                                upload_user.BMCServiceDesk__Account_ID__c   = RemedyAccount.Id;
                                upload_user.BMCServiceDesk__Account_Name__c = usr.BMCServiceDesk_Account_Name__c;
                            } 
                            
                            // Find the id of the manager
                            try{
                            manager = Database.query('select id from user where (username=\'' + usr.ManagerEmail__c + '\' or email =\'' + usr.ManagerEmail__c + '\' or User_ID__c =\'' + usr.Manager__c + '\' )');
                            } catch (Exception e) {
                            	Manager = new User();
                            }                     
                            
                            IF (manager.Id != null) {
                                upload_user.ManagerId = manager.Id; 
                            }
                            
                            // Add role / profile
                            upload_user.ProfileId	= '00eC000000192dJ';	
                            upload_user.UserRoleId 	= '00EC00000016tnr';
                            //upload_user.BMCServiceDesk__User_License__c = 'Salesforce Platform';
                            
                            try{
	                            insert upload_user;
                            } catch (Exception e) {
                            	System.debug('Error when inserting: ' + e.getMessage());
                                
								errorWhenSave = true;                                      
                            } 

                            If (!errorWhenSave) {                            
                            	system.debug('$$UploadUsersFromAD$$UserCreated$$ User has been created : ' + upload_user.Id + '*' + usr.FirstName__c + '*' + usr.LastName__c);                     

                                countCreated = countCreated + 1;
                            }   
                                
                            // Add permissionsets 
                            IF (upload_user.Id != null) { 
 	                            permset.AssigneeId 			= upload_user.Id;
	   	                        permset.PermissionSetId 	= '0PSC0000000X1aJ';
        	                    insert permset;
                            }
                            
                            //upload_user.BMCServiceDesk__User_License__c = 'Salesforce Platform';
                        }
                    }
                }  
            }
            
			//system.debug('$$UploadUsersFromAD$$FinalCountCreate$$ No of users has been created : ' + countCreated);     
			//system.debug('$$UploadUsersFromAD$$FinalCountUpdate$$ No of users has been updated : ' + countUpdated);     
			//system.debug('$$UploadUsersFromAD$$FinalCountInactive$$ No of users has been inactivated : ' + countInactive);     

            //danfosslog_item.clear();
            //danfosslog_item.LogTime__c = System.now();
            //danfosslog_item.Name = 'UploadUsersFromAD';
			//danfosslog_item.LogText__c = '$$UploadUsersFromAD$$FinalCountCreate$$ No of users has been created : ' + countCreated;
            //insert danfosslog_item;
            //danfosslog_item.clear();            
            //danfosslog_item.LogTime__c = System.now();            
            //danfosslog_item.Name = 'UploadUsersFromAD';            
			//danfosslog_item.LogText__c = '$$UploadUsersFromAD$$FinalCountUpdate$$ No of users has been updated : ' + countUpdated;
            //insert danfosslog_item;
            //danfosslog_item.clear();             
            //danfosslog_item.LogTime__c = System.now();            
            //danfosslog_item.Name = 'UploadUsersFromAD';            
			//danfosslog_item.LogText__c = '$$UploadUsersFromAD$$FinalCountInactive$$ No of users has been inactivated : ' + countInactive;
            //insert danfosslog_item;            
        }
   }
    
   global void finish(Database.BatchableContext BC){
       DanfossLog__c danfosslog_item = new DanfossLog__c();        
       
       danfosslog_item.clear();
       danfosslog_item.LogTime__c = System.now();
       danfosslog_item.Name = 'UploadUsersFromAD';
       danfosslog_item.LogText__c = '$$UploadUsersFromAD$$FinalCountCreate$$ No of users has been created : ' + countCreated;
       insert danfosslog_item;
       danfosslog_item.clear();            
       danfosslog_item.LogTime__c = System.now();            
       danfosslog_item.Name = 'UploadUsersFromAD';            
       danfosslog_item.LogText__c = '$$UploadUsersFromAD$$FinalCountUpdate$$ No of users has been updated : ' + countUpdated;
       insert danfosslog_item;
       danfosslog_item.clear();             
       danfosslog_item.LogTime__c = System.now();            
       danfosslog_item.Name = 'UploadUsersFromAD';            
       danfosslog_item.LogText__c = '$$UploadUsersFromAD$$FinalCountInactive$$ No of users has been inactivated : ' + countInactive;
       insert danfosslog_item;  

       system.debug('$$UploadUsersFromAD$$FinalCountCreate$$ No of users has been created : ' + countCreated);     
       system.debug('$$UploadUsersFromAD$$FinalCountUpdate$$ No of users has been updated : ' + countUpdated);     
       system.debug('$$UploadUsersFromAD$$FinalCountInactive$$ No of users has been inactivated : ' + countInactive);           
       
       // Delete the whole AD upload so that it is empty for next times
       List<UploadUsers__c> existingUpload = [SELECT Id From UploadUsers__c];
       delete existingUpload;    
   }
}