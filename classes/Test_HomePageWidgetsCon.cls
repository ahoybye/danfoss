/*
**************************************************************************************
Name                : TestHomePageWidgetsCon
Author              : Harshit Jain (Appirio offshore)
createdDate                 : 17 august,2012    
Description         : This class is used for verify all functionality of TestHomePageWidgetsCon class.
***************************************************************************************    
*/
@isTest
private class Test_HomePageWidgetsCon {
	static User adminUser;
    static testMethod void myUnitTest() {
            createTestData();                 
            Test.startTest();            
            HomePageWidgetsCon homePageWidgetsCon = new HomePageWidgetsCon();
        	homePageWidgetsCon.getPricingWidgetsList();
        	homePageWidgetsCon.getTechnicalLiteratureWidgetsList();
            homePageWidgetsCon.ContentType = 'Announcement';            
            homePageWidgetsCon.getContentFilterString();
            
            homePageWidgetsCon.ContentType = 'Technical Literature';
            homePageWidgetsCon.getContentFilterString();
            
            homePageWidgetsCon.ContentType = 'Service Bulletin';                        
            homePageWidgetsCon.getContentFilterString();
            
            homePageWidgetsCon.ContentType = 'Product Information Bulletin';
            homePageWidgetsCon.getContentFilterString();
        
            homePageWidgetsCon.ContentType = 'Pricing';
            homePageWidgetsCon.getContentFilterString();
            Test.stopTest();   
    }
    
    private static void createTestData() {
          
	    Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
	    UserRole roles = [Select id from UserRole where Name = 'CRM_SysAdmin PS' limit 1];
	    adminUser = Test_Utility.createUser(profile.Id,roles.Id, 1);
	    insert adminUser;
		system.runAs(adminUser) {
			ContentWorkspace workspace = [SELECT Id FROM ContentWorkspace WHERE Name = '*PS Public Content'];
			if (workspace != null) {
			Schema.DescribeSObjectResult d = Schema.SObjectType.ContentVersion;
			Map <String , Schema.RecordTypeInfo >rtMapByName = d.getRecordTypeInfosByName();
			Schema.RecordTypeInfo rtByName = rtMapByName.get('Announcement');
			ContentVersion content = new ContentVersion();
			content.RecordTypeId = rtByName.getRecordTypeId();
			content.FirstPublishLocationId = workspace.Id;
			content.pathOnClient = 'test1.xml';
			content.VersionData = Blob.valueOf('Hello');  
			insert content;
			}
		}
    }
}