public class AccountPlanShareOfWalletSupExtension {
    
    private Account_Plan__c ap;
    public ApexPages.StandardSetController setConComp {get;set;}

    public share_of_wallet__c SoWSumComp {get;set;}
    public List<ShareOfWalletProductLineWrapper> sowSums { get; set; }
    
    public AccountPlanShareOfWalletSupExtension(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String> {'Account__c'});
        }
        ap = (Account_Plan__c) stdController.getRecord();
        
        setConComp = new ApexPages.StandardSetController(Database.getQueryLocator([
            select Account__c, CY_Incremental_TO__c, Total_Potential_TO__c, Future_Addressable_TO__c, Future_Addressable_Turnover__c, 
            Target_TO_CY__c, Targer_Turnover_Current_Year__c, SoW_for__c, SoW_Total_Pot_TO__c, 
            Product_Line__c, LY_TO_Baseline__c, CY_Non_Address_TO__c, SoW_Total_Addressable_Turnover__c,
            Supplier_Position__c
            from share_of_wallet__c
            where Account__c = :ap.Account__c 
            order by Product_Line__c
        ]));
        setConComp.setPageSize(setConComp.getResultSize());
    }
    
    public void init() {
        calculateSum(); // Uses DML, so cannot be in constructor
    }
    
    /**
     * Creates a map of SoW summary records to be used for calculation.
     */
    private Map<String, ShareOfWalletSummary> createSummaryMap(){
        Map<String, ShareOfWalletSummary> summaryMap = new Map<String, ShareOfWalletSummary>();
    
        // Extract summaries by product line
        AggregateResult[] arSum = [
            select product_line__c, sum(Total_Potential_TO__c) Total_Potential_TO__c, sum(CY_Incremental_TO__c) CY_Incremental_TO__c, sum(LY_TO_Baseline__c) LY_TO_Baseline__c, sum(CY_Non_Address_TO__c) CY_Non_Address_TO__c
            from share_of_wallet__c
            where Account__c = :ap.Account__c 
            group by product_line__c
        ];
        
        for (AggregateResult ar : arSum ) {
            ShareOfWalletSummary summary = new ShareOfWalletSummary(
                    (String) ar.get('Product_Line__c'),
                    (Decimal) ar.get('Total_Potential_TO__c'),
                    (Decimal) ar.get('CY_Non_Address_TO__c'));
            if (ar.get('Product_Line__c') != null) {
                summaryMap.put((String) ar.get('Product_Line__c'), summary); 
                System.debug(LoggingLevel.INFO, summary + ' added to map for ' + ar.get('Product_Line__c'));   
            }
            else {
                System.debug(LoggingLevel.ERROR, ' Product Line key is null: ' + ar.get('Product_Line__c'));   
            }
        }        
        return summaryMap;
    }

    
    private void calculateSum() {
        sowSums  = new List<ShareOfWalletProductLineWrapper>();
        List<Share_of_Wallet__c> sows = getSowComp();
        Map<String, ShareOfWalletSummary> summaryMap = createSummaryMap();
        
        for(Share_of_Wallet__c sow : sows) {
            ShareOfWalletProductLineWrapper wrapper = null;
            
            ShareOfWalletSummary sowSummary = summaryMap.get(sow.Product_Line__c);
            if (sowSummary != null) {
                wrapper = new ShareOfWalletProductLineWrapper(sow, sowSummary);
                sowSums.add(wrapper);
                System.debug(LoggingLevel.INFO, 'Share Of Wallet wrapper created: ' + wrapper);
            }
        }
        System.debug(LoggingLevel.INFO, 'List of Share Of Wallet wrappers: ' + sowSums);  

        //3rd Feb - UAT defect - added warning 
        /*if (SoWSum.Total_Potential_TO__c < SoWSum.Targer_Turnover_Current_Year__c) {                     
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Total Potential less than Target.');
            ApexPages.addMessage(myMsg);  
        }*/ 

    }
    
    public List<share_of_wallet__c> getSoWComp() {
        return setConComp.getRecords();
    }

    public class ShareOfWalletProductLineWrapper {
        public Share_of_Wallet__c sow { get; set; }
        public ShareOfWalletSummary summary { get; set; }
        
        ShareOfWalletProductLineWrapper(Share_of_Wallet__c sow, ShareOfWalletSummary summary) {
            this.sow = sow;
            this.summary = summary;
        }
        
        public Decimal getTotalPotentialTurnoverFraction() {
            return summary.sumTotalPotentialTurnover > 0 ?
               ((sow.LY_TO_Baseline__c / summary.sumTotalPotentialTurnover)*100).setScale(2, RoundingMode.HALF_UP) : 0;
        }
        
        public Decimal getTotalAddressableTurnoverFraction() {
            return (summary.sumTotalPotentialTurnover - summary.sumTotalAdressableTurnover) > 0 ?
                ((sow.LY_TO_Baseline__c / (summary.sumTotalPotentialTurnover - summary.sumTotalAdressableTurnover))*100).setScale(2, RoundingMode.HALF_UP) : 0;
        }
    }
    
    public class ShareOfWalletSummary {
        String productLine {get; set; }
        public Decimal sumTotalPotentialTurnover { get; set; }
        public Decimal sumTotalAdressableTurnover { get; set; }
        
        ShareOfWalletSummary(String pl, Decimal tpt, Decimal tat) {
            productLine = pl;
            sumTotalPotentialTurnover = tpt != null ? tpt : 0;
            sumTotalAdressableTurnover = tat != null ? tat : 0;
        }
    }

}