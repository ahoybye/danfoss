/**
	Author: Erin Fink
	Date: 12JUL15
	Version 1.0
**/

@isTest
private class Test_EDISCandGrids {
	static testMethod void myUnitTest() {
		Account account = Test_Utility.createAccount(1);
        insert account;
		Contact contact = Test_Utility.createContact(account.Id, 1);
		insert contact;
		Opportunity oppty = Test_Utility.createOpportunity(account.Id, 1);
        insert oppty;
		Test.startTest();
		Influencer_Grid__c grid = new Influencer_Grid__c(Opportunity__c = oppty.Id, Contact__c = contact.Id);
		insert grid;
		
		EDISCextension Eext = new EDISCextension(new ApexPages.StandardController(new EDISC__c()));
		EDISC__c disc = new EDISC__c(Contact__c = contact.Id, Primary_Profile__c = 'D', Q1O1__c = 'Most', Q1O2__c = 'Most');
		insert disc;
		
		InfluencerExtension Iext = new InfluencerExtension(new ApexPages.StandardController(new Influencer_Grid__c()));
		Iext.newTypicalEdisc = true;
		Iext.SaveGrid();
		
		disc = new EDISC__c(Contact__c = contact.Id, Primary_Profile__c = 'D', Secondary_Profile__c = 'D', Q1O1__c = 'Least', Q1O2__c = 'Least');
		insert disc;
		disc = new EDISC__c(Contact__c = contact.Id, Primary_Profile__c = 'D', Secondary_Profile__c = 'D', Q1O1__c = 'Least', Q1O2__c = 'Most');
		insert disc;		
		Eext = new EDISCextension(new ApexPages.StandardController(disc));
		Eext.redirectToDetailPage();
		
		Iext = new InfluencerExtension(new ApexPages.StandardController(grid));
		Iext.getItems();
		Iext.findDiscs();
		Iext.SaveGrid();
		delete grid;
		Test.stopTest();
	}
}