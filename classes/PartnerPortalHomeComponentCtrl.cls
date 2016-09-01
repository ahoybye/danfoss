/*************************************************************************************************************
* @author Ankit (Appirio Ind.)
* @date 12/3/2013
* @description Controller class for PartnerPortalHomeComponent.
* @modified
* @12/5/2014 - Added check for Page name
*************************************************************************************************************/
public with sharing class PartnerPortalHomeComponentCtrl {
  public String pos{get;set;}
  public String errorMsg {get;set;}
  public User loginuser = [Select Id, Business_Org__c From User where Id =:userInfo.getUserId()];
  public Portal_Business_Org_Style__c pobu = Portal_Business_Org_Style__c.getInstance('PartnerLink Home Page');
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
      //Retrieve current page name
      string pageName = EncodingUtil.urlEncode(ApexPages.currentPage().getUrl().replaceFirst('/apex/',''),'UTF-8').split('%3F',0)[0];	 
      lstPnlBanner = [Select id, Component_Type__c, Object__c, Content_Type_to_Query__c 
                         From PortalBanner__c 
                         Where Position__c = :pos 
                         And Region__c = :region   
                         AND Business_Org__c = :userBusinessOrg 
                         AND Page__c = :pageName
                         And RecordTypeId = :recordType.get('Panel').getRecordTypeId()];
      
      //There should only be one match for VF Page and Position (Filter: VF Page, Position, User Region, User Business Org, RecordTypeId)                           
      if (lstPnlBanner.size() == 1) {
        portalBanner = lstPnlBanner[0]; 
      }else if(lstPnlBanner.isEmpty()){
        //Query banner record again for region "Default"
        lstPnlBanner = [Select id, Component_Type__c, Object__c, Content_Type_to_Query__c 
                         From PortalBanner__c 
                         Where Position__c = :pos 
                         And Region__c = 'Default'   
                         AND Business_Org__c = :userBusinessOrg
                         AND Page__c = :pageName
                         And RecordTypeId = :recordType.get('Panel').getRecordTypeId()];
        if(!lstPnlBanner.isEmpty()){
            PortalBanner__c defaultPortalBanner = lstPnlBanner[0];
            //Check other portal records displayed on page to see if there is a matching component type
            List<PortalBanner__c> tempLstPnlBanner = [Select id, Component_Type__c, Object__c, Content_Type_to_Query__c 
                             From PortalBanner__c 
                             Where Position__c != null And Position__c != ''  
                             And Region__c = :region   
                             AND Business_Org__c = :userBusinessOrg
                             AND Page__c = :pageName
                             And RecordTypeId = :recordType.get('Panel').getRecordTypeId()
                             And Component_Type__c = :defaultPortalBanner.Component_Type__c
                             And Id != :defaultPortalBanner.Id];
            
          if(!tempLstPnlBanner.isEmpty()){
            componentType = defaultPortalBanner.Component_Type__c;
            addErrorMsg(Label.Error_Msg_For_Multiple_Portal_Widget_Record_Match_Found_For_Same_Component_Type);
          } else{
            portalBanner = defaultPortalBanner;
          }                 
        } else {
            componentType = '';
            addErrorMsg(Label.Error_Msg_For_No_Portal_Widget_Record_Match_Found_Portal_Home_Page);
        }
      }
    
    return portalBanner;
  }

  /***********************************************************************************************************
  /* Returns list of contents
  * @return List<ContentVersion> returns list of content versions.
  ***********************************************************************************************************/
  public List<ContentVersion> getContentList() {
    List<ContentVersion> contentList = new List<ContentVersion>();
    if (portalBanner.Content_Type_to_Query__c == null) {
      return contentList;
    }
    List<String> lstContentType = new List<String>();
    lstContentType = portalBanner.Content_Type_to_Query__c.split(';');
    
    for(ContentVersion contentVersion : [ Select c.Title, c.CreatedDate, c.Content_Type__c, c.ContentDocumentId, c.ContentURL 
                                          From ContentVersion c 
                                          Where Content_Type__c IN :lstContentType 
                                          And IsLatest = true
                                          //And Region__c = :userRegion
                                          //AND Business_Org__c = :userBusinessOrg
                                          order by CreatedDate DESC limit :(Integer)pobu.NumberOfItems__c]) {
      contentList.add(contentVersion);
    }
    return contentList;
  }

  /***********************************************************************************************************
  /* Returns top 5 ideas based on created date
  * @return List<Idea>
  ***********************************************************************************************************/
  public List<Idea> getIdeaList() {
    return [Select i.Title, i.CreatedDate From Idea i order by CreatedDate DESC limit :(Integer)pobu.NumberOfItems__c];
  }
  
  /***********************************************************************************************************
  /* Returns top 5 ideas based on created date
  * @return List<Idea>
  ***********************************************************************************************************/
  private void addErrorMsg(String msg) {
    msg = msg.replace('[Position]', pos);
    msg = msg.replace('[Region]', userRegion != null ? userRegion : '\'\'');
    msg = msg.replace('[Business Org]', userBusinessOrg != null ? userBusinessOrg : '\'\'');
    msg = msg.replace('[Component Type]', componentType != null ? componentType : '\'\'');
    
    if (portalBanner != null) {
      msg = msg.replace('[Object]', portalBanner.Object__c);
    } else {
        msg = msg.replace('[Object]', '\'\'');
    }
    if (errorMsg == null) {
      errorMsg = msg;
    } else {
      errorMsg += msg;
    }
  }

  /***********************************************************************************************************
  /* Returns content filter string
  * @return List<Idea>
  ***********************************************************************************************************/
  public String ContentFilterString {
    get {
        return PortalBannerUtil.getContentFilterString(portalBanner);
    }
  }   
  
}