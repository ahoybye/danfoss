public class BusinessWarehouseReportExtension {
    
    public BusinessWarehouseReportExtension(ApexPages.StandardController controller) {
    }
    
    public List<BusinessWarehouseReport__c> getReports() {
        return [select Name, Report_URL__c from BusinessWarehouseReport__c];
    }
    
}