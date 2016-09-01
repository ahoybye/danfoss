/***************************************************************************
// (c) 2014 Appirio, Inc. 
//
// ImageBankCtrl  
// Controller class for ImageBank Page 
//
// Dec 12, 2014     Nishant Bansal (Appirio JDC) 
// Updated by Arvind Thakur on 17th Dec T-341544, T-341545.
//**************************************************************************/
public without sharing class ImageBankCtrl {
  public list<ContentWrapper> conWrapList {get;set;}
  public list<ContentWrapper> conWrapGraphicsList {get;set;}
  public list<String> productSelectList {
    get{
      if(productSelectList == null){
        productSelectList = new list<String>();
        for(SelectOption s : Utility.getPicklistValues(New PortalBanner__c(), 'Products__c')){
          productSelectList.add(s.getValue());
        }
      }
      return productSelectList;
    }set;}

  public String imageString {get; set;}
  public String commentBox {get; set;}
  public Blob attachment {get;set;}
  public String filename {get; set;}
  public String contentType {get; set;}
  public PortalBanner__c portalBanner {get; set;}

  public User user;

  private Account account;
  private Contact contact;
  private Case newCase;
  private static Map<String,Schema.RecordTypeInfo>  recordType = Schema.SObjectType.PortalBanner__c.getRecordTypeInfosByName();

  public ImageBankCtrl() {
    //productSelectList = Utility.getPicklistValues(Case, 'Products__c');

    user = [SELECT Id, Contact.AccountId, AccountId, ContactId, Contact.Account.Region__c, Contact.Account.Business_Org__c, FirstName FROM User WHERE Id=:userInfo.getuserid() LIMIT 1];
    if(user != null){
      for(Contact con : [SELECT Id, AccountId, Account.OwnerId FROM Contact WHERE Id = :user.ContactId]){
        contact = con; 
      }
      for(Account acc : [SELECT Id, OwnerId FROM Account WHERE Id =:user.AccountId]){
        account = acc;
      }  
    }

    List<ContentDocument> allLogos = [SELECT LatestPublishedVersion.Description,Title,LatestPublishedVersion.Content_Type__c,LatestPublishedVersion.PublishStatus,
                                                                      LatestPublishedVersion.FileType,LatestPublishedVersion.PathOnClient,LatestPublishedVersionId,
                                                                      LatestPublishedVersion.Content_ID__c
                                                                      FROM ContentDocument 
                                                                      WHERE LatestPublishedVersion.Content_Type__c IN ('Product Image','Product Graphic')
                                                                      ORDER BY  LatestPublishedVersion.Content_Type__c, ContentModifiedDate DESC];
    conWrapList = new list<ContentWrapper>();
    conWrapGraphicsList = new list<ContentWrapper>();
    for(ContentDocument cd : allLogos){
      ContentWrapper cw = new ContentWrapper();
      cw.title = cd.Title;
      cw.converid = cd.LatestPublishedVersionId; 
      cw.extid = cd.LatestPublishedVersion.Content_ID__c;
      cw.description = cd.LatestPublishedVersion.Description;
      if(cd.LatestPublishedVersion.Content_Type__c == 'Product Image'){
        conWrapList.add(cw);
      } else {
        conWrapGraphicsList.add(cw);
      }
    } 

    portalBanner = new PortalBanner__c();
    List<PortalBanner__c> lstPnlBanner = new List<PortalBanner__c>();
    lstPnlBanner = [SELECT Summary__c
                                FROM PortalBanner__c 
                                WHERE Region__c = :user.Contact.Account.Region__c   
                                AND Business_Org__c = :user.Contact.Account.Business_Org__c
                                AND Page__c = 'ImageBank' 
                                AND RecordTypeId = :recordType.get('Page Information').getRecordTypeId()];
    //There should only be one match for VF Page and Position (Filter: VF Page, Position, User Region, User Business Org, RecordTypeId)                           
    if (lstPnlBanner.size() == 1) {
      portalBanner = lstPnlBanner[0]; 
    }else if(lstPnlBanner.isEmpty()){
      //Query banner record again for region "Default"
      lstPnlBanner = [SELECT Summary__c
                                  FROM PortalBanner__c
                                  WHERE Region__c = 'Default' 
                                  AND Page__c = 'ImageBank'
                                  AND RecordTypeId = :recordType.get('Page Information').getRecordTypeId()];
      if(!lstPnlBanner.isEmpty()){
        PortalBanner__c defaultPortalBanner = lstPnlBanner[0];
        portalBanner = defaultPortalBanner;       
      }
    }              
  }

  public PageReference Submit(){ 
    return new PageReference('');
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

    String description = 'Requested Images: ' + imageString + '\r\n\r\n' + commentBox;

    Id caseId = Utility.createPortalCase(RecType.Id, description, 'Image Request', 'PartnerLink', 'Image Bank Request'
      , 'New', account.Id, user.ContactId);

    if(caseId != null && attachment != null){
      if(createAttachment(caseId)){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Thank you for your request!'));
      } else {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'An error has occured. Please try again.'));
      }
    }
  }

  public class ContentWrapper {
    public String title {get;set;}
    public Blob image {get;set;}
    public String converid {get;set;}
    public String description {get;set;}
    public String extid {get;set;}

    public ContentWrapper(){
    }
  }

}