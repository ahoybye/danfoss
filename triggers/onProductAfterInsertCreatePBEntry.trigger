/**********************************************************************************
Created By    :    Sumit Mishra
Date          :    10/14/2011
Reason        :    When a new product gets created add one entry in PricebookEntry for Standard Price Book
**********************************************************************************/
trigger onProductAfterInsertCreatePBEntry on Product2 (before Insert, after Insert, before Update, after Update) 
{
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            ProductTriggerHandler.setRecordType(Trigger.new);
        }
    } else {
        if (Trigger.isInsert) {
            ProductTriggerHandler.createClimateAndEnergyPricebookEntries(Trigger.new);
        }
    }
    
    List<PriceBookEntry> lstpbe = new List<PriceBookEntry>();
    // Begin Climate & Energy addition, Jesper Kristensen, Capgemini Sogeti, January 2015
    List<Product2> lstProducts = new List<Product2>();
    for (Product2 prod : Trigger.New) {
        if (prod.RecordTypeId != ProductTriggerHandler.climateAndEnergyProductRecordTypeId) {
            lstProducts.add(prod);
        }
    }
    // End Climate & Energy addition, Jesper Kristensen, Capgemini Sogeti, January 2015
    set<Id> setProdIds = new set<Id>();
    List<CurrencyType> lstCurrency = [Select id,IsoCode from CurrencyType];
    set<string> setCurrency = new set<string>();
    for (CurrencyType c :lstCurrency) 
        setCurrency.add(c.IsoCode);
    Map<string,PriceBook2> mapPriceBook = new Map<string,PriceBook2>();
            
    //Code to get Business Org-----------    
    set<string> setProductLine = new set<string>();
    for(Product2 prod:lstProducts) {
        setProdIds.add(prod.Id);
        if(prod.SAP_Product_Line_Code__c!=null && prod.SAP_Product_Line_Code__c!='')
            setProductLine.add(prod.SAP_Product_Line_Code__c);
    }
    Map<string,Product_Line__c> mapProductLine = new Map<string,Product_Line__c>();
    for(Product_Line__c pLine:[Select id, PL_Code__c,Business_Org__c from Product_Line__c where PL_Code__c in :setProductLine])
        mapProductLine.put(pLine.PL_Code__c.toLowerCase(),pLine);
    //---End Code to get Business Org--------------
                
    if (Trigger.isBefore) {
        for(Product2 prod:Trigger.New) {
            product_Line__c pLine = null;
            if (prod.SAP_Product_Line_Code__c != null && prod.SAP_Product_Line_Code__c != '') {
                pLine = mapProductLine.get(prod.SAP_Product_Line_Code__c.toLowercase()); 
                if (pLine != null) {
                    if (pLine.Business_Org__c == 'Integrated') {
                        prod.Business_Org__c = 'Danfoss';
                    } else {
                        prod.Business_Org__c = pLine.Business_Org__c;
                    }
                }
            }
        }
    }  
    
    if (Trigger.isAfter) {   
        List<string> OtherNames = new List<string>();
        OtherNames.add('Danfoss');
        OtherNames.add('Comatrol');
        OtherNames.add('Turolla');
        OtherNames.add('Valmova');
        for(PriceBook2 pb:[Select id,name,IsStandard  from PriceBook2 where IsStandard = true OR Name in:OtherNames])
        {
            if(pb.isStandard)
                mapPriceBook.put('STANDARD',pb);
            else
                mapPriceBook.put(pb.Name.toLowercase(),pb);
        }        
        List<PricebookEntry> lstpbEntry =new List<PricebookEntry>();  
        
        List<PricebookEntry> lstStdpbEntry =[Select PriceBook2Id, Product2Id, CurrencyIsoCode, ProductCode From PriceBookEntry Where 
            // (PriceBook2Id =: mapPriceBook.get('STANDARD').Id or PriceBook2Id = :mapPriceBook.get('danfoss').Id or 
            // PriceBook2Id = :mapPriceBook.get('comatrol').Id or PriceBook2Id = :mapPriceBook.get('turolla').Id or PriceBook2Id = :mapPriceBook.get('valmova').Id) 
            // and 
            (PriceBook2.IsStandard = true or PriceBook2.IsStandard = false) and Product2Id in :setProdIds];            
        Map<String, PricebookEntry> mapSTANDARD = new Map<String, PricebookEntry>();
        Map<String, PricebookEntry> mapdanfoss = new Map<String, PricebookEntry>();
        Map<String, PricebookEntry> mapcomatrol = new Map<String, PricebookEntry>();
        Map<String, PricebookEntry> mapturolla = new Map<String, PricebookEntry>();
        Map<String, PricebookEntry> mapvalmova = new Map<String, PricebookEntry>();
        for (PricebookEntry p :lstStdpbEntry) {
            if (p.PriceBook2Id == mapPriceBook.get('STANDARD').Id)
               mapSTANDARD.put(p.CurrencyIsoCode+p.Product2Id, p);
           else if (p.PriceBook2Id == mapPriceBook.get('danfoss').Id)
               mapdanfoss.put(p.CurrencyIsoCode+p.Product2Id, p);
           else if (p.PriceBook2Id == mapPriceBook.get('comatrol').Id)
               mapcomatrol.put(p.CurrencyIsoCode+p.Product2Id, p);
           else if (p.PriceBook2Id == mapPriceBook.get('turolla').Id)
               mapturolla.put(p.CurrencyIsoCode+p.Product2Id, p);
           else if (p.PriceBook2Id == mapPriceBook.get('valmova').Id)
               mapvalmova.put(p.CurrencyIsoCode+p.Product2Id, p);
        }
        lstStdpbEntry.clear();
        for (Product2 prod : lstProducts)
        {
            product_Line__c pLine = null;
            if (prod.SAP_Product_Line_Code__c != null && prod.SAP_Product_Line_Code__c != '')
                pLine = mapProductLine.get(prod.SAP_Product_Line_Code__c.toLowercase());
            
            for(CurrencyType cur:lstCurrency)
            {                               
                if(mapPriceBook.get('STANDARD')!=null){                                
                    if (mapSTANDARD.get(cur.IsoCode+prod.Id) == null){
                        system.debug('product ' + prod + 'in the if Standard loop ' + cur.IsoCode);
                        PricebookEntry pbEntry = new PricebookEntry(PriceBook2Id =mapPriceBook.get('STANDARD').Id, product2Id = prod.Id,UnitPrice =0,CurrencyIsoCode=cur.IsoCode, UseStandardPrice=false, IsActive=true);
                        lstStdpbEntry.add(pbEntry);
                    }
                }
                if(pLine!=null)
                {
                    if(pLine.Business_Org__c == 'Integrated')
                    {
                        if(mapPriceBook.get('danfoss')!=null) {
                            if (mapdanfoss.get(cur.IsoCode+prod.Id) == null){
                                PricebookEntry pbEntry = new PricebookEntry(PriceBook2Id =mapPriceBook.get('danfoss').Id, product2Id = prod.Id,UnitPrice =0,CurrencyIsoCode=cur.IsoCode, UseStandardPrice=false, IsActive=true);
                                lstpbEntry.add(pbEntry);
                            }
                        }
                    }
                    if(pLine.Business_Org__c == 'Comatrol') 
                    {
                        if(mapPriceBook.get('comatrol')!=null) {
                            if (mapcomatrol.get(cur.IsoCode+prod.Id) == null) {
                                PricebookEntry pbEntry = new PricebookEntry(PriceBook2Id =mapPriceBook.get('comatrol').Id, product2Id = prod.Id,UnitPrice =0,CurrencyIsoCode=cur.IsoCode, UseStandardPrice=false, IsActive=true);
                                lstpbEntry.add(pbEntry);
                            }
                        }
                    }
                    if(pLine.Business_Org__c == 'Turolla') 
                    {
                        if(mapPriceBook.get('turolla')!=null) {
                            if (mapturolla.get(cur.IsoCode+prod.Id) == null) {
                                PricebookEntry pbEntry = new PricebookEntry(PriceBook2Id =mapPriceBook.get('turolla').Id, product2Id = prod.Id,UnitPrice =0,CurrencyIsoCode=cur.IsoCode, UseStandardPrice=false, IsActive=true);
                                lstpbEntry.add(pbEntry);
                            }
                        }
                    }
                    if(pLine.Business_Org__c == 'Valmova') 
                    {
                        if(mapPriceBook.get('valmova')!=null) {
                            if (mapvalmova.get(cur.IsoCode+prod.Id) == null) {
                                PricebookEntry pbEntry = new PricebookEntry(PriceBook2Id =mapPriceBook.get('valmova').Id, product2Id = prod.Id,UnitPrice =0,CurrencyIsoCode=cur.IsoCode, UseStandardPrice=false, IsActive=true);
                                lstpbEntry.add(pbEntry);
                            }
                        }
                    }
                }
            }
        }
        system.debug('---------non standard--------------'+lstpbEntry);
        system.debug('------standard-----------------'+lstStdpbEntry);
        upsert lstStdpbEntry;
        upsert lstpbEntry;
    }
}