public class ShowMarketingAttributesExtensionV2 {

    private final Id objId;
    private final String type;
    public List<SelectOption> statusOptions { get; set; }
    public String selectedValue { get; set; }
    public ApexPages.StandardSetController setCon { get; set; }
    public string selectedAPI { get; set; }
    
    Public Account acc{ get; set; }
    Public Contact con{ get; set; }
    List<String> accFields { get; set; }
    List<String> conFields { get; set; }
    
   Map<String,Account_Division_Data_config__c> dataConfigType = new Map<String,Account_Division_Data_config__c>();
    
    public ShowMarketingAttributesExtensionV2 (ApexPages.StandardController stdController) {
        // Account record logic
        if (stdController.getId().startsWith('001'))
         {
            type = 'Account';
            //Query Account - Marketing Attributes fields from custom Data Config object
            accFields = qryObjFields();
            stdController.addFields(accFields);
            acc= (Account)stdController.getRecord();
            objId = acc.id;
        } 
        else if (stdController.getId().startsWith('003')) {
            type = 'Contact';
            //Query Contact - Marketing Attributes fields from custom Data Config object
            conFields = qryObjFields();         
            stdController.addFields(conFields);
            con= (Contact)stdController.getRecord();
            objId = con.id;

        } 

        statusOptions = new List<SelectOption>();
        Set<String> divisions = new Set<String>();
        for (AggregateResult ar : [select Division__c from Account_Division_Data_config__c where Division__c != null group by Division__c order by Division__c]) {
            String division = (String) ar.get('Division__c');
            statusOptions.add(new SelectOption(division, division));
            divisions.add(division);
        }
        
        selectedValue = System.currentPagereference().getParameters().get('division');
        if (selectedValue == null) {
            id uid = UserInfo.getUserId(); 
            selectedValue = [select Division__c from User where Id = :uid].Division__c;
        }
        if (!divisions.contains(selectedValue)) {
            // Invalid value, pick some valid value
            selectedValue = 'All';
        }
        initSetCon();
    }
    
    //Method to Query respective Marketing Attribute Field APIs of Account & Contact object; Method is called from Constructor 
    Public  List<String> qryObjFields(){
      List<String> addObjFields = new List<String>();
       for(Account_Division_Data_Config__c ad: [select Division__c,Attribute_Set__c,Attribute__c,Field_API__c from Account_Division_Data_config__c where Object_Type__c=:type]){
        addObjFields.add(ad.Field_API__c );
        dataConfigType.put(ad.Field_API__c,ad);

        }
       return  addObjFields;
        
    }
    
    
    public List<Account_Division_Data_Config__c> showAtts {get; set;}

    private void initSetCon() {
        id uid = UserInfo.getUserId(); 
        string division = selectedValue;
        
        if (type == 'Account') {
           showAtts = new List<Account_Division_Data_Config__c >();
           
           for(string sFld : accFields)
            if (((sObject)acc).get(sFld )!=null){
              if(division == 'All')
               showAtts.add(dataConfigType.get(sFld)); 
              else if(division == dataConfigType.get(sFld).Division__c)
                showAtts.add(dataConfigType.get(sFld)); 
             }   
             setCon = new ApexPages.StandardSetController(showAtts);
            
         } 
        else if (type == 'Contact') {
           showAtts = new List<Account_Division_Data_Config__c >();
    
           //Add the marketing attributes field api
           for(string sFldc : conFields)
            if (((sObject)Con).get(sFldc)!=null){
              if(division == 'All')
               showAtts.add(dataConfigType.get(sFldc)); 
              else if(division == dataConfigType.get(sFldc).Division__c)
                showAtts.add(dataConfigType.get(sFldc)); 
             }   
             setCon = new ApexPages.StandardSetController(showAtts);
          
        }
        else 
        System.assert(false);
        
        setCon.setPageSize(8);

    }
    
    public void filterADDs() {
        initSetCon();
    }
   
    public List<Account_Division_Data_config__c> getADDs() {
        return (List<Account_Division_Data_config__c>) setCon.getRecords();
    }
    
    public PageReference CreateADD() {
        PageReference pr = Page.AccountMarketingAttribute;
        pr.getParameters().put('objid', objId);
        pr.getParameters().put('type', type);
        pr.getParameters().put('retURL', getRetURL());
        return pr;
    }
    
    public PageReference EditADD() {
        PageReference pr = Page.AccountMarketingAttribute;
        pr.getParameters().put('objid', objId);
        pr.getParameters().put('type', type);
        pr.getParameters().put('fieldAPI', selectedAPI);
        pr.getParameters().put('retURL', getRetURL());
        return pr;
    }
    
    private String getRetURL() {
        if (type == 'Account') {
            return '/apex/ShowAccountMarketingAttributes?Id=' + objId + '&division=' + selectedValue;
        } else {
            return '/apex/ShowContactMarketingAttributes?Id=' + objId + '&division=' + selectedValue;
        }
    }
    
    public void DeleteADD() {
        if (type == 'Account'){
        ((sObject)acc).put(selectedAPI,null);
        update acc;
        }
        else if (type == 'Contact'){
        ((sObject)con).put(selectedAPI,null);
        update con;
        }
        
        initSetCon();
    }
    
    public ShowMarketingAttributesExtensionV2 getThis() {
        return this;
    }
    
}