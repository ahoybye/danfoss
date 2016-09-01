global class PublishOnEffectiveDateBatchable implements Database.Batchable<sObject>
{
   global Database.QueryLocator start(Database.BatchableContext BC)
   {
      return Database.getQueryLocator('Select Id, Published__c,Title from ContentVersion Where Effective_Date__c<=TODAY AND (Expiry_Date__c =null OR Expiry_Date__c >=TODAY) AND Published__c=False AND Effective_Date__c <> null  AND IsLatest = TRUE');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope)
   {
     for(sobject s : scope)
     {
         s.put('Published__c',true); 
     }
     update scope;
   }

   global void finish(Database.BatchableContext BC)
   {

   }
}