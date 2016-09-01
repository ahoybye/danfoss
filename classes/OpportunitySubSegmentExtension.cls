public class OpportunitySubSegmentExtension {
    
    private Opportunity opp;
    public boolean renderdirect { get; set; }
    
    public OpportunitySubSegmentExtension(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String> {'Account.Sub_Segment__c', 'Account.Secondary_Sub_Segment__c', 'Secondary_Segment__c'});
        }
        renderdirect = false;
        opp = (Opportunity) stdController.getRecord();
    }
    
    public void SecondarySubSegment() {
        opp.Chosen_Sub_Segment__c = opp.Account.Secondary_Sub_Segment__c;
        if (opp.Secondary_Segment__c == false) {
            opp.Main_Application__c = null;
        }
        opp.Secondary_Segment__c = true;
        update opp;
        renderdirect = true;
    }
    
    public void PrimarySubSegment() {
        opp.Chosen_Sub_Segment__c = opp.Account.Sub_Segment__c;
        if (opp.Secondary_Segment__c == true) {
            opp.Main_Application__c = null;
        }
        opp.Secondary_Segment__c = false;
        update opp;
        renderdirect = true;
    }    
}