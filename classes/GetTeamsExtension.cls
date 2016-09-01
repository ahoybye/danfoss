public class GetTeamsExtension {
    
    public Account a{get;set;}  
    public ApexPages.StandardSetController setCon {get;set;}
    public Id selectedDD {get;set;} 
    public String countryList {get;set;}    
    public Id selectedATMId {get;set;}
    public Id selectedATId {get;set;}
    public Boolean reload {get;set;}
    public String shownTab {get;set;}
    public Boolean userInTeam {get;set;}
    public AccountTeamMember userTeamMember {get;set;}
    public AccountTeamMember anyUserTeamMember {get;set;}
    public List<AccountTeamMember> currentAccountTeamMembers {get;set;}
    
    public GetTeamsExtension(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String> {'Country_MainAddress__c', 'ShippingCountry'});
        }        
        
        shownTab = ApexPages.currentPage().getParameters().get('selectedTab');
        if (shownTab=='')
            shownTab='teamsTab';
        
        a = (Account) stdController.getRecord();
        
        Set<String> countries = new Set<String>();
        if (a.Country_MainAddress__c != null) {
            countries.add(a.Country_MainAddress__c.substring(0, 2));
        }
        if (a.ShippingCountry != null) {
            countries.add(a.ShippingCountry.substring(0, 2));
        }
        countryList = String.join(new List<String>(countries), ', ');
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator([
            select Name, Division__c, SBA_Team__c, Id
            from Team__c
            where Id in (
                select Team__c
                from Location__c
                where Postal_Code_From__c <= :a.ShippingPostalCode and Postal_Code_To__c >= :a.ShippingPostalCode and Country__c in :countries
            )
        ]));
        setCon.setPageSize(8);
        
        refreshAccountTeamMembers();
        anyUserTeamMember = new AccountTeamMember();
        
        
    }
    
    public List<Team__c> getTeams() {       
        return setCon.getRecords();
        
    }
    
    /*
    public void refreshAssociatedTeams() {
        currentAssociatedTeams = [SELECT Id, UserId, TeamMemberRole, AccountId, User.Name FROM Associated_Teams__c WHERE accountId=:a.Id LIMIT 100];               
    }
    */
    public void refreshAccountTeamMembers() {
        currentAccountTeamMembers = [SELECT Id, UserId, TeamMemberRole, AccountId, User.Name FROM AccountTeamMember WHERE accountId=:a.Id LIMIT 100];
        
        userInTeam=false;
        // See if the users is already in Account team
        for (AccountTeamMember ATM : currentAccountTeamMembers) {
            if (ATM.UserId == UserInfo.getUserId()) {
                userTeamMember=ATM;        
                userInTeam=true;
                break;
            }
        }
        // If the users did not exist in the team - create a new Account Team Member
        if (userInTeam==false) {
            userTeamMember = new AccountTeamMember();
            userTeamMember.AccountId = a.Id;
            userTeamMember.UserId = UserInfo.getUserId();
        }
    }
    
    /*
    public List<SelectOption> getTeamRoleOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =AccountTeamMember.TeamMemberRole.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    */
    public pagereference AddTeam() {
        Team__c t = [select Name, SBA_Team__c from Team__c where Id = :selectedDD];
        List<AccountTeamMember> accountTeamList = new List<AccountTeamMember>();
       //Added for Team Fix 1th March 2015: only need to add Team Members that are of the "User" recordtype & where the user is actually active
        //for (TeamMember__c tm : [select User__c, user__r.isactive, Account_Team_Role__c from TeamMember__c where user__r.isactive = true and recordtype.developername='Team_Member_User' and Team__c = :selectedDD]) {
        for (TeamMember__c tm : [select User__c, user__r.isactive, Account_Team_Role__c from TeamMember__c where user__r.isactive = true and Team__c = :selectedDD]) {            
            String StrTeamRole = t.SBA_Team__c + ':' + tm.Account_Team_Role__c   ;
            if(StrTeamRole.length() > 40){StrTeamRole=StrTeamRole.substring(0,40);}
            AccountTeamMember acctTM = new AccountTeamMember(AccountId = a.Id,UserId = tm.User__c,TeamMemberRole = StrTeamRole);
            accountTeamList.add(acctTM);
        }
        
        //Added for Team Fix 1th March 2015: associate the team to the account with the junction object "Associated_Team__c"
        //Associated_Team__c assocTeam = new Associated_Team__c();
        //list<Associated_Team__c> assocTeamList = new list<Associated_Team__c>();
        //assocTeamList = [select name, account__c, Team__c from Associated_Team__c where Team__c =:selectedDD and account__c =:a.id limit 1];
        //if (assocTeamList.size() != 0)
        //{assocTeam=assocTeamList[0];}
        //else{ 
        //  assocTeam.Account__c = a.Id;
        //    assocTeam.Team__c = t.id;}
        //  assocTeam.name = t.Name + ', ' + a.name;
        
        //try {
        //    upsert assocTeam;
        //} catch (DMLException e) {
        //   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to Add Associated Team... ' + e));
        //}
             
             
        try {
            insert accountTeamList;
            refreshAccountTeamMembers();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Added ' + accountTeamList.size() + ' user(s) to the Account Team.'));
        } catch (DMLException e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to Add Account Team... ' + e));
        }
        
        //pageReference del = ApexPages.currentPage(); 
        //del.setRedirect(true);
        //del.getParameters().put('selectedTab','teamsTab');
        return null;
    }
   /*    
   public pagereference removeAT() {
        Associated_Team__c delacctT = new Associated_Team__c(id = selectedATId);
        list<AccountTeamMember> delAccountTeamMembers= new list<AccountTeamMember>();
        
        id team_id = [select Team__c from Associated_Team__c where id=:selectedATId].Team__c;
        for (AccountTeamMember atm : [select id from AccountTeamMember where accountid =:a.id and UserId in (select User__c from TeamMember__c where user__r.isactive = true and recordtype.developername='Team_Member_User' and Team__c = :team_id)])
        {
            delAccountTeamMembers.add(atm);
        }
        
       try {
            delete delAccountTeamMembers;
            refreshAccountTeamMembers();
        } catch (DMLException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to Delete Account Team Members...' + e));       
        }  
                
        try {
            delete delacctT;
        } catch (DMLException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to Delete Account Team...' + e));       
        }           
        
        return null;
    }
    */
    
    public pagereference addUser() {
        if (userTeamMember.TeamMemberRole==null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Please select a team role first.'));
        } else {
            insert userTeamMember;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Added user to the Account Team.'));
            refreshAccountTeamMembers();
        }
               
        return null;
    }
    
    public pagereference removeUser() {                   
        if (userTeamMember!=null) {
            delete userTeamMember;
            refreshAccountTeamMembers();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Removed user from the Account Team.'));
        }

        return null;     
    }

    public pagereference addTeamMember() {
        if (anyUserTeamMember.UserId==null || anyUserTeamMember.TeamMemberRole==null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Please select a user and a role.'));                        
        } else {
            anyUserTeamMember.AccountId=a.Id;   
            insert anyUserTeamMember;
            
            // re-initialize for next insert
            anyUserTeamMember = new AccountTeamMember();
            refreshAccountTeamMembers();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Added user to the Account Team.'));
        }
               
        return null;
    }
    
   public pagereference removeTeamMember() {
       AccountTeamMember delacctTM = new AccountTeamMember(id = selectedATMId);
       
       try {
           delete delacctTM;
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Removed user from the Account Team.'));
           refreshAccountTeamMembers();
       } 
       catch (DMLException e) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to Delete Account Team Member...' + e));       
       }                          
       return null;     
   }
}