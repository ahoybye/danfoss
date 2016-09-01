@isTest(seeAllData = False)
private class Test_CaseTriggerHandler {
    static User pUser;
    static User cUser;
    static Id caseRecordTypeId = [select Id from RecordType where SobjectType = 'Case' and Name = 'Pricing'].Id;
    static testMethod void myUnitTest() {
        Account acct = Test_Utility.createAccountEU(1);
        insert acct;
        Account acctAM = Test_Utility.createAccountAM(1);
        insert acctAM;
        Profile pricingProfile = [Select id from Profile where Name = 'CRM_Pricing Admin'];
        Profile csrProfile = [select id from Profile where Name = 'CRM_CSR'];
        pUser = Test_Utility.createUser(pricingProfile.Id, null, 1);
        cUser = Test_Utility.createUser(csrProfile.Id, null, 2);
        List<User> users = new List<User>();
        users.add(pUser);
        users.add(cUser);
        if (!users.isEmpty()) {
            insert users;
        }
        Case ca = new case(AccountId = acct.Id, RecordTypeId = caseRecordTypeId, Type='Net Price', Origin='Sales');
        insert ca;  
        ca = new case(AccountId = acct.Id, RecordTypeId = caseRecordTypeId, Type='Annual Price Adjustment', Origin='Pricing');
        insert ca;  
        ca.Pricing_Stage__c = '(2) Pricing Review and Load';
        ca.Open_orders_to_be_updated__c = 'Yes';
        ca.Update_quoted_prices_after_Sep_1st__c = 'Yes';
        update ca;
        ca.Pricing_Stage__c = '(4) CPL/MQ Review';
        update ca;      
        List<AccountTeamMember> members = new List<AccountTeamMember>();
        AccountTeamMember pmember = new AccountTeamMember(AccountId = acct.Id, TeamMemberRole = 'Price Planner', UserId = pUser.id);
        members.add(pmember);
        AccountTeamMember cmember = new AccountTeamMember(AccountId = acct.Id, TeamMemberRole = 'Customer Service Rep', UserId = cUser.id);
        members.add(cmember);
        
        if (!members.isEmpty()) {
            insert members;
        }
        Test.startTest();
        ca = new case(AccountId = acct.Id, RecordTypeId = caseRecordTypeId, Type='Annual Price Adjustment', Origin='Pricing');
        insert ca;  
        ca.Pricing_Stage__c = '(2) Pricing Review and Load';
        ca.Open_orders_to_be_updated__c = 'Yes';
        ca.Update_quoted_prices_after_Sep_1st__c = 'Yes';
        update ca;
        ca.Pricing_Stage__c = '(3) CPL/MQ requested';
        update ca;
        ca.Pricing_Stage__c = '(4) CPL/MQ Review';
        update ca;
        ca.Pricing_Stage__c = '(5) CPL/MQ Published';
        update ca;
        ca = new case(AccountId = acct.Id, RecordTypeId = caseRecordTypeId, Type='Net Price', Origin='Sales');
        insert ca;  
        ca = new case(AccountId = acctAM.Id, RecordTypeId = caseRecordTypeId, Type='Net Price', Origin='Sales');
        insert ca;  
        ca = new case(AccountId = acctAM.Id, RecordTypeId = caseRecordTypeId, Type='Annual Price Adjustment', Origin='Pricing');
        insert ca;  
        ca.Pricing_Stage__c = '(2) Pricing Review and Load';
        ca.Open_orders_to_be_updated__c = 'Yes';
        ca.Update_quoted_prices_after_Sep_1st__c = 'Yes';
        update ca;
        ca.Pricing_Stage__c = '(3) CPL/MQ requested';
        update ca;
        ca.Pricing_Stage__c = '(4) CPL/MQ Review';
        update ca;
        ca.Pricing_Stage__c = '(5) CPL/MQ Published';
        update ca;
        
        //Test Code for Fax handling
        Account acctce = new Account();
        acctce.Name = 'Test1';
        acctce.Division__c = 'Cooling';
        acctce.Language_CE__c = 'DE: German';
        acctce.Business_Org__c='Climate and Energy';
        insert acctce;
        
        Account acctce2 = new Account();
        acctce2.Name = 'Test1';
        acctce2.Division__c = 'Cooling';
        acctce2.Language_CE__c = 'DE: German';
        acctce2.Business_Org__c='Climate and Energy';
        insert acctce2;
        
        Contact con1= Test_Utility.createContact(acctce.id, 1);
        insert con1;
        
        Contact con2= Test_Utility.createContact(acctce.id, 2);
        insert con2;
        
        Contact con3= Test_Utility.createContact(acctce2.id, 3);
        insert con3;
        
        con1.Fax = '+4940200086899';
        update con1;
        con2.Fax = '+4940200086899';
        update con2;
        con3.Fax = '+494020435664436899';
        update con3;
        system.assertEquals(con3.Fax,'+494020435664436899');
        
        String str = 'fax from  \'+4940204354436899\' for \'+49 69 8902 466 494\' ';
        Case ca2 = new case(subject=str);
        insert ca2;  
        
        System.debug(ca2.contactid==null);
        
        System.assert(ca2.contactid==null);
        
        String str2 = 'fax from  \'+4940200086899\' for \'+49 69 8902 466 494\' ';
        Case ca3 = new case(subject=str2);
        insert ca3;  
                
        Test.stopTest();
        System.debug(ca);
    }
}