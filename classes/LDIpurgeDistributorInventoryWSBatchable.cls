global class LDIpurgeDistributorInventoryWSBatchable implements Database.Batchable<sObject> {
	public String query;
	public List<Distributor_Inventory__c> invtoupload;
	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	system.debug(query);
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
      delete scope;
      DataBase.emptyRecycleBin(scope);
   }

   global void finish(Database.BatchableContext BC){
   	if (invtoupload != null){
   		system.debug('invtoupload.size: ' + invtoupload.size());
	  insert invtoupload;}
	  
	  AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
      FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
      system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> a.Status: ' + a.Status);
   }
}