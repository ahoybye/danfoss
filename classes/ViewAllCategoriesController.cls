public with sharing class ViewAllCategoriesController {

    public static string commId = '';
    public List<QuestionDataCategorySelection> qDataCategoryList {get;set;}
    public Q_A_Settings__c qaSettings;
    public set<String> setCategoryName {get;set;}
    public map<String, String> mapCategoryNameToParentIds {get;set;}
    public map<String, String> mapCategoryNameToLabel {get;set;}
    //public map<String, List<String>> mapCategoryNameToParentIds {get;set;}
    public map<String, Integer> mapCategoryNameToNoOfQues {get;set;}

    public ViewAllCategoriesController (){
        list<string> lstCategoryName = new list<string>();
        setCategoryName = new set<string>();
        qaSettings = Q_A_Settings__c.getOrgDefaults();
        commId=qaSettings.Zone_Id__c;
        mapCategoryNameToParentIds = new map<String, String>();
        mapCategoryNameToLabel = new map<String, String>();
        //mapCategoryNameToParentIds = new map<String, List<String>>();
        mapCategoryNameToNoOfQues = new map<String, Integer>();
        //get all questions in newest to oldest order
        qDataCategoryList = new List<QuestionDataCategorySelection>();

        DataCategoryGroupSObjectTypePair pair1 = new DataCategoryGroupSObjectTypePair();
        pair1.dataCategoryGroupName=qaSettings.Data_Category_Group_Name__c;
        pair1.sObject='Question';
        DescribeDataCategoryGroupStructureResult[] results = Schema.describeDataCategoryGroupStructures(new DataCategoryGroupSObjectTypePair[]{pair1}, false);
        for (DescribeDataCategoryGroupStructureResult res : results){
            for(DataCategory r : res.topCategories){
                for(DataCategory c : r.childCategories){
                    if(c.Name == qaSettings.Data_Category_Child_Name__c){
                        for(DataCategory ch : c.childCategories){
                            if(!mapCategoryNameToParentIds.containsKey(ch.Name)){
                                system.debug('=== c.Name = ' + ch.Name);
                                //mapCategoryNameToParentIds.put(c.Name, c.Id);
                                lstCategoryName.add(ch.Name);
                                mapCategoryNameToNoOfQues.put(ch.Name,0);
                                mapCategoryNameToParentIds.put(ch.Name, ch.Name);
                                mapCategoryNameToLabel.put(ch.Name, ch.Label);
                            }
                        }
                    }
                }
            }
        }

        for(QuestionDataCategorySelection qDataCategory : [SELECT id, DataCategoryGroupName, DataCategoryName, Parent.Title, ParentId
                         FROM QuestionDataCategorySelection where parent.CommunityId =: commId ]){
            //lstCategoryName.add(qDataCategory.DataCategoryName);
            //if(mapCategoryNameToParentIds.containsKey(qDataCategory.DataCategoryName)){
                //String existingIds = mapCategoryNameToParentIds.get(qDataCategory.DataCategoryName);
                //if(existingIds == ''){
                //   existingIds = qDataCategory.parentid;
                //}
                //else{
                //    existingIds = existingIds + ',' + qDataCategory.parentid;
                //}
                //mapCategoryNameToParentIds.get(qDataCategory.DataCategoryName).(qDataCategory.ParentId);
                //mapCategoryNameToParentIds.put(qDataCategory.DataCategoryName, existingIds);
                mapCategoryNameToNoOfQues.put(qDataCategory.DataCategoryName,
                    mapCategoryNameToNoOfQues.get(qDataCategory.DataCategoryName)+1);
            //}
            //else{
            //   mapCategoryNameToParentIds.put(qDataCategory.DataCategoryName, qDataCategory.parentid);
            //    mapCategoryNameToNoOfQues.put(qDataCategory.DataCategoryName,1);
            //}
        }



        lstCategoryName.sort();
        setCategoryName.addAll(lstCategoryName);
    }

}