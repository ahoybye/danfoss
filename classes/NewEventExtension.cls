/*
 * Overrides the standard new event action, and redirects to the standard new event page.
 * On desktop this page sets default field values using URL hacks.
 * On mobile these are not set, since URL hacks are not supported.
 */
public class NewEventExtension {
    
    private PageReference eventURL;
    
    public NewEventExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String> {'WhoId', 'WhatId'});
        }
        Event event = (Event) controller.getRecord();
        
        User usr = [select Business_Org__c, Division__c from User where Id = :UserInfo.getUserId()];
        
        eventURL = new PageReference('/00U/e?nooverride=1&ent=Event');
        eventURL.getParameters().put('retURL', controller.cancel().getUrl());
        //Added branch for setting the URL for Climate & Energy, which uses Division
        eventURL.getParameters().put('what_id', event.WhatId);
        
        if (usr.Business_Org__c == 'Climate and Energy') {
            //DEFECT 230 - add in the contact from the opportunity
            if (event.WhatId != null && event.WhatId.getSObjectType() == Opportunity.sObjectType) {
                event.WhoId = [select Contact__c from Opportunity where Id = :event.WhatId].Contact__c;
            }
            eventURL.getParameters().put('RecordType', [select Id from RecordType where DeveloperName = 'C_E_Event' and SobjectType = 'Event'].Id);
            eventURL.getParameters().put(FieldID__c.getOrgDefaults().ActivityDivision__c, usr.Division__c);
        }
        
        eventURL.getParameters().put('who_id', event.WhoId);
        
    }
    
    public String geteventURL() {
        return eventURL.getUrl();
    }
    
}