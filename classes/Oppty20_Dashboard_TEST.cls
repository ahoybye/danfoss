@isTest
private class Oppty20_Dashboard_TEST {
    public static Opportunity_Trending__c opp_trend;
    
    static void setupUserPreferences() {
        Oppty20_User_Preferences__c userPref = new Oppty20_User_Preferences__c();
        userPref.Name = Userinfo.getUserId();
        userPref.Team__c = Userinfo.getUserId();
        userPref.Segment__c = '["Cooling"]';
        userPref.Region__c = '["India"]';
        userPref.Country__c = '["IN"]';

        Period p = [SELECT Id FROM Period Where StartDate = THIS_FISCAL_YEAR AND Type = 'Month' AND Number=1]; // January
        userPref.Time_Period__c = p.Id;

        CurrencyType ct = [SELECT Id FROM CurrencyType WHERE IsActive=true AND IsCorporate=true];
        userPref.Currency__c = ct.Id;
        
        insert userPref;
        system.assert(userPref.Id != null);
    }

    static void setupReportData() {
        Oppty20_Reports__c r = new Oppty20_Reports__c();
        r.Name = 'Shape';
        r.Report_Id__c = '12345';
        r.Segment_Field_Id__c = '12345';
        r.Region_Field_Id__c = '12345';
        r.Country_Field_Id__c = '12345';
        insert r;
        system.assert(r.Id != null);
    }
    
    static void setupOpportunityData() {
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Division__c = 'Cooling';
        insert acct;
        
        system.assert(acct.Id != null);
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acct.Id;
        opp.Amount = 100000;
        opp.CE_Sales_model__c = 'End user';

        Integer nYear = Date.today().year();
        opp.CloseDate = Date.newInstance(nYear, 1, 1); // the default selectedTime field value in the controller is January        
        opp.Reason__c = 'Quality';
		opp.StageName = 'Closed-Won';
        insert opp;
        
        system.assert(opp.Id != null);
    }
    
    static void setupTrendData() {
        opp_trend = new Opportunity_Trending__c();
        opp_trend.Stage__c = 'Identifying Opportunity (CE)';
        opp_trend.Amount__c = 100;
        opp_trend.opportunity_count__c = 1;
        opp_trend.Average_Probability_Weighted__c = 50;
        
        Integer nYear = Date.today().year();
        opp_trend.Period__c = Date.newInstance(nYear, 1, 1); // the default selectedTime field value in the controller is January
        opp_trend.Segment__c = 'Cooling';
        opp_trend.Region__c = 'India';
        opp_trend.Country__c = 'IN';
        opp_trend.OwnerId__c = UserInfo.getUserId(); 
        
        opp_trend.Overdue_count__c = 2;
        opp_trend.Inactive_count__c = 0;
        opp_trend.Overaged_count__c = 3;
        opp_trend.SizeChange_count__c = 5;

        opp_trend.Stalled_count__c = 1;
        opp_trend.ExtraLarge_count__c = 2;
        opp_trend.TimeSlip_count__c = 0;
        opp_trend.sizechange_amount__c = 50;
        opp_trend.overaged_amount__c = 10;
        opp_trend.inactive_amount__c = 10;
        opp_trend.Amount_at_Risk__c = 30;
        opp_trend.overdue_amount__c = 15;
        opp_trend.timeslip_amount__c = 10;

        insert opp_trend;
        system.assert(opp_trend.Id != null); 

        // Help text
        My_Pipeline_Starter_Question__c q = new My_Pipeline_Starter_Question__c();
        q.Name = 'Flow';
        q.Question_Body__c ='Flow help text';
        insert q;
        system.assert(q.Id != null);
    }
   
    static void setupForecastData() {
        ForecastingType ft = [SELECT Id FROM ForecastingType WHERE DeveloperName='OpportunityRevenue'];
        system.assert(ft.Id != null);

        List<ForecastingQuota> lstfq = new List<ForecastingQuota>();
        
        for(Period p : [SELECT Id, StartDate FROM Period Where StartDate = THIS_FISCAL_YEAR AND Type = 'Month']) {
            ForecastingQuota fq = new ForecastingQuota();
            fq.QuotaAmount = 100;
            fq.StartDate = p.StartDate;
            fq.ForecastingTypeId = ft.Id;
            lstfq.add(fq);
        }
        
        insert lstfq;
    }

    static testMethod void testSizeData() {
        setupUserPreferences();
            
        Test.startTest();
        
        Oppty20Controller ctrl = new Oppty20Controller();
        ctrl.getSizeData();
                
        Test.stopTest();
    }

    static testMethod void testFlowData() {
        setupTrendData();
            
        Test.startTest();
        
        Oppty20Controller ctrl = new Oppty20Controller();
        ctrl.selectedTeamMember = UserInfo.getUserId();
        
        ctrl.selectedSegments[0] = 'Cooling'; 
        ctrl.selectedRegions[0] = 'India'; 
        ctrl.selectedCountries[0] = 'IN'; 
        ctrl.getFlowData();
                
        Test.stopTest();
    }

    static testMethod void testShapeData() {
        setupTrendData();
            
        Test.startTest();
        
        Oppty20Controller ctrl = new Oppty20Controller();
        ctrl.selectedTeamMember = UserInfo.getUserId();
        
        ctrl.selectedSegments[0] = 'Cooling'; 
        ctrl.selectedRegions[0] = 'India'; 
        ctrl.selectedCountries[0] = 'IN'; 
        ctrl.getShapeData();
        
        ctrl.sHelpHint = 'Flow';
        ctrl.getHelp();
        system.assertEquals(ctrl.sHelpText, 'Flow help text');
        
        Test.stopTest();  
    }

    static testMethod void testQualityData() {
        setupTrendData();
            
        Test.startTest();
        
        Oppty20Controller ctrl = new Oppty20Controller();
        ctrl.selectedTeamMember = UserInfo.getUserId();
        
        ctrl.selectedSegments[0] = 'Cooling'; 
        ctrl.selectedRegions[0] = 'India'; 
        ctrl.selectedCountries[0] = 'IN'; 
        ctrl.getQualityData();
               
        Test.stopTest();  
    }

    static testMethod void testNetWinData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u2 = new User(Alias = 'newUser', Email='oppty20@danfoss.com',
                EmailEncodingKey='UTF-8', LastName='Oppty20', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId=p.Id, ForecastEnabled=true,
                TimeZoneSidKey='America/Los_Angeles', UserName='oppty20@danfoss.com',
                Division__c='Cooling', Region__c='India', User_Country__c='IN');

        System.runAs(u2) {                  
            setupForecastData(); // needed to run as u2
            
            Test.startTest();
        
            Oppty20Controller ctrl = new Oppty20Controller();
            ctrl.selectedTeamMember = 'All'; // UserInfo.getUserId();
            
            ctrl.selectedSegments[0] = 'Cooling'; 
            ctrl.selectedRegions[0] = 'India'; 
            ctrl.selectedCountries[0] = 'IN'; 
            
            ctrl.getNetWinData();
                   
            Test.stopTest();  
        }
    }

    static testMethod void testNetWinTrendData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u2 = new User(Alias = 'newUser', Email='oppty20@danfoss.com',
                EmailEncodingKey='UTF-8', LastName='Oppty20', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId=p.Id, ForecastEnabled=true,
                TimeZoneSidKey='America/Los_Angeles', UserName='oppty20@danfoss.com',
                Division__c='Cooling', Region__c='India', User_Country__c='IN');

        System.runAs(u2) {                  
            setupForecastData(); // needed to run as u2
            setupOpportunityData();
            setupReportData();
            
            Test.startTest();
        
            Oppty20Controller ctrl = new Oppty20Controller();
            ctrl.selectedTeamMember = UserInfo.getUserId();
            
            ctrl.selectedSegments[0] = 'Cooling'; 
            ctrl.selectedRegions[0] = 'India'; 
            ctrl.selectedCountries[0] = 'IN'; 
            
            ctrl.getNetWinTrendData();

            // test also other methods
            ctrl.initOppty20();
            
            ctrl.sReportHint = 'Shape';
            ctrl.getReport();
                               
            Test.stopTest();  
        }
    }

}