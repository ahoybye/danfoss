public class AccountPlanShareOfWalletExtension {
    
    private Account_Plan__c ap;
    public ApexPages.StandardSetController setCon {get;set;}
    public ApexPages.StandardSetController setConComp {get;set;}
    public share_of_wallet__c SoWSum {get;set;}
    public share_of_wallet__c SoWSumComp {get;set;}
    
    public AccountPlanShareOfWalletExtension(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String> {'Account__c'});
        }
        ap = (Account_Plan__c) stdController.getRecord();
        
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator([
            select Account__c, CY_Incremental_TO__c, Total_Potential_TO__c, Future_Addressable_TO__c, Future_Addressable_Turnover__c, Target_TO_CY__c, Targer_Turnover_Current_Year__c, SoW_for__c, SoW_Total_Pot_TO__c, Product_Line__c, LY_TO_Baseline__c, CY_Non_Address_TO__c, SoW_Total_Addressable_Turnover__c
            from share_of_wallet__c
            where Account__c = :ap.Account__c and SoW_for__c = 'Danfoss'
            order by Product_Line__c
        ]));
        setCon.setPageSize(3);
        setConComp = new ApexPages.StandardSetController(Database.getQueryLocator([
            select Account__c, CY_Incremental_TO__c, Total_Potential_TO__c, Future_Addressable_TO__c, Future_Addressable_Turnover__c, 
            Target_TO_CY__c, Targer_Turnover_Current_Year__c, SoW_for__c, SoW_Total_Pot_TO__c, 
            Product_Line__c, LY_TO_Baseline__c, CY_Non_Address_TO__c, SoW_Total_Addressable_Turnover__c,
            Supplier_Position__c
            from share_of_wallet__c
            where Account__c = :ap.Account__c 
            //and Type__c ='Competitor'
            order by Product_Line__c
        ]));
        setConComp.setPageSize(setConComp.getResultSize());
    }
    
    public void init() {
        calculateSum(); // Uses DML, so cannot be in constructor
    }
    
    private void calculateSum() {
        // Calculate the sums. SOQL will return them in the corporate currency
        AggregateResult arDanfossSum = [
            select sum(Total_Potential_TO__c) Total_Potential_TO__c, sum(CY_Incremental_TO__c) CY_Incremental_TO__c, sum(LY_TO_Baseline__c) LY_TO_Baseline__c, sum(CY_Non_Address_TO__c) CY_Non_Address_TO__c
            from share_of_wallet__c
            where Account__c = :ap.Account__c and SoW_for__c = 'Danfoss'
        ];
        AggregateResult arCompetitorSum = [
            select sum(Total_Potential_TO__c) Total_Potential_TO__c, sum(CY_Incremental_TO__c) CY_Incremental_TO__c, sum(LY_TO_Baseline__c) LY_TO_Baseline__c, sum(CY_Non_Address_TO__c) CY_Non_Address_TO__c
            from share_of_wallet__c
            where Account__c = :ap.Account__c 
            //and Type__c ='Competitor'
        ];
        // Store the sums in a dummy Sobject. This is required in order to use the standard currency display functionality in Visualforce.
        SoWSum = new share_of_wallet__c(
            Account__c = ap.Account__c,
            CurrencyIsoCode = [select IsoCode from CurrencyType where IsCorporate = true].IsoCode,
            Total_Potential_TO__c = (Decimal) arDanfossSum.get('Total_Potential_TO__c'),
            CY_Incremental_TO__c = (Decimal) arDanfossSum.get('CY_Incremental_TO__c'),
            LY_TO_Baseline__c = (Decimal) arDanfossSum.get('LY_TO_Baseline__c'),
            CY_Non_Address_TO__c = (Decimal) arDanfossSum.get('CY_Non_Address_TO__c'),
            //6th Feb Added to allow uniqueness field on SoW
            Type__c = 'SoWSum'
        );
        SoWSumComp = new share_of_wallet__c(
            Account__c = ap.Account__c,
            CurrencyIsoCode = [select IsoCode from CurrencyType where IsCorporate = true].IsoCode,
            Total_Potential_TO__c = (Decimal) arCompetitorSum.get('Total_Potential_TO__c'),
            CY_Incremental_TO__c = (Decimal) arCompetitorSum.get('CY_Incremental_TO__c'),
            LY_TO_Baseline__c = (Decimal) arCompetitorSum.get('LY_TO_Baseline__c'),
            CY_Non_Address_TO__c = (Decimal) arCompetitorSum.get('CY_Non_Address_TO__c'),
            //6th Feb Added to allow uniqueness field on SoW
            Type__c = 'SoWSumComp'
        );
        
        // Temporarly save the dummy Sobject, retrieve it and delete it. This ensures that formula fields are calculated.
        Savepoint sp = Database.setSavepoint();
        insert SoWSum;
        insert SoWSumComp;
        SoWSum     = [select Total_Potential_TO__c, CY_Incremental_TO__c, LY_TO_Baseline__c, Targer_Turnover_Current_Year__c, CY_Non_Address_TO__c, Future_Addressable_Turnover__c, SoW_Total_Pot_TO__c, SoW_Total_Addressable_Turnover__c from share_of_wallet__c where Id = :SoWSum.Id];
        SoWSumComp = [select Total_Potential_TO__c, CY_Incremental_TO__c, LY_TO_Baseline__c, Targer_Turnover_Current_Year__c, CY_Non_Address_TO__c, Future_Addressable_Turnover__c, SoW_Total_Pot_TO__c, SoW_Total_Addressable_Turnover__c from share_of_wallet__c where Id = :SoWSumComp.Id];
        Database.rollback(sp);
        
        //3rd Feb - UAT defect - added warning 
                if (SoWSum.Total_Potential_TO__c < SoWSum.Targer_Turnover_Current_Year__c) {                     
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Total Potential less than Target.');
            ApexPages.addMessage(myMsg);  
        } 


    }
    
    public List<share_of_wallet__c> getSoW() {
        return setCon.getRecords();
    }
    
    public List<share_of_wallet__c> getSoWComp() {
        return setConComp.getRecords();
    }
    
}