public with sharing class QuoteTabController {
    //Public List<Quote> quoteList {get; set;}
    public ApexPages.StandardSetController setCon {get;set;}
    Public List<SelectOption> listViewOptions {get; set;}
    Public String selectedListView {get; set;}
    public boolean showField_DueDate {get; set;}
    public boolean showField_Responsible {get; set;}
    
    
    public QuoteTabController() {
        
        listViewOptions = new List<SelectOption>();
        listViewOptions.add(new SelectOption('RECENTLY_VIEWED_QUOTES','Recently Viewed Quotes'));
        listViewOptions.add(new SelectOption('MY_OPEN_QUOTES','My Open Quotes'));
        listViewOptions.add(new SelectOption('MY_TEAMS_QUOTES','My team’s Open Quotes'));
        listViewOptions.add(new SelectOption('MY_QUOTES_FOLLOWUP','My Quotes for follow-up'));
        listViewOptions.add(new SelectOption('MY_QUOTES_FOLLOWUP_THISWEEK','My Quotes for follow-up (this week)'));
        selectedListView = 'RECENTLY_VIEWED_QUOTES';
        getQuotes();
    }
    
    public void getQuotes() {
        
        Id currentUserId = UserInfo.getUserId();
        Id currentUserRoleId=UserInfo.getUserRoleId();
        List<string> excludeStatus = new List<string>{'Rejected', 'Accepted', 'Stopped'};
        string query='';
        //string query = 'SELECT Id, quoteNumber, name, Status, Valid_To__c, Requested_Quote_Delivery_Date__c, Task_Due_Date__c, Custom_Account_Lookup__c, ContactId, OpportunityId, TotalPrice, Responsible__c FROM Quote';
        string query_select = 'SELECT Id, quoteNumber, name, Status, Valid_To__c, Requested_Quote_Delivery_Date__c, Task_Due_Date__c, Custom_Account_Lookup__c, ContactId, OpportunityId, TotalPrice, Responsible__c, ';
        string query_task_select = '(Select Id, Subject, ActivityDate from Tasks Where IsClosed=false Order by ActivityDate ASC Limit 1)';
        string query_from = ' FROM Quote';        
        string query_where = ' WHERE status <> :excludeStatus';
        
        if (selectedListView == 'MY_OPEN_QUOTES') {
            
            query = query_select + query_task_select + query_from + query_where;            
            query = query + ' AND responsible__c=:currentUserId';
            query = query + ' ORDER BY Valid_To__c asc';
            query = query + ' LIMIT 500';
            
            //setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            List<Quote> qlist = Database.query(query);
            for (Quote qs : qlist) {
                if (qs.Tasks.size()>0) {
                    qs.Task_Due_Date__c = qs.Tasks[0].ActivityDate;                    
                }                
            }
            setCon = new ApexPages.StandardSetController(qlist);
            showField_Responsible=false;
            showField_DueDate=true;
            
        } else if (selectedListView == 'MY_TEAMS_QUOTES') {
        
            Set<ID> subordinateUserSet = RoleHierarchyHelper.getRoleSubordinateUsers(currentUserId);            
            List<User> peerList = [SELECT id FROM user where userroleid=:currentUserRoleId and isactive=true and UserRoleId!=null limit 100];
            query = query_select + query_task_select + query_from + query_where;
            query = query + ' AND (responsible__c=:subordinateUserSet OR responsible__c=:peerList )';
            query = query + ' ORDER BY Valid_To__c asc';
            query = query + ' LIMIT 500';
            
            //setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            List<Quote> qlist = Database.query(query);
            for (Quote qs : qlist) {
                if (qs.Tasks.size()>0) {
                    qs.Task_Due_Date__c = qs.Tasks[0].ActivityDate;
                }                
            }
            setCon = new ApexPages.StandardSetController(qlist);
            
            showField_Responsible=true;
            showField_DueDate=true;
            
        } else if (selectedListView=='MY_QUOTES_FOLLOWUP') {
            query = query_select + query_task_select + query_from + query_where;
            
            query = query + ' AND responsible__c=:currentUserId';
            query = query + ' LIMIT 500';
            
            
            // Sort based on earliest task's ActivityDate - using a custom sort class (implementing Comparable)
            List<Quote> qlist = Database.query(query);
            List<QuoteSort> qsortedlist = new List<QuoteSort>();
            for (Quote qs : qlist) {  // only add it if there is a date
                if (qs.Tasks.size()>0) {
                    qs.Task_Due_Date__c = qs.Tasks[0].ActivityDate;
                    qsortedlist.add(new QuoteSort(qs));
                }                
            }
            qsortedlist.sort();
            
            qlist.clear();
            for (QuoteSort qs : qsortedlist) {
                qlist.add(qs.quote);
            }
            setCon = new ApexPages.StandardSetController(qlist);
            
            showField_Responsible=false;
            showField_DueDate=true;
        } else if (selectedListView=='MY_QUOTES_FOLLOWUP_THISWEEK') {
            // extra filter on the task sub select - to only get tasks within current week
            query_task_select = '(Select Id, Subject, ActivityDate from Tasks Where IsClosed=false and ActivityDate = THIS_WEEK Order by ActivityDate ASC Limit 1)';
            query = query_select + query_task_select + query_from + query_where;
            query = query + ' AND responsible__c=:currentUserId';            
            query = query + ' LIMIT 500';
            
            // Sort based on earliest task's ActivityDate - using a custom sort class (implementing Comparable)
            List<Quote> qlist = Database.query(query);
            List<QuoteSort> qsortedlist = new List<QuoteSort>();
            for (Quote qs : qlist) {
                if (qs.Tasks.size()>0) { // only add it if there is a date
                    qs.Task_Due_Date__c = qs.Tasks[0].ActivityDate;
                    qsortedlist.add(new QuoteSort(qs));
                }                
            }
            qsortedlist.sort();
            
            qlist.clear();
            for (QuoteSort qs : qsortedlist) {
                qlist.add(qs.quote);
            }
            setCon = new ApexPages.StandardSetController(qlist);
            
            showField_Responsible=false;
            showField_DueDate=true;
        } else if (selectedListView == 'RECENTLY_VIEWED_QUOTES') {
            query = query_select + query_task_select + query_from;            
            query = query + ' WHERE LastViewedDate !=null';
            query = query + ' ORDER BY LastViewedDate DESC';
            query = query + ' LIMIT 15';
            
            //setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            List<Quote> qlist = Database.query(query);
            for (Quote qs : qlist) {
                if (qs.Tasks.size()>0) {
                    qs.Task_Due_Date__c = qs.Tasks[0].ActivityDate;                    
                }                
            }
            setCon = new ApexPages.StandardSetController(qlist);
            showField_Responsible=true;
            showField_DueDate=true;
        }
        
        setCon.save();
        setCon.setPageSize(20);
        if(setCon.getResultSize() == 0) {
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No quotes for this selection');
            //ApexPages.addMessage(myMsg);  
        }
    }
    
    public List<quote> getQuoteList() {
        return (List<Quote>) setCon.getRecords();
    } 
    
    public class QuoteSort implements Comparable {

        public Quote quote;
    
        // Constructor
        public QuoteSort(Quote q) {
            quote = q;
        }
        
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to QuoteSort
            QuoteSort compareToQuote = (QuoteSort)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            
            if (quote.Task_Due_Date__c > compareToQuote.quote.Task_Due_Date__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (quote.Task_Due_Date__c < compareToQuote.quote.Task_Due_Date__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    
}