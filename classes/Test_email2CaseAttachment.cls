@IsTest (SeeAllData=true)
public class Test_email2CaseAttachment {

    
    static testMethod void test() {
       
        Test.startTest();
        case ca = new case();
        insert ca;
        
        emailmessage em = new emailmessage();
        em.parentID = ca.id;
        insert em;
        
        attachment a = new attachment();
        a.ParentId = em.id;
        
        string body1='abc';
		Blob b = Blob.valueOf(body1);
		a.Name = 'Test Attachment for Email';
		a.Body = b;
        a.ContentType = 'application/pdf';
        
        insert a; 
        
        id chatterpostID = [select id  from feeditem where parentID =:ca.id].id;
        system.assert(chatterpostID !=null);
    }
    
    
}