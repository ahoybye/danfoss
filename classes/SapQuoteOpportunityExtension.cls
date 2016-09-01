/**
 * Deep links into SAP to create a quote for the sub account associated with the given opportunity.
 * If no sub account is associated with the opportunity, the page first asks the user to select one, and then saves the choice on the opportunity.
 */
public class SapQuoteOpportunityExtension {
    
    public ApexPages.StandardSetController setCon {get;set;}
    public Id selectedDD {get;set;}
    private Opportunity o;
    
    public SapQuoteOpportunityExtension(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String> {'AccountId', 'Sub_Account__c', 'Account.CE_SAP_Account_ID__c'});
        }
        o = (Opportunity) stdController.getRecord();
        if (o.Sub_Account__c == null) {
            String soqlFields = 'Id';
            for (FieldSetMember field : SObjectType.Sub_Account__c.FieldSets.SapQuoteFields.getFields()) {
                soqlFields += ', ' + field.getFieldPath();
            }
            ID accId = o.AccountId;
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator('select ' + soqlFields + ' from Sub_Account__c where Account__c = :accId'));
            setCon.setPageSize(8);
        } else {
            selectedDD = o.Sub_Account__c;
        }
    }
    
    public PageReference init() {
        if (selectedDD == null) {
            if (setCon.getRecords().isEmpty()) {
            	return new PageReference(SAP_URLs__c.getInstance().Create_SAP_CRM_Quote_URL__c.replace('{SAPID}', '' + o.Account.CE_SAP_Account_ID__c));
            }
            return null;
        } else {
            return doCreateQuote();
        }
    }
    
    public List<Sub_Account__c> getDiv() {
        return setCon.getRecords();
    }
    
    public PageReference CreateQuote() {
        o.Sub_Account__c = selectedDD;
        try {
            update o;
        } catch (DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        return doCreateQuote();
    }
    
    public PageReference doCreateQuote() {
        Sub_Account__c sap_cust = [select SAP_Account_ID__c from Sub_Account__c where Id = :selectedDD];
        PageReference pageRef = new PageReference(SAP_URLs__c.getInstance().Create_SAP_CRM_Quote_URL__c.replace('{SAPID}', '' + sap_cust.SAP_Account_ID__c));
        return pageRef;
    }
    
}