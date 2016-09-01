/*
* @author Neeraj (Appirio Ind.)
* @date 12/09/2013
* @Task T-213767, I-85267
* @description  Actions required on Bulletin Delivery Job DML Operations.
*/
trigger BulletinDeliveryJobTrigger on Bulletin_Delivery_Job__c (before insert, before update) {
  if (Trigger.isBefore) {
	  if (Trigger.isInsert) {
	  	BulletinDeliveryJobTriggerHandler.beforeInsert(Trigger.New);
	  }
	  if (Trigger.isUpdate) {
      BulletinDeliveryJobTriggerHandler.beforeUpdate(Trigger.New, trigger.oldMap);
    }
  } 
}