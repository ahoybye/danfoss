public class Oppty20Controller {  
    public String sHelpHint {get;set;} // Help hint
    public String sHelpText {get;set;} // Help content

    public String sReportHint {get;set;} // Report hint
    public String sReportUrl {get;set;} // Report url

    public List<String> qcheck_data {get;set;} // Data for the Q Check component
    //public List<String> qindex_data {get;set;} // Data for the Q Index component
    //public List<String> netwin_data {get;set;} // Data for the Net Win component
    public List<String> netwin_trend_data {get;set;} // Data for the Net Win Trend component
    //public List<String> size_data {get;set;} // Data for the Size component
    //public List<String> stage_data {get;set;} // Data for the Stages component
    //public List<String> flow_data {get;set;} // Data for the Flow component
    public List<String> shapeflow_data {get;set;} // Data for the Shape & Flow component
    public List<String> winrate_data {get;set;} // Data for the Win Rate component    
    
    public List<SelectOption> segmentOptions {get;set;}
    public List<SelectOption> regionOptions {get;set;}
    public List<SelectOption> teamOptions {get;set;}
    public List<SelectOption> timeOptions {get;set;}
    public List<SelectOption> countryOptions {get;set;}
    public List<SelectOption> currencyOptions {get;set;}
    
    private List<DatedConversionRate> datedRates;

    public List<String> oppRecordTypes = new List<String> { 'Climate and Energy Open Opportunity', 'Project Opportunity' };
    //public List<String> oppRecordTypeIds = new List<String> {};
    public List<RecordType> oppRecordTypeIds = new List<Recordtype> {};
    private List<String> userIds = new List<String> {};
        
    public String[] selectedSegments {get; set;}
    public String[] selectedRegions {get; set;}
    public String[] selectedCountries {get; set;}

    public String selectedTeamMember {get; set;}
    public String selectedTime {get; set;}
    public String selectedCurrency {get; set;}
    
    public VF_dummy__c dummy {get;set;}
    
    private String prevViewAsUserId;    
    private String runningUserId;
    private Map<Id, Period> mapPeriods;
    private Map<String, Decimal> mapCurrencies;

    private Oppty20_User_Preferences__c userPref;
    
    private Map<String, String> periodLabels = new Map<String, String> {
            'Month-1' => 'January',
            'Month-2' => 'February',
            'Month-3' => 'March',
            'Month-4' => 'April',
            'Month-5' => 'May',
            'Month-6' => 'June',
            'Month-7' => 'July',
            'Month-8' => 'August',
            'Month-9' => 'September',
            'Month-10' => 'October',
            'Month-11' => 'November',
            'Month-12' => 'December'
        };
    
    // The Net Win Target Amount - is referenced from Size section
    //private Decimal netWinTargetAmount = 0;
    // The Net Win Realized Amount  - is referenced from Size section
    //private Decimal netWinRealizedAmount = 0;
    // The Shape total amount/size  - is referenced from Size section
    //private Decimal shapeTotalAmount = 0;
    // The Shape total number  - is referenced from Size section
    //private Integer shapeTotalNumber = 0;
    
    Decimal global_ttot = 0;
    Decimal global_wtot = 0;
    Decimal global_CalendarYearSizeTotal = 0;    
    
    // Corporate currency
    private CurrencyType orgDefaultCurrency = [SELECT Id, IsoCode, ConversionRate 
        FROM CurrencyType WHERE IsActive = true AND IsCorporate = true LIMIT 1];
    
    public Oppty20Controller() {
      	runningUserId = UserInfo.getUserId();
       
        selectedSegments = new String[]{}; // Initialize
        selectedRegions = new String[]{}; // Initialize
        selectedCountries = new String[]{}; // Initialize
  
        // Get the Id's of the allowed opportunity recordtypes    
        //List<Recordtype> oppRecordTypeIds = Database.query('SELECT id FROM recordtype where (name in : oppRecordTypes)');
		oppRecordTypeIds = Database.query('SELECT id FROM recordtype where (name in : oppRecordTypes)');
		System.debug(LoggingLevel.INFO, '@@ Oppty20Controller ' + oppRecordTypes + ' * ' + oppRecordTypeIds);        
        
        dummy = new VF_dummy__c();
        dummy.user__c = UserInfo.getUserId();
        
        // Read the 2 custompermissions for managers
        //CustomPermission MyPipelineUseAllDanfoss = new CustomPermission();
   	 	//MyPipelineUseAllDanfoss = [SELECT Id FROM CustomPermission WHERE DeveloperName = 'MyPipelineUseAllDanfoss'];        
        //List <CustomPermission> customPermissions = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'MyPipelineUseAllDanfoss'];
        //List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId FROM SetupEntityAccess
        //	WHERE SetupEntityId in :customPermissionNamesById.keySet() AND ParentId IN (SELECT PermissionSetId
        //    FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId())];
		CustomPermissionsReader cpr = new CustomPermissionsReader(Account.SObjectType);

		// Assert the CustomPermissionsReader confirms custom permission assigned
        IF (cpr.hasPermission('MyPipelineUseAllDanfoss')) {
        	System.debug(LoggingLevel.INFO, '@@ Has MyPipelineUseAllDanfoss');   
        } else {
         	System.debug(LoggingLevel.INFO, '@@ Has Not MyPipelineUseAllDanfoss');            
        }     
    
        setupTeamPicklist();

        // Setup segment picklist
        segmentOptions = new List<SelectOption>();
        IF (cpr.hasPermission('MyPipelineUseAllDanfoss')) {
        	segmentOptions.add(new SelectOption('All','All Danfoss'));
        }
        Schema.DescribeFieldResult brDesc = User.Division__c.getDescribe();
        List<Schema.PicklistEntry> listEntry = brDesc.getPicklistValues();
        for(Schema.PicklistEntry f : listEntry) {
            segmentOptions.add(new SelectOption(f.getLabel(), f.getLabel()));
        }                 
        selectedSegments.add(segmentOptions[0].getValue()); // default selection (all danfoss)
        
        // Setup the region picklist
        regionOptions = new List<SelectOption>();
        regionOptions.add(new SelectOption('All','All Regions'));
        brDesc = User.Region__c.getDescribe();
        listEntry = brDesc.getPicklistValues();
        for(Schema.PicklistEntry f : listEntry) {
            regionOptions.add(new SelectOption(f.getLabel(), f.getLabel()));
        }                 
        selectedRegions.add(regionOptions[0].getValue()); // default selection (all regions)

        // Setup the country picklist
        countryOptions = new List<SelectOption>();
        countryOptions.add(new SelectOption('All','All Countries'));
        brDesc = User.User_Country__c.getDescribe();
        listEntry = brDesc.getPicklistValues();
        for(Schema.PicklistEntry f : listEntry) {
            countryOptions.add(new SelectOption(f.getLabel(), f.getLabel()));
        }                 
        selectedCountries.add(countryOptions[0].getValue()); // default selection (all countries)
                
        // Setup time period
        timeOptions = new List<SelectOption>();
        mapPeriods = new Map<Id, Period>();
        for(Period p : [SELECT Id, StartDate, EndDate,FiscalYearSettingsId,IsForecastPeriod,Number,PeriodLabel,QuarterLabel,Type FROM Period Where StartDate = THIS_YEAR AND Type = 'Month']) {
            mapPeriods.put(p.Id, p);
            timeOptions.add(new SelectOption(p.Id, periodLabels.get(p.Type + '-' + p.Number)));
        }
        selectedTime = timeOptions[0].getValue(); // default selection in the listbox
                       
        // Setup currencies
        currencyOptions = new List<SelectOption>();
        mapCurrencies = new Map<String, Decimal>();
        // Add the corporate currency as the below soql will not fetch it
        mapCurrencies.put(orgDefaultCurrency.isoCode, orgDefaultCurrency.conversionRate);
        // Set the default currency - will be overwritten if the user has stored another currency in filter preferences
        currencyOptions.add(new SelectOption(orgDefaultCurrency.isoCode, orgDefaultCurrency.isoCode));
        selectedCurrency = UserInfo.getDefaultCurrency();
        // Get all date conversion rates in the org
        for(DatedConversionRate dcr : [SELECT Id, IsoCode, ConversionRate FROM DatedConversionRate WHERE StartDate = THIS_YEAR]) {
            mapCurrencies.put(dcr.IsoCode, dcr.ConversionRate);
            currencyOptions.add(new SelectOption(dcr.IsoCode, dcr.IsoCode));
        }
        currencyOptions.sort();

        // setup or read user preferences
        userPref = Oppty20_User_Preferences__c.getInstance(runningUserId);
        if(userPref == null) {
            userPref = new Oppty20_User_Preferences__c();
            userPref.Name = runningUserId;
        }
        else {
            selectedTeamMember = userPref.Team__c;
            selectedSegments = (List<String>) System.JSON.deserialize(userPref.Segment__c, List<String>.class);
            if(selectedSegments.isEmpty()) selectedSegments.add(segmentOptions[0].getValue());
             
            selectedRegions = (List<String>) System.JSON.deserialize(userPref.Region__c, List<String>.class);
           if(selectedRegions.isEmpty()) selectedRegions.add(regionOptions[0].getValue());
             
            selectedCountries = (List<String>) System.JSON.deserialize(userPref.Country__c, List<String>.class);
            if(selectedCountries.isEmpty()) selectedCountries.add(countryOptions[0].getValue());
            
            selectedTime = userPref.Time_Period__c;
            selectedCurrency = userPref.Currency__c;
        }

        debugFilterSettings('Constructor');

    }
  
    // refresh action function
    public Pagereference initOppty20() {
        loadData();
        return null;
    }
    
    // refresh action function
    public Pagereference loadData() {
        IF (dummy.User__c != null) {  
      	    //runningUserId = '005C0000005Qnp1';
            runningUserId = dummy.User__c; 
            
            //List<User> runningUser = [SELECT ForecastEnabled FROM User WHERE Id = :runningUserId];                    
            //IF (runningUser[0].ForecastEnabled == false) {
				//dummy.User__c.addError('This user’s data does not appear in MyPipeline Dashboard and reports because this user has not been allowed for Target inputs');
			//	dummy.User__c.addError('User not allowed for Target inputs');                
            //}
            
            IF (prevViewAsUserId != runningUserId) {
            	setupTeamPicklist();
            }
            
            System.debug(LoggingLevel.INFO, '@@ View as : ' + dummy.User__c + ' * ' + runningUserId);
        }
        
        debugFilterSettings('loadData');
                
        getUserIdList();
       
        datedRates = [SELECT Id, IsoCode, startDate, nextStartDate, ConversionRate FROM DatedConversionRate WHERE IsoCode = :selectedCurrency ORDER BY startDate];
        
        System.debug(LoggingLevel.INFO, '@@ Data collecting starts');

        // Note - loading of section data must be in this order as some data in sections 
        // is referenced from other sections
        getTrendData();
        getShapeAndFlow();
        getQualityAndRisk(); 
        getWinRate();
       
        // Store selected filter settings for the user but only if you are not running as a view as user
        //If (runningUserId != UserInfo.getUserId()) {
            userPref.Team__c = selectedTeamMember;
            System.debug(LoggingLevel.INFO, '@@ userPref.Team__c = ' + userPref.Team__c + ', selectedTeamMember = ' + selectedTeamMember);
            userPref.Segment__c = JSON.serialize(selectedSegments);
            userPref.Region__c = JSON.serialize(selectedRegions);
            userPref.Country__c = JSON.serialize(selectedCountries);
            userPref.Time_Period__c = selectedTime;
            userPref.Currency__c = selectedCurrency;
    
            upsert userPref;
        //}
            
        prevViewAsUserId = runningUserId;
        
        return null;
    }

    // action function to get the appropriate help text
    public Pagereference getHelp() {
        sHelpText = 'No help available.';
        List<My_Pipeline_Starter_Question__c> lstQ = [SELECT Question_Body__c FROM My_Pipeline_Starter_Question__c WHERE Name=:sHelpHint];
        if(!lstQ.isEmpty()) sHelpText = lstQ[0].Question_Body__c;
        
        return null;
    }

    // action function to get the appropriate report url
    public Pagereference getReport() {
        sReportUrl = '/';
        List<Oppty20_Reports__c> lstR = [SELECT Report_Id__c, Segment_Field_Id__c, Region_Field_Id__c, Country_Field_Id__c
                                        FROM Oppty20_Reports__c WHERE Name=:sReportHint];
        if(!lstR.isEmpty()) {
            sReportUrl += lstR[0].Report_Id__c;

            Set<Id> usrIds = new Set<Id>();
            String uNames = ''; // comma separated user names

            if((selectedTeamMember == 'AllDanfoss') || (selectedTeamMember == 'AllBelow')) { 
                if(selectedTeamMember == 'AllDanfoss') {
            		usrIds = null;
                } else {
                    List<User> runningUser = [SELECT Name FROM User WHERE Id = :runningUserId];                    
                    uNames = runningUser[0].Name + ',';                    
                    
                    //for(User u : [SELECT Name FROM User WHERE Id IN :userIds AND ForecastEnabled = true AND IsActive = true]) {
                    for(User u : [SELECT Name FROM User WHERE Id IN :userIds AND IsActive = true]) {                        
                        uNames += u.Name + ',';
                    }
                    uNames = uNames.removeEnd(',');                     
                }
            } else {
                if(selectedTeamMember == 'All') { // all users
                    usrIds = RoleHierarchyHelper.getRoleSubordinateUsers(runningUserId);
                    //if(usrIds.isEmpty()) usrIds.add(runningUserId); // no valid owners found - just add the logged in user;
                    //List<User> runningUser = [SELECT Name FROM User WHERE Id = :runningUserId];
                    List<User> runningUser = [SELECT Name FROM User WHERE Id = :runningUserId];                    
                    uNames = runningUser[0].Name + ',';
                } else { // a specific user is selected
                    usrIds.add(selectedTeamMember);
                }

   			    System.debug(LoggingLevel.INFO, '@@ getReport Id : ' + usrIds);   
                
                //for(User u : [SELECT Name FROM User WHERE Id IN :usrIds AND ForecastEnabled = true AND IsActive = true]) {
                for(User u : [SELECT Name FROM User WHERE Id IN :usrIds AND IsActive = true]) {                    
                    uNames += u.Name + ',';
                }
                uNames = uNames.removeEnd(',');                
            }
            
		    System.debug(LoggingLevel.INFO, '@@ getReport Name : ' + uNames);               
            
			System.debug(LoggingLevel.INFO, '@@ getReport 1 : ' + selectedSegments + '*' + selectedRegions + '*' + selectedCountries);   
            
          	String segments  = convertListToString(selectedSegments);
            String regions 	 = convertListToString(selectedRegions);
            String countries = convertListToString(selectedCountries);

            System.debug(LoggingLevel.INFO, '@@ getReport 2 : ' + segments + '*' + regions + '*' + countries);   
            
			sReportUrl += '?pv0=' + EncodingUtil.urlEncode(uNames, 'UTF-8'); // first parameter should be record owner

            //if(selectedTeamMember == 'AllDanfoss' || selectedTeamMember == 'All') {                         
            if((selectedTeamMember == 'AllDanfoss') || (selectedTeamMember == 'AllBelow')){                                         
                If (segments != '') {
                    //sReportUrl += '&pc1=' + lstR[0].Segment_Field_Id__c + '&pn1=co' + '&pv1=' + EncodingUtil.urlEncode(segments, 'UTF-8');
                    sReportUrl += '&pc5=' + lstR[0].Segment_Field_Id__c + '&pn5=co' + '&pv5=' + EncodingUtil.urlEncode(segments, 'UTF-8');                    
                }
                
                If (regions != '') {            
                    //sReportUrl += '&pc2=' + lstR[0].Region_Field_Id__c + '&pn2=co' + '&pv2=' + EncodingUtil.urlEncode(regions, 'UTF-8');
                    sReportUrl += '&pc6=' + lstR[0].Region_Field_Id__c + '&pn6=co' + '&pv6=' + EncodingUtil.urlEncode(regions, 'UTF-8');                    
                }
                
                If (countries != '') {            
                    //sReportUrl += '&pc3=' + lstR[0].Country_Field_Id__c + '&pn3=co' + '&pv3=' + EncodingUtil.urlEncode(countries, 'UTF-8');
                    sReportUrl += '&pc7=' + lstR[0].Country_Field_Id__c + '&pn7=co' + '&pv7=' + EncodingUtil.urlEncode(countries, 'UTF-8');                    
                }
                
                //sReportUrl += '&pc4=0724B000000Pe3A' + '&pn4=eq' + '&pv4=true';                
                //sReportUrl += '&pc4=0724B000000Pe39' + '&pn4=eq' + '&pv4=true';                                
            }
        }

        return null;
    }

    public void setupTeamPicklist() {    
        Set<Id> userIds = RoleHierarchyHelper.getRoleSubordinateUsers(runningUserId);
        //List<User> team = [SELECT Id, Name FROM User WHERE Id IN :userIds AND ForecastEnabled = true];
        List<User> team = [SELECT Id, Name FROM User WHERE Id IN :userIds];         
        
        teamOptions = new List<SelectOption>();        
        teamOptions.add(new SelectOption(runningUserId, 'My Pipeline'));
        teamOptions.add(new SelectOption('All', 'All Direct Reports'));  
        
		CustomPermissionsReader cpr = new CustomPermissionsReader(Account.SObjectType);        
        IF (cpr.hasPermission('MyPipelineUseAllDanfoss')) {
        	teamOptions.add(new SelectOption('AllDanfoss', 'All Danfoss')); 
        	//teamOptions.add(new SelectOption('AllBelow', 'All Below Reports'));             
        }
  		IF (cpr.hasPermission('MyPipelineUseAllBelow')) {        
       	    teamOptions.add(new SelectOption('AllBelow', 'All Below Reports'));  
        }    
            
        for (User u : team) {
            teamOptions.add(new SelectOption(u.Id, u.Name));
        }
        selectedTeamMember = teamOptions[0].getValue(); // default selection (none)
     }
    
    public void getUserIdList() {
        String userQuery;

        userIds.clear();

        if(selectedTeamMember == 'AllBelow') { 
            // Add the owner / view as person
            userIds.add(runningUserId);            
            
            System.debug(LoggingLevel.INFO, '@@ Going through role hierachy'+runningUserId);
            Set<Id> roleUserIds = new Set<Id>();
            roleUserIds = getRoleSubordinateUsers(runningUserId);
            //roleUserIds = getRoleSubordinateUsers('005C0000005QcnJ');        
            System.debug(LoggingLevel.INFO, '@@ roleUserIds : ' + roleUserIds);            
            
            for (Id u : roleUserIds) {
                userIds.add(u);
            }
            
            //userQuery = 'SELECT Id FROM User USING SCOPE TEAM WHERE (isActive = true) AND (ForecastEnabled = true)';                
            
            //List<User> lstUsrs = Database.query(userQuery); 
            //for(User u : lstUsrs) userIds.add(u.Id);
            if(userIds.isEmpty()) return;            
        } else {
            if(selectedTeamMember != 'AllDanfoss') { 
                if(selectedTeamMember == 'All' ) { // All    
                    // all users
                    Set<Id> usrIds = new Set<Id>(); 
                    usrIds = RoleHierarchyHelper.getRoleSubordinateUsers(runningUserId);
                   
                    if(usrIds.isEmpty()) {
                      System.debug(LoggingLevel.INFO, '@@ getUserIdList : usrIds.isEmpty() ');                
                        
                      return; // no valid owners found
                    } else {
                        //userIds.addAll(String usrIds);
                        //userQuery = 'SELECT Id FROM User WHERE (Id IN :usrIds)';
                        //userQuery = 'SELECT Id FROM User WHERE (Id IN :usrIds) AND (isActive = true) AND (ForecastEnabled = true)';                    
                        userQuery = 'SELECT Id FROM User WHERE (Id IN :usrIds) AND (isActive = true)';                    
                        
                        // Add the owner / view as person
                        userIds.add(runningUserId);
                        
                        List<User> lstUsrs = Database.query(userQuery); 
                        for(User u : lstUsrs) userIds.add(u.Id);
                        if(userIds.isEmpty()) return;
                    }
                }
                else { // a specific user is selected
                    System.debug(LoggingLevel.INFO, '@@ getUserIdList : 1 a specific user is selected ' + selectedTeamMember); 
                    
                    userIds.add(selectedTeamMember);
                }
            } else {
                String itPeople = '%ServiceDesk%';                
                userQuery = 'SELECT Id FROM User WHERE (isActive = true) AND (NOT Profile.Name LIKE : itPeople)';                
                //userQuery = 'SELECT Id FROM User WHERE (isActive = true) AND (ForecastEnabled = true) AND (NOT Profile.Name LIKE : itPeople)';                                
                //userQuery = 'SELECT Id FROM User WHERE (NOT Profile.Name LIKE : itPeople)';               
                
                if(!selectedSegments.isEmpty() && selectedSegments[0] != 'All') { // set the segment condition
                    userQuery += ' AND (Division__c IN :selectedSegments)';
                }
                if(!selectedRegions.isEmpty() && selectedRegions[0] != 'All') { // a specific region is selected
                    userQuery += ' AND (Region__c IN :selectedRegions) ';
                }                
                if(!selectedCountries.isEmpty() && selectedCountries[0] != 'All') { // a specific country is selected
                    userQuery += ' AND (User_Country__c IN :selectedCountries) ';
                }
    
                List<User> lstUsrs = Database.query(userQuery); 
                for(User u : lstUsrs) userIds.add(u.Id);
                if(userIds.isEmpty()) return;
            }
        }
            
        System.debug(LoggingLevel.INFO, '@@ getUserIdList : query ' + userQuery);                            
        System.debug(LoggingLevel.INFO, '@@ getUserIdList : SelectedCriteria ' + userIds + ' * ' + selectedSegments + ' * ' + selectedRegions + ' * ' + selectedCountries);         
        
    }    
    
    // -- DASHBOARD SECTION RELATED METHODS -- 
    
    // Trend data component
    public void getTrendData() {
        Map<String, String> mapData = new Map<String, String>(); // map of stage name and default stage data

        mapData.put('Target', '[' + '\'' + 'Target' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        mapData.put('Won', '[' + '\'' + 'Won' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');        
        mapData.put('Expected', '[' + '\'' + 'Expected' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');          
        mapData.put('Gap', '[' + '\'' + 'Gap' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        mapData.put('Gap %', '[' + '\'' + 'Gap %' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        
        netwin_trend_data = mapData.values(); // Get the default values
        
        Date firstQuarterThisYear, secondQuarterThisYear, thirdQuarterThisYear, fourthQuarterThisYear;
       	Date firstQuarterNextYear, secondQuarterNextYear, thirdQuarterNextYear, fourthQuarterNextYear;
        Date firstQuarterSecondYear;
		Integer nextYear;
        
        List<Period> periods = [select Id, StartDate, EndDate From Period Where type = 'Quarter' and (StartDate = THIS_YEAR OR FISCAL_YEAR(StartDate) = :system.today().year() + 1 OR FISCAL_YEAR(StartDate) = :system.today().year() + 2) ORDER BY StartDate ASC];        
        
        Date yearStart 			= Date.newInstance(Date.today().year(), 1, 1);   
        Date tomorrow 			= Date.today().addDays(1);        
        firstQuarterThisYear 	= periods[0].StartDate;
        secondQuarterThisYear 	= periods[1].StartDate;
        thirdQuarterThisYear 	= periods[2].StartDate;
        fourthQuarterThisYear 	= periods[3].StartDate;    
        firstQuarterNextYear 	= periods[4].StartDate; 
        secondQuarterNextYear 	= periods[5].StartDate; 
        thirdQuarterNextYear 	= periods[6].StartDate; 
        fourthQuarterNextYear 	= periods[7].StartDate; 
        firstQuarterSecondYear 	= periods[8].StartDate;         

        // Target - this is a quota object
        Decimal tAmount=0, tQ1=0, tQ2=0, tQ3=0, tQ4=0, tnyQ1=0, tnyQ2=0, tnyQ3=0, tnyQ4=0, ttot = 0, tnytot = 0;
        
        tAmount = getForecastAmount(yearStart, tomorrow, userIds);
        tQ1 	= getForecastAmount(firstQuarterThisYear, secondQuarterThisYear, userIds);
        tQ2 	= getForecastAmount(secondQuarterThisYear, thirdQuarterThisYear, userIds);
        tQ3 	= getForecastAmount(thirdQuarterThisYear, fourthQuarterThisYear, userIds);
        tQ4 	= getForecastAmount(fourthQuarterThisYear, firstQuarterNextYear, userIds);
        ttot    = tQ1 + tQ2 + tQ3 + tQ4;
        global_ttot = ttot;
        tnyQ1   = getForecastAmount(firstQuarterNextYear, secondQuarterNextYear, userIds);
        tnyQ2   = getForecastAmount(secondQuarterNextYear, thirdQuarterNextYear, userIds);
        tnyQ3   = getForecastAmount(thirdQuarterNextYear, fourthQuarterNextYear, userIds);
        tnyQ4   = getForecastAmount(fourthQuarterNextYear, firstQuarterSecondYear, userIds);
        tnytot  = tnyQ1 + tnyQ2 + tnyQ3 + tnyQ4;
        
        String sData = '[' + '\'' + 'Target' + '\'' + ',' + tAmount + ',' + tQ1 + ',' + tQ2 + ',' + tQ3 + ',' + tQ4 + ',' + ttot + ',' + tnyQ1 + ',' + tnyQ2 + ',' + tnyQ3 + ',' + tnyQ4 + ',' + tnytot +  ']';

        mapData.put('Target', sData);    
        
  		// Won - This is on opportunity object        
        Decimal wAmount=0, wQ1=0, wQ2=0, wQ3=0, wQ4=0, wnyQ1=0, wnyQ2=0, wnyQ3=0, wnyQ4=0, wtot = 0, wnytot = 0; 
  		
		if(!userIds.isEmpty()) {            
            wAmount = getOpportunityWonAmount(' WHERE IsWon = True AND CloseDate = THIS_YEAR ', yearStart, tomorrow, userIds);
            wQ1 	= getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) ', firstQuarterThisYear, secondQuarterThisYear, userIds);
            wQ2 	= getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) ', secondQuarterThisYear, thirdQuarterThisYear, userIds);
            wQ3 	= getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) ', thirdQuarterThisYear, fourthQuarterThisYear, userIds);
            wQ4		= getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) ', fourthQuarterThisYear, firstQuarterNextYear, userIds);
        	wtot  	= wQ1 + wQ2 + wQ3 + wQ4;
            global_wtot = wtot;            
            wnyQ1 	= getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) ', firstQuarterNextYear, secondQuarterNextYear, userIds);
            wnyQ2 	= getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) ', secondQuarterNextYear, thirdQuarterNextYear, userIds);
            wnyQ3 	= getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) ', thirdQuarterNextYear, fourthQuarterNextYear, userIds);
            wnyQ4 	= getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) ', fourthQuarterNextYear, firstQuarterSecondYear, userIds);
	        wnytot  = wnyQ1 + wnyQ2 + wnyQ3 + wnyQ4;
        }

        sData = '[' + '\'' + 'Won' + '\''  + ',' + wAmount + ',' + wQ1 + ',' + wQ2 + ',' + wQ3 + ',' + wQ4 + ',' + wtot + ',' + wnyQ1 + ',' + wnyQ2 + ',' + wnyQ3 + ',' + wnyQ4 + ',' + wnytot + ']';

        System.debug(LoggingLevel.INFO, '@@ getNetWinTrendData : Won ' + sData);                            
        
        mapData.put('Won', sData);  
        
        // Expected amount
        Decimal eAmount=0, eQ1=0, eQ2=0, eQ3=0, eQ4=0, enyQ1=0, enyQ2=0, enyQ3=0, enyQ4=0, etot = 0, enytot = 0;
  
		if(!userIds.isEmpty()) {            
            eAmount = getOpportunityExpectedAmount(' WHERE CloseDate = THIS_YEAR ', yearStart, tomorrow, userIds);            
            eQ1 	= getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) ', firstQuarterThisYear, secondQuarterThisYear, userIds);
            eQ2 	= getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) ', secondQuarterThisYear, thirdQuarterThisYear, userIds);
            eQ3 	= getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) ', thirdQuarterThisYear, fourthQuarterThisYear, userIds);
            eQ4		= getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) ', fourthQuarterThisYear, firstQuarterNextYear, userIds);
        	etot  	= eQ1 + eQ2 + eQ3 + eQ4;            
            enyQ1 	= getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) ', firstQuarterNextYear, secondQuarterNextYear, userIds);
            enyQ2 	= getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) ', secondQuarterNextYear, thirdQuarterNextYear, userIds);
            enyQ3 	= getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) ', thirdQuarterNextYear, fourthQuarterNextYear, userIds);
            enyQ4 	= getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) ', fourthQuarterNextYear, firstQuarterSecondYear, userIds);
	        enytot  = enyQ1 + enyQ2 + enyQ3 + enyQ4;            
        }

        sData = '[' + '\'' + 'Expected' + '\''  + ',' + eAmount + ',' + eQ1 + ',' + eQ2 + ',' + eQ3 + ',' + eQ4 + ',' + etot + ',' + enyQ1 + ',' + enyQ2 + ',' + enyQ3 + ',' + enyQ4 + ',' + enytot + ']';
        
        System.debug(LoggingLevel.INFO, '@@ getNetWinTrendData : Expected ' + sData);                            
        
        mapData.put('Expected', sData);         
        
        // Gap
        Decimal gAmount = eAmount - tAmount;
        Decimal gQ1 = eQ1 - tQ1;
        Decimal gQ2 = eQ2 - tQ2;
        Decimal gQ3 = eQ3 - tQ3;
        Decimal gQ4 = eQ4 - tQ4;
        Decimal gtot = gQ1 + gQ2 + gQ3 + gQ4; 
        Decimal gnyQ1 = enyQ1 - tnyQ1;
        Decimal gnyQ2 = enyQ2 - tnyQ2;
        Decimal gnyQ3 = enyQ3 - tnyQ3;
        Decimal gnyQ4 = enyQ4 - tnyQ4;
        Decimal gnytot = gnyQ1 + gnyQ2 + gnyQ3 + gnyQ4;

        sData = '[' + '\'' + 'Gap' + '\'' + ',' + gAmount + ',' + gQ1 + ',' + gQ2 + ',' + gQ3 + ',' + gQ4 + ',' + gtot + ',' + gnyQ1 + ',' + gnyQ2 + ',' + gnyQ3 + ',' + gnyQ4 + ',' + gnytot + ']';

        System.debug(LoggingLevel.INFO, '@@ getNetWinTrendData : Gap ' + sData);                            
        
        mapData.put('Gap', sData);
        
        // Gap %
        Decimal gpAmount = 0, gpQ1 = 0, gpQ2 = 0, gpQ3 = 0, gpQ4 = 0, gptot = 0, gpnyQ1 = 0, gpnyQ2 = 0, gpnyQ3 = 0, gpnyQ4 = 0, gpnytot = 0;
        
        If (tAmount > 0) {
        	gpAmount = eAmount * 100 / tAmount;
        }
        If (tQ1 > 0) {
        	gpQ1 = eQ1 * 100 / tQ1;
        }
        If (tQ2 > 0) {
            gpQ2 = eQ2 * 100 / tQ2;
        }
        If (tQ3 > 0) {
	        gpQ3 = eQ3 * 100 / tQ3;
        }
        If (tQ4 > 0) {
            gpQ4 = eQ4 * 100 / tQ4;
        }
        If (ttot > 0) {
            gptot = etot * 100 / ttot;
        }        
        If (tnyQ1 > 0) {
            gpnyQ1 = enyQ1 * 100 / tnyQ1;
        }
        If (tnyQ2 > 0) {
            gpnyQ2 = enyQ2 * 100 / tnyQ2;
        }
        If (tnyQ3 > 0) {
            gpnyQ3 = enyQ3 * 100 / tnyQ3;
        }
        If (tnyQ4 > 0) {
            gpnyQ4 = enyQ4 * 100 / tnyQ4;
        }
        If (tnytot > 0) {
            gpnytot = enytot * 100 / tnytot;
        }        
        
        sData = '[' + '\'' + 'Gap %' + '\'' + ',' + gpAmount + ',' + gpQ1 + ',' + gpQ2 + ',' + gpQ3 + ',' + gpQ4 + ',' + gptot + ',' + gpnyQ1 + ',' + gpnyQ2 + ',' + gpnyQ3 + ',' + gpnyQ4 + ',' + gpnytot + ']';

        System.debug(LoggingLevel.INFO, '@@ getNetWinTrendData : Gap %' + sData);                            
        
        mapData.put('Gap %', sData);
        netwin_trend_data = mapData.values();        
    }    
    
    // Shape & flow component
    public void getShapeAndFlow() {
        Map<String, String> mapData = new Map<String, String>(); // map of stage name and default stage data
        
        mapData.put('Identified Opportunity (CE)', '[' + '\'' + 'Identified Opportunity (CE)' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        mapData.put('Initial Planning (CE)', '[' + '\'' + 'Initial Planning (CE)' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        mapData.put('Specifying Solution (CE)', '[' + '\'' + 'Specifying Solution (CE)' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        mapData.put('Evaluating Solution (CE)', '[' + '\'' + 'Evaluating Solution (CE)' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        mapData.put('Closed-Won', '[' + '\'' + 'Closed-Won' + '\'' + ',,,' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        mapData.put('Closed-Lost', '[' + '\'' + 'Closed-Lost' + '\'' + ',,,' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');

        Map<String, StageAggregation> shapeAggr = new Map<String, StageAggregation>();        
        
        // New in stage - Flow part
        List<String> stageDeselect = new List<String> { 'Ordering Solution (CE)' };        
        
        // get the time period
        Period p;
        
        if (mapPeriods.containsKey(selectedTime)) {
        	p = mapPeriods.get(selectedTime);
        } else {
            p = mapPeriods.values()[0];
        }
        System.debug(LoggingLevel.INFO, '@@ Flow: Selected period: ' + p);
        Date sDate = p.StartDate;
        Date eDate = p.EndDate;
        System.debug(LoggingLevel.INFO, '@@ Flow: Selected start date: ' + sDate + ', selected end date' + eDate);
        
        // New in stage
        String SOQL_SELECT = 'SELECT StageName, count(id) cnt, sum(amount) amount_sum FROM Opportunity';
        String SOQL_WHERE = ' WHERE (CE_STAGE_CHANGE_DATE__c  >= :sDate AND CE_STAGE_CHANGE_DATE__c <= :eDate) ';
        SOQL_WHERE += ' AND (StageName NOT IN : stageDeselect) ';        
        
        if(!userIds.isEmpty()) {
        	SOQL_WHERE += ' AND (OwnerId IN :userIds) ';             
        }
        
        System.debug(LoggingLevel.INFO, '@@ Flow: Users = ' + userIds);
        String SOQL_GROUP_BY = ' GROUP BY StageName';
        
        System.debug(LoggingLevel.INFO, '@@ getFlowData : SOQL ' + SOQL_SELECT + SOQL_WHERE + SOQL_GROUP_BY);
  	    System.debug(LoggingLevel.INFO, '@@ getFlowData : SelectedCriteria ' + sDate + ' * ' + eDate + ' * ' + selectedSegments + ' * ' + selectedRegions + ' * ' + selectedCountries + ' * ' + userIds + ' * ' + selectedTeamMember);        
        
        List<AggregateResult> results_flow = Database.query(SOQL_SELECT+SOQL_WHERE+SOQL_GROUP_BY);
        
        System.debug(LoggingLevel.INFO, '@@ Flow: query results ' + results_flow);
        
        for (AggregateResult ar : results_flow) {
            String stage = (String) ar.get('StageName');   

            System.debug(LoggingLevel.INFO, '@@ Flow: Find stage ' + stage + '*');
            
        	// Only update those stages that has been put in the map in the initialization part
            if(shapeAggr.containsKey(stage)) {
                System.debug(LoggingLevel.INFO, '@@ Flow: Found stage ' + stage);                
                StageAggregation sa = shapeAggr.get(stage);
                 
                sa.inStageCount = (Integer) ar.get('cnt');
                if(sa.inStageCount == null) sa.inStageCount = 0;
                
                Decimal size = (Decimal) ar.get('amount_sum');
                sa.inStageSize = getFormattedCurrency(size);
            //}
            } else {
                System.debug(LoggingLevel.INFO, '@@ Shape: Add stage ' + stage);
                StageAggregation sa = new StageAggregation();

                sa.inStageCount = (Integer) ar.get('cnt');
                sa.inStageSize = (Decimal) ar.get('amount_sum');                
                
                sa.stageName = stage;                
                sa.amount = 0;
                sa.converted_amount = 0;
                sa.expected_revenue = 0;
                sa.count = 0;
                sa.totalCount = 0;
                sa.totalSize = 0;
                
                shapeAggr.put(stage, sa);                
            }
        }
        
        // Total part
        SOQL_SELECT = 'SELECT StageName, count(id) cnt, sum(amount) amount_sum FROM Opportunity';
        SOQL_WHERE = ' WHERE (StageName NOT IN : stageDeselect) ';        
        
        if(!userIds.isEmpty()) {
        	SOQL_WHERE += ' AND (OwnerId IN :userIds) ';             
        }
        
        System.debug(LoggingLevel.INFO, '@@ Flow: Users = ' + userIds);
        SOQL_GROUP_BY = ' GROUP BY StageName';
        
        System.debug(LoggingLevel.INFO, '@@ getFlowData : SOQL ' + SOQL_SELECT + SOQL_WHERE + SOQL_GROUP_BY);
  	    System.debug(LoggingLevel.INFO, '@@ getFlowData : SelectedCriteria ' + sDate + ' * ' + eDate + ' * ' + selectedSegments + ' * ' + selectedRegions + ' * ' + selectedCountries + ' * ' + userIds + ' * ' + selectedTeamMember);        
        
        List<AggregateResult> results_total = Database.query(SOQL_SELECT+SOQL_WHERE+SOQL_GROUP_BY);
        
        System.debug(LoggingLevel.INFO, '@@ Total: query results ' + results_total);
        
        for (AggregateResult ar : results_total) {
            String stage = (String) ar.get('StageName');   
            
        	// Only update those stages that has been put in the map in the initialization part
            if(shapeAggr.containsKey(stage)) {
                System.debug(LoggingLevel.INFO, '@@ Shape: Found stage ' + stage);                
                StageAggregation sa = shapeAggr.get(stage);
                 
                sa.totalCount = (Integer) ar.get('cnt');
                if(sa.totalCount == null) sa.totalCount = 0;
                
                Decimal size = (Decimal) ar.get('amount_sum');
                sa.totalSize = getFormattedCurrency(size);
                
                sa.inStageCount = sa.inStageCount;
                sa.inStageSize  = sa.inStageSize; 
                sa.amount 		= sa.amount;
                sa.converted_amount = sa.converted_amount;                    
                sa.expected_revenue = sa.expected_revenue;
                sa.count            = sa.count;    
            } else {
                System.debug(LoggingLevel.INFO, '@@ Shape: Add stage ' + stage);
                StageAggregation sa = new StageAggregation();

                sa.totalCount = (Integer) ar.get('cnt');
                if(sa.totalCount == null) sa.totalCount = 0;
                
                Decimal size = (Decimal) ar.get('amount_sum');
                sa.totalSize = getFormattedCurrency(size);

                sa.stageName = stage;                
                sa.amount = 0;
                sa.converted_amount = 0;
                sa.expected_revenue = 0;
                sa.count = 0;
                sa.inStageCount = 0;
                sa.inStageSize = 0;
                
                shapeAggr.put(stage, sa);                                
            }
        }
        
        // Calendar year - Shape part        
        SOQL_SELECT = 'SELECT StageName, CloseDate, Count(Id) opp_cnt, SUM(Amount) amount_sum, AVG(Probability) prob, SUM(ExpectedRevenue) exp_rev FROM Opportunity';
        SOQL_WHERE = ' WHERE IsClosed = false  AND (RecordTypeId IN :oppRecordTypeIds) ';                
        SOQL_WHERE += ' AND (StageName NOT IN : stageDeselect) AND (CloseDate = THIS_YEAR) ';
        
        if(!userIds.isEmpty()) {
			SOQL_WHERE += ' AND (OwnerId IN :userIds) ';
        }
        
        SOQL_GROUP_BY = ' GROUP BY StageName, CloseDate';

        System.debug(LoggingLevel.INFO, '@@ getShapeData : SOQL ' + SOQL_SELECT + SOQL_WHERE + SOQL_GROUP_BY);        
		System.debug(LoggingLevel.INFO, '@@ getShapeData : SelectedCriteria ' + selectedSegments + ' * ' + selectedRegions + ' * ' + selectedCountries + ' * ' + userIds + ' * ' + selectedTeamMember + ' * ' + oppRecordTypeIds);
        
        List<AggregateResult> results_shape = Database.query(SOQL_SELECT+SOQL_WHERE+SOQL_GROUP_BY);
        
        //Integer cntTotal = 0;
        //Decimal sizeTotal = 0;

        System.debug(LoggingLevel.INFO, '@@ Shape: Query results = ' + results_shape);        
        if(results_shape != null && results_shape.size() > 0) {
            Integer cnt = 0;
            Decimal size = 0;
            Decimal converted_size = 0;
            Date closeDate;
            for(AggregateResult ar : results_shape) {
                System.debug(LoggingLevel.INFO, '@@ Shape: Query result: ' + ar);        
                String stage = (String)ar.get('StageName');
                cnt = (Integer)ar.get('opp_cnt');
                size = (Decimal)ar.get('amount_sum');
                closeDate = (Date)ar.get('CloseDate');
                converted_size = getFormattedCurrency(closeDate, size);
                if(cnt == null) 
                    cnt = 0;
                
                Decimal exp_rev = (Decimal) ar.get('exp_rev');
                Decimal amount_sum = (Decimal) ar.get('amount_sum');
                
                System.debug(LoggingLevel.INFO, '@@ Shape: Find stage ' + stage + '*');
                
                // stage already exists - update existing stage data 
                if (shapeAggr.containsKey(stage)) {         
                    System.debug(LoggingLevel.INFO, '@@ Shape: Found stage ' + stage);
                    StageAggregation sa = shapeAggr.get(stage);
                    sa.amount = (sa.amount +(size!=null?size:0));
                    sa.converted_amount = (sa.converted_amount +(converted_size!=null?converted_size:0));                    
        			sa.expected_revenue = (sa.expected_revenue +(exp_rev!=null?exp_rev:0));
                    //sa.count = sa.count + cnt;
        			sa.count = (sa.count+(cnt!=null?cnt:0));
 
                    //sa.totalCount	= sa.totalCount;	
                    //sa.totalSize    = sa.totalSize;   
                	sa.inStageCount = sa.inStageCount; 
                	sa.inStageSize  = sa.inStageSize; 
                //}
                } else {
                    System.debug(LoggingLevel.INFO, '@@ Shape: Add stage ' + stage);
                    StageAggregation sa = new StageAggregation();
                    
                    sa.stageName = stage;
                    sa.amount = (size!=null?size:0);
                    sa.converted_amount = (converted_size!=null?converted_size:0);
        			sa.expected_revenue =(exp_rev!=null?exp_rev:0);
        			sa.count = (cnt!=null?cnt:0);
                    
                	sa.inStageCount = 0; 
                	sa.inStageSize = 0;   
                    sa.totalCount = 0;
                    sa.totalSize = 0;
                    
                    shapeAggr.put(stage, sa);
                }
            }
        }

     	// Put data in the map
        Decimal prob = 0;
        Decimal totalSizeTotal 	= 0;
        Integer totalCountTotal = 0;        
        Decimal flowSizeTotal 	= 0;
        Integer flowCountTotal 	= 0;
        
        for (StageAggregation sa : shapeAggr.values()) {
            
            if ((sa.expected_revenue != null) && (sa.amount != null) && (sa.amount > 0)) {
                prob = (sa.expected_revenue / sa.amount * 100);                    
            }
            
            System.debug(LoggingLevel.INFO, '@@ getShapeData : Amount ' + sa.stageName + '*' + sa.amount + '*' + '*' + sa.count + '*' + sa.converted_amount);                
            
            String sData;
           
            If (sa.stageName.substring(0,6) == 'Closed') {
	            sData = '[' + '\'' + sa.stageName + '\''  + ',,,,,,' + sa.inStageCount + ',' + sa.inStageSize + ']';
            } else {
            	If (sa.stageName != 'Identified Opportunity (CE)') {                
                    totalSizeTotal  = totalSizeTotal + sa.totalSize;
                    totalCountTotal = totalCountTotal + sa.totalCount;                 
                    flowSizeTotal   = flowSizeTotal + sa.converted_amount;
                    flowCountTotal  = flowCountTotal + sa.count;                    
                }
                
	            sData = '[' + '\'' + sa.stageName + '\''  + ',' + sa.totalCount + ',' + sa.totalSize + ',' + sa.count + ',' + sa.converted_amount + ',' + prob + ',' + sa.inStageCount + ',' + sa.inStageSize + ']';
            }
            
            //String sData = '[' + '\'' + sa.stageName + '\''  + ',' + 0 + ',' + 0 + ',' + sa.count + ',' + sa.converted_amount + ',' + prob + ',' + sa.inStageCount + ',' + sa.inStageSize + ']';            
            mapData.put(sa.stageName, sData);
        }

        global_CalendarYearSizeTotal = flowSizeTotal;
        
        String sData = '[' + '\'' + 'Total' + '\'' + ',' + totalCountTotal + ',' + totalSizeTotal + ',' + flowCountTotal + ',' + flowSizeTotal + ',,,' + 0 + ']';
        //String sData = '[' + '\'' + 'Total' + '\'' + ',' + totalCountTotal + ',' + totalSizeTotal + ',' + flowCountTotal + ',' + flowSizeTotal + ',,,' + '\'' + ' ' + '\'' + ']';        
        mapData.put('Total', sData); 
        
        shapeflow_data = mapData.values(); // fetch the latest values        
    }
    
    // Win Rate component
    public void getWinRate() {
       Map<String, String> mapData = new Map<String, String>(); 
       mapData.put('RestYear', '[' + '\'' + 'Rest of calendar Yr.' + '\'' + ',' + 0 + ']');

       Decimal winratePct = 0;        
        
       If (global_CalendarYearSizeTotal > 0) {
         winratePct = global_ttot - global_wtot / global_CalendarYearSizeTotal;
       } 

		System.debug(LoggingLevel.INFO, '@@ getWinRate : global_ttot ' + global_ttot + 'global_wtot' + global_wtot + 'global_CalendarYearSizeTotal' + global_CalendarYearSizeTotal + ' gives winratePct' + winratePct);
        
       String sData = '[' + '\'' + 'Rest of calendar Yr.' + '\'' + ',' + winratePct + ']';
       mapData.put('RestYear', sData);         
        
       winrate_data = mapData.values();        
    }

    public void getQualityAndRisk () {
        qcheck_data = new List<String>(); // initialise the data list (also clear old data)
        //qindex_data = new List<String>(); // initialise the data list (also clear old data)

        // Get the start and end date for the selected period
        Period p;        
        if (mapPeriods.containsKey(selectedTime)) {
        	p = mapPeriods.get(selectedTime);
        } else {
            p = mapPeriods.values()[0];
        }
        Date sDate = p.StartDate;
        Date eDate = p.EndDate;
        System.debug(LoggingLevel.INFO,'@@ Quality: Current period: start = ' + sDate + ', end = ' + eDate);
        
        // Overdue
        //List<String> stageOverdue = new List<String> { 'Initial Planning (CE)' , 'Specifying Solution (CE)', 'Evaluating Solution (CE)', 'Ordering Solution (CE)', 'Open', 'Identified Opportunity (CE)', 'Identification (CE)' };
        List<String> stageOverdue = new List<String> { 'Initial Planning (CE)' , 'Specifying Solution (CE)', 'Evaluating Solution (CE)', 'Ordering Solution (CE)', 'Open' };            
            
        String SOQL_SELECT = 'SELECT count( Id ) cnt, sum( Overdue__c ) overdue_count, sum(Q_Overdue_Amount__c) overdue_sum';
        //String SOQL_SELECT = 'SELECT count( Id ) overdue_count, sum(Q_Overdue_Amount__c) overdue_sum';        
        SOQL_SELECT += ' FROM Opportunity';
        
        //String SOQL_WHERE = ' WHERE (CloseDate < TODAY AND CloseDate != null AND Q_Overdue_Amount__c != null) ';
        String SOQL_WHERE = ' WHERE Overdue__c=1';        
		SOQL_WHERE += ' AND (StageName IN : stageOverdue)';
        //String SOQL_WHERE = ' WHERE (StageName IN : stageOverdue)';
 		SOQL_WHERE += '	AND (RecordTypeId IN :oppRecordTypeIds)';
        //SOQL_WHERE += ' AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR AND QuotaAmount > 0)';            
        //SOQL_WHERE += ' AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR)';                    
        
        //if (!selectedSegments.isEmpty() && selectedSegments[0] != 'All') {
        //    SOQL_WHERE += ' AND (Segment__c IN :selectedSegments)';
        //}
        //if (!selectedRegions.isEmpty() && selectedRegions[0] != 'All') {
        //    SOQL_WHERE += ' AND (Region__c IN :selectedRegions)';
        //}
        //if (!selectedCountries.isEmpty() && selectedCountries[0] != 'All') {
        //    SOQL_WHERE += ' AND (Country__c IN :selectedCountries)';
        //}
        
        SOQL_WHERE += ' AND (OwnerId IN :userIds) ';  
        
        System.debug(LoggingLevel.INFO, '@@ getQualityData : SOQL1 ' + SOQL_SELECT + SOQL_WHERE);
        System.debug(LoggingLevel.INFO, '@@ getQualityData : SelectedCriteria2 ' + sDate + ' * ' + eDate + ' * ' + selectedSegments + ' * ' + selectedRegions + ' * ' + selectedCountries + ' * ' + userIds + ' * ' + selectedTeamMember);
        
        List<AggregateResult>  OpptyTrend_current = Database.query(SOQL_SELECT+SOQL_WHERE);            

        Decimal overdue, overdue_sum, overdue_trend = 0; 
        Decimal cnt, inactive, stalled, extralarge, overaged, timeslip, sizechange=0;
        Decimal amount_sum, risk_amount, extralarge_sum, inactive_sum, overaged_sum, timeslip_sum, sizechange_sum, stalled_amount=0;
        Decimal cnt_trend, inactive_trend, stalled_trend, extralarge_trend, overaged_trend, timeslip_trend, sizechange_trend=0;
        Decimal risk_index=0, risk_index_old=0, overdue_index=0,overdue_index_old=0;
        
        // First get the current period quality indexes
        System.debug(LoggingLevel.INFO,'@@ Quality: Current period results ' + OpptyTrend_current);
        if (OpptyTrend_current.size() == 1) {

            //cnt = (Decimal) OpptyTrend_current.get(0).get('cnt');
            //if(cnt == null) cnt = 0;

            overdue = (Decimal) OpptyTrend_current.get(0).get('overdue_count');
            if(overdue == null) overdue = 0;
 
        	//cnt = cnt + overdue;            
            
            overdue_sum = (Decimal) OpptyTrend_current.get(0).get('overdue_sum');
            overdue_sum = getFormattedCurrency(overdue_sum);// * getExchangeRate();

            //inactive = (Decimal) OpptyTrend_current.get(0).get('inative_count');
            if(inactive == null) inactive = 0;

            //inactive_sum = (Decimal) OpptyTrend_current.get(0).get('inactive_sum');
            if(inactive_sum == null) inactive_sum = 0;
            inactive_sum = getFormattedCurrency(inactive_sum); // * getExchangeRate();
            
            //stalled = (Decimal) OpptyTrend_current.get(0).get('stalled_count');
            //if(stalled == null) stalled = 0;

            //stalled_amount = (Decimal) OpptyTrend_current.get(0).get('stalled_amount');
            //stalled_amount = getFormattedCurrency(stalled_amount); // * getExchangeRate();
            //stalled_amount = 0; // JPK Temp change 07-04-2016

            //extralarge = (Decimal) OpptyTrend_current.get(0).get('extralarge_count');
            //if(extralarge == null) extralarge = 0;

            //extralarge_sum = (Decimal) OpptyTrend_current.get(0).get('extralarge_sum');
            //extralarge_sum = getFormattedCurrency(extralarge_sum); // * getExchangeRate();
            //extralarge_sum = 0; // JPK Temp change 07-04-2016
            
            //overaged = (Decimal) OpptyTrend_current.get(0).get('overaged_count');
            //if(overaged == null) overaged = 0;

            //overaged_sum = (Decimal) OpptyTrend_current.get(0).get('overaged_sum');
            //overaged_sum = getFormattedCurrency(overaged_sum);// * getExchangeRate();
            //overaged_sum = 0; // JPK Temp change 07-04-2016
            
            //timeslip = (Decimal) OpptyTrend_current.get(0).get('timeslip_count');
            //if(timeslip == null) timeslip = 0;

            //timeslip_sum = (Decimal) OpptyTrend_current.get(0).get('timeslip_sum');
            //if(timeslip_sum == null) timeslip_sum = 0;
            //timeslip_sum = getFormattedCurrency(timeslip_sum); // * getExchangeRate();
            
            //sizechange = (Decimal) OpptyTrend_current.get(0).get('sizechange_count');
            //if(sizechange == null) sizechange = 0;

            //sizechange_sum = (Decimal) OpptyTrend_current.get(0).get('sizechange_sum');
			//if(sizechange_sum == null) sizechange_sum = 0;            
            //sizechange_sum = getFormattedCurrency(sizechange_sum); // * getExchangeRate();
            
            //amount_sum = (Decimal) OpptyTrend_current.get(0).get('amount_sum');
            //if(amount_sum == null) amount_sum = 0;
            //amount_sum = getFormattedCurrency(amount_sum);
            
            // Risk amount is the sum of all amounts except overdue
            //risk_amount = inactive_sum + stalled_amount + extralarge_sum + overaged_sum + timeslip_sum + sizechange_sum;
            
            //if (shapeTotalAmount > 0 && risk_amount != null) {
            //    risk_index = (risk_amount/shapeTotalAmount)*100; // Use total pipeline size from stage section
            //}
            // Overdue index is sum of overdue amount/total pipeline sum
            //if (shapeTotalAmount > 0 && overdue_sum != null) {
            //    overdue_index = (overdue_sum/shapeTotalAmount)*100;
            //}
        }
        
        String sData = '[' + '\'' + 'Overdue' + '\'' + ',' + overdue + ',' + overdue_sum + ']';
        qcheck_data.add(sData);

        sData = '[' + '\'' + 'Inactive' + '\'' + ',' + inactive + ',' + inactive_sum + ']';
        qcheck_data.add(sData);

        //sData = '[' + '\'' + 'Stalled' + '\'' + ',' + stalled + ',' + stalled_amount + ']';
        //qcheck_data.add(sData);
                
        //sData = '[' + '\'' + 'Extra Large' + '\'' + ',' + extralarge + ',' + extralarge_sum + ']';
        //qcheck_data.add(sData);
  
        //sData = '[' + '\'' + 'Overaged' + '\'' + ',' + overaged + ',' + overaged_sum + ']';
        //qcheck_data.add(sData);

        //sData = '[' + '\'' + 'Time Slippage' + '\'' + ',' + timeslip + ',' + timeslip_sum + ']';
        //qcheck_data.add(sData);

        //sData = '[' + '\'' + 'Size Change' + '\'' + ',' + sizechange + ',' + sizechange_sum + ']';
        //qcheck_data.add(sData);
        
        System.debug(LoggingLevel.INFO,'@@ Quality: qcheck_data ' + qcheck_data);        
        
        // QIndex
        //sData = '[' + '\'' + 'Overdue %' + '\'' + ',' + overdue_index_old.intValue() + ',' + overdue_index.intValue() + ']';
        //qindex_data.add(sData);

        //sData = '[' + '\'' + 'Risk Index' + '\'' + ',' + risk_index_old.setScale(1) + ',' + risk_index.setScale(1) + ']';
        //qindex_data.add(sData);
    }

    /**
     * Returns the forecast amount (sum of quotas) for the period defined by
     * startDate and endDate (not included) for users in usrIds.
     */ 
    //private Decimal getForecastAmount(Date startDate, Date endDate, Set<Id> usrIds) { 
    private Decimal getForecastAmount(Date startDate, Date endDate, List<String> usrIds) {         
		String SOQL_SELECT = 'SELECT SUM(QuotaAmount) amt FROM ForecastingQuota '
                +'WHERE IsAmount = true '
                + 'AND StartDate >= :startDate '
                + 'AND StartDate < :endDate '
                + 'AND QuotaOwnerId IN :usrIds ';
        
        System.debug(LoggingLevel.INFO, '@@ getForecastAmount : SOQL ' + SOQL_SELECT);         
        
        List<AggregateResult> results = Database.query(SOQL_SELECT);

        Decimal dAmount = 0;
        if(results != null && results.size() == 1) {
            dAmount = (Decimal) results[0].get('amt');
        }
        
        return getFormattedCurrency(dAmount);
    }

    /**
     * Returns the sum of the expected revenue for opportunities owned by the
     * users defined by usrIds and any filters added to the sql_where clause. 
     * The amount will be converted to the selected currency.
     */
    //private Decimal getOpportunityAmount(String sql_where, Set<Id> usrIds) {
    private Decimal getOpportunityWonAmount(String sql_where, Date startDate, Date endDate, List<String> usrIds) {        
		List<String> stageDeselect = new List<String> { 'Identified Opportunity (CE)' };        

        String SOQL_SELECT = 'SELECT CloseDate, SUM(Won_Amount__c) amt FROM Opportunity ';
        String SOQL_WHERE = sql_where + ' AND OwnerId IN :usrIds AND (RecordTypeId IN :oppRecordTypeIds) '; 
        SOQL_WHERE = SOQL_WHERE + ' AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR)';   
        SOQL_WHERE = SOQL_WHERE + ' AND CloseDate >= :startDate ' + 'AND CloseDate < :endDate ';
		SOQL_WHERE += ' AND (StageName NOT IN : stageDeselect) ';                
        String SOQL_GROUP_BY = ' GROUP BY CloseDate';
        
        System.debug(LoggingLevel.INFO, '@@ getOpportunityWonAmount : SOQL ' + SOQL_SELECT + SOQL_WHERE+SOQL_GROUP_BY);  
		System.debug(LoggingLevel.INFO, '@@ getOpportunityWonAmount : SelectedCriteria ' + usrIds + ' * ' + oppRecordTypeIds);        
        
        List<AggregateResult> results = Database.query(SOQL_SELECT+SOQL_WHERE+SOQL_GROUP_BY);

   		System.debug(LoggingLevel.INFO, '@@ getOpportunityWonAmount : results ' + results);
        
        Decimal dAmount = 0;
               
		if(results != null && results.size() > 0) {
            Decimal size = 0;
            Decimal converted_size = 0;
            Date closeDate;
            
            for(AggregateResult ar : results) {
				size = (Decimal)ar.get('amt');
                closeDate = (Date)ar.get('CloseDate');
                converted_size = getFormattedCurrency(closeDate, size);
				dAmount = dAmount + converted_size;
            }
        }
        
   		System.debug(LoggingLevel.INFO, '@@ getOpportunityAmount : dAmount ' + dAmount);

        return dAmount;        
    }    

    /**
     * Returns the sum of the expected revenue for opportunities owned by the
     * users defined by usrIds and any filters added to the sql_where clause. 
     * The amount will be converted to the selected currency.
     */
    private Decimal getOpportunityExpectedAmount(String sql_where, Date startDate, Date endDate, List<String> usrIds) {        
		List<String> stageDeselect = new List<String> { 'Identified Opportunity (CE)' };        
       
        String SOQL_SELECT = 'SELECT CloseDate, SUM(ExpectedRevenue) amt FROM Opportunity ';
        String SOQL_WHERE = sql_where + ' AND OwnerId IN :usrIds AND (RecordTypeId IN :oppRecordTypeIds) '; 
        SOQL_WHERE = SOQL_WHERE + ' AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR)';   
        SOQL_WHERE = SOQL_WHERE + ' AND CloseDate >= :startDate ' + 'AND CloseDate < :endDate ';        
		SOQL_WHERE += ' AND (StageName NOT IN : stageDeselect) ';       
        String SOQL_GROUP_BY = ' GROUP BY CloseDate';
        
        System.debug(LoggingLevel.INFO, '@@ getOpportunityExpectedAmount : SOQL ' + SOQL_SELECT + SOQL_WHERE+SOQL_GROUP_BY);  
		System.debug(LoggingLevel.INFO, '@@ getOpportunityExpectedAmount : SelectedCriteria ' + usrIds + ' * ' + oppRecordTypeIds);        
        
        List<AggregateResult> results = Database.query(SOQL_SELECT+SOQL_WHERE+SOQL_GROUP_BY);

   		System.debug(LoggingLevel.INFO, '@@ getOpportunityExpectedAmount : results ' + results);
        
        Decimal dAmount = 0;
               
		if(results != null && results.size() > 0) {
            Decimal size = 0;
            Decimal converted_size = 0;
            Date closeDate;
            
            for(AggregateResult ar : results) {
				size = (Decimal)ar.get('amt');
                closeDate = (Date)ar.get('CloseDate');
                converted_size = getFormattedCurrency(closeDate, size);
				dAmount = dAmount + converted_size;
            }
        }
        
   		System.debug(LoggingLevel.INFO, '@@ getOpportunityAmount : dAmount ' + dAmount);

        return dAmount;        
    }    
    
    // - Currency conversion utilities --

    /**
     * Returns the amount converted to the selected currency and set to
     * million scale - "M" is appended to the number in the VF page
     */
    private Decimal getFormattedCurrency(Decimal amount) {
        if (amount != null && amount > 0) {
            Integer scale = 3; 
            Integer divisor = 1000000; // Millions
            amount = getConvertedAmount(amount);
            Decimal formatted = (amount != null && amount > 0) ? amount.divide(divisor, scale) : 0;
            System.debug(LoggingLevel.INFO, '@@ Formatted amount ' + amount + ' to ' + formatted + ' using scale: ' 
                + scale + ', divisor: ' + divisor);
            return formatted;
        }
        System.debug(LoggingLevel.INFO, '@@ Skipped formatting for amount = ' + amount);
        return 0.00; // Setting to zero with proper scale
   }
    
   private Decimal getFormattedCurrency(Date conversionDate, Decimal amount) {
        if (amount != null && amount > 0) {
            Integer scale = 3; 
            Integer divisor = 1000000; // Millions
            amount = getConvertedAmount(conversionDate, amount);
            Decimal formatted = (amount != null && amount > 0) ? amount.divide(divisor, scale) : 0;
            System.debug(LoggingLevel.INFO, '@@ Formatted amount ' + amount + ' to ' + formatted + ' using scale: ' 
                + scale + ', divisor: ' + divisor);
            return formatted;
        }
        System.debug(LoggingLevel.INFO, '@@ Skipped formatting for amount = ' + amount);
        return 0.00; // Setting to zero with proper scale
   }

    /**
     * Returns the amount converted to the selected currency.
     */
    private Decimal getConvertedAmount(Decimal amount) {
        Decimal rate = getExchangeRate();
        Decimal converted = amount * rate;
        System.debug(LoggingLevel.INFO, '@@ Converted amount ' + amount + ' to ' + converted + ' using rate: ' + rate);
        return converted;
    }
    /**
     * 2016-04-05 AHoybye: Added to support proper dated conversion rates
     */
    private Decimal getConvertedAmount(Date conversionDate, Decimal amount) {
        Decimal rate = getExchangeRate(conversionDate);
        Decimal converted = amount * rate;
        System.debug(LoggingLevel.INFO, '@@ Converted amount ' + amount + ' to ' + converted + ' using rate: ' + rate + ' for date ' + conversionDate );
        return converted;
    }

    /**
     * Returns the exchange rate determined by the currency selected by the user. If the selected
     * currency is not found or the rate is 0/undefined the exchange rate for the org default
     * currency is returned (the corporate currency).
     */
    private Decimal getExchangeRate() {
        Decimal rate = mapCurrencies.get(selectedCurrency);
        if (rate == null || rate <= 0) {
            // Selected currency conversion rate was not found - fall back on default
            System.debug(LoggingLevel.ERROR, '@@ Failed to find conversion rate for ' + selectedCurrency + ' using corporate currency instead');
            selectedCurrency = orgDefaultCurrency.IsoCode;
            rate = orgDefaultCurrency.conversionRate;
        }
        System.debug(LoggingLevel.INFO, '@@ Conversion rate set to: ' + rate + ' , currency: ' + selectedCurrency);
       return rate;
    }
    /**
     * 2016-04-05 AHoybye: Added to support proper dated conversion rates
     */
    private Decimal getExchangeRate(Date conversionDate) {
        Decimal rate;
        for (DatedConversionRate dcr : datedRates) {
            if (conversionDate>=dcr.StartDate && conversionDate<dcr.NextStartDate) {
                
                rate = dcr.ConversionRate;
                break;
            }
        }
               
        if (rate == null || rate <= 0) {
            // Selected currency conversion rate was not found - fall back on default
            System.debug(LoggingLevel.ERROR, '@@ Failed to find conversion rate for ' + selectedCurrency + ' using corporate currency instead');
            selectedCurrency = orgDefaultCurrency.IsoCode;
            rate = orgDefaultCurrency.conversionRate;
        }
        System.debug(LoggingLevel.INFO, '@@ Conversion rate set to: ' + rate + ' , currency: ' + selectedCurrency + ', date:' + conversionDate);
        return rate;
    }

    /**
     * Utilty method to convert a list of strings to a comma separated string.
     */
    private String convertListToString(List<String> lStrings) {
        String sFinal = '';
        if(lStrings != null && !lStrings.isEmpty() && lStrings[0] != 'All') {
            for(String s : lStrings) {
                sFinal += s + ',';
            }
            sFinal = sFinal.removeEnd(','); // remove the last comma
        }
        
		System.debug(LoggingLevel.INFO, '@@ convertListToString ' + lStrings + '*' + sFinal);        
        return sFinal;
    }
    
    /**
     * Utilty method for dumping settings to the debug log. Value of prefix
     * will be used as header in the log.
     */
    private void debugFilterSettings(String prefix) {
        if (prefix == '')
            prefix = 'Initial';
        System.debug(LoggingLevel.INFO, '@@ *** ' + prefix + ' filter settings ***');
        System.debug(LoggingLevel.INFO, '-- selectedTeamMember = ' + selectedTeamMember);
        System.debug(LoggingLevel.INFO, '-- selectedSegments = ' + selectedSegments);        
        System.debug(LoggingLevel.INFO, '-- selectedRegions = ' + selectedRegions);        
        System.debug(LoggingLevel.INFO, '-- selectedCountries = ' + selectedCountries);  
        System.debug(LoggingLevel.INFO, '-- selectedTime = ' + selectedTime);                        
        System.debug(LoggingLevel.INFO, '-- selectedCurrency = ' + selectedCurrency);                                
        System.debug(LoggingLevel.INFO, '@@ ***************************************');
    }

    private class StageAggregation {
        public string stageName {get; set;}
        public Decimal converted_amount  {get; set;}
        public Decimal amount  {get; set;}
        public Decimal expected_revenue {get; set;}
        //public Decimal probability {get; set;}
        public Integer count {get; set;}
        public Integer inStageCount {get; set;}
        public Decimal inStageSize {get; set;}
        public Integer totalCount {get; set;}
        public Decimal totalSize {get; set;}
    }
    
   public static Set<ID> getRoleSubordinateUsers(Id userId) {
       System.debug(LoggingLevel.INFO, '@@ JPK1');       
       // get requested user's role
        Id roleId = [select UserRoleId from User where Id = :userId].UserRoleId;
       System.debug(LoggingLevel.INFO, '@@ JPK2' + roleId);         
        // get all of the roles underneath the user
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        // get all of the ids for the users in those roles
        //Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :allSubRoleIds AND ForecastEnabled = true AND IsActive = true]);
        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :allSubRoleIds AND IsActive = true]);       
       System.debug(LoggingLevel.INFO, '@@ JPK3');              
        // return the ids as a set so you can do what you want with them
        return users.keySet();
  }

  private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
       System.debug(LoggingLevel.INFO, '@@ JPK4'); 
      
    Set<ID> currentRoleIds = new Set<ID>();

    // get all of the roles underneath the passed roles
    for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null])
    	currentRoleIds.add(userRole.Id);

    // go fetch some more rolls!
    if(currentRoleIds.size() > 0)
      	currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));

       System.debug(LoggingLevel.INFO, '@@ JPK5');       
      
    return currentRoleIds;
  }    
    
}