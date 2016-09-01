/*************************************************************************************************************
* @author Matt Salpietro
* @date 12/5/2014
* @description Controller class for PartnerPortalPanelComponent.
*************************************************************************************************************/
public with sharing class PartnerPortalPanelComponentCtrl {
  public String pos{get;set;}
  public String errorMsg {get;set;}

/***********************************************************************************************************
/* Returns Current user with region and business org
***********************************************************************************************************/
private static User m_User;
private static User currentUser {
  get {
    if (m_User == null) {
      for (User usr: [ Select Contact.Account.Region__c, Contact.Account.Business_Org__c 
        From User 
        Where Id = :UserInfo.getUserId()]) {
        m_User = usr;
      }
    }
    return m_User;
  }
}

private static String userRegion = currentUser.Contact.Account.Region__c;
private static String userBusinessOrg = currentUser.Contact.Account.Business_Org__c;
private static String componentType = '';
private static Map<String,Schema.RecordTypeInfo>  recordType = Schema.SObjectType.PortalBanner__c.getRecordTypeInfosByName();

/***********************************************************************************************************
/* Returns Current user with region and business org
***********************************************************************************************************/
private List<PortalBanner__c> lstPnlBanner;
private PortalBanner__c m_portalBanner;

public PortalBanner__c portalBanner {
  get {
    if (lstPnlBanner != null) {
      return m_portalBanner;
    }
    m_portalBanner = getPortalBannerRecord(userRegion);
    return m_portalBanner;
  }
}

/***********************************************************************************************************
/* Returns Portal Banner Record based on region
* @param region Region
* @return PortalBanner__c.
***********************************************************************************************************/
private PortalBanner__c getPortalBannerRecord(String region){
  PortalBanner__c portalBanner;
  lstPnlBanner = [SELECT Id, Component_Type__c, Object__c, Summary__c, Name, (SELECT Id, Name  FROM Attachments)
                              FROM PortalBanner__c 
                              WHERE Position__c = :pos 
                              AND Region__c = :region   
                              AND Business_Org__c = :userBusinessOrg 
                              AND RecordTypeId = :recordType.get('Marketing Panel').getRecordTypeId()];
  //There should only be one match for VF Page and Position (Filter: VF Page, Position, User Region, User Business Org, RecordTypeId)                           
  if (lstPnlBanner.size() == 1) {
    portalBanner = lstPnlBanner[0]; 
    }else if(lstPnlBanner.isEmpty()){
  //Query banner record again for region "Default"
  lstPnlBanner = [SELECT Id, Component_Type__c, Object__c, Summary__c, Name, (SELECT Id, Name  FROM Attachments)
  FROM PortalBanner__c 
  WHERE Position__c = :pos 
  AND Region__c = 'Default'   
  AND RecordTypeId = :recordType.get('Marketing Panel').getRecordTypeId()];
  if(!lstPnlBanner.isEmpty()){
    PortalBanner__c defaultPortalBanner = lstPnlBanner[0];
    portalBanner = defaultPortalBanner;       
    } else {
      componentType = '';
    }
  }

  return portalBanner;
}

/***********************************************************************************************************
/* Returns list of links
* @return List<PortalBannerLink__c> returns list of portal banner links.
***********************************************************************************************************/
public List<PortalBannerLink__c> getPortalLInks() {
  String sitePrefix = '';
  if(Site.getPathPrefix() != null){
    sitePrefix = Site.getPathPrefix();
  }
  List<PortalBannerLink__c> portalLinkList = new List<PortalBannerLink__c>();

  for(PortalBannerLink__c link : [SELECT URL__c, Sequence__c, Name, Target__c, Type__c, DisplayPop__c, DisplayPopText__c, DisplayPopupText__c
                                                          FROM PortalBannerLink__c
                                                          WHERE PortalBanner__c = :portalBanner.Id
                                                          ORDER BY Sequence__c]) {
															  System.debug(link);
    if(link.Target__c == 'Self'){
      link.Target__c = '_self';
      } else {
        link.Target__c = '_blank';
      }
      if(link.Type__c == 'Internal'){
        String pageURL = ApexPages.currentPage().getUrl();
        link.URL__c = sitePrefix + '/apex/' + link.URL__c + '?' + pageURL.substring(pageURL.indexOf('sfdc.tabName'));
      } else if(link.Type__c == 'Content'){
        Id contentVersionId = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id = :link.URL__c LIMIT 1].LatestPublishedVersionId;
        //link.URL__c = URL.getSalesforceBaseUrl().toExternalForm() + sitePrefix + '/sfc/servlet.shepherd/version/download/' + contentVersionId;
        link.URL__c = sitePrefix + '/sfc/servlet.shepherd/version/download/' + contentVersionId;
      } 
      portalLinkList.add(link);
    }
    return portalLinkList;
  }

}