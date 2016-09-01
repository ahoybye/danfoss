public class MarkOliAsLostExtension {
    
    private ApexPages.StandardController controller;
    
    public MarkOliAsLostExtension(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference moveToLost() {
        ID oliId = controller.getId();
        OpportunityLineItem opptLineItem = [select OpportunityId, Product2Id, Quantity, UnitPrice, CurrencyIsoCode from OpportunityLineItem where Id = :oliId];
        
        Opportunity_Lost_Product__c opptLostItem = new Opportunity_Lost_Product__c(
            Opportunity__c = opptLineItem.OpportunityId,
            Product__c = opptLineItem.Product2Id,
            Quantity__c = opptLineItem.Quantity,
            Price__c = opptLineItem.UnitPrice,
            CurrencyIsoCode = opptLineItem.CurrencyIsoCode
        );
        
        insert opptLostItem;
        delete opptLineItem;
        
        return controller.cancel();
    }
    
}