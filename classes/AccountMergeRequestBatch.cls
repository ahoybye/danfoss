global without sharing  class AccountMergeRequestBatch implements Database.Batchable<sObject>{
// To test - paste this into Exec Anonymous: Id batjobId = Database.executeBatch(new AccountMergeRequestBatch(), 20);
    /*
    public void execute(SchedulableContext sc) {
        AccountMergeRequestBatch cmrB = new AccountMergeRequestBatch(); 
        database.executebatch(cmrB);
    }
    */
    public Database.QueryLocator start(Database.BatchableContext BC){return Database.getQueryLocator(query);}
    
    private String query{get{return  'select id, recordtype.developername from account where id in (select Master_Account__c from Account_Merge_Request__c where Request_processed__c = FALSE)';}}
    
    public void execute(Database.BatchableContext BC, List<Account> scope) {
        list <Account_Merge_Request__c> updatedAMR = new list <Account_Merge_Request__c>();
        Map<id,id> AccountMap = new Map<id,id>();
        list<id> accountIDs = new list<ID>();
        for (Account s : scope) {accountIDs.add(s.id);}   
        //1x select here for all of the batch
        system.debug('$$AMR$$ Retrieve merge requests');
        updatedAMR = [select Id, Merged_Account__c, Master_Account__c from Account_Merge_Request__c where Master_Account__c in :accountIDs AND Request_processed__c = FALSE];
        for (Account_Merge_Request__c amr : updatedAMR) 
        {            
            AccountMap.put(amr.Master_Account__c, amr.Merged_Account__c);            
        } 
        system.debug('$$AMR$$ Complete merge requests');
        //1 merge dml per record in batch therefore max batch size is <149
        for (Account s : scope) {
            
            doMerge(s, AccountMap.get(s.id), s.recordtype.developername);
            
        }                
    }
    
    public static void doMerge(account master, id merged, string type) {
        
        system.debug('$$AMR$$ Master account record type: ' + type);
        FieldSet fset = Schema.SObjectType.Account.fieldSets.getMap().get(type);
        List<Schema.FieldSetMember> schemaset = fset.getFields();
        
        //Added By Raj - to handle system Id fields
        List<Schema.FieldSetMember> idSchemaset = Schema.SObjectType.Account.fieldSets.getMap().get('Merge_System_Id_Fields').getFields();
        
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.account.fields.getMap();
        
        string queryfields='';
        for(Schema.FieldSetMember f : schemaset) {
            if(fieldMap.get(f.fieldPath).getDescribe().isUpdateable()) {
                queryfields += ', '  + f.getFieldPath();
            }
        }
        
        //Added By Raj - to handle system Id fields
        for(Schema.FieldSetMember f : idSchemaset ) 
            if(fieldMap.get(f.fieldPath).getDescribe().isUpdateable()) 
                queryfields += ', '  + f.getFieldPath();
            
        
        
        Account acct_merged = Database.query('select Id' + queryfields + ' from Account where Id=\'' + merged + '\''); 
        Account acct_master = Database.query('select Id' + queryfields + ' from Account where Id=\'' + master.id + '\''); 
        
        

        for(Schema.FieldSetMember f : schemaset) {
            Schema.DisplayType fieldtype = f.getType();
            
            //check if field can be update - else skip it
            if(fieldMap.get(f.fieldPath).getDescribe().isUpdateable()) {
                if ( ((sObject)acct_master).get(f.fieldPath)==null && fieldtype != Schema.DisplayType.MultiPicklist) {                
                        ((sObject)acct_master).put(f.fieldPath, ((sObject)acct_merged).get(f.fieldPath));
                        System.debug('$$ Field: \''+f.fieldPath+'\' set to <'+((sObject)acct_merged).get(f.fieldPath) + '> on master');
                } 
                else if (fieldtype == Schema.DisplayType.MultiPicklist) {
                                      
                        //Call addMasterValues string method to process the field values
                        ((sObject)acct_master).put(f.fieldPath, addMasterValues(acct_master,acct_merged,f) );   
                        System.debug('$$ Field: \''+f.fieldPath+'\' set to <'+((sObject)acct_merged).get(f.fieldPath) + '> on master');
                }
            }
        }
        
        //Added By Raj - to handle system Id fields
        for(Schema.FieldSetMember f : idSchemaset) {
             //Call addMasterValues string method to process the field values
                ((sObject)acct_master).put(f.fieldPath, addMasterValues(acct_master,acct_merged,f) );     
        }
        
        System.debug('$$ To be merged ' + acct_master + ' <- ' + acct_merged + ' (' + merged + ')');                       
        merge acct_master merged;
        update acct_master;
    }
    
    public static string addMasterValues(Account acct_master,Account acct_merged,Schema.FieldSetMember f){
        String merge_values = '';
        String master_values = '';
        
        if (((sObject)acct_master).get(f.fieldPath)!=null)                     
                        master_values = (String)((sObject)acct_master).get(f.fieldPath);
                    
                 if (((sObject)acct_merged).get(f.fieldPath)!=null) 
                        merge_values = (String)((sObject)acct_merged).get(f.fieldPath);
                    
                 master_values = master_values + ';' + merge_values;
                 
                 
                 Set<String> updated_set = new Set<String>(master_values.split(';'));
                 master_values='';
                    /*for (string v : updated_set) 
                        if (v!='') 
                            master_values +=  v + ';';   */ 
                  List<String> updated_list = new List<String>();
                  updated_list.addAll(updated_set);  
                                        
                    for (integer i=0;i<updated_list.size();i++){
                        master_values +=  updated_list[i];
                        If(i!=updated_list.size()-1)
                        master_values +=';';
                    }
                return master_values;
    
    }
        
    
    public void finish(Database.BatchableContext BC) {system.debug('$$AMR$$ done');}
}