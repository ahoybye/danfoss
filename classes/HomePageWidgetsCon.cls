/*
**************************************************************************************
Name                : HomePageWidgetsCon
Author              : Harshit Jain (Appirio offshore)
createdDate                 : 14 august,2012
Description         : This class is used for HomePageWidgets component.
Modified            : Erin Fink ~ 13 Nov 12 - changed return limit for contentVersion from 3 to 5
***************************************************************************************    
*/
public with sharing class HomePageWidgetsCon {
    /*************************************************************************************
    Getter Setter Properties
    **************************************************************************************/
    public String ContentType{get; set;}     
    
   /************************************************************************************
     get content list available in login user shared library.
    **************************************************************************************/
    public List<ContentVersion> getWidgetsList() {
        List<ContentVersion>    widgetsList = new List<ContentVersion>();
        for(ContentVersion contentVersion : [Select c.Title, c.CreatedDate, c.Content_Type__c, c.ContentDocumentId From ContentVersion c where Content_Type__c =:ContentType and IsLatest=true order by CreatedDate DESC limit 5]) {
            widgetsList.add(contentVersion);
        }
        return  widgetsList;
    }
    
    public List<ContentVersion> getPricingWidgetsList() {
    	List<String> lstContentType = new List<String>();
    	lstContentType.add('Pricebook');
    	lstContentType.add('Price File');
    	lstContentType.add('Pricing tool');
    	
        List<ContentVersion> widgetsList = new List<ContentVersion>();
        for(ContentVersion contentVersion : [Select c.Title, c.CreatedDate, c.Content_Type__c, c.ContentDocumentId From ContentVersion c where Content_Type__c IN :lstContentType and IsLatest=true order by CreatedDate DESC limit 5]) {
            widgetsList.add(contentVersion);
        }
        return  widgetsList;
    }
    
    public List<ContentVersion> getTechnicalLiteratureWidgetsList() {
    	List<String> lstContentType = new List<String>();
    	lstContentType.add('Technical Literature');
    	lstContentType.add('Service Bulletin');
    	
        List<ContentVersion> widgetsList = new List<ContentVersion>();
        for(ContentVersion contentVersion : [Select c.Title, c.CreatedDate, c.Content_Type__c, c.ContentDocumentId From ContentVersion c where Content_Type__c IN :lstContentType and IsLatest=true order by CreatedDate DESC limit 5]) {
            widgetsList.add(contentVersion);
        }
        return  widgetsList;
    }
    
    public String getContentFilterString(){
        String contentTypeFieldID = ContentType_Field_ID__c.getOrgDefaults().Content_Type_ID__c;
        contentTypeFieldID = '"'+contentTypeFieldID+'":["';
        if (ContentType.equals('Technical Literature')) {
            contentTypeFieldID = contentTypeFieldID+'9';
        }else if (ContentType.equals('Service Bulletin')) {
            contentTypeFieldID = contentTypeFieldID+'8';
        } else  if (ContentType.equals('Announcement')) {
            contentTypeFieldID = contentTypeFieldID+'1';
        } else if (ContentType.equals('Product Information Bulletin')) {
            contentTypeFieldID = contentTypeFieldID+'7';
        } else if (ContentType.equals('Pricing')) {
            contentTypeFieldID = contentTypeFieldID+'6","5","4';
        }
        contentTypeFieldID = '{'+contentTypeFieldID+'"]}';
        return contentTypeFieldID;      
    }
}