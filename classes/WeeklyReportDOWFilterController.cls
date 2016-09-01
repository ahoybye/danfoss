public class WeeklyReportDOWFilterController
{
    public string accountRegion{get;Set;}
    public string businessArea{get;Set;}
    public string businessOrg{get;Set;}
    public Task taskForBusinessArea{get;set;}
	User u = [Select Business_Org__c from User WHERE Id = :UserInfo.getUserId() limit 1];
    public List<SelectOption> getRegionList()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Any--'));
        Set<string> setuniqueRegion = new Set<string>();
        Set<string> setuniqueRegionLOWER = new Set<string>();
        for(region__c reg:[Select region__c from region__c where region__c!=null AND region__c!='' LIMIT 1000])
        {
            if(!setuniqueRegionLOWER.contains(reg.region__c.toLowercase()))
            {
                setuniqueRegionLOWER.add(reg.region__c.toLowercase());
                setuniqueRegion.add(reg.region__c);
            }
        }
        for(string str:setuniqueRegion)
            options.add(new SelectOption(str,str));
        return options;
    }
    public List<SelectOption> getBusinessAreaList()
    {
        Schema.DescribeFieldResult F = Task.Business_Area__c.getDescribe();
        List <Schema.PicklistEntry> pickVals = F.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Any--'));
        for(Schema.PicklistEntry pVal:pickVals)
        {
            options.add(new SelectOption(pVal.getValue(),pVal.getLabel()));
        }
        return options ;
    }
    public List<SelectOption> getBusinessOrgList()
    {
        Schema.DescribeFieldResult F = Account.Business_Org__c.getDescribe();
        List <Schema.PicklistEntry> pickVals = F.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();        
		Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
		if(UserInfo.getProfileId() == profile.Id){
	        options.add(new SelectOption('','--None--'));
	        for(Schema.PicklistEntry pVal:pickVals)
	        {
	            options.add(new SelectOption(pVal.getValue(),pVal.getLabel()));
	        }
		}
		else{
			options.add(new SelectOption('', u.Business_Org__c));
		}
        return options ;
    }
    public WeeklyReportDOWFilterController()
    {
        accountRegion='';
        businessArea='';
        businessOrg = '';
        taskForBusinessArea = new Task();
    }
    public pagereference runReport()
    {
        if(businessOrg==null || businessOrg=='')
        {			
			businessOrg = u.Business_Org__c;
		}
		if(businessOrg==null || businessOrg=='')
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,'Please select Business Org.');    
            ApexPages.addMessage(msg);
            return null;
        }
        businessArea = taskForBusinessArea.Business_Area__c;
        if(accountRegion==null)
            accountRegion='';
        if(businessArea==null)
            businessArea='';
        if(businessOrg==null)
            businessOrg='';
        //return new pagereference('/apex/WeeklyReportDOW?ar='+EncodingUtil.urlEncode(accountRegion,'UTF-8')+'&ba='+EncodingUtil.urlEncode(businessArea,'UTF-8'));
        return new pagereference('/apex/WeeklyReportDOW?ar='+EncodingUtil.urlEncode(accountRegion,'UTF-8')+'&bo='+EncodingUtil.urlEncode(businessOrg,'UTF-8')+'&ba='+EncodingUtil.urlEncode(businessArea,'UTF-8'));
    }
}