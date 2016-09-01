public without sharing class WeeklyReportDOWController
{
    public static boolean isRunningTestMethod = false;
    public static List<String> getSortedList(Set<String> mySet)
    {
        List<String> lst = new List<String>();
        for(string str : mySet)
            lst.add(str);
        lst.Sort();
        return lst;
    }
    public class Region
    {
        public Region(string nameOfRegion)
        {
            regionName = nameOfRegion;
            //lstTasks = new List<myTask>();
            mapChannels= new Map<string,MyChannel>();
        }
        public string regionName{get;set;}
        public Map<string,MyChannel> mapChannels;
        public List<MyChannel> getListOfChannels()
        {
            List<MyChannel> lst = new List<MyChannel>();
            for(string str:WeeklyReportDOWController.getSortedList(mapChannels.keyset()))
            {
                MyChannel Chn = mapChannels.get(str);
                lst.add(Chn);
            }
            return lst;
        }
        
        //public List<myTask> lstTasks{get;set;}
    }
    public class MyChannel
    {
        public MyChannel(string nameOfChannel)
        {
            ChannelName = nameOfChannel;
            lstTasks = new List<myTask>();
        }
        public string ChannelName{get;set;}
        public List<myTask> lstTasks{get;set;}
        public List<myTask> gettaskList()
        {
            for(integer i=0;i<lstTasks.size()-1;i++)
                for(integer j=i+1;j<lstTasks.size();j++)
                    if(
                        (lstTasks[i].accountChannel > lstTasks[j].accountChannel) || 
                        (lstTasks[i].accountChannel == lstTasks[j].accountChannel && lstTasks[i].CompanyName > lstTasks[j].CompanyName)||
                        (lstTasks[i].accountChannel == lstTasks[j].accountChannel && lstTasks[i].CompanyName == lstTasks[j].CompanyName && lstTasks[i].ActivityDate > lstTasks[j].ActivityDate)
                        
                      )
                    {
                        
                        MyTask m=lstTasks[i];
                        lstTasks[i] = lstTasks[j];
                        lstTasks[j] =m;
                    }
            return lstTasks;
        }
    }
    public class myTask
    {
        public string businessAreaName{get;set;}
        public string accountChannel{get;set;}
        public string ShippingAddress {get;set;}
        public string startDateSTR{get;set;}
        public string ownername{get;set;}
        public string parentCompany{get;set;}
        public string CompanyName{get;set;}
        public string acctID{get;set;}
        public string Comments{get;set;}
        public Date ActivityDate{get;set;}
        public boolean showParent{get;set;}
        public myTask(Task tsk)
        {
            ActivityDate = tsk.Activitydate;
            businessAreaName = tsk.Business_Area__c;
            accountChannel = tsk.Account.Channel__c;
            CompanyName = tsk.Account.Name;
            acctID = tsk.Account.Id;
            Comments = tsk.Description;
            ShippingAddress ='';
            if(tsk.Account.ShippingCity!='' && tsk.Account.ShippingCity!=null)
                if(ShippingAddress=='')
                    ShippingAddress = tsk.Account.ShippingCity;
                else
                    ShippingAddress = ShippingAddress+', '+tsk.Account.ShippingCity;
            if(tsk.Account.ShippingState!='' && tsk.Account.ShippingState!=null)
                if(ShippingAddress=='')
                    ShippingAddress = tsk.Account.ShippingState;
                else
                    ShippingAddress = ShippingAddress+', '+tsk.Account.ShippingState;
            if(tsk.Account.ShippingCountry!='' && tsk.Account.ShippingCountry!=null)
                if(ShippingAddress=='')
                    ShippingAddress = tsk.Account.ShippingCountry;
                else
                    ShippingAddress = ShippingAddress+', '+tsk.Account.ShippingCountry;
            if(tsk.Activitydate!=null)      
                startDateSTR = Datetime.newinstance(tsk.Activitydate.year(),tsk.Activitydate.month(),tsk.Activitydate.Day(),0,0,0).format('dd-MMM-yyyy');
            ownername = tsk.Owner.Name;
            showParent = false;
            if(tsk.Account.ParentId!=null)
            {
                //parentCompany = tsk.Account.Parent.Name +'('+tsk.Account.Parent.Channel__c+')';
                parentCompany = tsk.Account.Parent.Name; // +' '+tsk.Account.Parent.Channel__c;
                showParent = true;
            }
        }
        public myTask(Event tsk)
        {
            ActivityDate = tsk.Activitydate;
            businessAreaName = tsk.Business_Area__c;
            accountChannel = tsk.Account.Channel__c;
            CompanyName = tsk.Account.Name;
            Comments = tsk.Description;
            ShippingAddress ='';
            if(tsk.Account.ShippingCity!='' && tsk.Account.ShippingCity!=null)
                if(ShippingAddress=='')
                    ShippingAddress = tsk.Account.ShippingCity;
                else
                    ShippingAddress = ShippingAddress+', '+tsk.Account.ShippingCity;
            if(tsk.Account.ShippingState!='' && tsk.Account.ShippingState!=null)
                if(ShippingAddress=='')
                    ShippingAddress = tsk.Account.ShippingState;
                else
                    ShippingAddress = ShippingAddress+', '+tsk.Account.ShippingState;
            if(tsk.Account.ShippingCountry!='' && tsk.Account.ShippingCountry!=null)
                if(ShippingAddress=='')
                    ShippingAddress = tsk.Account.ShippingCountry;
                else
                    ShippingAddress = ShippingAddress+', '+tsk.Account.ShippingCountry;
            if(tsk.Activitydate!=null)      
                startDateSTR = Datetime.newinstance(tsk.Activitydate.year(),tsk.Activitydate.month(),tsk.Activitydate.Day(),0,0,0).format('dd-MMM-yyyy');
            ownername = tsk.Owner.Name;
            showParent = false;
            if(tsk.Account.ParentId!=null)
            {
                //parentCompany = tsk.Account.Parent.Name +'('+tsk.Account.Parent.Channel__c+')';
                parentCompany = tsk.Account.Parent.Name; // +' '+tsk.Account.Parent.Channel__c;
                //parentCompany = tsk.Account.Parent.Channel__c;
                showParent = true;
            }
        }
    }
    
    public Map<string,Region> RegionMap;
    public List<Region> getListOfReion()
    {
        List<Region> lst = new List<Region>();
        for(string str:WeeklyReportDOWController.getSortedList(RegionMap.keyset()))//for(Region BA:RegionMap.values())
        {
            Region BA = RegionMap.get(str);
            lst.add(BA);
        }
        return lst;
    }
    public string accountRegion{get;Set;}
    public string businessArea{get;Set;}
    public string businessOwner{get;Set;}
    public DateTime startDate{get;Set;}
    public string mainHeader{get;Set;}
    public string getstartDateSTR()
    {
        return startDate.format('w/yyyy');
    }
    public WeeklyReportDOWController()
    {
        accountRegion = ApexPages.currentPage().getParameters().get('ar');
        businessArea = ApexPages.currentPage().getParameters().get('ba');
        businessOwner = ApexPages.currentPage().getParameters().get('bo');
        if(accountRegion!=null)
            accountRegion = EncodingUtil.urlDecode(accountRegion,'UTF-8');
        if(businessArea!=null)
            businessArea = EncodingUtil.urlDecode(businessArea ,'UTF-8');
        if(businessOwner!=null)
            businessOwner = EncodingUtil.urlDecode(businessOwner ,'UTF-8');
        executeReport();
    }
    public void executeReport()
    {
        mainHeader = 'Weekly Report (DOW)';
        if(businessOwner == 'Comatrol')
            mainHeader = 'Comatrol Weekly';
        //BusinessAreaMap = new Map<string,businessArea>();
        RegionMap = new Map<string,Region>();
        startDate = DateTime.Now().addDays(-7);
        executeReport(true);
        executeReport(false);
    }
    public void executeReport(boolean isTask)
    {
        string objName = 'Event';
        if(isTask)
            objName = 'Task';
        string SOQL = 'Select Description,id,OwnerId,Owner.Name,Business_Area__c,Activitydate, '+
                      ' Account.Parent.Channel__c, Account.Region__c, Account.Channel__c,  '+
                      ' AccountId,Account.Name,Account.ParentId,Account.Parent.Name,Account.ShippingCity,Account.ShippingState,Account.ShippingCountry, Account.Market_Segment__c'+
                      ' from '+ objName +
                      ' where AccountId!=null AND Include_in_DOW__c=True AND Account.Business_Org__c =: businessOwner';
       
       if(!WeeklyReportDOWController.isRunningTestMethod)
        {
            SOQL = SOQL + ' AND Activitydate = LAST_WEEK ';
        } 
        
        if(businessArea !=null && businessArea !='')
        {
            string businessArea1 ='';
            for(string str:businessArea.split(';'))
                if(businessArea1=='')
                    businessArea1 = '\''+str+'\'';
                else
                    businessArea1 = businessArea1+',\''+str+'\'';
                    
            SOQL = SOQL+' AND Business_Area__c INCLUDES(' + businessArea1 + ') ';
        }
        if(accountRegion!=null && accountRegion !='')
            SOQL = SOQL+' AND Account.Region__c =: accountRegion';
            
        SOQL = SOQL+' ORDER BY Account.Region__c,Account.Channel__c,Account.Name,Activitydate';
        system.debug('-------------------------->'+SOQL);
        for(sobject thisTask:database.Query(SOQL))
        {
            Task tsk;
            Event eve;
            string channel;
            string thisRegion='';
            if(isTask)
            {
                tsk = (Task) thisTask;
                channel= tsk.Account.Channel__c;
                thisRegion = tsk.Account.Region__c;
            }
            else
            {
                eve = (Event) thisTask;
                channel= eve.Account.Channel__c;
                thisRegion = eve.Account.Region__c;
            }
            if(channel==null)
                channel = '';
            if(RegionMap.get(thisRegion.toLowerCase())==null)
                RegionMap.Put(thisRegion.toLowerCase(), New Region(thisRegion));
            Region currentReg = RegionMap.get(thisRegion.toLowerCase());
            if(currentReg.mapChannels.get(channel) == null)
                currentReg.mapChannels.put(channel,new MyChannel(channel));
            MyChannel channelObj = currentReg.mapChannels.get(channel);
            if(isTask)
                channelObj.lstTasks.add(new mytask(tsk));
            else
                channelObj.lstTasks.add(new mytask(eve));
        }
    }
}