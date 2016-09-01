public class AccountTeamDivisionsExtension {
// DANFOSS - JPK 02-12-2014 
    public String udivs { get; set; }
    
    public AccountTeamDivisionsExtension(ApexPages.StandardController stdController) {
        List<String> divisions = new List<String>();
        for (AggregateResult ar : [select User.Division__c div from AccountTeamMember where AccountId = :stdController.getId() and User.Division__c != null group by User.Division__c order by User.Division__c]) {
            divisions.add((String) ar.get('div'));
        }
        udivs = String.join(divisions, ', ');
        
    }
}