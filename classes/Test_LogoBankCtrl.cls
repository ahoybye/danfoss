/**********************************************************
Name            : Test_LogoBankController
Description     : Test Class for Logo Bank Controller
Created By      : Arvind Thakur
Date            : 24rd Dec, 2014
Task            : T-346183
***********************************************************/


@isTest 
private class Test_LogoBankCtrl {
    static User adminUser;
    static User testUser;
    static ContentVersion testVersion;
    
    static testMethod void testLogoBankController() {
        createTestData();
        system.runAs(testUser){
            test.startTest();          
                LogoBankCtrl controller = new LogoBankCtrl();
                controller.attachment = Blob.valueOf('Test Data');
                controller.contentType = 'text/plain';
                controller.filename = 'Test File.txt';
                controller.generateCase();
            test.stopTest();
        }
    }
    
    private static void createTestData(){        
	    Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
	    UserRole roles = [Select id from UserRole where Name = 'CRM_SysAdmin PS' limit 1];
	    adminUser = Test_Utility.createUser(profile.Id,roles.Id, 1);
	    insert adminUser;
	    List<Group> grpList =[Select g.Id From Group g where Name = '*Danfoss Power Solutions'];
	    system.assertEquals(grpList.size(), 1);
	    //Assign user to intergrated group to provide access on account record
	    GroupMember groupMember = new GroupMember(UserOrGroupId = adminUser.Id,GroupId = grpList.get(0).Id);
	    insert groupMember;
      
		system.runAs(adminUser) {
			Profile delegatedAdminProfile = [Select Name,Id From Profile p Where Name = 'PartnerLink - Full' Limit 1];
			Account account = Test_Utility.createAccount(1);
			insert account;
			Contact contact = Test_Utility.createContact(account.id, 1);
			insert contact; 
			testUser = Test_Utility.createPortalUser(contact.id, delegatedAdminProfile.id);  
			insert testUser;

			Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName = 'All_PS_Users_w_Portal' LIMIT 1];
			GroupMember groupMem = new GroupMember();
			groupMem.GroupId = publicGroup.Id;
			groupMem.UserOrGroupId = testUser.Id;
			insert groupMem;

			RecordType ContentRT = [SELECT Id FROM RecordType WHERE Name = 'Logo'];

			testVersion = new ContentVersion(); 
			testVersion.ContentURL='http://www.google.com/'; 
			testVersion.Description = 'testing Content version';
			testVersion.Title ='Google.com';
			testVersion.RecordTypeId = ContentRT.Id; 
			insert testVersion;

			ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testVersion.Id]; 

			ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = '*PS Public Content']; 

			ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc(); 
			newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id; 
			newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId; 
			insert newWorkspaceDoc; 
		}
    }
}