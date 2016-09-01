@RestResource(urlMapping='/RestInterfaceQuoteData/*')
global with sharing class RestOpportunityController {
    
    @HttpGet
    global static quoteData getQuoteData() {
        RestContext.response.addHeader('Content-Type', 'text/plain');
               
        // Get the opportunityId from the parameterlist in the REST call
        String oppId = RestContext.request.params.get('opportunityId');
        String accId = RestContext.request.params.get('accountId');     
        String usrId = RestContext.request.params.get('userId');             
     	quoteData qd = new quoteData();
        
        system.debug('$$RestInterfaceQuoteData$$ - Start');
 
        string accountQueryFields='';
        string opportunityQueryFields='';
        string contactQueryFields='';        
        string supportListQueryFields='';        
        
        // Retrieve all the fieldnames to be transferred from the custom settings
		for (RestInterfaceQuoteDataOpportunity__c fieldname : [select name from RestInterfaceQuoteDataOpportunity__c])  { 
         	   opportunityQueryFields += ', '  + fieldname.name;
        }
        
		for (RestInterfaceQuoteDataAccount__c fieldname : [select name from RestInterfaceQuoteDataAccount__c])  { 
         	   accountQueryFields += ', '  + fieldname.name;
        }

		for (RestInterfaceQuoteDataContact__c fieldname : [select name from RestInterfaceQuoteDataContact__c])  { 
         	   contactQueryFields += ', '  + fieldname.name;
        }        

		for (RestInterfaceQuoteDataSupportList__c fieldname : [select name from RestInterfaceQuoteDataSupportList__c])  { 
         	   supportListQueryFields += ', '  + fieldname.name;
        }  
        
        system.debug('$$RestInterfaceQuoteData$$Opportunity$$'+ opportunityQueryFields);
        system.debug('$$RestInterfaceQuoteData$$Account$$'+ accountQueryFields);
        system.debug('$$RestInterfaceQuoteData$$Contact$$'+ contactQueryFields);        
        system.debug('$$RestInterfaceQuoteData$$SupportList$$'+ supportListQueryFields);                

        // On a project opportunity it is the stakeholder that we need to start with and then we will take opportunity id from there
        // that is done so that the id fields in ConfigIt are the correct ones
        Associated_Account__c stakeholder;  
        try {
        	stakeholder = Database.query('select Id, contact__c, Project_Opportunity__c, SubAccount__c, Associated_Account__c from Associated_Account__c where Id=\'' + oppId + '\'');
        	IF (stakeholder.Project_Opportunity__c != null) {
          		oppId = stakeholder.Project_Opportunity__c;
        	}  
        } catch (exception ex) {
            
        }
        
        Opportunity opp = new Opportunity();
        User quotecreator = new User();
        
        // Selecting the data from the databases
        // Opportunity data
        IF (oppId != null) {
       		opp = Database.query('select Id' + opportunityQueryFields + ' from Opportunity where Id=\'' + oppId + '\''); 
            
            // Replace the 3 id fields from the opportunity with data from the stakeholder
        	IF (stakeholder != null) {                
          		opp.AccountId = stakeholder.Associated_Account__c;
          		opp.Contact__c = stakeholder.Contact__c;                
          		opp.Sub_Account__c = stakeholder.SubAccount__c;
                opp.Sales_Area__c = null;
        	}            
    	}
        
        IF (accId == null) {
            accId = opp.AccountId;
        }
                
        // Quote creator data
        IF (usrId != null) {
        	//List<user> userlist = [select Id, Division__c from User where User_Id__c=:usrId limit 1];
            List<user> userlist = Database.query('select Id, Division__c' + supportListQueryFields + ' from user where User_Id__c=\'' + usrId + '\' limit 1');
        	if (userlist.size()==1) {
                quotecreator = userlist[0];
            }            	
        }
        
        // Account data
        Account acc = Database.query('select Id' + accountQueryFields + ' from Account where Id=\'' + accId + '\''); 
        
        // List of sub accounts
        List<Sub_account__c> subaccounts = Database.query('select Id, SAP_Account_ID__c, name, Name_2__c, City__c, Postal_Code__c, Country_Code__c, Street__c, street_2__c, (select id, name, Incoterms_1__c, Incoterms_2__c, Payment_terms__c, Sales_Office__c, Sales_Group__c, Master_Channel__c, Master_Sales_Org__c, Master_Division__c, Payment_terms_SAP_ID__c, Warranty_SAP_ID__c, Incoterms_1_SAP_ID__c from Sales_Areas__r) from sub_account__c where inactive__c = false AND account__c=\'' + accId + '\''); 
        //List<Sub_account__c> subaccounts = Database.query('select Id' + subaccountQueryFields (select id, name, Incoterms_1__c, Incoterms_2__c, Payment_terms__c, Master_Channel__c, Master_Sales_Org__c, Master_Division__c from Sales_Areas__r) from sub_account__c where account__c=\'' + accId + '\'');                 
        
        // List of contacts
        List<Contact> contacts = Database.query('select Id' + contactQueryFields + ' from Contact where account.Id=\'' + accId + '\' and Inactive_Contact__c=false'); 

        User userprofile 	   = new User();
        User opportunity_owner = new User();
        User account_manager   = new User();
        List<User> commercial_contact_cooling = new List<User>(); 
        List<User> technical_contact_cooling  = new List<User>(); 
        List<User> commercial_contact_drives  = new List<User>(); 
        List<User> technical_contact_drives   = new List<User>(); 
        List<User> commercial_contact_heating = new List<User>(); 
        List<User> technical_contact_heating  = new List<User>(); 
        //User commercial_contact_cooling = new User(); 
        //User technical_contact_cooling  = new User(); 
        //User commercial_contact_drives  = new User(); 
        //User technical_contact_drives   = new User(); 
        //User commercial_contact_heating = new User(); 
        //User technical_contact_heating  = new User(); 
        
       	List<accountteammember> accountteam_list = new List<accountteammember>();
        List<opportunityteammember> opportunityteam_list = new List<opportunityteammember>();
		List<User> sales_support_list = new List<User>();       
		List<User> technical_support_list = new List<User>();       
		List<User> commercial_support_list = new List<User>(); 
                                                 
        // add persons from CSC section on account
		commercial_contact_cooling = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id in (select Cooling_Commercial_Contact__c from account where id=\'' + accId + '\') LIMIT 1');                    
        //If (commercial_contact_cooling != null) {
        if (commercial_contact_cooling.size() > 0) {
	        commercial_support_list.add(commercial_contact_cooling[0]);             
        }

        technical_contact_cooling  = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id in (select Cooling_Technical_Contact__c from account where id=\'' + accId + '\') LIMIT 1');                    
        //If (technical_contact_cooling != null) {    
        if (technical_contact_cooling.size() > 0) {            
	        technical_support_list.add(technical_contact_cooling[0]);                                
        }
        
        commercial_contact_drives  = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id in (select CSC_Agent__c from account where id=\'' + accId + '\') LIMIT 1');                    
        //If (commercial_contact_drives != null) {
        if (commercial_contact_drives.size() > 0) {            
        	commercial_support_list.add(commercial_contact_drives[0]); 
        }

        technical_contact_drives   = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id in (select Danfoss_Contact_Technical__c from account where id=\'' + accId + '\') LIMIT 1');                    
        //If (technical_contact_drives != null) {    
        if (technical_contact_drives.size() > 0) {            
        	technical_support_list.add(technical_contact_drives[0]);                                
        }
        
        commercial_contact_heating = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id in (select Heating_Commercial_Contact__c from account where id=\'' + accId + '\') LIMIT 1');                    
        //If (commercial_contact_heating != null) {  
        if (commercial_contact_heating.size() > 0) {            
        	commercial_support_list.add(commercial_contact_heating[0]);         
        }

        //technical_contact_heating  = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id in (select Heating_Technical_Contact__c from account where id=\'' + accId + '\') LIMIT 1');                    
        //If (technical_contact_heating != null) {            
        //	technical_support_list.add(technical_contact_heating);                                
        //}
        technical_contact_heating  = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id in (select Heating_Technical_Contact__c from account where id=\'' + accId + '\') LIMIT 1');                    
        If (technical_contact_heating.size() > 0) {            
        	technical_support_list.add(technical_contact_heating[0]);                                
        }

        
        // List of teams and owners
        IF (accId != null) {
            accountteam_list = Database.query('select userid, teammemberrole from accountteammember where accountid=\'' + accId + '\'');                
			account_manager  = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id in (select ownerid from account where id=\'' + accId + '\')');            
            
			sales_support_list.add(account_manager);                    
			technical_support_list.add(account_manager);                                
			commercial_support_list.add(account_manager); 
            
            IF (account_manager.Id == quotecreator.Id) {
               qd.sales_support_preselect = account_manager.Id;
               qd.technical_support_preselect = account_manager.Id;
               qd.commercial_support_preselect = account_manager.Id;
       		}
            
            // Account team members
            For (AccountTeamMember atm : accountteam_list) {
                If (atm.TeamMemberRole != null && atm.TeamMemberRole.contains('Employee Responsible') ||
                    atm.TeamMemberRole != null && atm.TeamMemberRole.contains('Key Account Manager')) {
                    userprofile = Database.query('select Id, Division__c' + supportListQueryFields + ' from user where id=\'' + atm.UserId + '\'');
                  	sales_support_list.add(userprofile);    
                        
                    if (userprofile.Id == quotecreator.Id && qd.sales_support_preselect == null) {
                      qd.sales_support_preselect = userprofile.Id;
                    }                        
                }
                If (atm.TeamMemberRole != null && atm.TeamMemberRole.contains('Internal Technical Support') ||
                    atm.TeamMemberRole != null && atm.TeamMemberRole.contains('Key Account Manager') ||
                    atm.TeamMemberRole != null && atm.TeamMemberRole.contains('Employee Responsible')) {
                    userprofile = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id=\'' + atm.UserId + '\'');
					technical_support_list.add(userprofile);
                        
                    if (userprofile.Id == quotecreator.Id && qd.technical_support_list == null)  {
                      qd.technical_support_preselect = userprofile.Id;
                    }                                                
                }
                If (atm.TeamMemberRole != null && atm.TeamMemberRole.contains('Inside Sales')) {
                    userprofile = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id=\'' + atm.UserId + '\'');
					commercial_support_list.add(userprofile);

                    if (userprofile.Id == quotecreator.Id && qd.commercial_support_preselect == null)  {
                      qd.commercial_support_preselect = userprofile.Id;
                    }                                            
                }
            }
        }
       
        IF (oppId != null) {        
            opportunityteam_list = Database.query('select userid, teammemberrole from opportunityteammember where opportunityId=\'' + oppId + '\'');            
            opportunity_owner = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id in (select ownerid from opportunity where id=\'' + oppId + '\')');            

            sales_support_list.add(opportunity_owner);                    
			technical_support_list.add(opportunity_owner);                                
			commercial_support_list.add(opportunity_owner); 
            
            IF (opportunity_owner.Id == quotecreator.Id) {
               qd.sales_support_preselect = opportunity_owner.Id;
               qd.technical_support_preselect = opportunity_owner.Id;
               qd.commercial_support_preselect = opportunity_owner.Id;
       		}
            
            // Opportunity team members
            For (OpportunityTeamMember otm : opportunityteam_list) {
                If (otm.TeamMemberRole != null && otm.TeamMemberRole.contains('Employee Responsible') ||
                    otm.TeamMemberRole != null && otm.TeamMemberRole.contains('Key Account Manager')) {
                    userprofile = Database.query('select Id, Division__c' + supportListQueryFields + ' from user where id=\'' + otm.UserId + '\'');
					sales_support_list.add(userprofile);
                        
                    if (userprofile.Id == quotecreator.Id && qd.sales_support_preselect == null){
                      qd.sales_support_preselect = userprofile.Id;
                    }                        
                }
                If (otm.TeamMemberRole != null && otm.TeamMemberRole.contains('Internal Technical Support') ||
                    otm.TeamMemberRole != null && otm.TeamMemberRole.contains('Key Account Manager') ||
                    otm.TeamMemberRole != null && otm.TeamMemberRole.contains('Employee Responsible')) {
                    userprofile = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id=\'' + otm.UserId + '\'');
					technical_support_list.add(userprofile);

                    if (userprofile.Id == quotecreator.Id && qd.technical_support_preselect == null) {
                      qd.technical_support_preselect = userprofile.Id;
                    }                           
                }
                If (otm.TeamMemberRole != null && otm.TeamMemberRole.contains('Inside Sales')) {
                    userprofile = Database.query('select Id, Division__c' + supportListQueryFields + ' from user  where id=\'' + otm.UserId + '\'');
					commercial_support_list.add(userprofile);
                    
                    if (userprofile.Id == quotecreator.Id && qd.commercial_support_preselect == null) {
                      qd.commercial_support_preselect = userprofile.Id;
                    }                      
                }
            }
        }
 
        // 2016-08-16 - Allan Hoybye (Salesforce.com)
		// Decision to add quote creator to all support lists
		if (quotecreator.Id != null)  {
        	sales_support_list.add(quotecreator);
            technical_support_list.add(quotecreator);
            commercial_support_list.add(quotecreator);
        }
        
 		// Remove duplicates
		Set<User> tmpset = new Set<User>();
		List<User> result_list1 = new List<User>();
		for (User sortlist : sales_support_list) {
          if (tmpset.add(sortlist)) {
            result_list1.add(sortlist);
          }
        }
        sales_support_list = result_list1;
  		sales_support_list.sort();
      
		List<User> result_list2 = new List<User>();        
        tmpset.clear();
		for (User sortlist : technical_support_list) {
          if (tmpset.add(sortlist)) {
            result_list2.add(sortlist);
          }
        }
        technical_support_list = result_list2;
        technical_support_list.sort();
        
		List<User> result_list3 = new List<User>();        
        tmpset.clear();        
		for (User sortlist : commercial_support_list) {
          if (tmpset.add(sortlist)) {
            result_list3.add(sortlist);
          }
        }
        commercial_support_list = result_list3;
        commercial_support_list.sort();
        
        system.debug('$$RestInterfaceQuoteData$$Copy of the 3 lists$$'+ quotecreator.Division__c + ' * ' + quotecreator.Division__c);

        List<User> division_sales_support_list 		= new List<User>();       
        List<User> division_technical_support_list  = new List<User>();       
        List<User> division_commercial_support_list = new List<User>();  
        
        // Create a copy of the 3 list and in those copies remove all users from different division
        //if (quotecreator.Division__c == 'JPKTEST') {         
        if (quotecreator.Division__c != null && quotecreator.Division__c != '') {
            division_sales_support_list 	 = sales_support_list.clone();
            division_technical_support_list  = technical_support_list.clone();
            division_commercial_support_list = commercial_support_list.clone();        
    
            system.debug('$$RestInterfaceQuoteData$$division_sales_support_list$$'+ division_sales_support_list.size() + ' * ' + sales_support_list.size());
            system.debug('$$RestInterfaceQuoteData$$division_technical_support_list$$'+ division_technical_support_list.size() + ' * ' + technical_support_list.size());
            system.debug('$$RestInterfaceQuoteData$$division_commercial_support_list$$'+ division_commercial_support_list.size() + ' * ' + commercial_support_list.size());
            
            Integer counter = 0;
            while (counter < division_sales_support_list.size()) {
              if(division_sales_support_list.get(counter).Division__c != quotecreator.Division__c) {
                division_sales_support_list.remove(counter);
              } else {
                counter++;
              }
            }
            counter = 0;
            while (counter < division_technical_support_list.size()) {
              if(division_technical_support_list.get(counter).Division__c != quotecreator.Division__c) {
                division_technical_support_list.remove(counter);
              } else {
                counter++;
              }
            }
            counter = 0;
            while (counter < division_commercial_support_list.size()) {
              if(division_commercial_support_list.get(counter).Division__c != quotecreator.Division__c) {
                division_commercial_support_list.remove(counter);
              } else {
                counter++;
              }
            }
			
        }
        
        IF (opp.AccountId == null) {
            opp.AccountId = null;
        }
        IF (opp.Contact__c == null) {
            opp.Contact__c = null;
        }     
        IF (opp.Sub_Account__c == null) {
            opp.Sub_Account__c = null;
        }        
        IF (opp.Sales_Area__c == null) {
            opp.Sales_Area__c = null;
        }                
        
        // Allocate to parameters
        qd.contact_list = contacts;
        qd.sub_account_list = subaccounts;
        qd.account = acc;
        qd.opportunity = opp;
        
        If (division_sales_support_list.size() == 1) { // if only one user is in the list (creator) - use the cross-divisional list
        	qd.sales_support_list = sales_support_list;
        } else {
            qd.sales_support_list = division_sales_support_list;
        }
        
        If (division_technical_support_list.size() == 1) { // if only one user is in the list (creator) - use the cross-divisional list
        	qd.technical_support_list = technical_support_list;
        } else {
            qd.technical_support_list = division_technical_support_list;
        }
        
        If (division_commercial_support_list.size() == 1) { // if only one user is in the list (creator) - use the cross-divisional list
        	qd.commercial_support_list = commercial_support_list;
        } else {
            qd.commercial_support_list = division_commercial_support_list;
        }
        
        return qd;
    }

    global class quoteData {
        public Opportunity opportunity {get; set;}
        public Account account {get; set;}
		public List<Sub_account__c> sub_account_list {get; set;}               
        public List<Contact> contact_list {get; set;}       
        public List<User> sales_support_list {get; set;}      
        public List<User> technical_support_list {get; set;}                
        public List<User> commercial_support_list {get; set;}  
        public Id sales_support_preselect {get; set;}
        public Id technical_support_preselect {get; set;}
        public Id commercial_support_preselect {get; set;}        
    }    
}