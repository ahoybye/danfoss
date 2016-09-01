//The top class needs to be global as this needs to be accessible for API call
global with sharing class MIDCloneUtils { 
   
   //New Parent Record ID for API call
   global string newParentRecordID {get;private set;}
    
    public class MyException extends Exception {}
    
    public Map<String,String> chidlObjAPIName_FieldAPIName = new Map<String,String>{};

   //standard constructor
   global MIDCloneUtils(){
       
   }

   //quick clone constructor
   global MIDCloneUtils(String parentRecordID,List<String> childObjAPINames){
       newParentRecordID=startsClone(parentRecordID,childObjAPINames);
   }
   
   //excute clone and returns new parent record id
   public string startsClone(String parentRecordID,List<String> childObjAPINames){
        string fieldsNames=''; 
             system.debug('parentRecordID: ' + parentRecordID);
     
        //Loop through all child object names
        for(string objAPIName: childObjAPINames) {
                  system.debug('objAPIName: ' + objAPIName);
     //Check if current child object has records linked with the parent record            
            String queryString = 'select count(id) total from Machine_Model_Product__c where Machine_Model__c=\'' + String.escapeSingleQuotes(parentRecordID) + '\'';
            SObject result = Database.query(queryString);                   
           system.debug('result: ' + result);
         //Find child object records linked with the parent record, add the child object API name into the list
            if((Integer)result.get('total') > 0)
                fieldsNames = fieldsNames + objAPIName + ',';
        }
        //Create Child Object API Name and creatable fields map
        Map<String, list<String>> objFields = New Map<String, list<String>>{};
        system.debug('fieldsNames: ' + fieldsNames);
        if(fieldsNames.length()>0) {
            //getCreatableFields(objAPIName) returns all creatable fields name for a given child obj API name        
            for(String objAPIName:fieldsNames.split(','))
                objFields.put(objAPIName,getCreatableFields(objAPIName));
        }
        //Clone parent record
        String newParentRecordID = cloneParentRecord(returnAPIObjectName(parentRecordID),getCreatableFields(returnAPIObjectName(parentRecordID)),parentRecordID);

        //Clone all selected child records
       for(String childObjAPIName:objFields.keySet()) {
            cloneChildRecords(childObjAPIName, objFields.get(childObjAPIName), returnAPIObjectName(parentRecordID), newParentRecordID,parentRecordID);
       }
        return newParentRecordID;    
    }

    //Clone all child records
    public void cloneChildRecords(String objAPIName, list<String> createableFields, String parentObjAPIName, string newParentRecordID, string parentRecordID){
        String fields = '';
        for(string s:createableFields)
            fields = fields + s + ',';

        fields=fields.substring(0, fields.lastIndexOf(','));
        String queryString = 'select ' + String.escapeSingleQuotes(fields) + ' from Machine_Model_Product__c where Machine_Model__c=\'' + String.escapeSingleQuotes(parentRecordID) + '\'';
        list<SObject> result = Database.query(queryString);         
        list<SObject> copy = result.deepclone(false);       
        for(SObject obj :copy){
          obj.put('Machine_Model__c', newParentRecordID);}
        insert copy;
    }

    //Clone parent record and return new parent record ID
    public String cloneParentRecord(String objAPIName, List<String> createableFields,string parentRecordID) {
        String fields = '';
        for(string s:createableFields) {
            //
            if(s.contains('__pc') == false){
            if (s != 'Production_Start_Date__c' && s != 'Production_End_Date__c')
                fields = fields + s + ','; 
            }         
        }
        fields = fields.substring(0, fields.lastIndexOf(','));

        String queryString = 'select ' + String.escapeSingleQuotes(fields) + ' from ' + String.escapeSingleQuotes(objAPIName) + ' where id=\'' + String.escapeSingleQuotes(parentRecordID) + '\'';
        SObject result = Database.query(queryString);    
        Sobject copy = result.clone(false, true);
        
        copy.put('Annual_Production_Volume__c', 0);
        copy.put('Annual_Production_Volume_Plus1__c', 0);
        copy.put('Annual_Production_Volume_Plus2__c', 0);
        copy.put('Annual_Production_Volume_Plus3__c', 0);
        copy.put('Annual_Production_Volume_Plus4__c', 0);
        copy.put('Annual_Production_Volume_Plus5__c', 0);
        insert copy;
        return copy.id ;
    }
       
    //Return the object API name for a given record
    public String returnAPIObjectName (string myRecordID){
        String objectName = '';
        String prefix = myRecordID.substring(0,3);
    
        Map<String, Schema.SObjectType> gd = Schema.getglobalDescribe();

        for(SObjectType s :gd.values()) {
            DescribeSObjectResult r = s.getDescribe();     
            if(r.getKeyPrefix()!=null) {
                if(r.getLocalName()!=null && r.getKeyPrefix().equals(prefix)) {
                    objectName=r.getLocalName();
                    break;
                } 
             }
        }        
        return objectName;
    }
        
    //Get all creatable fields for a given object
    public list<String> getCreatableFields(String objAPIName){
        Map<string,string> childFieldsName = new Map<string,string>{};
        
        Map<String, Schema.SObjectType> gd = Schema.getglobalDescribe();
        SObjectType sot = gd.get(objAPIName);
      
        //Get all non-creatable fields name except
        //Get the field tokens map
        Map<String, SObjectField> fields = new Map<String, SObjectField>{};
        if(sot.getDescribe().fields.getMap().keyset().size()>0)
            fields = sot.getDescribe().fields.getMap();
        
        //And drop those tokens in a List
        List<SObjectField> fieldtokens = fields.values();
        
        List<string> objectFields = new List<String>();
        
        for(SObjectField fieldtoken:fieldtokens) {
            DescribeFieldResult dfr = fieldtoken.getDescribe();
            
            if(dfr.isCreateable())
                objectFields.add(dfr.getLocalName());                       
        }
        
        return objectFields;
    }
}