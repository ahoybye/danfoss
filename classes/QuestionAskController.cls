public with sharing class QuestionAskController {

    public Question qstn {get;set;}
    public List<SelectOption> catOptions {get;set;}
    public Q_A_Settings__c qaSettings;
    public List<SelectOption> selectedCategories {get;set;}
    public List<SelectOption> allData {get;set;}
    
    public QuestionAskController(ApexPages.StandardController controller) {
        selectedCategories = new List<SelectOption>();
        allData = new List<SelectOption>();
        qaSettings = Q_A_Settings__c.getOrgDefaults();
        qstn = (Question)controller.getRecord();
        qstn.Origin = 'Chatter Answers';
        qstn.CommunityId = qaSettings.Zone_Id__c;

        catOptions= new List<SelectOption>();
        DataCategoryGroupSObjectTypePair pair1 = new DataCategoryGroupSObjectTypePair();
        pair1.dataCategoryGroupName= qaSettings.Data_Category_Group_Name__c;
        pair1.sObject='Question';
        DescribeDataCategoryGroupStructureResult[] results = Schema.describeDataCategoryGroupStructures(new DataCategoryGroupSObjectTypePair[]{pair1}, false);
        for (DescribeDataCategoryGroupStructureResult res : results){
            for(DataCategory r : res.topCategories){
                for(DataCategory c : r.childCategories){
                    if(c.Name == qaSettings.Data_Category_Child_Name__c){
                        for(DataCategory ch : c.childCategories){
                            catOptions.add(new SelectOption(ch.Name, ch.label));
                            allData.add(new SelectOption(ch.Name, ch.label));
                        }
                    }
                }
            }
        }
    }

    public PageReference save(){
        //check if value is added for all fields - March 14, 2016 - Himshikha Agrawa - T-481166
        if(qstn.Title == null || qstn.Title == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Question Title'));
            return null;
        } else if(qstn.Body == null || qstn.Body == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Question Body'));
            return null;
        } else if(selectedCategories.size() < 1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one Category from the list'));
            return null;
        }
        insert qstn;

        List<QuestionDataCategorySelection> dcsListToInsert = new List<QuestionDataCategorySelection>();
        for(SelectOption s : selectedCategories){
            dcsListToInsert.add(new QuestionDataCategorySelection(DataCategoryName=s.getValue(), ParentId = qstn.Id, DataCategoryGroupName=qaSettings.Data_Category_Group_Name__c));
        }

        if(!dcsListToInsert.isEmpty()){
            insert dcsListToInsert;
        }

        PageReference pageRef = new PageReference('/apex/QuestionView?id=' + qstn.Id);
        return pageRef;
    }
    
    //cancel ask new question - March 14, 2016 - Himshikha Agrawal - T-481166
    public PageReference cancel(){
        return new PageReference('/apex/QuestionAndAnswer');
    }

}