@isTest
public class Test_SearchOpportunityExtension {

    public static testMethod void testNoMatchFound() {
        Account account = Test_Utility.createAccount(0);
        insert account;
        Opportunity opportunity1 = Test_Utility.createOpportunity(account.Id, 0);
        opportunity1.Name = 'NoMatchOpportunity';
        insert opportunity1;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('accID', account.Id);
        Opportunity opportunity = new Opportunity();
        SearchOpportunityExtension c = new SearchOpportunityExtension(new ApexPages.StandardController(opportunity));
        System.assertEquals(false, c.getcreatepossible());
        opportunity.Name = 'MyTestOpportunity';
        c.search();
        opportunity.CloseDate = Date.today();
        c.selectedContactId = null;
        c.selectSalesArea();
        
        Test.stopTest();
        
        System.assertEquals(true, c.navigateToEditOpp);
        System.assertEquals(0, [select Id from Project_opportunity__c].size());
        System.assertEquals(2, [select Id from Opportunity].size());
    }

    public static testMethod void testMatchFound() {
        Account account = Test_Utility.createAccount(0);
        account.Business_Org__c='Climate and Energy';
        insert account;
        Opportunity opportunity1 = Test_Utility.createOpportunity(account.Id, 0);
        opportunity1.Name = 'NoMatchOpportunity';
        insert opportunity1;
        Opportunity opportunity2 = Test_Utility.createOpportunity(account.Id, 0);
        opportunity2.Name = 'MyTestOpportunity';
        insert opportunity2;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('accID', account.Id);
        Opportunity opportunity = new Opportunity();
        SearchOpportunityExtension c = new SearchOpportunityExtension(new ApexPages.StandardController(opportunity));
        System.assertEquals(false, c.getcreatepossible());
        opportunity.Name = 'MyTestOpportunity';
        c.search();
        System.assertEquals(true, c.getcreatepossible());
        System.assertEquals(false, c.navigateToEditOpp);
        System.assertEquals(1, c.getResults().size());
        c.CreateNew();
        opportunity.CloseDate = Date.today();
        c.selectedContactId = null;
        c.selectSalesArea();
        
        Test.stopTest();
        
        System.assertEquals(true, c.navigateToEditOpp);
        System.assertEquals(0, [select Id from Project_opportunity__c].size());
        System.assertEquals(3, [select Id from Opportunity].size());
    }

    public static testMethod void testProjectOpp() {
        Account account = Test_Utility.createAccount(0);
        account.Business_Org__c='Climate and Energy';
        insert account;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('accID', account.Id);
        Opportunity opportunity = new Opportunity();
        SearchOpportunityExtension c = new SearchOpportunityExtension(new ApexPages.StandardController(opportunity));
        System.assertEquals(false, c.getcreatepossible());
        opportunity.Name = 'MyTestOpportunity';
        c.isProjectOpp = true;
        c.showProjectFields();
        c.newProject = 'MyTestProject';
        c.search();
        opportunity.CloseDate = Date.today();
        c.selectedContactId = null;
        c.selectSalesArea();
        
        Test.stopTest();
        
        System.assertEquals(true, c.navigateToEditOpp);
        System.assertEquals(1, [select Id from Project_opportunity__c].size());
        System.assertEquals(1, [select Id from Opportunity].size());
    }

    public static testMethod void testOneSalesArea() {
        Account account = Test_Utility.createAccount(0);
        account.Business_Org__c='Climate and Energy';
        insert account;
        Sub_Account__c subAcc = new Sub_Account__c(Account__c = account.Id);
        insert subAcc;
        Sales_Area_Master__c sam = new Sales_Area_Master__c();
        insert sam;
        Sales_Area__c sa = new Sales_Area__c(Sub_Account__c = subAcc.Id, Sales_Area_Master__c = sam.Id);
        insert sa;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('accID', account.Id);
        Opportunity opportunity = new Opportunity();
        SearchOpportunityExtension c = new SearchOpportunityExtension(new ApexPages.StandardController(opportunity));
        System.assertEquals(false, c.getcreatepossible());
        opportunity.Name = 'MyTestOpportunity';
        c.search();
        opportunity.CloseDate = Date.today();
        c.selectedContactId = null;
        c.selectSalesArea();
        
        Test.stopTest();
        
        System.assertEquals(true, c.navigateToEditOpp);
        System.assertEquals(0, [select Id from Project_opportunity__c].size());
        System.assertEquals(1, [select Id from Opportunity].size());
        System.assertEquals(sa.Id, opportunity.Sales_Area__c);
    }

    public static testMethod void testManySalesArea() {
        Account account = Test_Utility.createAccount(0);
        account.Business_Org__c='Climate and Energy';
        insert account;
        Sub_Account__c subAcc = new Sub_Account__c(Account__c = account.Id);
        insert subAcc;
        Sales_Area_Master__c sam1 = new Sales_Area_Master__c();
        Sales_Area_Master__c sam2 = new Sales_Area_Master__c();
        insert new List<Sales_Area_Master__c> {sam1, sam2};
        Sales_Area__c sa1 = new Sales_Area__c(Sub_Account__c = subAcc.Id, Sales_Area_Master__c = sam1.Id);
        Sales_Area__c sa2 = new Sales_Area__c(Sub_Account__c = subAcc.Id, Sales_Area_Master__c = sam2.Id);
        insert new List<Sales_Area__c> {sa1, sa2};
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('accID', account.Id);
        Opportunity opportunity = new Opportunity();
        SearchOpportunityExtension c = new SearchOpportunityExtension(new ApexPages.StandardController(opportunity));
        System.assertEquals(false, c.getcreatepossible());
        opportunity.Name = 'MyTestOpportunity';
        c.search();
        opportunity.CloseDate = Date.today();
        c.selectedContactId = null;
        c.selectSalesArea();
        System.assertEquals(false, c.navigateToEditOpp);
        c.selectedSalesArea = sa1.Id;
        c.createOppandProject();
        
        Test.stopTest();
        
        System.assertEquals(true, c.navigateToEditOpp);
        System.assertEquals(0, [select Id from Project_opportunity__c].size());
        System.assertEquals(1, [select Id from Opportunity].size());
        System.assertEquals(sa1.Id, opportunity.Sales_Area__c);
    }

}