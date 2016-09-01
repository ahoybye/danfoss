// Jan 27, 2016 Himshikha Agrawal - Modified for Global Search 
// Feb 05, 2016 Himshikha Agrawal - Modified for T-471244
public with sharing class QuestionAndAnswerController {

    public static string zoneId = '';
    //public List<Question> qList {get;set;}

    //Added by Rajeev A(Appirio) - [12/22/2015]: T-459875(Update QuestionAndAnswer Page)
    //public List<Question> qListVotes {get;set;}
    //public List<Question> qListReplies {get;set;}
    //public List<Question> qListSubscr {get;set;}
    //public boolean isRendered {get; set;}
    public String CategoryNameSelected {get;set;}
    public Boolean bolCatSelected {get;set;}

    //Added by Rajeev A(Appirio) - [12/22/2015]: T-459875(Update QuestionAndAnswer Page)
    Public Integer noOfRecordsCon{get; set;}
    Public Integer sizeCon{get;set;}
    Public Integer noOfRecordsRepliesCon{get; set;}
    Public Integer sizeRepliesCon{get;set;}
    Public Integer noOfRecordsVotesCon{get; set;}
    Public Integer sizeVotesCon{get;set;}
    Public Integer noOfRecordsSubCon{get; set;}
    Public Integer sizeSubCon{get;set;}
    Public Integer sizeMyFavCon{get;set;}
    Public Integer noOfRecordsMyFavCon{get; set;}
    //Public Integer noOfRecords {get;set;}
    //Public Integer size {get;set;}
    public Boolean noResults {get;set;}
    public String searchString {get; set;}

    public Q_A_Settings__c qaSettings;
    public Map<String, List<String>> mapCategoryNameToParentIds;
    public List<String> qIds;
    public Set<Id> quesRepIds{get; set;}
    public Set<Id> quesBodyIds;
    public string strCategoryFilter;
    public string searchStringFilter;
    public String myFavFilter;
    public Set<Id> quesId;
    public String mapKeyString{get; set;}
    
    public Boolean showMyFav{get; set;}
    
    public Map<ID, List<String>> mapQuesAnswer{get; set;}
    
    public Map<Id, List<Question>> mapSubscribedQuesList;


    public QuestionAndAnswerController(){
        mapKeyString = '';
        myFavFilter = '';
        showMyFav = false;   
        mapCategoryNameToParentIds = new Map<String, List<String>>();
        mapQuesAnswer = new Map<ID, List<String>>();
        mapSubscribedQuesList = new Map<Id, List<Question>>();
        qaSettings = Q_A_Settings__c.getOrgDefaults();
        sizeCon = qaSettings.Page_Size__c.intValue();
        sizeRepliesCon = qaSettings.Page_Size__c.intValue();
        sizeVotesCon = qaSettings.Page_Size__c.intValue();
        sizeSubCon = qaSettings.Page_Size__c.intValue();
        sizeMyFavCon = qaSettings.Page_Size__c.intValue();
        zoneId = qaSettings.Zone_Id__c;
        noResults = false;
        qIds  = new List<String>();
        quesId = new Set<Id>();
        strCategoryFilter = '';
        if(ApexPages.currentPage().getParameters().containsKey('CategoryName')){
            CategoryNameSelected = ApexPages.currentPage().getParameters().get('CategoryName');
            bolCatSelected = true;
            for(QuestionDataCategorySelection qDataCategory : [SELECT id, DataCategoryGroupName, DataCategoryName, Parent.Title, ParentId
                         FROM QuestionDataCategorySelection where parent.CommunityId = :zoneId ]){
                if(qDataCategory.DataCategoryName == CategoryNameSelected){
                    if(!mapCategoryNameToParentIds.containsKey(qDataCategory.DataCategoryName)){
                        mapCategoryNameToParentIds.put(qDataCategory.DataCategoryName, new List<String>{qDataCategory.ParentId});
                    }
                    else{
                        mapCategoryNameToParentIds.get(qDataCategory.DataCategoryName).add(qDataCategory.ParentId);
                    }
                }
            }
            qIds = mapCategoryNameToParentIds.get(CategoryNameSelected);
            system.debug('=== qIds = ' + qIds);
            if(qIds != null && qIds.size() > 0){
                strCategoryFilter = ' and Id IN :qIds ';
            }
            else{
                noResults = true;
            }
        }
        //Added by Himshikha Agrawal for Global Search
        searchStringFilter = '';
        if(ApexPages.currentPage().getParameters().containsKey('searchString')){
            searchString = ApexPages.currentPage().getParameters().get('searchString').trim();
            system.debug('searchString>>>'+searchString);
            quesRepIds = new Set<Id>();
            //fetching the noise words from Label
            Set<String> noiseWords = new Set<String>(Label.Noise_Words.split(';'));
            system.debug(noiseWords);
            
            if(searchString != null && searchString != ''){
                List<String> stringParts = searchString.split(' ');
                String searchTerms = '';
                for(String s : stringParts){
                    if(!noiseWords.contains(s)){
                        if(!String.isEmpty(searchTerms)){
                            searchTerms += ' OR ';
                        }
                        searchTerms += '("' + s + '")';
                    }
                }
                 
                system.debug('searchTerms>>>'+searchTerms);
                if(searchTerms != null && searchTerms != ''){
                    String searchQuery = 'FIND :searchTerms IN ALL FIELDS RETURNING  Question(Id,Title,Body), Reply(Question.Id, Body)';
                    system.debug('searchQuery>>>'+searchQuery);
                    List<List <sObject>> searchList = search.query(searchQuery);
                    List<Question> quesList = ((List<Question>)searchList[0]);
                    List<Reply> replyList  = ((List<Reply>)searchList[1]);
                    for(Reply rep : replyList){
                        quesRepIds.add(rep.Question.Id);
                        String answerBody = rep.Body.stripHtmlTags();
                        if(mapQuesAnswer.containsKey(rep.Question.Id)){
                            String answer = answerBody.length() > 50 ? answerBody.substring(0,50) + '...' : answerBody;
                            mapQuesAnswer.get(rep.Question.Id).add(answer);
                        } else {
                            mapQuesAnswer.put(rep.Question.Id, new List<String>());
                            mapKeyString = mapKeyString + rep.Question.Id;
                            String answer = answerBody.length() > 50 ? answerBody.substring(0,50)  + '...' : answerBody;
                            mapQuesAnswer.get(rep.Question.Id).add(answer);
                        }
                    }
                    for(Question ques : quesList){
                        quesRepIds.add(ques.Id);
                    }
                }
                searchStringFilter = 'AND Id IN :quesRepIds ';
            }
        }
        //diplay the success message after delete - March 14, 2016 - Himshikha Agrawal - T-481166
        if(ApexPages.currentPage().getParameters().containsKey('hasError')){
            string errormessage=Apexpages.currentpage().getparameters().get('hasError');
            if(errormessage=='true'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,'Question was deleted.');
                ApexPages.addMessage(msg);
            }
        }
        
        //display the favourite records for the logged in user
        //Added by Himshikha Agrawal April 05, 2016 - T-489816 
        if(ApexPages.currentPage().getParameters().containsKey('myFav')){
            showMyFav = true;
            String myFav = Apexpages.currentpage().getparameters().get('myFav');
            if(myFav == 'true'){
                for(QuestionSubscription sub : [Select QuestionId, SubscriberId from QuestionSubscription where SubscriberId = : UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1000]){
                    quesId.add(sub.QuestionId);
                    mapSubscribedQuesList.put(sub.QuestionId, new List<Question>());
                }
            }
            system.debug(mapSubscribedQuesList);
            myFavFilter = 'AND Id IN : quesId ';
        }
    }

    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){

                string queryString = 'SELECT Id, BestReplyId, Body, CreatorName, NumReplies, NumSubscriptions, Title,' +
                        'UpVotes, VoteScore, CreatedById, CreatedBy.Name, CreatedDate, CreatorSmallPhotoUrl,' +
                        '(SELECT DataCategoryGroupName, DataCategoryName, ParentId ' +
                        'FROM DataCategorySelections) '+
                 'FROM Question ' +
                 'WHERE CommunityId =\''+ zoneId + '\' '+
                 strCategoryFilter +
                 searchStringFilter +
                 'ORDER BY CreatedDate DESC';
                system.debug('query is ' + queryString);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(sizeCon);
                noOfRecordsCon = setCon.getResultSize();
                if(noOfRecordsCon == 0){
                    Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.Error,'No results to return'));
                }
            }
            return setCon;
        }set;
    }

    public ApexPages.StandardSetController setRepliesCon {
        get{
            if(setRepliesCon == null){

                string queryString = 'SELECT Id, BestReplyId, Body, CreatorName, NumReplies, NumSubscriptions, Title,' +
                        'UpVotes, VoteScore, CreatedById, CreatedBy.Name, CreatedDate, CreatorSmallPhotoUrl,' +
                        '(SELECT DataCategoryGroupName, DataCategoryName, ParentId ' +
                         'FROM DataCategorySelections) '+
                 'FROM Question ' +
                 'WHERE CommunityId =\''+ zoneId + '\' '+
                 strCategoryFilter +
                 searchStringFilter +
                 'ORDER BY NumReplies DESC';

                setRepliesCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setRepliesCon.setPageSize(sizeRepliescon);
                noOfRecordsRepliescon = setCon.getResultSize();
            }
            return setRepliesCon;
        }set;
    }

    public ApexPages.StandardSetController setVotesCon {
        get{
            if(setVotesCon == null){
                string queryString = 'SELECT Id, BestReplyId, Body, CreatorName, NumReplies, NumSubscriptions, Title,' +
                        'UpVotes, VoteScore, CreatedById, CreatedBy.Name, CreatedDate, CreatorSmallPhotoUrl,' +
                        '(SELECT DataCategoryGroupName, DataCategoryName, ParentId ' +
                         'FROM DataCategorySelections) '+
                 'FROM Question ' +
                 'WHERE CommunityId =\''+ zoneId + '\' '+
                 strCategoryFilter +
                 searchStringFilter +
                 'ORDER BY UpVotes DESC';


                setVotesCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setVotesCon.setPageSize(sizeVotesCon);
                noOfRecordsVotesCon = setVotesCon.getResultSize();
            }
            return setVotesCon;
        }set;
    }


    public ApexPages.StandardSetController setSubCon {
        get{
            if(setSubCon == null){
                string queryString = 'SELECT Id, BestReplyId, Body, CreatorName, NumReplies, NumSubscriptions, Title,' +
                        'UpVotes, VoteScore, CreatedById, CreatedBy.Name, CreatedDate, CreatorSmallPhotoUrl,' +
                        '(SELECT DataCategoryGroupName, DataCategoryName, ParentId ' +
                         'FROM DataCategorySelections) '+
                 'FROM Question ' +
                 'WHERE CommunityId =\''+ zoneId + '\' '+
                 strCategoryFilter +
                 searchStringFilter +
                 'ORDER BY NumSubscriptions DESC';


                setSubCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setSubCon.setPageSize(sizeSubCon);
                noOfRecordsSubCon = setSubCon.getResultSize();
            }
            return setSubCon;
        }set;
    }
    
    public ApexPages.StandardSetController setMyFavCon {
        get{
            if(setMyFavCon == null){
                string queryString = 'SELECT Id, BestReplyId, Body, CreatorName, NumReplies, NumSubscriptions, Title,' +
                        'UpVotes, VoteScore, CreatedById, CreatedBy.Name, CreatedDate, CreatorSmallPhotoUrl,' +
                        '(SELECT DataCategoryGroupName, DataCategoryName, ParentId ' +
                        'FROM DataCategorySelections) '+
                    'FROM Question ' +
                    'WHERE CommunityId =\''+ zoneId + '\' '+
                    myFavFilter;
                
                setMyFavCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setMyFavCon.setPageSize(sizeMyFavCon);
                noOfRecordsMyFavCon = setMyFavCon.getResultSize();
                if(noOfRecordsMyFavCon == 0){
                    Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.Error,'No results to return'));
                }
            }
            return setMyFavCon;
        }set;
    }

    Public List<Question> getQuestions(){
        List<Question> QList = new List<Question>();
        for(Question q : (List<Question>)setCon.getRecords()){
            //system.debug('testdebug1' + q.DataCategorySelections.size());
            QList.add(q);
        }
        return QList;
    }

    Public List<Question> getRepliesQuestions(){
        List<Question> QList = new List<Question>();
        for(Question q : (List<Question>)setRepliesCon.getRecords())
            QList.add(q);
        return QList;
    }

    Public List<Question> getVotesQuestions(){
        List<Question> QList = new List<Question>();
        for(Question q : (List<Question>)setVotesCon.getRecords())
            QList.add(q);
        return QList;
    }

    Public List<Question> getSubsQuestions(){
        List<Question> QList = new List<Question>();
        for(Question q : (List<Question>)setSubCon.getRecords())
            QList.add(q);
        return QList;
    }
    
    Public List<Question> getMyFavQuestions(){
        List<Question> QList = new List<Question>();
        for(Question q : (List<Question>)setMyFavCon.getRecords()){
            if(mapSubscribedQuesList.get(q.Id) != null)
               mapSubscribedQuesList.get(q.Id).add(q);
        }
        for(Id  qId : mapSubscribedQuesList.keySet()){
            QList.addAll(mapSubscribedQuesList.get(qId));
        }
        return QList;
    }

    /*public pageReference refresh() {
        setCon = null;
        getQuestions();
        setCon.setPageNumber(1);
        return null;
    }*/
}