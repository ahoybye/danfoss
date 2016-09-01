global without sharing class PriceManagement {
            
    @future (callout = true)
    public static void GetSAPPrice(string sObjectId) {
        SAP_PriceService pr = new SAP_PriceService();
        SAP_PriceService.SAPPriceInput params = new SAP_PriceService.SAPPriceInput();
        QuoteLineItem lineitem = new QuoteLineItem();
        if (sObjectId.startsWith('0QL'))
        {
            lineitem = [select  Quote.Opportunity.Sales_Org__r.SAP_Sales_Org__c, Quote.Opportunity.Account.SAP_Account_ID__c, Quote.Opportunity.Account.Account_Group__c, Quote.Opportunity.Account.Channel__c, Quote.Opportunity.Account.Parent.SAP_Account_ID__c, Quote.Opportunity.Account.RecordType.Name, PricebookEntry.Product2.SAP_Material_Code__c, SAP_Price__c,  SAP_Currency__c, SAP_List_Price__c, UnitPrice From QuoteLineItem  where Id = :sObjectId];
            params.SalesOrgId = lineitem.Quote.Opportunity.Sales_Org__r.SAP_Sales_Org__c;
            params.AccountId = lineitem.Quote.Opportunity.Account.SAP_Account_ID__c;
            params.AccountGroup = lineitem.Quote.Opportunity.Account.Account_Group__c;
            params.Channel = lineitem.Quote.Opportunity.Account.Channel__c;
            params.acctRecType = lineitem.Quote.Opportunity.Account.RecordType.Name;
            params.ParentAccountId = lineitem.Quote.Opportunity.Account.Parent.SAP_Account_ID__c;
            params.ProductCode = lineitem.PricebookEntry.Product2.SAP_Material_Code__c;
        }
        
        SAP_PriceService.SAPPriceOutput outprice;
        outprice = pr.InvokeSAPPricing(params);
        lineitem.SAP_Price__c = outprice.SAPPrice;
        lineitem.SAP_Currency__c = outprice.SAPCurrency;
        lineitem.SAP_List_Price__c = outprice.SAPListPrice;
        update lineitem;
    }
    
    @future (callout = true)
    public static void GetSAPPriceOLI(string sObjectId, Id CRprod) {
        List<PS_Customer_Request__c> lstCustReqs = new List<PS_Customer_Request__c>([select Id, OpptyLineItemID__c from PS_Customer_Request__c where OpptyLineItemID__c = :sObjectId]);
        SAP_PriceService pr = new SAP_PriceService();
        SAP_PriceService.SAPPriceInput params = new SAP_PriceService.SAPPriceInput();
        OpportunityLineItem oli = [select Id, OpportunityId, Customer_Material_Number__c, CurrencyIsoCode, PricebookEntryId, PricebookEntry.Pricebook2Id, Opportunity.Account.Account_Group__c, Opportunity.Account.Channel__c, Opportunity.Account.Parent.SAP_Account_ID__c, Opportunity.Sales_Org__r.SAP_Sales_Org__c, Opportunity.Account.SAP_Account_ID__c, opportunity.Account.RecordType.Name, PricebookEntry.Product2.SAP_Material_Code__c, SAP_Price__c, SAP_Currency__c, SAP_List_Price__c from Opportunitylineitem where Id = :sObjectId];
        PricebookEntry pbe = [select Id from PricebookEntry where Product2Id = :CRprod and Pricebook2Id = :oli.PricebookEntry.Pricebook2Id and CurrencyIsoCode = :oli.CurrencyIsoCode limit 1];
        params.SalesOrgId = oli.Opportunity.Sales_Org__r.SAP_Sales_Org__c;
        params.AccountGroup = oli.Opportunity.Account.Account_Group__c;
        params.Channel = oli.Opportunity.Account.Channel__c;
        params.AccountId = oli.Opportunity.Account.SAP_Account_ID__c; 
        params.acctRecType = oli.opportunity.Account.RecordType.Name;
        params.ParentAccountId = oli.Opportunity.Account.Parent.SAP_Account_ID__c;
        params.ProductCode = oli.PricebookEntry.Product2.SAP_Material_Code__c;
        
        SAP_PriceService.SAPPriceOutput outprice;
        outprice = pr.InvokeSAPPricing(params);
        QuoteCloneUtility qcu = new QuoteCloneUtility(oli.Id);
        OpportunityLineItem oliClone = (OpportunityLineItem)qcu.newRecord;
        oliClone.put('SAP_Currency__c', outprice.SAPCurrency);
        oliClone.put('SAP_List_Price__c', outprice.SAPListPrice);
        oliClone.put('SAP_Price__c', outprice.SAPPrice);
        oliClone.put('PricebookEntryId', pbe.Id);
        insert oliClone;
        delete oli; 
        for(PS_Customer_Request__c cr : lstCustReqs){
            cr.OpptyLineItemID__c = oliClone.Id;
        }
        update lstCustReqs;
    }
}