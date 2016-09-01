@isTest
private class Test_QuestionViewController {

	static PageReference pref;
    static QuestionViewController con;
    static List<Question> qstnList;
    static List<Reply> repList;

    @isTest static void testAnsweringQuestion() {
        //create test data
        createTestData();
        Test.startTest();

        //Instantiate page and controller
        pref = Page.QuestionView;
        pref.getParameters().put('id', qstnList[0].Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(qstnList[0]);
        con = new QuestionViewController(stdCon);

        //test inserting an answer
        con.ans.Body = 'Test from test class';
        con.ans.QuestionId = qstnList[0].Id;
        con.postAnswer();

        //Query question to get updated value and assert
        Question q = [SELECT Id, NumReplies FROM Question WHERE Id =: qstnList[0].Id];
        system.assertEquals(6, q.NumReplies);

        Test.stopTest();
    }

    @isTest static void testSelectingBestAnswer() {
        //create test data
        createTestData();
        Test.startTest();

        //Instantiate page and controller
        pref = Page.QuestionView;
        pref.getParameters().put('id', qstnList[0].Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(qstnList[0]);
        con = new QuestionViewController(stdCon);

        //test selecting a reply as "Best Answer"
        con.bestAnswerId = repList[0].Id;
        con.addBestAnswer();

        //Query question to get updated value and assert
        Question q = [SELECT Id, BestReplyId FROM Question WHERE Id =: qstnList[0].Id];
        system.assertEquals(repList[0].Id, q.BestReplyId);

        //test removing a reply as "Best Answer"
        con.removeBestAnswer();

        //Query question to get updated value and assert
        Question q2 = [SELECT Id, BestReplyId FROM Question WHERE Id =: qstnList[0].Id];
        system.assertEquals(null, q2.BestReplyId);

        //test selecting a new reply as "Best Answer"
        con.bestAnswerId = repList[1].Id;
        con.addBestAnswer();

        //Query question to get updated value and assert
        Question q3 = [SELECT Id, BestReplyId FROM Question WHERE Id =: qstnList[0].Id];
        system.assertEquals(repList[1].Id, q3.BestReplyId);

        Test.stopTest();
    }

    @isTest static void testFollowingQuestion() {
        //create test data
        createTestData();
        Test.startTest();

        //Instantiate page and controller
        pref = Page.QuestionView;
        pref.getParameters().put('id', qstnList[0].Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(qstnList[0]);
        con = new QuestionViewController(stdCon);

        //test following question
        con.subscribe();

        //Query questionSubscription to get updated value and assert
        List<QuestionSubscription> qsList = [SELECT Id FROM QuestionSubscription WHERE QuestionId =: qstnList[0].Id
                                                AND SubscriberId = :UserInfo.getUserId()];
        system.assertEquals(1, qsList.size());

        //test unfollowing a question
        con.unsubscribe();

        //Query questionSubscription to get updated value and assert
        List<QuestionSubscription> qsList2 = new List<QuestionSubscription>();
        qsList2 = [SELECT Id FROM QuestionSubscription WHERE QuestionId =: qstnList[0].Id
                                    AND SubscriberId = :UserInfo.getUserId()];
        system.assertEquals(0, qsList2.size());

        Test.stopTest();
    }

    @isTest static void testEditQuestion() {
        //create test data
        createTestData();
        Test.startTest();

        //Instantiate page and controller
        pref = Page.QuestionView;
        pref.getParameters().put('id', qstnList[0].Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(qstnList[0]);
        con = new QuestionViewController(stdCon);

        //test editing question and assert new page
        PageReference nextPage = con.editQuestion();
        /*Map<String,String> pageParameters = nextPage.getParameters();
        System.assertEquals('/apex/QuestionEdit', nextPage.getUrl());
        System.assertEquals(1,pageParameters.values().size());
        System.assertEquals(qstnList[0].Id,pageParameters.get('id'));*/

        Test.stopTest();
    }

    @isTest static void testEditAnswer() {
        //create test data
        createTestData();
        Test.startTest();

        //Instantiate page and controller
        pref = Page.QuestionView;
        pref.getParameters().put('id', qstnList[0].Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(qstnList[0]);
        con = new QuestionViewController(stdCon);

        //test editing Answer and assert new page
        con.editAnswerId=repList[0].Id;
        PageReference nextPage = con.editAnswer();
        /*Map<String,String> pageParameters = nextPage.getParameters();
        System.assertEquals('/apex/AnswerEdit', nextPage.getUrl());
        System.assertEquals(1,pageParameters.values().size());
        System.assertEquals(qstnList[0].Id,pageParameters.get('id'));*/

        Test.stopTest();

    }

    @isTest static void testDeleteAnswer() {
        //create test data
        createTestData();
        Test.startTest();

        //Instantiate page and controller
        pref = Page.QuestionView;
        pref.getParameters().put('id', qstnList[0].Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(qstnList[0]);
        con = new QuestionViewController(stdCon);

        //test editing Answer and assert new page
        con.deleteAnswerId=repList[0].Id;
        con.deleteAnswer();

        //Query for deleted answer and assert it doesn't exist
        List<Reply> rList = new List<Reply>();
        rList = [SELECT Id FROM Reply WHERE Id= :repList[0].Id];
        System.assertEquals(0, rList.size());

        Test.stopTest();
    }

    private static void createTestData(){

        //create custom setting data used in controller
        Q_A_Settings__c qaSettings = Q_A_Settings__c.getOrgDefaults();
        qaSettings.Data_Category_Child_Name__c = 'Power_Solutions';
        qaSettings.Data_Category_Group_Name__c = 'Product_Support';
        qaSettings.Page_Size__c = 2;
        qaSettings.Zone_Id__c = '09aC000000017uX';
        insert qaSettings;

        //create a question
        qstnList = new List<Question>();
        qstnList.add(new Question(Title='test1', Body='test1', CommunityId=qaSettings.Zone_Id__c));
        insert qstnList;

        //create replies for that question
        repList = new List<Reply>();
        for(Question q : qstnList){
            for(Integer i = 0; i <5; i++){
                repList.add(new Reply(Body='test answer ' + q.Title + ' ' + i, QuestionId=q.Id));
            }
        }

        insert repList;

    }

}