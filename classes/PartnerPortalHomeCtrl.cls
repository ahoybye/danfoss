/***************************************************************************************
Name                : PartnerPortalHomeCtrl
Author              : Ankit Goyal (Appirio offshore)
createdDate         : 2 Dec,2013    
Description         : This class is used for Partner Portal Home Page.
****************************************************************************************/
public with sharing class PartnerPortalHomeCtrl {
    /*************************************************************************************
    Getter Setter Properties
    **************************************************************************************/
    
    private static String TOP_BANNER = 'Top Banner';
    private static String MARCOMM = 'MarComm';
    private static String LEFT = 'Left';
    private static String MIDDLE = 'Middle';
    private static String RIGHT = 'Right';
    private static String DEFAULT_REGION = 'default';
    //This is using on PartnerPortalHome page
    public String COMATROL_ORG {get{
        return 'Comatrol';
    }set;}
    
    //public List<Idea> ideaList {get;set;}
    public User loginUser {get;set;}
    public PortalBanner__c portalBanner {get; set;}
    public PortalBanner__c marCommLeft{get;set;}
    public PortalBanner__c marCommMiddle{get;set;}
    public PortalBanner__c marCommRight{get;set;}
    public Portal_Business_Org_Style__c styleSheetRecord{get; set;}
    
    public PartnerPortalHomeCtrl() { 
        for(User user:[Select Id, Contact.Account.Region__c, ContactId, Contact.AccountId, Business_Org__c From User where Id =:userInfo.getUserId()]) {
            loginUser = user; 
        }
        
        Map<String,Schema.RecordTypeInfo>  recordType = Schema.SObjectType.PortalBanner__c.getRecordTypeInfosByName();
           
        //fetch portal banner image based on login user (account) region. 
        for(PortalBanner__c portalBannerObj:[Select Alt__c,Link__c,RecordTypeId,Region__c,Summary__c,Id,Position__c,Business_Org__c,
                                           (Select Id, LastModifiedDate From Attachments order by LastModifiedDate desc limit 1) From PortalBanner__c where 
                                           Region__c =:loginUser.Contact.Account.Region__c and Business_Org__c =:loginUser.Business_Org__c]) { 
            if (portalBannerObj.RecordTypeId == recordType.get('Top Banner').getRecordTypeId()) {
                portalBanner = portalBannerObj;
            } else if(portalBannerObj.RecordTypeId == recordType.get('Spots').getRecordTypeId()) { // MarComm Widgets
                if (portalBannerObj.Position__c == LEFT) {
                    marCommLeft = portalBannerObj;
                } else if (portalBannerObj.Position__c == MIDDLE) {
                    marCommMiddle = portalBannerObj;
                } else if (portalBannerObj.Position__c == RIGHT) {
                    marCommRight = portalBannerObj;
                }
            }
        }
        // If there is no region image then fetch default images for Spots
        for(PortalBanner__c portalBannerObj:[Select Alt__c,Link__c,RecordTypeId,Region__c,Summary__c,Id,Position__c,Business_Org__c,
                                           (Select Id, LastModifiedDate From Attachments order by LastModifiedDate desc limit 1) From PortalBanner__c where 
                                           Region__c = :DEFAULT_REGION and Business_Org__c=:loginUser.Business_Org__c]){
            if (portalBanner == null && portalBannerObj.RecordTypeId == recordType.get('Top Banner').getRecordTypeId() ){
                portalBanner = portalBannerObj;
            } else if( portalBannerObj.RecordTypeId == recordType.get('Spots').getRecordTypeId()) { // MarComm Widgets
                if(portalBannerObj.Position__c == LEFT && marCommLeft == null) {
                    marCommLeft = portalBannerObj;
                } else if (portalBannerObj.Position__c == MIDDLE && marCommMiddle == null) {
                    marCommMiddle = portalBannerObj;
                } else if (portalBannerObj.Position__c == RIGHT && marCommRight == null) {
                    marCommRight = portalBannerObj;
                }
            }                                                   
        }      
        //Get style sheet resource on basis of current user's business org
        styleSheetRecord = Utility.getStyleSheetResource();
    }
}