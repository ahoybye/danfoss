@istest
private class Test_PublishandUnpublish{
	  static testMethod void myUnitTest() {
        PublishOnEffectiveDateBatchable b = new PublishOnEffectiveDateBatchable();          
		Id batchProcessId = database.executebatch(b); 
        UnPublishOnExpiryDateBatchable u = new UnPublishOnExpiryDateBatchable();          
		batchProcessId = database.executebatch(u);
        PublishOnEffectiveDateSchedulable  sco = new PublishOnEffectiveDateSchedulable ();        
        String sch = '0 0 23 * * ?';        
        system.schedule('x', sch, sco);
          
        UnPublishOnExpiryDateSchedulable sco1 = new UnPublishOnExpiryDateSchedulable();        
        system.schedule('y', sch, sco1);
      }
}