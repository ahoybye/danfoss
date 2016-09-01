public with sharing class customSendEmailController {
    public String subject { get; set; }
	public String body { get; set; }
    public string to { get; set;}
    public string cc {get; set;}
    public string language {get; set;}
    public string emailtemplate {get; set;}
    public string fromEmail {get; set;}
    public string replyToEmailAddr {get; set;}
    public boolean qattachdefault {get; set;}
    private final string objectId;
	private final Quote quote;	 
    //private List<fileAttachment> attachments;
    private List<fileAttachment> quoteAttachments;
    private List<fileAttachment> otherAttachments;
    
    public string getObjectId() {
        return objectId;
    }
    
    //--SELECT id, name, body, bodylength, description, ContentType, folderid from attachment where parentid='0Q04B00000003Uf'

	// Create a constructor that populates the Account object
	public customSendEmailController() {
		qattachdefault=true;
		objectId = ApexPages.currentPage().getParameters().get('id'); 
        string paramLanguage = ApexPages.currentPage().getParameters().get('lang');
        //EmailTemplate emailTemplate = [select Body, HtmlValue, Subject, DeveloperName, BrandTemplateId from EmailTemplate where DeveloperName='EMAIL_TEMPLATE_NAME' limit 1];
                
		quote = [SELECT Id, ContactId, Name, QuoteNumber, Status, OpportunityId, opportunity.Sales_Area__c, External_Sales_Org__c, Contact_Email__c, ConfigitQuoteRev__c, ConfigitQuoteRevDisplay__c, Customer_Request_Date__c, RFQ_Number__c, Price_Valid_From__c, Price_Valid_To__c, Valid_From__c, Valid_To__c, opportunity.Sales_Area__r.Master_Sales_Org__c                  
                   FROM quote
                   WHERE Id = :objectId];        
        
        string quote_sales_org;
        // Determine Sales Org - for determining template - and language
        if (quote.opportunity.Sales_Area__c!=null) {
                quote_sales_org = quote.opportunity.Sales_Area__r.Master_Sales_Org__c;                                
		} else if (quote.External_Sales_Org__c!=null) {  // Prio 2  - use the quote External_Sales_Org__c
                quote_sales_org = quote.External_Sales_Org__c;                
        }
        
        
		        
        if (!string.isBlank(paramLanguage)) {  //only continue if the lang page parameter was set - else the VF page will redirect using javascript - and set the lang parameter
        	prepareEmailQuote(quote, quote_sales_org);    
        } else {
            // find the language from a custom metadata type - the vf page will redirect
        	try {
            	QuoteEmailLanguage__mdt qel = [SELECT IsoLanguageCode__c FROM QuoteEmailLanguage__mdt WHERE SalesOrg__c = :quote_sales_org];
                language = qel.IsoLanguageCode__c;
                
            } catch (Exception qel_ex) {
                language = UserInfo.getLocale();
			}
        }
		
        
        
    }
    
    private void prepareEmailQuote (Quote quote, String quote_sales_org) {
        
        //attachments = new List<fileAttachment>();
        otherAttachments = new List<fileAttachment>();
        quoteAttachments = new List<fileAttachment>();
        
        for (attachment a: [SELECT id, name, description, body, ContentType, bodyLength, LastModifiedDate, CreatedDate from attachment where parentid=:objectId limit 50]) {
            fileAttachment ea = new fileAttachment(a);            
            ea.selected=qattachdefault;
            quoteAttachments.add(ea);                            
        }
        for (attachment a: [SELECT id, name, description, body, ContentType, bodyLength, LastModifiedDate, CreatedDate from attachment where parentid=:quote.OpportunityId limit 50]) {
            fileAttachment ea = new fileAttachment(a);            
            ea.selected=false;
            otherAttachments.add(ea);                            
        }
        subject = quote.Name + ' - ' + quote.QuoteNumber + ' - ' + quote.ConfigitQuoteRevDisplay__c;
        //to = quote.Contact_Email__c;
        to='';
        cc='';
        
		// Extract user signature to use in email body
        user u = [select id, signature, name from user where id = :UserInfo.getUserId()];
		string usig;
        string uname = u.name;
        if (u.Signature!=null) {
        	usig = '<br/><br/>' + u.signature.replace('\n', '<br/>') ;    
        } else 
        {
            usig = '<br/><br/>';
        }
        
        // Fallback solution
        body=usig;
        
        emailtemplate = 'CE_QUOTE';        
        Contact c;
        EmailTemplate et;
        boolean useGenericTemplate = true;
        
        // get all contact fields
        string cselectfields='id';
        List<string> lstContactFields = new List<string>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
       	Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Contact').getDescribe().fields.getMap();
		for(Schema.SObjectField sfield : fieldMap.Values())
		{
			schema.describefieldresult dfield = sfield.getDescribe();
			
			string fieldname = dfield.getname();
            if (!fieldname.equalsIgnoreCase('id')) {
                // translate picklist values using toLabel()
                if (dfield.getType().equals(DisplayType.Picklist ) || dfield.getType().equals(DisplayType.MultiPicklist)) {
                    cselectfields = (cselectfields + ',toLabel(' + fieldname + ')');
                } else {
                	cselectfields = (cselectfields + ',' + fieldname);    
                }            	
            }
            lstContactFields.add(fieldname);			
		}
        
        try {                        
            // extract all contact fields
            //c = [SELECT firstname, lastname, name, salutation, title, academic_title__c FROM CONTACT WHERE id=:quote.ContactId limit 1];
            c = Database.query('SELECT ' + cselectfields + ' FROM CONTACT WHERE id=\'' + quote.ContactId + '\' limit 1');
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.WARNING, ex.getMessage() + 'No contact selected - please select a contact on the quote'));
        }
        
        string email_sales_org;
        try {        	
            // Use the opportunity Sales Org to decide email template used
            if (!Test.isRunningTest() && !String.isBlank(quote_sales_org)) {                
                emailtemplate = 'CE_QUOTE_' + quote_sales_org;
                useGenericTemplate = false;            
            }
            
            // Extract the email template
            et = [SELECT id, body, subject, htmlvalue FROM EmailTemplate WHERE DeveloperName=:emailtemplate and isActive=true limit 1];    
            
            // setup the template map - for replacing values
            Map<String, String> mapBodyParams = new Map<String, String> {            	
                '{!Quote.QuoteNumber}' => quote.QuoteNumber,
                '{!Quote.Name}' => quote.Name,
                '{!Quote.ConfigitQuoteRev__c}' => quote.ConfigitQuoteRev__c,
                '{!Quote.ConfigitQuoteRevDisplay__c}' => quote.ConfigitQuoteRevDisplay__c,
                '{!Quote.Customer_Request_Date__c}' => quote.Customer_Request_Date__c!=null ? quote.Customer_Request_Date__c.format() : '',
                '{!Quote.RFQ_Number__c}' => quote.RFQ_Number__c,
                '{!Quote.Price_Valid_From__c}' => quote.Price_Valid_From__c != null ? quote.Price_Valid_From__c.format() : '',
                '{!Quote.Price_Valid_To__c}' => quote.Price_Valid_To__c!=null ? quote.Price_Valid_To__c.format() : '',
                '{!Quote.Valid_From__c}' => quote.Valid_From__c != null ? quote.Valid_From__c.format() : '',
                '{!Quote.Valid_To__c}' => quote.Valid_To__c != null ? quote.Valid_To__c.format() : '',
            	'{!User.Signature}' => usig,
                '{!User.Name}' => uname,
                '<![CDATA[' => '',
                ']]>' => ''
			};
            // Dynamically add contact fields
            for (string field : lstContactFields) {
            	string templatetext = '{!Contact.' + field +'}';                
                mapBodyParams.put(templatetext, string.valueOf(c.get(field)));            
            }
            
            
            if (et!=null && et.HtmlValue!=null) {
            	body=et.HtmlValue;
        		subject = et.Subject;    
            	for (String key : mapBodyParams.keySet()) {
                	body = body.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
                    subject = subject.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
            	}            
            }
                            
        } catch (Exception ex) {
            if (useGenericTemplate) {
                ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.WARNING, 'No generic email template available - user signature inserted'));
            } else {
            	ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.WARNING, 'No email template available for sales area ' + email_sales_org + ' - user signature inserted'));    
            }
            
        }
    }
    /*
    public void populateTemplate(){ // call in page tag - for email template preparation/merge [action="{!populateTemplate}"]        
        EmailTemplate emailTemplate = [select Id, Body, HtmlValue, Subject, DeveloperName, BrandTemplateId from EmailTemplate where id='00X4B000000Lxr7'];        
        Map<String,String> mergedMail = mailUtils.getMergedTemplateForObjectWithoutSending(quote.ContactId, quote.OpportunityId, emailTemplate.Id, false, false, '');
        body = mergedMail.get('textBody');
        subject = mergedMail.get('subject');        
    }
    */    
    
	public Quote getQuote() {
        return quote;
    }
    /*
    public List<fileAttachment> getAttachments() {
        return attachments;
    }
	*/
    public List<fileAttachment> getQuoteAttachments() {
        return quoteAttachments;
    }
    public List<fileAttachment> getOtherAttachments() {
        return otherAttachments;
    }
    
    public List<SelectOption> getOrgWideAddresses(){
        // Use Organization Wide Address 
        //List<OrgWideEmailAddress> orgWideEmails = [select id, Address, DisplayName from OrgWideEmailAddress];
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('0',UserInfo.getUserEmail()));
        for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress where IsAllowAllProfiles=true]) {  
            result.add(new SelectOption(owa.id,owa.address));		
            //email.setOrgWideEmailAddressId(owa.id); 
        }
        return result;
    }
    
    public List<SelectOption> getReplyToEmail(){
        
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('0',UserInfo.getUserEmail()));
        for(replyToEmail__c rte : [select id, name, email__c from replyToEmail__c LIMIT 50]) {  
            result.add(new SelectOption(rte.id,rte.name + ' <' + rte.email__c + '>'));            
        }
        return result;
    }


    public PageReference back() {
        return new PageReference('/' + objectId);
    }
    
    public PageReference send() {
                
		        
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setTargetObjectId(quote.ContactId);
        email.saveAsActivity=true;
        email.useSignature=false;
        
        
        if (replyToEmailAddr!='0') {
        	replyToEmail__c rte = [select id, name, email__c from replyToEmail__c where id = :replyToEmailAddr LIMIT 1];    
            if (rte!=null) {
            	email.setReplyTo(rte.email__c); 
        		email.setSenderDisplayName(rte.name); 
            }
        }
        if (fromEmail!='0') {
            email.setOrgWideEmailAddressId(fromEmail);
            email.setSenderDisplayName(null);
        }
        
        //email.setTemplateId(objectId);
        //email.setTreatBodiesAsTemplate=true;
        // Reference the attachment page and pass in the account ID
        //PageReference pdf =  Page.attachmentPDF;
        //pdf.getParameters().put('id',(String)account.id);
        //pdf.setRedirect(true);	 
	
		//efa.setFilename( 'myAttachmentName.txt');
		//efa.setbody(Blob.valueOf('Unit Test Attachment Body'));
	
        //String addresses = to;
       	
		/*
	    if (account.Contacts[0].Email != null) {
	    	addresses = account.Contacts[0].Email;
	    	// Loop through the whole list of contacts and their emails
			for (Integer i = 1; i < account.Contacts.size(); i++) {
	        	if (account.Contacts[i].Email != null) {
	           		addresses += ':' + account.Contacts[i].Email;
				}
			}
		}
	    */
        String[] toAddresses;
        String[] ccAddresses;
        
        if (to.length()>0) {
         	toAddresses= to.split(';', 0);   
        }         
        if (cc.length()>0) {
        	ccAddresses = cc.split(';', 0);    
        }
        
            
	    // Sets the paramaters of the email
	    email.setSubject( subject );
	    email.setToAddresses( toAddresses );
        email.setCcAddresses( ccAddresses );
	    //email.setPlainTextBody( body );
        email.setHTmlBody(body);
        
            
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        integer attch_cnt = 0;
        for (fileAttachment fa : quoteAttachments) {
            if (fa.selected) {
                attch_cnt++;
        		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
				efa.Body = fa.file.Body;
				efa.FileName = fa.file.Name;
				efa.ContentType = fa.file.ContentType;
                efa.setInline(false);
                emailAttachments.add(efa);
        	}
        }
        for (fileAttachment fa : otherAttachments) {
            if (fa.selected) {
                attch_cnt++;
        		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
				efa.Body = fa.file.Body;
				efa.FileName = fa.file.Name;
				efa.ContentType = fa.file.ContentType;
                efa.setInline(false);
                emailAttachments.add(efa);
        	}
        }
        
        email.setFileAttachments(emailAttachments);
		
        // Check that at least one attachment is selected
        if (attch_cnt>0) {
            // Sends the email
		    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
            if (r[0].success) {                
                ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.INFO, 'The email was sent successfully'));
                
                // Insert a new
                Task newQuoteEmailTask = new Task(Subject = 'Email: ' + email.getSubject(), 
     				OwnerId = UserInfo.getUserId(), WhatId = objectId, WhoId = quote.ContactId,
     				Status = 'Completed', ActivityDate = Date.today(), Priority = 'Normal', 
     				Description = GenerateTaskComment(email));
				INSERT newQuoteEmailTask; 
                
                quote.Status='Sent';
                update quote;
                
                return new PageReference('/' + objectId);
                
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.INFO, 'The email failed to send: ' + r[0].errors[0].message));                
            }
        } else {
             ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.WARNING, 'Please select at least one attachment'));
        }
        
	    return null;
	}
    
    private static String GenerateTaskComment(Messaging.SingleEmailMessage newEmail)
	{
    	List<String> listOfFileNames = new List<String>();

    	for(Messaging.EmailFileAttachment singleAttachment : newEmail.getFileAttachments())
        	listOfFileNames.add(singleAttachment.getFileName());

    	String endOfDescription = '_____________________________________________________________________'
    	+ '\nPowered by salesforce.com\nhttp://www.salesforce.com/';

    	return 'Additional To: '+ String.join(newEmail.getToAddresses() != null ? newEmail.getToAddresses() : new List<String>(), ',')
            + '\nCC: ' + String.join(newEmail.getCcAddresses() != null ? newEmail.getCcAddresses() : new List<String>(), ',') 
            + '\nBCC: ' + String.join(newEmail.getBccAddresses() != null ? newEmail.getBccAddresses() : new List<String>(), ',') 
            + '\nAttachment'+ (listOfFileNames.size() > 1 ? 's' : '') + ': ' + String.join(listOfFileNames, ',')
            + '\n\nSubject: ' + newEmail.getSubject()
            + '\nBody:\n' + newEmail.getPlainTextBody()
            + '\n\n' + endOfDescription;
	}
    
    //(Selection) wrapper class for attachments
    public class fileAttachment {
        public boolean selected;
        public Attachment file;
        
        public fileAttachment(attachment f) {
            selected=false;
            file = f;
        }
        
        public boolean getSelected() {
            return selected;
        }
        public void setSelected(Boolean b) {
            selected=b;
        }
        
        public Attachment getFile() {
            return file;
        }
        
    }
}