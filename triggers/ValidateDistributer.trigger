/**********************************************************************************
Created By    :    Sumit Mishra
Date          :    10/20/2011
Reason        :    Trigger to validate insertion of Authorized Products. 
**********************************************************************************/
trigger ValidateDistributer on Authorized_Product__c (before Insert) 
{
    Map<id,Account> mapAccount = new Map<id,Account>();
    Set<id> accountIdSet = new Set<id>();
    Set<id> productLineSet = new Set<id>();
    for(Authorized_Product__c prod:Trigger.new)
    {
        if(prod.Product_Line__c != null)
        {
            accountIdSet.add(prod.Account__c);
            productLineSet.add(prod.Product_Line__c);
        }
    }
    Set<id> parentAccountIdSet = new Set<id>();
    for(Account act:[Select id, Channel__c,Channel_Attributes__c,ParentId 
                from Account 
                where ((Channel__c ='Distributor' and Channel_Attributes__c!=null) or (Channel__c ='Indirect')) and Id in :accountIdSet and ParentId!=null
                AND Parent.Channel__c ='Distributor' and Parent.Channel_Attributes__c!=null])
    {
        parentAccountIdSet.add(act.ParentId);
        mapAccount.put(act.Id,Act);
    }
    Map<id,Set<Id>> mapaccounttoProductSet = new Map<id,Set<Id>>();
    for(Account act:[Select id,
                        (Select id,Product_Line__c from Products_Authorized__r 
                        where Product_Line__c!=null AND Product_Line__c in :productLineSet) 
                    from Account where id in :parentAccountIdSet])
    {
        Set<Id> mySet = new Set<Id>();
        mapaccounttoProductSet.put(act.Id,mySet);
        for(Authorized_Product__c prod:act.Products_Authorized__r)
        {
            mySet.add(prod.Product_Line__c);
        }
    }
    for(Authorized_Product__c prod:Trigger.new)
    {
        if(prod.Product_Line__c != null && mapAccount.get(prod.Account__c)!=null)
        {
            Set<id> mySet = mapaccounttoProductSet.get(mapAccount.get(prod.Account__c).ParentId);
            if(mySet!=null)
            {
                if(!mySet.Contains(prod.Product_Line__c))
                    prod.AddError('This account is not authorized to sell this product line. Please check parent account Authorized product lines for full list of available product lines.');
            }
        }   
    }
    
    
    

}