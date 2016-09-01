/*************************************************************************************************************
* @author Allan Hoybye (Salesforce)
* @description  Batch class for migrating marketing attributes from custom object to the account object
*************************************************************************************************************/

global class batchMigrateMarketingAttribs implements Database.Batchable<SObject>, Database.Stateful, Schedulable {   

    global database.Querylocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(
                [SELECT id FROM Account where id in (select account__c from Account_Division_Data__c)]);                    
    }
    
    /***********************************************************************************************************
    * Execute method of batch class.
    * @param Database.BatchableContext
    * @param SObject[]
    * @return void.
    *********************************************************************************************************/
    global void execute(Database.BatchableContext BC, SObject[] scope) {
        list<Account> accs = scope;
        list<id> accIds = new List<Id>();
        map<id, account> mapAccs = new map<id, account>();                
        list<Account> lstForUpdate = new list<Account>();
        list<marketing_attrib_duplicate__c> duplValues = new list<marketing_attrib_duplicate__c>();
        for (account a : accs) {
            accIds.add(a.id);
            mapAccs.put(a.id, a);
            
        }
        
        list<Account_Division_Data__c> lstADD = [select id,account__c,Account_Division_Data_Config__r.Field_API__c, Account_Division_Data_Config__r.Type__c,Account_Division_Data_Config__c,valueAgg__c  from Account_Division_Data__c where Account_Division_Data_Config__r.Object_Type__c='Account' and account__c in :accIds and account__c!=null ORDER BY account__c,Account_Division_Data_Config__r.Field_API__c];
        
        Account a = null;
        ID accId = null;
        String field_api = '';
        string field_value = '';
        string field_type = '';
        string configId;
        for (Account_Division_Data__c ADD : lstADD) {
            // if new customer fetch that from map
            if (accId!=ADD.account__c) {
                accId  = ADD.account__c;
                a = mapAccs.get(accId); 
                lstForUpdate.add(a);
            } 
            
            // Same account and field - several values
            if (accId==ADD.account__c && field_api == ADD.Account_Division_Data_Config__r.Field_API__c) {                
                if (field_type=='multivalue picklist') { // if multi-value picklist - concatenate values
                    field_value = field_value + ';' + ADD.valueAgg__c;    
                } else { //Log duplicate value
                    marketing_attrib_duplicate__c dupl = new marketing_attrib_duplicate__c();
                    dupl.account__c = accId;
                    dupl.Marketing_Attribute_Setup__c = configId;
                    dupl.storedvalue__c=field_value;
                    dupl.skippedvalue__c=ADD.valueAgg__c;
                    dupl.Marketing_Attribute_Data__c = ADD.Id;
                    duplValues.add(dupl);
                    
                }
                
                
                
            } else {                                
                field_api = ADD.Account_Division_Data_Config__r.Field_API__c;
                field_value = ADD.valueAgg__c;
                field_type = ADD.Account_Division_Data_Config__r.Type__c;    
                configId = ADD.Account_Division_Data_Config__c;
            }
            
            if (field_type=='number')
               a.put(field_api, decimal.valueOf(field_value));
            else   
            a.put(field_api, field_value);
            
            
        }                
        
        update lstForUpdate;
        insert duplValues;                
    }
    
    /***********************************************************************************************************
    * Finish method of batch class.
    * @param Database.BatchableContext
    * @return void.
    *********************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
       
    }
    
    /***********************************************************************************************************
    * Execute method of scheduler class.
    * @param SchedulableContext
    * @return void.
    *********************************************************************************************************/
    global void execute(SchedulableContext sc) {         
        
        batchMigrateMarketingAttribs batchMigrate = new batchMigrateMarketingAttribs(); 
        database.executebatch(batchMigrate, 50);
    }
    
   
}