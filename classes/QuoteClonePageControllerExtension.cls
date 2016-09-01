public with sharing class QuoteClonePageControllerExtension {
	    
    public QuoteClonePageControllerExtension(ApexPages.StandardController controller) {
        this.qt = (Quote)Controller.getRecord();
    }
    
    private QuoteCloneUtility cc=new QuoteCloneUtility();
    
    private Quote qt;
    private ApexPages.StandardController controller;
    private string newParentRecordID; //New Parent Record ID for API call 
    public Integer numberOfItems {get;private set;}
    public Boolean hasChildRecords {get;private set;}
    private Map<String,String> chidlObjAPIName_FieldAPIName {get;private set;}
    private string fieldsNames{get;private set;}
    private string recordId;  //Parent record id
    private string objName;  //Parent object API name
     
    //Constructor
    public QuoteClonePageControllerExtension(){ 
    }
      
    //Clone parent and selected child objects, redirect to the new parent record page after cloning
    public pagereference chainClone() {
        fieldsNames = '';
        string recId = qt.Id; 
        String objAPIName= 'QuoteLineItem';             
        String queryString = 'select count(id) total from QuoteLineItem where QuoteId=\'' + String.escapeSingleQuotes(recId) + '\'';
		Quote objQuote = [select QuoteNumber, Name from Quote where Id = :qt.Id limit 1];
		String strQuoteNum = objQuote.QuoteNumber;
		String strQuoteName = objQuote.Name;
        SObject result = Database.query(queryString);
        if((Integer)result.get('total')>0)
            fieldsNames = fieldsNames + objAPIName + ','; 
        list<String> selectedChildObjAPINames=New list<String>();
        if(fieldsNames.length()>0) {
            for(String childObjAPIName:fieldsNames.split(',')) {
                selectedChildObjAPINames.add(childObjAPIName);
            }
        }
        string newParentRecordId = cc.startsClone(recId,selectedChildObjAPINames,strQuoteNum,strQuoteName);
		PageReference pr = new PageReference('/apex/AddQuoteLineItems?id='+newParentRecordId+'&iscloned=1');
		pr.setRedirect(True);
        //PageReference pr = new PageReference('/'+newParentRecordId+'/e?retURL=%2F' + newParentRecordId);             
        return pr;
    }
}