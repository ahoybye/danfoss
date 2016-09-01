public class ShowMarketingAttributesExtension {

    private final Id objId;
    private final String type;
    public List<SelectOption> statusOptions { get; set; }
    public String selectedValue { get; set; }
    public ApexPages.StandardSetController setCon { get; set; }
    public Id selectedADD { get; set; }
    
    public ShowMarketingAttributesExtension(ApexPages.StandardController stdController) {
        SObject record = stdController.getRecord();
        objId = stdController.getId();
        if (record instanceof Account) {
            type = 'Account';
        } else if (record instanceof Contact) {
            type = 'Contact';
        } else {
            System.assert(false);
        }

        statusOptions = new List<SelectOption>();
        Set<String> divisions = new Set<String>();
        for (AggregateResult ar : [select Division__c from Account_Division_Data_config__c where Division__c != null group by Division__c order by Division__c]) {
            String division = (String) ar.get('Division__c');
            statusOptions.add(new SelectOption(division, division));
            divisions.add(division);
        }
        
        selectedValue = System.currentPagereference().getParameters().get('division');
        if (selectedValue == null) {
            id uid = UserInfo.getUserId(); 
            selectedValue = [select Division__c from User where Id = :uid].Division__c;
        }
        if (!divisions.contains(selectedValue)) {
            // Invalid value, pick some valid value
            selectedValue = 'All';
        }
        
        initSetCon();
    }
    
    private void initSetCon() {
        id uid = UserInfo.getUserId(); 
        string division = selectedValue;
        if (type == 'Account') {
            if (division == 'All') {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Account__c,Attribute_lkp__c,Attribute_Set_lkp__c, name, division_lkp__c, Value__c, ValueNumber__c, ValueAgg__c FROM Account_Division_Data__c where account__c =:objId  ORDER BY division_lkp__c,Attribute_Set_lkp__c,Attribute_lkp__c]));
            } else {                    
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Account__c,Attribute_lkp__c,Attribute_Set_lkp__c, name, division_lkp__c, Value__c, ValueNumber__c, ValueAgg__c FROM Account_Division_Data__c where account__c =:objId and (division_lkp__c =:division or division_lkp__c ='All') ORDER BY division_lkp__c,Attribute_Set_lkp__c,Attribute_lkp__c]));
            }
        } else if (type == 'Contact') {
            if (division == 'All') {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Account__c,Attribute_lkp__c,Attribute_Set_lkp__c, name, division_lkp__c, Value__c, ValueNumber__c, ValueAgg__c FROM Account_Division_Data__c where contact__c =:objId ORDER BY division_lkp__c,Attribute_Set_lkp__c,Attribute_lkp__c]));
            } else {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Account__c,Attribute_lkp__c,Attribute_Set_lkp__c, name, division_lkp__c, Value__c, ValueNumber__c, ValueAgg__c FROM Account_Division_Data__c where contact__c =:objId and (division_lkp__c =:division or division_lkp__c ='All') ORDER BY division_lkp__c,Attribute_Set_lkp__c,Attribute_lkp__c]));
            }
        } else {
            System.assert(false);
        }
        setCon.setPageSize(8);
    }
    
    public List<Account_Division_Data__c> getADDs() {
        return (List<Account_Division_Data__c>) setCon.getRecords();
    }
    
    public void filterADDs() {
        initSetCon();
    }
    
    public PageReference CreateADD() {
        PageReference pr = Page.MarketingAttribute;
        pr.getParameters().put('objid', objId);
        pr.getParameters().put('type', type);
        pr.getParameters().put('retURL', getRetURL());
        return pr;
    }
    
    public PageReference EditADD() {
        PageReference pr = Page.MarketingAttribute;
        pr.getParameters().put('objid', objId);
        pr.getParameters().put('type', type);
        pr.getParameters().put('Id', selectedADD);
        pr.getParameters().put('retURL', getRetURL());
        return pr;
    }
    
    private String getRetURL() {
        if (type == 'Account') {
            return '/apex/showAccountAttributes?Id=' + objId + '&division=' + selectedValue;
        } else {
            return '/apex/showContactAttributes?Id=' + objId + '&division=' + selectedValue;
        }
    }
    
    public void DeleteADD() {
        delete new Account_Division_Data__c(Id = selectedADD);
        initSetCon();
    }
    
    public showMarketingAttributesExtension getThis() {
        return this;
    }
    
}