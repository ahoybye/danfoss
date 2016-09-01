public with sharing class SalesOrgTriggerHandler{
        
    public static void populateSalesOrgFields(List<Sales_Org__c> lstSOs, Map<string, Application__c> mapApplications){  //BEFORE
        for (Sales_Org__c sOrg : lstSOs) {  
            if(sOrg.Application__c != null && sOrg.Application__c != ''){
                if(mapApplications.get(sOrg.Application__c) != null){
                    sOrg.App_Description__c = mapApplications.get(sOrg.Application__c).Name;
                    sOrg.Market_Segment__c = mapApplications.get(sOrg.Application__c).Market_Segment__c;
                }
                else{
                    sOrg.App_Description__c = '';
                    sOrg.Market_Segment__c = '';
                }
            }
        }   
    } 
    
    public static void populateAccountFields(Set<Id> setaccountIds, Map<string, Application__c> mapApplications){       //AFTER
        String apps = '';   
        String segs = '';   
        List<Sales_Org__c> lstSOs = new List<Sales_Org__c>([select Account__c, Application__c, Market_Segment__c, App_Description__c From Sales_Org__c where Account__c IN :setaccountIds]);
        Map <Id,Account> mapAccounts =  new Map<Id,Account>([Select Id, Applications__c, Market_Segment__c from Account where Id in :setaccountIds]);
        for (Sales_Org__c sOrg : lstSOs) {      
            if(sOrg.Account__c != null) {
                Account act = mapAccounts.get(sOrg.Account__c);
                if(mapApplications.get(sOrg.Application__c) != null){
    				if(sOrg.Application__c != null && sOrg.Application__c != ''){
                        if (apps == '')
                            apps = mapApplications.get(sOrg.Application__c).Name;
                        else if(!apps.contains(mapApplications.get(sOrg.Application__c).Name))
                            apps += ', ' + mapApplications.get(sOrg.Application__c).Name;
                        if (segs == '')
                            segs = mapApplications.get(sOrg.Application__c).Market_Segment__c;
                        else if(!segs.contains(mapApplications.get(sOrg.Application__c).Market_Segment__c))
                            segs += ', ' + mapApplications.get(sOrg.Application__c).Market_Segment__c;
                    }
                }
                act.Applications__c = apps;
                act.Market_Segment__c = segs;
            }
        }   
        update mapAccounts.Values();
    } 
}