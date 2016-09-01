public with sharing class QuestionViewController {

    public Question qstn {get;set;}
    public String deleteQuestionId {get;set;}
    public String bestAnswerId {get;set;}
    public Reply ans {get;set;}
    public String editAnswerId {get;set;}
    public String deleteAnswerId {get;set;}
    public Boolean currUserFollowing {get;set;}
    public String currUserId {get;set;}
    public Boolean bolQuestionDelete {get;set;}
    public Boolean bolQuestionEdit {get;set;}
    public Boolean bolAnswerDelete {get;set;}
    public Boolean bolAnswerEdit {get;set;}
    public Boolean bolSelectBestAnswer {get;set;}
    public Boolean bolRemoveBestAnswer {get;set;}
    public map<ID, Boolean> mapReplyIdTobolReplyEdit {get;set;}
    public map<ID, Boolean> mapReplyIdTobolReplyDelete {get;set;}
    public map<Id, Integer> mapReplyIdToVotes {get;set;}

    public QuestionViewController(ApexPages.StandardController controller) {
        mapReplyIdTobolReplyEdit = new map<ID, Boolean>();
        mapReplyIdTobolReplyDelete = new map<ID, Boolean>();
        mapReplyIdToVotes = new map<Id, Integer>();
        qstn = (Question)controller.getRecord();
        set<ID> setReplyIds = new set<ID>();
        currUserFollowing = false;
        currUserId = UserInfo.getUserId();
        qstn = [SELECT Id, BestReplyId, BestReplySelectedById, Body, CommunityId, CreatedDate, CreatedById,
                            CreatorName, HasSingleFieldForContent, NumReplies, NumSubscriptions,
                            Title, UpVotes, VoteScore, CreatorSmallPhotoUrl, BestReplySelectedBy.Name,
                            BestReply.Body, BestReply.Name, BestReply.CreatorName, BestReply.UpVotes,
                            BestReply.CreatorSmallPhotoUrl, BestReply.DownVotes, BestReply.CreatedDate,
                            BestReply.CreatedById,
                            (SELECT Id, Body, CommunityId, DownVotes, Name, QuestionId, UpVotes,
                                    VoteTotal, CreatorSmallPhotoUrl, CreatedDate, CreatorName, CreatedById
                             FROM Replies
                             ORDER BY CreatedDate ASC),
                            (SELECT Id
                             FROM Subscriptions
                             WHERE SubscriberId = :currUserId
                                AND QuestionId = :qstn.Id)
                     FROM Question
                     WHERE Id =: this.qstn.Id
                     LIMIT 1];
        if(qstn.Subscriptions.size() >= 1){
            currUserFollowing = true;
        }
        ans = new Reply(QuestionId = qstn.Id);

        for(Reply aRep : qstn.Replies){
            setReplyIds.add(aRep.Id);
            mapReplyIdToVotes.put(aRep.Id, (aRep.UpVotes - aRep.DownVotes) * 10);
        }

        UserRecordAccess usrQuestionAccess = [SELECT RecordId, HasEditAccess, HasDeleteAccess from UserRecordAccess
                                        where RecordId =: qstn.Id
                                        and UserId =: currUserId];
        Profile usrProfile = [Select Id, Name from Profile Where Id =: UserInfo.getProfileId()];
        //PermissionSet perSet = [Select Id From PermissionSet where ProfileId =: UserInfo.getProfileId()];
        PermissionSet perSet = [Select Id, Label From PermissionSet Where Label = 'Q&A Administrator'];
        List<PermissionSetAssignment> perSetAssigns = [Select Id From PermissionSetAssignment Where AssigneeId = :UserInfo.getUserId() And PermissionSetId = :perSet.Id];
        
        ObjectPermissions objectPermission = new ObjectPermissions();
        
        if(perSetAssigns.size() > 0){
            objectPermission = [Select PermissionsModifyAllRecords from ObjectPermissions where ParentId =: perSet.Id and SobjectType='Question__c' limit 1];
        } else {
            objectPermission = [Select PermissionsModifyAllRecords from ObjectPermissions where ParentId =: perSet.Id and SobjectType='Question' limit 1];
        }
            
        system.debug('testing fpr id' + qstn.CreatedById + currUserId);
        
        if(qstn.CreatedById == currUserId){
            bolSelectBestAnswer = true;
            bolRemoveBestAnswer = true;
        }
        if(qstn.CreatedById == currUserId || objectPermission.PermissionsModifyAllRecords)
            bolQuestionEdit = true;
            
        if(qstn.CreatedById == currUserId || objectPermission.PermissionsModifyAllRecords)
            bolQuestionDelete = true;

        /*for(UserRecordAccess usrAnswerAccess : [SELECT RecordId, HasEditAccess, HasDeleteAccess from UserRecordAccess
                                        where RecordId in :setReplyIds
                                        and UserId = :currUserId]){
            mapReplyIdTobolReplyEdit.put(usrAnswerAccess.RecordId, usrAnswerAccess.HasEditAccess);
            mapReplyIdTobolReplyDelete.put(usrAnswerAccess.RecordId, usrAnswerAccess.HasDeleteAccess);
        }*/
        
        for(Reply r : [SELECT Id,CreatedById
                          from Reply
                          where Id in :setReplyIds]){
            if(objectPermission.PermissionsModifyAllRecords || r.CreatedById == currUserId) {
                mapReplyIdTobolReplyEdit.put(r.Id, true);
                mapReplyIdTobolReplyDelete.put(r.Id, true);
            } else {
                mapReplyIdTobolReplyEdit.put(r.Id, false);
                mapReplyIdTobolReplyDelete.put(r.Id, false);
            }
        }
        
        system.debug('the answer access is ' + mapReplyIdTobolReplyEdit + mapReplyIdTobolReplyDelete);
        //display the message when answer is deleted - March 14, 2016 - Himshikha Agrawal - T-481166
        if(ApexPages.currentPage().getParameters().containsKey('hasError')){
            string errormessage=Apexpages.currentpage().getparameters().get('hasError');
            if(errormessage=='true'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,'Answer was deleted.');
                ApexPages.addMessage(msg);
            }
        } 
    }

    public PageReference subscribe(){
        QuestionSubscription sub = new QuestionSubscription (QuestionId=qstn.Id, SubscriberId=currUserId);
        insert sub;
        return new PageReference('/apex/QuestionView?id=' + qstn.Id).setRedirect(true);
    }

    public PageReference unsubscribe(){
        QuestionSubscription sub = [SELECT Id FROM QuestionSubscription  WHERE SubscriberId = :currUserId AND QuestionId = :qstn.Id];
        delete sub;
        return new PageReference('/apex/QuestionView?id=' + qstn.Id).setRedirect(true);
    }

    public PageReference editQuestion(){
        PageReference pageRef = new PageReference('/apex/QuestionEdit?id=' + qstn.Id);
        return pageRef;
    }
    
    //delete the question - March 14, 2016 - Himshikha Agrawal - T-481166
    public PageReference deleteQuestion(){
        system.debug('deleteQuestionId>>>'+deleteQuestionId);
        List<Question> questionToDelete = new List<Question>([SELECT Id FROM Question WHERE Id = :deleteQuestionId]);
        try {
            delete questionToDelete;
            return new PageReference('/apex/QuestionAndAnswer?hasError=true').setRedirect(true);
        }
        catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,e.getMessage());
            ApexPages.addMessage(msg);
        }
        return null;
    }

    public PageReference editAnswer(){
        system.debug('editAnswerId = ' + editAnswerId);
        return new PageReference('/apex/AnswerEdit?id=' + editAnswerId).setRedirect(true);
    }

    public PageReference deleteAnswer(){
        List<Reply> answerToDelete = new List<Reply>([SELECT Id FROM Reply WHERE Id = :deleteAnswerId]);
        delete answerToDelete;
        return new PageReference('/apex/QuestionView?id=' + qstn.Id + '&hasError=true').setRedirect(true);
    }

    public PageReference addBestAnswer(){
        qstn.BestReplyId = bestAnswerId;
        update qstn;
        return new PageReference('/apex/QuestionView?id=' + qstn.Id).setRedirect(true);
    }

    public PageReference removeBestAnswer(){
        qstn.BestReplyId = null;
        update qstn;
        return new PageReference('/apex/QuestionView?id=' + qstn.Id).setRedirect(true);
    }

    public PageReference postAnswer(){
        insert ans;
        return new PageReference('/apex/QuestionView?id=' + qstn.Id).setRedirect(true);
    }

}