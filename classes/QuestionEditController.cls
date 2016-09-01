public with sharing class QuestionEditController {

    public Question qstn {get;set;}
    public List<SelectOption> catOptions {get;set;}
    public List<SelectOption> selectedCategories {get;set;}
    public List<SelectOption> allData {get;set;}
    public Set<String> selectedCatset;
    public Map<String, QuestionDataCategorySelection> qstnCatIds;
    public Q_A_Settings__c qaSettings;

    public QuestionEditController(ApexPages.StandardController controller) {
        qstn = (Question)controller.getRecord();
        qstn = [SELECT Id, Title, Body, Origin,
                      (SELECT DataCategoryGroupName, DataCategoryName, ParentId
                       FROM DataCategorySelections)
                FROM Question
                WHERE Id =: qstn.Id]; 

        qaSettings = Q_A_Settings__c.getOrgDefaults();
        selectedCategories = new List<SelectOption>();
        qstnCatIds = new Map<String, QuestionDataCategorySelection>();
        allData = new List<SelectOption>();
        selectedCatSet = new set<String>();
        for(QuestionDataCategorySelection dcs : qstn.DataCategorySelections){
            selectedCatset.add(dcs.DataCategoryName);
            qstnCatIds.put(dcs.DataCategoryName, dcs);
        }

        catOptions= new List<SelectOption>();
        DataCategoryGroupSObjectTypePair pair1 = new DataCategoryGroupSObjectTypePair();
        pair1.dataCategoryGroupName=qaSettings.Data_Category_Group_Name__c;
        pair1.sObject='Question';
        system.debug('===selectedCatSet = ' + selectedCatSet);
        DescribeDataCategoryGroupStructureResult[] results = Schema.describeDataCategoryGroupStructures(new DataCategoryGroupSObjectTypePair[]{pair1}, false);
        for (DescribeDataCategoryGroupStructureResult res : results){
            for(DataCategory r : res.topCategories){
                for(DataCategory c : r.childCategories){
                    if(c.Name == qaSettings.Data_Category_Child_Name__c){
                        for(DataCategory ch : c.childCategories){
                            system.debug('===ch.Name = ' + ch.Name);
                            system.debug('===ch.Label = ' + ch.Label);
                            if(!selectedCatSet.contains(ch.Name)){
                                catOptions.add(new SelectOption(ch.Name, ch.label));
                            }
                            else{
                                selectedCategories.add(new SelectOption(ch.Name, ch.label));
                            }
                            allData.add(new SelectOption(ch.Name, ch.label));
                        }
                    }
                }
            }
        }
    }

    public PageReference cancel(){
        PageReference pageRef = new PageReference('/apex/QuestionView?id=' + qstn.Id);
        return pageRef;
    }

    public PageReference save(){
        List<QuestionDataCategorySelection> dcsListToInsert = new List<QuestionDataCategorySelection>();
        List<QuestionDataCategorySelection> dcsListToDelete = new List<QuestionDataCategorySelection>();

        if(selectedCategories.size() < 1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one Category from the list'));
            return null;
        }
        
        system.debug('qstn: ' + qstn);
        //qstn.Title = (String)Question.Title;
        //qstn.Body = (String)Question.Body;

        update qstn;

        //system.debug('set is:' + selectedCatSet + ' : selected categories are : ' + selectedCategories);
        for(SelectOption s : selectedCategories){
            if(!selectedCatSet.contains(s.getValue())){
                dcsListToInsert.add(new QuestionDataCategorySelection(DataCategoryName=s.getValue(), ParentId = qstn.Id, DataCategoryGroupName=qaSettings.Data_Category_Group_Name__c));
            }
        }

        for(SelectOption s : catOptions){
            if(selectedCatSet.contains(s.getValue())){
                dcsListToDelete.add(qstnCatIds.get(s.getValue()));
            }
        }

        if(dcsListToInsert.size() > 0){
            insert dcsListToInsert;
        }
        if(dcsListToDelete.size() > 0){
            delete dcsListToDelete;
        }

        PageReference pageRef = new PageReference('/apex/QuestionView?id=' + qstn.Id);
        return pageRef;
    }

}