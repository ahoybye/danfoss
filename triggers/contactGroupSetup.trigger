trigger contactGroupSetup on Contact (after insert, after update) 
{
    Set<id> accountToOperate = new Set<id>();
    Map<id,Id> RemoveFromM = new Map<id,Id>();
    Map<id,Id> AddToM = new Map<id,Id>();
    Map<id,Id> RemoveFromU = new Map<id,Id>();
    Map<id,Id> AddToU = new Map<id,Id>();
    for(Contact con:Trigger.New)
    {
        if (Trigger.isUpdate) {
            Contact conOld = Trigger.Oldmap.get(con.Id);
            string oType = 'U';
            string nType = 'U';
            User_Type_Department_Match__c utold=null;
            if(con.department__c!=null)
            {
                User_Type_Department_Match__c ut = User_Type_Department_Match__c.getValues(con.Department__c);
                if(ut!=null && ut.Type__c=='Restricted') 
                    nType  = 'M';
            }
            if(conOld.department__c!=null)
            {
                User_Type_Department_Match__c ut = User_Type_Department_Match__c.getValues(conOld.Department__c);
                if(ut!=null && ut.Type__c=='Restricted') 
                    oType  = 'M';
            }
            if((oType=='M' && nType =='U') || (conOld.AccountId !=Con.Accountid && oType=='M'))
                RemoveFromM.put(Con.Id,ConOld.Accountid);
                AddToU.put(Con.Id,Con.Accountid);  //*~*~* Added 27MAR13
            if(conOld.AccountId !=Con.Accountid)
                RemoveFromU.put(Con.Id,ConOld.Accountid);
            if((oType=='U' && nType =='M') || (conOld.AccountId !=Con.Accountid && nType=='M'))
                AddToM.put(Con.Id,Con.Accountid);
            if(conOld.AccountId !=Con.Accountid)
                AddToU.put(Con.Id,Con.Accountid);
            accountToOperate.add(con.AccountId);
            accountToOperate.add(conOld.AccountId);
        }
        
        if (Trigger.isInsert) {
            User_Type_Department_Match__c ut = User_Type_Department_Match__c.getValues(con.Department__c);
            if(ut!=null && ut.Type__c=='Restricted')
                AddToM.put(Con.Id,Con.Accountid);
            AddToU.put(Con.Id,Con.Accountid);
            accountToOperate.add(con.AccountId);
        }
    }
    if ((Test.isRunningTest()&&Limits.getFutureCalls()>=Limits.getLimitFutureCalls()) || system.isBatch()) {
        system.debug(LoggingLevel.Error, 'Future method limit reached - or called from batch. Skipping...');
    }
    else {
        ContentUtils.updateUserGroupSettingsonContactUpdate(accountToOperate,RemoveFromM,AddToM,RemoveFromU,AddToU);
    }
}