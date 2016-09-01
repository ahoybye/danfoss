/**
	* MachineTriggerHandler - Rolls up values
	* @author: Erin Fink
	* @date: 13MAY15
	* @version: 1.0
*/

public with sharing class MachineTriggerHandler{
	
	public static void GetAccountCurrency(List<Machine_Model__c> lstMachines){		//BEFORE INSERT
		for (Machine_Model__c machine : lstMachines) {
	        Account acct = [select currencyisocode from Account where id = :machine.Account__c];
			machine.CurrencyIsoCode = acct.CurrencyIsoCode;
		}
	}
	
	public static void CalculateTotalMachinePotential(List<Machine_Model__c> lstMachines){		//BEFORE UPDATE
		for (Machine_Model__c machine : lstMachines) {
	        if (machine.Average_Content_per_Machine__c != null)
	            machine.Total_Machine_Potential__c = machine.Annual_Production_Volume_Plus3__c * machine.Average_Content_per_Machine__c;
	        }
	}
	
	public static void UpdateAcctMetrics(List<Machine_Model__c> lstMachinesIN){		//AFTER UPDATE and AFTER DELETE
		double totalMachinePotential = 0;
	    double SDtotalMachinePotential = 0;
		double exchangeRate = 1.00;
	    Map<String, Double> mapCurrency = new Map<String, Double>(); 
	    List<CurrencyType> lstCurrency = [Select ConversionRate,IsoCode From CurrencyType];
		Map<Id, List<Machine_Model_Product__c>> mapMachineIdAndLstProds = new Map<Id, List<Machine_Model_Product__c>>(); 
		Map<Id, List<Machine_Model__c>> mapAcctIdAndLstMachines = new Map<Id, List<Machine_Model__c>>();
		List<Account> lstAccounts = new List<Account>();    
		List<Machine_Model__c> lstMachines = new List<Machine_Model__c>();
		List<Machine_Model_Product__c> lstProducts = new List<Machine_Model_Product__c>();
	    
	    for (CurrencyType c :lstCurrency)
	        mapCurrency.put(c.IsoCode, c.ConversionRate);
	        
	    for (Machine_Model__c machine : lstMachinesIN) {
			if(!mapAcctIdAndLstMachines.containsKey(machine.Account__c))
				mapAcctIdAndLstMachines.put(machine.Account__c, new List<Machine_Model__c>());
	    }
		
		lstMachines = [SELECT Name, Account__c, Total_Machine_Potential__c, Annual_Production_Volume_Plus3__c, Average_Content_per_Machine__c, Share_of_Wallet__c 
					   FROM Machine_Model__c where Account__c IN :mapAcctIdAndLstMachines.keySet()];	
		for(Machine_Model__c machine :lstMachines){
			if(!mapMachineIdAndLstProds.containsKey(machine.Id))
				mapMachineIdAndLstProds.put(machine.Id, new List<Machine_Model_Product__c>());
			set<Machine_Model__c> setMachines = new set<Machine_Model__c>(mapAcctIdAndLstMachines.get(machine.Account__c));
			if(!setMachines.contains(machine))
				mapAcctIdAndLstMachines.get(machine.Account__c).add(machine);	
		}
		
		lstProducts = [SELECT Adoption_Rate__c, Price__c, CurrencyIsoCode, Total_Product_value__c, Number_Per_Machine__c, Supplier__c, Machine_Model__c 
					   FROM Machine_Model_Product__c where IsDeleted = false and Machine_Model__c IN :mapMachineIdAndLstProds.keySet()];
		for(Machine_Model_Product__c p :lstProducts){
			set<Machine_Model_Product__c> setProducts = new set<Machine_Model_Product__c>(mapMachineIdAndLstProds.get(p.Machine_Model__c));
			if(!setProducts.contains(p))
				mapMachineIdAndLstProds.get(p.Machine_Model__c).add(p);
		}	
		
	    lstAccounts = [SELECT Name, CurrencyIsoCode, Aggregate_Wallet_Share__c, Aggregate_Potential__c 
					   FROM Account WHERE Id IN :mapAcctIdAndLstMachines.keySet()];
		for(Account acct :lstAccounts){
			for (Machine_Model__c machine :mapAcctIdAndLstMachines.get(acct.Id)) {
				for (Machine_Model_Product__c p : mapMachineIdAndLstProds.get(machine.Id)) {
					exchangeRate = mapCurrency.get(p.CurrencyIsoCode);				
		        	totalMachinePotential += (p.Total_Product_value__c / exchangeRate);		
				    if (p.Supplier__c == 'Danfoss')    
				        SDtotalMachinePotential += (p.Total_Product_value__c / exchangeRate);
				    }
				}			
			acct.Aggregate_Potential__c = totalMachinePotential * mapCurrency.get(acct.CurrencyIsoCode);
		    if (totalMachinePotential > 0)
		        acct.Aggregate_Wallet_Share__c = ((SDtotalMachinePotential * mapCurrency.get(acct.CurrencyIsoCode))/(totalMachinePotential * mapCurrency.get(acct.CurrencyIsoCode)))*100;
		    else
		        acct.Aggregate_Wallet_Share__c = 0;
		}
		update lstAccounts;	
	}
}