@isTest
public class Test_MarketingAttributeExtension {
    
    static testMethod void test() {
        Account_Division_Data_config__c cfg1 = new Account_Division_Data_config__c(Object_Type__c = 'Account', Division__c = 'All', Attribute_Set__c = 'x', Attribute__c = '1', Type__c = 'text');
        Account_Division_Data_config__c cfg2 = new Account_Division_Data_config__c(Object_Type__c = 'Account', Division__c = 'abc', Attribute_Set__c = 'y', Attribute__c = '2', Type__c = 'picklist', Picklist_Values__c = 'i\r\nj\r\nk');
        Account_Division_Data_config__c cfg3 = new Account_Division_Data_config__c(Object_Type__c = 'Account', Division__c = 'abc', Attribute_Set__c = 'y', Attribute__c = '3', Type__c = 'text');
        Account_Division_Data_config__c cfg4 = new Account_Division_Data_config__c(Object_Type__c = 'Account', Division__c = 'def', Attribute_Set__c = 'z', Attribute__c = '4', Type__c = 'text');
        insert new List<Account_Division_Data_config__c> {cfg1, cfg2, cfg3, cfg4};
        
        Account account = Test_Utility.createAccount(0);
        insert account;
        Account_Division_Data__c attr0 = new Account_Division_Data__c(Account__c = account.Id, Account_Division_Data_Config__c = cfg3.Id);
        insert new List<Account_Division_Data__c> {attr0};
        
        Test.startTest();
        
        Account_Division_Data__c attr1 = new Account_Division_Data__c(Account__c = account.Id);
        //System.currentPagereference().getParameters().put('division', 'abc');
        System.currentPagereference().getParameters().put('objid', account.Id);
        System.currentPagereference().getParameters().put('type', 'Account');
        System.currentPagereference().getParameters().put('retURL', '/abc');
        MarketingAttributeExtension c = new MarketingAttributeExtension(new ApexPages.StandardController(attr1));
        System.assertEquals(true, c.isCreate);
        System.assertEquals(4, c.attribSetOptions.size(), c.attribSetOptions); // blank + "x" + "y" + "z"
        System.assertEquals('y', c.attribSetOptions[2].getValue());
        c.attribSetValue = 'y';
        c.getAttribValues();
        System.assertEquals(2, c.attribOptions.size()); // blank + "2" ("3" should not be available since the account already has this attribute)
        System.assertEquals('2', c.attribOptions[1].getValue());
        c.attribValue = '2';
        c.getPicklistValues();
        System.assertEquals(3, c.valueOptions.size(), c.valueOptions); // "i" + "j" + "k"
        System.assert(c.isPicklist);
        attr1.Value__c = 'test';
        PageReference pr = c.save();
        
        Test.stopTest();
        
        System.assert(ApexPages.getMessages().isEmpty());
        System.assertNotEquals(null, pr);
        
        /*System.assertEquals(3, c.getADDs().size());
        
        c.selectedValue = 'abc';
        c.filterADDs();
        System.assertEquals(2, c.getADDs().size());
        
       	System.assertNotEquals(null, c.CreateADD());
        
        c.selectedADD = attr2.Id;
        System.assertNotEquals(null, c.EditADD());
        
        c.selectedADD = attr2.Id;
        c.DeleteADD();
        System.assertEquals(2, [select Id from Account_Division_Data__c].size());*/
    }
    
}