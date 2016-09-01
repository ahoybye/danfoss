public with sharing class QuotePDFExtension {
    
    private QuoteLineItem QLI;
    private Quote quote;
    private Opportunity oppty;
    private Account acct;
	private static Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
    public Boolean isDistributor{get;set;}
    public Boolean isIndirect{get;set;}
    public Boolean isDirect{get;set;}
    public string footertext{get;set;}
    //public string size {get;set;}
    public String imageURL{get;set;}
    public String acctAddress{get;set;}
	public Boolean showWatermark{get;set;}	
    //public String FooterSize{get;set;}
    //public Integer countEnterHeader{get;set;}
    //public Integer countEnterFooter{get;set;} 
    public string qId;
	
 	public string getDocumentLogoUrl()
    {
        //FooterSize='258px';
        imageURL='/servlet/servlet.FileDownload?file=';
        List<Document> lstDocument = new List<Document>();
		//Region__c japan = [SELECT id, Name from Region__c where Name = 'Japan'];
		if (acct.Business_Org__c == 'Comatrol')
		{
			lstDocument = [Select Id,DeveloperName from Document where DeveloperName = 'Comatrol_Logo' limit 1];
		}
		else if (acct.Business_Org__c == 'Turolla')
		{
			lstDocument = [Select Id,DeveloperName from Document where DeveloperName = 'Turolla_200_px_wide' limit 1];
		}
        //else if (quote.Country_Specific_Template__c == japan.Id)
         //   lstDocument = [Select Id,DeveloperName from Document where DeveloperName = 'Daikin' limit 1];
        else
            lstDocument = [Select Id,DeveloperName from Document where DeveloperName = 'DanfossLogoForPDF' limit 1];
        if(lstDocument.size()>0)
        {
            imageURL=imageURL+lstDocument[0].id;
        }
		//size = '2.0';
        return imageURL;
    }
    
    public QuotePDFExtension(ApexPages.StandardController controller) {
        this.quote = (Quote)controller.getRecord();
        //size = '2.0';
        oppty = [select AccountId, Sales_Org__r.Name from Opportunity where Id = :quote.OpportunityId];
        acct = [select Channel__c, SAP_Account_ID__c, Account_Group__c, Formatted_Address__c, Name, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, ParentId, Country__r.Country_Code__c, RecordTypeId, Business_Org__c from Account where Id = :oppty.AccountId];
		if (acct.Business_Org__c == 'Comatrol' || acct.Business_Org__c == 'Turolla')	{
			showWatermark = true;
		}
		else{
			showWatermark = false;
		}
        if (acct.Channel__c == 'Distributor') {
            isDistributor = true;
            isDirect = false;
            isIndirect = false;
            if (acct.Business_Org__c == 'Turolla')
				footertext = quote.Country_Specific_Template__r.Turolla_Distributor_Quote_Footer__c;
			else if (acct.Business_Org__c == 'Comatrol')
				footertext = quote.Country_Specific_Template__r.Comatrol_Distributor_Quote_Footer__c;
			else
				footertext = quote.Country_Specific_Template__r.Distributor_Quote_Footer__c;
        }
        else if (acct.Channel__c == 'Indirect') {
            isDistributor = false;
            isDirect = false;
            isIndirect = true;
            if (acct.Business_Org__c == 'Turolla')
				footertext = quote.Country_Specific_Template__r.Turolla_Distributor_Quote_Footer__c;
			else if (acct.Business_Org__c == 'Comatrol')
				footertext = quote.Country_Specific_Template__r.Comatrol_Distributor_Quote_Footer__c;
			else
				footertext = quote.Country_Specific_Template__r.Distributor_Quote_Footer__c;			
        }
        else { //Direct or Global
            isDistributor = false;
            isDirect = true;
            isIndirect = false; 
            if (acct.Business_Org__c == 'Turolla')
				footertext = quote.Country_Specific_Template__r.Turolla_OEM_Quote_Footer__c;
			else if (acct.Business_Org__c == 'Comatrol')
				footertext = quote.Country_Specific_Template__r.Comatrol_OEM_Quote_Footer__c;
			else
            	footertext = quote.Country_Specific_Template__r.OEM_Quote_Footer__c;
        }
		Account acctForAddress;
		if(isIndirect && acct.ParentId != null)
			acctForAddress = [select Formatted_Address__c, Name, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet from Account where Id = :acct.ParentId];
		else	
			acctForAddress = acct;
		
		if(acct.RecordTypeId == acctRecordTypeId){ //is prospect			
			acctAddress = acctForAddress.Name + '<br/>' + acctForAddress.ShippingStreet + '<br/>' + acctForAddress.ShippingCity + ', ' + acctForAddress.ShippingState + '  ' + acctForAddress.ShippingPostalCode + '<br/>' + acctForAddress.ShippingCountry;
		}
		else
			acctAddress = acctForAddress.Formatted_Address__c;
    }
    
    public User getcurUser() {
        return [select CompanyName,Street, City, State, PostalCode, Country from User where Id = :UserInfo.getUserId()];
    }
}