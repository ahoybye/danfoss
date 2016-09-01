@isTest
public class Test_AccountMerge {

    static testmethod void testMerge() {            
        string recordtypeId = [SELECT id from RecordType where DeveloperName ='PROSPECT_CE' AND SobjectType='Account'].Id;        
        
        User testUser;
        Id profileId = userInfo.getProfileId(); // using current users profile instead of hard-coded value (profile shouldn't matter)
        //Id profileId = [SELECT Id FROM Profile WHERE Name='CRM Standard User (CE)'].Id;

        
        System.runAs(new User(Id = Userinfo.getUserId())) {       
            // Important: Business Org must be 'Climate and Energy' because of account validation rule: CSC_CANNOT_ASSIGN_OWNERSHIP_OUTSIDE_CE
            testUser = new User(Business_Org__c='Climate and Energy', Alias = '18F.AM', Email='TESTER.ACCOUNTMERGER@DANFOSS.TEST.COM',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='TESTER.ACCOUNTMERGER@DANFOSS.TEST.COM');                                         
            insert  testUser;
        }

        System.runAs(testUser) { //ensure account records are created with CE user as owner ('Climate and Energy' as Business Org)
            List<Schema.FieldSetMember> schemaset= SObjectType.Account.FieldSets.Merge_System_Id_Fields.getFields();
             Account a1= new Account();  
             a1.Name='My Master Account 1';
            a1.recordTypeId =  recordtypeId;
            a1.Business_Org__c = 'Climate and Energy';
            a1.Siebell__c = 'wew1';
            a1.P16__c = 'ABC';
            a1.P02_Account__c = 'ABC44';
            a1.Turbocor__c = 'EWEW';
            a1.Goldmine__c = '121qwea';
            a1.PCM__c = 'sadasrew';
            a1.Kompas__c= 'vsdfsd';
            insert a1; 
               
            Account a2 = new Account();
            a2.Name='My Duplicate Account 2';
            a2.recordTypeId =  recordtypeId;            
            a2.Business_Org__c = 'Climate and Energy';
            a2.Siebell__c = 'wewasdsa1';
            a2.P16__c = 'AdasBC';
            a2.P02_Account__c = 'ABCadas44';
            a2.Turbocor__c = 'EWadasEW';
            a2.Goldmine__c = '121adaqwea';
            a2.PCM__c = 'saadadasrew';
            a2.Kompas__c= 'vsdadafsd';

            insert a2;
            
            Account_Merge_Request__c amr = new Account_Merge_Request__c();
            amr.master_account__c=a1.Id;
            amr.merged_account__c=a2.id;
            insert amr;
        }       
        
        Integer i = [SELECT COUNT() FROM Account];
        System.assertEquals(i, 2);
        
        i = [SELECT COUNT() FROM Account_Merge_Request__c where Request_processed__c = FALSE];
        System.assertEquals(i, 1);
        
        
        Test.startTest();
        
        //Database.executeBatch(new ContactMergeRequestBatch(), 30);
        AccountMergeRequestBatch amrb = new AccountMergeRequestBatch(); 
        Database.executebatch(amrb);
        //merge a1 a2.id;
        
        Test.stopTest();
        
        i = [SELECT COUNT() FROM Account];
        System.assertEquals(i, 1);
        
        i = [SELECT COUNT() FROM Account_Merge_Request__c where Request_processed__c = TRUE];
        System.assertEquals(i, 1);
        
    }   

}