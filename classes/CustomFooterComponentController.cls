/*
Class : CustomFooterComponentController 
Description :  This class is used for entering user info into Content Viewer object when user sees a content.
Created By	:	Manmeet Manethiya
Modified by : Manmeet Manethiya
Modified Date : Aug 3, 2012
*/
public with sharing class CustomFooterComponentController {
	
		private String documentId;
		private User user;
		//constructor
		public CustomFooterComponentController(){
			if(ApexPages.currentPage().getParameters().get('documentId') != null){
				documentId = ApexPages.currentPage().getParameters().get('documentId');
			}
		}
		//inserting Content_Viewer__c record
		public Pagereference insertContentViewerInfo(){
			if(isPartnerUser()){
				ContentWorkspaceDoc ctWorkSpace = new ContentWorkspaceDoc();
				for(ContentWorkspaceDoc obj : [Select c.SystemModstamp, c.IsOwner, c.IsDeleted, c.Id, c.CreatedDate, c.ContentWorkspace.name,
				 															c.ContentDocumentId, ContentDocument.title From ContentWorkspaceDoc c where c.ContentDocumentId =: documentId order by id asc limit 1]){
				 		ctWorkSpace = obj;
				 }
				 string Content_Version_Id = '';
				 for(ContentVersion verObj : [Select Id, versionnumber From ContentVersion where ContentDocumentId=:documentId order by versionnumber desc limit 1]){
				 	Content_Version_Id= verObj.id+'';
				 }
				 system.debug('***********Content_Version_Id:'+Content_Version_Id+', '+documentId);
				 Content_Viewer__c insertCnt= new Content_Viewer__c(name = UserInfo.getFirstName() + ' ' + UserInfo.getLastName(), User__c = UserInfo.getUserId(), 
																		Content_Id__c = ctWorkSpace.ContentDocumentId,
																		Content_Library__c = ctWorkSpace.ContentWorkspace.name,
																		Content_Title__c = ctWorkSpace.ContentDocument.title,
																		contact__c = user.contactID,
																		Content_Version_Id__c= Content_Version_Id);
				insert insertCnt;	
				system.debug('***********Content_Version_Id:'+Content_Version_Id+', '+documentId);
			} 
			return null; 
		}
		//checking whether the user is partner or not
		public boolean isPartnerUser(){
			user = new User();
			for(User usr : [select name, firstname, lastname, id , contactID from User where id  = : UserInfo.getUserId()]){
				user = usr;
			}
			return user.contactID != null ? true : false;
		}
}