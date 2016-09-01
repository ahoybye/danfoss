public class NewContactExtension {
    private PageReference pr;
    Private Id conRecTypeId;
    Public String businessOrg;
    private ApexPages.StandardController ctrl;


    public NewContactExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String> {'AccountId'});
            system.debug('ddddddddddddddddddddddd:'+ controller.getRecord().get('id'));
            system.debug('RRRRRRRRRRRRRRRRRRRRRRRR:'+ ApexPages.currentPage().getParameters().get('retURL'));
            
        }
        Contact contact = (Contact) controller.getRecord();
        
        User usr = [select Business_Org__c from User where Id = :UserInfo.getUserId()];
        businessOrg = usr.Business_Org__c;
        
        if (businessOrg == 'Climate and Energy') 
            pr = Page.CreateContact;
         else {
            //Added By Raj - SF1 fix
            If(Network.getNetworkId() != null)
              pr = new PageReference('e?nooverride=1&ent=Contact');
            else{
                
               pr = new PageReference('/003/e?nooverride=1&ent=Contact');
               pr.getParameters().put('RecordType', conRecTypeId);
              }
             }
             pr.getParameters().put('retURL', controller.cancel().getUrl());
             pr.getParameters().put('accid', contact.AccountId);    
       }   
        
    public String getGoToCon() {
        return pr.geturl();
    }
    
     public string getBusOrg() {
        return businessOrg;
    }    
    
    public String getRecTypeId() {
        Schema.DescribeSObjectResult describeCon = Schema.SObjectType.Contact;    
        List<Schema.RecordTypeInfo> rtInfos = describeCon.getRecordTypeInfos();
          for(Schema.RecordTypeInfo rtInfo : rtInfos) {
        if(rtInfo.isDefaultRecordTypeMapping()) {               
            conRecTypeId = rtInfo.getRecordTypeId();
            break;
         }
       }

        return conRecTypeId;
    }
    
}