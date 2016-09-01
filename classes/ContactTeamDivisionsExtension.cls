public class ContactTeamDivisionsExtension {
// DANFOSS - JPK 02-12-2014 
    public String udivs { get; set; }
    
    public ContactTeamDivisionsExtension(ApexPages.StandardController stdController) {
        List<String> divisions = new List<String>();
        for (AggregateResult ar : [select User__r.Division__c div from Contact_Team__c where Contact__c = :stdController.getId() and User__r.Division__c != null group by User__r.Division__c order by User__r.Division__c]) {
            divisions.add((String) ar.get('div'));
        }
        udivs = String.join(divisions, ', ');
    }
}