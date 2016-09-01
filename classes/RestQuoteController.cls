@RestResource(urlMapping='/RestInterfaceQuote/*')
global with sharing class RestQuoteController {
    
    @HttpGet
	global static serviceResult getQuoteData() {
        RestContext.response.addHeader('Content-Type', 'text/plain');
         
        serviceResult result =  new serviceResult();
        String configitQuoteId = RestContext.request.params.get('configitQuoteId');
         
        try {
         	// Get the configitQuoteId from the parameterlist in the REST call         	
            Quote q=[SELECT Id, Name, ConfigitQuoteId__c, Status, QuoteNumber, ConfigitQuoteRef__c, ConfigitQuoteRev__c, opportunityId FROM Quote WHERE ConfigitQuoteId__c=:configitQuoteId LIMIT 1];
            result.status='OK';
        	result.message='';
               
            result.return_url = URL.getSalesforceBaseUrl().toExternalForm() + '/' + q.id;            
            result.quote = q;
            
        } catch (Exception ex) {
        	result.status='ERROR';
        	result.message='Unable to find quote (' + ConfigitQuoteId + ')';
        }        
        
        return result;
                 
    }
    
    @HttpPost   
    global static serviceResult createQuote(String configitQuoteId, String configitQuoteRev, String configitQuickRefId, String quoteName, String accountId, String opportunityId, String contactId, String sapAccountId, String sapQuoteId, String salesOrg, String distribChannel, String salesDivision, String currencyCode, Date validFrom, Date validTo, Date priceValidFrom, Date priceValidTo, Date customerRequestDate, String customerRequestNumber, string userId, String sapDocNum, List<QLI> quoteLineItems) {
        serviceResult result =  new serviceResult();
        result.message='';
        result.status='OK';
        boolean createQuote=false;
        boolean firstSync = false;
        boolean newOpportunity = false;
                
        Quote q;
        Opportunity o;
        Associated_Account__c stakeholderMapping;
        Id currentUserid=null;
        Id pb2Id;
        Id stakeholderMappingId=null;
        Id SubAccountId=null;
        try {

            try {
                pb2Id=[SELECT Id FROM Pricebook2 WHERE Name='Climate and Energy'].Id;
            } catch  (exception ex) {
                result.status='ERROR';
                result.message='Unable to find Pricebook "Climate and Energy"';
                return result;
            }            
            
            // Check if the opportunity is a stakeholder mapping reference
            try {            
                stakeholderMapping=[SELECT Id, Project_Opportunity__c FROM Associated_Account__c WHERE Id=:opportunityId];
                stakeholderMappingId=opportunityId;
                opportunityId = stakeholderMapping.Project_Opportunity__c;                
                
            } catch (exception e) {
                
            }
            
            // Get the current user - based on current user in Configit
            try {
                if (userId!=null && userId!='') {
                    User u = [SELECT Id FROM user WHERE User_ID__c=:userId and IsActive=true limit 1];                
                    if (u!=null) {
                        currentUserid = u.Id;    
                    }
                }
            } catch (exception ex) {
                
            }
            
            try {            
                q=[SELECT Id, ConfigitQuoteId__c, opportunityId, status, ConfigitQuoteRev__c FROM quote WHERE ConfigitQuoteId__c=:configitQuoteId];
                opportunityId = q.OpportunityId;                
            } catch (exception e) {
                // If the quote does not exist 
                // and no opportunity id is passed from configit
                // then create a new (shadow) opportunity
                createQuote = true;
                firstSync = true;
                // Quote was initiated without an opportunity - so create the new shadow opportunity 
                if (opportunityId == '') { 
                    // if creating a shadow opportunity - update the oppty + quote name
                    //quoteName = 'Price Request ' + quoteName;
                    newOpportunity=true;
                    o = QuoteBusiness.createShadowOpportunity('Price Request ' + quoteName, accountId,currencyCode,currentUserid,pb2Id);
                    System.debug('$$ Insert new shadow oppty: ' + o);
                                        
                } 
            }
            if (o == null) {
                o = [SELECT Id, accountId, name, Originating_Case__c, currencyISOCode FROM Opportunity WHERE id=:opportunityId LIMIT 1];
                //currencyCode = o.CurrencyIsoCode;
                o.CurrencyIsoCode = currencyCode;
            }
            
            String salesArea;
            if (!firstSync) {
                try {                   
                    salesArea= salesOrg.rightPad(4, '0') + '-' + distribChannel.leftPad(2, '0') + '-' + salesDivision.leftPad(2, '0');
                    Sales_Area__c sa = [SELECT Id, Sub_Account__c, account__c, Sub_Account__r.account__c FROM Sales_Area__c WHERE SAP_Account_ID__c=:sapAccountId AND Sales_Area__c=:salesArea];
                    SubAccountId = sa.Sub_Account__c;
                    if (sa.Sub_Account__r.account__c == o.AccountId) {  // We shouldn't change the sub account to be from another account
                        o.Sub_Account__c = sa.Sub_Account__c;
                        o.Sales_Area__c = sa.Id;
                                               
                        /* - DO NOT UPDATE STAKEHOLDER -
                        if (stakeholderMapping!=null) {
                            try { 
                            	stakeholderMapping.Associated_Account__c = AccountId;
                            	stakeholderMapping.SubAccount__c = sa.Sub_Account__c;
								upsert stakeholderMapping;
                            } catch (exception ex) {
                                result.status='Warning';
                				result.message='Not possible to update stakeholder mapping ' + ex.getMessage();
                            }
                                
                        }
						*/
                    }                                        
                } catch (exception ex) {                    
                    result.status='OK';
                    result.message='Unable to find Sales Area (' + salesArea + ') for SAP# ' + sapAccountId;
                    //return result;
                }
                				                
                // only update contact to the opportunity - if it is related to an opportunity
                if (accountId == o.AccountId && contactId!=null && contactId!='') {
                    o.Contact__c=contactId;
                }
                
            }
            
            // Create/update opportunity
            try {    
                
                upsert o;
                opportunityId = o.Id;                                   
                
                
            } catch (exception ex) {
                result.status='ERROR'; // to be changed to Warning
                result.message='Unable create/update opportunity ' + ex.getMessage() + ' ' + o ;
                return result;
            }
            try {
                // Create stakeholder mapping - if the opportunity is just created            
                if (newOpportunity) {				
                    Associated_Account__c aa = new Associated_Account__c(
                        Associated_Account__c = o.AccountId,
                        Contact__c = o.Contact__c,
                        Project_Opportunity__c = o.Id,
                        Type_of_Association__c = 'Main Account');
                    insert aa;
                } else {
                    if (o.AccountId == accountId) {
                        List<Associated_Account__c> aaList = [SELECT Id, Contact__c, Associated_Account__c, Type_of_Association__c FROM Associated_Account__c WHERE Associated_Account__c=:o.AccountId AND Project_Opportunity__c=:o.Id];
                        
                        if (aaList.size()==0) {  // No mapping exists - create new mapping
                            Associated_Account__c aa = new Associated_Account__c(
                                Associated_Account__c = o.AccountId,
                                Contact__c = o.Contact__c,
                                Project_Opportunity__c = o.Id,
                                Type_of_Association__c = 'Main Account');
                            insert aa;
                        } else if (aaList.size()==1) {
                            Associated_Account__c aa = aaList[0];
                            aa.Contact__c = o.Contact__c;
                            aa.SubAccount__c = o.Sub_Account__c;
                            aa.Type_of_Association__c = 'Main Account';
                            update aa;    
                        }                                        	
                    }				                
                }
            } catch (exception ex) {
                result.status='WARNING'; // to be changed to Warning
                result.message='Unable create/update stakeholder record ' + ex.getMessage();
                //return result;
            }
            
            if (createQuote) {
                q = new Quote(ConfigitQuoteId__c = configitQuoteId, OpportunityId=opportunityId, Status='In Progress');
                q.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Quote' AND developername='CE_Quote' LIMIT 1].Id;
                if (currentUserid!=null)  {
                	q.CreatedBy_Configit__c = currentUserid;
                    q.CreatedDate_Configit__c = System.now();
                    q.Responsible__c = currentUserid;
                }
            }
            
            // Warn if user is overwritting a sent quote without creating a new revision
            if (q.Status=='Sent' && configitQuoteRev == q.ConfigitQuoteRev__c && (sapDocNum==null || sapDocNum=='')) {
                result.status='Warning';
                result.message += 'You are updating a sent quote in Salesforce. Please create a new revision before syncing to Salesforce.\n';
                result.return_url = URL.getSalesforceBaseUrl().toExternalForm() + '/' + q.id;
                return result;
            } else if (q.Status=='Sent' && configitQuoteRev != q.ConfigitQuoteRev__c) {
                q.Status='In Progress';
            }
            
            q.ConfigitQuoteRev__c = configitQuoteRev;
            q.ConfigitQuoteRef__c = configitQuickRefId;
            q.Valid_From__c = ValidFrom;
            q.Valid_To__c = ValidTo; 
            q.ExpirationDate = ValidTo; 
            // Added December 14 2015 - Allan Hoybye
            q.Price_Valid_From__c = priceValidFrom;                
            q.Price_Valid_To__c = priceValidTo;    
            q.Customer_Request_Date__c = customerRequestDate;    
			// Added February 23 2016 - Allan Hoybye
            q.ConfigitSyncMessage__c = 'OK';            
            if (!String.isEmpty(customerRequestNumber) && customerRequestNumber.length()>255) {
                result.status='Warning';
                result.message += 'The Customer Request Number is longer than the allowed 250 characters - value truncated.\n';
                q.RFQ_Number__c = customerRequestNumber.left(255); 
            } else {
                q.RFQ_Number__c = customerRequestNumber; 
            }
            
            // Added July 20 2016 - Allan Hoybye
            q.External_Sales_Org__c = salesOrg;
            
            if (sapDocNum != null) {            
            	q.SAP_Quote_ID__c = sapDocNum;
                if (sapDocNum.length()>1)  {
                	q.Status='Accepted';    
                }                
            }
                
            if (o.Originating_Case__c!=null) {
            	q.Originating_Case__c=o.Originating_Case__c;          
            }
            
            //q.Stakeholder__c = stakeholderMappingId;
            q.Name= quoteName.left(250);
            if (contactId!=null && contactId!='') {
                q.ContactId=contactId;
            }
            q.Custom_Account_Lookup__c=accountId;
            q.Sub_Account__c = SubAccountId;
            //q.CurrencyIsoCode=currencyCode; -- not writeable
            q.Pricebook2Id = pb2Id;
            
            if (currentUserid!=null)  {
            	q.Last_ModifiedBy_Configit__c = currentUserid;				
            } else {
                q.Last_ModifiedBy_Configit__c = null;
            }
            q.Last_ModifiedDate_Configit__c = System.now();
            // Create/update quote
            try {                
                upsert q;
                
            } catch (exception ex) {
                result.status='ERROR';
                result.message='Unable create/update quote ' + ex.getMessage() + ' ' + q ;
                return result;
            }
            
            result.return_url = URL.getSalesforceBaseUrl().toExternalForm() + '/' + q.id;
            
            result.quote=[SELECT Id, Name, ConfigitQuoteId__c, Status, QuoteNumber, ConfigitQuoteRef__c, ConfigitQuoteRev__c FROM Quote WHERE Id=:q.Id LIMIT 1];
            List<QuoteLineItem> qliList = [SELECT Id FROM QuoteLineItem WHERE QuoteId=:q.Id];
            
            if (qliList.size()>0) {
            	delete qliList;
            
            	//List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            	qliList.clear();
            } else {
                qliList = new List<QuoteLineItem>();
            }
            boolean containsAltOptMaterials = false;
            integer i = 1;
            Set<string> materialIDs = new Set<string>();            
            for (QLI cqli : quoteLineItems ) {
                materialIDs.add(cqli.materialID);
            }
            
            // Get all pricebook entries for the selected currency (method parameter)
            List<PricebookEntry> PBEs = [SELECT Id, Product2.SAP_Material_Code_CE__c FROM PricebookEntry WHERE Pricebook2Id=:pb2Id and Product2.SAP_Material_Code_CE__c IN :materialIDs and CurrencyIsoCode=:currencyCode];
            Map<String, Id> pbeMap = new Map<String, Id>();
            // put all pb entries into map - for use when creating quote line items
            for (PricebookEntry pbe : PBEs) {
            	  pbeMap.put(pbe.Product2.SAP_Material_Code_CE__c, pbe.Id);
            }
            
            for (QLI cqli : quoteLineItems ) {
                string test;
                
                if (String.isEmpty(cqli.optAltStatus) || cqli.optAltStatus.equalsIgnoreCase('standard') ) {
                	//QuoteLineItem qli = new QuoteLineItem(ConfigitQuoteLineId__c = cqli.configitLineId);
                	QuoteLineItem qli = new QuoteLineItem();
                    //qli.sortOrder=cqli.sortOrder;
                    //qli.CurrencyIsoCode=cqli.currencyCode;
                    qli.ConfigitQuoteLineId__c = cqli.configitLineId;
                    qli.UnitPrice = cqli.unitPrice;
                    qli.Description = cqli.description;
                    qli.Discount  = cqli.discount;
                    qli.Quantity = cqli.quantity;
                    qli.QuoteId = q.Id;
                    
                	//Id pId=[SELECT Id FROM Product2 WHERE SAP_Material_Code_CE__c=:cqli.materialID].Id;
                	try {
                        // Id pbeId=[SELECT Id FROM PricebookEntry WHERE Pricebook2Id=:pb2Id and Product2.SAP_Material_Code_CE__c=:cqli.materialID and CurrencyIsoCode=:currencyCode].Id;
                        if (pbeMap.containsKey(cqli.materialID)) {
                        	qli.PricebookEntryId=pbeMap.get(cqli.materialID);
                    		qliList.add(qli);
                        } else {
                            result.status='Warning';   // to be changed to Warning                                     
                    		result.message += 'Invalid material code or currency for ' + cqli.description + ' (material Id: ' + cqli.materialID + ')\n';
                        }
                    	//qli.Product2Id = pId;
                    	
                	} catch (exception e) {  // might not be needed - after putting it into a map              
                    	result.status='Warning';   // to be changed to Warning                                     
                    	result.message += 'Invalid material code or currency for ' + cqli.description + ' (material Id: ' + cqli.materialID + ')\n';
                    	//return result;
                	}    
                } else {
                    containsAltOptMaterials = true;
                }
            }
            //Schema.SObjectField f = QuoteLineItem.ConfigitQuoteLineId__c;
            //Database.UpsertResult [] cr = Database.upsert(qliList, f, false);
            //for (Database.UpsertResult ur : cr) {
            //	system.debug('$$ ' +  ur);
            //}
            insert qliList;
            
            // Added February 23 2016 - Allan Hoybye
            if (result.status.equals('Warning')) {
                q.ConfigitSyncMessage__c=result.message.left(255);
                update q;
            } else if (containsAltOptMaterials) {
                q.ConfigitSyncMessage__c='The quote contains optional or alternative materials. See print or Configit for details.';
                update q;
            }
            
            //result.message='';
            return result;
        } catch (exception fallbackEx) {
            result.status='ERROR';
            result.message='Unexpected Error: ' + fallbackEx.GetMessage() + '\n' + fallbackEx.getStackTraceString();
            result.quote=q;
            return result;
        }
    }
    
    @HttpPut
    global static Quote addQuoteDocument() {
        RestRequest req = RestContext.request;
        String OpportunityId = req.params.get('opportunityId');
        String configitQuoteId = req.params.get('configitQuoteId');
        String configitRevisionId = req.params.get('configitRevisionId');
        String type = req.params.get('type');
        String extension = req.params.get('extension');
        if (extension==null || extension=='') {
        	extension='pdf';
        }
        Quote q = [ Select ID, Name, status, quotenumber from Quote where ConfigitQuoteId__c = :configitQuoteId];
        /*
        if (extension=='pdf') {
        	QuoteDocument qd = new QuoteDocument();
        	qd.document = req.requestBody;
			qd.quoteId = q.Id;
            insert qd;
        	//qd.Name=q.name + '_' + configitRevisionId + '.' + extension;
       	}
		*/
        string filename = q.name + '_R' + (integer.valueof(configitRevisionId)+1) + '.' + extension;
        List<Attachment> attchs = [select Id from attachment where parentid=:q.id and (description = 'print' or name=:filename)];
        if (attchs!=null) {
            delete attchs;
        }
            
        Attachment a = new Attachment();
		a.ParentId = q.Id;
		a.Name = filename;
		a.Body = req.requestBody;
        a.Description=type;
    	insert a;
    	return q;        
    }
  /*                            
    public static Id getRecordTypeId(SObjectType entity, String recordTypeName) {
        try {
            return entity
                   .getDescribe()
                   .getRecordTypeInfosByName()
                   .get(recordTypeName)
                   .getRecordTypeId();
        } catch(Exception e) {
            return null;
        }
	}
*/    
    
    global class QLI {
        public String configitLineId {get; set;}
        public String materialID {get; set;}
        public Integer lineNumber {get; set;}
        public String description {get; set;}
        public String currencyCode {get; set;}
        public Double quantity {get; set;}
        public Double discount {get; set;}        
        public Double unitPrice {get; set;}
        public Double totalValue {get; set;} 
        public String optAltStatus {get;set;}
    }
    
    global class serviceResult {
        public string status {get;set;}
        public string message {get;set;}
        public string return_url {get;set;}
        public Quote quote {get;set;}
    }
        
}