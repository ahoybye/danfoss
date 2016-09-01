/*************************************************************************************************************
* @author Ankit (Appirio Ind.)
* @date 12/3/2013
* @Story S-162787
* @description Handler class for PortalBannerTrigger.
*************************************************************************************************************/
public without sharing class PortalBannerTriggerHandler {
    
  public static Map<String,Schema.RecordTypeInfo> recordType = Schema.SObjectType.PortalBanner__c.getRecordTypeInfosByName();
  
  /***********************************************************************************************************
  /* Actions performed before update of Portal Banner
  * @param newList List of Portal Banners
  * @param oldMap Map with old values of Portal Banners
  * @return void.
  ***********************************************************************************************************/
	public static void beforeUpdate(List<PortalBanner__c> newList, Map<Id, PortalBanner__c> oldMap) {
    checkForRecordExist(newList, oldMap);
	}
  
  /***********************************************************************************************************
  /* Actions performed before Insert of Portal Banner
  * @param newList List of Portal Banners
  * @return void.
  ***********************************************************************************************************/
  public static void beforeInsert(List<PortalBanner__c> newList) {
      checkForRecordExist(newList, null);
  }
  
  /***********************************************************************************************************
   * Method for check is record exist or not
	    #1 For panel type records, there can only be one record 
	      For each Position {Top Right, Top, Left, Bottom Right, Bottom Left} and Business Org Combination with Region = Default
	    #2 For panel type records, there can only be one record 
	      For each Position {Top Right, Top, Left, Bottom Right, Bottom Left} and Business Org and Region combination
      #3 For panel type records, there can only be one record 
        For each Component, Business Org and Region combination Where Location != None
   * @param newList List of Portal Banners
   * @param oldMap Map of old Portal Banners
   * @return void.
   *
   *Modified 12/4/2014 - Matt Salpietro - Added check for Page value
  ***********************************************************************************************************/
  private static void checkForRecordExist(List<PortalBanner__c> newList, Map<Id, PortalBanner__c> oldMap) {
    String useCase1FilterStr = 'Position__c,Business_Org__c,Region__c,Page__c'; 
    List<PortalBanner__c> lstPortalBanner = getLstPortalBanner(newList, oldMap, useCase1FilterStr);
		
		if(!lstPortalBanner.isEmpty()) {
			Set<String> keySet = new Set<String>();
			for(AggregateResult ar : [Select Position__c, Business_Org__c, Region__c, Page__c From PortalBanner__c 
                                Where RecordTypeId = :recordType.get('Panel').getRecordTypeId()  
                                group by Position__c, Business_Org__c, Region__c, Page__c]) {
        keySet.add(getKey(ar.get('Position__c') , null, ar.get('Business_Org__c'), ar.get('Region__c'), ar.get('Page__c')));
			}
			
			for(PortalBanner__c pb : lstPortalBanner) {
		    if(keySet.contains(getKey(pb.Position__c, null, pb.Business_Org__c, pb.Region__c, pb.Page__c))) {
	        pb.addError(getErrorMsg(Label.PortalBannerExistForPosition, pb));
		    } else {
	        keySet.add(getKey(pb.Position__c , null, pb.Business_Org__c, pb.Region__c, pb.Page__c));
		    }
			}   
    }
        
		useCase1FilterStr = 'Component_Type__c,Business_Org__c,Region__c,Position__c,Page__c';
		lstPortalBanner.clear();
		lstPortalBanner = getLstPortalBanner(newList, oldMap, useCase1FilterStr);
		if(!lstPortalBanner.isEmpty()) {
	    Set<String> keySet = new Set<String>();
	    for(AggregateResult ar : [Select Component_Type__c, Business_Org__c, Region__c, Page__c From PortalBanner__c 
                                Where RecordTypeId = :recordType.get('Panel').getRecordTypeId() 
                                And Position__c != '' And Position__c != null  
                                group by Component_Type__c, Business_Org__c, Region__c, Page__c]) {
	        
        keySet.add(getKey(null, ar.get('Component_Type__c'), ar.get('Business_Org__c'), ar.get('Region__c'), ar.get('Page__c')));
	    }
	    
	    for(PortalBanner__c pb : lstPortalBanner) {
		    if(keySet.contains(getKey(null, pb.Component_Type__c, pb.Business_Org__c, pb.Region__c, pb.Page__c))) {
	        pb.addError(getErrorMsg(Label.PortalBannerExistForComponentType, pb));
		    } else {
	        keySet.add(getKey(null , pb.Component_Type__c, pb.Business_Org__c, pb.Region__c, pb.Page__c));
		    }
	    }   
		}
  }
    
  /***********************************************************************************************************
   * Method for get final list of Portal Banner after check is field update and other required filters
   * @param newList List of Portal Banners
   * @param oldMap Map of old Portal Banners
   * @param changeFieldsStr string with comma separated fields api
   * @return List<Portal_Banner__c>.
  ***********************************************************************************************************/
  private static List<PortalBanner__c> getLstPortalBanner(
    List<PortalBanner__c> newList, Map<Id, PortalBanner__c> oldMap, String changeFieldsStr) {
    	
		List<PortalBanner__c> lstFinalPortalBanner = new List<PortalBanner__c>();
		List<PortalBanner__c> lstPortalBanner = new List<PortalBanner__c>();
    if(oldMap != null) {
			for(PortalBanner__c pb : newList) {
		    Boolean isRecordUpdate = false;
		    if(changeFieldsStr != '') {
	        for(String fieldApi : changeFieldsStr.split(',')) {
            isRecordUpdate = isRecordUpdate || Utility.isNewOrChanged(pb, fieldApi.trim(), oldMap);
	        }
		    }
		    if(isRecordUpdate) {
	        lstPortalBanner.add(pb);
		    }
			}
		} else {
	    lstPortalBanner.addAll(newList);
		}
        
		for(PortalBanner__c pb : lstPortalBanner) {
	    if(pb.RecordTypeId == recordType.get('Panel').getRecordTypeId() && pb.Position__c != null && pb.Position__c != '') {
        lstFinalPortalBanner.add(pb);
	    }
		}
		return lstFinalPortalBanner;
  }
    
  /***********************************************************************************************************
  * Append error message and replaces values for attributes: Position, Region, Business Org, Component Type
   * @param msg String error message
   * @param pb PortalBanner Record
   * @return String error message.
  ***********************************************************************************************************/
  private static String getErrorMsg(String msg, PortalBanner__c pb) {
		msg = msg.replace('[Position]', pb.Position__c);
		msg = msg.replace('[Region]', pb.Region__c);
		msg = msg.replace('[Business Org]', pb.Business_Org__c);
		msg = msg.replace('[Component Type]', pb.Component_Type__c);
		return msg;
  }
  
  /***********************************************************************************************************
  //Returns key for PortalBanner record constraints
   * @param position position of portalBanner
   * @param PortalBanner PortalBanner of portalBanner
   * @param bussinessOrg bussinessOrg of portalBanner
   * @param region region of portalBanner
   * @return Stirng.
  ***********************************************************************************************************/
  private static String getKey(object position, object compType, object bussinessOrg, object region, object page) {
    String key  = (position == null ? '' : String.valueOf(position) + '-')
			          + (compType == null ? '' : String.valueOf(compType) + '-')
			          + (bussinessOrg == null ? '' : String.valueOf(bussinessOrg) + '-')
			          + (region == null ? '' : String.valueOf(region) + '-')
                              + (page == null ? '' : String.valueOf(page) + '-');
    key = key.removeEnd('-');
    return key;
  }
}