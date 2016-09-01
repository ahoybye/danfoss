public class OpportunityCloseExtension {
    
    private ApexPages.StandardController stdController;
    private Opportunity opp;
    //public Boolean cc {get;set;}
    //public Boolean de {get;set;}
    public Boolean rc {get;set;}
    public Boolean hs {get;set;}
    public Boolean pe {get;set;}    
    private string division;
    
    public OpportunityCloseExtension(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String> {'CE_Division__c'});
        }
        opp = (Opportunity) stdController.getRecord();
        division = opp.CE_Division__c;
        hs = division == 'Heating';
        //de = division == 'NA - District Energy';
        rc = division == 'Cooling';
        pe = division == 'Drives';
        //cc = division == 'NA - Commercial Compressors';
    }
    
    public PageReference closeOpp() {
        if (division == 'Heating') { opp.Sub_reason__c=opp.CE_HS_Sub_reason__c; }
        //if (division == 'NA - District Energy') { opp.Sub_reason__c=opp.CE_DE_Sub_reason__c; }
        if (division == 'Cooling') { opp.Sub_reason__c=opp.CE_RC_Sub_reason__c; }
        if (division == 'Drives') { opp.Sub_reason__c=opp.CE_PE_Sub_reason__c; }
        //if (division == 'NA - Commercial Compressors') { opp.Sub_reason__c=opp.CE_CC_Sub_reason__c; }
        return stdController.save();
    }
    
}