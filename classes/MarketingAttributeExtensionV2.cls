public class MarketingAttributeExtensionV2 {

    Public account acc{ get; set; }
    Public Contact con{ get; set; }
    
    List<String> accFields;
    List<String> conFields  = new List<String>();   
    public String objId;
    private final string retURL;   
    Public  String type{ get; set; }


    public List<SelectOption> attribSetOptions { get; set; }
    public List<SelectOption> attribOptions { get; set; }
    
    public String attribSetValue {get;set;}
    public String attribValue {get;set;}
    public String fieldAPI {get;set;}
    public Boolean isCreate { get; set; }
    public Account_Division_Data_config__c adQry{ get; set; }
    
    
    public MarketingAttributeExtensionV2() {
       objId = System.currentPagereference().getParameters().get('objid');
       retURL = System.currentPagereference().getParameters().get('retURL');
       fieldAPI = System.currentPagereference().getParameters().get('fieldAPI');
       
       
       attribSetValue='-';
       attribValue='-';

       isCreate = fieldAPI == null;
       String query;
       
       if (objId.startsWith('001')){
    
         type = 'Account';         
         acc = (Account)qryObjFields();  
       }
       else if (objId .startsWith('003')) {
        type = 'Contact';
        con = (Contact)qryObjFields();  
       }
        
        
       If(!isCreate){
        
       adQry=  [select Division__c,Attribute_Set__c,Attribute__c,Field_API__c from Account_Division_Data_config__c where Object_Type__c=:type and Field_API__c=:fieldAPI ]; 
        attribSetValue=adQry.Attribute_Set__c;
        attribValue=adQry.Attribute__c;
       }
       else{
        getAttribSetValues();
        getAttribValues();
        getPicklistValues();
        }
        
    }
    
    //Method to Query respective Marketing Attribute Field APIs of Account & Contact object;
    Public  sobject qryObjFields(){
       accFields = new List<String>();
       conFields = new List<String>(); 
       String query = 'SELECT ';
       for(Account_Division_Data_Config__c ad: [select Division__c,Attribute_Set__c,Attribute__c,Field_API__c from Account_Division_Data_config__c where Object_Type__c=:type]){
       accFields.add(ad.Field_API__c);
       conFields.add(ad.Field_API__c);
       query += ad.Field_API__c  + ', '; 
       }
       query += 'Id FROM ' + type + ' where id=: objid' ;
       return  (Database.query(query));
        
    }
    
    public void getAttribSetValues() {
        attribSetOptions = new List<SelectOption>();
        attribSetOptions.add(new SelectOption('-','-'));
        for (AggregateResult ar : [SELECT Attribute_Set__c from Account_Division_Data_Config__c WHERE Object_Type__c =:type GROUP BY Attribute_Set__c]) { 
            String attribSet = (String) ar.get('Attribute_Set__c');
            attribSetOptions.add(new SelectOption(attribSet, attribSet));
        }
    }
    
    
    public void getAttribValues() {
           List<String> existingAttributes = new List<String>();           
           if(type=='Account'){
           Account A = (Account)qryObjFields();  
           for(String sFldA : accFields) 
             if (((sObject)A).get(sFldA)!=null)
               existingAttributes.add(sFldA);
           }   
           else if(type=='Contact'){
           Contact c = (Contact)qryObjFields();  
           for(String sFldc : conFields) 
           if (((sObject)C).get(sFldc)!=null)
            existingAttributes.add(sFldc);
            system.debug('CCCCCCCCCCCCCC:'+existingAttributes);
           }   
        
        
        attribOptions = new List<SelectOption>();
        attribOptions.add(new SelectOption('-','-'));
        for (AggregateResult da : [
            SELECT Attribute__c
            FROM Account_Division_Data_Config__c
            WHERE Attribute_Set__c = :attribSetValue and Object_Type__c =:type and Field_API__c not in :existingAttributes
            GROUP BY Attribute__c
            ORDER BY Attribute__c
        ]) { 
            String attr = (String) da.get('Attribute__c');
            attribOptions.add(new SelectOption(attr, attr));
        }
    }

    public void getPicklistValues(){
        List<Account_Division_Data_Config__c> DivAttributeConfigs = [select Id, Field_API__c
            from Account_Division_Data_Config__c
            where Attribute__c = :attribValue and Attribute_Set__c = :attribSetValue and Object_Type__c =:type
        ];
     
        if (DivAttributeConfigs.size() == 1) 
            fieldAPI = DivAttributeConfigs[0].Field_API__c;
       }
     
     
     public PageReference saveAtt() {
        {
        if(type=='Account')
         update acc;
        else if(type=='Contact')
        update con;
        return new PageReference(retURL);
        }
    }
    
     public PageReference cancel() {
     return new PageReference(retURL);
     }
 
}