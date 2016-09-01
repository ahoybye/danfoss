/**
	Author: Erin Fink
	Date: 15JUL15
	Version 1.0
**/

public with sharing class ExclusiveMaterialTriggerHandler{

	public static void onUpdateDeleteEM(List<Exclusive_Material__c> lstEMs){
		List<Exclusive_Material__c> lstExclusiveMaterials = new  List<Exclusive_Material__c>();
		for(Exclusive_Material__c exc : lstEMs) {
		    if(exc.isDeleted__c) {
		       lstExclusiveMaterials.add(exc);
		    }
		  }
		if(!lstExclusiveMaterials.isEmpty())
  			delete [select id from Exclusive_Material__c where Id IN :lstExclusiveMaterials];
	}
	
	public static void onDeleteCheckProduct(List<Exclusive_Material__c> lstEMs){
		
		List<Product2> lstProducts = new List<Product2>(); 
		Set<Id> setProductIds = new Set<Id>();
		for(Exclusive_Material__c material :lstEMs ) {
			setProductIds.add(material.Product__c);
		}
		
		lstProducts = [SELECT Id,Proprietary__c, (Select Id from Exclusive_Material__r limit 1) FROM Product2 WHERE Id IN :setProductIds];
		for(Product2 prod : lstProducts) {
			if(!prod.Exclusive_Material__r.isEmpty()) {
				prod.Proprietary__c = true;
			}
			else {
				prod.Proprietary__c = false;
			}
		}	
		if(!lstProducts.isEmpty())
			update lstProducts;
	}
}