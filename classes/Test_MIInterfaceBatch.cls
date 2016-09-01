@isTest
public class Test_MIInterfaceBatch {


	static testmethod void testMIInterface() {	        
	        
            Account a = new Account();
            a.Name='My Account';            
        	a.Business_Org__c='Climate and Energy';
        	a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer (CE)').getRecordTypeId();
            insert a;
        
        	Sub_Account__c sa = new Sub_Account__c();
        	sa.name='Sub Account';
        	sa.Account__c=a.Id;
        	insert sa;
        
        	//a.Master_Sub_Account__c = sa.Id;
			//update a;
        
        	Integer i = [SELECT COUNT() FROM Account];
            System.assertEquals(i, 1);
        
        	Test.startTest();                                
			
        	// Schedule the test job
        	MIInterfaceBatch.Schedule_MIInterfaceBatch_Job('0 0 * * * ?', 'TEST BI JOB (MIINterface)');
        	//String CRON_EXP = '0 0 0 15 3 ? 2022';
			//String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP, MIInterfaceBatch());
        
            MIInterfaceBatch MIIBatch1 = new MIInterfaceBatch(7, 'ACCOUNT');
            ID batchprocessid1 = Database.executeBatch(MIIBatch1,200);
            
            MIInterfaceBatch MIIBatch2 = new MIInterfaceBatch(7, 'MARKETINGATTRIB');
            ID batchprocessid2 = Database.executeBatch(MIIBatch2,200);
            
            MIInterfaceBatch MIIBatch3 = new MIInterfaceBatch(7, 'ACCOUNTTEAM');
            ID batchprocessid3 = Database.executeBatch(MIIBatch3,200);

	        Test.stopTest();
        
        	i = [SELECT COUNT() FROM MIInterfaceBatchSchedule__c where AccountID__c = :a.Id];
            System.assertEquals(i, 1);
        	
	}	

}