public class QuoteBusiness {

    
    public static Opportunity createShadowOpportunity (string name, Id accountId, string currencyCode, string currentUserid, id pb2Id) {
        Opportunity o = new Opportunity();                
        o.AccountId = accountId;  
		if (currentUserid!=null) {
        	o.ownerId = currentUserid;
			//o.CreatedById = currentUserid;
		}
                    
        o.name = name.left(120);
        o.CE_Phase__c = 'Qualification';
        o.CE_Status__c = 'Lost';
        o.Reason__c = 'No Follow-up';
        o.StageName='Closed-Lost';
        o.CloseDate=Date.today();
        o.CurrencyIsoCode=currencyCode;
		// CE_Opportunity
		o.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND developername='Shadow_Opportunity' LIMIT 1].Id;
                    
                    
        //o.RecordTypeId = RestQuoteController.getRecordTypeId(Opportunity.SObjectType, 'CE_Opportunity');
        o.Pricebook2Id=pb2Id;
        o.Amount=0;
        
        return o;
    }
    
    public static quote deepCloneQuote (quote q, boolean deleteOriginalQuote) {
		// build query string for all quote fields
        string query = getSelectAllQuery('Quote');           	
        query = (query + ' WHERE id=\'' + q.id + '\'');             
        Quote sourceQ = Database.query(query);
        //clone(Boolean preserveId, Boolean isDeepClone, Boolean preserveReadonlyTimestamps, Boolean preserveAutonumber)
        Quote targetQ = sourceQ.clone(false, true, true, true);
        targetQ.opportunityId=q.opportunity__c;
        targetQ.opportunity__c=null;        
        if (sourceQ.Cloned_Quote_Number__c!=null)  {
        	targetQ.Cloned_Quote_Number__c=sourceQ.Cloned_Quote_Number__c;    
		} else {
        	targetQ.Cloned_Quote_Number__c=sourceQ.QuoteNumber;
		}            
            
        sourceQ.configitQuoteId__c=null;
        sourceQ.opportunity__c =null;
        sourceQ.SAP_Quote_ID__c=null;
        update sourceQ;
            
        targetQ.name = targetQ.name;
        insert targetQ;
            
            
        // clone related data (quotelineitems)
        query = getSelectAllQuery('QuoteLineItem');
        //query=('SELECT id' + query);
        query = (query + ' WHERE quoteid=\'' + q.id + '\''); 
            
        List<quotelineitem> newItems = new List<quotelineitem>();
        List<quotelineitem> existingItems = Database.query(query);
        for (quotelineitem qli : existingItems) {
       		quotelineitem newqli = qli.clone(false);
            qli.ConfigitQuoteLineId__c=null;
            
			newqli.QuoteId = targetQ.id;
            newItems.add(newqli);
        }
        update existingItems;
        insert newItems;
            
        // insert quote attachments
        List<attachment> la = new List<attachment>();
        for (attachment a: [SELECT id, name, description, body, ContentType, bodyLength, LastModifiedDate, CreatedDate, parentid from attachment where parentid=:q.Id limit 50]) {
        	attachment na = a.clone();
            na.parentId=targetQ.Id;
            la.add(na);
        }
        insert la;
            
        if (deleteOriginalQuote) {
        	// cleanup and delete the original quote
        	delete sourceQ;            
        }
        
        return  targetQ;
        
    }
    
    public static String getSelectAllQuery(string sObjectName) {
    	// get all quote fields
        string qfields='SELECT id';
        //List<string> lstQuoteFields = new List<string>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
       	Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();
		for(Schema.SObjectField sfield : fieldMap.Values())
		{
			schema.describefieldresult dfield = sfield.getDescribe();
			
			string fieldname = dfield.getname();
            if (!fieldname.equalsIgnoreCase('id')) {
                qfields = (qfields + ',' + fieldname);                                	
            }
            //lstQuoteFields.add(fieldname);			
		}
        qfields = (qfields + ' FROM ' + sObjectName);
        return qfields;
    }     
}