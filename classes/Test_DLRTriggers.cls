@isTest (seealldata=true)
private class Test_DLRTriggers{
	static testMethod void testDLR() {
    	Account account = Test_Utility.createAccount(1);
    	insert account; 
        User u = [select id from User limit 1];
        Deviated_Lead_time_Request__c dlr = new Deviated_Lead_time_Request__c(Account__c = Account.Id);
        insert dlr;
        AccountTeamMember atm1 = new AccountTeamMember(TeamMemberRole = 'Customer Service Rep', AccountId = Account.Id, userId = u.Id);
        insert atm1;
        Deviated_Lead_time_Request__c dlr1 = new Deviated_Lead_time_Request__c(Account__c = Account.Id);
        insert dlr1;
        AccountTeamMember atm2 = new AccountTeamMember(TeamMemberRole = 'Sales Specialist', AccountId = Account.Id, userId = u.Id);
        insert atm2;
        update dlr;
    }
}