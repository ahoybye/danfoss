@isTest
private class Test_SalesOrgTrigger {
	static testMethod void myUnitTest() {
		Account mockAcct = Test_Utility.createAccount(1);
		insert mockAcct;
		List<Application__c> lstApplications = new List<Application__c>();
		Application__c mockAppl = new Application__c(SAP_Application_Code__c = 'ABA', Market_Segment__c = 'Agricultural Machine', Name = 'Tractors', CurrencyIsoCode = 'USD');		
		lstApplications.add(mockAppl);
		Application__c mockAppl2 = new Application__c(SAP_Application_Code__c = 'CCB', Market_Segment__c = 'Construction Machine', Name = 'Dozers', CurrencyIsoCode = 'USD');
		lstApplications.add(mockAppl2);
		if(!lstApplications.isEmpty())
			insert lstApplications;
		List<Sales_Org__c> lstSOs = new List<Sales_Org__c>();
		Sales_Org__c c1 = new Sales_Org__c (Account__c = mockAcct.Id, CurrencyIsoCode = 'USD', SAP_Sales_Org__c = '1500', Application__c = 'ABA');
		lstSOs.add(c1);
		Sales_Org__c c2 = new Sales_Org__c (Account__c = mockAcct.Id, CurrencyIsoCode = 'USD', SAP_Sales_Org__c = '1200', Application__c = 'CCB');
		lstSOs.add(c2);
		Sales_Org__c c3 = new Sales_Org__c (Account__c = mockAcct.Id, CurrencyIsoCode = 'USD', SAP_Sales_Org__c = '1200', Application__c = 'BBB');
		lstSOs.add(c3);
		if(!lstSOs.isEmpty())
			insert lstSOs;
	}
}