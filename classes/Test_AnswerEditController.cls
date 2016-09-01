/**=====================================================================
 * Appirio, Inc
 * Name: Test_AnswerEditController
 * Description: Test Class for custom controller AnswerEditController
 * Created Date: [01/07/2016]
 * Created By: [Rajeev Arya] (Appirio)
 *
 * Date Modified                Modified By                  Description of the update

 =====================================================================*/
@isTest
private class Test_AnswerEditController{
    static PageReference pageref;
    static AnswerEditController con;
    static Reply answ;

    /****************************************
    Test Method to test for editing an answer
    *****************************************/
    static testMethod void AnswerEditControllerTestMethod1() {
        createTestData();
        pageref = Page.AnswerEdit;
        Test.setCurrentPage(pageref);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(answ);
        con = new AnswerEditController(stdCon);
        system.assertNotEquals(con.ans.Id, null);
        
        //testing the cancel button functionality
        PageReference cancelPageRef = con.cancel();
        system.assertEquals(cancelPageRef.getURL(), (new PageReference('/apex/QuestionView?id=' + con.ans.QuestionId)).getURL());
        
        //testing the save button functionality of updating an answer
        con.ans.Body = 'testing the answer';
        PageReference savePageRef = con.save();
        system.assertEquals(savePageRef.getURL(), (new PageReference('/apex/QuestionView?id=' + con.ans.QuestionId)).getURL());
        system.assertEquals([select body from Reply where id =: con.ans.Id limit 1][0].body, 'testing the answer');
    }
    
    /********************************************
    Method to create test data for the controller
    *********************************************/
    private static void createTestData(){
        
        //Creating record for the custom setting 'Q&A Settings'
        Q_A_Settings__c qaSettings = Q_A_Settings__c.getOrgDefaults();
        qaSettings.Data_Category_Child_Name__c = 'Power_Solutions';
        qaSettings.Data_Category_Group_Name__c = 'Product_Support';
        qaSettings.Zone_Id__c = '09aC000000017uX';
        qaSettings.Page_Size__c = 2;
        insert qaSettings;
        
        //Inserting the question record with all the required fields to be used by the controller
        Question questn = new Question();
        questn.Title = 'This is the test Question title';
        questn.Body = 'This is the test Question Body';
        questn.CommunityId=qaSettings.Zone_Id__c;
        insert questn;

        List<QuestionDataCategorySelection> qdcsList = new List<QuestionDataCategorySelection>();
        DataCategoryGroupSObjectTypePair pair1 = new DataCategoryGroupSObjectTypePair();
        pair1.dataCategoryGroupName=qaSettings.Data_Category_Group_Name__c;
        pair1.sObject='Question';
        DescribeDataCategoryGroupStructureResult[] results = Schema.describeDataCategoryGroupStructures(new DataCategoryGroupSObjectTypePair[]{pair1}, false);
        for (DescribeDataCategoryGroupStructureResult res : results){
            for(DataCategory r : res.topCategories){
                for(DataCategory c : r.childCategories){
                    if(c.Name == qaSettings.Data_Category_Child_Name__c){
                        qdcsList.add(new QuestionDataCategorySelection(ParentId=questn.Id, DataCategoryName=c.childCategories[0].Name,
                                DataCategoryGroupName = qaSettings.Data_Category_Group_Name__c));
                    }
                }
            }
        }
        insert qdcsList;
        
        //inserting an answer for the inserted question
        answ = new Reply(Body='test answer ' + questn.Title, QuestionId=questn.Id);
        insert answ;
      
    }
}