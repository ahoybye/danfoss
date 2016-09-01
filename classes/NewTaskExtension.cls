/*
 * Overrides the standard new task action, and redirects to the standard new task page.
 * On desktop this page sets default field values using URL hacks.
 * On mobile these are not set, since URL hacks are not supported.
 */
public class NewTaskExtension {
    
    private PageReference taskURL;
    Private Id recTypeId, tskRecTypeId;
        
    public NewTaskExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String> {'WhoId', 'WhatId'});
        }
        Task task = (Task) controller.getRecord();
        
        User usr = [select Business_Org__c, Division__c from User where Id = :UserInfo.getUserId()];
        
        taskURL = new PageReference('/00T/e?nooverride=1&ent=Task');
        taskURL.getParameters().put('retURL', controller.cancel().getUrl());
        //Added branch for setting the URL for Climate & Energy, which uses Division
        taskURL.getParameters().put('what_id', task.WhatId);
        
        if (usr.Business_Org__c == 'Climate and Energy') {
            //DEFECT 230 - add in the contact from the opportunity
            if (task.WhatId != null && task.WhatId.getSObjectType() == Opportunity.sObjectType) {
                task.WhoId = [select Contact__c from Opportunity where Id = :task.WhatId].Contact__c;
            }
            
           recTypeId = [select Id from RecordType where DeveloperName = 'C_E_Task' and SobjectType = 'Task'].Id; 

            taskURL.getParameters().put('RecordType', recTypeId);
            taskURL.getParameters().put(FieldID__c.getOrgDefaults().ActivityDivision__c, usr.Division__c);
            taskURL.getParameters().put(FieldID__c.getOrgDefaults().ActivityType__c, 'Communication');
            //note 3rd Feb : added parameter to preset the diviions of the follow up task for log a call: necessary for log a call
            taskURL.getParameters().put(FieldID__c.getOrgDefaults().CallDivision__c, usr.Division__c);
        }
        
        taskURL.getParameters().put('who_id', task.WhoId);
      //note 3rd Feb : added parameters necessary for log a call
        taskURL.getParameters().put('title', ApexPages.currentPage().getParameters().get('title'));
        taskURL.getParameters().put('tsk5', ApexPages.currentPage().getParameters().get('tsk5'));
        taskURL.getParameters().put('followup', ApexPages.currentPage().getParameters().get('followup'));
        
    }
    
    public String gettaskURL() {
        return taskURL.getUrl();
    }
    
    public String getRecTypeId() {
        Schema.DescribeSObjectResult describeTask = Schema.SObjectType.Task;    
        List<Schema.RecordTypeInfo> rtInfos = describeTask.getRecordTypeInfos();
          for(Schema.RecordTypeInfo rtInfo : rtInfos) {
        if(rtInfo.isDefaultRecordTypeMapping()) {               
            tskRecTypeId = rtInfo.getRecordTypeId();
            break;
         }
       }

        return tskRecTypeId;
    }

    
}