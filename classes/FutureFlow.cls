global class FutureFlow {

    
          public static void runCaseAssignment(List<case> cases) {  
                id rt =[select id from recordtype where developername  ='Support_Case'].id;
                List<Id> caseIds = new List<Id>{};
                for (Case theCase:cases) 
                {caseIds.add(theCase.Id);}
                List<Case> caseupdate = new List<Case>{}; 
        
                    for(Case c : [Select Id, origin, subject, RecordTypeId, Requestor_Internal_Users__c from Case where Id in :caseIds])
                        {
                           if (c.origin == 'Internal' && c.RecordTypeId == rt && c.Requestor_Internal_Users__c!=null)
                            {
                               
                                //system.debug('trigger running');
                                Database.DMLOptions dmo = new Database.DMLOptions();
                                dmo.assignmentRuleHeader.useDefaultRule = true;
                                c.setOptions(dmo);
                                caseupdate.add(c);
                             
                            }
                        }
        update caseupdate;            
         
}
    
    
  @future 
  global static void myMethod(Set<Id> setCaseIDs) {
        
        List<Case> caseList = [Select Id, isclosed, owner.type From Case Where Id IN :setCaseIDs];
        List<Case> updatelist = new List<Case>();
      
        for (case c :caseList)
        {
            if (c.Owner.type == 'Queue' && c.IsClosed == false)
            {
                c.Assigned_to_Queue__c = true;
                updatelist.add(c);
            }
            update updateList;
                
  }

}
    
    /**
       @Method Name  : processCaseAccountType
       @description  : Method to process the Incoming CSC cases to identify whether Customer Type for all segements
                       are same or different.
       @param        : NA
       @return       : NA
    */ 
    public static void processCaseAccountType(){
    
        system.debug('IIIIIIIIIIIIIIIIIIIIIIIII');
        
        Set<Id> recordTypeIds = new Set<Id>();
        Map<Id, List<Case>> caseContactMap = new Map<Id, List<Case>> ();
        Map<Id, Case> oldCaseValues = (Map<Id, Case>)Trigger.oldMap;
        List<String> cscRecordTypeNames = new List<String>{'Complaint',  'Product Inquiry', 'Service Request', 
                                                           'Support Case', 'Transactional Request'};
        List<String> projectCustomerType = new List<String>{'End User','Others','Consultant','Installer/Contractor' };
        Set<String> caseAccountType = New Set<String>();
        List<String> caseCustomerType = new List<String>();
        
        for(RecordType rt : [SELECT Id,Name FROM RecordType WHERE SobjectType='Case' AND Name IN :cscRecordTypeNames]) {
            recordTypeIds.add(rt.Id);
        }
        
        for(Case processingCase : (List<Case>)Trigger.New){
            if(recordTypeIds.contains(processingCase.recordTypeId) && 
                (Trigger.isInsert && processingCase.ContactId!=NULL) || 
                (Trigger.isUpdate && processingCase.ContactId!=oldCaseValues.get(processingCase.Id).ContactId)){
                
                if(caseContactMap.keySet().Contains(processingCase.ContactId)){
                    caseContactMap.get(processingCase.ContactId).add(processingCase);
                }
                else{
                    caseContactMap.put(processingCase.ContactId, new List<Case>{processingCase});
                }
        
            }
        }
        
        
        for(Contact caseContact : [Select Id, Account.Customer_Type_1_RCCC__c, Account.Customer_Type_1_PE__c,
                                        Account.Customer_Type_1_DEN__c, Account.Customer_Type_1_HS__c from Contact
                                        WHERE Id IN :caseContactMap.keySet()]){
            if(caseContact.Account.Customer_Type_1_RCCC__c != 'none')
                caseAccountType.add(caseContact.Account.Customer_Type_1_RCCC__c);                           
            if(caseContact.Account.Customer_Type_1_PE__c != 'none')
                caseAccountType.add(caseContact.Account.Customer_Type_1_PE__c); 
            if(caseContact.Account.Customer_Type_1_DEN__c != 'none')
                caseAccountType.add(caseContact.Account.Customer_Type_1_DEN__c); 
            if(caseContact.Account.Customer_Type_1_HS__c != 'none')
                caseAccountType.add(caseContact.Account.Customer_Type_1_HS__c);                             
            
            if(!caseAccountType.isEmpty()){
                Integer acTypeSetSize = caseAccountType.size();
                if(acTypeSetSize == 1){
                    caseCustomerType.addAll(caseAccountType);
                    for(Case caseToUpdate : caseContactMap.get(caseContact.Id)){
                        caseToUpdate.Account_Customer_Type__c = caseCustomerType[0];
                    }
                }
                else if(acTypeSetSize > 1){
                    caseAccountType.removeAll(projectCustomerType);
                    if(caseAccountType.size() == 0){
                        for(Case caseToUpdate : caseContactMap.get(caseContact.Id)){
                            caseToUpdate.Account_Customer_Type__c = projectCustomerType[(Math.random()*(acTypeSetSize-1)).intValue()];
                        }
                    }
                }
            }
            caseAccountType.clear();
            caseCustomerType.clear();
        }
    
    
    }


}