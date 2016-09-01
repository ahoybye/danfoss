trigger CaseTrigger on Case (after update, before insert, after insert, before update) {
    
    If(Trigger.isInsert && Trigger.isAfter)
    {
         //Added 28th April - requirement to match the content of incoming emails 
        //casetrigger.checkCaseDescription(Trigger.new);

        futureFlow.runCaseAssignment(Trigger.new);
        
        //Added on 12-04-2016 - This method is update Contact,Account and Origin fields from the FAX Number
        set<Id> caseIds= new set<Id>();
        for(Case C:Trigger.New)
        caseIds.add(c.Id);
        CaseHandlerFuture.assignContactFromFax(caseIds);
        
    }
    
    If(Trigger.isAfter & Trigger.isUpdate && !system.isFuture())
    {
        futureFlow.myMethod(Trigger.newMap.keySet());
    }

    if(Trigger.isBefore && Trigger.isInsert){ //for Pricing Cases
        CaseTriggerHandler.assignToAccountManager(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){ //for Pricing Cases
        CaseTriggerHandler.updateCaseStatus(Trigger.new);
    }
    
    // Pass the Cases to the processing class to validate the Customer type field 
    // for different segments for CSC cases only
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
       if(TriggerContextUtility.isFirstRun()){
         TriggerContextUtility.setFirstRunFalse();
         FutureFlow.processCaseAccountType();
        }
    }
   
}