/*
Class : MarketingOptEmailServiceHandler 
Description :  T-69051 , this class is a email service handler, it triggers Email Notification to public group: Marketing Opt In/Out Admin.  Subject of emails will include "REMOVE".
Developed by : Manmeet Manethiya
Created Date : Aug 8, 2012
*/

global class MarketingOptEmailServiceHandler implements Messaging.InboundEmailHandler {
	  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		  Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		  Contact contactToBeUpdated;
		  if(email.subject.contains('REMOVE')){
		  	for(Contact contact :[select id from Contact where email = :email.fromAddress limit 1]){
		  	contactToBeUpdated = contact;
		  	}
		  update new Contact(id = contactToBeUpdated.id, Send_Notification__c = true);
		  }
		  return result;
      }
}