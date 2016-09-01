public class ContentUtils
{
    @future
    public static void UpdateUserGroupWhenLibraryChange(Set<id> accountToOperate, Map<id,String> RemoveFrom,Map<id,String> AddTo)
    {
        system.debug('----------------------------------------------------Sumit');
        system.debug(accountToOperate);
        system.debug(RemoveFrom);
        system.debug(AddTo);
        system.debug('----------------------------------------------------Sumit1');
        List<GroupMember> toDelete = new List<GroupMember>();
        for(GroupMember gm:[Select id,UserOrGroupId,GroupId,Group.Name from GroupMember 
                            where UserOrGroupId in:RemoveFrom.keyset() AND Group.Name in :RemoveFrom.values()])
        {
            if(gm.Group.Name.toLowerCase() == RemoveFrom.get(gm.UserOrGroupId).toLowerCase())
                toDelete.add(gm);
        }
        if(toDelete.size()>0)
            delete toDelete;
        Map<string,Id> mapGroupNameToId = new Map<string,Id>();
        for(Group g:[Select id,name from Group where Name in:addTo.Values()])
            mapGroupNameToId.put(g.Name.ToLowerCase(),g.Id);
        List<GroupMember> toInsert = new List<GroupMember>();
        for(Id cId:addTo.keyset())
        {
            if(mapGroupNameToId.get(addTo.get(cId).toLowerCase())!=null)
            {
                groupMember gm=new groupMember(GroupId = mapGroupNameToId.get(addTo.get(cId).toLowerCase()));
                gm.UserorGroupId = cId;
                toInsert.add(gm);
            }
        }
        if(toInsert.size()>0)
            insert toInsert;
    }
    @future
    public static void updateUserGroupSettingsonContactUpdate(Set<id> accountToOperate,Map<id,Id> RemoveFromM,Map<id,Id> AddToM,Map<id,Id> RemoveFromU,Map<id,Id> AddToU)
    {
        map<id,Id> mapContactTouser = new map<id,Id>();
        set<string> groupNames = new set<string>();
        map<id,Account> mapAccount = new map<id,Account>([Select id, manager_Library__c,User_Library__c from Account Where 
                                                         id in:accountToOperate]);
        for(User u:[Select id, ContactId from User where ContactId in :RemoveFromM.Keyset() OR
                                                         ContactId in :RemoveFromU.Keyset() OR
                                                         ContactId in :AddToM.Keyset() OR
                                                         ContactId in :AddToU.Keyset()])
        {
            mapContactTouser.put(u.ContactId,u.Id);
            if(RemoveFromM.get(u.ContactId)!=null && mapAccount.get(RemoveFromM.get(u.ContactId))!=null)
                groupNames.Add(mapAccount.get(RemoveFromM.get(u.ContactId)).manager_Library__c);
            if(RemoveFromU.get(u.ContactId)!=null && mapAccount.get(RemoveFromU.get(u.ContactId))!=null)
                groupNames.Add(mapAccount.get(RemoveFromU.get(u.ContactId)).User_Library__c);
            if(AddToM.get(u.ContactId)!=null && mapAccount.get(AddToM.get(u.ContactId))!=null)
                groupNames.Add(mapAccount.get(AddToM.get(u.ContactId)).manager_Library__c);
            if(AddToU.get(u.ContactId)!=null && mapAccount.get(AddToU.get(u.ContactId))!=null)
                groupNames.Add(mapAccount.get(AddToU.get(u.ContactId)).User_Library__c);
        }
        if(mapContactTouser.keyset().size()>0)
        {
            Map<string,Group> mapGroupNameToGroup = new Map<string,Group>();
            for(Group g:[Select id,name from Group where Name in:groupNames])
                mapGroupNameToGroup.put(g.name.ToLowerCase(),g);
            Map<string,GroupMember > mapGroupmember = new Map<string,GroupMember >();
            List<GroupMember> toDeleteGM = new List<GroupMember>();
            List<GroupMember> toAddGM = new List<GroupMember>();
            for(GroupMember gm:[Select Id,UserOrGroupId,GroupId,Group.Name from GroupMember where Group.Name in :groupNames and UserOrGroupId in :mapContactTouser.values()])
            {
                mapGroupmember.put(gm.UserOrGroupId+'-'+gm.Group.Name.toLowerCase(),gm);
            }
            for(id ConId:RemoveFromM.keyset())
            {
                if(mapContactTouser.get(ConId)!=null)
                {
                    string nm = mapContactTouser.get(ConId)+'-'+mapAccount.get(RemoveFromM.get(ConId)).manager_Library__c.toLowerCase();
                    if(mapGroupmember.get(nm)!=null)
                        toDeleteGM.add(mapGroupmember.get(nm));
                }
            } 
            for(id ConId:RemoveFromU.keyset())
            {
                if(mapContactTouser.get(ConId)!=null)
                {
                    string nm = mapContactTouser.get(ConId)+'-'+mapAccount.get(RemoveFromU.get(ConId)).User_Library__c.toLowerCase();
                    if(mapGroupmember.get(nm)!=null)
                        toDeleteGM.add(mapGroupmember.get(nm));
                }
            } 
            if(toDeleteGM.Size()>0)
                delete toDeleteGM;
            for(id ConId:AddToM.keyset())
            {
                if(mapContactTouser.get(ConId)!=null && mapAccount.get(AddToM.get(ConId))!=null)
                {
                    account act =  mapAccount.get(AddToM.get(ConId));
                    if(act.manager_Library__c!=null && mapGroupNameToGroup.get(act.manager_Library__c.toLowerCase())!=null)
                    {
                        groupMember gm=new groupMember(GroupId =  mapGroupNameToGroup.get(act.manager_Library__c.toLowerCase()).Id);
                        gm.UserorGroupId = mapContactTouser.get(ConId);
                        toAddGM.add(gm);
                    }
                }
            }
            for(id ConId:AddToU.keyset())
            {
                if(mapContactTouser.get(ConId)!=null && mapAccount.get(AddToU.get(ConId))!=null)
                {
                    account act =  mapAccount.get(AddToU.get(ConId));
                    if(act.User_Library__c!=null && mapGroupNameToGroup.get(act.User_Library__c.toLowerCase())!=null)
                    {
                        groupMember gm=new groupMember(GroupId =  mapGroupNameToGroup.get(act.User_Library__c.toLowerCase()).Id);
                        gm.UserorGroupId = mapContactTouser.get(ConId);
                        toAddGM.add(gm);
                    }
                }
            }
            if(toAddGM.size()>0)
                insert toAddGM;
        }
    }
    
    
    public static void updateUsersGroupSettings( Map<id,User> mapContactId)
    {
        if(mapContactId.keyset().size()>0)
        {
           Map<id,Contact> mapCon=new Map<id,Contact>([Select id,AccountId,Account.Manager_Library__c, 
                                                       Account.User_Library__c ,Department__c
                                                       from Contact where id in :mapContactId.keyset()]);
           Map<Id,string> mapuserToGroupM = new Map<Id,string>();
           Map<Id,string> mapuserToGroupU = new Map<Id,string>();
           for(User u:mapContactId.values())
           {
                Contact con = mapCon.get(u.ContactId);
                if(con.AccountId!=null && con.Account.Manager_Library__c !=null && con.Account.User_Library__c !=null)
                {
                    User_Type_Department_Match__c ut=null;
                    system.debug('=====================>>>>>>>>>>'+con.Department__c);
                    if(con.department__c!=null)
                        ut = User_Type_Department_Match__c.getValues(con.Department__c);
                    system.debug('=====================>>>>>>>>>>'+ut);
                    if(ut!=null && ut.Type__c=='Restricted') 
                        mapuserToGroupM.put(u.Id,con.Account.Manager_Library__c.toLowerCase());
                    mapuserToGroupU.put(u.Id,con.Account.User_Library__c.toLowerCase());
                }
            }
            if(mapuserToGroupU.keyset().size()>0 || mapuserToGroupM.keyset().size()>0)
            {
                map<string,Id>mapGroupId=new map<string,Id>();
                for(Group g:[select Id,name from group where Name IN :mapuserToGroupU.values() OR Name IN :mapuserToGroupM.values()])
                {
                    mapGroupId.put(g.Name.toLowerCase(),g.Id);
                }
                List<GroupMember> lstToInsert  =new List<GroupMember>();
                for(id uId:mapuserToGroupU.keyset())
                {
                    if(mapGroupId.get(mapuserToGroupU.get(uId).toLowerCase())!=null)
                    {
                        GroupMember gm = new GroupMember(UserorGroupId = uId);
                        gm.GroupId = mapGroupId.get(mapuserToGroupU.get(uId).toLowerCase());
                        lstToInsert.add(gm);
                    }
                }
                for(id uId:mapuserToGroupM.keyset())
                {
                    if(mapGroupId.get(mapuserToGroupM.get(uId).toLowerCase())!=null)
                    {
                        GroupMember gm = new GroupMember(UserorGroupId = uId);
                        gm.GroupId = mapGroupId.get(mapuserToGroupM.get(uId).toLowerCase());
                        lstToInsert.add(gm);
                    }
                }
                if(lstToInsert.size()>0)
                    insert lstToInsert;
            }  
        }
    }
    public static boolean isSetContainsAnyValue(set<String> setVal,string values)
    {
        if(setVal==null || values==null)
            return false;
        for(string val:values.split(';'))
        {
            string st = val.split('-')[0].trim();
            if(setval.contains(st.trim()))
                return true;
        }
        return false;
    }
    public static boolean isSetContainsAnyValue(string val1,string val2)
    {
        if(val1==null || val2==null)
            return false;
        set<string> setVal = new set<string>();
        for(string val:val1.split(';'))
        {
            setVal.add(val.trim());
        }
        for(string val:val2.split(';'))
        {
            if(setval.contains(val.trim()))
                return true;
        }
        return false;
    }
    public static boolean getReasonCountryConditionResult(Account act, ContentVersion ver,string accountCountry)
    {
        boolean isCountryReasonConditionTrue = false;
        set<string> setCountry = new Set<string>();
        if(ver.Country__c!=null)
            for(string st:ver.Country__c.split(';'))
                    setCountry.add(st.trim());
        set<string> setRegion = new Set<string>();
        if(ver.Region__c!=null)
            for(string st:ver.region__c.split(';'))
                    setregion.add(st.trim());
        if(ver.Region__c == null && ver.Country__c==null)
            isCountryReasonConditionTrue = true;
        if(ver.Region__c != null && setRegion.contains(act.Region__c))
            isCountryReasonConditionTrue = true;
        if(ver.Country__c != null && setCountry.contains(accountCountry))
            isCountryReasonConditionTrue = true;
        return isCountryReasonConditionTrue;
    }
    public static boolean compareContentverWithAccount(Account act, ContentVersion ver,Map<id,Set<string>> mapActProd,Region__c reg)
    {
        string accountCountry ='';
        if(reg!=null)
            accountCountry = reg.Name;
        boolean isCountryReasonConditionTrue = getReasonCountryConditionResult(act, ver,accountCountry);
        boolean isSecoreConditionTrue = false;
        set<string> setSecore = new Set<string>();
        if(ver.Customer_Segment__c!=null)
            for(string st:ver.Customer_Segment__c.split(';'))
                    setSecore.add(st.trim());
        if(ver.Customer_Segment__c == null)
            isSecoreConditionTrue = true;
        if(ver.Customer_Segment__c != null && setSecore.contains(act.Customer_Segment__c))
            isSecoreConditionTrue = true;
                         
        if( (ver.Channel__c == act.Channel__c)
            && (ver.Business_Org__c == act.Business_Org__c || ver.Business_Org__c==null)
            && (ver.Price_Schedule__c ==act.Price_Schedule__c || ver.Price_Schedule__c==null)
            && isSecoreConditionTrue
            && isCountryReasonConditionTrue 
            )
        {
             boolean chkProd = false;
             boolean chkChAtt = false;
             set<String> prodSet = mapActProd.get(act.Id);
             if(ver.Authorized_Product_Lines__c!=null)
                 chkProd = ContentUtils.isSetContainsAnyValue(prodSet,ver.Authorized_Product_Lines__c);
             else
                 chkProd = true;
             if(ver.Channel_Attributes__c!=null)
                 chkChAtt = ContentUtils.isSetContainsAnyValue(act.Channel_Attributes__c,ver.Channel_Attributes__c);
             else
                 chkChAtt= true;  
             if(chkProd && chkChAtt)
                 return true;
        }
        return false;
    }
    //--------------------------------------------------------------------------------------------------------------------
    //--------------------------------------------------------------------------------------------------------------------
    public static string createConditionString(Account act,Region__c actWithRegionCountry)
    {
        string condition =' ID != NULL ';
        if(act.Channel__c!=null)
            condition = condition+ ' AND (Channel__c = NULL OR Channel__c =\''+act.Channel__c+'\')';
        else
            condition = condition+ ' AND (Channel__c = NULL)';
        if(act.Business_Org__c!=null)
            condition = condition+ ' AND (Business_Org__c = NULL OR Business_Org__c =\''+act.Business_Org__c+'\')';
        else
            condition = condition+ ' AND (Business_Org__c = NULL)';
        if(act.Customer_Segment__c!=null)
            condition = condition+ ' AND (Customer_Segment__c = NULL OR Customer_Segment__c INCLUDES(\''+act.Customer_Segment__c+'\'))';
        else
            condition = condition+ ' AND (Customer_Segment__c = NULL)';
        if(act.Price_Schedule__c!=null)
            condition = condition+ ' AND (Price_Schedule__c = NULL OR Price_Schedule__c =\''+act.Price_Schedule__c+'\')';
        else
            condition = condition+ ' AND (Price_Schedule__c = NULL)';
        string regConString = '(Country__c = NULL AND Region__c=NULL) ';
        if(act.Country__c!=null)
            regConString = regConString + ' OR ( Country__c  INCLUDES (\''+ actWithRegionCountry.Name+'\'))';
        if(act.Region__c!=null)
            regConString = regConString + ' OR ( Region__c  INCLUDES(\''+actWithRegionCountry.Region__c+'\'))';
        regConString = '('+regConString+')';
        return '(' + condition+')';
    }
    @Future
    public static void ProcessforAccounts(Set<id> accountToOperate) 
    {
        List<Account> accountToProceed = [Select id, Channel_Attributes__c, Customer_Segment__c, Price_Schedule__c, Business_Org__c, Channel__c, Country__c, manager_Library__c,User_Library__c, Country__r.Name,Region__c,(Select Product_Line__r.PL_Code__c From Products_Authorized__r)
        									 from Account Where id in:accountToOperate];
        List<Id> lstToDeleteShare = new List<Id>();
        //set<id>accountIds = new set<id>();
        set<string>setLibId = new set<string>();
        List<string> conditionList = new List<string> ();
        set<id>CountryIds = new set<Id>();
        for(Account act : accountToProceed)
        {
            //accountIds.add(act.Id);
            if(act.Country__c!=null)
                CountryIds.add(act.Country__c);
            //if(TriggerIsUpdate)
            //    if(oldMap.get(act.Id).Country__c!=null)
            //        CountryIds.add(oldMap.get(act.Id).Country__c);
        }
        Map<id,region__c> mapregion = new Map<id,region__c>([Select Id,Name,region__c from region__c where id in :CountryIds]);
        Map<id,Set<String>> mapActProd = new Map<id,Set<String>>();
        
        for(Account act:[Select Country__r.Name,Region__c,id,(Select Product_Line__r.PL_Code__c From Products_Authorized__r) from account Where Id in:accountToOperate]) //accountIds])
        {
            Set<string> pSet = new Set<string>();
            mapActProd.put(act.Id,pSet);
            for( Authorized_Product__c ap:act.Products_Authorized__r)
                pSet.add(ap.Product_Line__r.PL_Code__c);
        }
        
        for(Account act : accountToProceed)
        {
            if(act.manager_Library__c!=null)
                setLibId.add(act.manager_Library__c);
            if(act.User_Library__c!=null)
                setLibId.add(act.User_Library__c);
            conditionList.add(createConditionString(act,mapregion.get(act.Country__c)));
            /*if(TriggerIsUpdate)
            {
                Account act1 = oldMap.get(act.Id);
                if(act1.manager_Library__c!=null)
                    setLibId.add(act1.Manager_Library__c);
                if(act1.User_Library__c!=null)
                    setLibId.add(act1.User_Library__c);
                conditionList.add(createConditionString(act1,mapregion.get(act1.Country__c)));
            }*/
         }
        map<String,String> mapWorkSpaceIdName = new map<String,String>();
        map<String,String> mapWorkSpaceNameById = new map<String,String>();
        for(ContentWorkspace content :[Select Name, Id From ContentWorkspace where Name in :setLibId])
        {
            mapWorkSpaceIdName.put(content.name , content.Id);
            string lib = content.Id;
            if(lib.Length()>15) lib= lib.SubString(0,15);
            mapWorkSpaceNameById.put(lib, content.Name);
        }
        string libCondition = '';
        //for(string libId:mapWorkSpaceNameById.keyset())
/*        for(string libId:mapWorkSpaceNameById.values())
        {
            if(libCondition =='')
                libCondition = ' (Library_Ids__c Like \'%'+libId+'%\')';
            else
                libCondition = libCondition + ' OR (Library_Ids__c Like \'%'+ libId +'%\')';
        }
*/        if(libCondition !='')
            libCondition ='(' + libCondition +')';
        for(string st:conditionList)
            if(libCondition=='')
                libCondition = st;
            else
                libCondition = libCondition + ' OR '+ st;
        if(libCondition !='')
            libCondition ='(' + libCondition +')';
            
        string soql ='Select id, Region__c, Business_Org__c,Channel__c ,User_Type__c,ContentDocumentId, Library_Ids__c '+
                      ' , Country__c,Customer_Segment__c, Price_Schedule__c, Authorized_Product_Lines__c, Channel_Attributes__c '+
                      ' from ContentVersion  where ';
        if(libCondition =='')
            soql = soql + ' Published__c = true AND IsLatest = TRUE ';
        else
            soql = soql +libCondition + ' AND Published__c = true AND IsLatest = TRUE ';
    
        system.debug('=============='+soql);
        List<ContentVersion> verLst = Database.Query(soql);                        
        
        list<ContentWorkspaceDoc> listContentWorkspaceDoc = new list<ContentWorkspaceDoc >();
        list<Id> IdToDelete = new list<Id >();
        for(ContentVersion ver:verLst)
        {
            for(Account act:accountToProceed)
            {
                if(ver.Library_Ids__c != null)
                {
                    for(string libId:ver.Library_Ids__c.split(','))
                    {
                        if(libId!=null && libId.trim()!='')
                        {
                            string lib = libId.trim();
                            //if(lib.Length()>15) lib= lib.SubString(0,15);
                            boolean breakNow = false;
                            //if(mapWorkSpaceNameById.get(lib) == act.User_Library__c)
                            if(act.User_Library__c != null&& lib.toLowerCase() == act.User_Library__c.toLowerCase())
                            {
                                ContentWorkspaceDoc wSpace = new ContentWorkspaceDoc();
                                wSpace.ContentDocumentId = ver.ContentDocumentId;
                                wSpace.ContentWorkspaceId = mapWorkSpaceIdName.get(act.User_Library__c);
                                listContentWorkspaceDoc.add(wSpace);
                                
                                system.debug('----SUMIT1---->'+ wSpace.ContentDocumentId+'=='+wSpace.ContentWorkspaceId);
                                
                                breakNow = true;
                            }
                            //if(mapWorkSpaceNameById.get(lib) == act.Manager_Library__c && act.Manager_Library__c!=act.User_Library__c)
                            if(act.Manager_Library__c!=null && lib.toLowerCase() == act.Manager_Library__c.toLowerCase() && act.Manager_Library__c!=act.User_Library__c)
                            {
                                ContentWorkspaceDoc wSpace = new ContentWorkspaceDoc();
                                wSpace.ContentDocumentId = ver.ContentDocumentId;
                                wSpace.ContentWorkspaceId = mapWorkSpaceIdName.get(act.Manager_Library__c);
                                listContentWorkspaceDoc.add(wSpace);
                                system.debug('----SUMIT2---->'+ wSpace.ContentDocumentId+'=='+wSpace.ContentWorkspaceId);
                                breakNow = true;
                            }
                            if(breakNow)break;
                        }
                    }
                }
                if(ver.Library_Ids__c == null && ContentUtils.compareContentverWithAccount(act,ver,mapActProd,mapregion.get(act.Country__c)))
                {
                    string lib = act.Manager_Library__c;
                    if(ver.User_Type__c != 'Restricted')
                        lib = act.User_Library__c;
                    if(lib!=null && mapWorkSpaceIdName.get(lib)!=null)
                    {
                        ContentWorkspaceDoc wSpace = new ContentWorkspaceDoc();
                        wSpace.ContentDocumentId = ver.ContentDocumentId;
                        wSpace.ContentWorkspaceId = mapWorkSpaceIdName.get(lib);
                        listContentWorkspaceDoc.add(wSpace);
                        system.debug('----SUMIT3---->'+ wSpace.ContentDocumentId+'=='+wSpace.ContentWorkspaceId);
                    }
                }
                /*if(TriggerIsUpdate)
                {
                    Account act1 = oldMap.get(act.Id);
                    if(ver.Library_Ids__c != null)
                    {
                        for(string libId:ver.Library_Ids__c.split(','))
                        {
                            if(libId!=null && libId.trim()!='')
                            {
                                string lib = libId.trim();
                                if(lib.Length()>15) lib= lib.SubString(0,15);
                                boolean breakNow = false;
                                if(mapWorkSpaceNameById.get(lib) == act1.User_Library__c)
                                    IdToDelete.add(mapWorkSpaceIdName.get(act1.User_Library__c));
                                if(mapWorkSpaceNameById.get(lib) == act1.Manager_Library__c)
                                    IdToDelete.add(mapWorkSpaceIdName.get(act1.Manager_Library__c));
                            }
                        }
                    }
                    if(ver.Library_Ids__c == null && ContentUtils.compareContentverWithAccount(act1,ver,mapActProd,mapregion.get(act1.Country__c)))
                    {
                        string lib = act1.Manager_Library__c;
                        if(ver.User_Type__c != 'Restricted')
                            lib = act1.User_Library__c;
                        if(lib!=null && mapWorkSpaceIdName.get(lib)!=null)
                        {
                            IdToDelete.add(mapWorkSpaceIdName.get(lib));
                        }
                    }
                }*/
            }
        }
        /*if(IdToDelete.size()>0)
        {
           for(List<ContentWorkspaceDoc> lstdel:[Select id from ContentWorkspaceDoc where ContentWorkspaceId in:IdToDelete And ISOwner = false])
               delete lstdel;
        }*/
        if(listContentWorkspaceDoc.size()>0)
        {
            Database.SaveResult[] lsr = Database.insert(listContentWorkspaceDoc,false);
            for(Database.SaveResult sr:lsr)
                if(!sr.isSuccess())
                    system.debug('------------ERROR:::------>>'+sr.getErrors()[0]);
        }
    }
}