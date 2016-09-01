/*******************************************************************
* Author        :  Harshit Jain (Appirio Offshore)
* Name          :  CustomFooterComponentController_Test
* Date                  :    August 27,2012
* Related Task  :  T-77514
* Description   :  Verify functionality of CustomFooterComponentController class.                 
*******************************************************************/

@isTest
private class Test_CustomFooterComponentController {

    static testMethod void testFooterComponentController() {
            Account account = Test_Utility.createAccount(1);
            insert account;
            //create contact to be used for portal user
            Contact contactPortal = Test_Utility.createContact(account.Id, 2);
            insert contactPortal;
            
            List<Profile> portalUserProfiles = [Select id from Profile where Name IN ('PartnerLink - Full') limit 1];
            system.assertEquals(portalUserProfiles.size(), 1);
            
            User    portalUser = Test_Utility.createPortalUser(contactPortal.Id, portalUserProfiles.get(0).Id);
            insert portalUser;
            
            List<Folder> folders =  [select id from folder where Type = 'Document' AND IsReadOnly = false AND AccessType = 'Public' limit 1];
            system.assertNotEquals(folders.get(0).Id, null);
            
            Document document;
            if(!folders.IsEmpty()) {
                document = new Document();
                document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.FolderId = folders.get(0).Id;
            document.Name = 'My Document';
            insert document;                
            }
            //login as portal user
            //Content_Viewer__c record should be created if document is available in library.  
            system.runAs(portalUser) {
                Test.startTest();
                    PageReference pageRef = Page.CustomFooterComponent;
                    Test.setCurrentPageReference(pageRef);
                    ApexPages.currentPage().getParameters().put('documentId', document.Id);
                    // Instantiate a new controller with all parameters in the page
                    CustomFooterComponentController customFooterComponentController = new CustomFooterComponentController();
                    customFooterComponentController.insertContentViewerInfo();
                    
                    List<Content_Viewer__c> contentViewerList = new List<Content_Viewer__c>(); 
                    for(Content_Viewer__c contenetViewer : [select Id from Content_Viewer__c where Name =:portalUser.FirstName]) {
                        contentViewerList.add(contenetViewer);
                    }
                    system.assertEquals(contentViewerList.size(), 0);
                Test.stopTest();
            }
    }
}