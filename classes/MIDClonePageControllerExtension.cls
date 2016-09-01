public with sharing class MIDClonePageControllerExtension {
    
    public MIDClonePageControllerExtension(ApexPages.StandardController controller) {
        this.mach = (Machine_Model__c)Controller.getRecord();
    }
    
    private MIDCloneUtils cc=new MIDCloneUtils();
    
    private Machine_Model__c mach;
    private ApexPages.StandardController controller;
    private string newParentRecordID; //New Parent Record ID for API call 
    public Integer numberOfItems {get;private set;}
    public Boolean hasChildRecords {get;private set;}
    private Map<String,String> chidlObjAPIName_FieldAPIName {get;private set;}
    private string fieldsNames{get;private set;}
    private string recordId;  //Parent record id
    private string objName;  //Parent object API name
     
    //Constructor
    public MIDClonePageControllerExtension(){ 
    }
      
    //Clone parent and selected child objects, redirect to the new parent record page after cloning
    public pagereference chainClone() {
        fieldsNames = '';
        string recId = mach.Id; //apexpages.currentPage().getParameters().get('id');
        String objAPIName= 'Machine_Model_Product__c'; //cc.getAllChildObjNames(objname, this.recordid).get(s);            
        String queryString = 'select count(id) total from Machine_Model_Product__c where Machine_Model__c=\'' + String.escapeSingleQuotes(recId) + '\'';
        SObject result = Database.query(queryString);
        if((Integer)result.get('total')>0)
            fieldsNames = fieldsNames + objAPIName + ','; 
        list<String> selectedChildObjAPINames=New list<String>();
        if(fieldsNames.length()>0) {
            for(String childObjAPIName:fieldsNames.split(',')) {
                selectedChildObjAPINames.add(childObjAPIName);
            }
        }
        string newParentRecordId = cc.startsClone(recId,selectedChildObjAPINames);
        PageReference pr = new PageReference('/'+newParentRecordId+'/e?retURL=%2F' + newParentRecordId);             
        return pr;
    }
}