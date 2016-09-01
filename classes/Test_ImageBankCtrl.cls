/**********************************************************
Name            : Test_ImageBankCtrl
Description     : Test Class for Image Bank Controller
Created By      : Arvind Thakur
Date            : 24rd Dec, 2014
Task            : T-346183
***********************************************************/
@isTest
private class Test_ImageBankCtrl {
    
    static User adminUser;
    static User testUser;
    
    static testMethod void myUnitTest() {
        createTestData();
        system.runAs(testUser){
            Test.startTest();
                ImageBankCtrl controller = new ImageBankCtrl();
                List<String> productList = controller.productSelectList;
                controller.attachment = Blob.valueOf('Test Data');
                controller.contentType = 'text/plain';
                controller.filename = 'Test File.txt';
                controller.generateCase();
                controller.submit();
            Test.stopTest();
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
			//contact.Email = 'a@a.com';
			insert contact; 
			testUser = Test_Utility.createPortalUser(contact.id, delegatedAdminProfile.id);  
			insert testUser;
			Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName = 'All_PS_Users_w_Portal' LIMIT 1];
			GroupMember groupMem = new GroupMember();
			groupMem.GroupId = publicGroup.Id;
			groupMem.UserOrGroupId = testUser.Id;
			insert groupMem;

			RecordType ContentRTImage = [SELECT Id FROM RecordType WHERE Name = 'Product Image'];
			ContentVersion testVersionImage = new ContentVersion(); 
			testVersionImage.ContentURL='http://www.google.com/'; 
			testVersionImage.Description = 'testing Content version';
			testVersionImage.Title ='Google.com';
			testVersionImage.RecordTypeId = ContentRTImage.Id; 
			insert testVersionImage;

			RecordType ContentRTGraphic = [SELECT Id FROM RecordType WHERE Name = 'Product Graphic'];
			ContentVersion testVersionGraphic = new ContentVersion(); 
			testVersionGraphic.ContentURL='http://www.google.com/'; 
			testVersionGraphic.Description = 'testing Content version';
			testVersionGraphic.Title ='Google.com';
			testVersionGraphic.RecordTypeId = ContentRTGraphic.Id; 
			insert testVersionGraphic;

			ContentVersion testContentImage = [SELECT ContentDocumentId FROM ContentVersion where Id = :testVersionImage.Id]; 
			ContentVersion testContentGraphic = [SELECT ContentDocumentId FROM ContentVersion where Id = :testVersionGraphic.Id]; 

			ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = '*PS Public Content']; 

			ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc(); 
			newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id; 
			newWorkspaceDoc.ContentDocumentId = testContentImage.ContentDocumentId; 
			insert newWorkspaceDoc;
			
			newWorkspaceDoc = new ContentWorkspaceDoc(); 
			newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id; 
			newWorkspaceDoc.ContentDocumentId = testContentGraphic.ContentDocumentId; 
			insert newWorkspaceDoc;
		}
    }
}