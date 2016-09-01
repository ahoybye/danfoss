/**=====================================================================
 * Appirio, Inc
 * Name: Test_QuestionAskController
 * Description: Test Class for custom controller QuestionAskController
 * Created Date: [01/07/2016]
 * Created By: [Rajeev Arya] (Appirio)
 *
 * Date Modified                Modified By                  Description of the update

 =====================================================================*/
@isTest
private class Test_QuestionAskController{
    static PageReference pageref;
    static QuestionAskController con;
    static Question questn;

    /************************************************************************************
    Test Method to test for the creation of the new Question and it's selected categories
    *************************************************************************************/
    static testMethod void QuestionAskControllerTestMethod1() {
        createTestData();
        pageref = Page.QuestionAsk;
        Test.setCurrentPage(pageref);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(questn);
        con = new QuestionAskController(stdCon);
        system.assertEquals(con.qstn.Origin, 'Chatter Answers');
        system.assertEquals(con.qstn.CommunityId, '09aC000000017uX');
        system.assertEquals(con.catOptions.isEmpty(), false);
        system.assertEquals(con.allData.isEmpty(), false);

        //Creating a Question without any selected categories
        con.save();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals(msgs.size(), 1);

        //Creating a Question after selecting the categories
        con.selectedCategories = con.catOptions;
        con.save();
        system.assertNotEquals(con.qstn.Id, null);
        List<QuestionDataCategorySelection> dcsInsertedCategories = [select DataCategoryName 
                                from QuestionDataCategorySelection 
                                where ParentId =: con.qstn.Id];
        system.assertEquals(dcsInsertedCategories.isEmpty(), false);
   
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
        
        //Creating the question record with title and body to be used by the controller
        questn = new Question();
        questn.Title = 'This is the test Question title';
        questn.Body = 'This is the test Question Body';

    }
}