public class AccountMergeRunController {
	private final Account_Merge_Request__c AMR;
    
    public AccountMergeRunController(ApexPages.StandardController controller) 
    {        
        controller.addFields(new List<String> {'Master_Account__c', 'Merged_Account__c', 'Master_Account__r.recordtype.developername'});
        this.AMR = (Account_Merge_Request__c)controller.getRecord();
    }
    
    public void runBatch() {
    	//AccountMergeRequestBatch batch = new AccountMergeRequestBatch();
    	//database.executeBatch(batch);
        if (AMR.Master_Account__c != AMR.Merged_Account__c) {
            try {
    			Account master = new Account(Id=AMR.Master_Account__c);
    			AccountMergeRequestBatch.doMerge(master, AMR.Merged_Account__c, AMR.Master_Account__r.recordtype.developername);            

            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Accounts successfully merged'));            
            } catch (exception ex) {
                ApexPages.addmessages(ex);
            }
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Merge not possible - must be two different accounts'));                        
        }          
	}
}