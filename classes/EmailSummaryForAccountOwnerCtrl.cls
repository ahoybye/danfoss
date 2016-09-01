/*
* @author Ankit (Appirio Ind.)
* @description  Controller class for EmailSummaryForAccountOwner
*/
public with sharing class EmailSummaryForAccountOwnerCtrl {
    
    public String bullAcctId {get; set;}
    public String notifiType {get; set;}
    public String accId {get; set;}
    public String area {get; set;}
    public String BDJName {get; set;}
    public String BDJId {get; set;}
    private static final String NOTIFICATION_TYPE_PIB_NON_SENSITIVE = 'PIB Non-Sensitive';
    private static final String NOTIFICATION_TYPE_SERVICE_BULLETIN = 'Service Bulletin';
    
    private List<Contact> m_lstContact;
    public List<Contact> lstContact {
        get{
            if(m_lstContact != null && !m_lstContact.isEmpty()){
                return m_lstContact;
            }
            m_lstContact = new List<Contact>();
            if(notifiType != null && notifiType == NOTIFICATION_TYPE_PIB_NON_SENSITIVE){
                m_lstContact = [Select Id, Name, Email, Title, Role__c, Department__c From Contact Where AccountId = :accId And Product_Information_Bulletin__c = true And PIB_BU__c INCLUDES (:area) And Inactive_Contact__c = false order by Lastname];
            } else if(notifiType != null && notifiType == NOTIFICATION_TYPE_SERVICE_BULLETIN){
                m_lstContact = [Select Id, Name, Email, Title, Role__c, Department__c From Contact Where AccountId = :accId And Service_Bulletin__c = true And PIB_BU__c INCLUDES (:area) And Inactive_Contact__c = false order by Lastname];
            }
            return m_lstContact;
        }
    }
	public string acctName {
		get{
            List<Account> lstAccts = [select Name from Account where Id = :accId limit 1];
            if (lstAccts.size() > 0){
				Account acct = lstAccts[0];
				return acct.Name;
        	}
        	else
                return '<account name>';
		}
	}
    
    public string jobType {
        get{
            if (notifiType == NOTIFICATION_TYPE_PIB_NON_SENSITIVE){
                return 'PIB';
            }
            else if (notifiType == NOTIFICATION_TYPE_SERVICE_BULLETIN){
                return 'Service Bulletin';
            }
            else
                return '';
        }
    }
    
    public string jobTypeFull {
        get{
            if (notifiType == NOTIFICATION_TYPE_PIB_NON_SENSITIVE){
                return 'Non-Sensitive PIB';
            }
            else if (notifiType == NOTIFICATION_TYPE_SERVICE_BULLETIN){
                return 'Service Bulletin';
            }
            else
                return '';
        }
    }
    
    public string fullURL {
        get{
            List<Attachment> lstattach = [select Id from Attachment where ParentId = :bullAcctId limit 1];
            if (lstattach.size() > 0){
                Attachment attach = lstattach[0];
            	return URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + attach.Id;
        	}
            else
                return URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + bullAcctId;
        }
    }    
}