/**
* Name : CasesWithNewUnreadEmailsTest
* Author : Subhabrata Basu, Salesforce
* Description : This is the Test Class for CasesWithNewUnreadEmails Class           
*/
@isTest
public with sharing class CasesWithNewUnreadEmailsTest {

    /**
       @Method Name  :getCasesWithNewEmails_Test
       @description  : This Method test the getCasesWithNewEmails methods of the CasesWithNewUnreadEmails class.
       @param        : NA
       @return       : NA
   */  
    private static testmethod void getCasesWithNewEmails_Test(){
        
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Case' AND Name = 'Support Case'];
        Case newCase = new Case(Subject = 'Test Email Case', RecordTypeId = rt.Id,
                                Reason = 'Sales & Marketing Support', Origin = 'Email', 
                                Priority = 'Low', SuppliedEmail = 'test@emailtest.com');
        
        Database.SaveResult sr = Database.insert(newCase);
        
        EmailMessage newEmail = new EmailMessage(Incoming = TRUE, ParentId = sr.getId(), Subject = 'Test Email',
                                                 Status = '0', TextBody = 'Test Email Body');

        insert newEmail;
        CasesWithNewUnreadEmails classInstance = new CasesWithNewUnreadEmails();
        CasesWithNewUnreadEmails.getCasesWithNewEmails();
    }

}