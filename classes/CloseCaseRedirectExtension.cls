public class CloseCaseRedirectExtension {

 	public String closeURL { get; set; }
    public case ca {get; set;}
    public String casenumber { get; set; }
    
    public CloseCaseRedirectExtension(ApexPages.StandardController controller)
    {
        ///https://success.salesforce.com/ideaview?id=08730000000Bqk0AAC
        case c = (Case) controller.getRecord();
    	ca = [select id, suppliedemail,subject, Contactid, casenumber from case where id=:c.id];
        closeURL =c.id + '/s?retURL=' + c.id + '&cas7=Closed';  
        casenumber = ca.casenumber;
    }   
}