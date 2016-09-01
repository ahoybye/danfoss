public with sharing class AccountSalesAreasExtension {
    
    public List<Sales_Area__c> salesAreas {get;set;}
    
    public AccountSalesAreasExtension(ApexPages.StandardController controller) {
        String soqlFields = 'Id';
        for (FieldSetMember field : SObjectType.Sales_Area__c.FieldSets.AccountRelatedListColumns.getFields()) {
            soqlFields += ', ' + field.getFieldPath();
        }
        ID accountId = controller.getId();
        salesAreas = Database.query('select ' + soqlFields + ' from Sales_Area__c where Sub_Account__r.Account__c = :accountId');
    }
    
}