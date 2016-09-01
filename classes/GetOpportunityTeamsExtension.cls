public class GetOpportunityTeamsExtension {
    
    public Opportunity o;    
    public ApexPages.StandardSetController setCon {get;set;}
    public Id selectedDD {get;set;} 
    public String countryList {get;set;}    
    public Id selectedOTMId {get;set;}
    public Id selectedOTId {get;set;}
    public Boolean reload {get;set;}
    public String shownTab {get;set;}
    public Boolean userInTeam {get;set;}
    public OpportunityTeamMember userTeamMember {get;set;}
    public OpportunityTeamMember anyUserTeamMember {get;set;}
    public List<OpportunityTeamMember> currentOpportunityTeamMembers {get;set;}
    
    public GetOpportunityTeamsExtension(ApexPages.StandardController stdController) {
        /*
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String> {'Country_MainAddress__c', 'ShippingCountry'});
        }        
        */
        shownTab = ApexPages.currentPage().getParameters().get('selectedTab');
        if (shownTab=='')
            shownTab='teamsTab';
        
        o = (Opportunity) stdController.getRecord();
        /*
        Set<String> countries = new Set<String>();
        if (o.Country_MainAddress__c != null) {
            countries.add(o.Country_MainAddress__c.substring(0, 2));
        }
        if (o.ShippingCountry != null) {
            countries.add(o.ShippingCountry.substring(0, 2));
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
        */
        
        refreshOpportunityTeamMembers();
        anyUserTeamMember = new OpportunityTeamMember();
                
    }
    
    public List<Team__c> getTeams() {       
        return setCon.getRecords();
        
    }

    public void refreshOpportunityTeamMembers() {
   		currentOpportunityTeamMembers = [SELECT Id, UserId, TeamMemberRole, OpportunityId, User.Name FROM OpportunityTeamMember WHERE OpportunityId=:o.Id LIMIT 100];
        
        userInTeam=false;
        // See if the users is already in Opportunity team
        for (OpportunityTeamMember OTM : currentOpportunityTeamMembers) {
            if (OTM.UserId == UserInfo.getUserId()) {
        		userTeamMember=OTM;        
                userInTeam=true;
                break;
            }
        }
        // If the users did not exist in the team - create a new Account Team Member
        if (userInTeam==false) {
        	userTeamMember = new OpportunityTeamMember();
        	userTeamMember.OpportunityId = o.Id;
        	userTeamMember.UserId = UserInfo.getUserId();
    	}
    }
/*    
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
            
        try {
            insert accountTeamList;
            refreshAccountTeamMembers();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Added ' + accountTeamList.size() + ' user(s) to the Account Team.'));
        } catch (DMLException e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to Add Account Team... ' + e));
        }
        
        return null;
    }
*/    
    public pagereference addUser() {
        if (userTeamMember.TeamMemberRole==null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Please select a team role first.'));
        } else {
        	insert userTeamMember;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Added user to the Opportunity Team.'));
            refreshOpportunityTeamMembers();
        }
               
        return null;
    }
    
    public pagereference removeUser() {                   
        if (userTeamMember!=null) {
        	delete userTeamMember;
            refreshOpportunityTeamMembers();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Removed user from the Opportunity Team.'));
    	}

        return null;     
    }

    public pagereference addTeamMember() {
        if (anyUserTeamMember.UserId==null || anyUserTeamMember.TeamMemberRole==null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Please select a user and a role.'));                        
        } else {
            anyUserTeamMember.OpportunityId=o.Id;   
        	insert anyUserTeamMember;
            
            // re-initialize for next insert
            anyUserTeamMember = new OpportunityTeamMember();
            refreshOpportunityTeamMembers();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Added user to the Opportunity Team.'));
        }
               
        return null;
    }
    
   public pagereference removeTeamMember() {
       OpportunityTeamMember delopptTM = new OpportunityTeamMember(id = selectedOTMId);
       
       try {
           delete delopptTM;
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Removed user from the Account Team.'));
           refreshOpportunityTeamMembers();
       } 
       catch (DMLException e) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to Delete Opportunity Team Member...' + e));       
       }                          
       return null;     
   }
}