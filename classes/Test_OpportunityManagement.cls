/******************************************************
* Author        :  Harshit Jain(Appirio)
* Name          :  OpportunityManagement_Test
* Date          :  27/08/2012
* Related Task  :  T-77514
* Description   :  verify the functionality of OpportunityManagement class
*******************************************************/
@isTest 
private class Test_OpportunityManagement {

    static Id StdPBId;
	static PriceBookEntry stdpbe;
	static Product2 product;
	static Account account;
	static Opportunity oppty;
	
    static testMethod void myUnitTest() {   
        createTestData();
        //create contact to be used for portal user
        Contact contactPortal = Test_Utility.createContact(account.Id, 2);
        insert contactPortal;
        List<Profile> portalUserProfiles = [Select id from Profile where Name IN ('PartnerLink - Full') limit 1];
        system.assertEquals(portalUserProfiles.size(), 1);  
        User portalUser = Test_Utility.createPortalUser(contactPortal.Id, portalUserProfiles.get(0).Id);
        insert portalUser;
        System.assertEquals(portalUser.IsActive, true);            
        
        OpportunityLineItem oli = Test_Utility.createOpportunityLineItem(oppty.Id, stdpbe.Id, 1);   
        insert oli;
        oli.Approx_Competitor_Price__c = 5;
        oli.Competitor__c = 'Bosch Rexroth';
        update oli;
    
        Test.startTest();
        oppty.stagename = 'Closed Won';
        oppty.Reason_Won_Lost__c = 'Price';
        oppty.Reason_Description__c = 'Better Price';
        update oppty;
   
        Customer_Part_Number__c cpn = new Customer_Part_Number__c(SAP_Customer_Material_Id__c = '23456', Material_Number__c = '12345', Account__c = account.Id, Product__c = product.Id);
        insert cpn;
        //Send email notification if opportunity is created by portal user
        system.runAs(portalUser) {            
            Opportunity opptyP = createOpportunity(account.Id, 2); 
            insert opptyP;
        }           
        Test.stopTest();
    }
	
	static void createTestData(){
    	Test_Utility.initTestData();   //create C&E pricebook
		product = Test_Utility.createProduct2();
		product.Business_Unit__c = 'Motors';
		product.ProductCode = '11111';
		product.Model_Code__c = 'modelcodetext';
		product.Business_Org__c = 'Danfoss';
		insert product;
		StdPBId = Test.getStandardPricebookId();
		stdpbe = new PricebookEntry(Pricebook2Id = StdPBId, Product2Id = product.Id, UnitPrice = 100, IsActive = true, CurrencyISOCode = 'DKK');
		insert stdpbe;
		account = Test_Utility.createAccount(1);
		account.SAP_Account_Id__c = '070707';
		insert account;
		Sales_Org__c so = new Sales_Org__c(Name = '1500', SAP_Sales_Org__c = '1500', Account__c = account.Id, SAP_Account_Id__c = account.SAP_Account_Id__c);
        insert so;
		oppty = createOpportunity(account.Id, 1);
		insert oppty;  
	}
	
	private static Opportunity createOpportunity(Id accountId, Integer i){
        Opportunity opportunity = new Opportunity(
                                Name='Test opportunity name'+i,
                                CurrencyISOCode = 'DKK',
                                AccountId = accountId,
                                StageName = 'Evaluating Need',
                                Production_Start_Date__c = Date.today().addDays(10),
                                CloseDate = Date.today().addDays(5));
        return opportunity;
    }
}