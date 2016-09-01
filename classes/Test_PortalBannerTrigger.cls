/*************************************************************************************************************
* @author Ankit (Appirio Ind.)
* @date 12/3/2013
* @description Test class for PortalBannerTrigger.
*************************************************************************************************************/
@isTest
private class Test_PortalBannerTrigger {
  private static Id panelRecordTypeId = Schema.SObjectType.PortalBanner__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
  
  /***********************************************************************************************************
  /* Test method for testBulkBeforeInsertAndBeforeUpdate
  ***********************************************************************************************************/
  public static testMethod void testBulkBeforeInsertAndBeforeUpdate() {
    List<PortalBanner__c> lstPortalbanner = createTestData();
    //Test for insert success and failure
    Test.startTest();
    List<Database.Saveresult> lstResult = Database.insert(lstPortalbanner, false);
    Integer successResultCount = 0;
    for(Database.Saveresult result : lstResult) {
      if(result.isSuccess()) {
        successResultCount++;
      }
    }
    Test.stopTest();
    System.assertEquals(52, successResultCount);
    
    //Test for update for failure
    List<PortalBanner__c> lstPortalBannerForUpdate = [Select Id From PortalBanner__c Where 
                                                        Business_Org__c = 'Test Org' 
                                                        And Position__c = '' 
                                                        And Region__c = 'Americas']; 
    for(PortalBanner__c pb : lstPortalBannerForUpdate) {
        pb.Position__c = 'Top Left';
    }
    successResultCount = 0;
    lstResult.clear();
    lstResult = Database.update(lstPortalBannerForUpdate, false);
    for(Database.Saveresult result : lstResult) {
      if(result.isSuccess()) {
        successResultCount++;
      }
    }
    System.assertEquals(0, successResultCount);
    
    //Test for update for success
    for(PortalBanner__c pb : lstPortalBannerForUpdate) {
      pb.Position__c = 'Top Right';
      pb.Component_Type__c = 'Test Component2';
    }
    successResultCount = 0;
    lstResult.clear();
    lstResult = Database.update(lstPortalBannerForUpdate, false);
    for(Database.Saveresult result : lstResult) {
      if(result.isSuccess()) {
        successResultCount++;
      }
    }
    System.assertEquals(1, successResultCount);
      
  }
  
  /***********************************************************************************************************
  /* Test method for testValidationAndConstraints
  ***********************************************************************************************************/
  public static testMethod void testValidationAndConstraints() {
    //Test for validation (Must Select one or more values for 'Content Type to Query' if 'Object' = Content)
    //Test for failure for validation rule
    Boolean isInsert = true;
    PortalBanner__c objPortalBanner;
    try{
      objPortalBanner = new PortalBanner__c(Component_Type__c = 'Test Component', Name = 'Test Banner', Object__c = 'Content', Position__c = 'Top Left', Region__c = 'Americas', RecordTypeId = panelRecordTypeId);
      insert objPortalBanner;
    } catch(Exception e) {
      isInsert = false;
    }
    System.assertEquals(false, isInsert);
    
    //Test for success for validation rule
    objPortalBanner.Content_Type_to_Query__c = 'Test Content1;Test Content2';
    insert objPortalBanner;
    isInsert = true;
    System.assertEquals(true, isInsert);
    
    delete [Select Id From PortalBanner__c];
    //Test for Constraints
    
    //#1. if there exist record with Position = ‘Top Right’, Business Org = ‘Integrated’, Region = Default, Component Type = ‘Announcement’, Record Type = ‘Panel’ 
    // and a user attempted to create a record with 
    //Position = ‘Top Left’, Business Org = ‘Integrated’, Region = ‘Default’, Component Type = ‘Announcement’, Record Type = ‘Panel’ , 
    objPortalBanner = new PortalBanner__c(Position__c = 'Top Right', Business_Org__c = 'Integrated', Region__c = 'Default', Component_Type__c = 'Announcement', RecordTypeId = panelRecordTypeId);
    insert objPortalBanner;
    objPortalBanner = new PortalBanner__c(Position__c = 'Top Left', Business_Org__c = 'Integrated', Region__c = 'Default', Component_Type__c = 'Announcement', RecordTypeId = panelRecordTypeId);
    isInsert = insertPortalBanner(objPortalBanner);
    //This is an error condition because the component is the same for the given business org, region, record type and the positions are not none
    System.assertEquals(false, isInsert);
    
    //#2. if there exist record with Position = ‘Top Right’, Business Org = ‘Integrated’, Region = Default, Component Type = ‘Announcement’, Record Type = ‘Panel’ 
    //and a user attempted to create a record with 
    //Position = None, Business Org = ‘Integrated’, Region = ‘Default’, Component Type = ‘Announcement’, Record Type = ‘Panel’ , 
    objPortalBanner = new PortalBanner__c(Position__c = '', Business_Org__c = 'Integrated', Region__c = 'Default', Component_Type__c = 'Announcement', RecordTypeId = panelRecordTypeId);
    isInsert = insertPortalBanner(objPortalBanner);
    //This is NOT an error condition because the position = none.  Positions with no values selected are never displayed on the page.
    System.assertEquals(true, isInsert);
    
    //#2.1 For update
    objPortalBanner.Position__c = 'Top Left';
    Boolean isUpdate = true;
    try{
      update objPortalBanner;
      isUpdate = true;
    } catch(Exception e) {
      isUpdate = false;
    }
    //This is an error condition because the component is the same for the given business org, region, record type and the positions are not none
    System.assertEquals(false, isUpdate);
    
    
    //#3. if there exist record with Position = ‘Top Right’, Business Org = ‘Integrated’, Region = Default, Component Type = ‘Announcement’, Record Type = ‘Panel’ 
    //and a user attempted to create a record with 
    //Position = ‘Top Right’, Business Org = ‘Integrated’, Region = ‘Default’, Component Type = ‘Technical Literature’, Record Type = ‘Panel’  
    objPortalBanner = new PortalBanner__c(Position__c = 'Top Right', Business_Org__c = 'Integrated', Region__c = 'Default', Component_Type__c = 'Technical Literature', RecordTypeId = panelRecordTypeId);
    isInsert = insertPortalBanner(objPortalBanner);
    //This is an error condition because the positions are not none and they are same for the given business org, region, and record type
    System.assertEquals(false, isInsert);
    
    //#4. if there exist record with Position = ‘Top Right’, Business Org = ‘Integrated’, Region = Default, Component Type = ‘Announcement’, Record Type = ‘Panel’ 
    //and a user attempted to create a record with 
    //Position = ‘Top Right’, Business Org = ‘Comatrol’, Region = ‘Default’, Component Type = ‘Announcement’, Record Type = ‘Panel’  
    objPortalBanner = new PortalBanner__c(Position__c = 'Top Right', Business_Org__c = 'Comatrol', Region__c = 'Default', Component_Type__c = 'Announcement', RecordTypeId = panelRecordTypeId);
    isInsert = insertPortalBanner(objPortalBanner);
    //This is NOT an error condition because the Business Orgs are different.  
    System.assertEquals(true, isInsert);
    
    //#5. if there exist record with Position = ‘Top Right’, Business Org = ‘Integrated’, Region = ‘Americas’, Component Type = ‘Announcement’, Record Type = ‘Panel’ 
    //and a user attempted to create a record with 
    //Position = None, Business Org = ‘Integrated’, Region = ‘Americas’, Component Type = ‘Announcement’, Record Type = ‘Panel’ , 
    objPortalBanner = new PortalBanner__c(Position__c = 'Top Right', Business_Org__c = 'Integrated', Region__c = 'Americas', Component_Type__c = 'Announcement', RecordTypeId = panelRecordTypeId);
    insert objPortalBanner;
    objPortalBanner = new PortalBanner__c(Position__c = '', Business_Org__c = 'Integrated', Region__c = 'Americas', Component_Type__c = 'Announcement', RecordTypeId = panelRecordTypeId);
    isInsert = insertPortalBanner(objPortalBanner);
    //This is NOT an error condition because the position = none.  Positions with no values selected are never displayed on the page.
    System.assertEquals(true, isInsert);
    
    //#6. if there exist record with Position = ‘Top Right’, Business Org = ‘Integrated’, Region = ‘Americas’, Component Type = ‘Announcement’, Record Type = ‘Panel’ 
    //and a user attempted to create a record with 
    //Position = ‘Top Right’, Business Org = ‘Integrated’, Region = ‘Americas’, Component Type = ‘Technical Literature’, Record Type = ‘Panel’  
    objPortalBanner = new PortalBanner__c(Position__c = 'Top Right', Business_Org__c = 'Integrated', Region__c = 'Americas', Component_Type__c = 'Technical Literature', RecordTypeId = panelRecordTypeId);
    isInsert = insertPortalBanner(objPortalBanner);
    //This is an error condition because the positions are not none, positions are both the same for the given business org, region, and record type
    System.assertEquals(false, isInsert);
    
    //#7. if there exist record with Position = ‘Top Right’, Business Org = ‘Integrated’, Region = ‘Americas’, Component Type = ‘Announcement’, Record Type = ‘Panel’ 
    //and a user attempted to create a record with 
    //Position = ‘Top Right’, Business Org = ‘Comatrol’, Region = ‘Americas’, Component Type = ‘Announcement’, Record Type = ‘Panel’  
    objPortalBanner = new PortalBanner__c(Position__c = 'Top Right', Business_Org__c = 'Comatrol', Region__c = 'Americas', Component_Type__c = 'Announcement', RecordTypeId = panelRecordTypeId);
    isInsert = insertPortalBanner(objPortalBanner);
    //This is NOT an error condition because the Business Orgs are different.
    System.assertEquals(true, isInsert);
    
    //#8. if there exist record with Position = ‘Top Right’, Business Org = ‘Integrated’, Region = ‘Americas’, Component Type = ‘Announcement’, Record Type = ‘Panel’ 
    //and a user attempted to create a record with 
    //Position = ‘Top Right’, Business Org = ‘Integrated’, Region = ‘Europe’, Component Type = ‘Announcement’, Record Type = ‘Panel’  
    objPortalBanner = new PortalBanner__c(Position__c = 'Top Right', Business_Org__c = 'Integrated', Region__c = 'Europe', Component_Type__c = 'Announcement', RecordTypeId = panelRecordTypeId);
    isInsert = insertPortalBanner(objPortalBanner);
    //This is NOT an error condition because the Regions are different.
    System.assertEquals(true, isInsert);
    
    //#9. if there exist record with Position = ‘Top Right’, Business Org = ‘Integrated’, Region = ‘Americas’, Component Type = ‘Announcement’, Record Type = ‘Panel’ 
    //and a user attempted to create a record with 
    //Position = ‘Top Left’, Business Org = ‘Integrated’, Region = ‘Americas’, Component Type = ‘Announcement’, Record Type = ‘Panel’ , 
    objPortalBanner = new PortalBanner__c(Position__c = 'Top Left', Business_Org__c = 'Integrated', Region__c = 'Americas', Component_Type__c = 'Announcement', RecordTypeId = panelRecordTypeId);
    isInsert = insertPortalBanner(objPortalBanner);
    //This is an error condition because the component is the same for the given business org, region, record type and the positions are not none
    System.assertEquals(false, isInsert);
    
    //#10. if there exist record with Position = ‘Top Right’, Business Org = ‘Integrated’, Region = ‘Americas’, Component Type = ‘Announcement’, Record Type = ‘Panel’ 
    //and a user attempted to create a record with 
    //Position = None, Business Org = ‘Integrated’, Region = ‘Americas’, Component Type = ‘Announcement’, Record Type = ‘Panel’ , 
    objPortalBanner = new PortalBanner__c(Position__c = '', Business_Org__c = 'Integrated', Region__c = 'Americas', Component_Type__c = 'Announcement', RecordTypeId = panelRecordTypeId);
    isInsert = insertPortalBanner(objPortalBanner);
    //This is NOT an error condition because the position = none.  Positions with no values selected are never displayed on the page.
    System.assertEquals(true, isInsert);
    
  }
  
  /***********************************************************************************************************
  /* Returns true or false based on insert success
  * @param objPortalBanner PortalBanner__c
  * @return Boolean
  ***********************************************************************************************************/
  private static Boolean insertPortalBanner(PortalBanner__c objPortalBanner){
  	Boolean isInsert;
  	try{
    	insert objPortalBanner;
    	isInsert = true;
    } catch(Exception e) {
    	isInsert = false;
    }
    return isInsert;
  }
  
  /***********************************************************************************************************
  /* Methos For Create Test Data
  * @return List<PortalBanner__c>
  ***********************************************************************************************************/
  private static List<PortalBanner__c> createTestData(){
    List<PortalBanner__c> lstPortalbanner = new List<PortalBanner__c>();
    
    // It will insert only one record and rest of 99 will get failure
    for(Integer i = 0 ; i < 100 ; i++){
      PortalBanner__c objPortalBanner = new PortalBanner__c();
      objPortalBanner.Business_Org__c = 'Test Org';
      objPortalBanner.Component_Type__c = 'Test Component';
      objPortalBanner.Name = 'Test Banner ' + i;
      objPortalBanner.Object__c = 'Idea';
      objPortalBanner.Position__c = 'Top Left';
      objPortalBanner.Region__c = 'Americas';
      objPortalBanner.RecordTypeId = panelRecordTypeId;
      lstPortalbanner.add(objPortalBanner);
    }
    
    // It will insert only one record and rest of 49 will get failure
    for(Integer i = 100 ; i < 150 ; i++){
      PortalBanner__c objPortalBanner = new PortalBanner__c();
      objPortalBanner.Business_Org__c = 'Test Org';
      objPortalBanner.Component_Type__c = 'Test Component';
      objPortalBanner.Name = 'Test Banner ' + i;
      objPortalBanner.Object__c = 'Idea';
      objPortalBanner.Position__c = 'Top Left';
      objPortalBanner.Region__c = 'Default';
      objPortalBanner.RecordTypeId = panelRecordTypeId;
      lstPortalbanner.add(objPortalBanner);
    }
    
    // It will insert all 50 records and no one will get failure
    for(Integer i = 150 ; i < 200 ; i++){
      PortalBanner__c objPortalBanner = new PortalBanner__c();
      objPortalBanner.Business_Org__c = 'Test Org';
      objPortalBanner.Component_Type__c = 'Test Component';
      objPortalBanner.Name = 'Test Banner ' + i;
      objPortalBanner.Object__c = 'Idea';
      objPortalBanner.Position__c = '';
      objPortalBanner.Region__c = 'Americas';
      objPortalBanner.RecordTypeId = panelRecordTypeId;
      lstPortalbanner.add(objPortalBanner);
    }
    return lstPortalbanner;
  }
}