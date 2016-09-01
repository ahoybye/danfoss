/**************************************************************************************
Class 			: Disable_portal_user 
Developed by 	: Shailendra Singh(Appirio Offshore)
Created Date 	: 04 Aug 2012
Related Task	: T-67673
Description		: Trigger Contact active approval process. 

Last Modified By : Shailendra Singh(Appirio Offshore)
Last Modifed Date: 27/08/2012
Purpose			 : Based on Parameter set diffent Message in approval request comments.
Related Task 	 : T-77691
****************************************************************************************/
public without sharing class Disable_portal_user {

	Contact contact;
	
	public Boolean isSubmitted{get;set;}
		
	
	public Disable_portal_user(ApexPages.StandardController controller){
		isSubmitted = false;
		contact = (Contact)controller.getRecord();
	}
	
	public void triggerApproval(){
		List<ProcessInstance> processList = [Select p.TargetObjectId, p.Status, p.Id,CreatedByID From ProcessInstance p Where TargetObjectId = :contact.id AND Status = 'Pending' limit 1];
		if(!processList.isEmpty()){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Approval request is already in process.'));
		}else{
		   // Trigger Approval process
			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			//req.setComments('Submitted for approval. Please approve.');
			req.setObjectId(contact.id);
			if(ApexPages.currentPage().getParameters().get('op') == '1'){
				req.setComments('Please disable this user.');
			}else{
				req.setComments('Please enable this user.');								
			}
			// submit the approval request for processing
			Approval.ProcessResult result = Approval.process(req);
			// display if the reqeust was successful
			System.debug('Submitted for approval successfully: '+result.isSuccess());
			isSubmitted = result.isSuccess();
		}	
	}
}