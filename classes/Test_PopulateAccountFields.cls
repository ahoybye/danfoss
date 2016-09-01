@isTest
private class Test_PopulateAccountFields {
    static Account account;
    static Contact contactPortal;
    static User portalUser;
    static User adminUser;
	static Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
   
    static testMethod void myUnitTest() {
        Account acct = Test_Utility.createAccount(1);
		acct.RecordTypeId = acctRecordTypeId;
    	insert acct;
		acct.Channel__c = 'Distributor';
		update acct;
		contactPortal = Test_Utility.createContact(acct.Id,2);
        insert contactPortal;
     	Contact cont = Test_Utility.createContact(acct.Id, 1);
        insert cont;
        List<Profile> portalUserProfiles = [Select id from Profile where Name IN ('PartnerLink - Basic','PartnerLink - Full') limit 1];
        portalUser = Test_Utility.createPortalUser(contactPortal.Id, portalUserProfiles.get(0).Id, 3);
        insert portalUser;
        system.runAs(portalUser) {
	    	Account acct2 = Test_Utility.createAccount(2);
    		insert acct2;
        }
    }
}