public class ContractAttachmentsExtension
{
    public Contract__c Contract{get;set;}
    public Boolean hasDeletePermission { get; set; }
    public boolean hasFullPermission {get;set;}
    public Contract_Attachment__c contAtt{get;set;}
    public string hasDMLExceptions {get;set;}
    public boolean hasPermission {get;set;}
    private string gotoURL;
    public string attachmentToDel{get;set;}
    public string contAttToDel{get;set;}    
    static final String NEWCONTRACT = 'Collaboration';
    static final String PENDING = 'Pending Approval';
    static final String APPROVED = 'Approved';
    static final String ACTIVE = 'Active';
    private List<PermissionSetAssignment> lstGPOs = new List<PermissionSetAssignment>();
    private List<User> lstSysAdmins = new List<User>(); 
    List<attachmentWrapper> lstAttachmentWrappers = new List<attachmentWrapper>();
    
    public class attachmentWrapper{
        public Contract_Attachment__c contAttachment{get;set;}
        public Id contAttId{get;set;}
        public Attachment attach {get;set;}
    }
    
    public List<attachmentWrapper> getAttachments() {
        Map<Id, Attachment> mapAttachments = new Map<Id, Attachment>();
        Set<Id> parentIds = new Set<Id>();
        List<Contract_Attachment__c> lstAllContAtt = [select Id, Name, Type__c, CreatedDate from Contract_Attachment__c where Contract__c = :Contract.Id Order by Type__c asc];
        
        for (Contract_Attachment__c ca : lstAllContAtt)
            parentIds.add(ca.Id);
        
        for(Attachment attach : [Select Id, Name, body, ParentId From Attachment Where ParentId IN :parentIds]){
           if(!mapAttachments.containsKey(attach.ParentId)) {
                mapAttachments.put(attach.ParentId, attach);
            }
        }
        for (Contract_Attachment__c ca : lstAllContAtt){
            attachmentWrapper attWrapper = new attachmentWrapper();
            attWrapper.contAttachment = ca;
            attWrapper.contAttId = ca.Id;
            attWrapper.attach = mapAttachments.get(ca.Id);
            System.debug(attWrapper);
            lstAttachmentWrappers.add(attWrapper);
        }
        return lstAttachmentWrappers;
    }
    
    public ContractAttachmentsExtension(ApexPages.StandardController stdController) {
        this.Contract = [Select Id, Name, Expected_Approver__c, CreatedById, OwnerId, Contract_Status__c From Contract__c where Id = :stdController.getRecord().id];  
        hasPermission=false;
        hasDeletePermission = false;
        hasFullPermission = false;
        lstGPOs = [Select AssigneeId from PermissionSetAssignment Where PermissionSet.Name = 'ContractsModifyAll' and AssigneeId = :UserInfo.getUserId()];
        lstSysAdmins = [Select Id from User WHERE (Profile.Name = 'System Administrator' or Profile.Name = 'CRM_System Administrator PS') and Id = :UserInfo.getUserId()];
        if (!lstGPOs.isEmpty() || !lstSysAdmins.isEmpty())
            hasFullPermission = true;
        if (Contract.Contract_Status__c == null)
        {
            hasPermission = true;
        }
        else if (Contract.Contract_Status__c == NEWCONTRACT)
        {           
            if(!hasPermission) //creator or owner (AM)
                hasPermission = this.Contract.CreatedById==UserInfo.getUserId() || this.Contract.OwnerId==UserInfo.getUserId();
            if(!hasPermission && Contract.Expected_Approver__c != null) //approvers
                hasPermission = Contract.Expected_Approver__c == UserInfo.getUserId();
            if(!hasPermission && !lstGPOs.isEmpty()) //GPO
                hasPermission = true;
                
            if(!hasDeletePermission) //creator or owner (AM)
                hasDeletePermission = this.Contract.CreatedById==UserInfo.getUserId() || this.Contract.OwnerId==UserInfo.getUserId();
            if(!hasDeletePermission && !lstGPOs.isEmpty()) //GPO                
                hasDeletePermission = true;
        }
        
        else if (Contract.Contract_Status__c == PENDING)
        {
            if(!hasPermission && Contract.Expected_Approver__c != null) //approvers
                hasPermission = Contract.Expected_Approver__c == UserInfo.getUserId();
            if(!hasPermission) //creator or owner (AM)
                hasPermission = this.Contract.CreatedById==UserInfo.getUserId() || this.Contract.OwnerId==UserInfo.getUserId();
            if(!hasPermission) //GPO
                hasPermission = !lstGPOs.isEmpty();
            
            if(!hasDeletePermission) //GPO              
                hasDeletePermission = !lstGPOs.isEmpty();
        }
        else if (Contract.Contract_Status__c == APPROVED || Contract.Contract_Status__c == ACTIVE)  
        {
            if(!hasPermission) //creator or owner (AM)
                hasPermission = this.Contract.CreatedById==UserInfo.getUserId() || this.Contract.OwnerId==UserInfo.getUserId();
            if(!hasPermission) //GPO
                hasPermission = !lstGPOs.isEmpty();     
        }
        hasDMLExceptions=null;
    }
  
    public PageReference addAttachment()
    {
        Contract_Attachment__c contA = new Contract_Attachment__c(Contract__c=Contract.Id,  Name = 'Attachment for ' + Contract.Name);
        insert contA;
        gotoURL = '/Apex/ContractAttach?Id=' + contA.id;
        PageReference np = new PageReference(gotoURL); 
        np.setRedirect(true);
        return np;  
    }
   
    public pagereference deleteAttachment()
    {     
        if(attachmentToDel!=null)
        {
			if(attachmentToDel != null && attachmentToDel != '')
            	delete new Attachment(id=attachmentToDel);
            delete new Contract_Attachment__c(Id=contAttToDel);
            update Contract;
        }        
        PageReference np = new PageReference('/' + Contract.id); 
        np.setRedirect(true);
        return np;  
    }
}