public class NewOpportunityExtension {
    
    private PageReference pr;
    Private Id opptyRecTypeId;
    public String businessOrg;
    
    public NewOpportunityExtension(ApexPages.StandardController controller) {
        
        Opportunity o = (Opportunity) controller.getRecord();
        
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        String accID = ApexPages.currentPage().getParameters().get('accid');
        
        Schema.DescribeSObjectResult describeOppty = Schema.SObjectType.Opportunity;    
        List<Schema.RecordTypeInfo> rtInfos = describeOppty.getRecordTypeInfos();
          for(Schema.RecordTypeInfo rtInfo : rtInfos) {
        if(rtInfo.isDefaultRecordTypeMapping()) {               
            opptyRecTypeId = rtInfo.getRecordTypeId();
            break;
         }
       }

        
        businessOrg = [select Business_Org__c from User where Id = :UserInfo.getUserId()].Business_Org__c;
        
        if (businessOrg == 'Climate and Energy') 
            pr = Page.SearchOpportunity;
        else {
            //Added By Raj - SF1 fix
  
            If(Network.getNetworkId() != null)
              pr = new PageReference('e?nooverride=1&ent=Opportunity');
            Else{
              pr = new PageReference('/006/e?nooverride=1&ent=Opportunity'); 
            
            pr.getParameters().put('accid', accID);
            pr.getParameters().put('RecordType', opptyRecTypeId);
            pr.getParameters().put('ent', 'opportunity');
            }

        }
        pr.getParameters().put('retURL', retURL);
        if (accID != null) {
            pr.getParameters().put('accid', accID);
        }
    }
    
    public string getGoToOpp() {
       return pr.geturl();
    }    
    
    public string getBusOrg() {
        return businessOrg;
    }    
    
    public String getRecTypeId() {
        Schema.DescribeSObjectResult describeOppty = Schema.SObjectType.Opportunity;    
        List<Schema.RecordTypeInfo> rtInfos = describeOppty.getRecordTypeInfos();
          for(Schema.RecordTypeInfo rtInfo : rtInfos) {
        if(rtInfo.isDefaultRecordTypeMapping()) {               
            opptyRecTypeId = rtInfo.getRecordTypeId();
            break;
         }
       }

        return opptyRecTypeId;
    }
    
}