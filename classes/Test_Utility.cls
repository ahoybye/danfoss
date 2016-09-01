/********************************************************************************
**@author : Rishi Khirbat (Appirio Offshore)
**@date : 24/08/2012
**@description : This class has many static helper methods used elsewhere.
********************************************************************************/
public with sharing class Test_Utility {
  
    /**
     * Should be called by all unit tests with SeeAllData=false
     * Initializes static test data, such as custom settings, which are used by triggers, which may be called during creation of test data.
     */
    public static void initTestData() {
        insert new Pricebook2(Name = 'Climate and Energy', IsActive = true);
    }
    
    static Id record_Type_Acc_Customer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
  
    public static Id getCountry(Integer i){
        Region__c country = new Region__c(
                                Name='Test Country Name' + i,
                                Country_Code__c = '0' + i,
                                Region__c = 'Test region' + i);
       insert country;
        return country.Id;
    }

    public static Account createAccount(Integer i){
        Account account = new Account(
                                Name='Test Account Name' + i,
                                Country__c=getCountry(i),
                                Business_Org__c='Integrated',
                                RecordTypeId = record_Type_Acc_Customer);
        account.OwnerId = UserInfo.getUserId();
        return account;
    }

    public static Account createAccountEU(Integer i){
        Region__c EUcountry = new Region__c(Name = 'EU region', Country_Code__c = 'EU', Region__c = 'Europe');
        insert EUcountry;
        Account account = new Account(
                                Name='EU account',
                                Country__c= EUcountry.Id,
                                Business_Org__c='Integrated',
                                RecordTypeId = record_Type_Acc_Customer);
        account.OwnerId = UserInfo.getUserId();
        return account;
    }

    public static Account createAccountAM(Integer i){
        Region__c AMcountry = new Region__c(Name = 'AM region', Country_Code__c = 'US', Region__c = 'Americas');
        insert AMcountry;
        Account account = new Account(
                                Name='AM account',
                                Country__c= AMcountry.Id,
                                Business_Org__c='Integrated',
                                RecordTypeId = record_Type_Acc_Customer);
        account.OwnerId = UserInfo.getUserId();
        return account;
    }

    public static Contact createContact(Id accountId, Integer i){
        Contact contact = new Contact(
                                FirstName='Test',
                                LastName='Account Name '+i,
                                AccountId=accountId,
                                Email='test'+i+'contact@danfosstest.com');
        return contact;
    }

    public static Opportunity createOpportunity(Id accountId, Integer i){
        Sales_Org__c so = new Sales_Org__c(Name = '1500', SAP_Sales_Org__c = '1500', Account__c = accountId);
        insert so;
        Opportunity opportunity = new Opportunity(
                                Name='Test opportunity name'+i,
                                CurrencyISOCode = 'DKK',
                                AccountId = accountId,
                                Sales_Org__c = so.Id,
                                StageName = 'Evaluating Need',
                                Production_Start_Date__c = Date.today().addDays(10),
                                CloseDate = Date.today().addDays(5));
        return opportunity;
    }

    public static OpportunityLineItem createOpportunityLineItem(Id opptyId, Id pbeId, Integer i)
    {
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opptyId, TotalPrice = 1, Quantity = 23,PricebookEntryId=pbeId);
        return oli;
    }
    
    public static Lead createLead(Boolean isInsert,Integer i){
    Lead lead = new Lead(
                  LastName='Test lead name'+i,
                  Business_Org__c = 'Integrated',
                  company = 'Test company');
    if(IsInsert) {
        insert lead;
    }                      
    return lead;
    }
    
    public static PortalBanner__c createPortalBanner(Boolean isInsert,String position){
    PortalBanner__c portalBanner = new PortalBanner__c(
                                                                    Name='Test banner',
                                                                      region__c = 'Test region',
                                                                    Summary__c = 'This is test text for Test region',
                                                                    Position__c = position);
    if(IsInsert) {
       insert portalBanner;
    }                      
    return portalBanner;
    }
    
    public static User createPortalUser(Id contactId, Id profileId){
        Contact con = [select ID,Email,FirstName,LastName,Name from Contact where id =:contactId limit 1];
            
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = true;
        User portalUser = new User();
        portalUser.firstName = con.FirstName;
        portalUser.LastName = con.LastName;
        portalUser.Business_Org__c = 'Integrated';
        
        if((con.Name).length()>8){
            portalUser.Alias = (con.Name).substring(0,8);
        }else{
            portalUser.Alias = con.Name;
        }
        portalUser.Email = con.Email;
        portalUser.UserName= con.Email;
        portalUser.ProfileId = profileId;
        portalUser.CommunityNickname = con.Email;
        portalUser.EmailEncodingKey ='ISO-8859-1';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.TimeZoneSidKey ='America/Indiana/Indianapolis';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.Country = 'USA';
        portalUser.ContactId = con.id;
        portalUser.IsActive = true;
        portalUser.setOptions(dmo);     
        return portalUser;
    }
    
    public static User createPortalUser(Id contactId, Id profileId, Integer i){
        Contact con = [select ID,Email,FirstName,LastName,Name from Contact where id =:contactId limit 1];
            
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = true;
        User portalUser = new User();
        portalUser.firstName = con.FirstName;
        portalUser.LastName = con.LastName + i;
        portalUser.Business_Org__c = 'Integrated';
        
        if((con.Name).length()>8){
            portalUser.Alias = (con.Name).substring(0,8);
        }else{
            portalUser.Alias = con.Name;
        }
        portalUser.Email = con.Email;
        portalUser.UserName= con.Email + i;
        portalUser.ProfileId = profileId;
        portalUser.CommunityNickname = con.Email;
        portalUser.EmailEncodingKey ='ISO-8859-1';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.TimeZoneSidKey ='America/Indiana/Indianapolis';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.Country = 'USA';
        portalUser.ContactId = con.id;
        portalUser.IsActive = true;
        portalUser.setOptions(dmo);     
        return portalUser;
    }
    
    public static User createUser(Id profileId, Id roleId, Integer i){
        User user = new User();
    user.firstName = 'Test';
    user.LastName = 'User' + i; 
    user.Alias = 'tst' + i;
    user.Email = 'test' + i + '.test@metacube.com';  
    user.UserName='t'+ i +'user1@gmail.com';
    user.ProfileId = profileId;
    user.UserRoleId = roleId;
    user.CommunityNickname = user.firstname + '_' + Math.random().format() + user.lastName;
    user.EmailEncodingKey ='ISO-8859-1'; 
    user.LanguageLocaleKey = 'en_US';
    user.TimeZoneSidKey ='America/Indiana/Indianapolis';
    user.LocaleSidKey = 'en_US';  
    user.IsActive = true;
    return user;
    } 
  
    public static Region__c createRegion(){
        Region__c region = new Region__c(Country_Code__c = 'US',Name = 'USA');
        return region;
    }

    public static Terms_and_Condition__c createTermsAndCondition(String country,string businessOrg){
        Terms_and_Condition__c conditions = new Terms_and_Condition__c ();
        conditions.Business_Org__c = businessOrg;
        conditions.Country__c = country;
        conditions.Description__c = 'Terms and conditions to be accepted';
        return conditions;      
  }
  
    public static Product2 createProduct2(){
      double randomNumber = randomNumber();
      Product2 product = new Product2();
      product.Name = 'TestProduct'+ String.valueOf(randomNumber);
      product.SAP_Product_Line_Code__c = 'abcdef';
      product.IsActive = true;
      return product ;
   }
   
    public static Product2 insertProduct2(){
      Product2 product = createProduct2();
      Product_Line__c pLine = new Product_Line__c(PL_Code__c = 'abcdef',Business_Unit_Description__c='asdbc'); 
      insert pLine;
      insert product ;
      return product ;
   }
   
    public static double randomNumber() {
     return Math.random();
   }
   
    public static PricebookEntry createPricebookEntry(Id productId , Id priceBookId , String currencyType){       
      PricebookEntry  pbe = new PricebookEntry();
      pbe.UseStandardPrice = false;
      pbe.Pricebook2Id = priceBookId;
      pbe.Product2Id = productId ;
      pbe.IsActive = true;
      pbe.CurrencyIsoCode = currencyType;
      pbe.UnitPrice = 100.0;
      pbe.UseStandardPrice = false;
      return pbe;
   }
    
    public static Bulletin_Delivery_Job__c createBulletinDeliveryJob(String name, boolean isInsert) {
    Bulletin_Delivery_Job__c bDj = new Bulletin_Delivery_Job__c();
    bDj.Name = name;
    bDj.Due_Date__c = Date.today().addDays(30);
    bDj.Status__c = 'Not Started';
    if(isInsert)
        insert bDj;
    return bDj;
    }
    
    public static Bulletin_Accounts__c createBulletinAccounts(Id bdJobId, Id accId, boolean isInsert) {
        Bulletin_Accounts__c bAcc = new Bulletin_Accounts__c();
        bAcc.Bulletin_Delivery_Job__c = bdJobId;
        bAcc.Account__c = accId;
        //bAcc.Name = name;
        bAcc.Status__c = 'Not Started';
        bAcc.Job_Type__c = 'PIB Sensitive';
        if(isInsert)
          insert bAcc;
        return bAcc;
    }
   
    public static Bulletin_Delivery_Log__c createBullDelLog(String name, Id bAccId, boolean isInsert) {
    Bulletin_Delivery_Log__c bdLog = new Bulletin_Delivery_Log__c();
    bdLog.Bulletin_Account__c = bAccId;
    //bdLog.Name = name;
    if(isInsert)
        insert bdLog;
    return bdLog;
    }
    
    public static Attachment createAttachment(Id parentId, Boolean isInsert) {
    Attachment attach = new Attachment();     
    attach.Name = 'Test Attachment';
    Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
    attach.body = bodyBlob;
    attach.ParentId = parentId;
    if (isInsert) {
        insert attach;
    }
    return attach;
  }
  
    public static Account createAccount(Boolean isInsert){
        Account account = new Account(
                                Name='Test Account Name',
                                //Country__c=getCountry(i),
                                Business_Org__c='Integrated',
                                RecordTypeId = record_Type_Acc_Customer);
        account.OwnerId = UserInfo.getUserId();
        if (isInsert) insert account;
        return account;
    }
    
    public static List<Question__c> createQuestions(Set<String> regions, Integer numQuestionSets){
      List<Question_Set__c> questionSetList = new List<Question_Set__c>();
      List<Question__c> questionList = new List<Question__c>();
      for(Integer i = 1;i<=numQuestionSets;i++) {
        Question_Set__c questionSet = new Question_Set__c(Name='Question Set '+i);
        questionSetList.add(questionSet);
      }
      insert questionSetList;
      for(Question_Set__c qs : questionSetList) {
        for(String region : regions) {
          Question__c question = new Question__c(
                            Question__c = qs.Name + ' - Question',
                            Answer__c = qs.Name + ' - Answer',
                            Region__c = region,
                            QuestionSet__c = qs.Id);
          questionList.add(question);
        }
      }
      insert questionList;
      return questionList;
    }
    
}