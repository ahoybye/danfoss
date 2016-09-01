/*******************************************************************
* Author        :  Harshit Jain (Appirio Offshore)
* Name          :  LeadManagement_Test
* Date                  :    August 27,2012
* Related Task  :  T-77514
* Description   :  Verify functionality of LeadManagement class.                 
*******************************************************************/
@isTest
private class Test_LeadManagement {
      
        static testMethod void leadCreatedByAdminUser() {
            List<Lead> leadList = new List<Lead>();
            //populate leadList
            Lead lead;
            //for(integer i=0; i<20; i++) {
                lead = Test_Utility.createLead(false, 1);
                lead.Assigned_To__c = 'Account Manager';
                leadList.add(lead); 
            //}
            //On insert trigger lead.Assigned_Date__c will be populated with current date
            Test.startTest();
            insert leadList;
            Test.stopTest();
            
            Lead leadTest = getLead(leadList.get(0).Id);
            system.assertNotEquals(leadTest, null);
            system.assertEquals(leadTest.Assigned_Date__c, Date.today());
            }
    
        
    static testMethod void leadCreatedByPortalUser() {
            Account account = Test_Utility.createAccount(1);
            insert account;
			State_Province__c sp = new State_Province__c(Name = 'confusion');
			insert sp;
            //create contact to be used for portal user
            Contact contactPortal = Test_Utility.createContact(account.Id,2);
            insert contactPortal;
            List<Profile> portalUserProfiles = [Select id from Profile where Name IN ('PartnerLink - Full') limit 1];
            system.assertEquals(portalUserProfiles.size(), 1);  
            User portalUser = Test_Utility.createPortalUser(contactPortal.Id, portalUserProfiles.get(0).Id, 1);
            insert portalUser;
			Group grp = new Group(Name = 'Marketing', Type = 'Queue');
			insert grp;
			QueueSobject qu = new QueueSobject(QueueId = grp.Id, SobjectType = 'Lead');
			System.runAs(new User(Id = UserInfo.getUserId())) {   
			    insert qu;
			}
            //login as portal user
            //If Lead is created by portal user than Assigned_Date__c and Assigned_To__c should be populated
            system.runAs(portalUser) {
                List<Lead> leadList = new List<Lead>();
                //populate leadList
                Lead lead;                
                lead = Test_Utility.createLead(false, 1);
                lead.Account_Manager__c = Userinfo.getUserId();
                lead.OwnerId = portalUser.Id;	
				leadList.add(lead);
			
                lead = Test_Utility.createLead(false, 2);
                lead.Account_Manager__c = Userinfo.getUserId();
                lead.OwnerId = qu.QueueId;
				lead.Country = 'USA';
				lead.PostalCode = 'bellvue';
				lead.State = 'confusion';
				lead.City = 'of angels';
				lead.Street = 'skid row';					
                leadList.add(lead); 
                
                //On insert trigger lead.Assigned_Date__c and lead.Assigned_To__c will be populated.
                Test.startTest();
                insert leadList;
                Test.stopTest();

                Lead leadTest = getLead(leadList.get(0).Id);
                system.assertNotEquals(leadTest, null);
				Database.LeadConvert lc = new Database.LeadConvert();		
				lc.setLeadId(leadTest.id);
				lc.setDoNotCreateOpportunity(false);
				lc.setConvertedStatus('Converted');

				Database.LeadConvertResult lcr = Database.convertLead(lc);
				System.assert(lcr.isSuccess());
            }
    }   
    
    //get Lead record
    private static Lead getLead(Id leadId) {
        return [select Assigned_Date__c,Assigned_To__c,OwnerId from lead where Id =:leadId limit 1];
    }
}