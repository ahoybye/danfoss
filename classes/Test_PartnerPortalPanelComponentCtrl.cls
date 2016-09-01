/**************************************************************************
Name            : Test_PartnerPortalPanelComponentCtrl
Description     : Test Class for PartnerPortalPanelComponentCtrl
Created By      : Arvind Thakur
Date            : 24rd Dec, 2014
Task            : T-346183
***************************************************************************/
@isTest
private class Test_PartnerPortalPanelComponentCtrl {
    
    static User adminUser;
    static User testUser;
    static PortalBanner__c testBanner;
    
    static testMethod void testPartnerPortalPanelComponentCtrl() {
    	createTestData();    	
    	system.runAs(testUser){
    		test.startTest();
    		PartnerPortalPanelComponentCtrl testPortal = new PartnerPortalPanelComponentCtrl();
    		testPortal.pos = 'Left';
            PortalBanner__c getBanner = testPortal.portalBanner;
            system.assertEquals(getBanner.Id , testBanner.Id);            
            List<PortalBannerLink__c> portalList = testPortal.getPortalLInks();
            system.assert(portalList.size() > 0);
            test.stopTest();
    	}        
       
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
			insert account;
			Contact contact = Test_Utility.createContact(account.id, 1);
			//contact.Email = 'athakur@appirio.com';
			insert contact; 
			testUser = Test_Utility.createPortalUser(contact.id, delegatedAdminProfile.id); 
			testUser.Business_Org__c = 'Integrated';
			insert testUser;
			
			
			RecordType bannerRecordType =  [select Id FROM RecordType WHERE Name='Marketing Panel'];
			testBanner = test_Utility.createPortalBanner(false, 'Left');
			testBanner.RecordTypeId = bannerRecordType.Id;
			testBanner.Region__c = 'default';
			testBanner.Page__c = 'MarketingToolbox';
			testBanner.Business_Org__c = 'Integrated';
			insert testBanner;
			
			Attachment testAttachment = test_utility.createAttachment(testBanner.Id, true);
			
			PortalBannerLink__c bannerLink = new PortalBannerLink__c();
			bannerLink.Target__c = 'Self';
			bannerLink.Type__c = 'External';
			bannerLink.URL__c = 'https://www.google.co.in';
			bannerLink.PortalBanner__c = testBanner.Id;
			insert bannerLink;
		}
    }
}