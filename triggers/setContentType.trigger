trigger setContentType on ContentVersion (before Insert,before update) 
{
    set<id> recTypeId = new set<id>();
    for(ContentVersion cv:Trigger.New)
        recTypeId.add(cv.recordTypeId);
    Map<Id,recordType> maprec = new Map<Id,recordType>([Select id, Name from recordType where Id in :recTypeId]);
    for(ContentVersion cv:Trigger.New)
    {
    	if (cv.Business_Org__c != 'Comatrol')
    	    if(maprec.get(cv.recordTypeId)!=null)
            	cv.Content_Type__c = maprec.get(cv.recordTypeId).Name;
    }
}