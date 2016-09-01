public class InitQuoteController {

    private Case c;
    public string url {get; set;}
    public string objectType {get; set;}
    public string objectId {get; set;}
    
    public  InitQuoteController ()
    {
        objectType = ApexPages.currentPage().getParameters().get('type');  
        objectId = ApexPages.currentPage().getParameters().get('oid');  
        url='';
    }
   
    @RemoteAction  
    public static String createOpptyAndRedirect (string otype, string oid)
    {
        Id pb2Id= null; 
        string returnUrl='';
        pb2Id=[SELECT Id FROM Pricebook2 WHERE Name='Climate and Energy'].Id;
        Opportunity o = new Opportunity();
        o = new Opportunity();                
        if (otype.equalsIgnoreCase('CONTACT')) {
            Contact contact = [SELECT id, accountid, account.CurrencyIsoCode, CurrencyIsoCode FROM Contact WHERE id=:oid limit 1];
            if (contact.accountid!=null) {
                o = QuoteBusiness.createShadowOpportunity('Price Request', contact.accountid, contact.account.CurrencyIsoCode, null, pb2Id);
            	o.Contact__c = contact.id;
            } 
                                    
        } else if (otype.equalsIgnoreCase('CASE')) {
            Case c = [SELECT id, accountid, account.CurrencyIsoCode, Subject, ContactId, CurrencyIsoCode FROM Case WHERE id=:oid limit 1];
            
            if (c.accountid!=null) {
                o = QuoteBusiness.createShadowOpportunity(c.Subject, c.accountid, c.account.CurrencyIsoCode, null, pb2Id);                              
            } else {
                o = QuoteBusiness.createShadowOpportunity(c.Subject, null, c.CurrencyIsoCode, null, pb2Id);
            }
            o.Contact__c = c.ContactId; 
            o.Originating_Case__c = c.Id;            	                      	                        
        } /* else if (otype.equalsIgnoreCase('STAKEHOLDER')) {
            Associated_Account__c sh = [SELECT id, Associated_Account__c, Contact__c, CurrencyIsoCode, Project_Opportunity__r.name FROM Associated_Account__c WHERE id=:oid limit 1];
            o.AccountId = sh.Associated_Account__c;
            o.Contact__c = sh.contact__c;
            o.name = sh.Project_Opportunity__r.name;
            o.CurrencyIsoCode = sh.CurrencyIsoCode;
        } */
                
        insert o;
        
        ConfigitQuoteSettings__c mc = ConfigitQuoteSettings__c.getOrgDefaults();
        //ConfigitQuoteSettings__c mc = ConfigitQuoteSettings__c.getInstance(UserInfo.getProfileId());
        returnUrl = mc.ServerProtocol__c + '://' + mc.ServerHost__c + '/Configit/Quote/api/ext/Opportunity/create/' + UserInfo.getUserId() +  '/' + o.AccountId + '/' + o.Id; 
        //PageReference pageRef = new PageReference(url);		
		//pageref.setRedirect(true);		
        return returnUrl;
        
    }
    
    

    
}