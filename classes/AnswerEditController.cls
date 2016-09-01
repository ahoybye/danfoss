public with sharing class AnswerEditController {
    
    public Reply ans {get;set;}
    
    public AnswerEditController(ApexPages.StandardController controller) {
        ans = (Reply)controller.getRecord();
        ans = [SELECT Id, Name, Body, QuestionId, Question.Title
                FROM Reply
                WHERE Id =: ans.Id];     
    }
    
    public PageReference cancel(){
        PageReference pageRef = new PageReference('/apex/QuestionView?id=' + ans.QuestionId);
        return pageRef;
    }
    
    public PageReference save(){
        update ans;
        PageReference pageRef = new PageReference('/apex/QuestionView?id=' + ans.QuestionId);
        return pageRef;
    }

}