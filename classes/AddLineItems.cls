global without sharing class AddLineItems {

    public Opportunity opportunity{get;set;}
    public Quote quote{get;set;}
    public Machine_Model__c machine{get;set;}
    
    public String sObjectId;
    public String objName{get;set;}
    public String priceBookEntryId;
    public Boolean isOpportunity{get;set;}
    public Boolean isMachine{get;set;}
    public Boolean priceretrieved{get;set;}
    public Decimal SAPPrice;
    public Decimal SAPListPrice;
    public String SAPCurrency;
    public String materialNum;    
    public Boolean isSAPError{get;set;}
    public String iscloned;
    public String sapErrMsg{get;set;}
    public String salesorg;
    public String subsystem;
    public AddLineItems() {
      initializePage();                  
    } 
     
     public PageReference initializePage() {
        isOpportunity = false;
        isMachine = false;
        isSAPError = false;
        sObjectId = ApexPages.currentPage().getParameters().get('id');
        priceBookEntryId = ApexPages.currentPage().getParameters().get('priceBookEntryId');      
        iscloned = ApexPages.currentPage().getParameters().get('iscloned');
        salesorg = ApexPages.currentPage().getParameters().get('salesorg');          
        subsystem = ApexPages.currentPage().getParameters().get('subsystem');
        if (sObjectId.startsWith('a0Q')) {
            isMachine = true;
            List <Machine_Model__c> lstMachine = [Select Id, Account__r.RecordType.Name, Account__r.Account_Group__c, Account__r.Channel__c, Account__r.Parent.SAP_Account_ID__c,CurrencyIsoCode,Name, Account__r.SAP_Account_ID__c FROM Machine_Model__c Where Id = :sObjectId];
            if (lstMachine.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You have been redirected to incorrect link'));
                return null;
            }
            else {
                machine = lstMachine [0];
                objName = machine.Name;
            }
       } 
       else if(sObjectId.startsWith('006') ) {
         isOpportunity = true;
         List<opportunity> lstOppty = [Select Id, Account.RecordType.Name, Account.Account_Group__c, Account.Channel__c, Account.Parent.SAP_Account_ID__c,PriceBook2Id,CurrencyIsoCode,Name,Pricebook2.Name, Account.SAP_Account_ID__c, Sales_Org__r.SAP_Sales_Org__c FROM Opportunity Where Id = :sObjectId];
         if(lstOppty.isEmpty()) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'You have been redirected to incorrect link'));
           return null;
         }
         else {
           opportunity = lstOppty[0];
             objName = opportunity.Name;
         }
       } 
       else {
         List<quote> lstQuote = [SELECT Id, Opportunity.Account.RecordType.Name, Opportunity.Account.Account_Group__c, Opportunity.Account.Channel__c, Opportunity.Account.Parent.SAP_Account_ID__c,PriceBook2Id,CurrencyIsoCode,Name,Pricebook2.Name, Opportunity.Sales_Org__r.SAP_Sales_Org__c,Opportunity.Account.SAP_Account_ID__c FROM Quote Where Id = :sObjectId];
         if(lstQuote.isEmpty()){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'You have been redirected to incorrect link'));
             return null;
         }
         else {
          quote = lstQuote[0];
             objName = quote.Name;
         } 
       }
       lstLineItem = new List<OpportunityLineItem>();    
       lstQuoteLineItem = new List<QuoteLineItem>();  
       lstMachineLineItem = new List<Machine_Model_Product__c>();
       
        if (iscloned=='1') {
            lstQuoteLineItem = [select Id, ClonedFlag__c, priceBookEntry.Product2.Name, priceBookEntry.Product2.SAP_Material_Code__c, Quantity, UnitPrice, Distributor_Price__c, SAP_Price__c, SAP_List_Price__c, SAP_Currency__c, Description, PS_Customer_Product_Category__c From QuoteLineItem where QuoteId = :sObjectId];
            for(QuoteLineItem qli :lstQuoteLineItem)
                qli.ClonedFlag__c = 'true2';
        }
        else
            SelectProduct();
       return null;
     }
     
  //-----------------------------------------------------------------------------------//
    
  private List<OpportunityLineItem> lstLineItem;
  private List<QuoteLineItem> lstQuoteLineItem;
  private List<Machine_Model_Product__c> lstMachineLineItem;
  
  public String selectedProducts {get;set;}
  
  public Product2 searchProduct {get;set;}
  
  public List<OpportunityLineItem> getOpportunityLineItems() {
    return this.lstLineItem;
  }
  
   public List<QuoteLineItem> getQuoteLineItems() {
    return this.lstQuoteLineItem;
  }
   
   public List<Machine_Model_Product__c> getMachineLineItems() {
    return this.lstMachineLineItem;
  }
  //================================================================//
  //Save Line Items and return back to Opportunity
  //===============================================================//
  public PageReference SaveLineItems() {
    try {
      if(isMachine) {
        if (!checkForMissingRequiredFields(this.lstMachineLineItem))
            upsert this.lstMachineLineItem;
          else 
          {
              machine.adderror('Fields with red heading are required.');
              return null;
          }
      } 
      else if(isOpportunity) {
        upsert this.lstLineItem;
      } 
      else {
        upsert this.lstQuoteLineItem;
      }
    }
    catch(DmlException ex) {
      ApexPages.addMessages(ex);
      return null;
    }
    
    return new PageReference('/' + sObjectId);
  }
  
  //================================================================//
  //Save Line Items and return back to for product selection
  //===============================================================//  
  public PageReference SaveAndMore() {
    try {
       if(isMachine) {
       if (!checkForMissingRequiredFields(this.lstMachineLineItem))
            upsert this.lstMachineLineItem;
          else 
          {
              machine.adderror('Fields with red heading are required.');
              return null;
          }
      } 
      else if(isOpportunity) {
        upsert this.lstLineItem;
      } 
      else {
        upsert this.lstQuoteLineItem;
      }
    }
    catch(DmlException ex) {
      ApexPages.addMessages(ex);
      return null;
    }
    PageReference pg;
     if(isMachine) {
        pg = new PageReference('/apex/AddMachineProduct?id='+sobjectId);
      } 
      else if(isOpportunity) { 
      pg = new PageReference('/apex/AddOpportunityProduct?id='+sobjectId);
    }
    else {
      pg = new PageReference('/apex/AddQuoteProduct?id='+sobjectId);
    }
    pg.setRedirect(true);    
    return pg;
  }
  
  private Boolean checkForMissingRequiredFields(List<Machine_Model_Product__c> lstMMPROD)  //true = a required field is missing
  {
      Boolean missingfields = false;
      for (Machine_Model_Product__c mmp :lstMMPROD)
      {
          if(mmp.Subsystem__c == null || mmp.Product_Type__c == null || mmp.Competitiveness__c == null || mmp.Adoption_Rate__c == null || mmp.Number_per_machine__c <= 0)
            missingfields = true;
      }
      return missingfields;
  }
  
  public PageReference GetSAPPrice()
  {
        if (isMachine && salesorg == '0') {
          machine.addError('You must select a Sales Org to retrieve SAP Price');
          return null;
        }
        else{
            SAP_PriceService pr = new SAP_PriceService();
            SAP_PriceService.SAPPriceInput params = new SAP_PriceService.SAPPriceInput();
            
          if(isMachine){ 
             params.SalesOrgId = salesorg;
             params.AccountId = machine.Account__r.SAP_Account_ID__c;           
             params.AccountGroup = machine.Account__r.Account_Group__c;
             params.Channel = machine.Account__r.Channel__c;
             params.ParentAccountId = machine.Account__r.Parent.SAP_Account_ID__c;           
             params.acctRecType = machine.Account__r.RecordType.Name;
             params.ProductCode = materialNum;
          } else if(isOpportunity){ 
             params.SalesOrgId = opportunity.Sales_Org__r.SAP_Sales_Org__c;
             params.AccountId = opportunity.Account.SAP_Account_ID__c;           
             params.AccountGroup = opportunity.Account.Account_Group__c;
             params.Channel = opportunity.Account.Channel__c;
             params.ParentAccountId = opportunity.Account.Parent.SAP_Account_ID__c;          
             params.acctRecType = opportunity.Account.RecordType.Name;
             params.ProductCode = materialNum;
          } else {
             params.SalesOrgId = quote.Opportunity.Sales_Org__r.SAP_Sales_Org__c;
             params.AccountId = quote.Opportunity.Account.SAP_Account_ID__c;           
             params.AccountGroup = quote.Opportunity.Account.Account_Group__c;
             params.Channel = quote.Opportunity.Account.Channel__c;          
             params.acctRecType = quote.Opportunity.Account.RecordType.Name;
             params.ParentAccountId = quote.Opportunity.Account.Parent.SAP_Account_ID__c;         
             params.ProductCode = materialNum;          
          }
          SAP_PriceService.SAPPriceOutput outprice;
          try{
              outprice = pr.InvokeSAPPricing(params);
              SAPPrice = outprice.SAPPrice;
              SAPCurrency = outprice.SAPCurrency; 
              SAPListPrice = outprice.SAPListPrice;
              if(outprice.RetCode!='' && outprice.RetCode!=null){
                isSAPError = true;
                sapErrMsg = outprice.RetMessage;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,sapErrMsg));
              }
              if(outprice.SAPPrice != null && outprice.SAPPrice > 0)
                priceretrieved = true;
              else
                priceretrieved = false;
          }catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,pr.translateSAPError(e.getTypeName())));
          }           
          return null;
        }
  }
    
  //======================================================================//
  //Select Products and create Opportunity line Items
  //======================================================================//
  public PageReference SelectProduct() { 
        List <PriceBookEntry >lstPriceBookEntry = [Select Id,Product2Id, Product2.Name,Product2.SAP_Material_Code__c, UnitPrice FROM PriceBookEntry WHERE Id = :priceBookEntryId];
        if (lstPriceBookEntry.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You have been redirected to incorrect link'));
            return null;
        }
        for (PriceBookEntry priceBookEntry :lstPriceBookEntry) {
            materialNum = priceBookEntry.Product2.SAP_Material_Code__c;
            String prodId = priceBookEntry.Product2Id;
            if (isMachine && salesorg != '0') {
                GetSAPPrice();
            }
            if (isMachine) {
                lstMachineLineItem.add(CreateMachineLineItem(priceBookEntry));
            }
            else if (isOpportunity) {
                GetSAPPrice();
                lstLineItem.add(CreateOpportunityLineItem(priceBookEntry));
            }
            else {
                GetSAPPrice();
                lstQuoteLineItem.add(CreateQuoteLineItem(priceBookEntry));
            }
        }
//  }
    return null;
}

  //==============================================================================//
 //Create Machine Line Items
 //===============================================================================// 
private Machine_Model_Product__c CreateMachineLineItem(PriceBookEntry priceBookEntry) {
    Machine_Model_Product__c lineItem = new Machine_Model_Product__c(Machine_Model__c = this.machine.Id);
    lineItem.Machine_Model_Product__c = priceBookEntry.Product2Id;
    lineItem.Name = priceBookEntry.Product2.SAP_Material_Code__c;
    lineItem.Subsystem__c = subsystem;
    lineItem.Sales_Org__c = salesorg;
    lineItem.Adoption_Rate__c = 100;
    lineItem.Number_per_machine__c = 0;
    if (!isSAPError)
    {
        lineItem.Price__c = SAPPrice;
        lineItem.CurrencyIsoCode = SAPCurrency;
        lineItem.IsSAPPrice__c = true;
        lineItem.SAP_Price_Retrieved_Date__c = Datetime.now();
    }
    return lineItem;
  }
  
 //==============================================================================//
 //Create Opportunity Line Items
 //===============================================================================// 
  private OpportunityLineItem CreateOpportunityLineItem(PriceBookEntry priceBookEntry){
    OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = this.opportunity.Id);
    
    lineItem.UnitPrice = priceBookEntry.UnitPrice;
    lineItem.PricebookEntryId = priceBookEntry.Id;
    lineItem.PriceBookEntry = priceBookEntry;
    lineItem.Quantity = 0;
   // if (Opportunity.Sales_Org__c != '' && Opportunity.Sales_Org__c != null) {
        lineItem.SAP_Price__c = SAPPrice;
        lineItem.SAP_Currency__c = SAPCurrency;
        lineItem.SAP_List_Price__c = SAPListPrice;
   // }
   
    return lineItem;
  }
  
  //==============================================================================//
 //Create Opportunity Line Items
 //===============================================================================// 
  public QuoteLineItem CreateQuoteLineItem(PriceBookEntry priceBookEntry){
    QuoteLineItem lineItem = new QuoteLineItem(QuoteId = this.quote.Id);
    
    lineItem.UnitPrice = priceBookEntry.UnitPrice;
    lineItem.PricebookEntryId = priceBookEntry.Id;
    lineItem.PriceBookEntry = priceBookEntry;
    lineItem.Quantity = 0;
    lineItem.SAP_Price__c = SAPPrice;
    lineItem.SAP_Currency__c = SAPCurrency;
    lineItem.SAP_List_Price__c = SAPListPrice;
     
    return lineItem;
  }
  
  public PageReference cancel() {
      try {
        return new PageReference('/' + sObjectId);
      }
      catch(DmlException ex) {
        return new PageReference('/' + sObjectId);
      }
  }
   
  //================================================Currency Formatting==========================================/
  @RemoteAction
  global static String getTotalPrice(String quantity,String unitPrice) {
    String decimalSeparator = getDecimalSeparator();
    try {
      Decimal result = Decimal.valueOf(quantity) * Decimal.valueOf(unitPrice);
      result = result.setScale(2,System.RoundingMode.HALF_UP);  
     
      String formattedResult = result.format();     
      if(formattedResult.indexOf(decimalSeparator) == -1) {
       formattedResult += decimalSeparator + '00';
      }
      return formattedResult; 
    }
    catch(TypeException ex) {
       //GIGO garbage in,Garbage out
    }
    
    return '0'+ decimalSeparator + '00';
  } 
  
  /*
  *Returns the decimal separator for the current user locale to be used in js for number parsing
  */
  global static String getDecimalSeparator() {
    Decimal d = 0.25;
    return d.format().subString(1,2);
  }
  global static String getThousandSeparator() {
    Decimal d = 1000;
    return d.format().subString(1,2);
  }
  
}