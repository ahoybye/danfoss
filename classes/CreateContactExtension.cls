public class CreateContactExtension {
    private Contact con;
    public Boolean navigateToEditCon {get;set;}
    Public Account acc {get;set;}
    
    public CreateContactExtension(ApexPages.StandardController stdController) {
        con = (Contact) stdController.getRecord();
        con.AccountId = ApexPages.currentPage().getParameters().get('accid');
        acc = new Account(Country_MainAddress__c ='None');
        If(stdController.cancel().geturl()!=Null){
        List<String> splitRetUrl = (stdController.cancel().geturl()).split('/');
        If(splitRetUrl.size()>3 && splitRetUrl[3].startsWith('003')){
        Contact lastCon = [select Id,AccountId from Contact where Id=:splitRetUrl[3]];
        con.AccountId = lastCon.AccountId; 
        }
        }
    }
    
    Public pageReference qryAcc(){
      acc = [select Language_CE__c, Country_MainAddress__c, fax_Country__c, Country_Phone__c, Division__c from Account where Id = :con.AccountId];
      return null;
    }
    
    public void CreateNew() {
        con.Language__c = acc.Language_CE__c;
        con.Fax_Country__c = acc.fax_Country__c;
        con.Phone_Country__c = acc.Country_Phone__c;
        con.Mobile_Country__c = acc.Country_Phone__c;
        con.Country_PrivateAddress__c = acc.Country_MainAddress__c;
        con.Division__c = acc.Division__c;     
        con.Same_Address_as_Account__c = True;    
        insert con;
        navigateToEditCon = true;
    }
    
}