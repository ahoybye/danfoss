public class ProductTriggerHandler {
    
    public static ID climateAndEnergyProductRecordTypeId = [select Id from RecordType where SobjectType = 'Product2' and DeveloperName = 'Product_CE'].Id;
    public static ID powerSolutionsProductRecordTypeId = [select Id from RecordType where SobjectType = 'Product2' and DeveloperName = 'Product_PS'].Id;
    private static ID standardPricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [select Id from Pricebook2 where IsStandard = true].Id;
    private static ID climateAndEnergyPricebookId = [select Id from Pricebook2 where Name = 'Climate and Energy'].Id;
    private static List<CurrencyType> activeCurrencies = [select IsoCode from CurrencyType where IsActive = true];
    
    /**
     * If the product is a C&E product, add it to the C&E pricebook with zero price for all currencies.
     * @author Jesper Kristensen, Capgemini Sogeti, January 2015
     */
    public static void createClimateAndEnergyPricebookEntries(List<Product2> products) {
        List<PricebookEntry> pbEntriesToInsert = new List<PricebookEntry>();
        for (Product2 product : products) {
            if (product.RecordTypeId == climateAndEnergyProductRecordTypeId) {
                for (CurrencyType curr : activeCurrencies) {
                    pbEntriesToInsert.add(new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product.Id, UnitPrice = 0, IsActive = true, CurrencyIsoCode = curr.IsoCode));
                    pbEntriesToInsert.add(new PricebookEntry(Pricebook2Id = climateAndEnergyPricebookId, Product2Id = product.Id, UnitPrice = 0, IsActive = true, CurrencyIsoCode = curr.IsoCode));
                }
            }
        }
        insert pbEntriesToInsert;
    }
    
    public static void setRecordType(List<Product2> products) {
        for (Product2 product : products) {
            if (product.SAP_Material_Code_CE__c != null) {
                product.RecordTypeId = climateAndEnergyProductRecordTypeId;
            } else {
                product.RecordTypeId = powerSolutionsProductRecordTypeId;
            }
        }
    }
    
}