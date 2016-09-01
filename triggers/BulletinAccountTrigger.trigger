/*************************************************************************************************************
* @author Ankit (Appirio Ind.)
* @date 9 Dec, 2013
* @description Bulletin Account Trigger
*************************************************************************************************************/
trigger BulletinAccountTrigger on Bulletin_Accounts__c (after insert, after update) {
	if(trigger.isUpdate) {
    BulletinAccountTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
	} else {
    BulletinAccountTriggerHandler.afterInsert(trigger.new);
	}
}