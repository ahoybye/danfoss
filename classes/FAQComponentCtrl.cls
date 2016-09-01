/***************************************************************************
// (c) 2014 Appirio, Inc. 
//
// FAQComponentCtrl
// Controller class for FAQ component
//
// Dec 12, 2014
// 
//**************************************************************************/
global without sharing class FAQComponentCtrl {
    
  //public ApexPages.StandardSetController setCont { get; set; }
  public String newQuestion {get;set;}
  public String questionTopic {get;set;}
  
  public List<Question__c> lstQues {
    get {
        if (lstQues == null){
        initFAQ();
        return lstQues;
        }else{
        return lstQues;
        }
    }set;
  }
  private User currentUsr;
    
  public FAQComponentCtrl(){
    currentUsr = [SELECT ContactId, Contact.AccountId, Contact.Account.OwnerId, Contact.Account.Region__c FROM User WHERE Id = :Userinfo.getUserId()];  
    initFAQ();
  }

  //Get list of questions by users region. If no region exists pull in default questions.
  public void initFAQ(){
    lstQues = new List<Question__c>();
    if(currentUsr.ContactId != null && currentUsr.Contact.Account.Region__c != null){
     lstQues = [SELECT Question__c, Answer__c, Region__c FROM Question__c 
      WHERE Region__c = :currentUsr.Contact.Account.Region__c ORDER BY SortOrder__c NULLS LAST, Question__c];
   }

   if(lstQues.size() == 0){
     lstQues = [SELECT Question__c, Answer__c, Region__c FROM Question__c 
       WHERE Region__c = 'Default' ORDER BY SortOrder__c NULLS LAST, Question__c];
   }
  }

  //Remote action to track how many clicks each question receives
  @RemoteAction
  global static void trackClicks(String questionId) {
    Question__c viewedQuestion = [SELECT ViewCount__c FROM Question__c WHERE Id = :questionId];
    if(viewedQuestion.ViewCount__c != null) {
      viewedQuestion.ViewCount__c += 1;
    } else {
      viewedQuestion.ViewCount__c = 1;
    }
    update viewedQuestion;
  }
  
  //Create Case
  public PageReference createNewCase(){
    RecordType RecType = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'PartnerLink Case'];

    String subject = questionTopic + ' - FAQ Question';

    Id caseId = Utility.createPortalCase(RecType.Id, newQuestion, 'Marketing Question', 'PartnerLink', subject
      , 'New', currentUsr.Contact.AccountId, currentUsr.ContactId);

    return null;
  }

}