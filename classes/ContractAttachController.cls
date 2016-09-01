public with sharing class ContractAttachController 
{
    public Contract_Attachment__c contAtt{get;set;}
    public Attachment attach {get;set;}
	Contract__c contract;

    public ContractAttachController(ApexPages.StandardController controller) {
        contAtt = [select Name, Contract__c, Type__c, Title__c from Contract_Attachment__c where Id = :controller.getRecord().id];
        attach = new Attachment();
		contract = [select Id, Contract_Status__c, File_Attached__c from Contract__c where Id = :contAtt.Contract__c];
    }

    public ApexPages.Pagereference upload()
    {
		ApexPages.getMessages().clear();
		if(attach.Name == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'You must choose a file before uploading.'));
            return null;
		}
		else{	
			attach.ParentId = contAtt.Id;
			insert attach;      
			contAtt.Title__c = attach.Name;
			update contAtt;
			contract.File_Attached__c = true;
			update contract;
			PageReference np = new PageReference('/' + contAtt.Contract__c); 
			np.setRedirect(true);
			return np;   
		}
    }
    
    public List<Attachment> getAttachments() {
        Map<Id, List<Attachment>> mapAttachments = new Map<Id, List<Attachment>>();
        List<Attachment> lstAttachments = new List<Attachment>();
        Set<Id> parentIds = new Set<Id>();
        List<Contract_Attachment__c> lstContAtt = [select Id, Name, Type__c from Contract_Attachment__c where Id=:contAtt.id ];
        lstAttachments = [Select Id, Name, body, ParentId From Attachment Where ParentId = :contAtt.Id];
        return lstAttachments;
    }
	
	public PageReference saveandReturn() {		
	    try {    
			upsert contAtt;
	    }
	    catch(DmlException ex) {
	        ApexPages.addMessages(ex);
	        return null;
	    }    
	    return new PageReference('/' + contract.Id);
  }
	
	public PageReference cancel() {
		System.debug(attach);
		if(attach.Name == null)
			delete contAtt;
    	return new PageReference('/' + contract.Id);
  }
    
}