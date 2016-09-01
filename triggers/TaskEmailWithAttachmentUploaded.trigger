trigger TaskEmailWithAttachmentUploaded on Attachment (after insert) {
    Set<Id> setTaskIds = new set<Id>();
    Map<Id, User> mapUsers = new Map<Id, User>();
    List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
    String BDJFrom;
    set<Id> setUserIds = new set<Id>();
    Map<Id, String> mapTaskAndBDJ = new Map<Id, String>();
    Map<Id, Bulletin_Delivery_Job__c> mapBDJIDAndBDJ = new Map<Id, Bulletin_Delivery_Job__c>();
    Map<Id, Attachment> mapAtts = new Map<Id, Attachment>();
    List<Attachment> lstAtts = new List<Attachment>();
    List<Task> lstTasks = new List<Task>();
    Map<Id, Task> mapTasks = new Map<Id, Task>();
    for(Attachment att: Trigger.New) {
        if (String.valueof(att.ParentId).left(3) == '00T') {
            setTaskIds.add(att.ParentId);
        }
    }   
    
    if (!setTaskIds.isEmpty()){     
        mapTasks = new Map<Id, Task>([select Id, OwnerId, CreatedById, WhatId, Subject, ActivityDate, Bulletin_Delivery_Job__c, Priority, Uploaded__c From Task where Id in :setTaskIds]);
        lstAtts = new List<Attachment>([select Id, ParentId, Name, Body, BodyLength from Attachment where ParentId in :setTaskIds]);
        lstTasks = [select Id, OwnerId, CreatedById, Subject, ActivityDate, Bulletin_Delivery_Job__c, Priority, Uploaded__c From Task where Id in :setTaskIds];
    }
    if (!lstTasks.isEmpty()){
        for (Task tsk :lstTasks) {   
            mapTaskAndBDJ.put(tsk.Id, tsk.Bulletin_Delivery_Job__c);
            setUserIds.add(tsk.CreatedById);
        }    
        for (User u :[Select Id, Name From User where Id IN :setUserIds])
            mapUsers.put(u.Id, u);    
        List<Bulletin_Delivery_Job__c> lstBDJs = [select Id, CreatedBy.Name From Bulletin_Delivery_Job__c where Id in :mapTaskAndBDJ.values()];
        for (Bulletin_Delivery_Job__c b : lstBDJs){
            mapBDJIDAndBDJ.put(b.Id, b);
        }
    }
    if (!lstAtts.isEmpty()){
        for (Attachment a :lstAtts)
            mapAtts.put(a.ParentId, a);
        for (Task tsk :mapTasks.values()) {     
            if(tsk.Uploaded__c == true && tsk.WhatId != null && tsk.WhatId.getSobjectType() == Contract__c.SObjectType) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(tsk.OwnerId);
                mail.setSubject(tsk.Subject);  
                DateTime ad = tsk.ActivityDate;
                string template;
                if (tsk.Bulletin_Delivery_Job__c != null && tsk.Bulletin_Delivery_Job__c != ''){
                    BDJFrom = mapBDJIDAndBDJ.get(tsk.Bulletin_Delivery_Job__c).CreatedBy.Name;
                    template = BDJFrom + ' has assigned you the following new task:' + '\n\n';
                }
                else {
                    template = mapUsers.get(tsk.CreatedById).Name + ' has assigned you the following new task:' + '\n\n';
                }
                template+= 'Subject: ' + tsk.Subject + '\n';
                template+= 'Due Date: ' + ad.format('dd-MMM-yyyy') + '\n';
                template+= 'Priority: ' + tsk.Priority + '\n\n';
                template+= 'For more details, click the following link:\n\n';
                template+= URL.getSalesforceBaseUrl().toExternalForm() + '/' + tsk.Id;
                mail.setSaveAsActivity(false);
                mail.setPlainTextBody(template);
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                for (Attachment a : mapAtts.values()) {
                    if (tsk.Id == a.ParentId) {
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(a.Name);
                        efa.setBody(a.Body);
                        fileAttachments.add(efa);
                    }
                }
                mail.setFileAttachments(fileAttachments);
                lstMsgsToSend.add(mail);
            } 
        }
    }

    if (!lstMsgsToSend.isEmpty())
        Messaging.SendEmail(lstMsgsToSend);
}