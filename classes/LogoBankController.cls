/***************************************************************************
// (c) 2014 Appirio, Inc. 
//
// LogoBankController
// Contoller class for LogoBank Page
//
// Dec 16, 2014     Arvind Thakur T-340991
// 
//**************************************************************************/
public without sharing class LogoBankController {
  public Blob logoImage{get; set;}
  public Blob attachment {get;set;}
  public String filename {get; set;}
  public String commentBox {get; set;}
  public String contentType {get; set;}
  public List<ContentWrapper> conWrapList {get; set;}

  private Account account;
  public Case newCase;
  public User user; 

  public LogoBankController() {  
    user = [SELECT Id, Contact.AccountId, ContactId, firstname FROM user WHERE id=:userinfo.getuserid() LIMIT 1];
    if(user != null){
      for(Account acc : [SELECT Id, OwnerId FROM Account WHERE Id =:user.Contact.AccountId]){
        account = acc;
      }
    }
    conWrapList = new List<ContentWrapper>();
    List<ContentDocument> allLogos = [SELECT Description, Title, LatestPublishedVersion.Content_Type__c, LatestPublishedVersion.PublishStatus, 
                                                                      LatestPublishedVersion.FileType, LatestPublishedVersion.PathOnClient, LatestPublishedVersionId
                                                                      FROM ContentDocument c
                                                                      WHERE c.LatestPublishedVersion.Content_Type__c='logo'];  
    for(ContentDocument cd : allLogos){
      ContentWrapper cw = new ContentWrapper();
      cw.converid = cd.LatestPublishedVersionId; 
      cw.description = cd.Description;
      cw.title = cd.Title;
      conWrapList.add(cw);   
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
    RecordType RecType = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Portal Case'];

    String description = commentBox;

    Id caseId = Utility.createPortalCase(RecType.Id, description, 'Logo Design', 'PartnerLink', 'Logo Design Request'
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