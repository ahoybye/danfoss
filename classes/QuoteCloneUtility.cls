global with sharing class QuoteCloneUtility {
    //for cloning Quotes
    //New Parent Record ID for API call
	global SObject newRecord{get; private set;}
    public class MyException extends Exception {}
    public Map <String , String >chidlObjAPIName_FieldAPIName = new Map <String , String >{};
    //standard constructor
    global QuoteCloneUtility() {
    }
    //quick clone constructor
    global QuoteCloneUtility(String RecordID){
        newRecord = cloneRecord(RecordID);
    }
    //excute clone and returns new parent record id
    public string startsClone(String parentRecordID, List <String >childObjAPINames, String sQuoteNumber, String sQuoteName) {
        string fieldsNames = '';
        //Loop through all child object names
        for (string objAPIName :childObjAPINames) {
            //Check if current child object has records linked with the parent record            
            String queryString = 'select count(id) total from QuoteLineItem where QuoteId=\''+ String.escapeSingleQuotes(parentRecordID)+ '\'';
            SObject result = Database.query(queryString);
            //Find child object records linked with the parent record, add the child object API name into the list
            if ((Integer)result.get('total')>0)fieldsNames = fieldsNames + objAPIName + ',';
        }
        //Create Child Object API Name and creatable fields map
        Map <String , list <String >>objFields = New Map <String , list <String >>{
        }
        ;
        if (fieldsNames.length()>0) {
            //getCreatableFields(objAPIName) returns all creatable fields name for a given child obj API name        
            for (String objAPIName :fieldsNames.split(','))objFields.put(objAPIName, getCreatableFields(objAPIName));
        }
        //Clone parent record
        String newParentRecordID = cloneParentRecord(returnAPIObjectName(parentRecordID), getCreatableFields(returnAPIObjectName(parentRecordID)), parentRecordID, sQuoteName);
        //Clone all selected child records
        for (String childObjAPIName :objFields.keySet()) {
            cloneChildRecords(childObjAPIName, objFields.get(childObjAPIName), returnAPIObjectName(parentRecordID), newParentRecordID, parentRecordID, sQuoteNumber);
        }
        return newParentRecordID;
    }
    //Clone all child records
    public void cloneChildRecords(String objAPIName, list <String >createableFields, String parentObjAPIName, string newParentRecordID, string parentRecordID, String sQNumber) {
        String fields = '';
        for (string s :createableFields)fields = fields + s + ',';
        fields = fields.substring(0, fields.lastIndexOf(','));
        String queryString = 'select '+ String.escapeSingleQuotes(fields)+ ' from QuoteLineItem where QuoteId=\''+ String.escapeSingleQuotes(parentRecordID)+ '\'';
        list <SObject >result = Database.query(queryString);
        list <SObject >copy = result.deepclone(false);
        for (SObject obj :copy) {
            obj.put('QuoteId', newParentRecordID);
            obj.put('ApprovalComments__c', 'Cloned from Quote '+ sQNumber);
			obj.put('ClonedFlag__c', 'true');
        }
		System.debug('copy: ' + copy);
        insert copy;
    }
	
    //Clone parent record and return new parent record ID
    public String cloneParentRecord(String objAPIName, List <String >createableFields, string parentRecordID, String sQName) {
        String fields = '';
        for (string s :createableFields) {
            if (s.contains('__pc')== false) {
                if (objAPIName == 'Quote' && s != 'Approval_Date__c' && s != 'RecordTypeId' && s != 'Approval_Stage__c' && s != 'Price_Status__c' && s != 'Pricing_Updated_in_SAP__c' && s != 'Approval_Date__c' && s != 'ExpirationDate' && s != 'Customer_Request_Date__c')
					fields = fields + s + ',';
            }
        }
        fields = fields.substring(0, fields.lastIndexOf(','));
        String queryString = 'select '+ String.escapeSingleQuotes(fields)+ ' from '+ String.escapeSingleQuotes(objAPIName)+ ' where id=\''+ String.escapeSingleQuotes(parentRecordID)+ '\'';
        SObject result = Database.query(queryString);
        SObject copy = result.clone(false, true);
        if (objAPIName == 'Quote'){
	        copy.put('Original_Quote__c', parentRecordID);
	        copy.put('Name', sQName + ' CLONE');
		}
        insert copy;
        return copy.id;
    }
	
	//Clone record and return new record
    public SObject cloneRecord(string recordID) {
		String objAPIName = returnAPIObjectName(recordID);
		List<String> createableFields = getCreatableFields(objAPIName);		
        String fields = '';
        for (string s :createableFields) {
            if (s.contains('__pc')== false) {               
				if(objAPIName == 'OpportunityLineItem' && s != 'TotalPrice')
					fields = fields + s + ',';
            }
        }
        fields = fields.substring(0, fields.lastIndexOf(','));
        String queryString = 'select '+ String.escapeSingleQuotes(fields)+ ' from '+ String.escapeSingleQuotes(objAPIName)+ ' where id=\''+ String.escapeSingleQuotes(recordID)+ '\'';
        SObject result = Database.query(queryString);
        SObject copy = result.clone(false, true);
        return copy;
    }
	
    //Return the object API name for a given record
    public String returnAPIObjectName(string myRecordID) {
        String objectName = '';
        String prefix = myRecordID.substring(0, 3);
        Map <String , Schema.SObjectType >gd = Schema.getglobalDescribe();
        for (SObjectType s :gd.values()) {
            DescribeSObjectResult r = s.getDescribe();
            if (r.getKeyPrefix()!= null) {
                if (r.getLocalName()!= null &&r.getKeyPrefix().equals(prefix)) {
                    objectName = r.getLocalName();
                    break ;
                }
            }
        }
        return objectName;
    }
    //Get all creatable fields for a given object
    public list <String >getCreatableFields(String objAPIName) {
        Map <string , string >childFieldsName = new Map <string , string >{
        }
        ;
        Map <String , Schema.SObjectType >gd = Schema.getglobalDescribe();
        SObjectType sot = gd.get(objAPIName);
        //Get all non-creatable fields name except
        //Get the field tokens map
        Map <String , SObjectField >fields = new Map <String , SObjectField >{
        }
        ;
        if (sot.getDescribe().fields.getMap().keyset().size()>0)fields = sot.getDescribe().fields.getMap();
        //And drop those tokens in a List
        List <SObjectField >fieldtokens = fields.values();
        List <string >objectFields = new List <String >();
        for (SObjectField fieldtoken :fieldtokens) {
            DescribeFieldResult dfr = fieldtoken.getDescribe();
            if (dfr.isCreateable())objectFields.add(dfr.getLocalName());
        }
        return objectFields;
    }
}