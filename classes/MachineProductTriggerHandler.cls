/**
	Author: Erin Fink
	Date: 14MAY15
	Version 1.0
**/

public with sharing class MachineProductTriggerHandler{
	public static boolean hasTriggerExecuted = false;

	public static void UpdatePartNumbers(List<Machine_Model_Product__c> lstProducts){		//BEFORE
		List<Machine_Model_Product__c> lstmmprod = new List<Machine_Model_Product__c>();
	    Set<Id> setMMProdIds = new Set<Id>();
	    Map<Id, Id> mapMMAcct = new Map<Id, Id>();
	    for (Machine_Model_Product__c mmprod :lstProducts) {
	            lstmmprod.add(mmprod);
	            setMMProdIds.add(mmprod.Machine_Model_Product__c);
	            mapMMAcct.put(mmprod.Machine_Model__c, NULL);
	    }
	    for(Machine_Model__c machine: [SELECT Id,Account__c FROM Machine_Model__c WHERE Id IN : mapMMAcct.keySet()]) {
	        mapMMAcct.put(machine.Id,machine.Account__c);
	    }
	    map<String,Customer_Part_Number__c> mapCustomerPartNumber = new map<String,Customer_Part_Number__c>(); 
	      for(Customer_Part_Number__c part : [SELECT Material_Number__c,Id,Account__c,Product__c 
	                          FROM Customer_Part_Number__c WHERE Account__c IN :mapMMAcct.values() AND Product__c IN :setMMProdIds]) {
	        mapCustomerPartNumber.put(part.Account__c+'-'+part.Product__c,part);
	      }
	    
	    for (Machine_Model_Product__c mmprod :lstmmprod) {
	        mmprod.Name = mmprod.SAP_Material_Number__c;
	        String key = mapMMAcct.get(mmprod.Machine_Model__c) + '-' + mmprod.Machine_Model_Product__c;
	        if(mapCustomerPartNumber.containsKey(key)) {
	          mmprod.Customer_Material_Number__c = mapCustomerPartNumber.get(key).Material_Number__c;
	        }
	    }
	}
	
	public static void UpdateMachineAndAcctMetrics(List<Machine_Model_Product__c> lstProducts, List<Machine_Model_Product__c> lstProductsOLD, Boolean isDelete, Boolean isInsert){		//AFTER
		double totalAvgContentPerMachine = 0;
		double SDtotalAvgContentPerMachine = 0;
		double totalTMP = 0; 
		double totalavgContentPerAccount = 0;
		double SDtotalavgContentPerAccount = 0;
		double acctCurrency;
		double exchangeRate = 1.00;
		Map<String, Double> mapCurrency = new Map<String, Double>(); 
		List<CurrencyType> lstCurrency = [Select ConversionRate,IsoCode From CurrencyType];
		Map<Id, List<Machine_Model_Product__c>> mapMachineIdAndLstProds = new Map<Id, List<Machine_Model_Product__c>>(); 
		Map<Id, List<Machine_Model__c>> mapAcctIdAndLstMachines = new Map<Id, List<Machine_Model__c>>(); 
		List<Account> lstAccounts = new List<Account>();
		List<Machine_Model__c> lstMachines = new List<Machine_Model__c>();
		List<Machine_Model_Product__c> lstmmprod = new List<Machine_Model_Product__c>();
		set<Id> setMachineIds = new set<Id>();
		set<Id> setAcctIds = new set<Id>();

		hasTriggerExecuted = true;
		for (CurrencyType c :lstCurrency)
		    mapCurrency.put(c.IsoCode, c.ConversionRate);
		system.debug('lstProducts: ' + lstProducts);
		if (isDelete) {
		    for (Machine_Model_Product__c prod : lstProductsOLD) {
				setMachineIds.add(prod.Machine_Model__c);
				if(!mapMachineIdAndLstProds.containsKey(prod.Machine_Model__c))
					mapMachineIdAndLstProds.put(prod.Machine_Model__c, new List<Machine_Model_Product__c>());
		   }
		}
		else if (isInsert) {
		    for (Machine_Model_Product__c prod : lstProducts) {
				setMachineIds.add(prod.Machine_Model__c);
				if(!mapMachineIdAndLstProds.containsKey(prod.Machine_Model__c))
					mapMachineIdAndLstProds.put(prod.Machine_Model__c, new List<Machine_Model_Product__c>());
		   }
		}
		else {
			for (Machine_Model_Product__c prod : lstProducts) {
				setMachineIds.add(prod.Machine_Model__c);
		    }
		}	
		
		system.debug('mapMachineIdAndLstProds: ' + mapMachineIdAndLstProds);
		
		for(Machine_Model__c mach :[SELECT Account__c FROM Machine_Model__c where Id IN :setMachineIds]){
			setAcctIds.add(mach.Account__c);
		}
		lstAccounts = [SELECT Name, CurrencyIsoCode, Aggregate_Wallet_Share__c, Aggregate_Potential__c 
					   FROM Account WHERE Id IN :setAcctIds];	
		if(isDelete || isInsert){
			lstMachines = [SELECT Name, Account__c, Total_Machine_Potential__c, Annual_Production_Volume_Plus3__c, Average_Content_per_Machine__c, Share_of_Wallet__c 
					  	   FROM Machine_Model__c where Account__c IN :setAcctIds]; 	
		}
		else{
			lstMachines = [SELECT Name, Account__c, Total_Machine_Potential__c, Annual_Production_Volume_Plus3__c, Average_Content_per_Machine__c, Share_of_Wallet__c 
					  	   FROM Machine_Model__c where Total_Machine_Potential__c != NULL and Total_Machine_Potential__c != 0 and Account__c IN :setAcctIds]; 
		}
		for(Machine_Model__c machine :lstMachines){
			if(!setMachineIds.contains(machine.Id))
				setMachineIds.add(machine.Id);
		}
		lstmmprod = [SELECT Adoption_Rate__c, Price__c, CurrencyIsoCode, Number_Per_Machine__c, Supplier__c, Machine_Model__c 
					   FROM Machine_Model_Product__c where IsDeleted = false and Machine_Model__c IN :setMachineIds];
		for(Machine_Model_Product__c p :lstmmprod){
			if(!mapMachineIdAndLstProds.containsKey(p.Machine_Model__c))
				mapMachineIdAndLstProds.put(p.Machine_Model__c, new List<Machine_Model_Product__c>());
			set<Machine_Model_Product__c> setProducts = new set<Machine_Model_Product__c>(mapMachineIdAndLstProds.get(p.Machine_Model__c));
			if(!setProducts.contains(p))
				if(mapMachineIdAndLstProds.containsKey(p.Machine_Model__c))
					mapMachineIdAndLstProds.get(p.Machine_Model__c).add(p);
		}
		for(Machine_Model__c machine :lstMachines){
			if(mapMachineIdAndLstProds.containsKey(machine.Id)){
				if(!mapAcctIdAndLstMachines.containsKey(machine.Account__c)){
					mapAcctIdAndLstMachines.put(machine.Account__c, new List<Machine_Model__c>());
				}
				mapAcctIdAndLstMachines.get(machine.Account__c).add(machine);
			}
		}	
		system.debug('lstmmprod: ' + lstmmprod);
		system.debug('lstMachines: ' + lstMachines);
		if(!lstmmprod.isEmpty() && !lstMachines.isEmpty()){ 			
			system.debug('mapAcctIdAndLstMachines: ' + mapAcctIdAndLstMachines);
			system.debug('mapMachineIdAndLstProds: ' + mapMachineIdAndLstProds);			
			for(Account acct :lstAccounts){
				totalavgContentPerAccount = 0;
				acctCurrency = mapCurrency.get(acct.CurrencyIsoCode);
				for(Machine_Model__c machine :mapAcctIdAndLstMachines.get(acct.Id)){
					totalAvgContentPerMachine = 0;
					SDtotalAvgContentPerMachine = 0;
					for(Machine_Model_Product__c p :mapMachineIdAndLstProds.get(machine.id)){
						exchangeRate = mapCurrency.get(p.CurrencyIsoCode);
					    if (p.Adoption_Rate__c != null && p.Price__c != null && p.Number_Per_Machine__c != null) 
					        totalAvgContentPerMachine += ((p.Price__c / exchangeRate) * p.Number_Per_Machine__c * (p.Adoption_Rate__c/100));   
					    if (p.Adoption_Rate__c != null && p.Price__c != null && p.Number_Per_Machine__c != null && p.Supplier__c == 'Danfoss')    
					        SDtotalAvgContentPerMachine += ((p.Price__c / exchangeRate) * p.Number_Per_Machine__c * (p.Adoption_Rate__c/100));
					}
					totalavgContentPerAccount += totalAvgContentPerMachine * machine.Annual_Production_Volume_Plus3__c;
					SDtotalavgContentPerAccount += SDtotalAvgContentPerMachine * machine.Annual_Production_Volume_Plus3__c;
					//Wallet Share for machine
					if (totalAvgContentPerMachine > 0) 
					    machine.Share_of_Wallet__c = ((SDtotalAvgContentPerMachine * acctCurrency)/(totalAvgContentPerMachine * acctCurrency))*100;
					else
					    machine.Share_of_Wallet__c = 0;
					machine.Average_Content_per_Machine__c = totalAvgContentPerMachine * acctCurrency;
					if (machine.Annual_Production_Volume_Plus3__c != null)
					    machine.Total_Machine_Potential__c = machine.Annual_Production_Volume_Plus3__c * totalAvgContentPerMachine * acctCurrency;
					else
					    machine.Total_Machine_Potential__c = 0;
					if (machine.Total_Machine_Potential__c != null)
		        		totalTMP += machine.Total_Machine_Potential__c;
				}
				update mapAcctIdAndLstMachines.get(acct.Id);
				acct.Aggregate_Potential__c = totalTMP;
				//Wallet Share for acct
				if (totalavgContentPerAccount > 0) 
				    acct.Aggregate_Wallet_Share__c = ((SDtotalavgContentPerAccount * acctCurrency)/(totalavgContentPerAccount * acctCurrency))*100;
				else
				    acct.Aggregate_Wallet_Share__c = 0;
				}
			update lstAccounts;	
			}
		else{
			system.debug('lstMachines: ' + lstMachines);
			for(Account acct :lstAccounts){
				for(Machine_Model__c machine :lstMachines){
					system.debug('machine: ' + machine);
					machine.Share_of_Wallet__c = 0;
					machine.Total_Machine_Potential__c = 0;
					machine.Average_Content_per_Machine__c = 0;
				}
				update lstMachines;
				system.debug('lstMachines: ' + lstMachines);
				acct.Aggregate_Potential__c = 0;
				acct.Aggregate_Wallet_Share__c = 0;
			}
			update lstAccounts;	
		}
	}
}