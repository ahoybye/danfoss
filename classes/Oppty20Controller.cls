public class Oppty20Controller {  
    public String sHelpHint {get;set;} // Help hint
    public String sHelpText {get;set;} // Help content

    public String sReportHint {get;set;} // Report hint
    public String sReportUrl {get;set;} // Report url

    public List<String> qcheck_data {get;set;} // Data for the Q Check component
    public List<String> qindex_data {get;set;} // Data for the Q Index component
    public List<String> netwin_data {get;set;} // Data for the Net Win component
    public List<String> netwin_trend_data {get;set;} // Data for the Net Win Trend component
    public List<String> size_data {get;set;} // Data for the Size component
    public List<String> stage_data {get;set;} // Data for the Stages component
    public List<String> flow_data {get;set;} // Data for the Flow component
    
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
    private Decimal netWinTargetAmount = 0;
    // The Net Win Realized Amount  - is referenced from Size section
    private Decimal netWinRealizedAmount = 0;
    // The Shape total amount/size  - is referenced from Size section
    private Decimal shapeTotalAmount = 0;
    // The Shape total number  - is referenced from Size section
    private Integer shapeTotalNumber = 0;
    
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
        getNetWinData();
        getNetWinTrendData();
        getFlowData();
        getShapeData();
        getQualityData(); // ref stage data
        getSizeData(); // ref. Net Win and Stage data
      
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
    
    // Net Win component
    public void getNetWinData() {
		List<String> stageDeselect = new List<String> { 'Identified Opportunity (CE)' };        
        
        System.debug(LoggingLevel.INFO, '@@ getNetWinData start');
        
        // Define row names and insert default data (to display if no data is fetched)
        Map<String, String> mapData = new Map<String, String>();
        mapData.put('Target', '[' + '\'' + 'Target' + '\'' + ',' + 0 + ',' + 0 + ']');
        mapData.put('Won', '[' + '\'' + 'Won' + '\'' + ',' + 0 + ',' + 0 + ']');
        mapData.put('Expected', '[' + '\'' + 'Expected (incl. won)' + '\'' + ',' + 0 + ',' + 0 + ']');

        // Get the default values
        netwin_data = mapData.values(); 

        //Set<Id> usrIds = new Set<Id>();

        // Get target data - target is the sum of all forecast quotas in the current
        // year - user cannot change the time period for this
        String SOQL_SELECT = 'SELECT SUM(QuotaAmount) amt FROM ForecastingQuota';
        String SOQL_WHERE = ' WHERE (IsAmount=true) AND StartDate = THIS_YEAR';
        
        // Determine forecast owner
        if((selectedTeamMember != 'AllDanfoss') && (selectedTeamMember != 'AllBelow')) { 
           	if(selectedTeamMember == 'All' ) { // All    
                // all users
                if(userIds.isEmpty()) {
                  System.debug(LoggingLevel.INFO, '@@ getNetWinData : userIds.isEmpty() ');                
                    
                  return; // no valid owners found
                }
                            
                SOQL_WHERE += ' AND (QuotaOwnerId IN :userIds) ';
            }
            else { // a specific user is selected
                System.debug(LoggingLevel.INFO, '@@ getNetWinData : 1 a specific user is selected ' + selectedTeamMember);                            
                 
                SOQL_WHERE += ' AND (QuotaOwnerId = :selectedTeamMember) ';
            }
        } else {
            if(userIds.isEmpty()) return;
            
            SOQL_WHERE += ' AND (QuotaOwnerId IN :userIds) ';    
        }
        
		System.debug(LoggingLevel.INFO, '@@ getNetWinData : SOQL1 ' + SOQL_SELECT + SOQL_WHERE);        
        System.debug(LoggingLevel.INFO, '@@ getNetWinData : SelectedCriteria ' + userIds + ' * ' + selectedTeamMember);        
        
        List<AggregateResult> results = Database.query(SOQL_SELECT+SOQL_WHERE);

        if(results == null && results.isEmpty()) 
            return;

        Decimal dTarget = (Decimal) results[0].get('amt');
        dTarget = getFormattedCurrency(dTarget); 

        System.debug(LoggingLevel.INFO, '@@ getNetWinData : target ' + dTarget);           
        
        String sData = '[' + '\'' + 'Target' + '\'' + ',' + dTarget + ',' + 100 + ']';
        mapData.put('Target', sData);
        netWinTargetAmount = dTarget;

        // Get realized - This is the sum of all won opportunities in the current fiscal year
        // Get the more specific users based on the filters
        
        //Set<Id> oppUsrIds = new Set<Id>();
        
        //String sOrg = 'Climate and Energy'; 
                  
        SOQL_SELECT = 'Select CloseDate, SUM(Won_Amount__c) amt FROM Opportunity';
        //SOQL_WHERE = ' WHERE (IsWon=true) AND (account.business_org__c = :sOrg) ';
        SOQL_WHERE = ' WHERE (IsWon=true) ';
        //SOQL_WHERE = ' WHERE (account.business_org__c = :sOrg) AND (CloseDate = THIS_YEAR) AND (RecordTypeId IN :oppRecordTypeIds) AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR)';  
        //SOQL_WHERE += ' AND (CloseDate = THIS_YEAR) AND (RecordTypeId IN :oppRecordTypeIds) AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR AND QuotaAmount > 0)';
        SOQL_WHERE += ' AND (CloseDate = THIS_YEAR) AND (RecordTypeId IN :oppRecordTypeIds) AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR)';        
        SOQL_WHERE += ' AND (StageName NOT IN : stageDeselect) ';                
        //SOQL_WHERE += ' AND (CloseDate = THIS_YEAR) ';
        //SOQL_WHERE += ' AND (CloseDate = THIS_YEAR) AND (RecordTypeId IN :oppRecordTypeIds)';        
        String SOQL_GROUP_BY = ' GROUP BY CloseDate';
        
        String query;
        //if (selectedTeamMember != 'AllDanfoss') { // All
            if ((selectedTeamMember == 'All' ) || (selectedTeamMember == 'AllDanfoss') || (selectedTeamMember == 'AllBelow')) { // All
            //if (selectedTeamMember == 'All' ) { // All            
                if(userIds.isEmpty()) return;
                
                System.debug(LoggingLevel.INFO, '@@ getNetWinData : A list of users ' + userIds);
                
                SOQL_WHERE += ' AND (OwnerId IN :userIds) ';    
            } else { // a specific user is selected
                System.debug(LoggingLevel.INFO, '@@ getNetWinData : 2 a specific user is selected ' + selectedTeamMember);                                        
                
                SOQL_WHERE += ' AND (OwnerId = :selectedTeamMember) '; // in this case, we ignore region and country selections
            }
        //}

        System.debug(LoggingLevel.INFO, '@@ getNetWinData : SOQL2 ' + SOQL_SELECT + SOQL_WHERE + SOQL_GROUP_BY);
  	    //System.debug(LoggingLevel.INFO, '@@ getNetWinData : SelectedCriteria ' + sOrg + ' * ' + userIds + ' * ' + selectedTeamMember + ' * ' + oppRecordTypeIds);        
  	    System.debug(LoggingLevel.INFO, '@@ getNetWinData : SelectedCriteria ' + userIds + ' * ' + selectedTeamMember + ' * ' + oppRecordTypeIds);        
        
        results = Database.query(SOQL_SELECT+SOQL_WHERE+SOQL_GROUP_BY);

        Decimal dReal = 0;
               
		if(results != null && results.size() > 0) {
            Decimal size = 0;
            Decimal converted_size = 0;
            Date closeDate;
            
            for(AggregateResult ar : results) {
				size = (Decimal)ar.get('amt');
                closeDate = (Date)ar.get('CloseDate');
                converted_size = getFormattedCurrency(closeDate, size);
				dReal = dReal + converted_size;
            }
        }
        
        //Decimal dReal = (Decimal) results[0].get('amt');
        //dReal = getFormattedCurrency(dReal);

        //Integer dPercent = (dTarget != 0) ? (Integer) (dReal/dTarget) * 100 : 0;
        Decimal dPercent;
        Integer intPercent;
        IF (dTarget > 0) {
            dPercent = (dReal/dTarget) * 100;
            intPercent = dPercent.intValue();            
        } else {
            intPercent = 0;
        }
        
        System.debug(LoggingLevel.INFO, '@@ getNetWinData : Won ' + dReal + ' * ' + dTarget + ' * ' + intPercent);        
        
        sData = '[' + '\'' + 'Won' + '\'' + ',' + dReal + ',' + intPercent + ']';
        mapData.put('Won', sData);
        netWinRealizedAmount = dReal;

        // Get estimated data - sum of expected revenue for all won opportunities and all opportunities
        // closing in this fiscal year       
        SOQL_SELECT = 'Select CloseDate, SUM(ExpectedRevenue) amt FROM Opportunity';
        //SOQL_WHERE = ' WHERE (CloseDate = THIS_YEAR) AND (account.business_org__c = :sOrg) ';
        //SOQL_WHERE = ' WHERE (CloseDate = THIS_YEAR) AND (account.business_org__c = :sOrg) AND (RecordTypeId IN :oppRecordTypeIds)';
        SOQL_WHERE = ' WHERE (CloseDate = THIS_YEAR) AND (RecordTypeId IN :oppRecordTypeIds)';
        
        if ((selectedTeamMember == 'All') || (selectedTeamMember == 'AllDanfoss') || (selectedTeamMember == 'AllBelow')) { // all users
            SOQL_WHERE += ' AND (OwnerId IN :userIds) ';
        }
        else { // a specific user is selected
            SOQL_WHERE += ' AND (OwnerId = :selectedTeamMember) '; // in this case, we ignore region and country selections
        }
        //SOQL_WHERE += 'AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR AND QuotaAmount > 0)';
        SOQL_WHERE += 'AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR)';        
        SOQL_WHERE += ' AND (StageName NOT IN : stageDeselect) ';                
        SOQL_GROUP_BY = ' GROUP BY CloseDate';
        
        
        System.debug(LoggingLevel.INFO, '@@ getNetWinData : SOQL3 ' + SOQL_SELECT + SOQL_WHERE+SOQL_GROUP_BY);
  	    //System.debug(LoggingLevel.INFO, '@@ getNetWinData : SelectedCriteria ' + sOrg + ' * ' + userIds + ' * ' + selectedTeamMember + ' * ' + oppRecordTypeIds);
  	    System.debug(LoggingLevel.INFO, '@@ getNetWinData : SelectedCriteria ' + userIds + ' * ' + selectedTeamMember + ' * ' + oppRecordTypeIds);
        
        results = Database.query(SOQL_SELECT+SOQL_WHERE+SOQL_GROUP_BY);

        Decimal dExpect = 0;
        
		if(results != null && results.size() > 0) {
            Decimal size = 0;
            Decimal converted_size = 0;
            Date closeDate;
            
            for(AggregateResult ar : results) {
				size = (Decimal)ar.get('amt');
                closeDate = (Date)ar.get('CloseDate');
                converted_size = getFormattedCurrency(closeDate, size);
				dExpect = dExpect + converted_size;
            }
        }        
        
        //Decimal dExpect = (Decimal) results[0].get('amt');
        //dExpect = getFormattedCurrency(dExpect);
        
        //dPercent = (dTarget != 0) ? (Integer) (dExpect/dTarget) * 100 : 0;
        IF (dTarget > 0) {
            dPercent = (dExpect/dTarget) * 100;
            intPercent = dPercent.intValue();            
        } else {
            intPercent = 0;
        }
        
        System.debug(LoggingLevel.INFO, '@@ getNetWinData : Expected ' + dExpect + ' * ' + dTarget + ' * ' + intPercent);                
        
        sData = '[' + '\'' + 'Expected (incl. won)' + '\'' + ',' + dExpect + ',' + intPercent + ']';
        mapData.put('Expected', sData);
        netwin_data = mapData.values();
    }
    
    // Net Win Trend country_lookup
    public void getNetWinTrendData() {
        Map<String, String> mapData = new Map<String, String>(); // map of stage name and default stage data
        mapData.put('Target', '[' + '\'' + 'Target' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        mapData.put('Won', '[' + '\'' + 'Won' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');        
        mapData.put('Expected', '[' + '\'' + 'Expected (incl. won)' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');          
        mapData.put('Gap', '[' + '\'' + 'Gap' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ',' + 0 + ']');

        netwin_trend_data = mapData.values(); // Get the default values

        //et<Id> usrIds = new Set<Id>();
        
        //if(selectedTeamMember != 'AllDanfoss') { 
        //    if(selectedTeamMember == 'All') { // all users
        //        usrIds = RoleHierarchyHelper.getRoleSubordinateUsers(runningUserId);
        //        if(usrIds.isEmpty()) return; // no valid owners found
        //    }
         //   else { // a specific user is selected
         //       usrIds.add(selectedTeamMember);
         //   }
        //} else {
        //    String query;
        //    
        //    String itPeople = '%ServiceDesk%';                
         //   query = 'SELECT Id FROM User WHERE (isActive = true) AND (NOT Profile.Name LIKE : itPeople)';                
        //    
        //    if(!selectedSegments.isEmpty() && selectedSegments[0] != 'All') { // set the segment condition
        //        query += ' AND (Division__c IN :selectedSegments)';
        //    }
        //    if(!selectedRegions.isEmpty() && selectedRegions[0] != 'All') { // a specific region is selected
        //        query += ' AND (Region__c IN :selectedRegions) ';
         //   }                
         //   if(!selectedCountries.isEmpty() && selectedCountries[0] != 'All') { // a specific country is selected
         //       query += ' AND (User_Country__c IN :selectedCountries) ';
         //   }
         //   
         //   System.debug(LoggingLevel.INFO, '@@ getNetWinData : query ' + query);                            
         //   System.debug(LoggingLevel.INFO, '@@ getNetWinData : SelectedCriteria ' + usrIds + ' * ' + selectedSegments + ' * ' + selectedRegions + ' * ' + selectedCountries);        
         //   
        //    List<User> lstUsrs = Database.query(query); 
        //    for(User u : lstUsrs) usrIds.add(u.Id);
        //    if(usrIds.isEmpty()) return;
        //}            
        
        List<Period> periods = [select Id, StartDate, EndDate From Period Where type = 'Quarter' 
            and (StartDate = NEXT_N_QUARTERS:4 OR StartDate = THIS_QUARTER) ORDER BY StartDate ASC];
        Date qStart = periods[0].StartDate;
        Date qNextStart = periods[1].StartDate;
        Date q2Start = periods[2].StartDate;
        Date q3Start = periods[3].StartDate;
        Date q4Start = periods[4].StartDate;
        Date q4End = periods[4].EndDate.addDays(1);
        Date yearStart = Date.newInstance(Date.today().year(), 1, 1);
        Date tomorrow = Date.today().addDays(1);

        // Target
        Decimal tAmount = getForecastAmount(yearStart, tomorrow, userIds);
        Decimal tQ1 = getForecastAmount(qStart, qNextStart, userIds);
        Decimal tnextQ = getForecastAmount(qNextStart, q2Start, userIds);
        Decimal tnext2Q = getForecastAmount(q2Start, q3Start, userIds);
        Decimal tnext3Q = getForecastAmount(q3Start, q4Start, userIds);
        Decimal tnext4Q = getForecastAmount(q4Start, q4End, userIds);

        String sData = '[' + '\'' + 'Target' + '\'' + ',' + tAmount + ',' + tQ1 + ',' + tnextQ
                    + ',' + tnext2Q + ',' + tnext3Q + ',' + tnext4Q + ']';

        mapData.put('Target', sData);

        // Act/Est - This is on opportunity object
        // Get the more specific users based on the filters
        //Set<Id> oppUsrIds = new Set<Id>();
        Decimal wAmount=0, wQ1=0, wnextQ=0, wnext2Q=0, wnext3Q=0, wnext4Q=0;

        //String query;
        //if(selectedTeamMember == 'AllDanfoss') { 
		//	string itPeople = '%ServiceDesk%';                
        //    query = 'SELECT Id FROM User WHERE (isActive = true) AND (NOT Profile.Name LIKE : itPeople)';  
        //} else {
        //    query = 'SELECT Id FROM User WHERE (Id IN :usrIds) ';            
        //}
        //    
        //if(!selectedSegments.isEmpty() && selectedSegments[0] != 'All') { // set the segment condition
        //    query += ' AND (Division__c IN :selectedSegments)';
        //}
        //if(!selectedRegions.isEmpty() && selectedRegions[0] != 'All') { // a specific region is selected
        //    query += ' AND (Region__c IN :selectedRegions) ';
        //}                
        //if(!selectedCountries.isEmpty() && selectedCountries[0] != 'All') { // a specific country is selected
        //    query += ' AND (User_Country__c IN :selectedCountries) ';
        //}
            
        //System.debug(LoggingLevel.INFO, '@@ getNetWinTrendData : query ' + query);                            
        //System.debug(LoggingLevel.INFO, '@@ getNetWinTrendData : SelectedCriteria ' + userIds + ' * ' + selectedSegments + ' * ' + selectedRegions + ' * ' + selectedCountries);
        
        //List<User> lstUsrs = Database.query(query); 
        //for(User u : lstUsrs) oppUsrIds.add(u.Id);
        //if(!oppUsrIds.isEmpty()) {
		if(!userIds.isEmpty()) {            
            wAmount = getOpportunityWonAmount(' WHERE IsWon = True AND CloseDate = THIS_YEAR ', userIds);
            wQ1 	= getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) AND CloseDate = THIS_QUARTER ', userIds);
            wnextQ 	= getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) AND CloseDate = NEXT_QUARTER ', userIds);
            wnext2Q = getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) AND CloseDate = NEXT_N_QUARTERS:2 ', userIds);
            wnext3Q = getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) AND CloseDate = NEXT_N_QUARTERS:3 ', userIds);
            wnext4Q = getOpportunityWonAmount(' WHERE (IsClosed = False OR IsWon = True) AND CloseDate = NEXT_N_QUARTERS:4 ', userIds);
            wnext4Q = wnext4Q - wnext3q; 
            wnext3Q = wnext3Q - wnext2q;             
            wnext2Q = wnext2Q - wnextq;             
        }

        sData = '[' + '\'' + 'Won' + '\''  + ',' + wAmount + ',' + wQ1 + ',' + wnextQ
                    + ',' + wnext2Q + ',' + wnext3Q + ',' + wnext4Q + ']';

        System.debug(LoggingLevel.INFO, '@@ getNetWinTrendData : Won ' + sData);                            
        
        mapData.put('Won', sData);

        // Expected amount
        Decimal eAmount=0, eQ1=0, enextQ=0, enext2Q=0, enext3Q=0, enext4Q=0;
  
		if(!userIds.isEmpty()) {            
            //String strClosedWon = 'Closed-Won';
            
            //eAmount = getOpportunityExpectedAmount(' WHERE CloseDate = THIS_YEAR AND CloseDate <= TODAY AND StageName != :strClosedWon ', userIds);
            eAmount = getOpportunityExpectedAmount(' WHERE CloseDate = THIS_YEAR AND CloseDate <= TODAY ', userIds);            
            eQ1 	= getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) AND CloseDate = THIS_QUARTER ', userIds);
            enextQ 	= getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) AND CloseDate = NEXT_QUARTER ', userIds);
            enext2Q = getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) AND CloseDate = NEXT_N_QUARTERS:2 ', userIds);
            enext3Q = getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) AND CloseDate = NEXT_N_QUARTERS:3 ', userIds);
            enext4Q = getOpportunityExpectedAmount(' WHERE (IsClosed = False OR IsWon = True) AND CloseDate = NEXT_N_QUARTERS:4 ', userIds);
            enext4Q = enext4Q - enext3q; 
            enext3Q = enext3Q - enext2q;             
            enext2Q = enext2Q - enextq;             
        }

        sData = '[' + '\'' + 'Expected (incl. won)' + '\''  + ',' + eAmount + ',' + eQ1 + ',' + enextQ
                    + ',' + enext2Q + ',' + enext3Q + ',' + enext4Q + ']';

        System.debug(LoggingLevel.INFO, '@@ getNetWinTrendData : Expected ' + sData);                            
        
        mapData.put('Expected', sData);         
        
        // Delta
        Decimal dAmount = eAmount - tAmount;
        Decimal dQ1 = eQ1 - tQ1;
        Decimal dnextQ = enextQ - tnextQ;
        Decimal dnext2Q = enext2Q - tnext2Q;
        Decimal dnext3Q = enext3Q - tnext3Q;
        Decimal dnext4Q = enext4Q - tnext4Q;

        sData = '[' + '\'' + 'Gap' + '\'' + ',' + dAmount + ',' + dQ1 + ',' + dnextQ
                    + ',' + dnext2Q + ',' + dnext3Q + ',' + dnext4Q + ']';

        System.debug(LoggingLevel.INFO, '@@ getNetWinTrendData : Gap ' + sData);                            
        
        mapData.put('Gap', sData);
        netwin_trend_data = mapData.values();
    }
            
    // Size component
    public void getSizeData() {
        Map<String, String> mapData = new Map<String, String>(); // map of stage name and default stage data
        mapData.put('Current Year', '[' + '\'' + 'Current Year' + '\'' + ',' + 0 + ',' + 0 + ',' + null + ']');
        mapData.put('Total', '[' + '\'' + 'Total' + '\'' + ',' + 0 + ',' + 0 + ',' + null + ']');
        //mapData.put('Index', '[' + '\'' + 'Index' + '\'' + ',' + null + ',' + null + ']');

        size_data = mapData.values(); // Get the default values
        
        // Set selected user
        //Set<Id> usrIds = new Set<Id>();
        
        //if(selectedTeamMember != 'AllDanfoss') {         
        //    if(selectedTeamMember == 'All') { // all users
         //       usrIds = RoleHierarchyHelper.getRoleSubordinateUsers(runningUserId);
         //       if(usrIds.isEmpty()) return; // no valid owners found
         //   }
         //   else { // a specific user is selected
        //        usrIds.add(selectedTeamMember);
        //    }
        //}
            
        //String stageDeselect = '(Identified Opportunity (CE),Closed-Won,Closed-Lost)'; 
        List<String> stageDeselect = new List<String> { 'Identified Opportunity (CE)', 'Closed-Won' , 'Closed-Lost' };
        
        // Current: Number and size of all open opportunities in the current period/year
        String SOQL_SELECT = 'SELECT Count(Id) cy_num, SUM(Amount) cy_size FROM Opportunity ';
        String SOQL_WHERE = 'WHERE CloseDate >= TODAY AND CloseDate = THIS_YEAR AND (IsClosed = false OR IsWon = true) ';


        //if (!selectedSegments.isEmpty() && selectedSegments[0] != 'All') {
        //    SOQL_WHERE += ' AND (Owner.Division__c IN :selectedSegments)';
        //}
        //if (!selectedRegions.isEmpty() && selectedRegions[0] != 'All') {
        //    SOQL_WHERE += ' AND (Owner.Region__c IN :selectedRegions)';
        //}
        //if (!selectedCountries.isEmpty() && selectedCountries[0] != 'All') {
        //    SOQL_WHERE += ' AND (Owner.User_Country__c IN :selectedCountries)';
        //}
        
        //if(selectedTeamMember != 'AllDanfoss') { 
        //	SOQL_WHERE += ' AND (OwnerId IN :usrIds) '; 
        if(!userIds.isEmpty()) {
        	SOQL_WHERE += ' AND (OwnerId IN :userIds) ';        
        }
        //}
        //SOQL_WHERE += ' AND (StageName != :stageDeselect) ';        
        SOQL_WHERE += ' AND (StageName NOT IN : stageDeselect) ';                
        
        System.debug(LoggingLevel.INFO, '@@ getSizeData : SOQL ' + SOQL_SELECT + SOQL_WHERE);
        System.debug(LoggingLevel.INFO, '@@ getSizeData : SelectedCriteria ' + selectedSegments + ' * ' + selectedRegions + ' * ' + selectedCountries + '*' + stageDeselect);
        
        // Size
        List<AggregateResult> current = Database.query(SOQL_SELECT+SOQL_WHERE);

        Decimal currentCount = 0;
        Decimal currentSize = 0;

        if(current != null && current.size() == 1) {   
            currentSize = (Decimal) current[0].get('cy_size');
            currentSize = getFormattedCurrency(currentSize); 
            currentCount = (Decimal) current[0].get('cy_num');        
        }

        Decimal sizeIndex = ((netWinTargetAmount - netWinRealizedAmount) > 0) ? 
            currentSize / (netWinTargetAmount - netWinRealizedAmount)  : 0.0;

        // Add data to data set for display
        String sData = '[' + '\'' + 'Current Year' + '\'' + ',' + currentCount + ',' + currentSize + ',' + sizeIndex.setScale(2) + ']';
        mapData.put('Current Year', sData);
        
        // Totals - get the total amount and number from the Shape section
        sData = '[' + '\'' + 'Total' + '\'' + ',' + shapeTotalNumber + ',' + shapeTotalAmount + ',' + null + ']';
        mapData.put('Total', sData);

        //sData = '[' + '\'' + 'Index' + '\'' + ',' + sizeIndex + ',' + null + ']';
        //mapData.put('Index', sData);
        
        size_data = mapData.values();
    }
    
    public void getFlowData() {        
        Map<String, String> mapData = new Map<String, String>(); // map of stage name and default stage data
        mapData.put('Identified Opportunity (CE)', '[' + '\'' + 'New in Identified Opportunity (CE)' + '\'' + ',' + 0 + ',' + 0 + ']');
        mapData.put('Initial Planning (CE)', '[' + '\'' + 'New in Initial Planning (CE)' + '\'' + ',' + 0 + ',' + 0 + ']');
        mapData.put('Specifying Solution (CE)', '[' + '\'' + 'New in Specifying Solution (CE)' + '\'' + ',' + 0 + ',' + 0 + ']');
        mapData.put('Evaluating Solution (CE)', '[' + '\'' + 'New in Evaluating Solution (CE)' + '\'' + ',' + 0 + ',' + 0 + ']');
        //mapData.put('Ordering Solution (CE)', '[' + '\'' + 'New in Ordering Solution (CE)' + '\'' + ',' + 0 + ',' + 0 + ']');
        mapData.put('Closed-Won', '[' + '\'' + 'Closed-Won' + '\'' + ',' + 0 + ',' + 0 + ']');
        mapData.put('Closed-Lost', '[' + '\'' + 'Closed-Lost' + '\'' + ',' + 0 + ',' + 0 + ']');
        
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
        
        //String SOQL_SELECT = 'SELECT Stage__c, sum(opportunity_count__c) cnt, sum(amount__c) amount_sum FROM Opportunity_Trending__c';
        //String SOQL_WHERE = ' WHERE (Period__c >= :sDate AND Period__c <= :eDate) ';
        String SOQL_SELECT = 'SELECT StageName, count(id) cnt, sum(amount) amount_sum FROM Opportunity';
        String SOQL_WHERE = ' WHERE (CE_STAGE_CHANGE_DATE__c  >= :sDate AND CE_STAGE_CHANGE_DATE__c <= :eDate) ';
        SOQL_WHERE += ' AND (StageName NOT IN : stageDeselect) ';        
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
        
        //Set<Id> usrIds = new Set<Id>();
        //System.debug(LoggingLevel.INFO, '@@ Flow: selectedTeamMeber ' + selectedTeamMember);
        
        //if(selectedTeamMember != 'AllDanfoss') {         
        //    if(selectedTeamMember == 'All') { // all users
         //       usrIds = RoleHierarchyHelper.getRoleSubordinateUsers(runningUserId);
         //       System.debug(LoggingLevel.INFO, '@@ Flow: All usrIds ' + usrIds);
          //      if(usrIds.isEmpty()) {
          //          System.debug(LoggingLevel.INFO, '@@ Flow: All no users found in hierarchy');
         //           return; // no valid owners found
         //       }
         //                   
         //       SOQL_WHERE += ' AND (OwnerId__c IN :usrIds) ';
         //   }
         //   else { // a specific user is selected
         //       SOQL_WHERE += ' AND (OwnerId__c = :selectedTeamMember) ';
         //   }
        //}
        
        if(!userIds.isEmpty()) {
        	//SOQL_WHERE += ' AND (OwnerId__c IN :userIds) '; 
        	SOQL_WHERE += ' AND (OwnerId IN :userIds) ';             
        }
        
        System.debug(LoggingLevel.INFO, '@@ Flow: Users = ' + userIds);
        //String SOQL_GROUP_BY = ' GROUP BY Stage__c';
        String SOQL_GROUP_BY = ' GROUP BY StageName';
        
        System.debug(LoggingLevel.INFO, '@@ getFlowData : SOQL ' + SOQL_SELECT + SOQL_WHERE + SOQL_GROUP_BY);
  	    System.debug(LoggingLevel.INFO, '@@ getFlowData : SelectedCriteria ' + sDate + ' * ' + eDate + ' * ' + selectedSegments + ' * ' + selectedRegions + ' * ' + selectedCountries + ' * ' + userIds + ' * ' + selectedTeamMember);        
        
        List<AggregateResult> results = Database.query(SOQL_SELECT+SOQL_WHERE+SOQL_GROUP_BY);
        
        System.debug(LoggingLevel.INFO, '@@ Flow: query results ' + results);
        for (AggregateResult ar : results) {
            //String stg = (String) ar.get('Stage__c');
            String stg = (String) ar.get('StageName');            
            if(mapData.containsKey(stg)) {               
                Decimal cnt = (Decimal) ar.get('cnt');
                if(cnt == null) cnt = 0;
                
                Decimal size = (Decimal) ar.get('amount_sum');
                size = getFormattedCurrency(size);
    
                String sData = '[' + '\'' + 'New in ' + stg + '\'' + ',' + cnt + ',' + size + ']';   
                mapData.put(stg, sData);
            }
        }
        flow_data = mapData.values(); // fetch the latest values
    }

    public void getQualityData () {
        qcheck_data = new List<String>(); // initialise the data list (also clear old data)
        qindex_data = new List<String>(); // initialise the data list (also clear old data)

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
            if(stalled == null) stalled = 0;

            //stalled_amount = (Decimal) OpptyTrend_current.get(0).get('stalled_amount');
            //stalled_amount = getFormattedCurrency(stalled_amount); // * getExchangeRate();
            stalled_amount = 0; // JPK Temp change 07-04-2016

            //extralarge = (Decimal) OpptyTrend_current.get(0).get('extralarge_count');
            if(extralarge == null) extralarge = 0;

            //extralarge_sum = (Decimal) OpptyTrend_current.get(0).get('extralarge_sum');
            //extralarge_sum = getFormattedCurrency(extralarge_sum); // * getExchangeRate();
            extralarge_sum = 0; // JPK Temp change 07-04-2016
            
            //overaged = (Decimal) OpptyTrend_current.get(0).get('overaged_count');
            if(overaged == null) overaged = 0;

            //overaged_sum = (Decimal) OpptyTrend_current.get(0).get('overaged_sum');
            //overaged_sum = getFormattedCurrency(overaged_sum);// * getExchangeRate();
            overaged_sum = 0; // JPK Temp change 07-04-2016
            
            //timeslip = (Decimal) OpptyTrend_current.get(0).get('timeslip_count');
            if(timeslip == null) timeslip = 0;

            //timeslip_sum = (Decimal) OpptyTrend_current.get(0).get('timeslip_sum');
            if(timeslip_sum == null) timeslip_sum = 0;
            timeslip_sum = getFormattedCurrency(timeslip_sum); // * getExchangeRate();
            
            //sizechange = (Decimal) OpptyTrend_current.get(0).get('sizechange_count');
            if(sizechange == null) sizechange = 0;

            //sizechange_sum = (Decimal) OpptyTrend_current.get(0).get('sizechange_sum');
			if(sizechange_sum == null) sizechange_sum = 0;            
            sizechange_sum = getFormattedCurrency(sizechange_sum); // * getExchangeRate();
            
            //amount_sum = (Decimal) OpptyTrend_current.get(0).get('amount_sum');
            if(amount_sum == null) amount_sum = 0;
            //amount_sum = getFormattedCurrency(amount_sum);
            
            // Risk amount is the sum of all amounts except overdue
            risk_amount = inactive_sum + stalled_amount + extralarge_sum + overaged_sum + timeslip_sum + sizechange_sum;
            
            if (shapeTotalAmount > 0 && risk_amount != null) {
                risk_index = (risk_amount/shapeTotalAmount)*100; // Use total pipeline size from stage section
            }
            // Overdue index is sum of overdue amount/total pipeline sum
            if (shapeTotalAmount > 0 && overdue_sum != null) {
                overdue_index = (overdue_sum/shapeTotalAmount)*100;
            }
        }
        
        String sData = '[' + '\'' + 'Overdue' + '\'' + ',' + overdue + ',' + overdue_sum + ']';
        qcheck_data.add(sData);

        sData = '[' + '\'' + 'Inactive' + '\'' + ',' + inactive + ',' + inactive_sum + ']';
        qcheck_data.add(sData);

        sData = '[' + '\'' + 'Stalled' + '\'' + ',' + stalled + ',' + stalled_amount + ']';
        qcheck_data.add(sData);
                
        sData = '[' + '\'' + 'Extra Large' + '\'' + ',' + extralarge + ',' + extralarge_sum + ']';
        qcheck_data.add(sData);
  
        sData = '[' + '\'' + 'Overaged' + '\'' + ',' + overaged + ',' + overaged_sum + ']';
        qcheck_data.add(sData);

        sData = '[' + '\'' + 'Time Slippage' + '\'' + ',' + timeslip + ',' + timeslip_sum + ']';
        qcheck_data.add(sData);

        sData = '[' + '\'' + 'Size Change' + '\'' + ',' + sizechange + ',' + sizechange_sum + ']';
        qcheck_data.add(sData);
        
        System.debug(LoggingLevel.INFO,'@@ Quality: qcheck_data ' + qcheck_data);        
        
        // QIndex
        sData = '[' + '\'' + 'Overdue %' + '\'' + ',' + overdue_index_old.intValue() + ',' + overdue_index.intValue() + ']';
        qindex_data.add(sData);

        sData = '[' + '\'' + 'Risk Index' + '\'' + ',' + risk_index_old.setScale(1) + ',' + risk_index.setScale(1) + ']';
        qindex_data.add(sData);
    }
    
    // function to get the stage name, number of opps, and total amount for the Shape dashboard component
    public void getShapeData() {
        Map<String, String> mapData = new Map<String, String>(); // map of stage name and default stage data
        
        mapData.put('Identified Opportunity (CE)', '[' + '\'' + 'Identified Opportunity (CE)' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        mapData.put('Initial Planning (CE)', '[' + '\'' + 'Initial Planning (CE)' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        mapData.put('Specifying Solution (CE)', '[' + '\'' + 'Specifying Solution (CE)' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        mapData.put('Evaluating Solution (CE)', '[' + '\'' + 'Evaluating Solution (CE)' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ']');
        //mapData.put('Ordering Solution (CE)', '[' + '\'' + 'Ordering Solution (CE)' + '\'' + ',' + 0 + ',' + 0 + ',' + 0 + ']');

        String SOQL_SELECT = 'SELECT StageName, CloseDate, Count(Id) opp_cnt, SUM(Amount) amount_sum, AVG(Probability) prob, SUM(ExpectedRevenue) exp_rev FROM Opportunity';
        String SOQL_WHERE = ' WHERE IsClosed = false  AND (RecordTypeId IN :oppRecordTypeIds) ';                
        //SOQL_WHERE += ' AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR AND QuotaAmount > 0)';            
        //SOQL_WHERE += ' AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR)';                    
        
        //if (!selectedSegments.isEmpty() && selectedSegments[0] != 'All') {
        //    SOQL_WHERE += ' AND (Owner.Division__c IN :selectedSegments)';
        //}
        //if (!selectedRegions.isEmpty() && selectedRegions[0] != 'All') {
        //    SOQL_WHERE += ' AND (Owner.Region__c IN :selectedRegions)';
        //}
        //if (!selectedCountries.isEmpty() && selectedCountries[0] != 'All') {
        //    SOQL_WHERE += ' AND (Owner.User_Country__c IN :selectedCountries)';
        //}

        //Set<Id> usrIds = new Set<Id>();
        //if(selectedTeamMember != 'AllDanfoss') {         
        //    if(selectedTeamMember == 'All') { // all users
         //       usrIds = RoleHierarchyHelper.getRoleSubordinateUsers(runningUserId);
         //       if(usrIds.isEmpty()) return; // no valid owners found
         //                   
         //       SOQL_WHERE += ' AND (OwnerId IN :usrIds) ';
         //   }
        //    else { // a specific user is selected
         //       SOQL_WHERE += ' AND (OwnerId = :selectedTeamMember)';
        //    }
        //}
        
        if(!userIds.isEmpty()) {
			SOQL_WHERE += ' AND (OwnerId IN :userIds) ';
        }
        
        String SOQL_GROUP_BY = ' GROUP BY StageName, CloseDate';

        System.debug(LoggingLevel.INFO, '@@ getShapeData : SOQL ' + SOQL_SELECT + SOQL_WHERE + SOQL_GROUP_BY);        
		System.debug(LoggingLevel.INFO, '@@ getShapeData : SelectedCriteria ' + selectedSegments + ' * ' + selectedRegions + ' * ' + selectedCountries + ' * ' + userIds + ' * ' + selectedTeamMember + ' * ' + oppRecordTypeIds);
        
        List<AggregateResult> results = Database.query(SOQL_SELECT+SOQL_WHERE+SOQL_GROUP_BY);
        Map<String, ShapeAggregation> shapeAggr = new Map<String, ShapeAggregation>();
        Integer cntTotal = 0;
        Decimal sizeTotal = 0;

        System.debug(LoggingLevel.INFO, '@@ Shape: Query results = ' + results);        
        if(results != null && results.size() > 0) {
            Integer cnt = 0;
            Decimal size = 0;
            Decimal converted_size = 0;
            Date closeDate;
            for(AggregateResult ar : results) {
                System.debug(LoggingLevel.INFO, '@@ Shape: Query result: ' + ar);        
                String stage = (String)ar.get('StageName');
                cnt = (Integer)ar.get('opp_cnt');
                size = (Decimal)ar.get('amount_sum');
                closeDate = (Date)ar.get('CloseDate');
                converted_size = getFormattedCurrency(closeDate, size);
                if(cnt == null) 
                    cnt = 0;
                if (stage != 'Identified Opportunity (CE)'){
                    cntTotal += cnt;
                    sizeTotal += converted_size;
                }
                
                Decimal exp_rev = (Decimal) ar.get('exp_rev');
                Decimal amount_sum = (Decimal) ar.get('amount_sum');
                
                System.debug(LoggingLevel.INFO, '@@ Shape: Find stage ' + stage);
                
                if (shapeAggr.containsKey(stage)) { // stage already exists - update existing stage data                    
                    System.debug(LoggingLevel.INFO, '@@ Shape: Found stage ' + stage);
                    ShapeAggregation sa = shapeAggr.get(stage);
                    sa.amount = (sa.amount +(size!=null?size:0));
                    sa.converted_amount = (sa.converted_amount +(converted_size!=null?converted_size:0));                    
        			sa.expected_revenue = (sa.expected_revenue +(exp_rev!=null?exp_rev:0));
        			//sa.probability = 
        			sa.count = (sa.count+(cnt!=null?cnt:0));
                } else {
                    System.debug(LoggingLevel.INFO, '@@ Shape: Add stage ' + stage);
                    ShapeAggregation sa = new ShapeAggregation();
                    sa.stageName = stage;
                    sa.amount = (size!=null?size:0);
                    sa.converted_amount = (converted_size!=null?converted_size:0);
        			sa.expected_revenue =(exp_rev!=null?exp_rev:0);
        			//sa.probability = 
        			sa.count = (cnt!=null?cnt:0);
                    shapeAggr.put(stage, sa);
                }
                    
                //Decimal prob = (Decimal) ar.get('prob');
                //if(prob == null) prob = 0;
                //prob = (cnt > 0) ? (prob / cnt) : 0 ; 
                     
                            
            }
            Decimal prob=0;
            for (ShapeAggregation sa : shapeAggr.values()) {
                
                if ((sa.expected_revenue != null) && (sa.amount != null) && (sa.amount > 0)) {
                   //prob = (ar.get('exp_rev') / ar.get('amount_sum') * 100);
                   prob = (sa.expected_revenue / sa.amount * 100);                    
                }
                
				System.debug(LoggingLevel.INFO, '@@ getShapeData : Amount ' + sa.stageName + '*' + sa.amount + '*' + '*' + sa.count + '*' + sa.converted_amount);                
                
                String sData = '[' + '\'' + sa.stageName + '\'' + ',' + sa.count + ',' + sa.converted_amount + ',' + prob + ']';
                mapData.put(sa.stageName, sData);
            }
        }
        //System.debug(LoggingLevel.INFO, '@@ Shape: Values to add to table data' + mapData.values());        
        stage_data = mapData.values();
        String sData = '[' + '\'' + 'Total' + '\'' + ',' + cntTotal + ',' + sizeTotal + ',' + null + ']';
        stage_data.add(sData);
        //System.debug(LoggingLevel.INFO, '@@ Shape: Final stage_data ' + stage_data);    
        // Store totals for use in size section
        shapeTotalAmount = sizeTotal;
        shapeTotalNumber = cntTotal;
        
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
    private Decimal getOpportunityWonAmount(String sql_where, List<String> usrIds) {        
		List<String> stageDeselect = new List<String> { 'Identified Opportunity (CE)' };        

        //String sOrg = 'Climate and Energy';
             
        String SOQL_SELECT = 'SELECT CloseDate, SUM(Won_Amount__c) amt FROM Opportunity ';
        //String SOQL_WHERE = sql_where + ' AND OwnerId IN :usrIds AND account.business_org__c = :sOrg ';
        //String SOQL_WHERE = sql_where + ' AND OwnerId IN :usrIds AND account.business_org__c = :sOrg  AND (RecordTypeId IN :oppRecordTypeIds) ';        
        String SOQL_WHERE = sql_where + ' AND OwnerId IN :usrIds AND (RecordTypeId IN :oppRecordTypeIds) '; 
        //SOQL_WHERE = SOQL_WHERE + ' AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR AND QuotaAmount > 0)';
        SOQL_WHERE = SOQL_WHERE + ' AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR)';        
		SOQL_WHERE += ' AND (StageName NOT IN : stageDeselect) ';                
        String SOQL_GROUP_BY = ' GROUP BY CloseDate';
        
        System.debug(LoggingLevel.INFO, '@@ getOpportunityWonAmount : SOQL ' + SOQL_SELECT + SOQL_WHERE+SOQL_GROUP_BY);  
		//System.debug(LoggingLevel.INFO, '@@ getOpportunityAmount : SelectedCriteria ' + usrIds + ' * ' + sOrg + ' * ' + oppRecordTypeIds);
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
        
        //Decimal dAmount = 0;
        //if(results != null && results.size() == 1) {
        //    dAmount = (Decimal) results[0].get('amt');
        //}

   		System.debug(LoggingLevel.INFO, '@@ getOpportunityAmount : dAmount ' + dAmount);

        
        //return getFormattedCurrency(dAmount);
        return dAmount;        
    }

    
    /**
     * Returns the sum of the expected revenue for opportunities owned by the
     * users defined by usrIds and any filters added to the sql_where clause. 
     * The amount will be converted to the selected currency.
     */
    //private Decimal getOpportunityAmount(String sql_where, Set<Id> usrIds) {
    private Decimal getOpportunityExpectedAmount(String sql_where, List<String> usrIds) {        
		List<String> stageDeselect = new List<String> { 'Identified Opportunity (CE)' };        
    
        //String sOrg = 'Climate and Energy';
		//String strClosedWon = 'Closed-Won';
        
        String SOQL_SELECT = 'SELECT CloseDate, SUM(ExpectedRevenue) amt FROM Opportunity ';
        //String SOQL_WHERE = sql_where + ' AND OwnerId IN :usrIds AND account.business_org__c = :sOrg ';
        //String SOQL_WHERE = sql_where + ' AND OwnerId IN :usrIds AND account.business_org__c = :sOrg  AND (RecordTypeId IN :oppRecordTypeIds) ';        
        String SOQL_WHERE = sql_where + ' AND OwnerId IN :usrIds AND (RecordTypeId IN :oppRecordTypeIds) '; 
        //SOQL_WHERE = SOQL_WHERE + ' AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR AND QuotaAmount > 0)';
        SOQL_WHERE = SOQL_WHERE + ' AND OwnerId IN (SELECT QuotaOwnerId FROM ForecastingQuota WHERE (IsAmount=true) AND StartDate = THIS_YEAR)';        
		SOQL_WHERE += ' AND (StageName NOT IN : stageDeselect) ';       
        String SOQL_GROUP_BY = ' GROUP BY CloseDate';
        
        System.debug(LoggingLevel.INFO, '@@ getOpportunityExpectedAmount : SOQL ' + SOQL_SELECT + SOQL_WHERE+SOQL_GROUP_BY);  
		//System.debug(LoggingLevel.INFO, '@@ getOpportunityAmount : SelectedCriteria ' + usrIds + ' * ' + sOrg + ' * ' + oppRecordTypeIds);
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
        
        //Decimal dAmount = 0;
        //if(results != null && results.size() == 1) {
        //    dAmount = (Decimal) results[0].get('amt');
        //}

   		System.debug(LoggingLevel.INFO, '@@ getOpportunityAmount : dAmount ' + dAmount);

        
        //return getFormattedCurrency(dAmount);
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
    
    private class ShapeAggregation {
        public string stageName {get; set;}
        public Decimal converted_amount  {get; set;}
        public Decimal amount  {get; set;}
        public Decimal expected_revenue {get; set;}
        public Decimal probability {get; set;}
        public integer count {get; set;}
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