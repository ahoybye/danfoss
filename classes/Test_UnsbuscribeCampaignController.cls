/*******************************************************************
* Author        :  Harshit Jain (Appirio Offshore)
* Name          :  UnsbuscribeCampaignController
* Date          :  September 3,2012
* Description   :  Verify functionality of UnsbuscribeCampaignController class.                 
*******************************************************************/
@isTest 
private class Test_UnsbuscribeCampaignController {
    static User adminUser;
    static Contact contact;
    static Account account;
    static EmailTemplate emailTemplate;
    static EmailTemplate emailTemplateUsedForUnsbuscribtion;
        
    static testMethod void testSendEmailFunctionality() {
         List<Folder> folders =  [select id from folder where IsReadOnly = false AND AccessType = 'Public' AND Type = 'Email' limit 1];
         system.assertNotEquals(folders.get(0).Id, null);
         emailTemplate = new EmailTemplate(Name = 'Test template', DeveloperName = 'Test_template', FolderId = folders.get(0).Id, TemplateType = 'text', Subject = '{!Contact.Name}');
         insert emailTemplate;
         Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
         UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
         adminUser = Test_Utility.createUser(profile.Id,roles.Id, 1);
         insert adminUser;
         Group grp = [Select ID From Group where Name  = '*PS Mktg Opt In/Out Admin' Limit 1];
         GroupMember member = new GroupMember(UserOrGroupId = adminUser.Id, GroupId = grp.Id); 
         insert member;
         //Login as other admin user to create setup and non setup object in different context
         system.runAs(adminUser) {
        account = Test_Utility.createAccount(1);
            insert account; 
            contact = Test_Utility.createContact(account.Id, 1);
        insert contact;
        Org_Base_URL__c baseUrl = new Org_Base_URL__c(Name = 'Base URL', Base_URL__c = 'https://sd--portaldev.cs14.my.salesforce.com');
        insert baseUrl;
         }
       Test.startTest();
       PageReference pageRef = Page.UnsbuscribeCampaign;
       Test.setCurrentPageReference(pageRef);
       ApexPages.currentPage().getParameters().put('Id', contact.Id);
       ApexPages.currentPage().getParameters().put('templateName', 'Test_template');
       UnsbuscribeCampaignController unsbuscribeCampaignController = new UnsbuscribeCampaignController();
       unsbuscribeCampaignController.sendEmail();
       Test.stopTest();
    }
}