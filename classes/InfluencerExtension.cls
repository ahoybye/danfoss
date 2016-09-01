/**
	Author: Erin Fink
	Date: 15JUN15
	Version 1.0
**/

public with sharing class InfluencerExtension{

    private Influencer_Grid__c grid;
	private integer i;
	private integer j;
	private Map<String, String> mapFieldNamesandValues= new Map<String, String>();
	SObject objDisc{get;set;}
	public Boolean discSelected {get;set;}
	public string edID {get;set;}
	public Boolean newTypicalEdisc {get;set;}
	public List<EDISC__c> lstDiscs {get;set;}
	public EDISC__c disc {get;set;}
	private Contact cont;
	public Integer dominance {get;set;}
	public Integer influence {get;set;}
	public Integer steadiness {get;set;}
	public Integer compliance {get;set;}
	private Influencer_Grid__c pgrid {
		get{
			if(pgrid == null){
				pgrid = this.grid;
			}
			return pgrid;
		}
		set;
	}
		
	public class applicationException extends Exception {}
		
    public InfluencerExtension(ApexPages.standardController stdcontroller){
        this.grid = (Influencer_Grid__c)stdcontroller.getRecord();				
		dominance = 0;
		influence = 0;
		steadiness = 0;
		compliance = 0;
	}
	
	public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Most','Most')); 
        options.add(new SelectOption('Least','Least')); 
		return options; 
    }
	
	public PageReference findDiscs(){
		System.debug('fired');
		ApexPages.getMessages().clear();
		if(grid.Contact__c != null){
			String queryString = EdiscQuery(null, false);
			lstDiscs = Database.query(queryString + ' where Contact__c = \'' + grid.Contact__c + '\'' + ' and Opportunity__c = \'' + grid.Opportunity__c + '\'' + ' limit 1');
			if(!lstDiscs.isEmpty()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, lstDiscs[0].Contact__r.Name + ' is already listed on this opportunity.'));
				return null;
			}
			else{
				Contact cont = [select Id, Title, Friend_Enemy__c, Typical_Buying_Center_Role__c from Contact where Id = :grid.Contact__c];
				grid.Role_In_The_Buying_Center__c = cont.Typical_Buying_Center_Role__c;
				grid.Friend_Enemy__c = cont.Friend_Enemy__c;
				grid.Title__c = cont.Title;
				discSelected = true;
				lstDiscs = Database.query(queryString + ' where Contact__c = \'' + grid.Contact__c + '\'' + ' and Opportunity__c = null limit 1');
				if(!lstDiscs.isEmpty()){
					newTypicalEdisc = false;
					edID = lstDiscs[0].Id;
					objDisc = cloneEDISC(edID, 'EDISC__c');
					disc = (EDISC__c)objDisc;
					dominance = (Integer)disc.Dcalculation__c;
					influence = (Integer)disc.Icalculation__c;
					steadiness = (Integer)disc.Scalculation__c;
					compliance = (Integer)disc.Ccalculation__c;
				}
				else { //no typical EDISC exists for the selected contact
					newTypicalEdisc = true;		
				}
			}
		}
		return null;
	}
	
	public PageReference SaveGrid() { //only called when it's a new record
		try {
			if(edID!=null && edID!='')
			{
				pgrid.EDISC__c = (Id)edID;
			}
			if(newTypicalEdisc){
				objDisc = cloneEDISC(edID, 'EDISC__c');
				disc = (EDISC__c)objDisc;
				disc.Opportunity__c = null;
				insert disc;
				cont = [select E_DISC__c from Contact where Id = :disc.Contact__c];
				if(cont.E_DISC__c == null){
					cont.E_DISC__c = disc.Id;
					update cont;
				}		
			}	
			insert grid;
		}
		catch (Exception ex) {
			ApexPages.addMessages(ex);
			return null;
		}
		return new PageReference('/'+ grid.Opportunity__c);
	}
	
	private SObject cloneEDISC(String recId, String objAPIName){
        String queryString = EdiscQuery(edID, true);
        SObject result = Database.query(queryString);  
        Sobject copy = result.clone(false, true);    
        copy.put('Opportunity__c', grid.Opportunity__c);
		return copy;
	}
	
	private String fieldList(){
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
        return fields.substring(0, fields.lastIndexOf(','));
	}
	
	private String EdiscQuery(String recId, Boolean isClone){
		String fields = fieldList();
		fields += ',Contact__r.Name,Dcalculation__c,Icalculation__c,Scalculation__c,Ccalculation__c';
		//if(!isClone)
		//	fields += ',Dcalculation__c,Icalculation__c,Scalculation__c,Ccalculation__c';
		if(recId == null)
			return 'select ' + String.escapeSingleQuotes(fields) + ' from EDISC__c';
		else
			return 'select ' + String.escapeSingleQuotes(fields) + ' from EDISC__c where id= \'' + String.escapeSingleQuotes(recId) + '\'';
	}

}