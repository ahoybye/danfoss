/*************************************************************************************************************
* @author Neeraj (Appirio Ind.)
* @date 12/09/2013
* @Task T-213767, I-85267
* @description  When a user creates a Bulletin Delivery Job record and indicates "Defect Correction" the trigger will, 
                for every task created under the specified Bulletin Delivery Job (the lookup field), 
                we need to delete the tasks that were created by that job that have a status of "Not Started" 
                and mark their Bulletin Delivery Log as defect.  We also need to save the value of the former Job ID 
                in a new field called "Old Job Information ID" (please create on the log object).
*************************************************************************************************************/
public without sharing class BulletinDeliveryJobTriggerHandler {
  /***********************************************************************************************************
  * Executes before insertion of Bulletin Delivery Job.
  * @param lstBulletinJob Bulletin Delivery Records that are being inserted or updated
  * @return void.
  ***********************************************************************************************************/
  public static void beforeInsert(List<Bulletin_Delivery_Job__c> lstBulletinJob) {
    processDefectiveJobs(lstBulletinJob, null);
  }
  
  /***********************************************************************************************************
   * Executes before updation of Bulletin Delivery Job.
   * @param lstBulletinJob Bulletin Delivery Records that are being inserted or updated
   * @return void.
  ***********************************************************************************************************/
  public static void beforeUpdate(List<Bulletin_Delivery_Job__c> lstBulletinJob, Map<Id, Bulletin_Delivery_Job__c> oldMap) {
    processDefectiveJobs(lstBulletinJob, oldMap);
  }
  
  /***********************************************************************************************************
   * Deletes InComplete Task for Defective Bulletin Delivery Jobs.
   * @param lstBulletinJob Bulletin Delivery Records that are being inserted or updated
   * @param oldMap Old values of bulletin delivery job in case of updates
   * @return void.
  ***********************************************************************************************************/
  private static void processDefectiveJobs(List<Bulletin_Delivery_Job__c> lstBulletinJob, Map<Id, Bulletin_Delivery_Job__c> oldMap) {
    Map<Id, Id> defectAndNewJobMap = new Map<Id, Id>();
    for (Bulletin_Delivery_Job__c bdj : lstBulletinJob) {
        if (bdj.Defect_Correction__c == true && bdj.Defective_Bulletin_Delivery_Job__c != null )
        //&& (Utility.isNewOrChanged(bdj, 'Defect_Correction__c', oldMap) || Utility.isNewOrChanged(bdj, 'Defective_Bulletin_Delivery_Job__c', oldMap))) 
        {
            defectAndNewJobMap.put(bdj.Defective_Bulletin_Delivery_Job__c, bdj.Id);
        }
    }
    
    //Get Bulletin Accounts with Status as not started for defective Bulletin Job
    List<Bulletin_Accounts__c> lstBulletinAccountToUpdt = new List<Bulletin_Accounts__c>();
    for (Bulletin_Accounts__c ba : [ Select id, Status__c, Bulletin_Delivery_Job__c
                                    From Bulletin_Accounts__c
                                    Where Bulletin_Delivery_Job__c in :defectAndNewJobMap.keySet()
                                    AND Status__c in ('Not Started', 'Complete')]) {
        ba.Status__c = 'Defect';
        lstBulletinAccountToUpdt.add(ba);
      }
      
      List<Bulletin_Delivery_Log__c> lstBDL = new List<Bulletin_Delivery_Log__c>();
      for (Bulletin_Delivery_Log__c bdLog : [ Select id, Old_Job_Information_ID__c, Bulletin_Account__r.Bulletin_Delivery_Job__c
                                              From Bulletin_Delivery_Log__c 
                                              Where Bulletin_Account__c in :lstBulletinAccountToUpdt]) {
        bdLog.Old_Job_Information_ID__c = defectAndNewJobMap.get(bdLog.Bulletin_Account__r.Bulletin_Delivery_Job__c);
        lstBDL.add(bdLog);
      }
      
      if (!lstBDL.isEmpty()) {
        update lstBDL;
      }
      
      Set<Id> taskIdsForDelAttach = new Set<Id>();
      List<Task> lstNewTasks = new List<Task>();
      if (!lstBulletinAccountToUpdt.isEmpty()) {
        list<Task> lstTaksToCancel = new list<Task>();
        for (Task task : [ Select id, OwnerId, WhatId, ActivityDate, Status
                                   From Task 
                                   Where Bulletin_Delivery_Job__c = :defectAndNewJobMap.keySet() 
                                   And Status in ('In Progress', 'Not Started')]) {
          task.Status = 'Cancelled';
          taskIdsForDelAttach.add(task.Id);
          lstTaksToCancel.add(task);
        }
        if (!lstTaksToCancel.isEmpty()) {
          delete [Select Id From Attachment Where ParentId IN :taskIdsForDelAttach];
          update lstTaksToCancel;
        }
        update lstBulletinAccountToUpdt;
      }
  }
  
}