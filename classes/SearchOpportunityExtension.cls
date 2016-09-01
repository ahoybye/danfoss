public without sharing class SearchOpportunityExtension {
    /*
     *	      
     *  2016.06.09 - (AHO) 
     *   - Changed class to run without sharing to prevent creation of duplicates across regions
     *   - additional criterias on search SOQL account.business_org__c='Climate and Energy'
     *      
     */
    
    public String newProject {get;set;}
    public boolean isProjectOpp {get;set;}
    private Opportunity opp;
    public string myOpportunities {get;set;}
    public string myTeamOpportunities {get;set;}
    private final string division;
    public Id selectedOpportunity { get; set; }
    public ApexPages.StandardSetController setCon {get;set;}
    public Boolean navigateToEditOpp {get;set;}
    public ApexPages.StandardSetController contactsCon {get;set;}
    public Id selectedContactId {get;set;}
    public List<Sales_Area__c> AvailableSalesAreas {get;set;}
    public ID selectedSalesArea {get;set;}
    
    public SearchOpportunityExtension(ApexPages.StandardController stdController) {
        newProject = '';
        navigateToEditOpp = false;
        //get the page parameters        
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        ID accID = ApexPages.currentPage().getParameters().get('accID');
        String projOpp = ApexPages.currentPage().getParameters().get('projOpp');
        ID projID = ApexPages.currentPage().getParameters().get('projID');
        //determine if this is a project opportunity or not
        isProjectOpp = projOpp == 'TRUE';
        //get the opportunity & set the AccountID 
        opp = (Opportunity) stdController.getRecord();
        opp.Name = '';
        opp.Project_Opportunity__c = projID;
        opp.AccountId = accID;
        
        // Aded July 2 - 2015 - Allan Hoybye @Salesforce.com
        // Get user currency - for defaulting
        if (opp.AccountId != null) {
            opp.CurrencyIsoCode = [select CurrencyIsoCode from Account where Id = :opp.AccountId].CurrencyIsoCode;
        }
        //get the user division & if it is Heating Solutions, default to a Project
        division = [Select division__c from User where Id = :Userinfo.getuserId()].division__c;
        // if (division == 'Heating Solutions'){isProjectOpp=true;}
        
        //display the enhanced lists.....
        Database.QueryLocator ql = Database.getQueryLocator([select Id from Opportunity where Id = :opp.id]);
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(ql);
        System.SelectOption[] listViews = setController.getListViewOptions();
        for (System.SelectOption listView : listViews) {
            if (listView.getLabel() == 'My Opportunity (team)') {
                myTeamOpportunities = listView.getValue();
                myTeamOpportunities = myTeamOpportunities.left(15);
            }
        }
        for (System.SelectOption listView : listViews) {
            if (listView.getLabel() == 'My Opportunities...') {
                myOpportunities = listView.getValue();
                myOpportunities = myOpportunities.left(15);
            } 
        }
    }
    
    public void showProjectFields() {
        // don't change anything, just rerender
    }
    
    //if the user hasn't searched then they can't create a new Opportunity
    public boolean getcreatepossible() {
        return opp.Name != '';
    }
    
    public pagereference GoToAccount() {
        //provide navigation for the searched records
        PageReference pageRef = new PageReference('/'+selectedOpportunity);
        return pageRef;
    }
    
    public void CreateNew() {
        goToContactSelection();
    }
    
    public void search() {
        
        //make sure that the users have filled in what they need to 
        if (opp.Name == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Please enter Name '));
            return;
        }
        
        //do the query & get the list of matching opps
        String term = '%' + opp.Name + '%';
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select id, Project_Opportunity__c, name, Account.name ,Amount, stagename, CE_division__c, closedate, owner.name, City__c, Country__c from opportunity where Account.Business_Org__c='Climate and Energy' AND Account.Inactive__c=false AND name like :term limit 20]));
        setCon.setPageSize(8);
        
        //if there are no matches, create the opportunity & project
        if (!setCon.getRecords().isEmpty()) {
            return;
        }
        
        goToContactSelection();
    }
    
    private void goToContactSelection() {
        String fields = 'Id';
        for (FieldSetMember field : SObjectType.Contact.FieldSets.CreateOpportunityFields.getFields()) {
            fields += ', ' + field.getFieldPath();
        }
        String accId = opp.AccountId;
        //contactsCon = new ApexPAges.StandardSetController(Database.getQueryLocator('select ' + fields + ' from Contact where AccountId = :accId and Inactive_Contact__c = false order by CreatedDate desc'));
		contactsCon = new ApexPAges.StandardSetController(Database.getQueryLocator('select ' + fields + ' from Contact where AccountId = :accId and Inactive_Contact__c = false order by name'));
        contactsCon.setPageSize(50);
    }
    
    public List<Contact> getContactsList() {
        return (List<Contact>) contactsCon.getRecords();
    }
    
    public List<opportunity> getResults() {
        return (List<opportunity>) setCon.getRecords();
    }
    
    public void selectSalesArea() {
        String soqlFields = 'Id';
        for (FieldSetMember field : SObjectType.Sales_Area__c.FieldSets.PricesForOpportunityColumns.getFields()) {
            soqlFields += ', ' + field.getFieldPath();
        }
        ID accountId = opp.AccountId;
        AvailableSalesAreas = Database.query('select ' + soqlFields + ' from Sales_Area__c where Sub_Account__r.Account__c = :accountId');
        if (AvailableSalesAreas.isEmpty()) {
            selectedSalesArea = null;
            AvailableSalesAreas = null;
            contactsCon=null;
            createOppandProject();
            return;
        }
        if (AvailableSalesAreas.size() == 1) {
            selectedSalesArea = AvailableSalesAreas[0].Id;
            AvailableSalesAreas = null;
            contactsCon=null;
            createOppandProject();
            return;
        }
    }
    
    public void createOppandProject() {
        Savepoint sp = Database.setSavepoint();
        if (isProjectOpp) {
            //if it's a project they need to create a new one or select a pre-existing one
            if (opp.Project_Opportunity__c == null) {
                if (newProject == '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'For Project Opportunities select an existing Project, or create a new one'));
                    return;
                }
                Project_opportunity__c p = new Project_opportunity__c(
                    Name = newProject
                );
                try {
                    insert p;
                } catch (DMLException ex) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to Create Project...' + ex));       
                    Database.rollback(sp);
                    return;
                }
                opp.Project_Opportunity__c = p.id;
            }
        } else {
            opp.Project_Opportunity__c = null;
        }
        //next get the record Type 
        String recTypeDevName = isProjectOpp ? 'Project_Opportunity' : 'CE_Opportunity';
        String recType = [select Id from RecordType where DeveloperName = :recTypeDevName and SobjectType = 'Opportunity'].Id;
        //check that the user is from Heating Solutions & set salesmodel to Project  
        if (division == 'Heating Solutions') {
            opp.CE_Sales_model__c = 'Project';
        }
        //complete the rest of the required values 
        // JPK 05-02-2015 - UAT #59     
        //opp.Amount = 0;
        opp.CE_Status__c = 'Open';
        opp.CE_Phase__c = 'Identification';
        opp.RecordTypeId = recType;
        opp.StageName = 'Open';
        opp.CE_Division__c = division;
        opp.Type = 'New Business';
        opp.Contact__c = selectedContactId;
        // Removed July 2 - 2015 - Allan Hoybye @Salesforce.com
        //if (opp.AccountId != null) {
        //    opp.CurrencyIsoCode = [select CurrencyIsoCode from Account where Id = :opp.AccountId].CurrencyIsoCode;
        //}
        opp.Sales_Area__c = selectedSalesArea;
        if (opp.Sales_Area__c != null) {
            opp.Sub_Account__c = [select Sub_Account__c from Sales_Area__c where Id = :opp.Sales_Area__c].Sub_Account__c;
        }
        //try to insert the opportunity   
        try {
            insert opp;
        } catch (DMLException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to Create Opportunity...' + ex));
            Database.rollback(sp);
            return;
        }
        
        Associated_Account__c aa = new Associated_Account__c(
            Associated_Account__c = opp.AccountId,
            Contact__c = selectedContactId,
            Project_Opportunity__c = opp.Id,
            Type_of_Association__c = 'Main Account'
        );
        
        try {
            insert aa;
        } catch (DMLException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to Create Opportunity...' + ex));
            Database.rollback(sp);
            return;
        }
        
        navigateToEditOpp = true;
    }
    
}