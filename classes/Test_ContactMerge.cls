@isTest
public class Test_ContactMerge {

    static testmethod void testMerge() {            
            
            Account a = new Account();
            a.Name='My Account';            
            insert a;                        
            
            Contact masterCon = new contact();
            masterCon.LastName = 'Original';
            masterCon.FirstName = 'My';
            masterCon.Email = 'my.original@dummy.org';
            masterCon.AccountId = a.Id;
            insert masterCon;
            
            Contact mergeCon = new contact();
            mergeCon.LastName = 'Duplicate';
            mergeCon.FirstName = 'My';
            mergeCon.Email = 'my.duplicate@dummy.org';
            mergeCon.AccountId = a.Id;
            insert mergeCon;
            
            Contact_Merge_Request__c cmr = new Contact_Merge_Request__c();
            cmr.master_contact__c=masterCon.Id;
            cmr.merged_contact__c=mergeCon.id;
            insert cmr;

            Integer i = [SELECT COUNT() FROM Contact];
            System.assertEquals(i, 2);
        
            i = [SELECT COUNT() FROM Contact_Merge_Request__c where Request_processed__c = FALSE];
            System.assertEquals(i, 1);
        
            Test.startTest();                                
            //Database.executeBatch(new ContactMergeRequestBatch(), 30);
            ContactMergeRequestBatch cmrb = new ContactMergeRequestBatch(); 
            Database.executebatch(cmrb);
            Test.stopTest();
        
            i = [SELECT COUNT() FROM Contact];
            System.assertEquals(i, 1);
        
            i = [SELECT COUNT() FROM Contact_Merge_Request__c where Request_processed__c = TRUE];
            System.assertEquals(i, 1);
            
    }   
}