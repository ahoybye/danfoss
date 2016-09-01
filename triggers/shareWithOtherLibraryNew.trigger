/*********************************************************************************************************************
Created By     :    Sumit Mishra(Appirio)
Date           :    2 Aug 2012
Last Modify    :    9 Aug 2012
Reason         :    This trigger fires when contentversion update. 
                    It picks all accounts where attributes match and then share document with these
*********************************************************************************************************************/

trigger shareWithOtherLibraryNew on ContentVersion (after update,before update) 
{
    if(trigger.IsBefore)
    {
        set<ID> setPublicLibraryIDs = new Set<ID>();
        Set<ID> documentIds = new Set<ID>();
        set<ID> marketingLiteratureDocuments = new Set<ID>();
        for(ContentWorkspace workspace : [Select ID from ContentWorkspace Where Name IN ('*PS Public Content', '*CM_Marketing', '*PS - Product Information Bulletins (PIB)')]){
            setPublicLibraryIDs.add(workspace.Id);
        }       
        if(setPublicLibraryIDs.size() > 0){
            for(ContentVersion ver : trigger.new){
                	documentIds.add(ver.ContentDocumentId);
            }           
            for(ContentWorkspaceDoc workspace : [Select Id,ContentDocumentId From ContentWorkspaceDoc
                                                 Where ContentDocumentId IN :documentIds AND ContentWorkspaceId IN :setPublicLibraryIDs]){
                marketingLiteratureDocuments.add(workspace.ContentDocumentId);  
            }
        }
        //Set published checkbox depends if today is between effective and expiry date
        for(ContentVersion ver : trigger.new)
        { System.debug('ver.Business_Org__c: '+ver.Business_Org__c);
			if (ver.Business_Org__c == null || ver.Business_Org__c == '')
				break;
            boolean proceed =true;
            if(ver.Effective_Date__c!=null && ver.Effective_Date__c > Date.Today())
               proceed =false;
            if(ver.Expiry_Date__c!=null && ver.Expiry_Date__c < Date.Today())
               proceed =false;
            ver.Published__c = proceed ;
            if(ver.Channel__c == null && ver.Library_Ids__c==null)
                ver.Published__c = false;
            if(marketingLiteratureDocuments.contains(ver.ContentDocumentId)){
                ver.Published__c = false;
            }
                            
        }
    }
    else //Trigger.isAfter
    {
        Set<string> setLibId = new Set<string>();
        List<string> conditionList = new List<string> ();
        List<ContentVersion> lstToShareusingAccount = new List<ContentVersion>();
        List<ContentVersion> lstToShareUsingLibrary = new List<ContentVersion>();
        List<Id> lstToDeleteShare = new List<Id>();
        for(ContentVersion ver : trigger.new)
        {
			if (ver.Business_Org__c == null || ver.Business_Org__c == '')
				break;
            boolean doBoth = false;
            if(ver.Published__c && trigger.OldMap.get(ver.Id).Published__c && ( 
                ver.Channel__c != trigger.OldMap.get(ver.Id).Channel__c 
                || ver.Business_Org__c != trigger.OldMap.get(ver.Id).Business_Org__c
                || ver.Library_IDs__c != trigger.OldMap.get(ver.Id).Library_IDs__c
                || ver.User_Type__c != trigger.OldMap.get(ver.Id).User_Type__c
                || ver.Country__c != trigger.OldMap.get(ver.Id).Country__c
                || ver.Customer_Segment__c != trigger.OldMap.get(ver.Id).Customer_Segment__c
                || ver.Price_Schedule__c != trigger.OldMap.get(ver.Id).Price_Schedule__c
                || ver.Channel_Attributes__c != trigger.OldMap.get(ver.Id).Channel_Attributes__c
                || ver.Authorized_Product_Lines__c != trigger.OldMap.get(ver.Id).Authorized_Product_Lines__c
                || ver.Region__c != trigger.OldMap.get(ver.Id).Region__c
                )) 
                {
                    doBoth = true;
					System.debug('ver: ' + ver);
                }
            if(doBoth || ver.Published__c && !trigger.OldMap.get(ver.Id).Published__c)
            {
                if(ver.Library_Ids__c!=null)
                {
                    for(string libId:ver.Library_Ids__c.split(','))
                        if(libId!=null && libId.trim()!='')
                            setLibId.add(libId.trim());
                    lstToShareUsingLibrary.add(ver); 
                }
                if(ver.Library_Ids__c == null)
                {
                    string condition = ''; //' ID != NULL ';
                    if(ver.Channel__c!=null)
                        condition = condition +' AND Channel__c = \'' + ver.Channel__c +'\'';
                    if(ver.Business_Org__c!=null)
                        condition = condition +' AND Business_Org__c = \'' + ver.Business_Org__c +'\'';
                    if(ver.Price_Schedule__c!=null)
                        condition = condition +' AND Price_Schedule__c = \'' + ver.Price_Schedule__c +'\'';
                    if(ver.Customer_Segment__c!=null)
                    {
                        string Cond='';
                        if(ver.Customer_Segment__c!=null)
                        {
                            for(string st:ver.Customer_Segment__c.split(';'))
                                if(Cond == '')
                                    Cond = '\''+st.trim()+'\'';
                                else
                                    Cond = Cond+ ',\''+st.trim()+'\'';
                        }
                        if(Cond!='')
                            condition = condition +' AND Customer_Segment__c IN (' + Cond +') ';
                    }
                        
                    if(ver.Country__c!=null || ver.Region__c!=null)
                    {
                        string contryCond='';
                        if(ver.Country__c!=null)
                        {
                            for(string st:ver.Country__c.split(';'))
                                if(contryCond == '')
                                    contryCond = '\''+st.trim()+'\'';
                                else
                                    contryCond = contryCond+ ',\''+st.trim()+'\'';
                        }
                        string regionCond='';
                        if(ver.Region__c!=null)
                        {
                            for(string st:ver.Region__c.split(';'))
                                if(regionCond == '')
                                    regionCond = '\''+st.trim()+'\'';
                                else
                                    regionCond = regionCond+ ',\''+st.trim()+'\'';
                        }
                        if(contryCond!='' && regionCond!='')
                            condition = condition +' AND ( Country__r.Name IN (' + contryCond +') OR Region__c  IN (' + regionCond +') )';
                        else if( contryCond!='')
                            condition = condition +' AND Country__r.Name IN (' + contryCond +') ';
                        else if(regionCond!=null)
                            condition = condition +' AND Region__c IN (' + regionCond +') ';
                    }
					condition =condition.replaceFirst(' AND ', '') ;
                    condition ='(' + condition +')';
					system.debug('condition: ' + condition);
                    conditionList.add(condition);
                    lstToShareUsingAccount.add(ver);
                }
            }
					system.debug('conditionList: ' + conditionList);
            if(doBoth || !ver.Published__c && trigger.OldMap.get(ver.Id).Published__c)
            {
                lstToDeleteShare.add(ver.ContentDocumentId);
            }
        }
        //end loop through content record(s)
        system.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~lstToDeleteShare.size: ' + lstToDeleteShare.size());
        if(lstToDeleteShare.size()>0)
            for(List<ContentWorkspaceDoc> lstdel:[Select id from ContentWorkspaceDoc where ContentDocumentId in:lstToDeleteShare And ISOwner = false])
                delete lstdel;
        //loop through list of content to be shared based on value in Library_Ids__c field
        list<ContentWorkspaceDoc> listContentWorkspaceDoc = new list<ContentWorkspaceDoc >();
        if(lstToShareUsingLibrary.size()>0)
        {
            map<String,String> mapWorkSpaceIdName = new map<String,String>();
            
            for(ContentWorkspace content :[Select Name, Id From ContentWorkspace where Name in :setLibId])
            {
                string cId = content.Id;
                mapWorkSpaceIdName.put(content.Name.toLowerCase(),cId);
            }
            for(ContentVersion ver : lstToShareUsingLibrary)
            {
                set<string> contIds = new set<string>();
                if(ver.Library_IDs__c!=null)
                {
                    for(string libId:ver.Library_IDs__c.split(','))
                    {
                        if(libId!=null && libId.trim()!='')
                        {
                            string lib = libId.trim();
                            //if(lib.Length()>15) lib= lib.SubString(0,15);
                            //if(mapWorkSpaceIdName.get(lib)!=null && !contIds.contains(lib))
                            if(lib != null && !contIds.contains(lib.toLowerCase()) && mapWorkSpaceIdName.get(lib.toLowerCase())!=null)
                            {
                                ContentWorkspaceDoc wSpace = new ContentWorkspaceDoc();
                                wSpace.ContentDocumentId = ver.ContentDocumentId;
                                //wSpace.ContentWorkspaceId =lib.trim();
                                wSpace.ContentWorkspaceId = mapWorkSpaceIdName.get(lib.toLowerCase());
                                //contIds.add(lib);
                                contIds.add(lib.toLowerCase());
                                listContentWorkspaceDoc.add(wSpace);
                            }
                        }
                    }
                }
            }            
        }
        
        //loop through list of content to be shared based on matching Account attributes
        set<Id> libIdSetToInsert = new set<Id>();
        set<Id> ContentIdSetToInsert = new set<Id>();
        set<string> mergeIdSetToInsert = new set<String>();        
        if(lstToShareUsingAccount.size()>0)
		{System.debug('lstToShareUsingAccount: ' + lstToShareUsingAccount);
            //Need dynamic soql because of so so many dependencies
            string SOQL = 'Select Id, Name, Business_Org__c,Channel__c, Country__r.Name ,Country__c,Region__c, Channel_Attributes__c, '+
            ' Customer_Segment__c, Price_Schedule__c, Manager_Library__c, User_Library__c, '+
            ' (Select Product_Line__r.PL_Code__c From Products_Authorized__r) '+
            ' from Account ';
            string whereOR = ' WHERE (';
            string AtEndBracket = ''; 
            for(string st:conditionList)
            {System.debug('st: ' + st);
                soql=soql + whereOR +st;
                whereOR  = ' OR ';
                AtEndBracket= ')';
            }
            soql=soql +AtEndBracket;
			System.debug('soql: ' + soql);
            List<Account> actLst = Database.query(soql);
            map<String,String> mapWorkSpaceIdName = new map<String,String>();
            Set<string> lstWSNamesToLoad = new Set<string>();
            for(Account act:actLst)
            {
                if(act.User_Library__c!=null)
                    lstWSNamesToLoad.add(act.User_Library__c);
                if(act.Manager_Library__c!=null)
                    lstWSNamesToLoad.add(act.Manager_Library__c);
            }
            
            for(ContentWorkspace content :[Select Name, Id From ContentWorkspace where Name in :lstWSNamesToLoad]){
                mapWorkSpaceIdName.put(content.name , content.Id);
            	system.debug('content: ~' + content.Id + '~' + content.name);
            }
            for(Account act:actLst)
            {
                Set<string> pSet = new Set<string>();
                for( Authorized_Product__c ap:act.Products_Authorized__r)
                    pSet.add(ap.Product_Line__r.PL_Code__c);
                for(ContentVersion ver : lstToShareUsingAccount)
                {
                    boolean matchFound = false;
                    boolean isSecoreConditionTrue = false;
                    set<string> setSecore = new Set<string>();
                    if(ver.Customer_Segment__c!=null)
                        for(string st:ver.Customer_Segment__c.split(';'))
                                setSecore.add(st.trim());
                    boolean isCountryReasonConditionTrue = ContentUtils.getReasonCountryConditionResult(act, ver,act.Country__r.Name);
                    if(ver.Customer_Segment__c == null)
                        isSecoreConditionTrue = true;
                    if(ver.Customer_Segment__c != null && setSecore.contains(act.Customer_Segment__c))
                        isSecoreConditionTrue = true;       
                    if((ver.Business_Org__c ==null ||(ver.Business_Org__c == act.Business_Org__c))
                        && (ver.Channel__c ==null ||(ver.Channel__c == act.Channel__c))
                        && (ver.Price_Schedule__c ==null ||(ver.Price_Schedule__c == act.Price_Schedule__c))
                        && isCountryReasonConditionTrue 
                        && isSecoreConditionTrue)
                    {
                        boolean chkProd = false;
                        boolean chkChAtt = false;
                        if(ver.Authorized_Product_Lines__c!=null)
                            chkProd = ContentUtils.isSetContainsAnyValue(pSet,ver.Authorized_Product_Lines__c);
                        else
                            chkProd = true;
                        if(ver.Channel_Attributes__c!=null)
                            chkChAtt = ContentUtils.isSetContainsAnyValue(act.Channel_Attributes__c,ver.Channel_Attributes__c);
                        else
                            chkChAtt= true;  
                        if(chkProd && chkChAtt)
                            matchFound = true;
                    }
                    //this content record's attributes match this account record's attributes - matchFound
                    if(matchFound)
                    {   //User_Type__c on content record determines with which library of this account record to share this content record
                        string lib = act.User_Library__c;
                        if(ver.User_Type__c=='Restricted')
                            lib = act.manager_Library__c;
                        if(lib!=null && lib!='')
                        {
                            if(mapWorkSpaceIdName.get(lib)!=null)
                            {
                                ContentWorkspaceDoc wSpace = new ContentWorkspaceDoc();
                                wSpace.ContentDocumentId = ver.ContentDocumentId;
                                wSpace.ContentWorkspaceId = mapWorkSpaceIdName.get(lib);
                                if(!mergeIdSetToInsert.contains(wSpace.ContentWorkspaceId+'-'+wSpace.ContentDocumentId))
                                    listContentWorkspaceDoc.add(wSpace);
                                ContentIdSetToInsert.add(wSpace.ContentWorkspaceId);
                                LibIdSetToInsert.add(wSpace.ContentDocumentId);
                                mergeIdSetToInsert.add(wSpace.ContentWorkspaceId+'-'+wSpace.ContentDocumentId); 
                            }
                        }
                    }
                }
            }
        }
        //now we have the list of content records for which to create new shares
        if(listContentWorkspaceDoc.size()>0)
        {
            List<ContentWorkspaceDoc> finalSetToInsert = new List<ContentWorkspaceDoc>();
            mergeIdSetToInsert.clear();
            for(ContentWorkspaceDoc wSpace:[Select ContentWorkspaceId,ContentDocumentId from ContentWorkspaceDoc  
                                        where ContentWorkspaceId in:ContentIdSetToInsert AND ContentDocumentId in:LibIdSetToInsert])
            {
                mergeIdSetToInsert.add(wSpace.ContentWorkspaceId+'-'+wSpace.ContentDocumentId); 
            }
            for(ContentWorkspaceDoc wSpace:listContentWorkspaceDoc)
            {
                string st=wSpace.ContentWorkspaceId+'-'+wSpace.ContentDocumentId;                
                if(!mergeIdSetToInsert.contains(st))
                {
                    finalSetToInsert.add(wSpace);
                    mergeIdSetToInsert.add(st);
                }
            }
            if(finalSetToInsert.size()>0)
                insert listContentWorkspaceDoc;
        }   
    }
}