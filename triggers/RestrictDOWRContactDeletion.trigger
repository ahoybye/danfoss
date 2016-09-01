/******************************************************************************************************************
Created By    :    Sumit(Appirio)
Date          :    11/9/2011
Reason        :    Restrict deletion of contacts which are refereed in DOW Report custom setting
********************************************************************************************************************/
trigger RestrictDOWRContactDeletion on Contact (before Delete) 
{
     Map<String, DOW_Report_Setting__c> dowReportMap = DOW_Report_Setting__c.getAll();
     Set<string> contactIds = new Set<string>();
     for(DOW_Report_Setting__c rep:dowReportMap.values())
         if(rep.Email_To_Contact__c!=null)
         {
             contactIds.add(rep.Email_To_Contact__c);
         }
     for(Contact con:trigger.Old)
     {
         string conId = con.id;
         boolean isError = false;
         for(string str:contactIds)
             if(str.indexof(con.Id)>=0 || conId.indexof(str)>=0)
                 isError = true;
         if(isError)
             con.addError('Contact is referred in DOW Report settings. Please remove it from setting first.');
     }
}