public class QuoteLineItemPDFExtension{
	private Quote quote;
    private Opportunity oppty;
    private Account acct;
	private static Id quoteRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Not Routed Quote').getRecordTypeId();
	public String partlabel{get; set;}
    public Boolean isDistributor{get;set;}
    public Boolean isIndirect{get;set;}
    public Boolean isDirect{get;set;}
    //public Boolean showDistSellPrice{get;set;}
    public boolean customerPartColumn{get;set;}
    public boolean additionColumn{get;set;}
    //public boolean commentColumn{get;set;}
    public boolean distsellpriceColumn{get;set;}
    public string qId;
    public boolean commentColSpan2{get;set;}
    public boolean commentColSpan3{get;set;}
    public boolean commentColSpan4{get;set;}
    private Integer headerCommentsLine{get;set;}
    public integer firstListSize{get;set;}
    public integer secondListSize{get;set;}
    public List<wrapper> firstList{get;set;}
    public List<wrapper> secondList{get;set;}
    public List<list<wrapper>> listOfItems{get;set;}
    public list<parentWrapper> listparentWrapper{get;set;}
    
    public class parentWrapper{
        public list<wrapper> listwrapper {get;set;}
        public boolean isBreakPage{get;set;} 
    }
    public class wrapper{ 
        public string danfossPartNumber{get;set;}
        public string description{get;set;}
        public string modalCode{get;set;}
        public string publishedCustomerComments{get;set;}
        public double annualQuantity{get;set;}
        public double unitSalePrice{get;set;}
        public String priceBookEntryProduct2Name{get;set;}
        public String customerPartNumber{get;set;}
        public double distributorPrice{get;set;}
        public string currencyIsoCode{get;set;}
		public string customerProductCategory{get;set;}
	    public boolean commentColumn{get;set;}
    }
    public QuoteLineItemPDFExtension() {
		qId = ApexPages.currentPage().getParameters().get('id');
        headerCommentsLine = 1;
		customerPartColumn = false;
		additionColumn = false;
        commentColSpan2 = false;
        commentColSpan3 = false;
        commentColSpan4 = false;
        listOfItems = new List<list<wrapper>>();
        firstList = new List<wrapper>();
        secondList = new List<wrapper>(); 
        Integer j=0;
        listparentWrapper = new list<parentWrapper>();
        quote = [select Id, OpportunityId, Description, Footer_Comments__c from Quote where Id = :qId];        
        oppty = [select AccountId from Opportunity where Id = :quote.OpportunityId];
        acct = [select Channel__c, SAP_Account_ID__c, ParentId, Business_Org__c from Account where Id = :oppty.AccountId];
        if (acct.Channel__c == 'Distributor') {
            isDistributor = true;
            isDirect = false;
            isIndirect = false;
        }
        else if (acct.Channel__c == 'Indirect') {
            isDistributor = false;
            isDirect = false;
            isIndirect = true;	
        }
        else { //Direct or Global
            isDistributor = false;
            isDirect = true;
            isIndirect = false;
        }
		
		if (acct.Business_Org__c == 'Comatrol')
		{
			partlabel = 'Comatrol_Part_Number';
		}
		else if (acct.Business_Org__c == 'Turolla')
		{
			partlabel = 'Turolla_Part_Number';
		}
		else
			partlabel = 'Danfoss_Part_Number';
        list<QuoteLineItem> listQsI = new List<QuoteLineItem>();
        listQsI = [select PriceBookEntry.Product2.Name, Model_Code__c, Part_Number__c, Customer_Part_Number__c, Description, Order__c, Published_Customer_Comments__c, Quantity, UnitPrice, Distributor_Price__c, PS_Customer_Product_Category__c, CurrencyIsoCode From QuoteLineItem where QuoteId = :qId and (Line_Item_Approval_Stage__c like '%Approved%' OR quote.RecordTypeId = :quoteRecordTypeId) Order By Order__c asc ];
		for(QuoteLineItem qli : listQsI){
			if(qli.Customer_Part_Number__c != null ){
                customerPartColumn = true;
            }
            if(qli.Description != null ){
                additionColumn = true;
            }
            /*if(qli.Published_Customer_Comments__c != null ){
                commentColumn = true;
            }*/
            if(!isDirect && qli.Distributor_Price__c != null ){
                distsellpriceColumn = true;
            }
        }
		if(customerPartColumn && additionColumn){
			commentColSpan4 = true;
		}
		else if(customerPartColumn || additionColumn){
			commentColSpan3 = true;
		}
		else{
			commentColSpan2 = true;
		}
		
		// header comments calculations
        if(quote.Description != null && quote.Description.length() > 0){
            if(math.mod(quote.Description.length(), 160) > 0){
                headerCommentsLine = (quote.Description.length()/160) + 1;
            }
            else{
                headerCommentsLine = (quote.Description.length()/160);
            }
        }
		
		firstListSize = 21 - headerCommentsLine;
        secondListSize= 14;
        Integer iCounter=0;
        for(integer i = 0  ; i < listQsI.size() ;i++){
            if(listQsI[i].Part_Number__c != null && listQsI[i].Part_Number__c != ''){
                iCounter++;
            }
            if(listQsI[i].PriceBookEntry.Product2.Name != null && listQsI[i].PriceBookEntry.Product2.Name != ''){
                iCounter++;
            }
            if(listQsI[i].Model_Code__c != null && listQsI[i].Model_Code__c != ''){
                iCounter++;
            }
			if(listQsI[i].Published_Customer_Comments__c != null && listQsI[i].Published_Customer_Comments__c != ''){
				iCounter++;
				if(listQsI[i].Published_Customer_Comments__c.length() > 150){
					iCounter++;
				}
            }
            if(iCounter <= firstListSize){                    
                wrapper wrp = new wrapper();
                wrp.danfossPartNumber = listQsI[i].Part_Number__c;
                wrp.description = listQsI[i].Description;
                wrp.modalCode = listQsI[i].Model_Code__c;
                wrp.publishedCustomerComments = listQsI[i].Published_Customer_Comments__c;
                wrp.annualQuantity = listQsI[i].Quantity;
                wrp.unitSalePrice = listQsI[i].UnitPrice;
                wrp.priceBookEntryProduct2Name = listQsI[i].PriceBookEntry.Product2.Name;
                wrp.customerPartNumber = listQsI[i].Customer_Part_Number__c;
                wrp.distributorPrice = listQsI[i].Distributor_Price__c;
                wrp.currencyIsoCode = listQsI[i].CurrencyIsoCode;
				wrp.customerProductCategory = listQsI[i].PS_Customer_Product_Category__c;
				if(listQsI[i].Published_Customer_Comments__c != null ){
                	wrp.commentColumn = true;
            	}
				else{
					wrp.commentColumn = false;
				}
                firstList.add(wrp);    
		System.debug('firstList.size(): ' + firstList.size());                                 
            }
            else if(iCounter > firstListSize){                    
                if(listparentWrapper.size()==0){
                    parentWrapper objparentWrapper = new parentWrapper();
                    objparentWrapper.isBreakPage = true;
                    objparentWrapper.listwrapper = firstList;					
                    listparentWrapper.add(objparentWrapper);
				System.debug('objparentWrapper.isBreakPage: ' + objparentWrapper.isBreakPage);
                }
				System.debug('listparentWrapper.size(): ' + listparentWrapper.size());
                if(listQsI[i].Part_Number__c != null && listQsI[i].Part_Number__c != ''){
                	j++;
                }
                if(listQsI[i].PriceBookEntry.Product2.Name != null && listQsI[i].PriceBookEntry.Product2.Name != ''){
                	j++;
                }
                if(listQsI[i].Model_Code__c != null && listQsI[i].Model_Code__c != ''){
                    j++;
                }
				if(listQsI[i].Published_Customer_Comments__c != null && listQsI[i].Published_Customer_Comments__c != ''){
					j++;
					if(listQsI[i].Published_Customer_Comments__c.length() > 150){
						j++;
					}
	            }
                wrapper wrp = new wrapper();
                wrp.danfossPartNumber = listQsI[i].Part_Number__c;
                wrp.description = listQsI[i].Description;
                wrp.modalCode = listQsI[i].Model_Code__c;
                wrp.publishedCustomerComments = listQsI[i].Published_Customer_Comments__c;
                wrp.annualQuantity = listQsI[i].Quantity;
                wrp.unitSalePrice = listQsI[i].UnitPrice;
                wrp.priceBookEntryProduct2Name = listQsI[i].PriceBookEntry.Product2.Name;
                wrp.customerPartNumber = listQsI[i].Customer_Part_Number__c;
                wrp.distributorPrice = listQsI[i].Distributor_Price__c;
                wrp.currencyIsoCode = listQsI[i].CurrencyIsoCode;
				wrp.customerProductCategory = listQsI[i].PS_Customer_Product_Category__c;
				if(listQsI[i].Published_Customer_Comments__c != null ){
                	wrp.commentColumn = true;
            	}
				else{
					wrp.commentColumn = false;
				}
                secondList.add(wrp);
		System.debug('secondList.size(): ' + secondList.size());
                if(j >= secondListSize){
                    j=0;
                    listOfItems.add(secondList);
                    parentWrapper objparentWrapper1 = new parentWrapper();
                    objparentWrapper1.isBreakPage = true;
                    objparentWrapper1.listwrapper = secondList;
                    listparentWrapper.add(objparentWrapper1);
                    secondList = new list<wrapper>();                       
                }
				System.debug('listparentWrapper.size(): ' + listparentWrapper.size());
            }
        }
            
        if(listparentWrapper.size()==0){
            parentWrapper objparentWrapper = new parentWrapper();
            objparentWrapper.isBreakPage = false;
            objparentWrapper.listwrapper = firstList;
            listparentWrapper.add(objparentWrapper);
        }
        
        if(secondList != null && secondList.size()>0){
            parentWrapper objparentWrapper1 = new parentWrapper();             
            objparentWrapper1.listwrapper = secondList;
            objparentWrapper1.isBreakPage = true;
            listparentWrapper.add(objparentWrapper1);
        }
        
				System.debug('listparentWrapper.size(): ' + listparentWrapper.size());
        if(listparentWrapper != null && listparentWrapper.size() > 0){
            listparentWrapper[listparentWrapper.size() - 1].isBreakPage = false;
        }
				System.debug('listparentWrapper[listparentWrapper.size() - 1].isBreakPage: ' + listparentWrapper[listparentWrapper.size() - 1].isBreakPage);
    }	

}