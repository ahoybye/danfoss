/* 
    Custom controller extension to create marketing attributes
    
    2014.10.22 Allan Hoybye (Salesforce)
    
    2014.10.22/AH - Initial version
    2014.11.14/AH - Moved config from custom setting to custom object
    2014.11.17/AH - Support for multi-value picklists
    2014.01.20/AH - multi-value picklist values on separate records
    

*/
public class MarketingAttributeExtension {

    //private final account a;
    private final Id objId;
    private final string type;
    private final string retURL;
    private Account_Division_Data__c divData;
    
    public boolean isPickList {get;set;}
    public boolean isText {get;set;}
    public boolean isNumber {get;set;}
    public boolean isMultiValuePicklist {get;set;}

    public Boolean isCreate { get; set; }
    public List<SelectOption> valueOptions { get; set; }
    public List<SelectOption> attribSetOptions { get; set; }
    public List<SelectOption> attribOptions { get; set; }
    
    public String attribSetValue {get;set;}
    public String attribValue {get;set;}
    
    /* Get and Set functions */    
    public String[] selectedValues { get; set; }
    
    
    public MarketingAttributeExtension(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String>{'Account_Division_Data_Config__c', 'division_lkp__c'});
        }
        objId = System.currentPagereference().getParameters().get('objid');
        type = System.currentPagereference().getParameters().get('type');
        retURL = System.currentPagereference().getParameters().get('retURL');
        divData = (Account_Division_Data__c)stdController.getRecord();
        
        isCreate = divData.Id == null;
        attribSetValue = divData.Attribute_Set_lkp__c;
        attribValue = divData.Attribute_lkp__c;
        
        getAttribSetValues();
        getAttribValues();
        getPicklistValues();
        
        System.assert(objId != null, 'No account/contact was selected');
        
        if (type == 'Account') {
            divData.account__c = objId;
        } else if (type == 'Contact') {
            divData.contact__c = objId;
        } else {
            System.assert(false);
        }
        
    }
    
    public void getPicklistValues()
    {
        isNumber=false;
        isPicklist=false;
        isText=false;
        isMultiValuePicklist=false;
        
        valueOptions = new List<SelectOption>();
        
        divData.Account_Division_Data_Config__c = null;
        
        Account_Division_Data_Config__c DivAttributeConfig;
        // Find the configuration for the selected attribute.
        // If it is a dependent picklist, there is multiple records for the same attribute. In this case we pick one of them (using "limit 1").
        List<Account_Division_Data_Config__c> DivAttributeConfigs = [
            select Id, Attribute__c, Picklist_Values__c, Type__c, Attribute_Set__c, division__c, Controlling_Field__c, Controlling_Value__c
            from Account_Division_Data_Config__c
            where Attribute__c = :attribValue and Attribute_Set__c = :attribSetValue and Object_Type__c = :type
        ];
        if (DivAttributeConfigs.size() == 0) {
            // No attribute selected yet.
            return;
        } else if (DivAttributeConfigs.size() == 1) {
            DivAttributeConfig = DivAttributeConfigs[0];
        } else {
            // We have multiple configs. Only dependent picklists should have multiple configs. Assume this is a dependent picklist.
            String controllingValue = null;
            String controllingField = DivAttributeConfigs[0].Controlling_Field__c;
            try {
                SObject obj = Database.query('select ' + controllingField + ' from ' + type + ' where Id =\'' + objId + '\'');
                controllingValue = (String) obj.get(controllingField);
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'This attribute has an invalid controlling field: ' + controllingField));
                return;
            }
            for (Account_Division_Data_Config__c cfg : DivAttributeConfigs) {
                if (cfg.Controlling_Value__c == controllingValue) {
                    DivAttributeConfig = cfg;
                    break;
                }
            }
            if (DivAttributeConfig == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'This attribute has an invalid controlling field value: ' + controllingValue));
                return;
            }
        }
        
        divData.Account_Division_Data_Config__c = DivAttributeConfig.Id;
        
        if (DivAttributeConfig.Type__c == 'text') {
            isText=true;
        } else if (DivAttributeConfig.Type__c == 'number') {
            isNumber=true;
        } else if (DivAttributeConfig.Type__c == 'picklist') {
            isPicklist=true;
        } else if (DivAttributeConfig.Type__c == 'multivalue picklist') {
            isMultiValuePicklist=true;
            List<Account_Division_Data__c>  selection = new List<Account_Division_Data__c>();
            if (type == 'Account') {                
                selection=[SELECT Value__c FROM Account_Division_Data__c WHERE Account__c = :objId AND Account_Division_Data_Config__c=:divData.Account_Division_Data_Config__c];
            } else {
                selection=[SELECT Value__c FROM Account_Division_Data__c WHERE Contact__c = :objId AND Account_Division_Data_Config__c=:divData.Account_Division_Data_Config__c];
            }
            List<String> values = new List<String>();
            for (Account_Division_Data__c addata : selection){
                values.add(addata.Value__c);
            }
            selectedValues=values;
            
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'This attribute is marked with an invalid type: ' + DivAttributeConfig.Type__c));
            return;
        }
        
        if (isPicklist || isMultiValuePicklist) {
            String values = DivAttributeConfig.Picklist_Values__c;
            if (values == null) {
                values = '';
            }
            List<String> lines = values.split('\n');
            for (String value : lines) {
                value = value.trim();
                valueOptions.add(new SelectOption(value, value));
            }            
        }
    }
    
    public void getAttribSetValues() {
        attribSetOptions = new List<SelectOption>();
        attribSetOptions.add(new SelectOption('-','-'));
        for (AggregateResult ar : [SELECT Attribute_Set__c from Account_Division_Data_Config__c WHERE Object_Type__c = :type GROUP BY Attribute_Set__c]) { 
            String attribSet = (String) ar.get('Attribute_Set__c');
            attribSetOptions.add(new SelectOption(attribSet, attribSet));
        }
    }
    
    public void getAttribValues() {
        List<String> existingAttributes = new List<String>();
        if (type == 'Account') {
            for (Account_Division_Data__c add : [select Attribute_lkp__c from Account_Division_Data__c where account__c = :objId and Attribute_Set_lkp__c = :attribSetValue and Account_Division_Data_Config__r.Type__c!='multivalue picklist']) {
                existingAttributes.add(add.Attribute_lkp__c);
            }
        } else {
            for (Account_Division_Data__c add : [select Attribute_lkp__c from Account_Division_Data__c where contact__c = :objId and Attribute_Set_lkp__c = :attribSetValue and Account_Division_Data_Config__r.Type__c!='multivalue picklist']) {
                existingAttributes.add(add.Attribute_lkp__c);
            }
        }
        
        attribOptions = new List<SelectOption>();
        attribOptions.add(new SelectOption('-','-'));
        for (AggregateResult da : [
            SELECT Attribute__c
            FROM Account_Division_Data_Config__c
            WHERE Attribute_Set__c = :attribSetValue and Object_Type__c = :type and Attribute__c not in :existingAttributes
            GROUP BY Attribute__c
            ORDER BY Attribute__c
        ]) { 
            String attr = (String) da.get('Attribute__c');
            attribOptions.add(new SelectOption(attr, attr));
        }
    }
    
    public PageReference saveAndNew() {
        doSave();
        PageReference pr = Page.MarketingAttribute;
        pr.getParameters().put('objid', objId);
        pr.getParameters().put('type', type);
        pr.getParameters().put('retURL', retURL);
        return pr;
    }
    
    private void doSave() {
        if (isMultiValuePicklist) {
            List<Account_Division_Data__c>  delmarker = new List<Account_Division_Data__c>();
            if (type == 'Account') {                
                delmarker=[SELECT Id FROM Account_Division_Data__c WHERE Account__c=:divData.Account__c AND Account_Division_Data_Config__c=:divData.Account_Division_Data_Config__c];
            } else {
                delmarker=[SELECT Id FROM Account_Division_Data__c WHERE Contact__c=:divData.Contact__c AND Account_Division_Data_Config__c=:divData.Account_Division_Data_Config__c];
            }
            
            delete delmarker;
            
            String[] values=this.selectedValues;
            
            for (String val : this.selectedValues){
                Account_Division_Data__c addata = new Account_Division_Data__c();
                addata.Account__c=divData.Account__c;
                addata.Contact__c=divData.Contact__c;
                addata.Account_Division_Data_Config__c=divData.Account_Division_Data_Config__c;
                addata.Value__c=val;
                insert addata;
            }
            
            
        } else {
            upsert divData;
        }
    }
    
    public PageReference save() {
        doSave();
        return new PageReference(retURL);
    }
    
    public String getType() {
        return type;
    }
    
}