public with sharing class CaseProductEntryExtension {

    private ApexPages.StandardController controller;
    private Case theOpp;
    
    public String Division {get;set;}
    public String ProductLine {get;set;}
    public String searchString {get;set;}    
    public String searchClass {get;set;} 
    public String searchMaterialNo {get;set;} 
    public String searchStatNo {get;set;}                 
    
    public Case_Product__c[] shoppingCart {get;set;}
    public ApexPages.StandardSetController AvailableProductsCon {get;set;}
    public String searchType {get;set;}
    
    public Boolean backToCase {get;set;}
            
    public ID toSelect {get;set;}
    public ID toUnselect {get;set;}
    
    private Case_Product__c[] forDeletion = new Case_Product__c[]{};
    public String searchTypeText {get;set;}

    public CaseProductEntryExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String> {'Id'});
        }
        this.controller = controller;
        searchString = '';
        searchClass = '';
        searchMaterialNo = '';
        searchStatNo = '';
        backToCase = false;
        theOpp = (Case) controller.getRecord();
        
        //This should contain information about which products should be searched
        // PRODUCTS, GROUPS or ALL
        this.searchType = ApexPages.currentPage().getParameters().get('searchType');
        if (this.searchType == null) {
            this.searchType = 'ALL';
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
        shoppingCart = [
            select
                Id,
                Serial_Number__c,
                Quantity__c,
                Product__c,
                Product__r.Name,
                Product__r.Product_Set__c,
                Product__r.Product_Line__c,
                Product__r.Business_Unit__c,
                Product__r.ProductCode,
                Product__r.isProductGroupOnly__c,
                Product__r.SAP_Material_Code_CE__c
            from Case_Product__c
            where Case__c = :theOpp.Id
        ];
        
    }
    
    // this is the 'action' method on the page
    public void init() {
        
        if (searchType == 'GROUPS') {
            updateAvailableList();
        }
    }
    
    public void search() {
        updateAvailableList();
    }
    
    private void updateAvailableList() {
        
        // We dynamically build a query string and exclude items already in the shopping cart
        String qString = 'select Id, Name, Business_Unit__c, Product_Line__c, Product_Set__c, ProductCode'
            + ' from Product2'
            + ' where IsActive = true';
            
        //Raj - synch with Oppty Search
        String nameLike = searchString.replaceAll('[*]', '%');
        if (searchString != '') {
            qString += ' and Name like :nameLike';
        }
        String businessUnit = ProductLine;
        
        if (ProductLine != 'All') {
            qString += ' and Business_Unit__c = :businessUnit';
        } else if (ProductLine == 'All') {
            List<String> plines = new List<String>();            
            for (Product_Groups__c grp : [select Group_Code__c from Product_Groups__c where Division__c = :Division order by Group_Code__c])  { 
               plines.add((String) grp.Group_Code__c);  
            }
            
            qString += ' and Business_Unit__c IN :plines';
        }
        //Raj - synch with Oppty Search
        String lineLike = searchClass.replaceAll('[*]', '%');
        if (searchClass != '') {
            qString += ' and Product_Line__c like :lineLike';
        }
        //Raj - synch with Oppty Search
        String codeLike = searchMaterialNo.replaceAll('[*]', '%');
        if (searchMaterialNo!= '') {
            qString += ' and ProductCode like :codeLike';
        }
        //Raj - synch with Oppty Search
        String setLike = searchStatNo.replaceAll('[*]', '%');
        if (searchStatNo !='') {
            qString += ' and Product_Set__c like :setLike';
        }
        if (searchType == 'PRODUCTS') {
            qString += ' and isProductGroupOnly__c = false';
        } else if (searchType == 'GROUPS') {
            qString += ' and isProductGroupOnly__c = true';
        }
        
        Set<ID> selectedEntries = new Set<ID>();
        for (Case_Product__c d : shoppingCart) {
            selectedEntries.add(d.Product__c);
        }
        
        qString += ' and Id not in :selectedEntries';
        qString += ' order by Business_Unit__c, Name limit 10000';
        
        System.debug('qString:' + qString);        
        AvailableProductsCon = new ApexPages.StandardSetController(Database.getQueryLocator(qString));
        AvailableProductsCon.setPageSize(10);
    }
    
    public List<Product2> getAvailableProducts() {
        return AvailableProductsCon.getRecords();
    }
    
    public void addToShoppingCart() {
        // This function runs when a user hits "select" button next to a product
        Product2 d = [
            select
                Id,
                Name,
                Product_Set__c,
                Product_Line__c,
                Business_Unit__c,
                ProductCode,
                isProductGroupOnly__c,
                SAP_Material_Code_CE__c
            from Product2
            where Id = :toSelect
        ];
        shoppingCart.add(new Case_Product__c(
            Name = d.Name,
            Case__c = theOpp.Id,
            Product__r = d,
            Product__c = d.Id
        ));
        
        updateAvailableList();  
    }
    
    public void removeFromShoppingCart() {
        
        // This function runs when a user hits "remove" on an item in the "Selected Products" section
        
        Integer count = 0;
        
        for (Case_Product__c d : shoppingCart) {
            if (d.Product__c == toUnselect) {
                if (d.Id != null) {
                    forDeletion.add(d);
                }
                shoppingCart.remove(count);
                break;
            }
            count++;
        }
        
        updateAvailableList();
    }
    
    public void onSave() {
        
        //theOpp.ChangedLineItems__c=true;
        
        // If previously selected products are now removed, we need to delete them
        if (!forDeletion.isEmpty()) {
            try {
                delete forDeletion;
            } catch (DMLException e) {
                ApexPages.addMessages(e);
                return;
            }
        }
        
        // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
        if (!shoppingCart.isEmpty()) {
            try {
                upsert shoppingCart;
            } catch (DMLException e) {
                ApexPages.addMessages(e);
                return;
            }
        }
        
        backToCase = controller.save() != null;
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
    
}