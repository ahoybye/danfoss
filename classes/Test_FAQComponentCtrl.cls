/*
**************************************************************************************
Name            : Test_FAQComponentCtrl
Author          : Matt Salpietro (Modified By Arvind)
Ceated Date     : 16 December 2014 
Description     : Test class for FAQComponentCtrl
***************************************************************************************    
*/
@isTest 
private class Test_FAQComponentCtrl {
    static User adminUser;
  static User testUser;
  static User portalUser;
  static Account account;

  static testMethod void testFAQ() {
    createUsers();
	system.runAs(adminUser) {
		List<Question__c> questionList = Test_Utility.createQuestions(New Set<String>{'Default'}, 10);
	}
    System.runAs(portalUser) {
      Test.startTest();
      FAQComponentCtrl controller = New FAQComponentCtrl();
      system.assertEquals(10, controller.lstQues.size()); 
      Test.stopTest();
    }
  }

  static testMethod void testClickTrack() {
    createUsers();
    System.runAs(portalUser) {
      List<Question__c> questionList = Test_Utility.createQuestions(New Set<String>{'Default'}, 10);
	  Test.startTest();
      FAQComponentCtrl.trackClicks(questionList[0].Id);
      Question__c testQuestion = [SELECT ViewCount__c FROM Question__c WHERE Id = :questionList[0].Id];
      system.assertEquals(1, testQuestion.ViewCount__c);
      FAQComponentCtrl.trackClicks(questionList[0].Id);
      testQuestion = [SELECT ViewCount__c FROM Question__c WHERE Id = :questionList[0].Id];
      system.assertEquals(2, testQuestion.ViewCount__c);
      Test.stopTest();
    }
  }
  
  static testMethod void testCreateNewTask(){
    createUsers();
    System.runAs(portalUser){
        Test.startTest();
        FAQComponentCtrl controller = New FAQComponentCtrl();
        controller.createNewCase(); 
        controller.newQuestion = 'Testing';   
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
    GroupMember groupMember = new GroupMember(UserOrGroupId = adminUser.Id,GroupId = grpList.get(0).Id);
    insert groupMember;
  
	system.runAs(adminUser) {
		account = Test_Utility.createAccount(1);
		insert account;
		Contact contactPortal = Test_Utility.createContact(account.Id,2);
		insert contactPortal;
		List<Profile> portalUserProfiles = [Select id from Profile where Name IN ('PartnerLink - Full') limit 1];
		portalUser = Test_Utility.createPortalUser(contactPortal.Id, portalUserProfiles.get(0).Id);
		insert portalUser;
		GroupMember  grpMember = new GroupMember(UserOrGroupId = portalUser.Id,GroupId = grpList.get(0).Id);
		insert grpMember;
	}
  }
}