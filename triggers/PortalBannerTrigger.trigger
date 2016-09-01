/*************************************************************************************************************
* @author Ankit (Appirio Ind.)
* @date 12/3/2013
* @Story S-162787
* @description Trigger for PortalBanner DML Operations
*************************************************************************************************************/
trigger PortalBannerTrigger on PortalBanner__c (before update, before insert) {
  if(trigger.isUpdate){
    PortalBannerTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
  } else{
    PortalBannerTriggerHandler.beforeInsert(trigger.new);
  }
}