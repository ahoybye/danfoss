trigger UpdateOrigBDJWithDefectBDJ on Bulletin_Delivery_Log__c (after update) {
    Id bdjId;
    Id defectJobId;
    Id record_Type_BDJ;
    for (RecordType recType : [Select id From RecordType Where SobjectType = 'Bulletin_Delivery_Job__c' and Name = 'Defect_Correction']) {
       record_Type_BDJ = recType.ID;
    }
 
    for (Bulletin_Delivery_Log__c bdLog :Trigger.new){
       bdjId = bdLog.Bulletin_Account__c;
       defectJobId = bdLog.Old_Job_Information_ID__c;
    }
    
    Bulletin_Accounts__c ba = [select Bulletin_Delivery_Job__c, Bulletin_Delivery_Job__r.Defective_Bulletin_Delivery_Job__c From Bulletin_Accounts__c where Id = :bdjId];
    Bulletin_Delivery_Job__c BDJ = [select Defective_Bulletin_Delivery_Job__c From Bulletin_Delivery_Job__c where Id = :ba.Bulletin_Delivery_Job__r.Id];
    BDJ.Corrective_Bulletin_Delivery_Job__c = defectJobId;
    update BDJ;
}