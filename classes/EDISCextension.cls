/**
	Author: Erin Fink
	Date:  15APR15
	Version 1.0
**/

public with sharing class EDISCextension{
	
	private EDISC__c disc;
	SObject objDisc;
	private List<EDISC__c> lstDiscs;
	public string edID {get;set;}
	private Contact cont;
	public Integer dominance {get;set;}
	public Integer influence {get;set;}
	public Integer steadiness {get;set;}
	public Integer compliance {get;set;}
	
	public EDISCextension(ApexPages.StandardController stdcontroller) {
		if(stdcontroller.getRecord().Id != null){
			String queryString = EdiscQuery();
			disc = Database.query(queryString + ' where Id = \'' + stdcontroller.getRecord().Id + '\'');
			objDisc = disc;
			dominance = (Integer)disc.Dcalculation__c;
			influence = (Integer)disc.Icalculation__c;
			steadiness = (Integer)disc.Scalculation__c;
			compliance = (Integer)disc.Ccalculation__c;
		}
		else{
			String contId = ApexPages.currentPage().getParameters().get('cont');
        	this.disc = (EDISC__c)stdcontroller.getRecord();
			objDisc = disc;
			disc.Contact__c = contId;						
			dominance = 0;
			influence = 0;
			steadiness = 0;
			compliance = 0;
		}
	}
	
	private String EdiscQuery(){
		List<SObjectField> fieldtokens = Schema.getGlobalDescribe().get('EDISC__c').getDescribe().fields.getMap().values();
		List<string> objectFields = new List<String>();        
        for(SObjectField fieldtoken:fieldtokens) {
            DescribeFieldResult dfr = fieldtoken.getDescribe(); 
            if(dfr.isCreateable())
                objectFields.add(dfr.getLocalName());                       
        }		 
		String fields = '';
        for(string s:objectFields) {
            if(s.contains('Created') == false && s.contains('LastModified') == false)
                fields = fields + s + ','; 
        } 
		fields += 'Contact__r.Name,Dcalculation__c,Icalculation__c,Scalculation__c,Ccalculation__c';
		return 'select ' + String.escapeSingleQuotes(fields) + ' from EDISC__c';
	}
	
	public PageReference redirectToDetailPage() { //only used when creating typical EDISC from Contact
		cont = [select E_DISC__c from Contact where Id = :disc.Contact__c];
		if(cont.E_DISC__c == null){
			cont.E_DISC__c = edID;
			update cont;
		}
		return new PageReference('/'+ disc.Contact__c);
	}

}