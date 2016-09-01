/**=====================================================================
 * Appirio, Inc
 * Name: Test_ViewAllCategoriesController
 * Description: Test Class for custom controller ViewAllCategoriesController
 * Created Date: [01/07/2016]
 * Created By: [Rajeev Arya] (Appirio)
 *
 * Date Modified                Modified By                  Description of the update

 =====================================================================*/
@isTest
private class Test_ViewAllCategoriesController{
    static PageReference pageref;
    static ViewAllCategoriesController con;
    static Reply answ;

    /****************************************
    Test Method to test for existence of all categories
    *****************************************/
    static testMethod void ViewAllCategoriesControllerTestMethod1() {
        createTestData();
        pageref = Page.ViewAllCategories;
        Test.setCurrentPage(pageref);
        con = new ViewAllCategoriesController();
        
        system.assertEquals(con.setCategoryName.isEmpty(), false);
        system.assertEquals(con.mapCategoryNameToNoOfQues.isEmpty(), false);
        system.assertEquals(con.mapCategoryNameToParentIds.isEmpty(), false);
        system.assertEquals(con.mapCategoryNameToNoOfQues.keySet().size(), con.setCategoryName.size());
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

        //inserting data category records for the inserted question
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
    }
}