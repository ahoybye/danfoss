/*************************************************************************************************************
Name                : Test_PartnerPortalHomeCtrl
Author              : Ankit Goyal (Appirio offshore)
createdDate         : 7 Dec,2013    
Description         : This class is used for verify all functionality of PartnerPortalHomeCtrl class.
*************************************************************************************************************/
@isTest
private class Test_PartnerPortalHomeCtrl {
  static Account account;
  static Contact contactPortal;
  static User portalUser;
  static User adminUser;
        
  static testMethod void unitTestWithTopBanner() { 
    PortalBanner__c portalBanner;
    List<Idea> ideaList;
    createUsers();
    update PortalUser;
    //Run as admin user to create dummy data(As setup or non setup data conn't be created in one context)
    system.runAs(adminUser){
    ideaList = new List<Idea>();
    for(Community community : [Select c.Id From Community c where IsActive = true limit 1]) {
      for(Integer i=0; i<5; i++) {
          Idea idea = new Idea(Title = 'Test idea'+i, CommunityId = community.Id);
          ideaList.add(idea);
      }       
    }
    if(!ideaList.IsEmpty()) {
      insert ideaList;
    } 
    //Create portal Banner record of TopBanner record Type
    portalBanner = Test_Utility.createPortalBanner(true, 'Middle');
    portalBanner.Business_Org__c = 'Integrated';
    portalBanner.Region__c = 'default';
    update portalBanner;
  // Add test attacment file to portal banner record      
    Attachment attach = new Attachment();     
          attach.Name = 'Unit Test Attachment';
          Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
          attach.body = bodyBlob;
      attach.parentId = portalBanner.id;
      insert attach;        
    }
    //login as portal user
    //verify that controller fetch latest 3 ideas
    //verify portalBanner is fetched against the region of portal user account  
    System.runAs(portalUser) {
      Test.startTest();
      PartnerPortalHomeCtrl portalHomePageCon = new PartnerPortalHomeCtrl();
      system.assertNotEquals(portalHomePageCon.loginUser, null);
      portalBanner.Position__c = 'Right';
      update portalBanner;
      portalHomePageCon = new PartnerPortalHomeCtrl();
      portalBanner.Position__c = 'Left';
      update portalBanner;
      portalHomePageCon = new PartnerPortalHomeCtrl();
      system.assertNotEquals(portalHomePageCon.marCommLeft, null); 
      Test.stopTest();
    }
  }
    
  static testMethod void unitTestWithSpotsBanner() { 
    PortalBanner__c portalBanner;
    createUsers();
    //Run as admin user to create dummy data(As setup or non setup data cann't be created in one context)     
    system.runAs(adminUser){
      Map<String,Schema.RecordTypeInfo> recordType = Schema.SObjectType.PortalBanner__c.getRecordTypeInfosByName();
      //Create portal Banner record of sports record type
      portalBanner = Test_Utility.createPortalBanner(false, 'Middle');
      portalBanner.RecordTypeId = recordType.get('Spots').getRecordTypeId(); 
      insert portalBanner;
      // Add test attacment file to portal banner record      
      Attachment attach = new Attachment();     
      attach.Name = 'Unit Test Attachment';
      Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
      attach.body = bodyBlob;
      attach.parentId = portalBanner.id;
      insert attach;        
    }
    //Login as portal user
    //verify portalBanner is fetched against the region of portal user account    
    System.runAs(portalUser) {
      Test.startTest();
      PartnerPortalHomeCtrl portalHomePageCon = new PartnerPortalHomeCtrl();
      portalBanner.Position__c = 'Right';
      update portalBanner;
      portalHomePageCon = new PartnerPortalHomeCtrl();
      portalBanner.Position__c = 'Left';
      update portalBanner;
      portalHomePageCon = new PartnerPortalHomeCtrl();
      system.assertEquals(portalHomePageCon.portalBanner, null); 
      Test.stopTest();
    }
  }
    
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
      account = new Account(Name='Test Account Name', Business_Org__c='Integrated');//Test_Utility.createAccount(1);
      //Region__c region = new Region__c(Name = 'USA');//[select Id from Region__c where Name = 'USA'];
      Region__c region = new Region__c(
                              Name='USA',
                              Country_Code__c='16',
                              Region__c = 'Test region');
      insert region;
      account.Country__c = region.Id;
      insert account;
      contactPortal = Test_Utility.createContact(account.Id,2);
      insert contactPortal;
      List<Profile> portalUserProfiles = [Select id from Profile where Name IN ('PartnerLink - Full') limit 1];
      system.assertEquals(portalUserProfiles.size(), 1);
      portalUser = Test_Utility.createPortalUser(contactPortal.Id, portalUserProfiles.get(0).Id);
      insert portalUser;
      //Provide access on account record by assigning portal user to intergrated group
      GroupMember  grpMember = new GroupMember(UserOrGroupId = portalUser.Id,GroupId = grpList.get(0).Id);
      insert grpMember;
    }
  }
}