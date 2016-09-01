public class CaseNewEmailExtension {
    public String emailURL { get; set; }
    public case ca {get; set;}
    public string p26 = '';
    public string p24 = '';
    public string p2 = '';
    public string p6 = '';
    public CaseNewEmailExtension(ApexPages.StandardController controller)
    {
        //create a url which has the parameters setting from address, p26....Contact, p2....and p6 subject
        //the page has the javascript to open tabs etc - this should be optimized
        case c = (Case) controller.getRecord();
        ca = [select id, suppliedemail,subject, Case_Email_Sent_To__c,Contactid, casenumber from case where id=:c.id];

        p2 = ca.Contactid;
        //p2 = String.valueOf(ca.Contactid).substring(0, 15);
       
        if (ca.Contactid == null)
        {  
            p24 = '';
            if(ca.suppliedemail!=null)
            {p24= ca.suppliedemail;}
            
        }
        
        p6 = 'Case Number:' + ca.casenumber ;
        
        if (ca.Case_Email_Sent_To__c != null)
        {
            //added just in case email sent to multiple addresses - unlikely but possible
        string emails =  ca.Case_Email_Sent_To__c;
        list<string> listemails = emails.split(';');
        p26 = listemails[0];
        //system.debug('1 listemails' + listemails );
        //system.debug('2 p26' + p26 );    
        }
        
        if (ca.Case_Email_Sent_To__c == null)
        {
            p26 = [select Call_Centre_Default_Email__c from user where id=:UserInfo.getUserId()].Call_Centre_Default_Email__c;
        //  system.debug('4 p26' + p26 );    
        }

        emailURL =  '/_ui/core/email/author/EmailAuthor?p3_lkid='+ String.valueOf(ca.Id).substring(0, 15)+ '&p2_lkid='+ p2 + '&p6='+ p6 + '&p24='+ p24 + '&p26='+ p26+ '&textmode=r&p5=';
        //system.debug('3 emailtemp' + emailURL );      
       
        //emailURL = emailtemp + '&p26=' + p26;        
        // system.debug('5 emailURL' + emailURL );      
    
  
    }   
}