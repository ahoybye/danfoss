public without sharing class WeeklyDOWReportRunner
{
	
    public static Id RunReportAndSendMailAndAttachment(string BusinessOrg)
    {
        List<DOW_Report_Setting__c> lstReport =[Select Document_Folder__c,Email_To_Contact__c,
                                                OrgWideEmail__c,
                                                Email_template__c,Send_Email__c
                                                FROM DOW_Report_Setting__c where Name = :BusinessOrg];
        if(lstReport.size()==0)
            return null;
        PageReference pdf = Page.WeeklyReportDOW;
        pdf.getParameters().put('ar','');
        pdf.getParameters().put('bo',BusinessOrg);
        pdf.getParameters().put('RunTime',String.valueOf(DateTime.Now().Day()));
        Blob body;
        List<Id> idList = new List<Id>();
        string textError = 'No Error';
        try 
        {
            body = pdf.getContentAsPDF();
        }
        catch (VisualforceException e) 
        {
            textError = 'Error is here:'+e.getmessage();
        }  
        Document doc = new Document(Type='pdf',Ispublic = True,FolderId=lstReport[0].Document_Folder__c);
        string reportName = BusinessOrg;
        if(BusinessOrg =='Integrated')
            reportName = 'Danfoss';
        Datetime dt = DateTime.Now().addDays(-7);
        reportName = reportName +'WeeklyDow_'+ dt.format('w_yyyy') +'.pdf';
        doc.name = reportName;
        doc.Body = body;
        insert doc; 
        idList.add(doc.id);
        
        if(lstReport[0].Send_Email__c)
        {      
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(lstReport[0].Email_template__c);
            mail.setTargetObjectId(lstReport[0].Email_To_Contact__c);
            mail.setDocumentAttachments(idList);
            mail.setOrgWideEmailAddressId(lstReport[0].OrgWideEmail__c);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        return doc.Id;
    }
    public static testMethod  void testRunReport()
    {
        Account acct = Test_Utility.createAccount(1);
		insert acct;
		Contact cont = Test_Utility.createContact(acct.Id, 1);
		insert cont;
        DOW_Report_Setting__c rep = DOW_Report_Setting__c.getInstance('Integrated');
        rep.Email_to_Contact__c = (string)cont.Id;
		update rep;
		test.StartTest();
        RunReportAndSendMailAndAttachment('Integrated');
        test.StopTest();
        boolean iserror = false;
        try
        {
        delete cont;
        }
        catch(Exception ex)
        {
            system.Debug('------------------------'+ex.getMessage());
            iserror=true;
        }
        system.assertEquals(isError,true);
             
    }
}