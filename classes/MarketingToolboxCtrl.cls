/***************************************************************************************
Name                : PartnerPortalHomeCtrl
Author              : Matt Salpietro
CreatedDate         : 12 Dec,2014    
Description         : This class is used for Marketing Toolbox Page.
****************************************************************************************/
public with sharing class MarketingToolboxCtrl {
    /*************************************************************************************
    Getter Setter Properties
    **************************************************************************************/
    
    private static String TOP_BANNER = 'Top Banner';
    private static String DEFAULT_REGION = 'default';

    public String COMATROL_ORG {get{
        return 'Comatrol';
    }set;}
    
    public User loginUser {get;set;}
    public PortalBanner__c portalBanner {get; set;}
    public Portal_Business_Org_Style__c styleSheetRecord{get; set;}
    public String baseURL {get;set;}
    public String pageURL {get;set;}


    public MarketingToolboxCtrl() { 
        baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        pageURL = ApexPages.currentPage().getUrl();

        for(User user:[Select Id, Contact.Account.Region__c, ContactId, Contact.AccountId, Business_Org__c From User where Id =:userInfo.getUserId()]) {
            loginUser = user; 
        }
        
        Map<String,Schema.RecordTypeInfo>  recordType = Schema.SObjectType.PortalBanner__c.getRecordTypeInfosByName();
           
        //fetch portal banner image based on login user (account) region. 
        for(PortalBanner__c portalBannerObj:[Select Alt__c,Link__c,RecordTypeId,Region__c,Summary__c,Id,Position__c,Business_Org__c,
                                           (Select Id, LastModifiedDate From Attachments order by LastModifiedDate desc limit 1) From PortalBanner__c where 
                                           Region__c =:loginUser.Contact.Account.Region__c and Business_Org__c =:loginUser.Business_Org__c
                                           and Page__c = 'MarketingToolbox']) { 
            if (portalBannerObj.RecordTypeId == recordType.get('Top Banner').getRecordTypeId()) {
                portalBanner = portalBannerObj;
            }
        }
        // If there is no region image then fetch default images
        for(PortalBanner__c portalBannerObj:[Select Alt__c,Link__c,RecordTypeId,Region__c,Summary__c,Id,Position__c,Business_Org__c,
                                           (Select Id, LastModifiedDate From Attachments order by LastModifiedDate desc limit 1) From PortalBanner__c where 
                                           Region__c = :DEFAULT_REGION and Business_Org__c=:loginUser.Business_Org__c
                                           and Page__c = 'MarketingToolbox']){
            if (portalBanner == null && portalBannerObj.RecordTypeId == recordType.get('Top Banner').getRecordTypeId() ){
                portalBanner = portalBannerObj;
            }                                               
        }      
        //Get style sheet resource on basis of current user's business org
        styleSheetRecord = Utility.getStyleSheetResource();
    }
}