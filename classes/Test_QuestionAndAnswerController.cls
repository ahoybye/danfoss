@isTest
private class Test_QuestionAndAnswerController {

    //static PageReference pref;
    //static QuestionAndAnswerController con;

    @isTest static void testStandardPage() {
        //create test data
        createTestData(true);
        Test.startTest();

        //instantiate page and controller
        PageReference pref = Page.QuestionAndAnswer;
        Test.setCurrentPage(pref);
        QuestionAndAnswerController con = new QuestionAndAnswerController();

        //call methods
        con.getQuestions();
        con.getRepliesQuestions();
        con.getSubsQuestions();
        con.getVotesQuestions();

        //assert logic
        system.assertNotEquals(con.setCon, null);
        system.assertNotEquals(con.setRepliesCon, null);
        system.assertNotEquals(con.setVotesCon, null);
        system.assertNotEquals(con.setSubCon, null);
        system.assertEquals(5, con.noOfRecordsCon);
        system.assertEquals(2, con.sizeCon);
        system.assertEquals(5, con.noOfRecordsRepliesCon);
        system.assertEquals(2, con.sizeRepliesCon);
        system.assertEquals(5, con.noOfRecordsVotesCon);
        system.assertEquals(2, con.sizeVotesCon);
        system.assertEquals(5, con.noOfRecordsSubCon);
        system.assertEquals(2, con.sizeSubCon);
        system.assertEquals(false,con.noResults);

        Test.stopTest();
    }

    @isTest static void testWithCatNameWithQuestions() {
        //create test data
        createTestData(false);
        Test.startTest();

        //instantiate page and controller
        PageReference pref = Page.QuestionAndAnswer;
        pref.getParameters().put('CategoryName', 'Steering');
        Test.setCurrentPage(pref);
        QuestionAndAnswerController con = new QuestionAndAnswerController();

        //assert logic
        system.assertNotEquals(con.setCon, null);
        system.assertNotEquals(con.setRepliesCon, null);
        system.assertNotEquals(con.setVotesCon, null);
        system.assertNotEquals(con.setSubCon, null);
        system.assertEquals(1, con.noOfRecordsCon);
        system.assertEquals(1, con.noOfRecordsRepliesCon);
        system.assertEquals(1, con.noOfRecordsVotesCon);
        system.assertEquals(1, con.noOfRecordsSubCon);
        system.assertEquals(false,con.noResults);

        Test.stopTest();
    }

    @isTest static void testWithCatNameWithoutQuestions() {
        //create test data
        createTestData(false);
        Test.startTest();

        //instantiate page and controller
        PageReference pref = Page.QuestionAndAnswer;
        pref.getParameters().put('CategoryName', 'Valves');
        Test.setCurrentPage(pref);
        QuestionAndAnswerController con = new QuestionAndAnswerController();

        //assert logic
        system.assertEquals(true,con.noResults);

        Test.stopTest();
    }
    
    //Test Method for global search string functionality
    // Added by Himshikha Agrawal, Feb 01, 2016
    @isTest static void testWithSearchString(){
        //create test data
        createTestData(false);
        Test.startTest();
        
        //instantiate page and controller
        PageReference pref = Page.QuestionAndAnswer;
        pref.getParameters().put('searchString', 'test');
        Test.setCurrentPage(pref);
        QuestionAndAnswerController con = new QuestionAndAnswerController();
        
        //assert logic
        system.assertNotEquals(con.setCon, null);

        Test.stopTest();
    }

    private static void createTestData(Boolean createMultipleQDCS){
        //create custom setting data used in controller
        Q_A_Settings__c qaSettings = Q_A_Settings__c.getOrgDefaults();
        qaSettings.Data_Category_Child_Name__c = 'Power_Solutions';
        qaSettings.Data_Category_Group_Name__c = 'Product_Support';
        qaSettings.Page_Size__c = 2;
        qaSettings.Zone_Id__c = '09aC000000017uX';
        insert qaSettings;

        //create 5 questions
        List<Question> qstnList = new List<Question>();
        qstnList.add(new Question(Title='test1', Body='test1', CommunityId=qaSettings.Zone_Id__c));
        qstnList.add(new Question(Title='test2', Body='test2', CommunityId=qaSettings.Zone_Id__c));
        qstnList.add(new Question(Title='test3', Body='test3', CommunityId=qaSettings.Zone_Id__c));
        qstnList.add(new Question(Title='test4', Body='test4', CommunityId=qaSettings.Zone_Id__c));
        qstnList.add(new Question(Title='test5', Body='test5', CommunityId=qaSettings.Zone_Id__c));
        insert qstnList;

        //Create 5 replies for each question
        List<Reply> repList = new List<Reply>();
        for(Question q : qstnList){
            for(Integer i = 0; i <5; i++){
                repList.add(new Reply(Body='test answer ' + q.Title + ' ' + i, QuestionId=q.Id));
            }
        }

        insert repList;

        //If createMultipleQDSC is true, create data category selection for each question
        //If false, only create a data category selection for 1 question
        List<QuestionDataCategorySelection> qdcsList = new List<QuestionDataCategorySelection>();
        if(createMultipleQDCS == true){

            DataCategoryGroupSObjectTypePair pair1 = new DataCategoryGroupSObjectTypePair();
            pair1.dataCategoryGroupName=qaSettings.Data_Category_Group_Name__c;
            pair1.sObject='Question';
            DescribeDataCategoryGroupStructureResult[] results = Schema.describeDataCategoryGroupStructures(new DataCategoryGroupSObjectTypePair[]{pair1}, false);
            for (DescribeDataCategoryGroupStructureResult res : results){
                for(DataCategory r : res.topCategories){
                    for(DataCategory c : r.childCategories){
                        if(c.Name == qaSettings.Data_Category_Child_Name__c){
                            for(DataCategory ch : c.childCategories){
                                for(Question q : qstnList){
                                    qdcsList.add(new QuestionDataCategorySelection(ParentId=q.Id, DataCategoryName=ch.Name,
                                        DataCategoryGroupName = qaSettings.Data_Category_Group_Name__c));
                                }
                            }
                        }
                    }
                }
            }
        }
        else{
            qdcsList.add(new QuestionDataCategorySelection(ParentId=qstnList[0].Id, DataCategoryName='Steering', DataCategoryGroupName = qaSettings.Data_Category_Group_Name__c));
        }

        insert qdcsList;


    }
}