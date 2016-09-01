/**=====================================================================
 * Appirio, Inc
 * Name: Test_MultiselectController
 * Description: Test Class for multiselect asset controller class MultiselectController
 * Created Date: [01/08/2016]
 * Created By: [Rajeev Arya] (Appirio)
 *
 * Date Modified                Modified By                  Description of the update

 =====================================================================*/
@isTest
private class Test_MultiselectController{
    static PageReference pageref;
    static MultiselectController con;
    static List<SelectOption> compLeftOptions;
    static List<SelectOption> compRightOptions;
    static List<SelectOption> compAllData;

    /****************************************************************************************************************
    Test Method to test for organizing categories in left and right panel boxes of the multiselect picklist component
    *****************************************************************************************************************/
    static testMethod void MultiselectControllerTestMethod() {
        createTestData();
        pageref = Page.QuestionEdit;
        Test.setCurrentPage(pageref);
        con = new MultiselectController();
        String leftOptHidden = '';
        String rightOptHidden = '';
        
        //assigning controller's SelectOption lists
        con.leftOptions = compLeftOptions;
        con.rightOptions = compRightOptions;
        con.AllDataTo = compAllData;
        
        //populating a string variable to store the values of the left options, as passed in the VF Page
        for(SelectOption s : compLeftOptions){
            leftOptHidden = leftOptHidden  + s.getValue() + '&' + s.getLabel() + '&';
        }
        
        //populating a string variable to store the values of the right options, as passed in the VF Page
        for(SelectOption s : compRightOptions){
            rightOptHidden = rightOptHidden + s.getValue() + '&' + s.getLabel() + '&';
        }
        
        //testing the getter and setter methods for the controller's variables leftOptionsHidden and rightOptionsHidden 
        con.leftOptionsHidden = leftOptHidden ;
        String compLeftOptionsHidden = con.leftOptionsHidden;
        con.rightOptionsHidden = rightOptHidden ;
        String compRightOptionsHidden = con.rightOptionsHidden;

        system.assertEquals(con.leftOptions.isEmpty(), false);
        system.assertEquals(con.rightOptions.isEmpty(), false);
        system.assertEquals(con.AllDataTo.isEmpty(), false);
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

        //initializing list of SelectOption required by the controller
        compLeftOptions= new List<SelectOption>();
        compRightOptions= new List<SelectOption>();
        compAllData= new List<SelectOption>();

        //populating the list of SelectOption required by the controller
        DataCategoryGroupSObjectTypePair pair1 = new DataCategoryGroupSObjectTypePair();
        pair1.dataCategoryGroupName= qaSettings.Data_Category_Group_Name__c;
        pair1.sObject='Question';
        integer counter = 0;
        DescribeDataCategoryGroupStructureResult[] results = Schema.describeDataCategoryGroupStructures(new DataCategoryGroupSObjectTypePair[]{pair1}, false);
        for (DescribeDataCategoryGroupStructureResult res : results){
            for(DataCategory r : res.topCategories){
                for(DataCategory c : r.childCategories){
                    if(c.Name == qaSettings.Data_Category_Child_Name__c){
                        for(DataCategory ch : c.childCategories){
                            compLeftOptions.add(new SelectOption(ch.Name, ch.label));
                            compAllData.add(new SelectOption(ch.Name, ch.label));
                            if(counter<2){
                                compRightOptions.add(new SelectOption(ch.Name, ch.label));
                                counter ++;
                            }
                        }
                    }
                }
            }
        }
    }
}