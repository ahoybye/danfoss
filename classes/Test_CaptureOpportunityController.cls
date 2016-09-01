/**************************************************************************************
Class           : CaptureOpportunityController_Test 
Developed by    : Shailendra Singh(Appirio Offshore)
Created Date    : 28 Aug 2012
Description     : Test class for CaptureOpportunityController 
Related Task    : T-77780
****************************************************************************************/
@isTest
private class Test_CaptureOpportunityController {

    static testMethod void myUnitTest() {
        Account acc = Test_Utility.createAccount(1);
        insert acc;
        Contact contact = Test_Utility.createContact(acc.id,1);
        insert contact;
        
        Campaign campaign = new Campaign();
        campaign.Name = 'Demo';
        insert campaign;
        Sales_Org__c so = new Sales_Org__c(Name = '1500', SAP_Sales_Org__c = '1500', Account__c = acc.Id);
        insert so;
        System.currentPageReference().getParameters().put('campaignID',campaign.id);
        System.currentPageReference().getParameters().put('contactID',contact.id);
        Test.startTest();
            CaptureOpportunityController controller = new CaptureOpportunityController();
            controller.opportunity.StageName = 'Evaluating Need';
            controller.opportunity.CurrencyIsoCode = 'USD';
        	controller.opportunity.Sales_Org__c = so.Id;
            controller.opportunity.Name = 'Unit Test';
            controller.opportunity.Production_Start_Date__c = System.today();
             controller.opportunity.CloseDate = System.today().addDays(-5);
            controller.save();
        Test.stopTest();
        // validate that campaign has opportunity related to it.
        
        List<Opportunity> oppList = [Select ID from Opportunity Where CampaignID = :campaign.Id];
        
        System.assertEquals(oppList.size(),1);
        
    }
}