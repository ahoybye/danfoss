/**
Test class to provide test coverage to autoCompleteController.cls
 */
@isTest
private class autoCompleteController_Test {

    static testMethod void testAutocomplete() {
        Community comm = [select Id from Community limit 1];
        
        Question q= new Question(Title= 'Test Question', CommunityId = comm.Id);
        insert q;
        QuestionDataCategorySelection qdcs = new QuestionDataCategorySelection(ParentId = q.Id, DataCategoryName = 'Valves', DataCategoryGroupName = 'Product_Support');
        insert qdcs;
        
        Test.startTest();
        
            List<Question> listQuestion = (List<Question>) autoCompleteController.findSObjects('NullObject', 'Test', '');
            listQuestion = (List<Question>) autoCompleteController.findSObjects('Question', 'Test', 'Origin');
            List<QuestionDataCategorySelection> listQDCS = (List<QuestionDataCategorySelection>) autoCompleteController.findSObjects('QuestionDataCategorySelection', 'Test', 'Origin');
            System.assert(listQuestion != null, 'Should return one record');    
            System.assert(listQuestion[0].Title == 'Test Question', 'Question Title should contains "test"');
            
        Test.stopTest();
    }
}