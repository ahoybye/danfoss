global without sharing class LDIpurgeDistributorInventoryWebService {
	
    webService static Boolean purgeInventory(String acctId) {
    	DateTime dt = datetime.now().addMinutes(-5);    	
    	String myDtString = String.valueofgmt(dt).replaceFirst(' ', 'T');
System.debug('&*&*&*&*&***&*&*&*&*&*&*&**&**&**&**&**&*&&**& DATE: ' + myDtString); 
    	LDIpurgeDistributorInventoryWSBatchable batchToDelete = new LDIpurgeDistributorInventoryWSBatchable();
    	//batchToDelete.query = 'SELECT Account__c FROM Distributor_Inventory__c WHERE Account__c IN (SELECT  Id FROM Account WHERE SAP_Account_ID__c = \'' + acctId + '\')'; 
		batchToDelete.query = 'SELECT Account__c FROM Distributor_Inventory__c WHERE Account__c IN (SELECT  Id FROM Account WHERE SAP_Account_ID__c = \'' + acctId + '\') AND LastModifiedDate < ' + myDtString + 'Z';
		ID batchprocessid = Database.executeBatch(batchToDelete);
		System.debug('Returned batch process ID: ' + batchProcessId); 
 /*       boolean err = false;
       // Set<string> setActId = new Set<string>();
        List<Distributor_Inventory__c> lstDistToDelete = new List<Distributor_Inventory__c>();
       // List<Account> lstAccounts = [SELECT Id, SAP_Account_ID__c FROM Account WHERE SAP_Account_ID__c = :acctId];
        //for (Account act:lstAccounts)
         //   setActId.add(act.Id);
        for (Distributor_Inventory__c dist : [SELECT Account__c FROM Distributor_Inventory__c WHERE Account__c IN (SELECT  Id FROM Account WHERE SAP_Account_ID__c = :acctId)]) //[SELECT Account__c FROM Distributor_Inventory__c WHERE Account__c IN : setActId])
        {
        	lstDistToDelete.add(dist);
        }
        try{
            delete lstDistToDelete1;
        } catch (System.DmlException e) {
            //update our err flag
            err = true;
            System.debug('error bulk inserting new candidate record');
            for (Integer k = 0; k < e.getNumDml(); k++) {
                // Process exception here
                System.debug(e.getDmlMessage(k));
            }
        }
                
        // check for errors and return the success flag
        if (!err) {
            return true;
        } else {
        //  further error handling here
            return false;
        }   
  		string wsStatus = '';
  		AsyncApexJob a = new AsyncApexJob();
  		do {
  			a = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :batchprocessid]; 
      		wsStatus = a.Status;
      		system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> a.Status: ' + a.Status);
  		} while (wsStatus != 'Completed');*/
  	        return true; 
    }
    
    webService static Boolean purgeInventoryNotSAP(String acctId, List<Distributor_Inventory__c> invtoupload) {
    	LDIpurgeDistributorInventoryWSBatchable batchToDelete = new LDIpurgeDistributorInventoryWSBatchable();
    	batchToDelete.query = 'SELECT Account__c FROM Distributor_Inventory__c WHERE Account__c IN (SELECT  Id FROM Account WHERE SAP_Account_ID__c = \'' + acctId + '\')';  // AND CreatedDate < ' + myDtString;
		batchToDelete.invtoupload = invtoupload;
		ID batchprocessid = Database.executeBatch(batchToDelete);
		System.debug('Returned batch process ID: ' + batchProcessId); 
		
  		return true;
    }
}