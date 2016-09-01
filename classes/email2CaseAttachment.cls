public class email2CaseAttachment {

    public static void chatterAttachment(List<attachment> triggerAttachments) { 
    ID caseId;   
    list<id> emailmsgids = new list<id>();
    list<emailmessage> emails = new list<emailmessage>();
    list<Attachment> attachments = new list<Attachment>();
    Map<id,emailmessage> emailMap = new Map<id,emailmessage>();
    list<FeedItem> listOfFeedFiles = new List<FeedItem>();  
        
    //Loop thru & get a list of attachments associated with an email and a list of the emails ids
    for( Attachment a : triggerAttachments ) {  
     if( a.parentid != null )
            {     
                String s = a.parentid;     
                if( s.substring( 0, 3 ) == '02s' ) // 02s is for emailmessage
                    {  
                            emailmsgids.add(a.parentid);
                            attachments.add(a);
                    }
            }
    }
    
    //get a map of the email id to the Case ID
    emails =[select parentID, ID, subject from EmailMessage where id in:emailmsgids];
    for(EmailMessage e : emails){emailMap.put(e.ID,e);}
 
    //for all of the attchments, create a chatter post
    for( Attachment a : attachments ) {  
        
        caseId = emailMap.get(a.ParentId).parentID ;
        String caseIdStr = emailMap.get(a.ParentId).parentID ;
        //Create a chatter post only when the parent of the email is a Case
        if( caseIdStr.substring( 0, 3 ) == '500' )
        {
                FeedItem post = new FeedItem();
                post.ParentId = caseId; //eg. Opportunity id, custom object id..
                post.Body = 'Attachment added from Email Subject: '  + emailMap.get(a.ParentId).subject + ' Attachment Filename:' +a.name ;
                post.Type = 'ContentPost';
                post.ContentData = a.body; 
                post.ContentFileName = a.Name;
                //post.Title = 'Email:'  + emailMap.get(a.ParentId).subject + ' Filename:' + a.Name;
                post.Title = ('Filename:' + a.Name).left(255);
                listOfFeedFiles.add(post);
        } 
                    }
         
    if(listOfFeedFiles!=null){
        insert listOfFeedFiles; 
    }
           }
}