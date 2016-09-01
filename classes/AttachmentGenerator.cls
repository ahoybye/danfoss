global class AttachmentGenerator {
   webService static String AttachPDFToQuote(string Id) {
        string retRes = '';
        try
        {
         PageReference pageRef = new PageReference('/apex/QuotePDF?Id='+Id);
        // if(!Test.isRunningTest()) {
         	Blob content = pageRef.getContent();
         	QuoteDocument doc = new QuoteDocument(Document = content, QuoteId = Id);
         	insert doc;
        // }

         retRes='SUCCESS';
         return retRes;
       } catch(exception ex) {
           System.debug('--- Error ----------'+ ex);
           retRes= ex.getMessage();
           return retRes;
       }
   }
    
    webService static string SaveAndEmail(string Id) {
        string retRes = '';
        try
        {
         Quote q = [Select ContactId from Quote Where Id = :Id];
         Contact con = [Select Id from Contact Where Id = :q.ContactId];
         //if(!Test.isRunningTest()) {
             PageReference pageRef = new PageReference('/apex/QuotePDF?Id='+Id);
         Blob content = pageRef.getContent();
         QuoteDocument doc = new QuoteDocument(Document = content, QuoteId = Id);
         insert doc;
         return String.valueOf(new PageReference('/_ui/core/email/author/EmailAuthor?p2_lkid=' + con.Id + '&rtype=003&p3_lkid=' + Id + '&doc_id=' + doc.Id + '&retURL=%2F' + Id).getUrl());
        // }
         //   else
           //     return null;
       } catch(exception ex) {
           System.debug('--- Error ----------'+ ex);
           retRes= ex.getMessage();
           return retRes;
       }
   }
}