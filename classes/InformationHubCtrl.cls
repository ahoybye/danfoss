public with sharing class InformationHubCtrl {
  public Portal_Business_Org_Style__c styleSheetRecord{get; set;}

  public InformationHubCtrl() {
    styleSheetRecord = Utility.getStyleSheetResource();
  }

}