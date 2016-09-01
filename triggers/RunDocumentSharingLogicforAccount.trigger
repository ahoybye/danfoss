trigger RunDocumentSharingLogicforAccount on Authorized_Product__c (after insert,after Delete) 
{
    set<id>accountIds = new set<Id>();
    if(Trigger.IsInsert)
    {
        for(Authorized_Product__c ap:trigger.New)
            accountIds.add(ap.Account__c);
    }
    if(Trigger.IsDelete)
    {
        for(Authorized_Product__c ap:trigger.Old)
            accountIds.add(ap.Account__c);
    }
    Map<Id,Account> lst = new Map<Id,Account>([Select id, Business_Org__c,Channel__c, SAP_Account_ID__c ,Manager_Library__c,User_Library__c,
                            Country__c, Customer_Segment__c, Price_Schedule__c, 
                            Region__c,
                            Channel_Attributes__c, Name From Account where id in:accountIds]);
    
    ContentUtils.ProcessforAccounts(accountIds); 

}