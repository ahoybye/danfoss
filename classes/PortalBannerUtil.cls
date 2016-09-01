/*************************************************************************************************************
* @author Neeraj (Appirio Ind.)
* @date 12/3/2013
* @Story S-162787
* @description Utility class for portalbanner object related queries
*************************************************************************************************************/
public with sharing class PortalBannerUtil {
   
  /***********************************************************************************************************
  /* Returns jsonString for content Type default filter
  * @param portalBanner PortalBanner__c object
  * @return String.
  ***********************************************************************************************************/
  public static String getContentFilterString(PortalBanner__c portalBanner){
    String contentTypeFieldID = ContentType_Field_ID__c.getOrgDefaults().Content_Type_ID__c;
    
    Set<String> lstContentType = new Set<String>();
    lstContentType.add(portalBanner.Component_Type__c);
    system.debug('content type to query: ' + lstContentType);
    contentTypeFieldID = '{"'+contentTypeFieldID+'":[';
    if (lstContentType.contains('Technical Literature')) {
      contentTypeFieldID += '"9",';
    }
    if (lstContentType.contains('Service Bulletin')) {
      contentTypeFieldID += '"8",';
    } 
    if (lstContentType.contains('Announcement')) {
      contentTypeFieldID += '"1",';
    } 
    if (lstContentType.contains('Product Information Bulletin')) {
      contentTypeFieldID += '"7",';
    } 
    if (lstContentType.contains('Pricing & Tools')) {
      contentTypeFieldID += '"13","6","5","11",';
    }
    if (lstContentType.contains('Unique Selling Points Handbooks')) {
      contentTypeFieldID += '"17",';
    } 
    if (lstContentType.contains('Let\'s Torque E-Newsletters')) {
      contentTypeFieldID += '"18",';
    } 
    if (lstContentType.contains('Press Releases')) {
      contentTypeFieldID += '"19",';
    }
    if (lstContentType.contains('Customer Presentation Archives')) {
      contentTypeFieldID += '"20",';
    } 
    contentTypeFieldID = contentTypeFieldID.removeEnd(',');
    contentTypeFieldID += ']}';
	 system.debug('contentTypeFieldID: ' + contentTypeFieldID);
    return contentTypeFieldID;      
  }
}