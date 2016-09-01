public with sharing class Utility {
/**
* Returns true if field value is added or changed 
* @param obj Sobject being inserted or updated.
* @param fldName sobject field to check for value changes.
* @param oldMap Trigger oldmap for previous values
* @return true if field has value and its being changed from some other value.
*/ 
public static Boolean isNewOrChanged(Sobject obj, String fldName, Map<Id, Sobject> oldMap) {
  if (obj != null && fldName != null && oldMap != null) {
    return ((obj.get(fldName) != oldMap.get((Id)obj.get('id')).get(fldName) ? true : false));
  } 
  return (obj.get(fldName) != null);
}

/**
* Returns String of Style Sheet Resource
* @return String of Style Sheet Resource
*/
public static Portal_Business_Org_Style__c getStyleSheetResource(){
  User loginUser;
  Portal_Business_Org_Style__c styleSheetResource;
  Portal_Business_Org_Style__c defaultStyleSheetResource;
  for(User user:[Select Id, Business_Org__c From User where Id =:userInfo.getUserId()]) {
    loginUser = user; 
  }
  for(Portal_Business_Org_Style__c orgStyle : [Select Id, Business_Org__c, Stylesheet_Resource__c, Terms_and_Conditions_Visualforce_Page__c From Portal_Business_Org_Style__c Where Business_Org__c IN (:loginUser.Business_Org__c, '', null)]){
    if(orgStyle.Business_Org__c == null || orgStyle.Business_Org__c == ''){
      defaultStyleSheetResource = orgStyle;
      }else{
        styleSheetResource = orgStyle;      	
      }
    }
    return styleSheetResource != null ? styleSheetResource : defaultStyleSheetResource;
  }

  public static Id createPortalCase(Id recTypeId, String description, String type, String origin, String subject, String status
                                                    , Id account, Id contact){
    Database.DMLOptions dmlOpts = new Database.DMLOptions();
    dmlOpts.AssignmentRuleHeader.useDefaultRule = true;
    dmlOpts.EmailHeader.triggerAutoResponseEmail = true;
    dmlOpts.EmailHeader.triggerUserEmail = true;

    Case newCase = new Case(AccountId = account
                                                      , RecordTypeId = recTypeId
                                                      , Description = description
                                                      , Subject = subject
                                                      , Type = type
                                                      , Status = status
                                                      , Origin = origin
                                                      , ContactId = contact);
    newCase.setOptions(dmlOpts);

    try{
      insert newCase;
      return newCase.Id;
    }catch(exception ex){
      return null;
    } 
  }

  public static list<SelectOption> getPicklistValues(SObject obj, String fld){
    list<SelectOption> options = new list<SelectOption>();
    Schema.sObjectType objType = obj.getSObjectType(); 
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
    map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
    list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
    for (Schema.PicklistEntry a : values){ 
      options.add(new SelectOption(a.getLabel(), a.getValue())); 
    }
    return options;
  } 

}