/**
    Author: Erin Fink
    Date: 09JUN15
    Version 1.0
**/

public with sharing class CaseTriggerHandler{

    private static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Pricing').getRecordTypeId();
    static QueueSobject PricingAMqueue = [Select QueueId from QueueSobject where Queue.DeveloperName = 'PS_Pricing_Americas'];
    static QueueSobject PricingEUqueue = [Select QueueId from QueueSobject where Queue.DeveloperName = 'PS_Pricing_Europe'];
    static QueueSobject EUSCqueue = [Select QueueId from QueueSobject where Queue.DeveloperName = 'PS_Pricing_EUSC'];
    
    public static void assignToAccountManager(List<Case> lstCases){         
        Set<Id> setAMqueueMembers = new Set<Id>();
        for (GroupMember qUser :[Select UserOrGroupId from GroupMember WHERE GroupId = :PricingAMqueue.QueueId]){
            setAMqueueMembers.add(qUser.UserOrGroupId);
        }
        System.debug(setAMqueueMembers);
        
        set<Id> setAcctIds= new set<Id>();
        for(Case c :lstCases){
            setAcctIds.add(c.AccountId);
        }
        map<Id, List<AccountTeamMember>> mapAccountTeamMembers = new map<Id, List<AccountTeamMember>>();
        List<AccountTeamMember> lstAcctsTeam = [select Id, AccountId, TeamMemberRole, UserId from AccountTeamMember where AccountId IN :setAcctIds];
        Id PricePlanner;
        for(AccountTeamMember atm :lstAcctsTeam){
            if(!mapAccountTeamMembers.containsKey(atm.AccountId))
                mapAccountTeamMembers.put(atm.AccountId, new List<AccountTeamMember>());
            mapAccountTeamMembers.get(atm.AccountId).add(atm);
        }
        map<Id, Account> mapAccounts = new map<Id, Account>([select Id, OwnerId, Sales_Manager__c, Country__r.Region__c from Account where Id IN :setAcctIds]);

        for(Case c :lstCases){
            if(c.RecordTypeId != caseRecordTypeId)
                break;
            c.Sales_Manager__c = mapAccounts.get(c.AccountId).Sales_Manager__c;
            if(mapAccounts.get(c.AccountId).Country__r.Region__c == 'Americas'){
                c.Status = 'In Process';  //here or only when Origin is Pricing?
                if(!setAMqueueMembers.contains(UserInfo.getUserId())){                  
                    c.OwnerId = PricingAMqueue.QueueId; 
                    c.Origin = 'Sales';
                }
                else
                    c.Origin = 'Pricing';
                    if(c.Type == 'Annual Price Adjustment'){
                        c.Pricing_Stage__c = '(1) APA Negotiation Ongoing';
                        c.OwnerId = mapAccounts.get(c.AccountId).OwnerId; 
                    }
            }
            
            else if(mapAccounts.get(c.AccountId).Country__r.Region__c == 'Europe'){
                if(mapAccountTeamMembers.containsKey(c.AccountId)){
                    for(AccountTeamMember mem :mapAccountTeamMembers.get(c.AccountId)){
                        if(mem.TeamMemberRole == 'Price Planner'){
                            PricePlanner = mem.UserId;
                        }
                    }
                }           
                if(c.Type != 'Annual Price Adjustment' && c.Origin == 'Sales'){         
                    if(PricePlanner != null)
                        c.OwnerId = PricePlanner;
                    else
                        c.OwnerId = PricingEUqueue.QueueId;
                }
                else{
                    c.OwnerId = mapAccounts.get(c.AccountId).OwnerId; 
                }
                
                if(c.Type == 'Annual Price Adjustment'){
                    c.Pricing_Stage__c = '(1) APA Negotiation Ongoing';
                }
            }
        }  
    }
    
    public static void updateCaseStatus(List<Case> lstCases){
        set<Id> setAcctIds= new set<Id>();
        for(Case c :lstCases){
            setAcctIds.add(c.AccountId);
        }
        map<Id, List<AccountTeamMember>> mapAccountTeamMembers = new map<Id, List<AccountTeamMember>>();
        List<AccountTeamMember> lstAcctsTeam = [select Id, AccountId, TeamMemberRole, UserId from AccountTeamMember where AccountId IN :setAcctIds];
        Id CSR;
        Id PricePlanner;
        for(AccountTeamMember atm :lstAcctsTeam){
            if(!mapAccountTeamMembers.containsKey(atm.AccountId))
                mapAccountTeamMembers.put(atm.AccountId, new List<AccountTeamMember>());
            mapAccountTeamMembers.get(atm.AccountId).add(atm);
        }
        map<Id, Account> mapAccounts = new map<Id, Account>([select Id, OwnerId, Sales_Manager__c, Country__r.Region__c from Account where Id IN :setAcctIds]);
        for(Case c :lstCases){  
            if(c.RecordTypeId != caseRecordTypeId)
                break;      
            c.Sales_Manager__c = mapAccounts.get(c.AccountId).Sales_Manager__c;
            if(c.Type == 'Annual Price Adjustment'){
                if(mapAccountTeamMembers.containsKey(c.AccountId)){
                    for(AccountTeamMember mem :mapAccountTeamMembers.get(c.AccountId)){
                        if(mem.TeamMemberRole == 'Customer Service Rep'){
                            CSR = mem.UserId;
                        }
                        else if(mem.TeamMemberRole == 'Price Planner'){
                            PricePlanner = mem.UserId;
                        }
                    }
                }            
                if(c.Pricing_Stage__c.contains('2')){
                    if(mapAccounts.get(c.AccountId).Country__r.Region__c == 'Americas'){
                        c.OwnerId = PricingAMqueue.QueueId;
                    }
                    else if(mapAccounts.get(c.AccountId).Country__r.Region__c == 'Europe'){
                        c.Status = 'Open';
                        if(PricePlanner != null)
                            c.OwnerId = PricePlanner;
                        else
                            c.OwnerId = PricingEUqueue.QueueId;
                    }
                }           
                
                if(c.Pricing_Stage__c.contains('3') && mapAccounts.get(c.AccountId).Country__r.Region__c == 'Europe'){
                    c.Status = 'In Process';
                    c.OwnerId = EUSCqueue.QueueId;
                }            
                
                if(c.Pricing_Stage__c.contains('4') && mapAccounts.get(c.AccountId).Country__r.Region__c == 'Europe'){
                    if(PricePlanner != null)
                        c.OwnerId = PricePlanner;
                    else
                        c.OwnerId = PricingEUqueue.QueueId;
                }            
                
                if(c.Pricing_Stage__c.contains('5') && mapAccounts.get(c.AccountId).Country__r.Region__c == 'Europe'){
                    c.Status = 'Closed';
                }
            }
        }
    }
       
}