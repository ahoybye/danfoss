/*---------------------------------------------------------------------
  Author        :   Appirio Offshore(Nikita Jain)
  Date          :   July 25, 2012
  Description   :   Test class for AfterLeadConvert trigger
                    (Trigger on Lead maps custom address fields of lead to
                     Shipping address field of account and mailing address of contact)
  Related Task  :   Task T-65155    
//---------------------------------------------------------------------*/
@isTest
private class Test_AfterLeadConvert {
 
    static Lead lead;
    @isTest 
    static void testLeadConvert() {
        createData();
        
        //Converting lead
        Database.LeadConvert lc = new database.LeadConvert();
        
        lc.setLeadId(lead.Id);
        LeadStatus convertstatus = [select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult results = Database.convertLead(lc);
        
        lead ld = [Select l.ConvertedAccount.ShippingCountry, l.ConvertedAccount.ShippingPostalCode,
                     l.ConvertedAccount.ShippingState, l.ConvertedAccount.ShippingCity,
                     l.ConvertedAccount.ShippingStreet, l.ConvertedAccountId , City__c , Country__r.name ,
                     State_Province__r.name, Zip_Code__c, Street__c, l.ConvertedContact.MailingCountry,
                     l.ConvertedContact.MailingPostalCode, l.ConvertedContact.MailingState,Business_Org__c,
                     Channel__c, l.ConvertedAccount.Channel__c, 
                     l.ConvertedContact.MailingCity, l.ConvertedContact.MailingStreet, l.ConvertedContactId,
                     ConvertedAccount.Business_Org__c From Lead l where id = :lead.Id];
                     
        /*system.assertEquals(ld.ConvertedAccount.ShippingCountry , ld.Country__r.name);
        system.assertEquals(ld.ConvertedAccount.ShippingState , ld.State_Province__r.name); 
        system.assertEquals(ld.ConvertedAccount.ShippingCity , ld.City__c); 
        system.assertEquals(ld.ConvertedAccount.ShippingStreet , ld.Street__c); 
        system.assertEquals(ld.ConvertedAccount.ShippingPostalCode , ld.Zip_Code__c);
        system.assertEquals(ld.ConvertedAccount.Business_Org__c , ld.Business_Org__c);  
        system.assertEquals(ld.ConvertedAccount.Channel__c , ld.Channel__c);         
        
        
        system.assertEquals(ld.ConvertedContact.MailingCountry , ld.Country__r.name);
        system.assertEquals(ld.ConvertedContact.MailingState , ld.State_Province__r.name);  
        system.assertEquals(ld.ConvertedContact.MailingCity , ld.City__c);  
        system.assertEquals(ld.ConvertedContact.MailingStreet , ld.Street__c);  
        system.assertEquals(ld.ConvertedContact.MailingPostalCode , ld.Zip_Code__c);  */               
        
    }
    
    //Method to create dummy data 
    static void createData(){
        Region__c reg = new Region__c();
        reg.Country_Code__c = 'TC';
        reg.Name = 'test Country';
        insert reg;
        
        State_Province__c state = new State_Province__c();
        state.Name = 'test state';
        insert state;
        
        Account acct = Test_Utility.createAccount(1);
        insert acct;
        
        Opportunity oppty = Test_Utility.createOpportunity(acct.Id, 1);
        insert oppty;
        
        lead = new Lead();
        lead.City = 'test City';
        lead.Country = 'test Country';
        lead.State = 'test state';
        lead.PostalCode = '1234';
        lead.Street = 'test street';
        lead.LastName = 'test lastname'+'i';
        lead.Company = 'test company';
        //lead.ConvertedOpportunityId = oppty.Id;
        lead.Account_Manager__c = system.Userinfo.getUserId();
        lead.Distributor__c = system.Userinfo.getUserId();
        insert lead;
        
        
    }
    
}