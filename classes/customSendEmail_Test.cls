@isTest
public class customSendEmail_Test {

    public static testMethod void test_customSendEmail() {
		Quote q = createTestData();
        
        // add attachment - since minimum one quote attachment is required for sending
        Attachment qattach=new Attachment();    
		qattach.Name='Quote Attachment';		
		qattach.body=Blob.valueOf('Unit Test Attachment Body');
        qattach.parentId=q.id;
        insert qattach;
        
        Attachment oattach=new Attachment();    
		oattach.Name='Opportunity Attachment';	
		oattach.body=Blob.valueOf('Unit Test Attachment Body');
        oattach.parentId=q.OpportunityId;
        insert oattach;
                
                
        PageReference pageRef = Page.customSendEmail;
		Test.setCurrentPage(pageRef);
        apexpages.currentpage().getparameters().put('id' , q.id);
        apexpages.currentpage().getparameters().put('lang' , 'en');

        // initiate controller - and check page parameter (from query string)
        customSendEmailController cem = new customSendEmailController();
        System.assertEquals(q.Id, cem.getObjectId());

        // check helper functions
		cem.getOrgWideAddresses();
        cem.getReplyToEmail();
        cem.getQuote();
        
        System.assertEquals('/' + q.Id, cem.back().getUrl());
        // set testing values
        cem.fromEmail = '0';
        cem.replyToEmailAddr='0';
        cem.to='ab=danfoss.com@example.com;cd=danfoss.com@example.com';
        cem.cc='ef=danfoss.com@example.com;gh=danfoss.com@example.com';
        
        // check quote attachments
        List<customSendEmailController.fileAttachment> qa = cem.getQuoteAttachments();
        System.assertEquals(1, qa.size());
        if (qa.size()==1) {            
            boolean qb = qa[0].getSelected();
        	qa[0].setSelected(true);
        }        
        
        // check opportunity attachments
        List<customSendEmailController.fileAttachment> oa = cem.getOtherAttachments();
        System.assertEquals(1, oa.size());
        if (oa.size()==1) {
            boolean ob = oa[0].getSelected();
        	oa[0].setSelected(true);
        }
        
        // check if send completes and return page reference to quote (id)
        PageReference resultPage = cem.send();                
        System.assertEquals('/' + q.Id, resultPage.getUrl());        

    }
    
    public static quote createTestData () {
                      
        
        /* Price Book */
        Pricebook2 pb = Test_DataFactory.create_CE_PriceBook();        
        insert pb;
        
        /* Create CE Customer */        
        Account account = Test_DataFactory.create_CE_Customer('Danfoss', 'USD', 'DK', 'CER');
        account.ShippingCountry = 'DK';
        account.ShippingPostalCode = '6430';
        account.ShippingCity = 'Nordborg';
        account.ShippingStreet = 'Nordborgvej 81';        
        insert account;
                
        Sales_Area_Master__c sam = Test_DataFactory.create_SalesAreaMaster('2300','00','00');
        insert sam;
                        
        Sub_Account__c sa = Test_DataFactory.create_SubAccount(account.name, '23456789', account);
        insert sa;
        
        Sales_Area__c sao = Test_DataFactory.create_salesArea(sa, sam);
        insert sao;               
        
        Test_DataFactory.setMaster(account, sa);        
        update account;
        
        contact c = new contact();        
        c.Academic_Title__c = 'Professor';
        c.AccountId = account.Id;
        c.FirstName = 'Anders';
        c.LastName = 'Breinholt';
        c.Phone = '+45 12345678';
        c.Email = 'ab=danfoss.com@example.com';
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.accountId = account.Id;
        opp.Name = 'My Test Opportunity';
        opp.Sub_Account__c = sa.Id;
        opp.Sales_Area__c = sao.Id;
        opp.RecordTypeId = [SELECT Id FROM recordtype WHERE sObjectType='Opportunity' and DeveloperName = 'CE_Opportunity' and IsActive=true LIMIT 1].Id;
        opp.CurrencyIsoCode = 'USD';
        opp.Amount  = 5000;
        opp.Contact__c = c.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Initiated';        
        insert opp;
        
        Quote q = new Quote(ConfigitQuoteId__c = '012345678', OpportunityId=opp.Id, Status='In Progress');
        q.RecordTypeId = [SELECT Id FROM recordtype WHERE sObjectType='Quote' and DeveloperName = 'CE_Quote' and IsActive=true LIMIT 1].Id;
		q.ConfigitQuoteRev__c = 'R1';
		q.ExpirationDate = Date.today(); 
        q.Name= 'My Test Quote';
		q.ContactId=c.Id;
        q.Custom_Account_Lookup__c=account.Id;
        q.Sub_Account__c = sa.Id;
		q.Pricebook2Id = pb.Id;
		insert q;
        
               
        
        
        return q;
    }
}