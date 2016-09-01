public with sharing class CEQuoteCloneController {
	Id objId;
    Quote q;
    public CEQuoteCloneController (ApexPages.StandardController stdController) {
		stdController.addFields(new List<String>{'OpportunityId', 'Opportunity__c'});  		
        q = (Quote)stdController.getRecord();
        objId = stdController.getId();
        q.opportunity__c=q.OpportunityId;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.QuoteCloneWarning));
    }

    public PageReference cloneQuote () {
        if (q.OpportunityId==q.opportunity__c)   {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have to select another opportunity'));
             return null;
            
        } else {
            try {
            	Quote clonedQuote = QuoteBusiness.deepCloneQuote(q, true);            
            	return new PageReference('/' + clonedQuote.Id);    
            } catch (exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                return null;
            }
                        
        }
        
    }
    
    public PageReference cancel () {        
             return new PageReference('/' + q.Id);
    }
	    
       
}