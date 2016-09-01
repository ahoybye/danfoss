public with sharing class OpportunityProductEntryExtension {

    private ApexPages.StandardController controller;
    private Opportunity theOpp;
    
    public String Division {get;set;}
    public String ProductLine {get;set;}
    public String searchString {get;set;}    
    public String searchClass {get;set;} 
    public String searchMaterialNo {get;set;} 
    public String searchStatNo {get;set;}                 
    
    public wrapOpportunityLineItem[] shoppingCart {get;set;}
    public ApexPages.StandardSetController AvailableProductsCon {get;set;}
    public String searchType {get;set;}
          
    public ID toSelect {get;set;}
    public ID toUnselect {get;set;}
    public Decimal Total {get;set;}
    
    public List<Sales_Area__c> AvailableSalesAreas {get;set;}
    public ID selectedSalesArea {get;set;}
    
    private OpportunityLineItem[] forDeletion = new OpportunityLineItem[]{};
    public String searchTypeText {get;set;}
    public VF_dummy__c myOppTotal {get;set;}    
    
    public OpportunityProductEntryExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String> {'Id', 'Pricebook2Id', 'RecordType.Id', 'RecordType.Name', 'Pricebook2.Name', 'CurrencyIsoCode', 'AccountId', 'Sub_Account__c', 'Sales_Area__c', 'Sales_Area__r.Sales_Area_Master__r.Sales_Org__c', 'Sales_Area__r.Sales_Area_Master__r.Channel__c', 'Sales_Area__r.Sales_Area_Master__r.Division__c', 'Sales_Area__r.Sub_Account__r.SAP_Account_ID__c'});
        }
        this.controller = controller;
        searchString = '';
        searchClass = '';
        searchMaterialNo = '';
        searchStatNo = '';

        myOppTotal = new VF_dummy__c();
                
        theOpp = (Opportunity) controller.getRecord();

        //This should contain information about which products should be searched
        // PRODUCTS, GROUPS or ALL (ALL is no longer used)
        this.searchType = ApexPages.currentPage().getParameters().get('searchType');
        if (this.searchType == null) {
            this.searchType = 'GROUPS';
        }
            
        if (searchType == 'PRODUCTS') {
            searchTypeText = SObjectType.Product2.LabelPlural;
        } else if (searchType == 'GROUPS') {
            searchTypeText = SObjectType.Product2.Label + ' Groups';
        } else {
            searchTypeText = SObjectType.Product2.LabelPlural + ' and ' + SObjectType.Product2.Label + ' Groups';
        }
        
        // Get current user division
        Division = [select Division__c from User where Id = :UserInfo.getUserId()].Division__c;
        if ([select Id from Product_Groups__c where Division__c = :Division limit 1].isEmpty()) {
            // The user's division is not a valid SelectOption.
            Division = getDivisions()[0].getValue();
        }
        ProductLine = getProductLines()[0].getValue();
        
        // If products were previously selected need to put them in the "selected products" section to start with
       //5th Feb - not add in the shadow field DELETEME__c, here...... 
       // Wrapping the OpportunityLineItem : JPK 08-04-2015
        shoppingCart = new List<wrapOpportunityLineItem>();
        for (OpportunityLineItem oli : [
            select
                Id,
                Quantity,
                UnitPrice,
                ListPrice,
                Discount,
                Proposed_Price__c,
                TotalPrice,
                PriceBookEntryId,
                PriceBookEntry.Product2.Name,
                PriceBookEntry.Product2.Product_Set__c,
                PriceBookEntry.Product2.Product_Line__c,
                PriceBookEntry.Product2.Business_Unit__c,
                PriceBookEntry.Product2.ProductCode,
                PriceBookEntry.Product2.isProductGroupOnly__c,
                PricebookEntry.Product2.SAP_Material_Code_CE__c
            from opportunityLineItem
            where OpportunityId=:theOpp.Id
        ]) {
            shoppingCart.add(new wrapOpportunityLineItem(oli));
        }
        
    }
    
    // this is the 'action' method on the page
    public PageReference init() {
        
        // Check if Opp has a pricebook associated yet
        if (theOpp.Pricebook2Id == null) {
            Pricebook2[] activepbs = [select Id, Name from Pricebook2 where IsActive = true and Name = 'Climate and Energy' limit 2];
            if (activepbs.size() == 2) {
                // if the user needs to select a pricebook before we proceed we send them to standard pricebook selection screen
                return changePricebook();
            } else {
                //if there is only one active pricebook we go with it and save the opp
                try {
                    theOpp.Pricebook2Id = activepbs[0].Id;
                    theOpp.Pricebook2 = activepbs[0];
                    update theOpp;
                } catch (DMLException e) {
                    ApexPages.addMessages(e);
                }
            }
        }
        
        if (searchType == 'GROUPS') {
            updateAvailableList();
        }
        refreshTotals();
        return null;
    }

    public void search() {
        updateAvailableList();
        
        if (searchType == 'PRODUCTS') {
            searchTypeText = SObjectType.Product2.LabelPlural;
        } else if (searchType == 'GROUPS') {
            searchTypeText = SObjectType.Product2.Label + ' Groups';
        } else {
            searchTypeText = SObjectType.Product2.LabelPlural + ' and ' + SObjectType.Product2.Label + ' Groups';
        }
    }
    
    private void updateAvailableList() {
        
        ID pbId = theOpp.Pricebook2Id;
        String cur = theOpp.CurrencyIsoCode;
        // We dynamically build a query string and exclude items already in the shopping cart
        String qString = 'select Id, Product2.Name, Product2.Business_Unit__c, Product2.Product_Line__c, Product2.Product_Set__c, Product2.SAP_Material_Code_CE__c'
            + ' from PricebookEntry'
            + ' where IsActive = true and Pricebook2Id = :pbId and CurrencyIsoCode = :cur';
        
        String nameLike = searchString.replaceAll('[*]', '%');

        if (searchString != '') {
            qString += ' and Product2.Name like :nameLike';
        }
        String businessUnit = ProductLine;
        
        if (ProductLine != 'All') {
            qString += ' and Product2.Business_Unit__c = :businessUnit';
        } else if (ProductLine == 'All') {
            List<String> plines = new List<String>();            
            for (Product_Groups__c grp : [select Group_Code__c from Product_Groups__c where Division__c = :Division order by Group_Code__c])  { 
               plines.add((String) grp.Group_Code__c);  
            }
            
            qString += ' and Product2.Business_Unit__c IN :plines';
        }
        String lineLike = searchClass.replaceAll('[*]', '%');
        if (searchClass != '') {
            qString += ' and Product2.Product_Line__c like :lineLike';
        }
        String codeLike = searchMaterialNo.replaceAll('[*]', '%');
        if (searchMaterialNo!= '') {
            qString += ' and Product2.SAP_Material_Code_CE__c like :codeLike';
        }
        String setLike = searchStatNo.replaceAll('[*]', '%');
        if (searchStatNo !='') {
            qString += ' and Product2.Product_Set__c like :setLike';
        }
        if (searchType == 'PRODUCTS') {
            qString += ' and Product2.isProductGroupOnly__c = false';
        } else if (searchType == 'GROUPS') {
            qString += ' and Product2.isProductGroupOnly__c = true';
        }
        
        Set<ID> selectedEntries = new Set<ID>();
        for (wrapOpportunityLineItem d : shoppingCart) {
            selectedEntries.add(d.oppLine.PricebookEntryId);
        }
        
        qString += ' and Id not in :selectedEntries';
        qString += ' order by Product2.Business_Unit__c, Product2.Name limit 10000';
        
        System.debug('qString:' + qString);        
        AvailableProductsCon = new ApexPages.StandardSetController(Database.getQueryLocator(qString));
        AvailableProductsCon.setPageSize(10);
    }
    
    public List<PricebookEntry> getAvailableProducts() {
        return AvailableProductsCon.getRecords();
    }
    
    public void addToShoppingCart() {
        // This function runs when a user hits "select" button next to a product
        PricebookEntry d = [
            select
                Id,
                Product2.Name,
                Product2.Product_Set__c,
                Product2.Product_Line__c,
                Product2.Business_Unit__c,
                Product2.ProductCode,
                Product2.isProductGroupOnly__c,
                Product2.SAP_Material_Code_CE__c
            from PricebookEntry
            where Id = :toSelect
        ];
        shoppingCart.add(new wrapOpportunityLineItem(new opportunityLineItem(
            OpportunityId = theOpp.Id,
            PriceBookEntry = d,
            PriceBookEntryId = d.Id
        )));
        
        updateAvailableList();  
        refreshTotals();
    }
    
    public void removeFromShoppingCart() {
        
        // This function runs when a user hits "remove" on an item in the "Selected Products" section
        
        Integer count = 0;
        
        for (wrapOpportunityLineItem d : shoppingCart) {
            if (d.oppLine.PriceBookEntryId == toUnselect) {
                if (d.oppLine.Id != null) {
                    forDeletion.add(d.oppLine);
                }
                shoppingCart.remove(count);
                break;
            }
            count++;
        }
        
        updateAvailableList();
        refreshTotals();
    }
    
    public void selectSalesArea() {
        theOpp.Sales_Area__c = selectedSalesArea;
        theOpp.Sales_Area__r = [select Id, Sales_Area_Master__r.Sales_Org__c, Sales_Area_Master__r.Channel__c, Sales_Area_Master__r.Division__c, Sub_Account__c, Sub_Account__r.SAP_Account_ID__c from Sales_Area__c where Id = :theOpp.Sales_Area__c];
        theOpp.Sub_Account__c = theOpp.Sales_Area__r.Sub_Account__c;
        AvailableSalesAreas = null;
        fetchPrices();
    }
    
    public void cancelSalesAreaSelect() {
        AvailableSalesAreas = null;
    }
    
    public void fetchPrices() {
        if (theOpp.Sales_Area__r == null) {
            /*
             * We need a sales area in order to get prices.
             * If a sales area is already selected, use that, otherwise if the account only has one sales area, use that, otherwise let the user select a sales area.
             * Save the chosen sub account and sales are on the opportunity.
             */
            String soqlFields = 'Id';
            for (FieldSetMember field : SObjectType.Sales_Area__c.FieldSets.PricesForOpportunityColumns.getFields()) {
                soqlFields += ', ' + field.getFieldPath();
            }
            ID accountId = theOpp.AccountId;
            AvailableSalesAreas = Database.query('select ' + soqlFields + ' from Sales_Area__c where Sub_Account__r.Account__c = :accountId');
            if (AvailableSalesAreas.size() == 1) {
                selectedSalesArea = AvailableSalesAreas[0].Id;
                selectSalesArea();
                return;
            }
            return;
        }
        
        if ((theOpp.Sales_Area__r.Sales_Area_Master__r.Sales_Org__c == null) || (theOpp.Sales_Area__r.Sales_Area_Master__r.Channel__c == null) || (theOpp.Sales_Area__r.Sales_Area_Master__r.Division__c == null)) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SalesOrg needs to be setup on the opportunity.' ));
              return;
         }

        for (wrapOpportunityLineItem woli : shoppingCart) {
            if (woli.oppLine.PricebookEntry.Product2.isProductGroupOnly__c) {
                continue;
            }
            SAP_CEPriceService pr = new SAP_CEPriceService();
            SAP_CEPriceService.SAPPriceInput params = new SAP_CEPriceService.SAPPriceInput();
            
            params.SalesOrgId = theOpp.Sales_Area__r.Sales_Area_Master__r.Sales_Org__c;
            params.DistributionChannel = theOpp.Sales_Area__r.Sales_Area_Master__r.Channel__c;
            params.Division = theOpp.Sales_Area__r.Sales_Area_Master__r.Division__c;
            params.AccountId = theOpp.Sales_Area__r.Sub_Account__r.SAP_Account_ID__c;
            params.ProductCode = woli.oppLine.PriceBookEntry.Product2.SAP_Material_Code_CE__c;
            
            system.debug('SAP Call : ' + params.SalesOrgId + ' - ' + params.DistributionChannel + ' - ' + params.Division);
            
            SAP_CEPriceService.SAPPriceOutput outprice;
            try{
                outprice = pr.InvokeSAPPricing(params);  
            } catch (Exception e){
                System.debug('SAP Exception:' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pr.translateSAPError(e.getTypeName())));
                break;
            }
            if(outprice.HasError) {
                System.debug('SAP HasError');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, outprice.ErrorMessage));
                break;
            }
            if (theOpp.CurrencyIsoCode != outprice.SAPCurrency) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Expected currency ' + theOpp.CurrencyIsoCode + ' but received currency ' + outprice.SAPCurrency + ' from SAP.'));
                break;
            }
            woli.oppLine.UnitPrice = outprice.SAPPrice;
        }
        refreshTotals();
    }
    
    public PageReference onSave() {
        
        //theOpp.ChangedLineItems__c=true;
        for (wrapOpportunityLineItem woli : shoppingCart) {
            if (woli.oppLine.UnitPrice == null) {
                woli.oppLine.UnitPrice.addError('Please enter a value');
                return null;
            }
        }
        
        // If previously selected products are now removed, we need to delete them
        if (!forDeletion.isEmpty()) {
            try {
                delete forDeletion;
            } catch (DMLException e) {
                ApexPages.addMessages(e);
                return null;
            }
        }
        
        // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
        if (!shoppingCart.isEmpty()) {
            // Unwrapping the shoppingcart wrapper : JPK 08-04-2015
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
            for (wrapOpportunityLineItem woli : shoppingCart) {
                olis.add(woli.oppLine);
            }
            try {
                upsert olis;
            } catch (DMLException e) {
                ApexPages.addMessages(e);
                return null;
            }
        }
        
        return controller.save();
    }
    
    public PageReference changePricebook() {
        
        // This simply returns a PageReference to the standard Pricebook selection screen
        // Note that is uses retURL parameter to make sure the user is sent back after they choose
        
        PageReference ref = new PageReference('/oppitm/choosepricebook.jsp');
        ref.getParameters().put('id', theOpp.Id);
        ref.getParameters().put('retURL', '/apex/opportunityProductEntry?id=' + theOpp.Id);
        return ref;
    }
    
    public PageReference goToProductSelector() {
        
        PageReference ref = new PageReference('/apex/opportunityProductEntry');
        ref.getParameters().put('id', theOpp.Id);
        ref.getParameters().put('type', 'PRODUCTS');
        return ref;
    }
                                
    public PageReference goToProductGroupSelector() {
        
        PageReference ref = new PageReference('/apex/opportunityProductEntry');
        ref.getParameters().put('id', theOpp.Id);
        ref.getParameters().put('type', 'GROUPS');
        return ref;
    }
    
    public List<SelectOption> getProductLines() { 
        List<SelectOption> options = new List<SelectOption>();
        if (searchType == 'GROUPS') {        
            options.add(new SelectOption('All','All'));
        }        
            
        for (Product_Groups__c grp : [select Group_Code__c from Product_Groups__c where Division__c = :Division order by Group_Code__c])  { 
            options.add(new SelectOption(grp.Group_Code__c, grp.Group_Code__c));  
        }
        return options;
    }
    
    public List<SelectOption> getDivisions() {
        List<SelectOption> options = new List<SelectOption>();
        for (AggregateResult ar : [select Division__c from Product_Groups__c group by Division__c order by Division__c]) {
            options.add(new SelectOption((String) ar.get('Division__c'), (String) ar.get('Division__c')));  
        }
        return options;
    }
    
    public void refreshTotals() {
        Total = 0;
        for (wrapOpportunityLineItem d : shoppingCart) {
            if (d.oppLine.Quantity != null && d.oppLine.UnitPrice != null) {
                Total += d.oppLine.Quantity * d.oppLine.UnitPrice;
            }
        }
        myOppTotal.CurrencyIsoCode = theOpp.CurrencyIsoCode;
        myOppTotal.VF_dummy_currency__c = Total;
    }
    
    public class wrapOpportunityLineItem{
        public OpportunityLineItem oppLine{get;set;}
        
        public wrapOpportunityLineItem(OpportunityLineItem a){
            oppLine=a;
        }
        
        public VF_Dummy__c getTotalLinePrice() {
            return new VF_Dummy__c(
                CurrencyIsoCode = oppLine.CurrencyIsoCode,
                VF_dummy_currency__c = oppLine.TotalPrice
            );
        }
    }
    
    
}