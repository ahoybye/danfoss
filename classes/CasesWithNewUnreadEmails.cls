/**
* Name : CasesWithNewUnreadEmails
* Author : Subhabrata Basu, Salesforce
* Description : This class holds the Logic to get the List of Cases with New Unread Emails and serves as the Controller for the   
*               CasesWithNewUnreadEmails visualforce page           
*/
global with sharing class CasesWithNewUnreadEmails {
    
    /* Default Constructor */
    public CasesWithNewUnreadEmails () { }

    /**
       @Method Name  : getCasesWithNewEmails
       @description  : This is getter method of List Cases with new Unread Emails.
                       The method returns only the Cases assigned to the current logged in user, if any of the Case has received new Email since last 
                       update of the Case.
                       This method will be called from the javascript of the related Page.
       @param        : NA
       @return       : List<Case>
    */
    @RemoteAction
    global static List<Case> getCasesWithNewEmails() {

		system.debug('$$CasesWithNewUnreadEmails$$ - Start');
        
        List<Id> caseIds = new List<Id>();
        List<String> caseRecordTypes = new List<String>{'Complaint',  'Product Inquiry', 'Service Request', 
                                                           'Support Case', 'Transactional Request'};
        
        // Checking For all the Email Message record which is received after the Case Last Modified and The Owner of the Case is Current
        // logged in User; This will always return the Cases received emails after last modified and only for the Cases owned by Ccurrent Logged in user.
        for(EmailMessage newEmail : [SELECT Id, ParentId, Parent.LastModifiedDate, Parent.OwnerId, MessageDate , CreatedDate from EmailMessage WHERE
                                     Parent.OwnerId =:userinfo.getuserId() AND Status = '0' AND Incoming = TRUE AND
									 Parent.RecordType.Name IN: caseRecordTypes]){            
            //if((newEmail.CreatedDate.getTime() - newEmail.Parent.LastModifiedDate.getTime()) >= 0){
       	        system.debug('$$CasesWithNewUnreadEmails$$ - New Email '+newEmail.ParentId);
                caseIds.add(newEmail.ParentId);
            //}
        }
        
        List<Case> caseWithNewEmails = [SELECT Id, Subject, CaseNumber, Status FROM Case Where Id IN: caseIds];

		system.debug('$$CasesWithNewUnreadEmails$$ - All case id '+caseWithNewEmails);
        
        return caseWithNewEmails;
    }
}