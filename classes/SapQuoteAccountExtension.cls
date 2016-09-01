/**
 * Asks the user to select a sub account related to the given account, and then deep links into SAP to create a quote for the selected sub account.
 */
public class SapQuoteAccountExtension {
    
    private final Account a;
    public ApexPages.StandardSetController setCon {get;set;}
    public Id selectedDD {get;set;}
    
    public SapQuoteAccountExtension(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String> {'CE_SAP_Account_ID__c'});
        }
        a = (Account) stdController.getRecord();

        String soqlFields = 'Id';
        for (FieldSetMember field : SObjectType.Sub_Account__c.FieldSets.SapQuoteFields.getFields()) {
            soqlFields += ', ' + field.getFieldPath();
        }        
        ID accId = stdController.getId();        
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator('select ' + soqlFields + ' from Sub_Account__c where Account__c = :accId'));
        setCon.setPageSize(8);
    }
    
    public PageReference init() {
        if (setCon.getRecords().isEmpty()) {
            return new PageReference(SAP_URLs__c.getInstance().Create_SAP_CRM_Quote_URL__c.replace('{SAPID}', '' + a.CE_SAP_Account_ID__c));
        }
        return null;
    }
    
    public List<Sub_Account__c> getDiv() {
        return setCon.getRecords();
    }
    
    public PageReference CreateQuote() {
        Sub_Account__c sap_cust = [select SAP_Account_ID__c from Sub_Account__c where Id = :selectedDD];
        PageReference pageRef = new PageReference(SAP_URLs__c.getInstance().Create_SAP_CRM_Quote_URL__c.replace('{SAPID}', '' + sap_cust.SAP_Account_ID__c));
        return pageRef;
    }
    
}