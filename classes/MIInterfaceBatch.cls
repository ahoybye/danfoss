global class MIInterfaceBatch implements Database.Batchable<sObject>,Schedulable { 
    String query;
     /* 
		2015.08.24	(AHO)	Recordtype added to WHERE clause - only selecting type CUSTOMER_CE
		2015.08.24	(AHO)	Error handling (catch) added to ignore competing inserts/upserts
	*/
    
    public static String sched = '0 0 * * * ?';  //Every Day at Midnight
    //Every Wednesday as 2 am:  0 0 2 ? * 4

    global static String Schedule_MIInterfaceBatch_Job(string customSchedule, string jobName) {
        MIInterfaceBatch SC = new MIInterfaceBatch(0,''); 
        if (jobName=='' || jobName==null) {
            jobName='Scheduled MIInterfaceBatch';
        }
        return System.schedule(jobName, customSchedule, SC);
    }
    
    global void execute(SchedulableContext ctx) {
        MIInterfaceBatch MIIBatch1 = new MIInterfaceBatch(8, 'ACCOUNT');
        ID batchprocessid1 = Database.executeBatch(MIIBatch1,200);
        
        MIInterfaceBatch MIIBatch2 = new MIInterfaceBatch(8, 'MARKETINGATTRIB');
        ID batchprocessid2 = Database.executeBatch(MIIBatch2,200);
        
        MIInterfaceBatch MIIBatch3 = new MIInterfaceBatch(8, 'ACCOUNTTEAM');
        ID batchprocessid3 = Database.executeBatch(MIIBatch3,200);
   }
    
    global MIInterfaceBatch(integer last_n_days, string type) {
        system.debug('Initializing MIInterfaceBatch');
        if (type.equals('ACCOUNT')) 
        {
            query = 'SELECT ID FROM Account WHERE LastModifiedDate=LAST_N_DAYS:' + last_n_days + ' AND ID IN (SELECT account__c FROM Sub_Account__c WHERE account__c!=null) AND RecordType.DeveloperName=\'Customer_CE\'';
        } else if (type.equals('MARKETINGATTRIB')) 
        {
            query = 'SELECT Id FROM Account WHERE ID IN (SELECT account__c FROM Sub_Account__c WHERE account__c!=null) AND ID IN (SELECT Account__c FROM Account_Division_Data__c WHERE Account_Division_Data_Config__r.ID__c IN (\'RC/CC Attribute 2\', \'RC/CC Attribute 4\', \'COMPANY_MC Account Classification (PE)\', \'COMPANY_MC ABC Classification (PE)\') AND LastModifiedDate=LAST_N_DAYS:' + last_n_days + ')  AND RecordType.DeveloperName=\'Customer_CE\'';
        } else if (type.equals('ACCOUNTTEAM')) 
        {
            query = 'SELECT Id FROM Account WHERE ID IN (SELECT account__c FROM Sub_Account__c WHERE account__c!=null) and ID IN (SELECT AccountId FROM AccountTeamMember WHERE TeamMemberRole = \'DDS: Employee Responsible\' AND LastModifiedDate=LAST_N_DAYS:' + last_n_days + ')  AND RecordType.DeveloperName=\'Customer_CE\'';
        }
        /*
        List<Account> accountTeamChanges =  [SELECT Id FROM Account WHERE ID IN (SELECT account__c FROM Sub_Account__c WHERE account__c!=null) and ID IN (SELECT AccountId FROM AccountTeamMember WHERE TeamMemberRole = 'DDS: Employee Responsible' AND LastModifiedDate=LAST_N_DAYS:7)];
        List<Account> marketingAttributeChanges =  [SELECT Id FROM Account WHERE ID IN (SELECT account__c FROM Sub_Account__c WHERE account__c!=null) AND ID IN (SELECT Account__c FROM Account_Division_Data__c WHERE Account_Division_Data_Config__r.ID__c IN ('RC/CC Attribute 2', 'RC/CC Attribute 4', 'COMPANY_MC Account Classification (PE)', 'COMPANY_MC ABC Classification (PE)') AND LastModifiedDate=LAST_N_DAYS:7)];
        List<Account> accountChanges =  [SELECT ID FROM Account WHERE LastModifiedDate=LAST_N_DAYS:7 AND ID IN (SELECT account__c FROM Sub_Account__c WHERE account__c!=null)];
        */        
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Account> scope){
        Map<String, MIInterfaceBatchSchedule__c> changeBatch = new Map<String, MIInterfaceBatchSchedule__c>();
        
        
        for ( Account a : scope) {
           MIInterfaceBatchSchedule__c mb = new MIInterfaceBatchSchedule__c(AccountID__c=a.ID, Status__c='Initiated');
           changeBatch.put(a.ID, mb);
        }               
       
        // Update using external key
        //Schema.SObjectField f = MIInterfaceBatchSchedule__c.Fields.AccountID__c;
        //Database.UpsertResult [] cr = Database.upsert(changeBatch, f, false);
        try 
        {
        	UPSERT changeBatch.values() AccountID__c;
        } 
        catch (DMLException ex)
        { 
            // Can be caused by competing INSERTS/UPSERTS - ignore
        }

    }
    
    global void finish(Database.BatchableContext BC){}
}