/*************************************************************************************************************
* @author Allan Hoybye (Salesforce)
* @description  Batch class for migrating marketing attributes from custom object to the account object
*************************************************************************************************************/

global class batchContactMigrateMarketingAttribs implements Database.Batchable<SObject>, Database.Stateful, Schedulable {   

    global database.Querylocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(
                [SELECT id FROM Contact where id in (select contact__c from Account_Division_Data__c)]);                    
    }
    
    /***********************************************************************************************************
    * Execute method of batch class.
    * @param Database.BatchableContext
    * @param SObject[]
    * @return void.
    *********************************************************************************************************/
    global void execute(Database.BatchableContext BC, SObject[] scope) {
        list<contact> cons = scope;
        list<id> conIds = new List<Id>();
        map<id, contact> mapCons= new map<id, contact>();                
        list<Contact> lstForUpdate = new list<Contact>();
        list<marketing_attrib_duplicate__c> duplValues = new list<marketing_attrib_duplicate__c>();
        for (contact c : cons) {
            conIds.add(c.id);
            mapCons.put(c.id, c);
            
        }
        
        list<Account_Division_Data__c> lstADD = [select id,Contact__c,Account_Division_Data_Config__r.Field_API__c, Account_Division_Data_Config__r.Type__c,Account_Division_Data_Config__c,valueAgg__c  from Account_Division_Data__c where Account_Division_Data_Config__r.Object_Type__c='Contact' and contact__c in :conIds and contact__c!=null ORDER BY contact__c,Account_Division_Data_Config__r.Field_API__c];
        
        Contact c = null;
        ID conId = null;
        String field_api = '';
        string field_value = '';
        string field_type = '';
        string configId;
        for (Account_Division_Data__c ADD : lstADD) {
            // if new customer fetch that from map
            if (conId!=ADD.contact__c) {
                conId  = ADD.contact__c;
                c = mapcons.get(conId); 
                lstForUpdate.add(c);
            } 
            
            // Same Contact and field - several values
            if (conId==ADD.contact__c && field_api == ADD.Account_Division_Data_Config__r.Field_API__c) {                
                if (field_type=='multivalue picklist') { // if multi-value picklist - concatenate values
                    field_value = field_value + ';' + ADD.valueAgg__c;    
                } else { //Log duplicate value
                    marketing_attrib_duplicate__c dupl = new marketing_attrib_duplicate__c();
                    dupl.contact__c = conId;
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
               c.put(field_api, decimal.valueOf(field_value));
            else   
            c.put(field_api, field_value);
            
            
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