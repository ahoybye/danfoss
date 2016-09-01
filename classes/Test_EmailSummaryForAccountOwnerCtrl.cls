/*************************************************************************************************************
* @author Ankit (Appirio Ind.)
* @description Test class for EmailSummaryForAccountOwnerCtrl.
*************************************************************************************************************/
@isTest
public with sharing class Test_EmailSummaryForAccountOwnerCtrl {
  
  /***********************************************************************************************************
    * Method for runPositiveTestCases
    ***********************************************************************************************************/
  static testMethod void  runPositiveTestCases(){
    Account acc = Test_Utility.createAccount(false);
    acc.Channel__c = 'Direct';
    acc.Business_Org__c = 'Integrated';
    insert acc;
    
    List<Contact> lstContact = new List<Contact> ();
    Boolean isSensitive = false;
    for (Integer i = 1; i <= 200; i++) {
      if(isSensitive) {
        lstContact.add(new Contact(FirstName = 'Contact ' + i, 
                        LastName = acc.Name, 
                        Email = 'danfossapexemail@gmail.com', 
                        AccountId = acc.Id, 
                        PIB_BU__c = 'Steering',
                        Product_Information_Bulletin__c = true));
        isSensitive = false;
          
      } else {
        lstContact.add(new Contact(FirstName = 'Contact ' + i, 
                        LastName = acc.Name, 
                        Email = 'danfossapexemail@gmail.com', 
                        AccountId = acc.Id, 
                        PIB_BU__c = 'Steering',
                        Service_Bulletin__c = true));
        isSensitive = true;
      }
    }
    insert lstContact;
        
    EmailSummaryForAccountOwnerCtrl ctrl = new EmailSummaryForAccountOwnerCtrl();
    ctrl.accId = acc.Id;
    ctrl.area = 'Steering';
    ctrl.notifiType = 'PIB Non-Sensitive';
    System.assertEquals(100, ctrl.lstContact.size());
    
    EmailSummaryForAccountOwnerCtrl ctrl2 = new EmailSummaryForAccountOwnerCtrl();
    ctrl2.accId = acc.Id;
    ctrl2.area = 'Steering';
    ctrl2.notifiType = 'Service Bulletin';
    System.assertEquals(100, ctrl2.lstContact.size());
    //Getter property will return old list
    System.assertEquals(100, ctrl2.lstContact.size());
  }
  
  /***********************************************************************************************************
  * Method for runNegativeTestCases
  ***********************************************************************************************************/
  static testMethod void runNegativeTestCases() {
    Account acc = Test_Utility.createAccount(false);
    acc.Channel__c = 'Direct';
    acc.Business_Org__c = 'Integrated';
    insert acc;
    EmailSummaryForAccountOwnerCtrl ctrl = new EmailSummaryForAccountOwnerCtrl();
    ctrl.accId = acc.Id;
    ctrl.area = 'Steering';
    ctrl.notifiType = 'PIB Non-Sensitive';
    System.assertEquals(0, ctrl.lstContact.size());
  }
}