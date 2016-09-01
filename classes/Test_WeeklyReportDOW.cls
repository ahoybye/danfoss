/**********************************************************************************
Created By    :    Sumit Mishra
Date          :    10/22/2011
Reason        :    Test method for WeeklyReportDOWController 
 
Updates       : 11/4/2011 [Svatka Simpson]  - added country code to generation of regions as it is now required in UAT
                11/4/2011 [Svatka Simpson]  - added description field to task creation (validation in UAT)  
**********************************************************************************/
@isTest
private class Test_WeeklyReportDOW    
{
    static testMethod void unitTest1() 
    {
        WeeklyReportDOWController.isRunningTestMethod = true;
        region__c r1=new region__c(Name='REG1',Region__c='REG1', Country_Code__c = 'ZZ');
        insert r1;
        region__c r2=new region__c(Name='REG2',Region__c='REG2', Country_Code__c = 'YY');
        insert r2;
        Account Pact1 = Test_Utility.createAccount(1);       
        Pact1.Country__c = r1.Id;
        Pact1.Channel__c = 'Direct';
        Pact1.Business_Org__c='Comatrol';
        Pact1.ShippingCity='Jaipur';
        Pact1.ShippingState='Raj';
        Pact1.ShippingCountry='India';
        insert Pact1;
        Account Cact1 = Test_Utility.createAccount(2);       
        Cact1.Country__c = r1.Id;
        Cact1.Channel__c = 'Direct';
        Cact1.Business_Org__c='Comatrol';
        Cact1.ShippingCity='Jaipur';
        Cact1.ShippingState='Raj';
        Cact1.ShippingCountry='India';
        Cact1.ParentID=pact1.Id;
        insert Cact1;
        List<Task>lstT = new List<Task>();
        Task t1 = new task(WhatId=pact1.id,Subject='test1',Include_In_Dow__c = true,allMID_relevant_information__c='No',Activitydate=Date.Today()+1,Business_Area__c='Comatrol;High Power', Description='Task 1 comments');
        lstT.add(t1);
        t1 = new task(WhatId=pact1.id,Subject='test2',Include_In_Dow__c = true,allMID_relevant_information__c='Yes',Activitydate=Date.Today()+2,Business_Area__c='Comatrol;High Power', Description='Task 2 comments');
        lstT.add(t1);
        t1 = new task(WhatId=cact1.id,Subject='test2',Include_In_Dow__c = true,allMID_relevant_information__c='No',Activitydate=Date.Today()+3,Business_Area__c='Comatrol;High Power', Description='Task 3 comments');
        lstT.add(t1);
        t1 = new task(WhatId=cact1.id,Subject='test2',Include_In_Dow__c = true,allMID_relevant_information__c='No',Activitydate=Date.Today()+4,Business_Area__c='Comatrol;High Power', Description='Task 4 comments');
        lstT.add(t1);
        insert lstT;
        List<Event>lstE = new List<Event>();
        Event e1 = new Event(StartDateTime=DateTime.Now(),EndDateTime=DateTime.Now().addMinutes(10),WhatId=cact1.id,Subject='test2',Include_In_Dow__c = true,allMID_relevant_information__c='No',Activitydate=Date.Today()+3,Business_Area__c='Comatrol;High Power', Description='Event 1 comments');
        lstE.add(e1);
        e1 = new Event(StartDateTime=DateTime.Now(),EndDateTime=DateTime.Now().addMinutes(10),WhatId=cact1.id,Subject='test2',Include_In_Dow__c = true,allMID_relevant_information__c='No',Activitydate=Date.Today()+4,Business_Area__c='Comatrol;High Power', Description='Event 2 comments');
        lstE.add(e1);
        insert lstE;
        WeeklyReportDOWFilterController wF = new WeeklyReportDOWFilterController();
        wf.runReport();
        ApexPages.currentPage().getParameters().put('ar','');
        ApexPages.currentPage().getParameters().put('bo','Comatrol');
        wf.getRegionList();
        wf.getBusinessAreaList();
        wf.getBusinessOrgList();
        wf.businessOrg = 'Comatrol';
        wf.accountRegion = '';
        wf.businessArea = 'Motors';
        wf.runReport();
        WeeklyReportDOWController wC = new WeeklyReportDOWController();        
        wC.executeReport();
        wC.accountRegion = 'Americas';
        wC.businessArea = 'Motors';
        wC.businessOwner = 'Comatrol';
        wC.getListOfReion()[0].getListOfChannels();
        wC.getstartDateSTR();
        wC.executeReport();
        //system.AssertEquals(wC.getListOfChannels().size(),1);
        //system.AssertEquals(wC.getListOfReion()[0].getListOfBusinessArea().size(),2);
        
    }
}