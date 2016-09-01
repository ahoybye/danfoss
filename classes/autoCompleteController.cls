global class autoCompleteController {
    
    @RemoteAction
    global static SObject[] findSObjects(string obj, string qry, string addFields) {
        // more than one field can be passed in the addFields parameter
        // split it into an array for later use
        List<String> fieldList;
        if (String.isNotBlank(addFields)) fieldList = addFields.split(',');
       // check to see if the object passed is valid
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        // create the filter text
        String filter = ' like \'%' + String.escapeSingleQuotes(qry) + '%\'';
        //begin building the dynamic soql query
        String soql;
        if(obj == 'QuestionDataCategorySelection')
            soql = 'select id, DataCategoryName';
        else
            soql = 'select id, title';
        // if an additional field was passed in add it to the soql
        if (fieldList != null) {
            for (String s : fieldList) {
                soql += ', ' + s;
            }
        }
        // add the object and filter by name to the soql
        if(obj == 'QuestionDataCategorySelection')
            soql += ' from ' + obj + ' where DataCategoryName' + filter;
        else
            soql += ' from ' + obj + ' where title' + filter;
        // add the filter by additional fields to the soql
        if (fieldList != null) {
            for (String s : fieldList) {
                soql += ' or ' + s + filter;
            }
        }
        if(obj == 'QuestionDataCategorySelection')
            soql += ' order by DataCategoryName limit 20';    
        else
            soql += ' order by title limit 20';
        List<sObject> L = new List<sObject>();
        try {
            L = Database.query(soql);
        }
        catch (QueryException e) {
            return null;
        }
        return L;
   }
}