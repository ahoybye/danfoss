/*---------------------------------------------------------------------
  Author        :   Appirio Offshore(Nikita Jain)
  Date          :   July 25, 2012
  Description   :   Test class for BeforeLeadInsertUpdate trigger
                    (Trigger on Lead that copies custom address fields from
                    standard ones. Country and state are queried from the 
                    related objects to populate the custom references.)
  Related Task  :   Task T-64473    
//---------------------------------------------------------------------*/
@isTest
private class Test_BeforeLeadInsertUpdate {

    Static List<Lead> leadlist;
    Static Region__c reg;
    Static State_Province__c state;
    
    //Test method to test lead insert
    //custom address fields getting populated from standard adress fields
    @isTest
    static void testFieldUpdateInsertCase() {
        createData();
        
        for(Lead ld : [Select Zip_Code__c, Street, State_Province__c, Country__c,
                               City__c , City , Country , State , PostalCode , Street__c
                               FROM lead WHERE id = :leadlist]){                                                                 
            system.assertEquals(ld.Zip_Code__c , ld.PostalCode);
            system.assertEquals(ld.Street__c , ld.Street);
            system.assertEquals(ld.City__c , ld.City);
            system.assertEquals(ld.State_Province__c , state.Id);
            system.debug('========'+ld.Country__c);
            system.debug('========'+reg.Id);
            system.assertEquals(ld.Country__c , reg.Id);
        }   
    }
    
   //Test method to test lead update
   //custom address fields getting populated from standard adress fields 
   @isTest
    static void testFieldUpdateUpdateCase() {
        createData();
        updateData();
                    
        for(Lead ld : [Select Zip_Code__c, Street, State_Province__c, Country__c,
                               City__c , City , Country , State , PostalCode , Street__c
                               FROM lead WHERE id = :leadlist]){                                                           
            system.assertEquals(ld.Zip_Code__c , ld.PostalCode);
            system.assertEquals(ld.Street__c , ld.Street);
            system.assertEquals(ld.City__c , ld.City);
            system.assertEquals(ld.State_Province__c , state.Id);
            system.assertEquals(ld.Country__c , reg.Id);
        }
    }
    
    
    //Method to create dummy data 
    static void createData(){
        reg = new Region__c();
        reg.Country_Code__c = 'TC';
        reg.Name = 'test country';
        insert reg;
        
        state = new State_Province__c();
        state.Name = 'test state';
        insert state;
        
        leadlist = new list<Lead>();
        for(integer i = 0 ; i < 5 ; i++){       
            Lead lead = new Lead();
            lead.City = 'test City';
            lead.Country = 'test country';
            lead.State = 'test state';
            lead.PostalCode = '1234';
            lead.Street = 'test street';
            lead.LastName = 'test lastname'+'i';
            lead.Company = 'test company';
            leadlist.add(lead);
        } 
        insert leadlist;
    }
    
    //Method to update leads
    static void updateData(){
         list<lead> updateLead = new list<Lead>();
         for(Lead ld : [Select Zip_Code__c, Street, State_Province__c, Country__c,
                               City__c , City , Country , State , PostalCode , Street__c
                               FROM lead WHERE id = :leadlist]){
            ld.PostalCode = '0011';
            ld.City = 'test City1';
            ld.Street = 'test upate street';
            updateLead.add(ld);
         }
         update updateLead;     
    }
         
}