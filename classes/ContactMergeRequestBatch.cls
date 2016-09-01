global with sharing  class ContactMergeRequestBatch implements Database.Batchable<sObject>{
// Schedulable,    
// conflicts with legacy trigger contactGroupSetup - which is commented out in spirit
// To test - paste this into Exec Anonymous: Id batjobId = Database.executeBatch(new ContactMergeRequestBatch(), 35);
// https://help.salesforce.com/apex/HTViewSolution?id=000171199&language=en_US

/*
    Contact masterCon = [SELECT Id FROM Contact WHERE id= '0034B000001V74C'];
    Contact mergeCon = [SELECT Id FROM Contact WHERE id= '0034B000001V73x'];
    Contact_Merge_Request__c cmr = new Contact_Merge_Request__c();
    cmr.master_contact__c=masterCon.Id;
    cmr.merged_contact__c=mergeCon.id;
    insert cmr;
    Id batjobId = Database.executeBatch(new ContactMergeRequestBatch(), 30);
*/
/*    
    public void execute(SchedulableContext sc) {
		ContactMergeRequestBatch cmrB = new ContactMergeRequestBatch(); 
    	database.executebatch(cmrB);
    }
*/    
    public Database.QueryLocator start(Database.BatchableContext BC){return Database.getQueryLocator(query);}
    
    private String query{get{return  'select id from contact where id in (select Master_Contact__c from Contact_Merge_Request__c where Request_processed__c = FALSE)';}}
	
    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        list <Contact_Merge_Request__c> updatedCMR = new list <Contact_Merge_Request__c>();
        Map<id,id> ContactMap = new Map<id,id>();
        list<id> contactIDs = new list<ID>();
        for (Contact s : scope) {contactIDs.add(s.id);}   
        //1x select here for all of the batch
        system.debug('$$CMR$$ Retrieve merge requests');
        updatedCMR = [select Id, Merged_Contact__c, Master_Contact__c from Contact_Merge_Request__c where Master_Contact__c in :contactIDs AND Request_processed__c = FALSE];
        for (Contact_Merge_Request__c cmr : updatedCMR) 
        {            
            ContactMap.put(cmr.Master_Contact__c, cmr.Merged_Contact__c);            
        } 
        system.debug('$$CMR$$ Complete merge requests');
        //4 merge dml per record in batch therefore max batch size is <35
        for (Contact s : scope) {
            //merge s ContactMap.get(s.id);
            doMerge(s, ContactMap.get(s.id), 'Contact_CE');
        }
	}
    
    public static void doMerge(contact master, id merged, string type) {
        
        system.debug('$$CMR$$ Master contact record type: ' + type);
        FieldSet fset = Schema.SObjectType.Contact.fieldSets.getMap().get(type);
        List<Schema.FieldSetMember> schemaset = fset.getFields();        
        string queryfields='';
        for(Schema.FieldSetMember f : schemaset) {
            queryfields += ', '  + f.getFieldPath();
        }
        
        // get the data from the two records (master and merged) - based on the field set
        Contact record_merged = Database.query('select Id' + queryfields + ' from Contact where Id=\'' + merged + '\''); 
        Contact record_master = Database.query('select Id' + queryfields + ' from Contact where Id=\'' + master.id + '\''); 

        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.contact.fields.getMap();       
        
		for(Schema.FieldSetMember f : schemaset) {
            Schema.DisplayType fieldtype = f.getType();
            
            //check if field can be update - else skip it
            if(fieldMap.get(f.fieldPath).getDescribe().isUpdateable()) {
                
                if ( ((sObject)record_master).get(f.fieldPath)==null && fieldtype != Schema.DisplayType.MultiPicklist) {                
                        ((sObject)record_master).put(f.fieldPath, ((sObject)record_merged).get(f.fieldPath));
                } else if (fieldtype == Schema.DisplayType.MultiPicklist) {
                    String merge_values = '';
                    String master_values = '';
                    if (((sObject)record_master).get(f.fieldPath)!=null) {                     
                    	master_values = (String)((sObject)record_master).get(f.fieldPath);
                    }
                    if (((sObject)record_merged).get(f.fieldPath)!=null) {
                    	merge_values = (String)((sObject)record_merged).get(f.fieldPath);
                    }

                    master_values = master_values + ';' + merge_values;
                
                    Set<String> updated_set = new Set<String>(master_values.split(';'));
                    
                    master_values='';
                    for (string v : updated_set) {
                        if (v!='') {
                            master_values +=  v + ';';    
                        }                    
                    }
                    
                    ((sObject)record_master).put(f.fieldPath, master_values);                				
                }
            }
        }
                                
        merge master merged;
        update record_master;
    }
	
    public void finish(Database.BatchableContext BC) {system.debug('$$CMR$$ done');}
}