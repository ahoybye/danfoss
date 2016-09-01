global class CaseHandlerFuture
{
/*Description: This apex method is executed in the Case:After Insert scenerio. 
                 The code in the apex class is used to udpate the Contact,Account,Case Origin fields.
                 
                 Fax number in available in the Case subject, is queried on Fax field of Contacts and contact result is added to Case. */
                 
    @future(callout=true)
    public static void assignContactFromFax(set<Id> CaseIds)
    {   
         //Map collection to hold case Id and Fax number   
      List<Case> insCases = [Select Id,subject From Case Where ID IN:CaseIds ]; 
      Map<Id,String> caseFaxFormat = new Map<Id,String>();
      set<String> caseFaxNo = new set<String>();
      Map<String, List<Contact>> conMap = new Map<String, List<Contact>>();
      List<Case> conList = new List<Case>();
      
    //Split the case-subject to get the Fax Number and build the map
      for(Case C:insCases){
      If(C.Subject!=null){
        If(C.Subject.containsIgnoreCase('fax from')){
          List<String> splitSubject = C.Subject.split('\'');
          string str = splitSubject[1].deleteWhitespace();
          str=str.remove('(');
          str=str.remove(')');
          caseFaxFormat.put(C.Id,str);
          caseFaxNo.add(str);
        }
       } 
      }
    //End of for loop
    
    //Query the Contact records with the matching Fax Number and add them to map
    List<Contact> conQryList = [Select Id,AccountId,Fax From Contact where Fax != null and Fax IN :caseFaxNo and Account.Business_Org__c='Climate and Energy' limit 100000];
    for(Contact con : conQryList ){
      if(conMap.containsKey(con.Fax)) {
         List<Contact> Cons = conMap.get(con.Fax);
         Cons.add(con);
         conMap.put(con.Fax, Cons);
      }
      else
      conMap.put(con.Fax, new List<Contact> {con});
      
    }

    //Process the Fax map and assign the Contact & Account Lookup Fields in Case
    for(Case C:insCases){
    List<Contact> noOfContacts;
    Case cp = new Case(id=C.Id);
    If(conMap.get(caseFaxFormat.get(C.Id)) != null)
     noOfContacts = conMap.get(caseFaxFormat.get(C.Id));
    Else 
     noOfContacts = new List<Contact>();
    
     //process single search results
     // No search results aren't handled
    If(C.Subject!=null){
    If(C.Subject.containsIgnoreCase('fax from'))
    cp.Origin = 'Fax';
    
    If(!noOfContacts.isEmpty()){
     If(noOfContacts.size()==1){
     //Single mtach scenerio
     cp.ContactId = noOfContacts[0].Id;
     cp.AccountId= noOfContacts[0].AccountId;
     }
     Else If(noOfContacts.size()>1){
      //Check the multi-match scenerio
       set<Id> AccIds = new set<Id>();
        for(Contact Con:noOfContacts)
         If(Con.AccountId!=Null)
         AccIds.add(Con.AccountId);
       If(AccIds.size()==1)   
       cp.AccountId= noOfContacts[0].AccountId;
        
     }
    }
    conList.add(cp);
    }
   }     
   If(!conList.isEmpty()) 
     update conList;
  }
  //End of method
    
 
}