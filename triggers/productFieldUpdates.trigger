/*
*
*
*
*/
trigger productFieldUpdates on Product2 (before insert, before update) {
    
    map<String,Product_Line__c> mpProductLine = new map<String,Product_Line__c>();
    for (Product2 prod : Trigger.New) { 
      //if(isProductDataChanged(prod)) {
        mpProductLine.put(prod.SAP_Product_Line_Code__c,NULL); 
      //}
    }
    
    if(mpProductLine.isEmpty()) {
      return;
    }
    
    for(Product_Line__c pLine : [Select id, PL_Code__c, Business_Org__c, Business_Unit_Description__c from Product_Line__c where PL_Code__c IN :mpProductLine.keySet()]) {
      mpProductLine.put(pLine.PL_Code__c,pLine);
    }
    
    for (Product2 prod : Trigger.new) { 
      if(mpProductLine.containsKey(prod.SAP_Product_Line_Code__c) && mpProductLine.get(prod.SAP_Product_Line_Code__c) != NULL) {
         Product_Line__c pLine = mpProductLine.get(prod.SAP_Product_Line_Code__c);
         if(pLine.Business_Org__c == 'Integrated') {
           prod.Business_Org__c = 'Danfoss';
         }else {
           prod.Business_Org__c = pLine.Business_Org__c;
         }
         prod.Business_Unit__c = pLine.Business_Unit_Description__c;
      }
    }
    
    private Boolean isProductDataChanged(Product2 prod) {
      if(prod.SAP_Product_Line_Code__c == null) {
        return false;  
      }
      if(Trigger.isInsert) {
        return true;
      }
      if(Trigger.oldMap.get(prod.Id).SAP_Product_Line_Code__c != prod.SAP_Product_Line_Code__c) {
        return true;
      }
      return false;
    }
}