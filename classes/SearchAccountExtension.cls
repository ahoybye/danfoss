public without sharing class SearchAccountExtension {
    
    /*
     *	      
     *  2015.12.21 - (AHO) 
     *   - Changed class to run without sharing to prevent creation of duplicates 
     *   - only searching for accounts with business Org = 'Climate and Energy'
     *   - Added additional fields to the result phone and local name
     * 
     * 
     * 
     */
    
    private Account acc;
    private User u;
    private string businessOrg;
    public string myAccounts {get;set;}
    public string myTeamAccounts {get;set;}
    public Id selectedAccount {get;set;}
    public ApexPages.StandardSetController setCon {get;set;}
    public Boolean navigateToEditAcc {get;set;}
    
    
    public SearchAccountExtension(ApexPages.StandardController stdController) {
        navigateToEditAcc = false;
        acc = (Account) stdController.getRecord();
        acc.Name = '';
        //get the information from the user & populate the accounnt accordingly, we may wish to save the account
        u = [select Id, Name, Business_Org__c, Division__c, User_Country__c, Phone_Country_Code__c from User where Id=:UserInfo.getUserId()];
        acc.Country_MainAddress__c  = u.User_Country__c;
        //acc.BillingCountry= u.User_Country__c;
        acc.ShippingCountry= u.User_Country__c;
        acc.Division__c = u.Division__c;
        acc.Business_Org__c = u.Business_Org__c;
        businessOrg = u.Business_Org__c;
        acc.Country_Phone__c = u.Phone_Country_Code__c;
        acc.Fax_Country__c = u.Phone_Country_Code__c;
        acc.Country_POBox__c = acc.Country_MainAddress__c;
        
        //get the recordtype
        String recTypeDeveloperName;
        List<Account_Record_Type_Mapping__c> artms = [select Record_Type_Developer_Name__c from Account_Record_Type_Mapping__c where Business_Org__c = :u.Business_Org__c];
        if (artms.isEmpty()) {
            recTypeDeveloperName = 'Prospect';
        } else {
            recTypeDeveloperName = artms[0].Record_Type_Developer_Name__c;
        }
        acc.RecordTypeId = [select Id from RecordType where DeveloperName = :recTypeDeveloperName and SobjectType = 'Account'].Id;
        
        //code to set the listIDs for the enhanced lists on the page.....
        Database.QueryLocator ql = Database.getQueryLocator([select Id from Account where Id = :acc.Id]);
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(ql);
        System.SelectOption[] listViews = setController.getListViewOptions();
        for (System.SelectOption listView : listViews) {
            if (listView.getLabel() == 'My Account (team)') {
                myTeamAccounts = listView.getValue();
                myTeamAccounts = myTeamAccounts.left(15);
            }
        }
        for (System.SelectOption listView : listViews) {
            if (listView.getLabel() == 'My Accounts...') {
                myAccounts = listView.getValue();
                myAccounts = myAccounts.left(15);
            }
        }
    }
    
    public boolean getcreatepossible() {
        return acc.Name != '';
    }
    
    public pagereference GoToAccount() {
        PageReference pageRef = new PageReference('/'+selectedAccount);
        return pageRef;
    }
    
    public void CreateNew() {
        //  PageReference pageRef = new PageReference('/apex/newAccountredirect?searchname='+ acc.Name + '&city=' + acc.City__c + '&country=' + acc.Country_MainAddress__c);
        //  system.debug('page ref ' + pageRef);
        //acc.Country_Phone__c = u.Phone_Country_Code__c;
        //acc.Fax_Country__c = u.Phone_Country_Code__c;
        acc.Country_POBox__c = acc.Country_MainAddress__c;        
        //acc.BillingCountry= acc.Country_MainAddress__c;
        acc.ShippingCountry= acc.Country_MainAddress__c;
        //FIX FOR Phone Country Default - Account Management 3rd March: the user has chosen the acc.Country_MainAddress__c field in the UI
        //The phone picklists should match this value, compare the picklist values of phone with the acc.Country_MainAddress__c and set the
        //correct phone picklist value
       
		Schema.DescribeFieldResult fieldResult = Account.Country_Phone__c.getDescribe();
   		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
       for( Schema.PicklistEntry f : ple)
   			{
                string countryCode = f.getValue();

                if (acc.Country_MainAddress__c != null) {
                    if (countryCode.startswith(acc.Country_MainAddress__c)) {
                        acc.Country_Phone__c = countryCode;
                        acc.Fax_Country__c = countryCode;
                    }
                }
   			} 
        //FIX FOR Phone Country Default - Account Management 3rd March
        insert acc;
        navigateToEditAcc = true;
    }
    
    public void search() {
        if(acc.Name == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,'Please enter Search Term '));
            return;
        }
        String accNameLike = '%' + acc.Name.replace('*', '%') + '%';
        String query = 'select id,ShippingStreet, ShippingCity, ShippingCountry, ShippingPostalCode, Country_MainAddress__c, name, Local_Account_Name__c, phone, industry, division__c, recordtype.name, owner.name from account where Business_Org__c = :businessOrg and (name like :accNameLike or name_2__c like :accNameLike or Local_Account_Name__c like :accNameLike) ';
        
        String shippingCityLike = '%'+ acc.ShippingCity + '%';
        if (acc.ShippingCity != null) {
            query = query + ' and (ShippingCity like :shippingCityLike or Local_City__c like :shippingCityLike)' ;
        }
        String countryMainAddress = acc.Country_MainAddress__c;
        if (acc.Country_MainAddress__c != null) {
            countryMainAddress = countryMainAddress.substring(0,2) + '%';
            query = query + ' and (Country_MainAddress__c like :countryMainAddress or ShippingCountry like :countryMainAddress)';
        }
        System.debug(LoggingLevel.DEBUG, '@@ Search Query: ' + query);
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        setCon.setPageSize(8);
        if (setCon.getRecords().isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'No Matching Accounts '));  
        }
    }
    
    public List<Account> getResults() {
        return setCon.getRecords();
    }
    
}