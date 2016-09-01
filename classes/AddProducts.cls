/**************************************************************************************
Class          : 
Developed by   : Jacqueline Ison
Description    : Product picker VF page extension controller to populate Opportunity Pricebook
Related Task   : 
****************************************************************************************/
public without sharing class AddProducts
{
    public Opportunity opportunity{get;set;}
    public Quote quote{get;set;}
    public Machine_Model__c machine{get;set;}
    
    public Authorized_Product__c[] ap = new List<Authorized_Product__c>();
    public PricebookEntry pbe;
    public Id accountId;
    public String sObjectId;
	public String subsystem;
    public Boolean isOpportunity{get;set;}
    public Boolean isMachine{get;set;}
    public Boolean isPortalUser;
    List<String> lstPLCode = new List<String>(); 
    List<Id> lstExclusiveProducts = new List<Id>();
    Boolean pageLoad;
    public Boolean limitExceeded{get;set;}
    public Boolean validExclusive{get;set;}
    Final Integer RECORD_LIMIT = 100;
    User curuser = getCurrentUserData();   
	public String salesorg {get;set;}
   	public List<Sales_Org__c> lstSOs = new List<Sales_Org__c>();
    public String Name{get;set;}
    public String ProductCode{get;set;}
    public String Model_Code{get;set;}
    public String Family{get;set;}
    public String ProductSet{get;set;}
    public String ProductLine{get;set;}	
    public Decimal SAPPrice;
    public String SAPCurrency;	
    public Boolean isSAPError{get;set;}
    public String sapErrMsg{get;set;}
	public Boolean priceretrieved{get;set;}
    public String materialNum;  
   
    public AddProducts() {
      initializePage();                  
    } 
     
     public void initializePage() {
       isOpportunity = false;
       isMachine = false;
       limitExceeded = false;
       validExclusive = true;
       pageLoad = true;
	   isSAPError = false;
       sObjectId = ApexPages.currentPage().getParameters().get('id');
	   subsystem = ApexPages.currentPage().getParameters().get('subsystem');
		 if(sObjectId.startsWith('006') ) {
         isOpportunity = true;
         opportunity = [Select Id, Account.RecordType.Name, Account.Account_Group__c, Account.Channel__c, Account.SAP_Account_ID__c, Account.Parent.SAP_Account_ID__c, PriceBook2Id,CurrencyIsoCode,Name,Pricebook2.Name,AccountId FROM Opportunity Where Id = :sObjectId];
         accountId = opportunity.AccountId;
       } 
       else if(sObjectId.startsWith('0Q0') ) {
         quote = [SELECT Id, Opportunity.Account.RecordType.Name, Opportunity.Account.Account_Group__c, Opportunity.Account.Channel__c, Opportunity.Account.Parent.SAP_Account_ID__c, Opportunity.Account.SAP_Account_ID__c, PriceBook2Id,CurrencyIsoCode,Name,Pricebook2.Name,Opportunity.AccountId FROM Quote Where Id = :sObjectId];
         accountId = quote.Opportunity.AccountId;
       }
       else if(sObjectId.startsWith('a0Q')) {
		 isMachine = true;
       	 machine = [Select Id, Account__r.RecordType.Name, Account__r.Account_Group__c, Account__r.SAP_Account_ID__c, Account__r.Channel__c, Account__r.Parent.SAP_Account_ID__c, CurrencyIsoCode, Name, Account__c FROM Machine_Model__c Where Id = :sObjectId];  
         accountId = machine.Account__c;
	     lstSOs = [select Id, Name from Sales_Org__c where Account__c = :accountId and Inactive__c = false];
	    }
       this.isPortalUser = false;
       this.isAscending = false;
       this.sortField = 'Product2.Name';    
       searchProduct = new Product2();
       lstPriceBookEntry = new List<PriceBookEntry>();
     }
     
     public void autorun() {   
        // set the pricebook in opportunity and quote
       if((isOpportunity && opportunity.Pricebook2Id==null) || (!isOpportunity && !isMachine && quote.Pricebook2Id==null)) {
         String businessOrg = curuser.Business_Org__c;
         if(businessOrg == 'Integrated') {
           businessOrg = 'Danfoss';
         } 
         Pricebook2 pb;            
         List<PriceBook2> lstPriceBook = [Select Id,Name from PriceBook2 where Name = :businessOrg];
         if(!lstPriceBook.isEmpty()) {
           pb = lstPriceBook[0];
         }
         try{
           if(isOpportunity) {
             opportunity.Pricebook2Id = pb.Id;           
             update opportunity;           
           }
           else {
             quote.Pricebook2Id = pb.Id;
             update quote; 
           }
         }    
         catch (DmlException e){
           ApexPages.addMessages(e);
         }        
       }                        
    }
  
   private void getAuthorizedProducts() {
     if(curuser.UserType == 'Portal'|| curuser.UserType == 'PowerPartner') { 
       this.isPortalUser = true;
       for(Authorized_Product__c ap : [select Product_Line__r.PL_Code__c from Authorized_Product__c where Account__c =: curuser.Contact.AccountId]) {
         if(ap.Product_Line__r.PL_Code__c != null) {
           lstPLCode.add(ap.Product_Line__r.PL_Code__c);
         }
       }
     }
   } 
   
   private void getExclusiveMaterials() {    
     for(Exclusive_Material__c exProd : [select Product__c from Exclusive_Material__c WHERE isDeleted__c = false and Account__c =: accountId]) {
       if(exProd.Product__c != null) {
         lstExclusiveProducts.add(exProd.Product__c);
       }
     }
   }
  
   private User getCurrentUserData() {
     return [Select Contact.AccountId, Business_Org__c, UserType from User where Id = :UserInfo.getUserId()];
   }
  //-----------------------------------------------------------------------------------//
    
  private List<PriceBookEntry> lstPriceBookEntry;  
  
  public String selectedProducts {get;set;}
  
  public Product2 searchProduct {get;set;}
  
  public List<PriceBookEntry> getAllEntries() {
    return this.lstPriceBookEntry;
  }
  
  /****************************************************Sorting******************************************************/
  
  //----------------Sorting variables---------------------//
  private String previousSortField = 'Name';
  
  public string sortField {
    get;
    set {
      this.previousSortField = sortField;
      this.sortField = value;
      setAscendingStatus();
    }
  } 
  
  private void setAscendingStatus() {
    if(previousSortField == sortField) {
      isAscending = !isAscending;
      return;
    }
    this.isAscending = true;  
  }
  
  public Boolean isAscending {get;set;}
  
  public PageReference doSort() {
    LoadPriceBookEntry();
    return null;
  }
  
  //======================================================================//
  //Method called internally to query and load products
  //======================================================================//    
  private PageReference LoadPriceBookEntry() {
    limitExceeded = false;
    string sortingOrder = ' ASC';
    List<PriceBookEntry> templstPBEntry = new List<PriceBookEntry>();
    
    if(isAscending == false){
      sortingOrder = ' DESC';
    }    
    
    if(pageLoad){
      return null;
    }
    
    list<Product2> lstProduct2 = getProductsList();
    lstPriceBookEntry = new List<PriceBookEntry>();
    validExclusive = checkValidExclusive();   
        
    if(lstPLCode.size()==0 && isPortalUser){
       return null;
    }
    
    if(lstProduct2.size() > 99) {
       limitExceeded = true;
      // return null;
    }    
    
    if(lstProduct2.isEmpty()) {
      return null;
    }
    
    if (!validExclusive){
        return null;
    }
    
    String currencyIsoCode;
    Id priceBookId;
	if(isMachine) {
	  priceBookId = [SELECT Id FROM PriceBook2 WHERE IsStandard=True].Id;
      currencyIsoCode = machine.CurrencyIsoCode;
	}
    else if(isOpportunity) { 
      priceBookId = opportunity.Pricebook2Id;
      currencyIsoCode = opportunity.CurrencyIsoCode;
    }
    else {
      priceBookId = quote.Pricebook2Id;
      currencyIsoCode = quote.CurrencyIsoCode;
    }
          
    String query = 'SELECT UnitPrice, IsActive, Pricebook2Id, Product2.Id, product2.productcode,'+
                   'product2.product_line__c, product2.SAP_Product_Line_Code__c, product2.model_code__c,' + 
                   'Product2.Name, Product2.Description, Product2.Family, Product2.Product_Set__c, Product2.SAP_Material_Code__c ' + 
                   'FROM PricebookEntry Where IsActive = true AND Product2.IsActive = true AND ' +
                   ' CurrencyIsoCode =  :currencyIsoCode';
    
    if(lstProduct2.size() > 0) {
      query += ' AND Product2.Id IN :lstProduct2';
    }
                
    query += ' ORDER BY ' + this.sortField + sortingOrder + ' LIMIT '+RECORD_LIMIT; 
    
    templstPBEntry = (List<PriceBookEntry>)Database.query(query);
    
    for (PriceBookEntry addPbe : templstPBEntry){
        if (addPbe.Pricebook2Id == priceBookId){
            this.lstPriceBookEntry.add(addPbe);
        }
    }    
    return null;
  }
  
  //======================================================================//
  //Get list of all the product that matches the criteria
  //======================================================================//  
  private list<Product2> getProductsList() {
    Product2[] plist;
    String query = getquerystring();
    try {
      plist = Database.query(query);
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }
    return plist; 
  }
  
 private Boolean checkValidExclusive(){
    Boolean ret = true;
    list<Id> exclAccnt = new list<Id>();
    if (ProductCode != null && ProductCode != ''){
        for(Exclusive_Material__c exAccount : [select Account__c from Exclusive_Material__c WHERE isDeleted__c = false and Product__r.ProductCode =: ProductCode]) {
            if(exAccount.Account__c != null) {
             exclAccnt.add(exAccount.Account__c);
            }
        }
        if (!exclAccnt.isEmpty()){
            ret = false;
            for(Id accId : exclAccnt){
                if (accId == accountId){
                    ret = true;
                }
            }           
        }
    }
    return ret;
 } 
  //----------------------------------------//
  // Construct Query to pull products
  //----------------------------------------//
  
  public String getquerystring() {       
    String soql = 'select Id from product2 where IsActive = true ';
    if (Name != null && Name != '') {
		String strName = Name + '%';
      	soql += ' and name LIKE \''+String.escapeSingleQuotes(strName).replace('*','%')+'\'';
		strName = Name;
    }  
    if (ProductCode != null && ProductCode != '') {
		String strProductCode = ProductCode + '%';
      	soql += ' and productcode LIKE \''+String.escapeSingleQuotes(strProductCode).replace('*','%')+'\'';
		strProductCode = ProductCode;
    }  
    if (Model_Code != NULL && Model_Code != '') {
		String strModel_Code = Model_Code + '%';
      	soql += ' and model_code__c LIKE \''+String.escapeSingleQuotes(strModel_Code).replace('*','%')+'\'';
		strModel_Code = Model_Code;
    }  
    if (ProductSet !=NULL && ProductSet != ''){
		String strProductSet = ProductSet + '%';
      	soql += ' and Product_Set__c LIKE \''+String.escapeSingleQuotes(strProductSet).replace('*','%')+'\'';
		strProductSet = ProductSet;
    }  
    soql += ' and (Proprietary__c = FALSE OR Id IN :lstExclusiveProducts)';
    system.debug('************************************************************************************* soql: ' + soql);
    if (lstPLCode.size()>0)
      soql += ' and SAP_Product_Line_Code__c in :lstPLCode ';                     
    
    
    soql += ' limit '+RECORD_LIMIT;
    
    
    return soql;
  }  

  //======================================================================//
  //Search method called from page 
  //======================================================================//  
  public PageReference Search() {	 
    if(pageLoad) {
      autorun();
      getAuthorizedProducts();
      getExclusiveMaterials();
    }   
    pageLoad = false;  
    LoadPriceBookEntry();
    return null;
  }
    
  //======================================================================//
  //Select Products and create line Items
  //======================================================================//
  public PageReference SelectProduct() {
	for(PriceBookEntry priceBookEntry :getAllEntries()){
      String selected = ApexPages.currentPage().getParameters().get(priceBookEntry.Product2.Id);
      //if the product is selected
      if(selected == '1') {
        pbe = priceBookEntry;
		materialNum = priceBookEntry.Product2.SAP_Material_Code__c;
      }
    }
    
    if(pbe == null) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please select at least one product'));
      return null;
    }    
	
    PageReference pg;
    if(isMachine) { 
		pg = new PageReference('/apex/AddMachineLineItems?id='+sobjectId+'&priceBookEntryId='+pbe.Id + '&subsystem=' + subsystem + '&salesorg=' + salesorg);
	    pg.setRedirect(True);
	    return pg;	
    }
    else if(isOpportunity) { 
      	pg = new PageReference('/apex/AddOpptyLineItems?id='+sobjectId+'&priceBookEntryId='+pbe.Id);   
	    pg.setRedirect(True);
	    return pg;
    }
    else {
      	pg = new PageReference('/apex/AddQuoteLineItems?id='+sobjectId+'&priceBookEntryId='+pbe.Id);   
	    pg.setRedirect(True);
	    return pg;
    } 
  }
     
  public PageReference cancel() {
    return new PageReference('/' + sObjectId);
  }
  
  public List<SelectOption> getItems() {
    List<SelectOption> options = new List<SelectOption>();
	if(lstSOs.size() > 1)
		options.add(new SelectOption('0','--Select Sales Org--'));
	for(Sales_Org__c s :lstSOs)	  
  		options.add(new SelectOption(s.Name, s.Name));
    return options;
  }
}