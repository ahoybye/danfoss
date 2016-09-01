/**=====================================================================
 * Appirio, Inc
 * Name: Test_QuestionEditController
 * Description: Test Class for custom controller QuestionEditController
 * Created Date: [01/07/2016]
 * Created By: [Rajeev Arya] (Appirio)
 *
 * Date Modified                Modified By                  Description of the update

 =====================================================================*/
@isTest
private class Test_QuestionEditController{
    static PageReference pageref;
    static QuestionEditController con;
    static Question questn;

    /************************************************************************************
    Test Method to test for the editing of the Question and it's selected categories
    *************************************************************************************/
    static testMethod void QuestionEditControllerTestMethod1() {
        createTestData();
        pageref = Page.QuestionEdit;
        Test.setCurrentPage(pageref);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(questn);
        con = new QuestionEditController(stdCon);
        list<String> lstExistingCat = new list<string>(con.selectedCatSet);
        system.assertEquals(con.selectedCategories.size(), 1);
        system.assertEquals(con.catOptions.isEmpty(), false);
        system.assertEquals(con.allData.isEmpty(), false);
        system.assertEquals(con.selectedCatSet.isEmpty(), false);
        system.assertEquals(con.qstnCatIds.containsKey(lstExistingCat[0]), true);
        
        //testing the cancel button functionality
        con.cancel();
      
        //Editing the Question and selecting multiple categories
        con.selectedCategories = con.catOptions;
        system.debug('selected are ' + con.selectedCategories);
        con.save();
        List<QuestionDataCategorySelection> dcsInsertedCategories = [select DataCategoryName 
                                from QuestionDataCategorySelection 
                                where ParentId =: con.qstn.Id];
        system.assertEquals(dcsInsertedCategories.size() > 1, true);
        
        //clearing out the selected categories
        con.catOptions.clear();
        for(String existingCat : con.selectedCatset){
            con.catOptions.add(new SelectOption(existingCat, existingCat));
        }
        con.save();
        List<QuestionDataCategorySelection> dcsInsertedCategories1 = [select DataCategoryName 
                                from QuestionDataCategorySelection 
                                where ParentId =: con.qstn.Id];
        system.assertEquals(dcsInsertedCategories1.size() > 1, true);
        
        //Editing the Question without any selected categories
        con.selectedCategories.clear();
        con.save();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals(msgs.size(), 1);

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
        questn = new Question();
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
        system.debug('it is' + qdcsList);
    }
}