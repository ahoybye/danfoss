/****************************************************************************************************************************************** 
 * Class Name   : DuplicateCaseCheck
 * Description  : Check the Incoming email and validate whether the Email is related to previous Case
 *              : Scenario: A user can copy others while sending an email into Salesforce. In a typical world, 
 *                these could be either their own management folks, team members. When these folks who are copied on the email, 
 *                respond to the original email to ask an update or provide additional information, Salesforce will end up creating a 
 *                second case instead of updating the case. This is because the original email will not have the Thread Id so the system 
 *                assumes that you are sending in the email the first time.
 *      
 * Created By   : Subhabrata Basu, Salesforce
 */
public class DuplicateCaseCheck{

    public static void processIncomingEmail(List<EmailMessage> IncomingEmail){
    string CONS_REFID       = 'ref:_';                                          // Pattern to match Salesforce REF IDs
        string CONS_DUPSTATS    = 'Duplicate';                                      // Status to be tagged on duplicate cases
        
        list<EmailMessage> incomingEmails   = new list<EmailMessage>();             // List of emails that are being sent into Salesforce
        set<Id> incomingParentIds           = new set<Id>();                        // List (set) of Case Ids associated with emails that are sent into Salesforce
        map<Id, Case> incomingCases         = new map<Id, Case>();                  // Map of Cases related to the emails sent into Salesforce
        
        map<String, EmailMessage> referenceMsgs = new map<String, EmailMessage>();  // Each email will contain a set of References (RFC Param), this map will have that mapping
      
        // If a case already has Salesforce REF ID in its Subject or Body then let Salesforce take care of managing the email.
        for(EmailMessage em : IncomingEmail){
    
            if(em.Incoming){
                string subject  = em.Subject != null ? em.Subject : '';
                string body     = em.TextBody != null ? em.TextBody : '';
                
                // Ref ID could be in Subject and/or Body, so ignore those emails
                if(!subject.contains(CONS_REFID) && !body.contains(CONS_REFID)){
                    incomingEmails.add(em);
                    incomingParentIds.add(em.ParentId);
                }
            }
            
        }
        // After the above FOR loop, you will have a list of emails that are either brand New (meaning case should be created) or is a candidate for duplicate check
        // IncomingEmails list will have those emails and IncomingParentIds will have the list of cases that are associated to those emails
        // All these emails do not necessarily mean they are duplicate, there could be genuine new emails in it so the next step is to identify those
    
        // Get these cases so we can update the RFC Message Id field with the information from the email.
        if(!incomingParentIds.isEmpty()){
            for(Case c : [SELECT Id, RFC_Message_Id__c
                            FROM Case
                            WHERE Id In :incomingParentIds])
                incomingCases.put(c.Id, c);
        }
    
        /* 
            The next set of code is to parse out the RFC params from the Email Header - Message Id and References. 
            
            Here is how the parameters look like in a typical email exchange
            ---------------------------------------------------------------------------------------------------------
            Scenario                    |   Message Id      |   References      |
            ---------------------------------------------------------------------------------------------------------
            Seller sends a new email    |                   |                   |
            and copies userA and userB  |       M1          |   Not Available   |
            on the email                |                   |                   |
            ---------------------------------------------------------------------------------------------------------
            UserA replies on top of the |                   |                   |
            email that Seller sent      |       M2          |   M1              |
                                        |                   |                   |
            ---------------------------------------------------------------------------------------------------------
            UserB replies on top of the |                   |                   |
            email that UserA sent       |       M3          |   M1 M2           |
                                        |                   |                   |
            ---------------------------------------------------------------------------------------------------------
        */
        for(EmailMessage em : incomingEmails){
    
            if(em.Headers != null) {
                String header = em.Headers; 
                String [] rfcParams = header.split('\n');
        
                for(String param : rfcParams){
                    String[] keyVal;
                    // RFC Param Message Id Parsing
                    if(param.startsWith('Message-ID:')){        // Message-ID: <CABA6inOcuV6kgn46hroaaBnEsf1sCx5k2JsMvk6iKQSsXj8FHA@mail.gmail.com>
                        keyVal = param.split(':');              // 2 array values Message-ID, <CABA6inOcuV6kgn46hroaaBnEsf1sCx5k2JsMvk6iKQSsXj8FHA@mail.gmail.com>
                        
                        // Get the Message Id and stamp it on the case, this is used as the key to look for cases in duplicate check
                        Case c = incomingCases.get(em.ParentId);
                        c.RFC_Message_Id__c = keyVal[1].trim(); // Trim the value as there is space before and after the Message Id in the Header
                        incomingCases.put(em.ParentId, c);
                    }
                    
                    // RFC Param References Parsing (it may or may not be there)
                    if(param.startsWith('References:')){        // References: <31339349235632339@unknownmsgid> <-8806630126809707804@unknownmsgid>
                        keyVal = param.split(':');              // 2 array values References, <31339349235632339@unknownmsgid> <-8806630126809707804@unknownmsgid>
                        keyVal = keyVal[1].split(' ');          // 2 array values <31339349235632339@unknownmsgid>, <-8806630126809707804@unknownmsgid>
        
                        for(String ref : keyVal){               // Map reference id to email, useful for duplicate check below
                            if(!referenceMsgs.containsKey(ref.trim()))
                                referenceMsgs.put(ref.trim(), em);
                        }
                    }
                }
            }    
        }
        
        // From the above big table, you can see that for replies w/o ref Id, the References will indicate whether the user is replying to a email thread
        // or is it a brand new email. Since we are always stamping the Message Id on the Case and since Message Ids are what is set in RFC References
        // parameter, you can look for Cases having the Message Ids to see if there is a case in Salesforce already
        if(!referenceMsgs.isEmpty()){
            for(Case c : [SELECT Id, RFC_Message_Id__c
                            FROM Case
                            WHERE RFC_Message_Id__c In :referenceMsgs.keySet()                                
                          		AND Status  != :CONS_DUPSTATS
                                AND RFC_Message_Id__c != null]){
                				// AND IsClosed = false
                EmailMessage originalMsg = referenceMsgs.get(c.RFC_Message_Id__c);
    
                if(originalMsg != null){
                    Case dup    = incomingCases.get(originalMsg.ParentId);
                    if (dup != null)  { // check if case is not already handled (re-parented)
                    	dup.Status  = CONS_DUPSTATS;
                    	dup.ParentId = c.Id;
                    	incomingCases.put(originalMsg.ParentId, dup);
                    }
                	
                    // Re-parent the email to the original case so replies can always go out from one case
                	originalMsg.ParentId = c.Id;
                }
                
                
            }
        }
        
        if(!incomingParentIds.isEmpty())
            update incomingCases.values();
    }


}