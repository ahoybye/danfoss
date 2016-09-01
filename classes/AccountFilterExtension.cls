public class AccountFilterExtension {

    private final ID objId;
    public List<SelectOption> divisionOptions { get; set; }
    public String selectedDivision { get; set; }
    public ApexPages.StandardSetController setCon { get; set; }
    
    public AccountFilterExtension(ApexPages.StandardController stdController) {
        objId = stdController.getId();
        selectedDivision = [select division__c from user where id = :UserInfo.getUserId()].division__c;
        divisionOptions = new List<SelectOption>();
  		
        Boolean foundSelectedValue = false;
        String firstValue = null;
    	for (AggregateResult ar : [select Division__c from Sub_Account__c where Account__c = :objId group by Division__c order by Division__c]) {
            String division = (String) ar.get('Division__c');
            
            if (division == null) {
                division = '';
            }
            
        	divisionOptions.add(new SelectOption(division, division));
            
            if (selectedDivision == division) {
                foundSelectedValue = true;
            }
            if (firstValue == null) {
                firstValue = division;
            }
        }
        
        if (!foundSelectedValue) {
            selectedDivision = firstValue;
        }
        
        initSetCon();
    }
    
    
    private void initSetCon() {
        List<String> fields = new List<String>();
        for (FieldSetMember field : SObjectType.Sub_Account__c.FieldSets.AccountFilterFields.getFields()) {
            fields.add(field.getFieldPath());
        }
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator('select ' + String.join(fields, ', ') + ' from Sub_Account__c where Account__c = :objId and Division__c = :selectedDivision order by Name'));
        setCon.setPageSize(3);
    }

    public List<Sub_Account__c> getSAP() {
        return setCon.getRecords();
    }
    
    public void filterSAP() {
        initSetCon();
    }

}