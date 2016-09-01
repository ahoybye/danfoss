/**
	Author: Erin Fink
	Date: 11JUL15
	Version 1.0
**/

trigger InfluencerGridTrigger on Influencer_Grid__c bulk (after delete) {
	Set<Id> setOpptyIds = new set<Id>();
	Set<Id> setContactIds = new set<Id>();
	for(Influencer_Grid__c grid :trigger.old){
		setOpptyIds.add(grid.Opportunity__c);
		setContactIds.add(grid.Contact__c);
	}
	Map<Id, EDISC__c> mapEDISCs = new map<Id, EDISC__c>([select Id from EDISC__c where Opportunity__c IN :setOpptyIds and Contact__c = :setContactIds]);
	delete mapEDISCs.values();
}