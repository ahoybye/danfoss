/***************************************************************************
// (c) 2014 Appirio, Inc. 
//
// LogoBankController
// Contoller class for LogoBank Page
//
// Dec 16, 2014     Arvind Thakur T-340991
// 
//**************************************************************************/
public without sharing class LogoBankCtrl {
  public Blob logoImage{get; set;}
  public Blob attachment {get;set;}
  public String filename {get; set;}
  public String commentBox {get; set;}
  public String contentType {get; set;}
  public List<ContentWrapper> conWrapList {get; set;}
  public PortalBanner__c portalBanner {get; set;}

  private Account account;
  public Case newCase;
  public User user; 

  private static Map<String,Schema.RecordTypeInfo>  recordType = Schema.SObjectType.PortalBanner__c.getRecordTypeInfosByName();
  
  public LogoBankCtrl() {  
    user = [SELECT Id, Contact.AccountId, ContactId, Contact.Account.Region__c, Contact.Account.Business_Org__c, FirstName FROM User WHERE Id=:userInfo.getuserid() LIMIT 1];
    if(user != null){
      for(Account acc : [SELECT Id, OwnerId FROM Account WHERE Id =:user.Contact.AccountId]){
        account = acc;
      }
    }
    conWrapList = new List<ContentWrapper>();
    List<ContentDocument> allLogos = [SELECT LatestPublishedVersion.Description, Title, LatestPublishedVersion.Content_Type__c, LatestPublishedVersion.PublishStatus, 
                                                                      LatestPublishedVersion.FileType, LatestPublishedVersion.PathOnClient, LatestPublishedVersionId
                                                                      FROM ContentDocument c
                                                                      WHERE c.LatestPublishedVersion.Content_Type__c='logo'];  
    for(ContentDocument cd : allLogos){
      ContentWrapper cw = new ContentWrapper();
      cw.converid = cd.LatestPublishedVersionId; 
      cw.description = cd.LatestPublishedVersion.Description;
      cw.title = cd.Title;
      conWrapList.add(cw);   
    }

    portalBanner = new PortalBanner__c();
    List<PortalBanner__c> lstPnlBanner = new List<PortalBanner__c>();
    lstPnlBanner = [SELECT Summary__c
                                FROM PortalBanner__c 
                                WHERE Region__c = :user.Contact.Account.Region__c   
                                AND Business_Org__c = :user.Contact.Account.Business_Org__c
                                AND Page__c = 'LogoBank' 
                                AND RecordTypeId = :recordType.get('Page Information').getRecordTypeId()];
    //There should only be one match for VF Page and Position (Filter: VF Page, Position, User Region, User Business Org, RecordTypeId)                           
    if (lstPnlBanner.size() == 1) {
      portalBanner = lstPnlBanner[0]; 
    }else if(lstPnlBanner.isEmpty()){
      //Query banner record again for region "Default"
      lstPnlBanner = [SELECT Summary__c
                                  FROM PortalBanner__c
                                  WHERE Region__c = 'Default' 
                                  AND Page__c = 'LogoBank'
                                  AND RecordTypeId = :recordType.get('Page Information').getRecordTypeId()];
      if(!lstPnlBanner.isEmpty()){
        PortalBanner__c defaultPortalBanner = lstPnlBanner[0];
        portalBanner = defaultPortalBanner;       
      }
    }
  }

  //Create Attachment
  public boolean createAttachment(Id objectId){
    Attachment newAttachment = new Attachment();
    newAttachment.ContentType = contentType;
    newAttachment.Body = attachment;
    newAttachment.ParentId = objectId;
    newAttachment.Name = filename;
  try{
    insert newAttachment;
    return true;
    }catch(exception ex){
      return false;
    }
  }
   
  //Create Case
  public void generateCase(){
    RecordType RecType = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'PartnerLink Case'];

    String description = commentBox;

    Id caseId = Utility.createPortalCase(RecType.Id, description, 'Logo Design', 'PartnerLink', 'Document Approval for Logo Request'
      , 'New', account.Id, user.ContactId);

    if(caseId != null && attachment != null){
      if(createAttachment(caseId)){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Thank you for your request!'));
      } else {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'An error has occured. Please try again.'));
      }
    }
  }
   
  //Wrapper class
  public class ContentWrapper{
    public String converid {get;set;}
    public String description {get;set;}
    public String title {get;set;}
  }
}