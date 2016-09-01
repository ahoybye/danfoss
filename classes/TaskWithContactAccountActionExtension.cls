public class TaskWithContactAccountActionExtension {
    
    public Task t {get;set;}
    
    public TaskWithContactAccountActionExtension(ApexPages.StandardController stdController) {
        t = new Task(
            WhatId = stdController.getId(),
            Description = 'Added with Quick Create...'
        );
    }
    
    // Wrapper needed to support HTML5 date input
    public Date duedate {
        get { return t.ActivityDate; }
        set { t.ActivityDate = value; }
    }
    
    public void CreateTask() {
        try {
            insert t;
        } catch (DMLException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to Create Task...' + ex));       
            return;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Task Created...'));  
    }
    
}