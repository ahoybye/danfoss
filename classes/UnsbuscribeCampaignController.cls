/*********************************************************
* Author        :  Shailendra Singh (Appirio Offshore)
* Name          :  UnsbuscribeCampaignController
* Date			:  12/08/2012
* Related Task  :  T-69051
* Description   :  Unsubscribe option for Campaign Members.
**********************************************************/
public without sharing class UnsbuscribeCampaignController {
	Contact contact;
	EmailTemplate template;
	String sfdc_baseurl;
	
	public UnsbuscribeCampaignController(){
		String contactID = System.currentPageReference().getParameters().get('ID');
		if(contactID != null){
			contact = [Select ID,Name,FirstName,LastName,Account.Name from Contact where ID =:contactID];
		}
		System.debug('Templates =>'+[Select Subject,Id,body,Name From EmailTemplate e limit 1]);
		template = [Select Subject,Id,body,Name From EmailTemplate e Where DeveloperName = :System.currentPageReference().getParameters().get('templateName')];
		Org_Base_URL__c baseurlSetting = Org_Base_URL__c.getValues('Base URL');
		sfdc_baseurl = baseurlSetting.Base_URL__c;
		
	}
	
	public void sendEmail(){
		Set<ID> userIds = new Set<ID>();
		EmailTemplate msgTemplate = [Select Subject,Id,htmlValue,body From EmailTemplate e Where DeveloperName = 'Marketing_Opt_In_Out'];
		String body = msgTemplate.htmlValue;
		Group grp = [Select ID From Group where Name  = '*PS Mktg Opt In/Out Admin' Limit 1];
		// Send Email Alerts
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		for(GroupMember member : [Select UserOrGroupId,Id,GroupId From GroupMember Where GroupId = :grp.id]){
			userIds.add(member.UserOrGroupId);
		}
		for(User member : [Select ID,Email From User Where ID IN :userIds]){
			System.debug('Email Sending to '+member);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String email = '';
            email = member.email;
            if(contact.FirstName == null){
            	contact.FirstName = '';
            }
            String templateBbody = body.replace('{!Contact.Name}',contact.Name).replace('{!Contact.FirstName}',contact.FirstName).replace('{!Contact.Link}',sfdc_baseurl+ '/' +contact.Id);
            templateBbody = templateBbody.replace('{!Contact.LastName}',contact.LastName);
            templateBbody = templateBbody.replace('{template.Name}',template.Name);
            templateBbody = templateBbody.replace(']]>','');// unused character
            if(contact.Account.Name != null){
            	templateBbody = templateBbody.replace('{!Account.Name}',contact.Account.Name);
            }else{
            	templateBbody = templateBbody.replace('{!Account.Name}','');
            }
         	templateBbody = templateBbody.replace('http:','https:');
            mail.setSubject(template.subject.replace('{!Contact.Name}',contact.Name));
            mail.setHtmlBody(templateBbody);
            mail.setToAddresses(new String[] {email});
            mail.setSaveAsActivity(false);
            emails.add(mail);									
		}
		if(!emails.isEmpty()){
			Messaging.sendEmail(emails,false);
		}
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Unsubscribe request has been accepted.'));		
	}
}