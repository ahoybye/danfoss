/**************************************************************************
Name            : Test_MarketingToolboxCtrl
Description     : Test Class for MarketingToolboxCtrl
Created By      : Arvind Thakur
Date            : 24rd Dec, 2014
Task            : T-346183
***************************************************************************/
@isTest
private class Test_MarketingToolboxCtrl {
    
    static User adminUser;
    static User testUser;
    
    static testMethod void testMarketingToolBoxCtrl() {
    	
    	createTestData();
    	String testString;
    	system.runAs(testUser){
    		 test.startTest();
    		 MarketingToolboxCtrl controller = new MarketingToolboxCtrl();
             testString = controller.COMATROL_ORG;
             test.stopTest();
    	}
       
       system.assertEquals(testString, 'Comatrol');
    }
    
    private static void createTestData(){
	    Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
	    UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
	    adminUser = Test_Utility.createUser(profile.Id,roles.Id, 1);
	    insert adminUser;
	    List<Group> grpList =[Select g.Id From Group g where Name = '*Danfoss Power Solutions'];
	    system.assertEquals(grpList.size(), 1);
	    //Assign user to intergrated group to provide access on account record
	    GroupMember groupMember = new GroupMember(UserOrGroupId = adminUser.Id,GroupId = grpList.get(0).Id);
	    insert groupMember;
      
		system.runAs(adminUser) {    	
			Profile delegatedAdminProfile = [Select Name,Id From Profile p Where Name = 'PartnerLink - Delegated Admin' Limit 1];
			Account account = Test_Utility.createAccount(1);
			//account.Region__c = 'China';
			insert account;
			Contact contact = Test_Utility.createContact(account.id, 1);
			//contact.Email = 'athakur@appirio.com';
			insert contact; 
			testUser = Test_Utility.createPortalUser(contact.id, delegatedAdminProfile.id); 
			testUser.Business_Org__c = 'Integrated';
			insert testUser;
			
			
			RecordType bannerRecordType =  [select Id FROM RecordType WHERE Name='Top Banner'];
			PortalBanner__c testBanner = test_Utility.createPortalBanner(false, 'Left');
			testBanner.RecordTypeId = bannerRecordType.Id;
			testBanner.Region__c = 'default';
			testBanner.Page__c = 'MarketingToolbox';
			testBanner.Business_Org__c = 'Integrated';
			insert testBanner;
			Attachment testAttachment = test_utility.createAttachment(testBanner.Id, true);
		}
    }
}