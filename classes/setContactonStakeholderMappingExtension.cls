public class setContactonStakeholderMappingExtension {

    public Associated_Account__c aa;
    public ApexPages.StandardSetController setCon {get;set;}
    public Id selectedContactId {get;set;}
    public Boolean navigateToAA {get;set;}
        
    public setContactonStakeholderMappingExtension(ApexPages.StandardController stdController) {
        aa = (Associated_Account__c) stdController.getRecord();
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select account.name, email, firstname, lastname , accountid from contact where accountid in (select Associated_Account__c from Associated_Account__c where id =:aa.id)]));
        setCon.setPageSize(15);
        if(setCon.getResultSize() == 0) {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No Contacts for the selected Account');
        ApexPages.addMessage(myMsg);  
            }
    }
  
  public List<contact> getResults() {
        return (List<contact>) setCon.getRecords();
    }
    
    public void updatewithContact() {
        aa.Contact__c = selectedContactId;
        update aa;
        navigateToAA = true;
       
    }
        public void navigatewithoutContact() {
        navigateToAA = true;
       
    }
                                                                               }