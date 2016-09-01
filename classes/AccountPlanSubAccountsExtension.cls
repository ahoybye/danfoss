public class AccountPlanSubAccountsExtension {
    
    public List<Sales_Area__c> salesAreas {get;set;}
    
    public AccountPlanSubAccountsExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String> {'Account__c'});
        }
        String soqlFields = 'Id';
        for (FieldSetMember field : SObjectType.Sales_Area__c.FieldSets.AccountRelatedListColumns.getFields()) {
            soqlFields += ', ' + field.getFieldPath();
        }
        ID accountId = ((Account_Plan__c) controller.getRecord()).Account__c;
        salesAreas = Database.query('select ' + soqlFields + ' from Sales_Area__c where Sub_Account__r.Account__c = :accountId');
    }
    
}