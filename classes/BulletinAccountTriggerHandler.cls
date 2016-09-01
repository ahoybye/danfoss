/*************************************************************************************************************
* @author Ankit (Appirio Ind.)
* @date 9 Dec, 2013
* @description Bulletin Account Trigger handler
*************************************************************************************************************/
public without sharing class BulletinAccountTriggerHandler {
	
	/***********************************************************************************************************
	//Method for after update trigger
	***********************************************************************************************************/
	public static void afterUpdate(List<Bulletin_Accounts__c> newList, Map<Id, Bulletin_Accounts__c> oldMap) {
    updateBDJobStatus(newList, oldMap);
	}
	
  /***********************************************************************************************************
	//Method for after insert trigger
	***********************************************************************************************************/
	public static void afterInsert(List<Bulletin_Accounts__c> newList) {
	    updateBDJobStatus(newList, null);
	}
    
  /***********************************************************************************************************
   * Method for update status of Bulletin Delivery Job status
   * @param newList List of Bulletin Accounts
   * @param oldMap Map of old Bulletin Accounts
  ***********************************************************************************************************/
  private static void updateBDJobStatus(List<Bulletin_Accounts__c> newList, Map<Id, Bulletin_Accounts__c> oldMap) {
		List<Bulletin_Accounts__c> lstFinalBulletinAccount = getLstBulletinAccount(newList, oldMap);
		Set<Id> bulletinDeliveryJobIds = new Set<Id>();
		Map<Id, List<Bulletin_Accounts__c>> mapBDJobAndAccounts = new Map<Id, List<Bulletin_Accounts__c>>();
		List<Bulletin_Delivery_Job__c> lstForUpdateBDjob = new List<Bulletin_Delivery_Job__c>();  
		for(Bulletin_Accounts__c ba : lstFinalBulletinAccount) {
			if (ba.Bulletin_Delivery_Job__c != null) {
				bulletinDeliveryJobIds.add(ba.Bulletin_Delivery_Job__c);
			}
		}
    	
		for(Bulletin_Accounts__c ba : [ Select Id, Status__c, Bulletin_Delivery_Job__c  
		                                From Bulletin_Accounts__c 
		                                Where Bulletin_Delivery_Job__c IN :bulletinDeliveryJobIds 
		                                And Status__c IN ('Not Started','Failed','Complete', 'Defect')]) {
			if (!mapBDJobAndAccounts.containsKey(ba.Bulletin_Delivery_Job__c)) {
				mapBDJobAndAccounts.put(ba.Bulletin_Delivery_Job__c, new List<Bulletin_Accounts__c>());
			}
			mapBDJobAndAccounts.get(ba.Bulletin_Delivery_Job__c).add(ba);
		}
    	
		lstForUpdateBDjob = getBDjobListForUpdate(mapBDJobAndAccounts);
		if (!lstForUpdateBDjob.isEmpty()){
		  update lstForUpdateBDjob;
		}
  }
    
	/***********************************************************************************************************
   * Method for get final list of Bulletin Accounts after check is status field update
   * @param newList List of Bulletin Accounts
   * @param oldMap Map of old Bulletin Accounts
   * @return List<Bulletin_Accounts__c>.
  ***********************************************************************************************************/
	private static List<Bulletin_Accounts__c> getLstBulletinAccount(List<Bulletin_Accounts__c> newList, Map<Id, Bulletin_Accounts__c> oldMap) {
		List<Bulletin_Accounts__c> lstFinalBulletinAccount = new List<Bulletin_Accounts__c>(); 
		if (oldMap != null) {
			for(Bulletin_Accounts__c ba : newList) {
				if (Utility.isNewOrChanged(ba, 'Status__c', oldMap)) {
					lstFinalBulletinAccount.add(ba);
				}
			}
		} else {
			lstFinalBulletinAccount.addAll(newList);
		}
		return lstFinalBulletinAccount;
	}
       
  /***********************************************************************************************************
   * Method for get BDjob List For Update
   * @param mapBDJobAndAccounts of job id and list of bulletin accounts
   * @return List<Bulletin_Delivery_Job__c>.
  ***********************************************************************************************************/
	private static List<Bulletin_Delivery_Job__c> getBDjobListForUpdate(Map<Id, List<Bulletin_Accounts__c>> mapBDJobAndAccounts){
		List<Bulletin_Delivery_Job__c> bbJobListForUpdate = new List<Bulletin_Delivery_Job__c>();
		for(Id bdJobId : mapBDJobAndAccounts.keySet()) {
			Boolean isNotStarted = false;
			Boolean isFalied = false;
			Boolean isComplete = false;
            Boolean isDefect = false;
			for(Bulletin_Accounts__c ba : mapBDJobAndAccounts.get(bdJobId)) {
				if (ba.Status__c == 'Not Started') {
					isNotStarted = true;
				} else if (ba.Status__c == 'Failed') {
					isFalied = true;
                } else if (ba.Status__c == 'Defect') {
					isDefect = true;
				} else {
					isComplete = true;
				}
			}
            if ((isNotStarted && isComplete) || (isNotStarted && isFalied)) {
				bbJobListForUpdate.add(new Bulletin_Delivery_Job__c(Id = bdJobId, Status__c = 'In Progress'));
			} 
            else if (isNotStarted && !isComplete && !isFalied) {
				bbJobListForUpdate.add(new Bulletin_Delivery_Job__c(Id = bdJobId, Status__c = 'Not Started'));
			} 
        	else if (!isNotStarted && isFalied) {
				bbJobListForUpdate.add(new Bulletin_Delivery_Job__c(Id = bdJobId, Status__c = 'Fail'));
			} 
            else if (!isNotStarted && isDefect) {
				bbJobListForUpdate.add(new Bulletin_Delivery_Job__c(Id = bdJobId, Status__c = 'Defect'));
			}
            else if (!isNotStarted && isComplete) {
				bbJobListForUpdate.add(new Bulletin_Delivery_Job__c(Id = bdJobId, Status__c = 'Completed'));
			}
            
		}
		return bbJobListForUpdate;
	}
}