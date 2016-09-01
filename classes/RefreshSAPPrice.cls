public class RefreshSAPPrice{
   public String sObjectId;
   public String lineItemId;
   public Boolean isOpportunity;
   public Boolean isMachine;
   public Opportunitylineitem oli;
   public Quotelineitem qli;
   public Machine_Model_Product__c mmprod;
   
   private ApexPages.StandardController controller;
    
   public RefreshSAPPrice(ApexPages.StandardController controller){
    this.controller = controller;
    isOpportunity=false;
    isMachine=false;
    sObjectId = ApexPages.currentPage().getParameters().get('id');
    if (sObjectId.startsWith('a0Q')) {
        isMachine = true;
        lineItemId = ApexPages.currentPage().getParameters().get('mmprodId');
    }
    else if(sObjectId.startsWith('006') ) {
        isOpportunity = true;
        lineItemId = ApexPages.currentPage().getParameters().get('opportunityLineItemId');
    }
    else {
        lineItemId = ApexPages.currentPage().getParameters().get('quoteLineItemId');
    }
   }
   
   public PageReference autorun(){
    String errMsg;
    
    SAP_PriceService pr = new SAP_PriceService();
    SAP_PriceService.SAPPriceInput params = new SAP_PriceService.SAPPriceInput();
    SAP_PriceService.SAPPriceOutput outprice;   
    
    if(isMachine){ 
         mmprod = [Select Id, Machine_Model__r.Account__r.RecordType.Name, Machine_Model__r.Account__r.Account_Group__c, Machine_Model__r.Account__r.SAP_Account_ID__c, Machine_Model__r.Account__r.Channel__c, Machine_Model__r.Account__r.Parent.SAP_Account_ID__c, CurrencyIsoCode, Name, Machine_Model__r.Account__c, Sales_Org__c, Machine_Model_Product__r.SAP_Material_Code__c FROM Machine_Model_Product__c Where Id = :lineItemId];
         params.SalesOrgId = mmprod.Sales_Org__c;
         params.AccountId = mmprod.Machine_Model__r.Account__r.SAP_Account_ID__c;           
         params.AccountGroup = mmprod.Machine_Model__r.Account__r.Account_Group__c;
         params.Channel = mmprod.Machine_Model__r.Account__r.Channel__c;
         params.ParentAccountId = mmprod.Machine_Model__r.Account__r.Parent.SAP_Account_ID__c;           
         params.acctRecType = mmprod.Machine_Model__r.Account__r.RecordType.Name;
         params.ProductCode = mmprod.Machine_Model_Product__r.SAP_Material_Code__c;
        
        system.debug(params);
        try{
            outprice = pr.InvokeSAPPricing(params);  
            mmprod.Price__c = outprice.SAPPrice;
            mmprod.IsSAPPrice__c = true;
            mmprod.CurrencyISOCode = outprice.SAPCurrency;  
            mmprod.SAP_Price_Retrieved_Date__c = Datetime.now();        
            update mmprod;  
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,pr.translateSAPError(e.getTypeName())));
            return null;
        }
    }
    else if(isOpportunity){ 
        oli = [select Id, Opportunity.Account.Account_Group__c, Opportunity.Account.Channel__c, Opportunity.Account.Parent.SAP_Account_ID__c, Opportunity.Sales_Org__r.SAP_Sales_Org__c,Opportunity.Account.SAP_Account_ID__c,PricebookEntry.Product2.SAP_Material_Code__c, SAP_Price__c, SAP_Currency__c, SAP_List_Price__c from Opportunitylineitem where Id =: lineItemId];
        system.debug(oli);
        params.SalesOrgId = oli.Opportunity.Sales_Org__r.SAP_Sales_Org__c;
        params.AccountGroup = oli.Opportunity.Account.Account_Group__c;
        params.Channel = oli.Opportunity.Account.Channel__c;
        params.AccountId = oli.Opportunity.Account.SAP_Account_ID__c;
        params.ParentAccountId = oli.Opportunity.Account.Parent.SAP_Account_ID__c;
        params.ProductCode = oli.PricebookEntry.Product2.SAP_Material_Code__c;
        
        system.debug(params);
        try{
            outprice = pr.InvokeSAPPricing(params);  
            oli.SAP_Price__c = outprice.SAPPrice;
            oli.SAP_List_Price__c = outprice.SAPListPrice;
            oli.SAP_Currency__c = outprice.SAPCurrency;         
            update oli;  
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,pr.translateSAPError(e.getTypeName())));
            return null;
        }
    }else{
        qli = [select Id, Quote.Opportunity.Account.Account_Group__c, Quote.Opportunity.Account.Channel__c, Quote.Opportunity.Account.Parent.SAP_Account_ID__c, Quote.Opportunity.Sales_Org__r.SAP_Sales_Org__c, Quote.Opportunity.Account.SAP_Account_ID__c, PricebookEntry.Product2.SAP_Material_Code__c, SAP_Price__c, SAP_Currency__c, SAP_List_Price__c from Quotelineitem where Id =: lineItemId];
        params.SalesOrgId = qli.Quote.Opportunity.Sales_Org__r.SAP_Sales_Org__c;
        params.AccountGroup = qli.Quote.Opportunity.Account.Account_Group__c;
        params.Channel = qli.Quote.Opportunity.Account.Channel__c;
        params.AccountId = qli.Quote.Opportunity.Account.SAP_Account_ID__c;
        params.ParentAccountId = qli.Quote.Opportunity.Account.Parent.SAP_Account_ID__c;
        params.ProductCode = qli.PricebookEntry.Product2.SAP_Material_Code__c;

        try{
        outprice = pr.InvokeSAPPricing(params);
        qli.SAP_Price__c = outprice.SAPPrice;
        qli.SAP_List_Price__c = outprice.SAPListPrice;
        qli.SAP_Currency__c = outprice.SAPCurrency;
        update qli;         
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,pr.translateSAPError(e.getTypeName())));
            return null;            
        }
    }
    if(outprice.RetCode!=null && outprice.RetCode!=''){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,outprice.RetMessage));
        return null;
    } else  
        return saveAndReturn();
   }
   
    public PageReference saveAndReturn()
    {
         /*   PageReference cancel = controller.cancel();
            controller.save();
            return cancel;
         */
         PageReference liPage;
        if(isMachine){
            liPage = new ApexPages.StandardController(mmprod).view();         
        }
        else if (isOpportunity){
            liPage = new ApexPages.StandardController(oli).view();              
         }else{
            liPage = new ApexPages.StandardController(qli).view();      
         }
         liPage.setRedirect(true);
         return liPage;
    }
}