global class UnPublishOnExpiryDateBatchable implements Database.Batchable<sObject>
{
   global Database.QueryLocator start(Database.BatchableContext BC)
   {
      return Database.getQueryLocator('Select Id, Published__c from ContentVersion Where Expiry_Date__c<TODAY AND Published__c=True AND Expiry_Date__c <> null AND IsLatest = TRUE');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope)
   {
     for(sobject s : scope)
     {
         s.put('Published__c',false); 
     }
     update scope;
   }

   global void finish(Database.BatchableContext BC)
   {

   }
}