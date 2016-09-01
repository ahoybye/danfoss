/*************************************************************************************************************
* @author Ankit (Appirio Ind.)
* @date 7 Dec,2013
* @description This class is used for verify all functionality of PartnerPortalHomeComponentCtrl class.
*************************************************************************************************************/
@isTest
public with sharing class Test_PartnerPortalHomeComponentCtrl {
    private static Id panelRecordTypeId = Schema.SObjectType.PortalBanner__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
    static User adminUser;
    static User portalUser;
    static User comatrolUser;
    
    /***********************************************************************************************************
    /* Test method for testPortalBannerForPortalUser
    ***********************************************************************************************************/    
    static testMethod void testPortalBannerForPortalUser() { 
        createUsers();
        PortalBanner__c objPortalBanner;
        PartnerPortalHomeComponentCtrl ctrl;
		Portal_Business_Org_Style__c pobu;
        Test.setCurrentPage(Page.InformationHub);
        //#1 No Match is found neither user's region nor default region (Error condition)
        system.runAs(portalUser) {
            ctrl = new PartnerPortalHomeComponentCtrl();
            ctrl.pos = 'Top Right';
            System.assertEquals(null, ctrl.portalBanner);
            System.assertNotEquals(null, ctrl.errorMsg);
        }
        
        //#2 Match is found with user's region (No error condition)
        system.runAs(adminUser){
        	objPortalBanner = new PortalBanner__c(Page__c = 'InformationHub', Position__c = 'Top Right', Business_Org__c = 'Integrated', Region__c = 'USA', Component_Type__c = 'Announcement', 
        						Content_Type_to_Query__c = 'TestContent1;TestContent2', Object__c = 'Idea', RecordTypeId = panelRecordTypeId);
            insert objPortalBanner;
			pobu = new Portal_Business_Org_Style__c(Name='PartnerLink Home Page', NumberOfItems__c = 7, Business_Org__c = 'Integrated', Terms_and_Conditions_Visualforce_Page__c='test');
			insert pobu;			
        }
        system.runAs(portalUser) {
            ctrl = new PartnerPortalHomeComponentCtrl();
            ctrl.pos = 'Top Right';
            System.assertEquals(objPortalBanner.Id, ctrl.portalBanner.Id);
            System.assertEquals(true, ctrl.errorMsg == null);
            System.assertEquals(0, ctrl.getContentList().size());
            System.assertEquals(0, ctrl.getIdeaList().size());
            System.assertEquals(true, ctrl.ContentFilterString != null);
        }
        
        //#3 Match is found with Default region (No error condition)
        system.runAs(adminUser){
        	objPortalBanner.Region__c = 'Default';
        	update objPortalBanner; 
        }
        system.runAs(portalUser) {
            ctrl = new PartnerPortalHomeComponentCtrl();
            ctrl.pos = 'Top Right';
            System.assertEquals(objPortalBanner.Id, ctrl.portalBanner.Id);
            System.assertEquals(true, ctrl.errorMsg == null);
        }
        
        //#4 Match is found with Default region for other panel records displayed on page to with matching component type (Error condition)
        system.runAs(adminUser){
        	objPortalBanner = new PortalBanner__c(Page__c = 'InformationHub', Position__c = 'Top Left', Business_Org__c = 'Integrated', Region__c = 'USA', Component_Type__c = 'Announcement', 
        						Content_Type_to_Query__c = 'TestContent1;TestContent2', Object__c = 'Idea', RecordTypeId = panelRecordTypeId);
        	insert objPortalBanner; 
        }
        system.runAs(portalUser) {
            ctrl = new PartnerPortalHomeComponentCtrl();
            ctrl.pos = 'Top Right';
            System.assertEquals(null, ctrl.portalBanner);
            System.assertNotEquals(null, ctrl.errorMsg);
        }
    }
    
    /***********************************************************************************************************
    /* Test method for testPortalBannerForComatrolUser
    ***********************************************************************************************************/
    static testMethod void testPortalBannerForComatrolUser() { 
        createUsers();
        PortalBanner__c objPortalBanner;
        PartnerPortalHomeComponentCtrl ctrl;
		Portal_Business_Org_Style__c pobu;
        Test.setCurrentPage(Page.InformationHub);
        
        //#1 No Match is found neither user's region nor default region (Error condition)
        system.runAs(comatrolUser) {
            ctrl = new PartnerPortalHomeComponentCtrl();
            ctrl.pos = 'Top Right';
            System.assertEquals(null, ctrl.portalBanner);
            System.assertNotEquals(null, ctrl.errorMsg);
        }
        
        //#2 Match is found with user's region (No error condition)
        system.runAs(adminUser){
        	objPortalBanner = new PortalBanner__c(Page__c = 'InformationHub', Position__c = 'Top Right', Business_Org__c = 'Integrated', Region__c = 'USA', Component_Type__c = 'Announcement', 
        						Content_Type_to_Query__c = 'TestContent1;TestContent2', Object__c = 'Idea', RecordTypeId = panelRecordTypeId);
            insert objPortalBanner;
			pobu = new Portal_Business_Org_Style__c(Name='PartnerLink Home Page', NumberOfItems__c = 7, Business_Org__c = 'Integrated', Terms_and_Conditions_Visualforce_Page__c='test');
			insert pobu;
        }
        system.runAs(comatrolUser) {
            ctrl = new PartnerPortalHomeComponentCtrl();
            ctrl.pos = 'Top Right';
            System.assertEquals(objPortalBanner.Id, ctrl.portalBanner.Id);
            System.assertEquals(true, ctrl.errorMsg == null);
            System.assertEquals(0, ctrl.getContentList().size());
            System.assertEquals(0, ctrl.getIdeaList().size());
            System.assertEquals(true, ctrl.ContentFilterString != null);
        }
        
        //#3 Match is found with Default region (No error condition)
        system.runAs(adminUser){
        	objPortalBanner.Region__c = 'Default';
        	update objPortalBanner; 
        }
        system.runAs(comatrolUser) {
            ctrl = new PartnerPortalHomeComponentCtrl();
            ctrl.pos = 'Top Right';
            System.assertEquals(objPortalBanner.Id, ctrl.portalBanner.Id);
            System.assertEquals(true, ctrl.errorMsg == null);
        }
        
        //#4 Match is found with Default region for other panel records displayed on page with matching component type (Error condition)
        system.runAs(adminUser){
        	objPortalBanner = new PortalBanner__c(Page__c = 'InformationHub', Position__c = 'Top Left', Business_Org__c = 'Integrated', Region__c = 'USA', Component_Type__c = 'Announcement', 
        						Content_Type_to_Query__c = 'TestContent1;TestContent2', Object__c = 'Idea', RecordTypeId = panelRecordTypeId);
        	insert objPortalBanner; 
        }
        system.runAs(comatrolUser) {
            ctrl = new PartnerPortalHomeComponentCtrl();
            ctrl.pos = 'Top Right';
            System.assertEquals(null, ctrl.portalBanner);
            System.assertNotEquals(null, ctrl.errorMsg);
        }
    }
    
    /***********************************************************************************************************
    /* Methos For Create Test users
    ***********************************************************************************************************/
    private static void createUsers() {
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
		    Region__c region = new Region__c(Name='USA', Country_Code__c='16', Region__c = 'USA');
		    insert region;
		    Account account = new Account(Name='Test Account Name', Business_Org__c='Integrated', Country__c = region.Id);
		    insert account;
		    //Create portal user
		    Contact contactPortal = Test_Utility.createContact(account.Id,1);
		    insert contactPortal;
		    List<Profile> userProfiles = [Select id from Profile where Name IN ('PartnerLink - Full') limit 1];
		    system.assertEquals(userProfiles.size(), 1);
		    portalUser = Test_Utility.createPortalUser(contactPortal.Id, userProfiles.get(0).Id);
		    insert portalUser;
		    //Provide access on account record by assigning portal user to intergrated group
		    GroupMember  grpMember = new GroupMember(UserOrGroupId = portalUser.Id,GroupId = grpList.get(0).Id);
		    insert grpMember;
		    
		    //Create comatrol user
		    Contact contactComatrol = Test_Utility.createContact(account.Id,2);
		    insert contactComatrol;
		    userProfiles = [Select id from Profile where Name IN ('MyComatrol - Full') limit 1];
		    system.assertEquals(userProfiles.size(), 1);
		    comatrolUser = Test_Utility.createPortalUser(contactComatrol.Id, userProfiles.get(0).Id);
		    insert comatrolUser;
		    //Provide access on account record by assigning comatrol user to intergrated group
		    grpMember = new GroupMember(UserOrGroupId = comatrolUser.Id,GroupId = grpList.get(0).Id);
		    insert grpMember;
		}
    }
}