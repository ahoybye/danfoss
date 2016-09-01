trigger DLRPrepopulateFields on Deviated_Lead_time_Request__c (before insert, before update) {
     for (Deviated_Lead_time_Request__c c :Trigger.new){
        Account acct = [select Id, OwnerId from Account where Id = :c.Account__c Limit 1];
        List<AccountTeamMember> atms = [select TeamMemberRole, UserId from AccountTeamMember where AccountId = :acct.Id]; 
        c.Account_Owner__c = acct.OwnerId; 
        for (AccountTeamMember a :atms) {
            if (a.TeamMemberRole == 'Customer Service Rep')
                c.CSR__c = a.UserId;
            if (a.TeamMemberRole == 'Sales Specialist')
                c.Sales_Specialist__c = a.UserId;
            if (c.CSR__c == null)
                c.CSR__c = acct.OwnerId;
            if (c.Sales_Specialist__c == null)
                c.Sales_Specialist__c = acct.OwnerId;
        }
    }
}