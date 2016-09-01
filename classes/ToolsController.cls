/***************************************************************************************
Name                : ToolsController
Author              : Rajeev Arya
CreatedDate         : 21 Dec 2015
Description         : This class is used for Tools Page.
****************************************************************************************/
public with sharing class ToolsController {

    /*************************************************************************************
    Getter Setter Properties
    **************************************************************************************/
    public list<ContentVersion> lstConVer {get;set;}
    public map<Id, Id> mapConVersionToBannerAttachment {get;set;}
    public Map<Id, Id> conAttMap {get;set;}
    public Set<Id> etList;

    //rendered="{!lstConVer.size > 0}"
    public ToolsController() {
        set<String> setConType = new set<String>();
        mapConVersionToBannerAttachment  = new map<Id, Id>();
        conAttMap = new Map<Id, Id>();
        etList = new Set<Id>();
        map<String, Id> mapBannerContentTypeToAttachId = new map<String, Id>();
        lstConVer = new list<ContentVersion>();

        User loginUser = [Select Id, Contact.Account.Region__c, ContactId, Contact.AccountId, Business_Org__c
                    From User
                    where Id =:userInfo.getUserId()];

        Map<String,Schema.RecordTypeInfo>  recordType = Schema.SObjectType.PortalBanner__c.getRecordTypeInfosByName();

        //fetch portal banner based on login user (account) region.
        for(PortalBanner__c portalBannerObj:[SELECT id, Content_Type_to_Query__c,
                                                   (SELECT Id, LastModifiedDate
                                                    FROM Attachments
                                                    ORDER BY LastModifiedDate DESC
                                                    LIMIT 1)
                                             FROM PortalBanner__c
                                             WHERE Region__c = 'default'
                                                 AND Business_Org__c =:loginUser.Business_Org__c
                                                 AND Page__c = 'Tools'
                                                 AND RecordType.DeveloperName = 'Tools']) {
            setConType.add(portalBannerObj.Content_Type_to_Query__c);
        }

        //fetch ContentVersions based on User's Account's region and Banner's Content Type
        for (ContentVersion conVer : [SELECT Id, Title, Expert_Tool__c, Description, LastModifiedDate
                                      FROM ContentVersion
                                      WHERE (Region__c INCLUDES (:loginUser.Contact.Account.Region__c)
                                            OR
                                            Region__c = null)
                                            AND Content_Type__c in: setConType
                                            AND RecordType.Name in: setConType
                                      ORDER BY Title ASC]){
            lstConVer.add(conVer);
            etList.add(conVer.Expert_Tool__c);
        }

        if(etList.size() > 0){
          for (Expert_Tools__c et : [SELECT Id, (SELECT Id FROM Attachments ORDER BY LastModifiedDate DESC LIMIT 1)
                                    FROM Expert_Tools__c
                                    WHERE Id = :etList]){
                   conAttMap.put(et.Id, et.Attachments[0].Id);
          }
        }
    }
}