/*************************************************************************
Name                : Test_ToolsController
Author              : Diana Losey
CreatedDate         : Jan 4 2016
Description         : This is a test class for ToolsController
*************************************************************************/
@isTest
private class Test_ToolsController {

    static User adminUser;
    static User testUser;

	@isTest static void testToolsPage() {
		createTestData();
        //String testString;
        system.runAs(testUser){
             test.startTest();
             ToolsController controller = new ToolsController();

             test.stopTest();
        }

       //system.assertEquals(testString, 'Comatrol');
    }

    private static void createTestData(){
        Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
        UserRole roles = [Select id from UserRole where Name = 'CRM_SysAdmin PS' limit 1];
        adminUser = Test_Utility.createUser(profile.Id,roles.Id, 1);
        insert adminUser;
        //List<Group> grpList =[Select g.Id From Group g where Name = '*Danfoss Power Solutions'];
        //system.assertEquals(grpList.size(), 1);
        //Assign user to intergrated group to provide access on account record
        //GroupMember groupMember = new GroupMember(UserOrGroupId = adminUser.Id,GroupId = grpList.get(0).Id);
        //insert groupMember;

        system.runAs(adminUser) {
            Profile delegatedAdminProfile = [Select Name,Id From Profile p Where Name = 'PartnerLink - Delegated Admin' Limit 1];
            Account account = Test_Utility.createAccount(1);
            insert account;
            Contact contact = Test_Utility.createContact(account.id, 1);
            insert contact;
            testUser = Test_Utility.createPortalUser(contact.id, delegatedAdminProfile.id);
            testUser.Business_Org__c = 'Integrated';
            insert testUser;


            RecordType bannerRecordType =  [select Id FROM RecordType WHERE Name='Tools' AND sObjectType = 'PortalBanner__c'];
            PortalBanner__c testBanner = test_Utility.createPortalBanner(false, 'Left');
            testBanner.RecordTypeId = bannerRecordType.Id;
            testBanner.Region__c = 'default';
            testBanner.Page__c = 'Tools';
            testBanner.Business_Org__c = 'Integrated';
            testBanner.Content_Type_to_Query__c = 'Tools';
            insert testBanner;

            RecordType ContentRT = [select Id FROM RecordType WHERE Name='Tools' AND sObjectType = 'ContentVersion'];
            ContentVersion testContentInsert =new ContentVersion();
            testContentInsert.ContentURL='www.google.com';
            testContentInsert.Title ='Google.com';
            testContentInsert.RecordTypeId = ContentRT.Id;
            insert testContentInsert;

            ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id];

            ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name='*PS Public Content'];
            ContentWorkspaceDoc newWorkspaceDoc =new ContentWorkspaceDoc();
            newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id;
            newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId;
            insert newWorkspaceDoc;

            Expert_Tools__c et = new Expert_Tools__c(Name = 'Test', Category__c = 'Pricing Tools', Description__c = 'Test, test, test');
            insert et;

            testContent.Expert_Tool__c = et.Id;
            testContent.Content_Type__c = 'Tools';
            testContent.Region__c = 'Americas';
            update testContent;

            Attachment testAttachment = test_utility.createAttachment(et.Id, true);
        }
    }

}